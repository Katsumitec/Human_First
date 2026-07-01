# UI-to-Code 換版前置作業工作流（v5 前端）

> 目的：把 Figma 設計稿「一比一」落地到既有 Angular 元件，**只動 `.html` / `.scss`**，TS 邏輯原則上不動（除非設計帶來的 UX 改動必須在 TS 操作）。
> 適用：`code/f2e/v5/projects/<platform>-web|app/` 下的元件換版。
> 本文是「前置作業」（盤點＋對照＋規劃），**不含實際逐行切版**。前置作業產出經確認後，才進入切版。

> ⚠️ **換膚適用範圍（重要前提）**：**只有元件路徑／名稱含 `lottery` 字串的元件才需要做換膚**（token + skin map + `@include v()`）。
> 其餘元件（user-center、account-setting、各種設定頁…）**沒有換膚需求** → scss **直接落值**即可，**不需** `@include v()`、**不需**動 `scss/skins/*`。
> 因此下方 Step 4（判定 skin）、Step 7／§2（token 規劃）**只在 lottery 元件適用**；非 lottery 元件可跳過，直接照 Figma 落單一外觀。

---

## 0. 輸入（每次換版必備）

| 項目 | 範例 |
|------|------|
| Figma 連結 | `https://www.figma.com/design/<fileKey>/...?node-id=<nodeId>` |
| → `fileKey` | `2ZCvSvnI4yVIHUzGaVdNgY` |
| → `nodeId` | `1-10829`（傳給 MCP 時用 `1:10829`） |
| 目標（二選一） | **元件 selector**（如 `app-account-setting`）**或** **單一 class**（如 `.router-path`，`.` 開頭） |
| 目標平台/專案 | `krm-web` |

> URL 解析規則：`figma.com/design/:fileKey/:name?node-id=1-2` → `fileKey=:fileKey`、`nodeId=1:2`。沒有 `node-id` 時**必須**回頭跟使用者要節點層級的連結，不可臆測 nodeId。

> **目標型別**：以 `.` 開頭 → **class 模式**（只切該 class 對應樣式；先 grep 定義在 component scss 還是 `_common.scss`，再決定改元件或改全域；通常 HTML/TS 不動）。否則 → **元件模式**（整個元件三件套）。
> 範例：`app-account-setting` + `node-id=1-10829`（元件）；`.router-path` + `node-id=1-10942`（class，麵包屑「个人 / 个人中心」區塊）。

---

## 1. 工作流步驟（這就是要餵給 Claude 的 prompt 骨架）

### Step 0 — 定位元件（先確認改哪裡）
```
grep -rn "<selector>" projects/<proj>/src --include="*.ts" -l
```
找到元件目錄後，鎖定三件套：`*.component.html` / `*.component.scss` / `*.component.ts`。
列出子元件（子資料夾），判斷哪些屬於本次換版範圍。

### Step 1 — 讀 Figma 結構（節點樹）
`mcp__figma__get_metadata({ fileKey, nodeId })`
→ 取得 frame/instance 階層、命名、座標、尺寸。這是「節點 → DOM」對照的骨架。
> get_metadata 只給結構，**不給樣式**。要實作一定要再跟著呼叫 get_design_context 或 get_screenshot。

### Step 2 — 讀 Figma 視覺 + 變數 + 間距 + 比例
- `mcp__figma__get_screenshot({ fileKey, nodeId, maxDimension: 1600 })` → 下載 PNG 後用 Read 看實際樣貌。
- `mcp__figma__get_variable_defs({ fileKey, nodeId })` → 取得設計變數（顏色 / 陰影 / 字級）。
- **間距（padding / margin / gap）要從節點座標推導**：`get_metadata` / `get_design_context` 的 `x/y/width/height`、`inset-[…]` 就是設計間距來源。相鄰節點 x/y 差＝gap / margin；子節點相對父框內縮＝padding。
- **比例（佔比 / 長寬比 / 相對尺寸）也要一起量**：子節點 `width` ÷ 父框 `width`＝寬度佔比；圖片 / 卡片 / icon 的 `width:height`＝長寬比（換圖換版要維持，避免變形）；字級 / icon / 圓角彼此的相對大小＝設計層級節奏。**換色 reskin 預設「色＋間距＋比例」三者一起對齊，不可只換顏色/字級而沿用舊版尺寸與佔比。** 響應式版面無法逐 px 對齊時，取設計的比例與節奏對齊（`%`／`aspect-ratio`／`flex`），並在 scss 註明對應 Figma px 值。
> 截圖回傳的是短效 URL，用 `curl -o` 抓下來再 Read。

