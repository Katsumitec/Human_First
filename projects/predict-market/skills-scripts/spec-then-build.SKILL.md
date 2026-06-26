---
name: spec-then-build
description: 一條龍流程：需求規格 → 並行實作 → 整合驗證，適合大規模功能開發
user-invocable: true
---

# Spec → Build → Verify Pipeline

When the user invokes `/spec-then-build`, execute the full pipeline below. This is designed for **medium-to-large features** that span both backend and frontend.

---

## Stage 0: Pre-check — RFC / ADR 判斷

在開始寫規格前，先判斷此 Issue 是否需要 RFC 或 ADR：

### 判斷規則

| 條件 | 需要文件 | 動作 |
|------|----------|------|
| 涉及新商業規則 / 核心機制 | RFC | 檢查 `docs/rfcs/` 是否已有對應 RFC |
| 涉及架構決策 / 技術選型 | ADR | 檢查 `docs/adr/` 是否已有對應 ADR |
| 純功能實作（規則已定） | 無 | 直接進入 Stage 1 |

### 行為

1. **RFC/ADR 已存在** → 讀取內容作為 SPEC 的上下文，在 SPEC 中引用路徑
2. **RFC/ADR 應存在但缺少** → 提醒用戶：「此 Issue 涉及 [商業規則/架構決策]，建議先撰寫 RFC/ADR，是否要先產出？」
   - 用戶同意 → 使用 `docs/rfcs/TEMPLATE.md` 或 `docs/adr/TEMPLATE.md` 產出草稿，等用戶確認後再繼續
   - 用戶略過 → 在 SPEC 風險欄記錄「缺少 RFC/ADR，規則可能變動」
3. **不需要 RFC/ADR** → 直接進入 Stage 1

---

## Stage 1: Specification (product-spec-writer agent)

1. Spawn `product-spec-writer` agent with the user's requirement
2. Agent produces spec using the **SPEC template** at `docs/specs/TEMPLATE.md`, containing 7 sections:
   - 摘要、需求規格、資料與狀態、實作切分、驗收標準、測試情境、風險與待釐清
3. **SPEC metadata must include**:
   - `Issue`: 關聯的 GitHub Issue 編號
   - `RFC`: 關聯的 RFC 路徑（若有）
   - `ADR`: 關聯的 ADR 路徑（若有）
   - **Blast Radius 區塊（必填，位於 metadata 正下方）** — 顯眼標示 Backend / Frontend / GraphQL schema / Infra 的影響範圍。若某一層無變更，明確寫「**無變更**」，不得省略。
4. **實作切分（Section 4）必須強制使用 `### Backend` / `### Frontend` 分組標題**，即使純後端 SPEC 也必須寫 `### Frontend` 並標註「無變更」。步驟在各分組內用 `#### Step N:` 子標題。這能讓 Stage 2 並行實作 agent 精準切出各自任務清單，不需解析。
5. **Save spec** to `docs/specs/{ISSUE_NUMBER}-{feature-name}.md`
   - 範例：`docs/specs/023-market-category.md`
6. Present spec summary to user and **wait for confirmation** before Stage 2

### Layer Split Enforcement（Stage 1 Self-check）

Before presenting the spec to user, the spec-writer agent MUST verify:
- [ ] Metadata 下方有 Blast Radius 區塊，三層（Backend / Frontend / GraphQL）各有一句話
- [ ] 「實作切分」section 有 `### Backend` 與 `### Frontend` 兩個子標題
- [ ] 每個 Step 有 `**檔案**` 欄位列出絕對相對路徑（以 `backend/` 或 `frontend/` 開頭）
- [ ] 純後端 / 純前端 SPEC 仍保留兩個標題，其中一邊寫「本 SPEC 無變更」

若未通過 self-check，重寫該 section 再呈交 user。

### File Naming Convention

```
docs/specs/{ISSUE_NUMBER 三位數}-{kebab-case-feature-name}.md
```

Examples:
- Issue #23 → `docs/specs/023-market-category.md`
- Issue #29 → `docs/specs/029-kalshi-fee-formula.md`

