---
name: ui-to-code
description: Figma → 既有 Angular 元件 / 單一 class 換版前置作業（v5）。新平台切版專用——只動 html/scss，TS 邏輯幾乎不動。輸入支援元件 selector 或 `.class`。產出節點對照 / 落差盤點 / 切版計畫，不直接切版
user_invocable: true
---

# /ui-to-code：Figma 換版前置作業（新平台切版專用）

把 Figma 設計稿「一比一」落地到既有 Angular 元件的**前置作業**。

> **定位**：本 skill 是**新平台切版專用**。切版只動 `.html` / `.scss`，**TS 邏輯幾乎不會動**——只有當設計帶來的 UX 改動「必須在 TS 操作」（如元件種類改變、新增互動、資料來源改變）時才動，且**一律先問使用者**。
> **邊界**：本 skill **只做前置盤點＋規劃**（對照 / token / 落差 / 計畫），**不直接逐行切版**。產出經使用者確認 §決策 Gate 後，才進入實際切版。
> ⚠️ **換膚適用範圍**：**只有元件路徑／名稱含 `lottery` 的元件才需要做換膚**（token + skin map + `@include v()`）。其餘元件（user-center、設定頁…）**無換膚需求** → scss **直接落 Figma 值**，**不做 token、不動 `scss/skins/*`**。Step 5（判定 skin）與 Step 8（token 規劃）**只在 lottery 元件適用**。
> 完整工作流與 worked example 見 `claude_docs/ui-to-code-workflow.md`。

## 用法

支援兩種「目標」：**元件 selector**（整個元件三件套）或**單一 class**（只切某個區塊 / 共用 class，可不對應獨立元件）。class 以 `.` 開頭辨識。

| 輸入 | 行為 |
|------|------|
| `/ui-to-code <selector> <figma-url>` | 對整個元件做換版前置作業 |
| `/ui-to-code .<class> <figma-url>` | 只對單一 class 對該 Figma 節點切版 |
| `/ui-to-code app-account-setting https://figma.com/design/2ZC.../?node-id=1-10829` | 元件範例 |
| `/ui-to-code .router-path https://figma.com/design/2ZC.../?node-id=1-10942` | class 範例（麵包屑「个人 / 个人中心」區塊） |

**必備輸入**：
- 目標：**元件 selector**（如 `app-account-setting`）**或** **單一 class**（如 `.router-path`，`.` 開頭）
- Figma 節點連結 → 解析出 `fileKey` 與 `nodeId`
- 目標平台 project（如 `krm-web`；未指定則從元件 / class 所在路徑推斷）

> URL 解析：`figma.com/design/:fileKey/:name?node-id=1-2` → `fileKey=:fileKey`、`nodeId=1:2`（MCP 傳 `1:2`）。

> **目標型別判斷**：輸入以 `.` 開頭 → **class 模式**（見 Step 1 的 class 分支）；否則 → **元件模式**。class 模式只動「該 class 對應的樣式」（component scss 或 `_common.scss`），不會去碰整個元件的其他區塊；class 模式通常 **HTML/TS 完全不動**，純改 scss。

## 中止/繼續決策

**立即中止：**
- 當前在主線分支（`beta` / `master` / `master_for_daddy`）→ 先開功能分支（`feature/{user}/ui-to-code-{元件}`）再動工。
- Figma 連結**無 `node-id`** → 回頭跟使用者要節點層級的連結，**不可臆測 nodeId**。
- 找不到 selector 對應元件、或 class 模式 grep 不到該 class 的定義 → 列出 grep 結果讓使用者確認。
- 盤點出 **C 類落差（涉及 TS / UX）** → 停在 §決策 Gate，不自行決定。

**繼續不停：**
- 只有 A 類（純外觀）/ B 類（結構但不漏資料）落差 → 照常完成前置產出。

## 流程

### Step 0 — Node.js 版本（若後續要驗證／切版才需要）
```bash
export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh" && nvm use 20.12.2 && node -v
```
前置作業本身（讀檔 / 讀 Figma）不需 Node，可略過。

### Step 1 — 定位目標（依模式分支）

**元件模式**（`app-xxx`）：
```bash
grep -rn "<selector>" code/f2e/v5/projects/<proj>/src --include="*.ts" -l
```
鎖定 `*.component.html` / `*.component.scss` / `*.component.ts`，並列出子資料夾（子元件），判斷哪些屬於本次範圍。

