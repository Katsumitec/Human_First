# PredictMarket — 「AI 軟體工廠」架構

> 把流程、規範、守門全寫進 `.claude/`，六個互相咬合的元件構成一條可重複的產線。
> 資料截止 2026-06-04。

---

## 1. `.claude/` 生態系全景

```
.claude/
├── settings.json          # 權限白名單（43 allow / 9 deny）+ hooks
├── settings.local.json    # 開發者本地覆蓋
├── hooks/
│   ├── block-env-read.sh  # 工具呼叫層攔截任何印 .env 的操作
│   └── lint-after-edit.sh # 編輯後自動 tsc --noEmit / php -l
├── rules/                 # 5 檔・依檔案路徑自動載入
│   ├── backend/laravel.md
│   ├── backend/graphql.md
│   ├── frontend/react.md
│   ├── frontend/typescript.md
│   └── security.md
├── agents/                # 4 個 sub-agent（全用 Opus）
│   ├── product-spec-writer.md
│   ├── spec-reviewer.md          # 唯讀・無記憶 = 防偏見
│   ├── laravel-graphql-backend.md
│   └── senior-react-ts-graphql.md
└── skills/                # 12 個客製 skill
    ├── spec-then-build/   # 主編排（341 行）
    ├── review-code/  review-spec/
    ├── e2e-test/  qa-acceptance/  testing/
    ├── debug-troubleshoot/  session-back/  workspace-config/
    └── b2b-api/  db-migration/  filament-admin/  security-audit/
```

| 元件 | 角色 |
|------|------|
| **Skills（12 個）** | 固化工作流，被「編排」呼叫——`spec-then-build` 像主程式，沿途條件式呼叫其他 skill 當副程式 |
| **Sub-agents（4 個・Opus）** | 規格 / 審查 / 後端 / 前端分工；`spec-reviewer` 唯讀無記憶，避免「作者審自己」的偏見 |
| **Rules（5 檔）** | 依路徑自動載入的領域硬規則（色表、i18n、命名、認證矩陣） |
| **Hooks** | 機器強制守門（見 §4） |
| **三層 Memory** | L1 使用者偏好、L2 每 agent 累積教訓、L3 路徑自動載入硬規則 |
| **Docs + Permissions** | RFC→ADR→SPEC 三層治理 + 白名單權限 |

---

## 2. 三層文件治理：決策 → 架構 → 實作

```
RFC（決策層・13 份）   要不要做？規則是什麼？     → docs/rfcs/
  ↓
ADR（架構層・5 份）    技術怎麼選？架構怎麼設計？  → docs/adr/
  ↓
SPEC（實作層・99 份）  怎麼寫 code？驗收標準？     → docs/specs/
  ↓
Code（405 commits）
```

**SPEC 固定七段結構**：摘要 / 需求規格（含 user story）/ 資料與狀態 / 實作切分 / 驗收標準 / 測試情境 / 風險。

**關鍵設計 — Blast Radius + 強制分層**：每份 SPEC 必填影響範圍（Backend / Frontend / GraphQL / Infra），用 `### Backend` / `### Frontend` 切分。讓並行 agent 能精準切出各自任務清單、介面天生對齊。

---

## 3. 五層測試金字塔

| 層級 | 內容 | 數量 |
|------|------|------|
| L1 | PHPUnit Unit | 22 檔 |
| L2 | Feature + Vitest | 173 + 32 檔 |
| L3 | Playwright E2E（守底線・黃金路徑） | 49 spec / 11 `@critical` |
| **L4** | **AI 探索性測試（主動探雷・混亂路徑）** | **20 scenarios / 79 報告** |
| L5 | Prod smoke | 規劃中 |

### ⭐ L4：AI 探索性測試（本架構的核心創新）

一個 AI agent **自主駕駛瀏覽器**去探索 app，找「腳本化測試抓不到的 bug」。和 L3 的根本差別：L3 只照人寫死的腳本走；L4 由 AI 亂序下注、每步切語系、中途打斷流程，模擬真實使用者的混亂行為。

