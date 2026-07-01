# architecture — 換版工作流架構與規範對照

這份文件說明「Figma 設計稿 → 既有 Angular 元件」的換版怎麼運作，讓別人快速看懂 `/ui-to-code` 的定位與資料流。

## 核心模型：Component ↔ Figma Node，一個對一個
換版不是「重畫一個畫面」，而是**既有 Angular 元件 ↔ Figma 節點一對一對應**：
- 換版＝換「**外觀＋間距＋比例**」，不是換功能。
- 前端原則（已寫進 `/ui-to-code`）：**只動 `.html` / `.scss`，TS 邏輯幾乎不動**——沿用 DOM、保留所有綁定。
- 對得上號 → 換版變成**機械式、可預期、可批量**：
  - ① 對得上 = 快（Node 對 class，改 scss 即生效）
  - ② 不動 TS = 安全（功能不會被換皮改壞）
  - ③ 可批量 = 產線化（多平台多皮膚邊際成本遞減）

## 痛點根源：Sketch 轉 Figma 缺什麼
外部設計多為 Sketch 轉檔，缺原生 Figma 能力，前端只能逆向工程：

| 原生 Figma 能力 | Sketch 轉檔後 | 對前端的後果 |
|---|---|---|
| **Auto Layout** 自動排版 | 全是絕對座標 | 間距 / gap 要逐節點手量 |
| **Variables** 設計變數 | 顏色散成一堆 hex | token 對照只能逆向猜，對不齊皮膚 |
| **Component + Variants** | 每張卡都是獨立圖層 | 9 宮格、10 彩票項看不出是同一元件 |
| **Constraints** 父容器行為 | 無拉伸／固定資訊 | RWD 行為靠猜，響應式無依據 |

## 全場核心：Figma 規範 ⇄ /ui-to-code 工作流
| Figma 規範 | 解決什麼 | 對應 /ui-to-code | 沒做到的代價 |
|---|---|---|---|
| ① Auto Layout | 間距可被讀取 | Step 3：由 x/y/w/h、inset 推導 padding/gap | 逐節點手量座標 |
| ② Variables | 顏色/間距變數化 | Step 8：get_variable_defs → token、`@include v()` | token 逆向猜、皮膚對不齊 |
| ③ Component+Variants | 重複元素一次定義 | 節點→元件 1:1，9 宮格 / 10 彩票項複用 DOM | 重複圖層逐張比對易漏 |
| ④ Constraints | 父容器行為明確 | Step 3 比例：佔比/長寬比 → %/aspect-ratio/flex | RWD 變形、圖片拉伸 |
| ⑤ Mobile/Tablet | RWD 有設計依據 | web/app 雙變體，比例節奏對齊 | 響應式靠前端臆測 |

> 設計多花 1 分鐘結構化，前端少花 1 小時逆向工程。

## 資料流（前置盤點 → 決策 Gate → 切版）
```
Figma 節點連結(含 node-id)
      │  Figma MCP
      ▼
get_metadata  → 節點樹 / 座標 / 尺寸（推導間距與比例）
get_screenshot→ 視覺對照
get_variable_defs → 顏色 / 陰影 / 字級變數
      │
      ▼
比對既有元件三件套(.html / .scss / .ts)
      │
      ▼
產出 4 大交付物 ──▶ 決策 Gate（人把關）──▶ 實際切版(改 .html / .scss)
      │                                          │
      ▼                                          ▼
節點對照表 / token 清單 / 落差清單 / 切版計畫   /front-end-verify → /front-end-e2e
```

## 4 大交付物
1. **節點對照表** — Figma node → DOM class → token，逐一對齊
2. **新 token 清單** — key / 各皮膚值 / 對應 Figma 變數
3. **落差清單** — A / B / C 分類，C 類標「待確認」
4. **切版計畫** — 改哪些檔、幾個區塊、TS 是否要動

## 落差分類 A / B / C（Human First 的關鍵）
- **A 純外觀**（色 / 圓角 / 間距 / 比例 / 陰影 / 字級）→ 直接改 scss，**繼續不停**。
- **B 結構**（多 / 少區塊、重排）→ 改 html，確認不漏資料，**繼續不停**。
- **C 涉及 TS / UX**（元件種類變、新互動、資料來源變）→ **停下問人**。

> 價值：外觀換版可放心交給標準流程；真正動行為的部分一定有人把關，不會默默改壞功能。判斷留給人，重複勞動交給流程。

## 換膚機制：不是所有元件都要 token
- **只有 `lottery` 元件**才走「token ＋皮膚 map ＋`@include v()`」，支援多皮膚（token 補在 `scss/skins/{classic,blue,pink,purple,green}.scss`，classic 為 fallback 必填）。
- 其餘元件（user-center、設定頁、活動頁…）**無換膚需求** → scss 直接落 Figma 值。
- **換色 ≠ 只換色值**：色＋間距＋比例三者一起對齊；圖片/卡片維持長寬比避免變形。
- krm 慣例：宇宙紫換版改 `classic.scss` 色票值，結構邊框硬編在共用層。

## 給外部設計的交付 Checklist（收稿驗收標準）
- 卡片 / 按鈕 / 列表項都是 **Auto Layout**（非絕對定位）
- 顏色、主要間距已抽成 **Variables**，命名清楚
- 重複元素做成 **Component + Variants**，標明哪些是同一元件
- 關鍵元素有 **Constraints**（拉伸 / 固定）
- 提供**節點層級連結**（含 node-id，前端才能精準定位）
- 重要頁面附 **Mobile / Tablet** 畫布

## 實戰案例：KRM 新手福利 · 宇宙紫換版（1:1）
全程照 `/ui-to-code`：沿用 DOM、只換外觀與間距比例、TS 不動，設計稿 → 完成版幾乎像素對齊。三態對照圖見 `slides/`（`原本.png` / `figma設計.png` / `完成版.png`）。