**class 模式**（`.xxx`）：先找出該 class 在哪定義、哪些頁面用到，判斷改全域或單一元件：
```bash
# 1) class 樣式定義在哪（component scss？還是 _common.scss / 共用 scss？）
grep -rn "\.<class>\s*{" code/f2e/v5/projects/<proj>/src/scss code/f2e/v5/projects/<proj>/src/app --include="*.scss"
# 2) class 被哪些 html 使用（評估影響範圍）
grep -rln "<class>" code/f2e/v5/projects/<proj>/src/app --include="*.html"
```
- 定義在某 `*.component.scss` 且只該頁用 → 改該元件 scss。
- 定義在 `_common.scss` 等共用檔、跨多頁用 → **直接改 `_common.scss`**（re-skin 一致套用；改前確認所有引用頁都該套用，見紅線）。
- class 模式 Step 4 的「讀現有三件套」可只讀**該 class 相關的 scss/html 片段**，通常不需動 TS。

### Step 2 — 讀 Figma 結構（節點樹）
`mcp__figma__get_metadata({ fileKey, nodeId })` → frame/instance 階層、命名、座標、尺寸。
> get_metadata 只給結構不給樣式，後面一定要再取截圖／變數。

### Step 3 — 讀 Figma 視覺 + 變數 + **間距 + 比例**
- `mcp__figma__get_screenshot({ fileKey, nodeId, maxDimension: 1600 })` → 用 `curl -o` 抓短效 URL 的 PNG，再 Read。
- `mcp__figma__get_variable_defs({ fileKey, nodeId })` → 顏色 / 陰影 / 字級變數。
- **間距（padding / margin / gap）要從節點座標推導**：`get_metadata` / `get_design_context` 的 `x/y/width/height` 與 `inset-[…]` 就是設計間距來源。相鄰節點 x/y 差 = gap / margin；子節點相對父框的 x/y 內縮 = padding。
- **比例（尺寸 / 佔比 / 長寬比）也要一起量**：同樣從 `width/height` 推導——
  - **元素佔比**：子節點 `width` ÷ 父框 `width` = 該區塊寬度佔比（如卡片寬 = 父框 90%、兩欄各佔 48%）。
  - **長寬比**：圖片 / 卡片 / icon 的 `width:height`（如 banner 16:9、logo 1:1）→ 換圖換版時須維持，避免變形（參考近期「banner 圖片改 object-cover 避免變形」教訓）。
  - **相對尺寸節奏**：字級、icon 尺寸、圓角半徑彼此的相對大小關係，換色時若只改色值會破壞原設計的層級比例。
- ⚠️ **換色 ≠ 只換色值**：reskin 換版常被誤當「只改顏色」，但 Figma 改版往往連 **間距與比例** 一起調整。**切版要把間距與比例一起對齊設計，不可只換顏色/字級而沿用舊版的尺寸與佔比。**
  > 響應式版面（%/flex）無法逐 px 對齊時，取設計的「比例與節奏」對齊（欄寬佔比、卡內內縮、長寬比、區塊垂直節奏），用 `%` / `aspect-ratio` / `flex` 比例值表達，並在 scss 註明對應的 Figma px 值與算出的比例。

### Step 4 — 讀現有元件三件套
完整讀 html/scss/ts，重點：
- 現有 DOM 結構與 class（切版**沿用 DOM**，只換外觀）。
- scss 是硬編碼還是已 token 化（決定 token 工作量）。
- ts 的畫面綁定（`[(ngModel)]` / `(click)` / `*ngIf` / `*ngFor`）——切版不可破壞。

### Step 5 — 判定對應 Skin（v5 換膚關鍵；**僅 lottery 元件適用**）
> **先判斷：元件路徑／名稱含 `lottery` 嗎？** 否 → **跳過本步與 Step 8**，scss 直接落 Figma 外觀（單一固定樣式）。是 → 才往下判定 skin。

Figma 通常只畫單一 skin 的長相，先確認是哪個：

| Skin | 名稱 | 模式 | 判斷 |
|------|------|------|------|
| `classic` | 預設 | light | fallback |
| `pink` / `blue` / `green` | — | light | |
| `purple` | 宇宙紫 | **dark** | `ThemeService.getSkinMode()` 只有 purple 回 `dark` |

> 深色底＋紫/桃紅 → 幾乎是 **purple（宇宙紫 / dark）**。對應的 Skin 範圍是 §決策 Gate 第 1 題。