### User Confirmation Gate
Ask: 「規格已完成，是否要繼續進入實作階段？如需修改請告訴我。」
- If user says 繼續/OK/是 → proceed to Stage 1.5
- If user has feedback → revise spec first, then re-confirm

---

## Stage 1.5: Independent Spec Review (spec-reviewer agent)

User 確認 spec 後、開始實作前，啟動獨立審查。目的：用**無 context 偏見的 subagent** 找出 spec-writer 的盲點。

### 執行流程

1. 用 `gh issue view {N}` 取得 Issue 原文（若可取得）
2. 啟動 `spec-reviewer` agent（唯讀、獨立 context）：

   ```
   審查以下 SPEC：
   - Spec: docs/specs/{ISSUE_NUMBER}-{feature-name}.md
   - Issue #{N} 內容：
   {issue_body}

   請讀取 spec 檔案後，依照你的審查流程執行。
   ```

3. **主 agent 事實驗證**：spec-reviewer 回傳後，逐項 grep 確認引用的 method/class/type 是否存在，移除誤判
4. 依結果分支：
   - **0 個問題** → 「Spec 審查通過」→ 進入 Stage 2
   - **有 HIGH 問題** → 列出問題，**停下等使用者決定**是否修正 spec
   - **只有 MEDIUM / LOW** → 列出問題，建議但不阻擋 → 進入 Stage 2

> **為什麼需要這步？** spec-writer agent 寫完 spec 後做的 self-check 是「作者審自己」，
> 有 confirmation bias。spec-reviewer 是獨立 subagent，不共享寫作時的推理脈絡，
> 能客觀找出需求遺漏、跨層矛盾、codebase 事實錯誤。

---

## Stage 2: Parallel Implementation (2 agents)

After Stage 1.5 passes (or user decides to proceed despite issues), extract backend/frontend task lists from the spec and spawn agents **in parallel**:

### Backend → `laravel-graphql-backend` agent

**Skill 參照判斷**：根據 SPEC 內容決定是否在 prompt 中附帶相關 skill 規範：

| 條件 | 參照 Skill | 動作 |
|------|-----------|------|
| 涉及 Filament 後台（新增/修改 Resource、Widget、Settings Page） | `/filament-admin` | 讀取 `.claude/skills/filament-admin/SKILL.md` 並附帶至 prompt |
| 涉及 B2B REST API（新增/修改端點、更新 Partner 文檔） | `/b2b-api` | 讀取 `.claude/skills/b2b-api/SKILL.md` 並附帶至 prompt |
| 純 GraphQL / Service 層變更 | 無 | 使用預設 prompt |

Prompt template:
```
根據以下規格實作後端功能：
[paste relevant sections from spec: 資料與狀態 + 實作切分 backend steps]

按照以下順序實作：
1. Migration  2. Model  3. Service  4. GraphQL Schema
5. Resolver   6. 授權檢查（resolver/Service 內 `Auth::id()` 比對；本 repo 無 Policy 類）  7. Validation 8. Test

[若涉及 Filament 後台]
請遵循 filament-admin skill 規範（已附於下方），特別注意：
- canViewAny() 權限檢查
- HasActivityLog 操作紀錄
- i18n 翻譯檔（lang/en + lang/zh-TW）
- ViewRecord 頁面（若需唯讀詳情）
[附帶 .claude/skills/filament-admin/SKILL.md 內容]

[若涉及 B2B API]
請遵循 b2b-api skill 規範（已附於下方），特別注意：
- 同步更新 public/partner-docs/{en,zh}/openapi.yaml
- 撰寫 Feature Test（tests/Feature/B2B/）
- HMAC 認證 middleware 已自動套用
[附帶 .claude/skills/b2b-api/SKILL.md 內容]

規格檔：docs/specs/{ISSUE_NUMBER}-{feature-name}.md
```