**架構**（開發者一行指令 `npm run exploratory -- --task=place-bet-chaos`）：
1. 連 `localhost:5173` + `127.0.0.1:8000`，沿用既有 docker stack 與 seed
2. 啟 Playwright（headed 預設開，肉眼看 AI 在點什麼）
3. 透過 **Claude Agent SDK** 跑 multi-turn 工具迴圈（`ANTHROPIC_API_KEY` 認證）
4. 注入約 14 個工具給 agent 操作與觀察
5. 結束寫單一 markdown 報告到 `e2e/exploratory/reports/`

**三條腿驗證（核心理念：不盲信 AI 主觀判斷，每個結論都要 deterministic 證據）**：

| 條腿 | 機制 |
|------|------|
| ① 後端 Invariant API | `POST /internal/invariants/check`——機率和=1、抽水≤10%、資金守恆、無孤兒交易、bot 隔離，**用整數算，不靠 AI 看畫面猜** |
| ② DOM / GraphQL ground truth | `whoami()` 查登入身分、`check_layout_issues()` 掃版面違規、讀 `read_network` 的 GraphQL `errors[]` 判斷規則健康 |
| ③ 可重現 reproducer | AI 標 anomaly → 人寫成固定 Playwright spec → 連跑 3 次穩定 fail 才算真 bug |

**守門**：local-only（production 完全 404）、不排程 / 不上 CI / 不自動開 Issue、預算雙重上限（單 run $0.50 / 總 $5 hard stop）、單 run 上限 15 分鐘 / 100 step。

---

## 4. 守門機制：機器強制，不靠自律

| 類型 | 機制 |
|------|------|
| **Hooks** | `block-env-read.sh` 擋任何印 `.env` 的操作；`lint-after-edit.sh` 編輯後自動 `tsc --noEmit` / `php -l`；artisan test 前清 GraphQL schema 快取；對話結束自動 `pint --dirty` 格式化 |
| **Permissions** | 43 條 allow（npm / tsc / playwright / docker 內 artisan…）、9 條 deny（`rm -rf` / `git push --force` / `migrate:fresh` / `DROP TABLE`…） |

---

## 5. 上線部署架構

- **雲平台**：AWS EC2（Rocky Linux 8.10）、Docker Compose（dev + prod overlay）
- **CI/CD**：GitHub Actions **self-hosted runner**（同台 EC2，省 GitHub 分鐘數）
- **容器組成**：app（PHP-fpm）/ nginx / mysql 8 / redis 7 / horizon（queue worker）/ scheduler
- **前端靜態化**：不跑 Node 容器；nginx prod image 在 build 階段內嵌 Vite build，直接 serve 靜態檔 → 省記憶體、降攻擊面
- **部署亮點**：rsync + `--exclude-from` 避開敏感檔、`horizon:terminate` 做 zero-downtime queue restart、test 與 deploy job 分離（任一失敗整個 deploy 不跑）

---

## 6. 可複用的五個核心原則（跨技術棧通用）

| # | 原則 | 一句話 |
|---|------|--------|
| 1 | 規範入庫 | 把硬規則寫進 `.claude/rules/`，依路徑自動載入 |
| 2 | 流程成腳本 | 把最佳流程固化成 skill，一鍵調用 |
| 3 | 規格先行 | Schema-first 契約先定死，前後端才能並行不打架 |
| 4 | 獨立審查 | 唯讀無記憶的審查員 + grep 反查 method 是否真存在，擋 AI 幻覺 |
| 5 | 守門機器化 | hook 在工具呼叫層攔截，9 條 deny 封破壞指令 |

**導入順序**：`CLAUDE.md` → 幾條 rules → 擋密鑰 hook → 權限名單 → 第一個 skill → multi-agent。

> 我們用 Laravel + React，換成任何棧邏輯相同。