### Step 3 — 讀現有元件三件套
完整讀 `.html` / `.scss` / `.ts`。重點抓：
- 現有 DOM 結構與 class 命名（切版要沿用 DOM 結構，只換外觀）。
- **`.scss` 目前是硬編碼還是已 token 化**（決定 token 工作量）。
- `.ts` 裡和畫面綁定的欄位 / 事件 / `*ngIf` / `*ngFor`（切版不可破壞這些綁定）。

### Step 4 — 判定對應 Skin（v5 換膚關鍵；**僅 lottery 元件適用**）
> 先判斷：**元件路徑／名稱是否含 `lottery`**？否 → 跳過本步與 Step 7，scss 直接落 Figma 外觀。是 → 才往下判定 skin。

Figma 通常只畫**單一 skin 的長相**。先確認這份設計對應哪個 skin：

| Skin | 名稱 | 模式 | 判斷依據 |
|------|------|------|----------|
| `classic` | 預設 | light | 預設 fallback |
| `pink` | 粉 | light | |
| `blue` | 藍 | light | |
| `green` | 綠 | light | |
| `purple` | 宇宙紫 | **dark** | `ThemeService.getSkinMode()` 只有 purple 回 `dark` |

> 看到深色底＋紫/桃紅漸層 → 幾乎可確定是 **purple（宇宙紫 / dark）** skin。
> **這是必問的決策點**：本次換版只要對到這一個 skin，還是五個 skin 都要重定 token？（見 §4 決策 Gate）

### Step 5 — 建立「節點 → DOM → token」對照表
把 get_metadata 的節點，逐一對到現有 DOM 的 class，再對到要用的 token。範例見 §5。

### Step 6 — 盤點落差（最重要，避免悶頭切錯）
逐區比對 Figma vs 現有 DOM，標記三類落差：
- **A. 純外觀**：顏色 / 圓角 / 間距 / **比例（佔比 / 長寬比 / 相對尺寸）** / 陰影 / 字級 → 切版範圍，改 scss（lottery 元件走 token；非 lottery 直接落值）。換色時連間距與比例一併盤點對照，不可只列顏色差異。
- **B. 結構**：多／少區塊、欄位重排 → 改 html，但要確認不是漏資料。
- **C. 涉及 TS / UX**：元件種類改變（checkbox→radio）、新增互動（分頁、排序）、資料來源改變 → **停下來問使用者**，因為會動到 TS / 行為。

> CLAUDE.md 紅線：**用戶流程改動必須列舉所有入口**、**重構不可丟失副作用**。C 類落差不可自行決定。

### Step 7 — Token 規劃（**僅 lottery 元件適用**；切版規範：樣式必須走 token）
> 非 lottery 元件**跳過本步**：無換膚需求，scss 直接落 Figma 值即可，不建 token、不動 skin map。

- 視覺常數**先寫成 skin token**，scss 透過 `@include v(...)` 引用，**禁止硬編顏色**。
- 命名規範：`<元件區塊>-<元素>-<屬性>`，全小寫 kebab，沿用既有前綴慣例（如 `table-`, `title-`, `top-nav-`）。本元件建議前綴：`user-account-setting-` 或精簡 `account-setting-`。
- Token 要在**所有納入範圍的 skin map** 都補上（`scss/skins/{classic,blue,pink,purple,green}.scss`）。`classic` 的值會被當成輸出的 fallback，必填。

### Step 8 — 產出前置作業交付物
1. **節點對照表**（§5 格式）。
2. **新 token 清單**（key / 各 skin 值 / 對應 Figma 變數）。
3. **落差清單**（A/B/C 分類，C 類標「待確認」）。
4. **切版計畫**：要改哪些檔、估動幾個區塊、TS 是否需動。

---

## 2. Token 命名與引用規範（專案實況）

引用機制（`scss/skins/skin.scss`）：
```scss
@mixin v($property, $varName, $content: null) {
  #{$property}: map.get($skin-default, $varName);   // classic fallback（編譯期寫死）
  #{$property}: var(--#{$varName}) #{$content};       // 各 skin 由 .skin-xxx body class 覆寫
}
```

元件 scss 用法：
```scss
@import "../../../../scss/variables";   // 路徑依元件深度調整，會帶入 v mixin

.ranking-val {
  @include v("color", "account-setting-rank-val-font");
}
```

Skin 套用方式（`styles.scss`）：`body` 掛 `.skin-<name>` → 注入該 skin map 的所有 `--token`。`classic`/`default` 不注入，直接吃 mixin 的 fallback 值。

