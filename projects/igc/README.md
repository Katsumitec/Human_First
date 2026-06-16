# 專案名稱：AI First 實戰 — 從工具導入到工程流程重塑

> 金流系統與第三方遊戲整合平台的 AI 應用、踩坑與方法論。
> 以「自問自答」的形式，整理一年 AI 導入後真正改變的觀念。

## 基本資訊
- **團隊／負責人**：murphy（Backend / Payment / Game Integration）
- **聯絡方式**（Email / Slack / GitHub）：murphy@sky-net.tw
- **一句話介紹**：在金流、錢包、遊戲結算等高風險場景導入 AI 後，對流程、驗證與決策的重新思考。

## 這個專案在做什麼
- **解決的問題 / 痛點**：
  - GC 第三方遊戲整合平台：串接大量外部遊戲供應商 API、設計 Unified API、處理高併發帳務與遊戲紀錄更新。
  - 四方金流系統：整合多支付渠道 API、設計統一支付介面、處理高併發交易與帳務流程。
  - 在這類高複雜度、高風險系統中，AI 導入不是「寫 Code 快一點」，而是重新分配人與 AI 的注意力。
- **使用者 / 適用情境**：後端 / 金流 / 遊戲整合工程團隊，以及想把 AI 從個人使用推進到團隊流程的技術主管。

## 用了哪些 AI 工具與技術
- **AI 工具 / 模型**：
  - **Claude Code** — 主要開發、重構、上下文對話與計畫拆解
  - **Codex CLI** — Review、二次檢查、攻擊式檢查
  - **JetBrains AI Pro** — IDE 內輔助、局部理解、快速修改
  - **Gemini CLI** — 額外分析、交叉驗證、替代觀點
- **框架 / 技術棧**：Codegraph MCP、CLAUDE.md（分層規則）、Skills、Review Commands、Refactor Plan
- **可重用的 SKILL / SCRIPT / prompt**：分層規則設計（Global / Domain / Task）、多層 Review 流程（普通 / 攻擊式 / 特定二審）、重構計畫流程（放在 `skills-scripts/`）

## 成果與效益
- **做出了什麼**：
  - 用工程生命週期（開發 / 文件 / 日常 / 知識工作）盤點 AI 應用場景。
  - 完成接近五十個遊戲供應商平台的重構（AI 協助找共通模式、產生重構計畫與測試方向）。
  - 把 AI Review 從「問一次」升級為多角色、多角度的多層檢查流程。
- **效益**：重構效率提升、Review 覆蓋更全面（普通 + 攻擊式 + 高風險二審）；金流／結算以「不變量」為審查核心，降低資金與狀態風險。

## 架構簡述
- 核心方法論：**AI 品質 = 模型能力 × Context 品質**。
- 分工原則：讓 AI 負責推理（展開、生成、分析、找盲點），讓 Script 負責執行，讓 Test 負責驗證，人類負責簽核。
- 規則分層：Global Rules（CLAUDE.md）→ Domain Rules（Skill）→ Task Rules（本次限制）。
- 高風險領域原則：最大化 AI 產出，同時最小化 AI 決策權。

### 踩坑紀錄（重點教訓）
1. **grep 只看前幾行** → 導入 Codegraph MCP，讓 AI 理解呼叫關係與結構。
2. **AI 很會猜但沒有全部資訊**（例：S3 OAC vs 公司用 Cloudflare）→ 建議合理但不一定符合現況，那是 Trade-off。
3. **注意 AI 知識截止時間** → 版本、雲端規格、價格等需查證官方文件或實測。
4. **AI 會用 Mock 假裝完成核心機制** → 規範禁止在 production path 使用 mock / stub / fake。

## Demo / 連結
- 簡報（HTML 版，可直接用瀏覽器開啟）：[`slides/murphy_ai_first_2026.html`](slides/murphy_ai_first_2026.html)
  - 操作：← / → 翻頁、`N` 顯示逐字提示、`F` 全螢幕；瀏覽器列印可匯出 PDF。

---
### 內容物清單
- [x] `slides/` — 投影片（HTML 簡報，共 19 頁）
- [ ] `architecture/` — 架構圖或介紹
- [ ] `skills-scripts/` — 技術檔（如有）
