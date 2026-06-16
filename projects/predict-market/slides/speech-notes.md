# 用 Claude Code 蓋一座 AI 軟體工廠 — 演講稿

> 對應投影片：`nick-predict-market.pptx`（28 張）
> 全程數字皆基於 git 紀錄、`.claude/` 設定與 `docs/` 實測（資料截止 2026-06-04）。
> 每張標「**講什麼**」要點，過場頁一句串場即可。**AI 探索性測試（L4）為本場核心，獨立深講。**

---

## 第 1 段：背景說明（Slide 1–6）

**Slide 1 — 封面**
- 開場一句：「這場分享的主題不是『我用 AI 寫了多少 code』，而是『我怎麼把人帶 AI 的方法，變成一條可版控、可重複、可交接的產線』。」
- 強調全部數字都有出處，不是體感。

**Slide 2 — 分享結構（六段）**
- 快速念六段，點名「第 4、5 段（成功 / 踩坑）是本場核心，會誠實講哪些值得複製、哪些坑別再踩」。

**Slide 3 — Part 1 過場**：一句帶過：「先講我們是誰、為什麼決定把『人怎麼帶 AI』制度化。」

**Slide 4 — 專案與團隊背景**
- PredictMarket：二元預測市場 aPaaS，MVP 已上線 `protype.kf-test.com`。
- 核心機制：LMSR 撮合、自動結算、費率 ≤ 10%。技術棧 Laravel 12 + GraphQL + React 19。
- **關鍵張力**：核心開發只有 1–2 人，卻要 11 週維持高產出 → 問題是「小團隊如何用 AI 規模化，又不犧牲品質與可交接性？」

**Slide 5 — 為什麼要把 AI 開發「流程化」**
- 左欄痛點：每次 prompt 結果看運氣、AI 不懂專案硬規則（違反架構 / 洩密 / breaking change）、規格只在腦袋裡無法審查、技術債堆積、前後端各做各的對不上。
- 右欄選擇：把規範寫進 `.claude/rules/`、流程寫成 skill、規格落地成 `docs/specs/`、守門靠 hooks + 權限（機器強制）、前後端由**同一份 SPEC** 切分並行。
- 一句收斂：「我們賭的是『制度』，不是『更會寫 prompt』。」

**Slide 6 — Part 2 過場**：「接下來用實際數據說明這 11 週產出了什麼。」

---

## 第 2 段：專案內容（Slide 7–8）

**Slide 7 — 11 週產出數據快照**
- 四個大數字：**405** main commits、**87.7%** commit 綁定 Issue、**99** 份 SPEC（平均 ~9/週）、**13 / 5** RFC / ADR。
- 程式碼規模：後端 PHP 598 檔 ~65.8k 行、前端 TS/TSX 232 檔 ~40.8k 行、GraphQL schema 單一真相源 2,223 行。
- 節奏表：03→108、04→163、05→115、06→19（至 6/4）。「重點是穩定高產出，不是一次性衝刺；Issue 已開到 #506、PR 到 #508。」

**Slide 8 — 三層文件治理：決策 → 架構 → 實作**
- RFC（決策層・13 份）→ ADR（架構層・5 份）→ SPEC（實作層・99 份）→ Code（405 commits）。
- 關鍵設計兩點：
  - ① SPEC 固定七段結構（摘要 / 需求規格含 user story / 資料與狀態 / 實作切分 / 驗收標準 / 測試情境 / 風險）。
  - ② **Blast Radius + 強制分層**：每份 SPEC 必填影響範圍（BE/FE/GraphQL/Infra），用 `### Backend` / `### Frontend` 切分，讓並行 agent 精準切任務、介面天生對齊。

---

## 第 3 段：使用工具（Slide 9–17）

**Slide 9 — Part 3 過場**：「把流程、規範、守門全寫進 `.claude/`，六個互相咬合的元件。」

**Slide 10 — `.claude/` 生態系全景**
- ① Skills（12 個・2,196 行）② Sub-agents（4 個・全用 Opus）③ Rules（5 檔・404 行，依路徑自動載入）④ Hooks（2 腳本 + 4 內嵌，機器強制守門）⑤ 三層 Memory ⑥ Docs + Permissions（43 allow / 9 deny）。
- 一句定錨：「這六件就是『AI 軟體工廠』的廠房配置圖。」