### Frontend → `senior-react-ts-graphql` agent
Prompt template:
```
根據以下規格實作前端功能：
[paste relevant sections from spec: 需求規格 UI flow + 實作切分 frontend steps]

按照以下順序實作：
1. GraphQL operation (src/lib/graphql.ts)
2. TypeScript interface
3. Component (處理 loading/error/empty)
4. Route (src/App.tsx)
5. Navigation
6. i18n 翻譯（所有語系檔）

## 必要規範（不可省略）

### 深色主題與色彩 Token
**實作前必讀** `.claude/rules/frontend/react.md` 的「樣式」段落，該檔定義唯一合法的色彩 token 表（`bg-page` / `bg-card` / `bg-accent` / `text-title` 等），並禁止主站使用 Tailwind 原色階（`bg-gray-*`、`indigo-*`）。參考頁面：`src/pages/MarketsPage.tsx`、`src/pages/HomePage.tsx`。

### i18n 多語系
**實作前必讀** `.claude/rules/frontend/react.md` 的「i18n」段落。重點：所有用戶可見文字用 `t()` 包裝，禁止硬編碼；5 個語系檔（en / zh-TW / zh-CN / ja / ko）必須同步更新完整原生翻譯，**禁止英文 fallback**。新增 key 前先讀 `src/i18n/locales/en.json` 與 `zh-TW.json` 了解命名慣例。

### GraphQL User type
User type 的欄位為 `id, name, email, avatar, balance`。**沒有 `displayName`**（`displayName` 僅存在於 `Creator` type）。

GraphQL schema 變更參考規格中的「資料與狀態」section。
若 schema 尚未確定，以 TODO 標記。
規格檔：docs/specs/{ISSUE_NUMBER}-{feature-name}.md
```

---

## Stage 3: Integration Verification (main Claude)

After both agents complete:

### 3.1 Automated Checks — MANDATORY

**實作完成後必須執行全量測試。** 不可只跑新增的測試，必須確認不引入回歸。

測試撰寫規範請參照 `/testing` skill（`.claude/skills/testing/SKILL.md`），包含：
- GraphQL 測試繼承 `GraphQLTestCase`，使用 `postGraphQL()` / `assertGraphQLSuccess()`
- B2B API 測試繼承 `B2BTestCase`，使用 `b2bGetJson()` / `b2bPostJson()`（自動 HMAC 簽名）
- Filament 測試用 `Livewire::test()` + `actingAs($admin, 'admin')`

```bash
# Backend — 全量測試（在 Docker 內執行）
cd docker && docker-compose exec app php artisan test
cd docker && docker-compose exec app php artisan migrate:status

# Frontend（若有前端變更）
cd frontend && npx tsc --noEmit
cd frontend && npm run lint
cd frontend && npm run build
```

#### 處理測試失敗

1. 先用 `git stash` 暫存本次修改，跑一次全量測試確認哪些失敗是**既有問題**
2. `git stash pop` 恢復修改
3. 在最終報告中區分：
   - **本次引入的失敗** → 必須修復後才能 commit
   - **既有失敗** → 標註為 pre-existing，不阻擋本次 commit

### 3.2 Cross-Layer Alignment
- [ ] GraphQL schema types ↔ Frontend TS interfaces match
- [ ] GraphQL operation field names match schema
- [ ] Mutation inputs match between schema and frontend
- [ ] All AC (驗收標準) from spec are covered

### 3.3 Completeness Gate
- [ ] Every new GraphQL type has a corresponding TS interface
- [ ] Every mutation has error handling on both sides
- [ ] Every data-fetching component handles loading / error / empty
- [ ] No `any` types introduced
- [ ] Backend tests: 1 happy path + 1 error + 1 auth per feature
- [ ] Spec's QA checklist items are all addressable

---

## Stage 3.5: E2E Testing (main Claude) — MANDATORY

**此階段為必要步驟，不可跳過。** 實作完成後必須自動檢查服務狀態並執行 E2E 測試。

### Prerequisites Check
```bash
# Check services are running
cd docker && docker-compose ps
curl -s http://localhost:5173 > /dev/null && echo "Frontend OK" || echo "Frontend NOT running"
curl -s http://localhost:8000 > /dev/null && echo "Backend OK" || echo "Backend NOT running"
```

If services are **not running**, skip E2E and note in the final report: `E2E：⏭️ Skipped (services not running)`