> 注意：`@include v(` 幾乎只出現在 `app/ui/lottery/**`，因為**換膚需求僅限 lottery 元件**。`app/ui/user/**` 等非 lottery 區**不做 token**，scss 直接落值。本節（token 規範）只在處理 lottery 元件時才需要。

---

## 3. 紅線與注意事項（換版專用）

- **只動 html / scss**；TS 僅在「設計帶來的 UX 改動必須在 TS 操作」時才動，且**先確認**。
- **間距與比例都要切**：padding / margin / gap **與** 元素佔比 / 長寬比 / 相對尺寸都依 Figma 節點座標（x/y/width/height、inset）推導調整，**不可只換顏色/字級而沿用舊間距與舊比例**。換色 reskin 預設「色＋間距＋比例」三者一起對齊；圖片 / 卡片 / icon 維持設計長寬比避免變形。響應式版面取比例節奏對齊（`%`／`aspect-ratio`／`flex`）並在 scss 註明 Figma px 值。
- **lottery 元件樣式必須走 token**，不可硬編顏色（切版規範）；**非 lottery 元件無換膚需求**，scss 直接落值即可。
- **DOM 結構盡量沿用**，保留所有 `[(ngModel)]` / `(click)` / `*ngIf` / `*ngFor` 綁定 → 不可丟失副作用。
- **禁止刪除**現有檔案 / 函數（動態載入難追蹤引用，保守處理）。
- **命名 / 名稱必須查證**：區塊業務名稱從程式碼（Lang / Definition / 現有 class）查，不從 Figma 中文標籤臆測。
- **影響範圍必須 Grep**：改共用 class / token 前，搜尋所有引用點。
- **跨頁共用結構 class 直接改 `_common.scss`**：`.sw-bottom`/`.sw-solid`/`.info-item` 等定義在 `_common.scss`、跨多頁共用的結構 class，re-skin 該一致套用 → 直接改 `_common.scss`（grep 確認所有引用頁都該套用），不要悶在單一元件 `:host` 覆寫。只有「該頁專屬」樣式才留元件 `:host`。`.appfi-*` 連 lottery 頁也用，動它較保守。
- 跨區（非自己主責的 `code/f2e/`）改動先知會該區負責人。

---

## 4. 決策 Gate（前置作業結束、進切版前必問）

1. **是否需換膚**：元件路徑／名稱含 `lottery` 嗎？非 lottery → 無換膚、不做 token，scss 直接落 Figma 單一外觀（多數設定頁屬此類）。是 lottery → 再決定 token 要對幾個 skin。
2. **C 類落差處理**：Figma 與現況在「元件種類 / 互動 / 資料」上的差異，是要 1:1 跟 Figma（會動 TS / 行為），還是只重外觀、保留現有行為？
3. **設計外框 chrome**：Figma 節點若包含麵包屑 / 分頁等「父層 layout」才有的元素，確認是否屬於本元件範圍。

---

## 5. 附錄：`app-account-setting` 範例（worked example）

> Figma：`fileKey=2ZCvSvnI4yVIHUzGaVdNgY`、`nodeId=1:10829`（content）。
> 元件：`projects/krm-web/src/app/ui/user/account-setting/`。
> **換膚判定：路徑為 `app/ui/user/**`、名稱不含 `lottery` → 無換膚需求**。雖然 Figma 是深紫外觀，但本元件**不做 token、不動 skin map**，scss 直接落這份 Figma 外觀（單一固定樣式）。
> 結論（實際決策）：Skin 範圍＝**只做 classic（即唯一外觀）不換膚**；C-1＝**保留 3 個 checkbox 只重外觀**；C-3 TIT＝**外框不納入**。

### 5.1 節點 → DOM 對照（節錄）

| Figma 節點 | 名稱 | 現有 DOM | 區塊 |
|------------|------|----------|------|
| `1:10832` | 个人设置 | `.left` | 左欄卡片 |
| `1:10838` | 编组 12（頭像） | `.info-item.avatar` | 頭像設置 |
| `1:10846` | 编组 3（昵称） | `.app-form-item .appfi-input` | 昵称設置 |
| `1:10849` | 编组（系統設定） | `.appfi-checkbox` ×N | 系統設置 |
| `22:51766` | Button_H50 | `.setting-btn` | 更新個人設置 |
| `1:10857` | 最近登入日志 | `.center` | 登入日誌表 |
| `1:10878/81/84` | 编组 11/9/6 | `.ip-info-item`（時間/IP/位置） | 表格三欄 |
| `1:10888` | 编组 13 | `.right` | 合買績效榜 |
| `1:10897/98/99` | 矩形备份 5/6/8 | `.ranking-item` ×3 | 昵称/上週/上月 |
| `24:93495` | info-bar | `.sw-bottom`（用戶名/昵称/獎金/餘額/註冊時間） | 底部資訊條 |
| `1:10939` | **TIT**（个人/个人中心 + Segmented 三天/一周/三月） | **現有 code 無此元素** | ⚠ 見落差 C-3 |