**Slide 11 — 12 個客製 Skills**
- 挑三個講：`spec-then-build`（主編排 341 行）、`review-code/review-spec`（審查）、`e2e-test`（Playwright）。
- 點出「+ 原生內建 skills（code-review / security-review / verify / deep-research）可與客製組合」。

**Slide 12 — 關鍵洞察：Skills 是被「編排」的**
- 重點概念：`spec-then-build` 像主程式，沿途**條件式呼叫**其他 skill 當副程式（Stage 1.5 審查 → Stage 2 後端 → Stage 3 測試 → Stage 4 品質門）。
- 也能單獨拿出來用：`session-back`（開工恢復脈絡）、`debug-troubleshoot`（卡關除錯）、`workspace-config`（演進系統本身）。

**Slide 13 — 主流程 spec-then-build：五階段產線**
- 0 前置判斷 → 1 規格產出 → 1.5 獨立審查 → 2 雙線並行 BE+FE → 3 整合驗證 +3.5 E2E → 4 品質門 +commit。
- 強調：**全程有 human gate**（規格核可 / HIGH 問題 / push 前），輸出是「已測試、已審查、已掃描」的 commit，但**不自動 push，等人確認**。適用中大型跨前後端；小修不必走全程。

**Slide 14 — 4 個 Sub-agents + 三層記憶體**
- 四 agent 全用 Opus：`product-spec-writer`、`spec-reviewer`（**唯讀・無記憶 = 防偏見**）、`laravel-graphql-backend`、`senior-react-ts-graphql`。
- 三層 memory：L1 使用者偏好、L2 每 agent 累積教訓、L3 路徑自動載入的硬規則。

**Slide 15 — 測試策略：五層金字塔**（進入核心）
- L1 PHPUnit Unit 22 檔 → L2 Feature 173 檔 + L2′ Vitest 32 檔 → L3 Playwright E2E 49 spec / 11 個 `@critical` → **L4 AI 探索性測試 20 scenarios / 79 份報告** → L5 Prod smoke（規劃中）。
- 串場句：「**L3 守底線（黃金路徑），L4 主動探雷（腳本抓不到的混亂路徑）**。下一頁深入 L4 —— 這是今天我最想分享的。」

---

## ⭐ Slide 16 深講 — L4 AI 探索性測試（怎麼用 + 怎麼驗證）

> 全場技術含量最高的一張，建議放慢，用「是什麼 → 怎麼跑 → 怎麼驗證 → 成效」四段講。

### ① 是什麼 / 為什麼（先建立動機）

- **一句定義**：一個 AI agent **自主駕駛瀏覽器**去探索 app，找「腳本化測試抓不到的 bug」。
- **和 L3 的根本差別**：
  - L3 E2E 是人寫死的「黃金路徑」—— 它只會照腳本走，你想到的 case 才測得到。
  - L4 是 AI **亂序下注、每步切語系、中途打斷流程** —— 模擬真實使用者的混亂行為，去撞你沒想到的 case。
- **正式記錄於 RFC-010（已 Accepted）**，退出條件 AC-12：「至少抓到 1 個既有測試沒抓到的 bug」—— 已達成（後面講）。

### ② 怎麼跑（架構 — 這段是「怎麼用」）

開發者一行指令啟動：

```bash
cd e2e && npm run exploratory -- --task=place-bet-chaos
```

背後流程（照箭頭走）：

| 步驟 | 做什麼 |
|------|--------|
| 1. 連線 | 預設連 `localhost:5173` + `127.0.0.1:8000`，沿用既有 docker stack 與 seed 資料 |
| 2. 啟瀏覽器 | 啟動 Playwright，**headed 模式預設開** —— 你能親眼看 AI 在點什麼 |
| 3. 驅動 agent | 透過 **Claude Agent SDK** 跑 **multi-turn 工具迴圈**（用 `ANTHROPIC_API_KEY` 認證，不走訂閱） |
| 4. 注入工具 | 給 agent **約 14 個工具**去操作與觀察（下列） |
| 5. 輸出報告 | 結束寫單一 markdown 到 `e2e/exploratory/reports/YYYY-MM-DD-HHMM-<task>.md` |

