# skills-scripts — 樂力 AI 工作流可重用技術檔

> 本目錄收錄樂力 AI-First 導入過程中產出的 **Claude Code / OpenClaw Skills**。每個 skill 是一份 `SKILL.md`：以 YAML frontmatter 描述「何時觸發」，再以 markdown 指示書教 AI agent 如何完成任務，多數**不需另寫程式**即可重用。

skill 依用途分為四個群組：

| 群組 | 數量 | 用途 | 主要使用者 |
|---|---|---|---|
| [`ll-skills/`](ll-skills/) | 7 | 渠道對接分析、開發與維運（SQL / Kibana / Git） | 開發團隊 |
| [`ll-bot-skills/`](ll-bot-skills/) | 15 | icpay TG Bot 客服 / 運營 API（細顆粒，一支 API 一個 skill） | 客服機器人 |
| [`vibe-sdlc-skills/`](vibe-sdlc-skills/) | 7 | 軟體開發生命週期 Slash Command（規格→Issue→開發→PR→Release） | 開發團隊 |
| [`common-skills/`](common-skills/) | 8 | 通用工具：瀏覽器自動化、OpenCLI、智能搜尋、本地隧道 | 全體 |

> `ll-bot-skills/` 與 `vibe-sdlc-skills/` 已各自附有更詳細的 `README.md`，本檔僅做總覽與導引。

---

## ll-skills — 渠道對接與既有專案維運

對應導入現況的「渠道對接」與「樂力既有專案」兩大主軸，從文檔分析、渠道開發到 SQL / 日誌維運。

| Skill | 用途 |
|---|---|
| `analyze-channel-api` | 分析支付渠道 API 文件，生成標準接口文檔與範例（含代收／代付） |
| `analyze-channel-dev-requirement` | 分析渠道對接開發需求（來源可為本地檔、URL、GitLab/GitHub Issue），輸出對接規格與關鍵參數 |
| `channel-dev` | 渠道開發：依接口文檔產出對接所需的全部設定檔（configs / params / responses / templates） |
| `extract-channel` | 由 MySQL 依 `chnl_id` 擷取渠道配置，輸出 SQL（REPLACE INTO）／Markdown／FTL 模板 |
| `git-workflow` | Git 工作流助手，封裝開分支、提交、推送（含建 MR）、合併、同步，用自然語言操作 |
| `ll-kibana` | 在內網 ll-kibana 的 `dev_ll_log-*` 搜尋日誌、定位錯誤、追蹤呼叫鏈（基於 agent-browser） |
| `run-sql` | 執行 MySQL `.sql` 腳本檔，支援指定 Database 與錯誤處理策略 |

## ll-bot-skills — icpay TG Bot 客服 / 運營

對應「樂力 AI 客服機器人」，讓 OpenClaw AI 助理直接呼叫 `icpay-tg-bot-services` REST API，採細顆粒設計（一支 API 一個 skill）。

查詢 / 交易類（8）— `ll-balance`（各幣別餘額）、`ll-transactions`（月度交易清單）、`ll-order`（單筆查單預設入口）、`ll-order-refresh`（PROCESSING 時升級刷新）、`ll-order-by-chnl`（以渠道訂單號查單）、`ll-market`（OKX P2P 行情）、`ll-channel-chats`（商戶渠道群組清單）、`ll-chat-identity`（解析 chat 身份）。

運營 / Admin 類（7）— `ll-bind` / `ll-unbind`（chat ↔ 商戶綁定）、`ll-admin-add` / `ll-admin-remove`（管理員增減）、`ll-chat-channel-bind` / `ll-chat-channel-unbind`（chat ↔ 渠道綁定）、`ll-healthcheck`（服務存活／就緒探測）。

> 多數運營端點採嚴格 admin chat 授權與軟刪（保留審計軌跡），詳見群組 README。

## vibe-sdlc-skills — 軟體開發生命週期

將 Vibe-SDLC 流程封裝為 Claude Code Slash Command，依階段引導完成整個開發生命週期。內建角色定義、操作步驟、報告模板與前置／完成條件。

| Skill | 階段 / 用途 |
|---|---|
| `vibe-sdlc` | 流程總覽與導航，引導進入對應 Phase |
| `vibe-sdlc-spec` | Phase 1：規格文件與計畫（PRD / SRD / SDD / API Spec / Dev Plan） |
| `vibe-sdlc-issues` | Phase 2：審核 Dev Plan 並自動建立 GitHub Issues |
| `vibe-sdlc-dev` | Phase 3：開發循環——領 Issue、開發、測試、Vibe Check，通過後自動建 PR |
| `vibe-sdlc-pr` | Phase 4：CI 監控、失敗修正與合併後作業 |
| `vibe-sdlc-release` | Phase 5：回饋收集、Release 發佈與迭代規劃 |
| `vibe-sdlc-status` | 讀取各 Agent 狀態檔，彙整為全局 `STATUS.md` |

> 另含 `local-tunnel`（將本地服務發佈至公網供遠端測試）與 `DEPLOY.md`、安裝腳本說明。

## common-skills — 通用工具

| Skill | 用途 |
|---|---|
| `agent-browser` | AI agent 瀏覽器自動化 CLI：導航、填表、點擊、截圖、抓資料、測試網頁 |
| `opencli-usage` | 執行 OpenCLI 指令操作網站／桌面 App／公開 API（87+ adapters），含安裝與指令參考 |
| `opencli-browser` | 以 Chrome 既有登入態讓網站對 agent 可存取（免 LLM API key） |
| `opencli-explorer` | 從零建立 OpenCLI adapter：API 探索、認證策略、TS adapter 撰寫與測試 |
| `opencli-oneshot` | 由單一 URL + 目標快速產生單一 OpenCLI 指令（4 步） |
| `opencli-autofix` | OpenCLI 指令失敗時自動診斷、修補 adapter、重試並回報上游 issue |
| `smart-search` | 基於 opencli 的智能搜尋路由器（社群、技術、新聞、購物、中文內容等） |
| `local-tunnel` | 將本地前後端服務透過隧道發佈至公網，供手機／平板／外部測試者存取 |

---

## 使用與前置條件

- **Claude Code skills**（`ll-skills`、`vibe-sdlc-skills`）：將對應資料夾安裝至 Claude Code skills 目錄（或用 `vibe-sdlc-skills` 內的 `install.sh`），即可以 Slash Command 觸發。
- **OpenClaw skills**（`ll-bot-skills`）：部署於 OpenClaw／agent-container，依 frontmatter 觸發詞呼叫 `icpay-tg-bot-services` API；需有效 token 與綁定。
- **資料庫相關**（`run-sql`、`extract-channel`）：需 Python 3 與 `pymysql`、`python-dotenv`，並於工作目錄提供含 DB 連線資訊的 `.env`。
- **內網相依**：`ll-kibana` 需可連內網 Kibana；`ll-bot-skills` 需可連 icpay 服務。

> 各 skill 的詳細觸發詞、參數與注意事項，請見其資料夾內的 `SKILL.md`。內含內網位址、商戶資料等敏感資訊者，對外分享前請先去識別化。
