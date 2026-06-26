# 專案名稱：樂力 AI-First 工作流導入

> 彙整樂力各專案導入 AI 工作流的現況，依「渠道對接」、「既有專案維運」、「AI 客服機器人」三大主軸，分述定位、工作流程、使用工具、主要挑戰與導入心得。

## 基本資訊
- **團隊／負責人**：樂力（LL）團隊
- **聯絡方式**（Email / Slack / GitHub）：robin@sky-net.tw
- **一句話介紹**：以 Claude Code 為核心，將渠道對接、既有專案維運、客服機器人三大場景導入 AI 工作流。

## 這個專案在做什麼
- **解決的問題 / 痛點**：渠道對接文檔繁雜不全、既有專案龐大難定位、客服業務流程複雜且觸發詞相近，仰賴大量人力。
- **使用者 / 適用情境**：樂力開發團隊與 OP，涵蓋渠道對接開發、系統維運增修、運營客服自動化。

## 用了哪些 AI 工具與技術
- **AI 工具 / 模型**：Claude Code、Antigravity IDE、OpenClaw / Hermes（評估）
- **框架 / 技術棧**：Java Spring（既有專案）、狀態機（transitions）＋ JSONLogic 自建 Harness、TG Bot、SQL
- **可重用的 SKILL / SCRIPT / prompt**：已收錄於 `skills-scripts/`，分四組——`ll-skills`（渠道對接與維運，7）、`ll-bot-skills`（icpay TG Bot 客服 / 運營，15）、`vibe-sdlc-skills`（SDLC 流程，7）、`common-skills`（通用工具，8）

## 成果與效益
- **做出了什麼**：建立「底層交互 → 正向對接 → 反向校正與生產輸出」的渠道對接閉環；既有專案以 AI 接單修改與審查；客服機器人採自建 Harness 狀態機控制對話流程。
- **量化效益**：以 AI 從 GitLab Issue 接單、產出報文轉換模板與 SQL 參數初稿、生成索引文件加速定位，減少人工分析與部分 OP 測試工作（詳見簡報與導入現況）。

## 架構簡述
- 渠道對接由 `channels`（通用底層）、`ll-chnl`（正向對接）、`ll-chnl-reverse`（反向校正與生產輸出）三者構成閉環；客服機器人由 `agent-container`、`icpay-tg-bot-services`、`icpay-ai-bot-crm` 組成。完整架構圖與資料流見 `architecture/`。

## Demo / 連結
- 簡報：`slides/LL-AI-First-導入現況.pdf`（原始 .pptx、.html 一併附上）
- 導入現況詳述：`architecture/LL-Ai-First-work-review.md`

---
### 內容物清單
- [x] `slides/` — 投影片（PDF / PPTX / HTML）
- [x] `architecture/` — 導入現況與架構說明（含 mermaid 架構圖）
- [x] `skills-scripts/` — 技術檔（37 個 skill，分 4 組；見該目錄 README）