**注入的工具（agent 的手與眼）**：

| 類別 | 工具 | 用途 |
|------|------|------|
| 操作 | `navigate` / `click` / `fill` | 駕駛瀏覽器 |
| 觀察 | `screenshot`（可 `fullPage`） | 截圖（檔名帶 timestamp，給人覆核） |
| 觀察 | `read_console` / `read_network` | 讀 console error 與網路請求（含 GraphQL operationName / response） |
| **驗證** | `whoami()` | GraphQL `me` query 確認登入身分 —— **不准用截圖猜「我登入了沒」**，這是 ground truth |
| **驗證** | `check_layout_issues()` | DOM 掃描版面違規（水平溢出 / 文字截斷 / 觸控目標 < 24px），比「看截圖判斷」客觀 |
| **驗證** | `assert_invariant(marketId?)` | 打後端不變量 API（下詳） |
| 報告 | `report_anomaly(severity,...)` | 寫異常進報告 |
| 報告 | `report_tc_result(...)` | 逐條驗收條件回報（qa-acceptance 用） |

**守門（制度化的關鍵，務必講）**：
- **local-only**：路由與 API 在 production 完全不存在（404）。
- **不排程、不上 CI、不自動開 Issue** —— 報告寫給人看，要追蹤再手動開 Issue。
- **預算雙重上限**：單 run `$0.50` / 總 `$5`，SDK 收到 `total_cost_usd` 超過即 hard stop。
- **單 run 上限**：15 分鐘 / 100 step，超過自動收尾。

### ③ 怎麼驗證（重點）

L4 的「驗證」分**三條腿**，缺一不可 —— 核心理念是**不盲信 AI 的主觀判斷，每個結論都要有 deterministic 證據**：

#### 第 1 條腿：後端 Invariant API（帳目守恆 — 機器算，不靠 AI 看）

- 端點：`POST /internal/invariants/check`（僅 local / staging / testing 掛載；production 不存在）。
- agent 每隔幾步就呼叫一次，後端 `InvariantChecker` 聚合驗這些**數學不變量**：

| 不變量 | 規則 |
|--------|------|
| 機率和 = 1 | `yes_price + no_price == 1.00 ± 0.01` |
| 抽水 ≤ 10% | `Σ platform_fee / Σ total_amount ≤ 0.10` |
| 資金守恆 | `signed_flow + platform_fee + payout == 0`（cents 整數比對，**僅 resolved / voided 跑**；活躍狀態因 LMSR pool 未排空會天生不平 → 自動 skip） |
| 無孤兒交易 | 每筆 `trade` 對應的 `market` 必存在 |
| bot 隔離 | `extras` 回 bot / human 4 拆分欄位，驗會計守恆同時不破壞 ADR-003 報表隔離 |

> 講重點：「**『帳有沒有算錯』是後端用整數算出來的，不是 AI 看畫面猜的**。AI 只負責製造混亂的下注序列，對不對由 API 裁決。」

#### 第 2 條腿：DOM / GraphQL ground truth（客觀觀察，不靠截圖詮釋）

- 「我登入了嗎」→ `whoami()` 查 GraphQL，不看截圖。
- 「版面爆了嗎」→ `check_layout_issues()` 掃 DOM 量測，不靠 AI 目測。
- 「這個輸入該被擋下嗎」→ 讀 `read_network` 的 GraphQL response：有 `errors[]` = 後端規則健康；該被拒卻回了 `data` = 真 P1 anomaly。

#### 第 3 條腿：可重現 reproducer（AI 找到後，人用腳本複驗）

- AI 報的 anomaly **不直接當定論**。流程是：AI 標 anomaly → 人把它寫成一支固定的 Playwright spec → **連跑 3 次穩定 fail** 才算真 bug。
- 對應踩過的教訓：**「AI 報 0 anomaly」不代表沒問題**（runner 不存 GraphQL body，可能假陰性），所以關鍵結論一律用 deterministic `curl` / spec 補驗。

> 一句收斂：「L4 的價值不在 AI 多聰明，而在**我們不相信它的主觀判斷** —— 帳目交給後端整數驗、身分交給 GraphQL 驗、bug 交給可重現 spec 驗。AI 只是那個不知疲倦、會亂玩的測試員。」