### DB Preparation
```bash
# Run any new migrations and seeders
cd docker && docker-compose exec app php artisan migrate --force
# Run seeders if the feature added new ones (check database/seeders/)
```

### Write E2E Tests
Using the `/e2e-test` skill guidelines (`e2e/tests/*.spec.ts`):

1. **Extract test scenarios from SPEC** — use the 「驗收標準」and 「測試情境」sections
2. **Focus on user-visible behavior** — not implementation details
3. **Test categories** (pick what applies to the feature):

| Category | When to include | Example |
|----------|----------------|---------|
| **API behavior** | Feature adds rate limiting, auth, or API changes | Send burst requests, verify 429/403 |
| **UI flow** | Feature adds pages or modifies frontend | Navigate, interact, assert |
| **Admin panel** | Feature adds Filament pages/resources | Login as admin, verify page loads |
| **Error handling** | Feature has error states | Mock errors, verify toast/message |

4. **Test file naming**: `e2e/tests/{feature-name}.spec.ts`
5. **Keep tests pragmatic** — don't test what's already covered by unit/feature tests

### Run E2E Tests
```bash
cd e2e && npx playwright test tests/{feature-name}.spec.ts --reporter=line --timeout=60000
```

### Handling Results
- **All passed** → proceed to Stage 4
- **Some failed** → attempt to fix (max 2 rounds), then proceed to Stage 4 with failures noted
- **Environment issue** (services down, DB not migrated) → skip and note in report

---

## Stage 4: Quality Gate (main Claude)

After Stage 3.5 passes (or is skipped), run the full quality gate before finalizing.

### 4.1 Code Review
Execute the `/review-code` checklist against all changed files:
- Security: SQL injection, XSS, secret exposure
- Data consistency: transactions, race conditions
- N+1 queries: eager loading
- Type safety: PHP type hints, TS no `any`

### 4.2 Component & Unit Tests
```bash
# Frontend component tests
cd frontend && npx vitest run --reporter=verbose

# Backend tests (if not already run in Stage 3)
cd docker && docker-compose exec app php artisan test
```

### 4.3 Security Scan
Execute `/security-audit` focused on changed files:
- Check new GraphQL mutations **needing auth** have `@guard` (authentication)；公開入口（`register` / `login` / OAuth `loginWith*` / `pingPresence` / `recordAttribution`）刻意不加，勿誤判；授權檢查在 resolver/Service 內以 `Auth::id()` 比對（本 repo 無 `@can` directive / Policy 類）
- Check new API endpoints have authentication
- Check no secrets or sensitive data in code
- Run dependency audit:
```bash
cd frontend && npm audit --audit-level=high
cd docker && docker-compose exec app composer audit
```

### 4.4 Final Report
Output a comprehensive summary:
```
## 實作完成報告
- Issue: #N
- 規格檔：docs/specs/NNN-feature-name.md
- 關聯 RFC/ADR：(if any)
- 新增/修改檔案：(list)
- Backend tests：X passed
- Frontend vitest：X passed
- Frontend：tsc ✓ lint ✓ build ✓
- E2E tests：X passed / ⏭️ Skipped
- Code Review：✓ / ⚠️ (issues found)
- Security Scan：✓ / ⚠️ (issues found)
- 未完成項目：(if any)
- 建議分支名：feature/{issue-number}-{desc}
```

### 4.5 Git Commit
- Create git commit with all changes（不 push）
- Commit message 格式：`feat: <subject> (Closes #N)`
- 等待使用者確認後手動 `git push` 並建立 PR

---

## Error Recovery

- If **spec agent** fails or produces incomplete spec → ask user for clarification, retry
- If **backend agent** fails → review error, fix manually or re-spawn with narrower scope
- If **frontend agent** fails → same as above
- If **cross-layer mismatch** found in Stage 3 → fix the side that's wrong (usually frontend adapts to backend schema)
- If tests fail → diagnose with `/debug-troubleshoot` pattern, fix, re-run
- If **RFC/ADR missing** and user skipped → log as risk, continue but flag in report