### 5.2 Figma 變數（get_variable_defs 實際回傳）

| Figma 變數 | 值 | 用途推測 |
|------------|-----|----------|
| `普通文字` | `#555555` | 一般文字 |
| `#4D0360-T` | `#4d0360` | 深紫（卡片底 / 強調） |
| `#A38098-T` | `#a38098` | 灰紫（次要文字） |
| `#D35E74` | `#d35e74` | 桃紅（數值 / 重點） |
| `#94DBE5` | `#94dbe5` | 青（連結 / 提示） |
| `Btn Shadow` | 雙層 drop-shadow（白 -3/-3 + `#4d036033` 2/2） | 按鈕新擬物陰影 |
| `%/#FFFFFF-40%` | `#ffffff66` | 半透明白 |
| `%/#A06DB3-15%` | `#a06db326` | 半透明紫（hover / BG） |

### 5.3 落差清單（盤點結果）

- **A（純外觀）**：整體由淺色（`#F6EFEA` 卡片 / `#ffc283` 按鈕橘）→ 深紫底 + 桃紅數值 + 漸層按鈕。現有 scss 全硬編碼；**因本元件非 lottery、無換膚需求，切版直接改 scss 落 Figma 值即可（不 token 化）**。
- **B（結構）**：右欄標題現為「合买排行榜」，Figma 為「合买中心绩效榜」→ 文案/標題差異，需查證實際業務名稱（不照搬 Figma 中文）。
- **C（涉及 TS / UX，待確認）**：
  - **C-1**：系統設置現有 **3 個 checkbox**（封单与开奖声音提示 / 中奖通知提示 / 聊天通知声音提示），Figma 只畫 **2 個 radio**（封单声音提示 / 开奖声音提示）。元件種類（checkbox→radio）與項目數量都不同 → **會動 TS 綁定與 `batchModifyUserSetting` 邏輯**，必須確認。
  - **C-2**：登入日誌欄 Figma 有 `ScorllBar` 元件與交替列底，現有為 `overflow-y:auto` + `:nth-child(even)` → 多為外觀，但需確認是否要換成設計的捲軸元件。
  - **C-3**：**TIT**（麵包屑「个人 / 个人中心」+ Segmented「三天/一周/三月」）在現有 user/layout 程式碼中**完全不存在** → 研判屬報表 Figma 檔的外框 chrome 或父層 layout，**非本元件範圍**，需確認。

### 5.4 直接落值對照（**本元件不 token 化**，scss 直接寫死 Figma 值）

| 元素 | 現有（淺色） | 改為（對 Figma） | Figma 變數 |
|------|-------------|------------------|-----------|
| 卡片底 `.left` / `.ranking-item` | `#F6EFEA` / `#ffdfbf8a` | 深紫系 | `#4D0360` |
| 標題 `.li-title` | `#888888` | `#a38098` | `#A38098` |
| 數值 `.ranking-val` | `#C08238` | `#d35e74` | `#D35E74` |
| 按鈕 `.setting-btn` | `#ffc283` | 紫→桃紅漸層 | btn_fill |
| 按鈕陰影 | 現有陰影 | 白 + `#4d036033` 雙層 | `Btn Shadow` |
| 表格交替列 `.ip-info-item:nth-child(even)` | `#ffdfbf47` | `#a06db326` | `%/#A06DB3-15%` |

> 以上為**前置作業產出**。本元件非 lottery → 不建 token、不動 skin map，切版時於 `account-setting.component.scss` 直接落上述值。

---

## 6. 一句話 Prompt（要快速啟動時複製這段）

> 「對 `<selector>` 做 Figma 換版前置作業：Figma `fileKey=<…>` `nodeId=<…>`。流程：定位元件三件套 → get_metadata 取節點樹 → get_screenshot+get_variable_defs 取視覺與變數 → 讀現有 html/scss/ts → **先判斷元件是否含 `lottery`（含才需換膚/token；不含則跳過 skin 判定與 token，scss 直接落 Figma 外觀）** → 做『節點→DOM』對照 → 盤點 A/B/C 落差（C 類涉及 TS/UX 先停下問我）→（僅 lottery）規劃 token 走 `@include v()`、補齊 skin map → 產出對照表/落差清單/切版計畫。只動 html+scss，TS 不動除非 UX 必須。先給我前置作業產出與待確認決策，不要直接切版。」