### ④ 成效（用真實證據收尾，對應 Slide 26）

- **PoC 6 天 / 9 次 run**，找到既有 `@critical`（27 passed）**完全沒抓到**的真實 UX bug：下注送出按鈕被 viewport 截掉（`bottom=974px > viewport=720px`），開單 **#216**。
- **成本極低**：6 天共 ~**$3.27**（上限 $10）。
- 關鍵：**搭配後端不變量 API 才能驗「帳有沒有算錯」，不只是點得動。**

---

**Slide 17 — 守門機制：機器強制，不靠自律**
- Hooks（工具呼叫層攔截）：`block-env-read.sh` 擋任何想印出 `.env` 的操作、`lint-after-edit.sh` 編輯後自動 `tsc --noEmit` / `php -l`、artisan test 前清 GraphQL schema 快取、對話結束自動 `pint --dirty` 格式化。
- Permissions：43 條 allow（npm / tsc / playwright / docker 內 artisan…）、9 條 deny（`rm -rf` / `git push --force` / `migrate:fresh` / `DROP TABLE`…）。
- **關鍵差異（重講）**：「規範不是『希望 AI 記得』，而是**系統在工具呼叫層攔截 —— 想違反也做不到**。」

---

## 第 4 段：成功經驗（Slide 18–20）

**Slide 18 — Part 4 過場**：「本場核心之一 —— 哪些做法值得繼續投入。」

**Slide 19 — 值得繼續投入的六件事**（不分技術棧，是真正產生槓桿的地方）

| 主題 | 一句話 |
|------|--------|
| 紀律 | Issue-first + commit 綁定（87.7% 綁 #N），任何一行 code 都能反查「為什麼改」 |
| 契約 | Schema-first 契約先行，介面先定死，前後端才能並行不打架 |
| 對抗式驗證 | 獨立審查員（唯讀無記憶）+ grep 反查 method 是否真存在，擋 AI 幻覺 |
| 並行設計 | Blast Radius + 強制分層，先講清楚動到哪幾層才安全 |
| 機器護欄 | 守門機器化，hook 在工具呼叫層攔截，9 條 deny 封破壞指令 |
| 主動探雷 | AI 探索測試 + 不變量 API，配 $ 上限、不自動開 Issue |

- 加碼小招：`git stash` 分辨新舊測試失敗、commit 但不自動 push、三層 memory 累積教訓。

**Slide 20 — 為什麼有效 / 成效 / 關鍵成功因素**
- 有效：品質前移（規格期就抓問題）、去偏見（獨立審查不讓作者審自己）、不靠自律（護欄機器強制）、介面先定（schema-first）。
- 成效：11 週 99 SPEC + 405 commits、1–2 人維持、87.7% 綁 Issue、**AI 探索測試抓到 @critical 漏掉的真實 bug（#216）**、可重複 / 可審查 / 可交接。
- 一句話總結：「把『人怎麼帶 AI』從隱性知識，變成可版控、可重複、可交接的工程資產。」

---

## 第 5 段：失敗 / 踩坑（Slide 21–24）

**Slide 21 — Part 5 過場**：「本場另一核心，誠實講做了又撤回、踩過的坑。」

**Slide 22 — 真正「做了又撤回 / 失敗」的嘗試**
- ① **時區對齊當 hotfix（撤回）**：為修 HOT 分數時間 bug 想直接改 DB 連線時區 +8，但 226 欄全 `TIMESTAMP`，改了會位移既有資料 +8h 成 split-brain —— 這是 **ADR 級資料遷移，不能當 hotfix**。正解：收斂共用 `parse util`（#488/#506）。教訓：「有些『修正』本質是資料遷移，硬幹會擴大災難。」
- ② **Codex MCP 架構（Round 1 中止）**：想用 MCP 接 OpenAI Codex 訂閱跑探索測試，三個 blocker 卡死中止重來。Round 2 改**內嵌 HTTP server** 繞過全部 blocker、recall 3/3 成功（RFC-012）。教訓：「先做小 spike 驗架構，別一路走到底。」

**Slide 23 — 開發中踩過的坑（附 issue 佐證）**

