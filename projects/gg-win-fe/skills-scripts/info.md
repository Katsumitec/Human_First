# skills-scripts — 可重用的技術檔

本專案對外可重用的核心技術產物是 **`/ui-to-code` skill**——把 Figma 設計稿「一比一」落地到既有 Angular 元件的**前置作業（盤點＋規劃）**工具。skill 本體已直接收錄於此，可拿了就用。

## 內容物

```
skills-scripts/
├── info.md                          ← 你正在看的這份（使用說明）
└── ui-to-code/
    ├── SKILL.md                     ← skill 定義（Claude Code slash command，含 frontmatter）
    └── ui-to-code-workflow.md       ← 完整工作流與 worked example
```

## 怎麼安裝（拿去別的專案用）
1. 把 `ui-to-code/SKILL.md` 放到目標專案的 `.claude/commands/ui-to-code.md`（Claude Code 會自動載入為 `/ui-to-code` slash command）。
2. 把 `ui-to-code/ui-to-code-workflow.md` 放到目標專案的 `claude_docs/ui-to-code-workflow.md`（SKILL.md 內部引用此路徑）。
3. 確認已連接 **Figma MCP**（`get_metadata` / `get_screenshot` / `get_variable_defs`）。
4. 在 Claude Code 輸入 `/ui-to-code <selector|.class> <figma-url>` 即可。

> ⚠️ 本 skill 針對 KR 專案的 v5 前端結構（`code/f2e/v5/projects/*`、皮膚 token `scss/skins/*`）撰寫；套用到其他專案時，路徑與皮膚機制需依實際結構調整。

## SKILL：/ui-to-code

### 定位
- **新平台切版專用**：切版只動 `.html` / `.scss`，**TS 邏輯幾乎不動**（只有 UX 必須時才動，且一律先問使用者）。
- **只做前置盤點＋規劃**（對照 / token / 落差 / 計畫），產出經使用者確認「決策 Gate」後，才進入實際切版——**先規劃、後動手**。
- **換膚只限 lottery 元件**：路徑／名稱含 `lottery` 才做 token；其餘元件 scss 直接落 Figma 值。

### 前置條件
- Claude Code（載入本 skill）＋ **Figma MCP**（`get_metadata` / `get_screenshot` / `get_variable_defs`）。
- Node.js `20.12.2`（若後續要 build / 驗證才需要）：
  ```bash
  export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh" && nvm use 20.12.2 && node -v
  ```
- 目標為 Angular 專案（v5 結構：`code/f2e/v5/projects/<proj>`），皮膚 token 位於 `scss/skins/*`。

### 怎麼跑（用法）
支援兩種「目標」：**元件 selector**（整個元件三件套）或 **單一 class**（`.` 開頭）。
```
/ui-to-code <selector> <figma-url>        # 對整個元件做換版前置作業
/ui-to-code .<class>   <figma-url>        # 只對單一 class 切版
```
範例：
```
/ui-to-code app-account-setting https://figma.com/design/2ZC.../?node-id=1-10829
/ui-to-code .router-path        https://figma.com/design/2ZC.../?node-id=1-10942
```
> URL 解析：`figma.com/design/:fileKey/:name?node-id=1-2` → `fileKey=:fileKey`、`nodeId=1:2`。**無 `node-id` 不可臆測**，回頭跟對方要節點層級連結。

### 流程（9 步）
0. Node 版本（要驗證/切版才需）
1. 定位目標（元件模式 grep selector；class 模式 grep class 定義與引用）
2. 讀 Figma 節點樹（`get_metadata`）
3. 讀視覺 + 變數 + **間距 + 比例**（`get_screenshot` / `get_variable_defs`，由座標推導 padding/gap 與佔比/長寬比）
4. 讀現有元件三件套（沿用 DOM，不破壞綁定）
5. 判定對應 Skin（**僅 lottery 適用**；深色底＋紫/桃紅 ≈ purple 宇宙紫 dark）
6. 節點 → DOM → token 對照
7. 盤點落差（A 純外觀 / B 結構 / C 涉及 TS/UX）
8. Token 規劃（**僅 lottery 適用**，`@include v("prop","token")`，禁硬編色）
9. 產出 4 大交付物：節點對照表 / 新 token 清單 / 落差清單 / 切版計畫

### 決策 Gate（進切版前必問）
1. 是否需換膚（元件含 `lottery`？）
2. C 類落差怎麼處理（跟 Figma 1:1 動 TS，還是保留現有行為只重外觀？）
3. 設計外框 chrome（麵包屑/分頁等父層 layout 是否屬本元件範圍？）

### 前端紅線（換版專用）
- 只動 html / scss；TS 僅在 UX 必須時才動，且先確認。
- 換色 reskin 預設「**色＋間距＋比例**」三者一起對齊；圖片/卡片/icon 維持長寬比避免變形。
- lottery 元件樣式必須走 token、禁硬編色；非 lottery 直接落值。
- 沿用 DOM 結構、保留所有綁定，不丟失副作用；禁刪現有檔案/函數。
- 命名/名稱必須查證（從 Lang / Definition / 現有 class 查，不從 Figma 中文標籤臆測）；改共用 class / token 前 grep 所有引用點。

### 後續銜接
前置確認 → 實際切版（改 html/scss）→ `/front-end-verify <平台>`（build/lint/test）→ `/front-end-e2e`（e2e）。

---
> 完整流程細節與 worked example 見同資料夾的 `ui-to-code/ui-to-code-workflow.md`；skill 定義為 `ui-to-code/SKILL.md`。
