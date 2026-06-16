# 專案名稱：PredictMarket — 用 Claude Code 蓋一座 AI 軟體工廠

> 主題不是「我用 AI 寫了多少 code」，而是「怎麼把『人怎麼帶 AI』變成一條**可版控、可重複、可交接**的產線」。
> 全部數字皆基於 git 紀錄、`.claude/` 設定與 `docs/` 實測（資料截止 **2026-06-04**）。

## 基本資訊
- **團隊／負責人**：Nick（核心開發 1–2 人）
- **聯絡方式**：nick@sky-net.tw / GitHub `Katsumitec`
- **一句話介紹**：二元預測市場 aPaaS 平台，用 Claude Code 把 AI 輔助開發制度化成一條跨前後端、可審查、可交接的產線。

## 這個專案在做什麼
- **解決的問題 / 痛點**：核心開發只有 1–2 人，卻要在 11 週維持高產出。核心張力是「小團隊如何用 AI 規模化，又不犧牲品質與可交接性？」
  - 每次 prompt 結果看運氣、AI 不懂專案硬規則（違反架構 / 洩密 / breaking change）
  - 規格只在腦袋裡無法審查、技術債堆積、前後端各做各的對不上
- **使用者 / 適用情境**：想把 AI 開發從「會寫 prompt」升級成「有制度」的小團隊；不限技術棧，五個核心原則跨語言通用。
- **產品本身**：二元預測市場（LMSR 撮合、自動結算、費率 ≤ 10%），MVP 已上線 `protype.kf-test.com`。

## 用了哪些 AI 工具與技術
- **AI 工具 / 模型**：Claude Code（Opus）、Claude Agent SDK（驅動 AI 探索測試）、OpenAI Codex 訂閱（雙 runner 控成本）
- **框架 / 技術棧**：Laravel 12 · PHP 8.2 · Lighthouse GraphQL · Filament 3 ／ React 19 · TypeScript 5.9 · Apollo Client · Tailwind CSS 4 ／ MySQL 8 · Redis · Laravel Horizon ／ Docker Compose · GitHub Actions（self-hosted runner）
- **可重用的 SKILL / SCRIPT / prompt**（放在 [`skills-scripts/`](./skills-scripts/)）：
  - `block-env-read.sh` — 在工具呼叫層攔截任何想印出 `.env` 的操作（可直接複用）
  - `lint-after-edit.sh` — 編輯後自動 `tsc --noEmit` / `php -l`
  - `spec-then-build.SKILL.md` — 主編排 skill：規格 → 獨立審查 → 並行實作 → 整合驗證 → 品質門
  - `settings.example.json` — 權限白名單（43 allow / 9 deny）+ hooks 配置範例

## 成果與效益
- **做出了什麼**：把「人怎麼帶 AI 寫好程式」從隱性知識，變成可版控、可重複、可交接的工程資產。
- **量化效益**（11 週 / 資料截止 2026-06-04）：

  | 指標 | 數據 |
  |------|------|
  | main commits | **405** |
  | commit 綁定 Issue | **87.7%** |
  | SPEC 文件 | **99** 份（平均 ~9/週） |
  | RFC / ADR | **13 / 5** |
  | 後端 PHP | 598 檔 ~65.8k 行 |
  | 前端 TS/TSX | 232 檔 ~40.8k 行 |
  | GraphQL schema | 單一真相源 2,223 行 |
  | 測試金字塔 | 5 層（Unit / Feature / E2E / **AI 探索** / Prod smoke） |

- **最有感的發現**：**AI 探索性測試真的有效** —— PoC 6 天 / 9 次 run，抓到既有 `@critical`（27 passed）完全沒抓到的真實 UX bug（下注送出鈕被 viewport 截掉，開單 #216），6 天總成本僅 **~$3.27**。關鍵是搭配後端不變量 API，才能驗「帳有沒有算錯」，不只是「點得動」。

## 架構簡述
六個互相咬合的元件構成「AI 軟體工廠」（詳見 [`architecture/overview.md`](./architecture/overview.md)）：

1. **Skills（12 個）** — 固化工作流，`spec-then-build` 是主編排，沿途條件式呼叫其他 skill 當副程式
2. **Sub-agents（4 個・全用 Opus）** — 規格撰寫 / 獨立審查（唯讀無記憶＝防偏見）/ 後端 / 前端
3. **Rules（5 檔）** — 依檔案路徑自動載入的領域硬規則
4. **Hooks** — 機器強制守門（擋 `.env`、編輯後 lint、測試前清快取、收尾自動格式化）
5. **三層 Memory** — 使用者偏好 / 每 agent 教訓 / 路徑自動載入硬規則
6. **Docs + Permissions** — RFC→ADR→SPEC 三層治理 + 43 allow / 9 deny 白名單

核心理念：**規範不是「希望 AI 記得」，而是系統在工具呼叫層攔截 —— 想違反也做不到。**

## Demo / 連結
- 投影片：[`slides/predict-market-claude-sharing.pptx`](./slides/predict-market-claude-sharing.pptx)（28 張）
- 完整講稿（含 ⭐ L4 AI 探索測試深講）：[`slides/speech-notes.md`](./slides/speech-notes.md)
- 線上 MVP：`protype.kf-test.com`

---
### 內容物清單
- [x] `slides/` — 投影片（pptx）+ 完整講稿
- [x] `architecture/` — 「AI 軟體工廠」架構與五層測試金字塔說明
- [x] `skills-scripts/` — 可直接複用的 hook / skill / 權限設定