| 類別 | 坑 |
|------|-----|
| 測試環境 | harness 硬鎖 SQLite，隱藏 MySQL 專屬 bug（#476 分數溢位、Filament groupBy 撞 `ONLY_FULL_GROUP_BY` 1055）→ 聚合 / list 頁需用 MySQL 跑 E2E |
| E2E 偽綠 | 條件式 skip 的 render-race：等錯 locator 再 count 會誤判空集合、silent skip 核心路徑（#494）→ 先等目標 locator 可見再判斷 |
| AI 假陰性 | 盲信「0 anomaly」：runner 不存 GraphQL body，AI 報「沒問題」可能假陰性 → 0 異常必用 deterministic `curl` 補驗 |
| 主題 token | Tailwind `@theme inline` + hex literal 會把 utility 編譯死，runtime 切主題無效 → E2E 驗 computed-style |
| 金流原子性 | `incrementBalance/decrementBalance` 自身不開 transaction，caller 必須自包；多補完成路徑須共用單一 lock + idempotent |
| 流程 / 人 | 流程過重套小修反而慢、產出集中單人（bus factor）、code 演進後 SPEC 會脫節需定期對帳 |

- **共同根因（點題）**：「**外部假設（DB 引擎 / 時區 / locator / AI 自評）都要在『目標 scope』內精確驗證，不可單一信號下結論。**」

**Slide 24 — 如果重來一次，會怎麼做**
- 測試與驗證：① harness 從第一天就用 MySQL 跑關鍵聚合 / list 測試，不靠 SQLite；② E2E 條件式 skip 一律先等目標 locator 可見；③ AI 探索結果**預設不信任**，deterministic `curl` 補驗納入標準流程。
- 架構與流程：① 時區 / 金額等基礎決策一開始就立 ADR + 共用 util；② 新整合先做小 spike 驗架構；③ 明訂「輕量 vs 全程」準則，並早點讓第 2、3 人實跑分散 bus factor。
- **核心心法**：「把『驗證外部假設』變成流程的**預設動作**，而不是踩雷後的補救。」

---

## 第 6 段：額外分享（Slide 25–28）

**Slide 25 — Part 6 過場**：「有價值的發現、新工具推薦、可複用方法論。」

**Slide 26 — 有價值的發現與新工具推薦**
- 💡 發現：**AI 探索測試真的有效** —— PoC 6 天 / 9 run 抓到「下注送出鈕被 viewport 截掉」的 UX bug，既有 `@critical` 完全沒抓到（#216），6 天 ~$3.27。關鍵是**搭後端不變量 API 才能驗「帳有沒有算錯」，不只是點得動**。
- 🛠 新工具推薦：**雙 runner 控成本** —— Anthropic API key（預設・production-grade）+ OpenAI Codex 訂閱（成本固定）並存。~36 個 codex run 另抓到多個 finding，訂閱制讓探索測試的**邊際成本趨近 0**。推薦給有大量 agent 探索 / 批次任務的團隊：高頻可重複任務用訂閱 runner、需要穩定品質的關鍵任務用 API runner。

**Slide 27 — 可複用方法論 + 參考資源**
- 核心五原則（跨技術棧通用）：① 規範入庫 ② 流程成腳本 ③ 規格先行 ④ 獨立審查 ⑤ 守門機器化。導入順序：`CLAUDE.md` → 幾條 rules → 擋密鑰 hook → 權限名單 → 第一個 skill → multi-agent。
- 參考資源：Claude Agent SDK、RFC-010（AI 探索測試）/ RFC-012（雙 runner）/ ADR-002（主題 token）、內建 skills、`block-env-read.sh` 可直接複用。
- 收尾句：「**五個原則跨語言、跨框架通用 —— 我們用 Laravel + React，換成任何棧邏輯相同。**」

**Slide 28 — 一句話帶走（結尾）**
- 「我們把『人怎麼帶 AI 寫好程式』變成了**可版控、可重複、可交接的工程資產**。」
- 四個錨點數字：**99** SPECs、**12 / 4** Skills/Agents、**5 層**測試金字塔、**L4** AI 自主探索測試。
- 進 Q&A：「所有數字查證來源都在 git 紀錄、`.claude/` 設定與 `docs/`。」