### Step 6 — 節點 → DOM → token 對照
把 Step 2 的節點逐一對到現有 DOM 的 class，再對到要用的 token（格式見 workflow 文件 §5.1）。

### Step 7 — 盤點落差（A / B / C）
- **A 純外觀**（色 / 圓角 / 間距 / **比例（佔比 / 長寬比 / 相對尺寸）** / 陰影 / 字級）→ 改 scss（lottery 走 token；非 lottery 直接落值）。**換色時連間距與比例一併盤點，逐項對照新舊值列出，不可只列顏色差異。**
- **B 結構**（多／少區塊、重排）→ 改 html，需確認不漏資料。
- **C 涉及 TS / UX**（元件種類變、新互動、資料來源變）→ **停下問使用者**。

### Step 8 — Token 規劃（**僅 lottery 元件適用**；切版規範：樣式必須走 token）
> 非 lottery 元件**跳過本步**：無換膚需求，於 `*.component.scss` 直接落 Figma 值即可，不建 token、不動 skin map。

- 視覺常數先寫成 skin token，scss 用 `@include v("prop","token")` 引用，**禁止硬編顏色**。
- 命名：`<區塊>-<元素>-<屬性>` kebab，沿用既有前綴（`table-`/`title-`/`top-nav-`…），本類元件建議前綴 `account-setting-` 之類。
- Token 補在**納入範圍的每個 skin map**（`scss/skins/{classic,blue,pink,purple,green}.scss`）；`classic` 是輸出 fallback，必填。
- scss 引用範例：
  ```scss
  @import "../../../../scss/variables";   // 路徑依元件深度，帶入 v mixin
  .ranking-val { @include v("color", "account-setting-rank-val-font"); }
  ```

### Step 9 — 產出前置作業交付物
1. **節點對照表**
2. **新 token 清單**（key / 各 skin 值 / 對應 Figma 變數）
3. **落差清單**（A/B/C，C 類標「待確認」）
4. **切版計畫**（改哪些檔、幾個區塊、TS 是否需動）

## 決策 Gate（前置作業結束、進切版前必問）

1. **是否需換膚**：元件含 `lottery` 嗎？非 lottery → 無換膚、不做 token，scss 直接落單一外觀。是 lottery → 再決定 token 對幾個 skin。
2. **C 類落差處理**：跟 Figma 1:1（會動 TS / 行為）還是只重外觀、保留現有行為？
3. **設計外框 chrome**：Figma 節點若含麵包屑 / 分頁等「父層 layout」元素，確認是否屬本元件範圍。

## 前端紅線（換版專用）

- **只動 html / scss**；TS 僅在 UX 必須時才動，且**先確認**。
- **間距與比例都要切**：padding / margin / gap **與** 元素佔比 / 長寬比 / 相對尺寸都依 Figma 節點座標（x/y/width/height、inset）推導調整，**不可只換顏色/字級而沿用舊間距與舊比例**。換色 reskin 預設「色＋間距＋比例」三者一起對齊；圖片 / 卡片 / icon 維持設計長寬比避免變形。響應式版面取比例節奏對齊（`%`／`aspect-ratio`／`flex`）並在 scss 註明 Figma px 值。
- **lottery 元件樣式必須走 token**，禁硬編顏色；**非 lottery 元件無換膚需求**，scss 直接落值即可。
- **沿用 DOM 結構**，保留所有綁定 → 不可丟失副作用（CLAUDE.md：重構不可丟失副作用、用戶流程改動必須列舉所有入口）。
- **禁止刪除**現有檔案 / 函數。
- **命名 / 名稱必須查證**：業務名稱從程式碼（Lang / Definition / 現有 class）查，不從 Figma 中文標籤臆測。
- **影響範圍必須 Grep**：改共用 class / token 前搜尋所有引用點。
- **跨頁共用結構 class（`.sw-bottom`/`.sw-solid`/`.info-item` 等定義於 `_common.scss`）re-skin 直接改 `_common.scss`**（grep 確認所有引用頁都該套用），不要悶在單一元件 `:host` 覆寫；只有「該頁專屬」樣式才留 `:host`。`.appfi-*` 連 lottery 頁也用，較保守。
- 跨區改動先知會該區負責人。

## 後續銜接

前置作業確認後 → 進入實際切版（改 html/scss）→ `/front-end-verify <平台>` 跑 build/lint/test → `/front-end-e2e` 跑 e2e。
