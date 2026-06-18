# OpenClaw Skills — `ll-*`（icpay-tg-bot-services）

這是一組讓 [OpenClaw](https://openclaw.ai) 個人 AI 助理能直接呼叫 `icpay-tg-bot-services` REST API 的 skill 包，採**細顆粒設計**（一支 API 一個 skill）。

每個 skill 是一份 `SKILL.md`：YAML frontmatter 描述「何時觸發」+ markdown 指示書教 agent 怎麼用 OpenClaw 內建工具（`exec` / `web fetch`）呼叫對應端點。**不需編寫程式**。

---

## 15 個 skill 一覽

### 查詢 / 交易（8）— scope: `balance.read` / `transaction.read` / `transaction.refresh` / `market.read` / `binding.read`

| Skill | 對應 API | 用途 |
|-------|---------|------|
| [`ll-balance`](skills/ll-balance/SKILL.md) | API-005 GET `/api/v1/merchants/{mchntCd}/balance` | 各幣別可用 / 義務 / 凍結餘額 |
| [`ll-transactions`](skills/ll-transactions/SKILL.md) | API-006 GET `/api/v1/merchants/{mchntCd}/transactions` | 月度交易清單（含 state / pageSize≤10）|
| [`ll-order`](skills/ll-order/SKILL.md) | API-007 GET `/api/v1/merchants/{mchntCd}/transactions/{orderId}` | 單筆訂單 + 跨月回溯（查單預設入口）|
| [`ll-order-refresh`](skills/ll-order-refresh/SKILL.md) | API-012 POST `/api/v1/transactions/refresh` | 訂單升級刷新（PROCESSING 時由 ll-order 自動接；scope `transaction.refresh`，**有上游 RPC 副作用**）|
| [`ll-order-by-chnl`](skills/ll-order-by-chnl/SKILL.md) | API-013 POST `/api/v1/transactions/lookup-by-chnl-order` | 以渠道訂單號查單（caller 須綁渠道；scope `transaction.read`）|
| [`ll-market`](skills/ll-market/SKILL.md) | API-008 GET `/api/v1/market/okx-p2p` | OKX P2P 行情（USDT/CNY，公開）|
| [`ll-channel-chats`](skills/ll-channel-chats/SKILL.md) | API-011 GET `/api/v1/chat-bindings/channel-chats` | 商戶涵蓋的渠道群組清單（chatId 去重 + 上限 100，scope `binding.read`）|
| [`ll-chat-identity`](skills/ll-chat-identity/SKILL.md) | API-014 GET `/api/v1/chat-identity` | 解析當前 chat 身份（roleType MER/CHNL/NONE/CONFLICT + 對應綁定 + 幣別；scope `binding.read`）|

### 運營 / Admin（6）— scope: `binding.write` / `admin.write`

| Skill | 對應 API | 用途 / 注意 |
|-------|---------|------------|
| [`ll-bind`](skills/ll-bind/SKILL.md) | API-001 POST `/api/v1/chat-binding` | chat ↔ 商戶綁定（admin OR）|
| [`ll-unbind`](skills/ll-unbind/SKILL.md) | API-002 DELETE `/api/v1/chat-binding` | 軟刪綁定（保留審計）|
| [`ll-admin-add`](skills/ll-admin-add/SKILL.md) | API-003 POST `/api/v1/admin/users` | 註冊 admin user（嚴格 admin chat）|
| [`ll-admin-remove`](skills/ll-admin-remove/SKILL.md) | API-004 DELETE `/api/v1/admin` | 移除 admin（含 Lock-out 保護）|
| [`ll-chat-channel-bind`](skills/ll-chat-channel-bind/SKILL.md) | API-009 POST `/api/v1/chat-channel-binding` | chat ↔ 渠道綁定（**嚴格 admin user** / N:N / category 固定 TG）|
| [`ll-chat-channel-unbind`](skills/ll-chat-channel-unbind/SKILL.md) | API-010 DELETE `/api/v1/chat-channel-binding` | 軟刪渠道綁定（不存在亦冪等回 200）|

### SRE / 巡檢（1）— 匿名

| Skill | 對應端點 | 用途 |
|-------|---------|------|
| [`ll-healthcheck`](skills/ll-healthcheck/SKILL.md) | GET `/healthz` + GET `/readyz` | liveness / readiness（含 deps map）|

---

## 為什麼細顆粒？

我們選擇「一支 API 一個 SKILL.md」而不是「商戶 / 運營兩份大 SKILL.md」：

- **觸發描述更專注** — 每個 skill 的 description 只描述「自己」何時被選中，agent 在 15 個小 skill 中比在 2 個大 skill 中更容易選對
- **權限隔離直觀** — `ll-bind`（admin OR）/ `ll-admin-add`（嚴格 admin chat）/ `ll-chat-channel-bind`（嚴格 admin user）三套不同的 admin 規則，分檔讓守則不會混淆
- **失敗隔離** — 若某個 skill 描述要改（例如 API 行為變更），不會牽動其他 skill

代價：14 個業務 API + 1 個 healthcheck = 15 份檔案。可接受。

---

## 依 agent 角色選擇要安裝的 skill

⚠️ **不同角色的 agent 不該裝全套 15 個 skill** — 應依該 agent 的職責安裝最小子集，達成**最小授權原則**：

| Agent 角色 | 應安裝的 skill | 對應 token 需求 | 備註 |
|------------|---------------|----------------|------|
| **商戶 agent**（給商戶 / 商戶代理用） | `ll-balance` `ll-transactions` `ll-order` `ll-order-refresh` `ll-order-by-chnl` `ll-market` `ll-channel-chats` `ll-chat-identity` | 只 `ICPAY_TG_TOKEN_MER`（含 `transaction.refresh` + `binding.read` scope） | 無綁定 / admin 寫入能力（缺 admin token）；例外：`ll-order-refresh` 會觸發上游同步 RPC（副作用，scope `transaction.refresh`），`ll-order-by-chnl` 需 caller 綁渠道（否則 403） |
| **運營 / Admin agent**（平台運營用） | 全部 15 個 | `ICPAY_TG_TOKEN_MER` + `ICPAY_TG_TOKEN_ADMIN` | 可做綁定 / 解綁 / admin 增刪 / chat-channel 綁定；不同寫入操作有不同 admin 規則（admin OR / 嚴格 admin chat / 嚴格 admin user），仍受後端對應檢查保護 |
| **SRE agent**（巡檢 / 監控腳本） | `ll-healthcheck` | 不需 token | `/healthz` `/readyz` 為匿名端點 |

> 「商戶 agent」與「Admin agent」是**邏輯角色**（依 token / skill 範圍區分），不是 OpenClaw 的內建概念 — 由你決定要起幾個 OpenClaw 實例（或 workspace）來承載這些角色。

---

## 安裝與載入

OpenClaw 在啟動時掃描下列目錄載入 skill（[官方文檔](https://docs.openclaw.ai/tools/skills-config.md)），優先順序由高到低：

```
<workspace>/.agents/skills/        # 工作區（最高）
<workspace>/skills/
~/.agents/skills/                  # 個人
~/.openclaw/skills/
skills.load.extraDirs              # 自訂（最低）
```

### 安裝範例（依角色 selective install）

從本 repo 根目錄（`icpay-tg-bot-services/`）執行；下面的 `SRC` 指向本 skill 包內 9 份 SKILL.md 的位置。

```bash
SRC="$(pwd)/skills/openclaw/skills"
mkdir -p ~/.openclaw/skills
```

#### 商戶 agent — 只裝 5 個查詢類

```bash
for s in ll-balance ll-transactions ll-order ll-order-refresh ll-order-by-chnl ll-market ll-channel-chats ll-chat-identity; do
  ln -sf "$SRC/$s" "$HOME/.openclaw/skills/$s"
done
```

#### Admin agent — 全裝 15 個

```bash
for s in "$SRC"/ll-*; do
  ln -sf "$s" "$HOME/.openclaw/skills/$(basename "$s")"
done
```

#### SRE agent — 只裝 healthcheck

```bash
ln -sf "$SRC/ll-healthcheck" "$HOME/.openclaw/skills/ll-healthcheck"
```

> 若 OpenClaw 是 per-workspace 跑（每個角色一個 workspace），把 symlink 改放到 `<workspace>/.agents/skills/` 也可，優先級更高、隔離更乾淨。

### 載入後驗證

```bash
openclaw gateway restart
openclaw skills list | grep '^ll-'
```

商戶 agent 預期看到 8 個 `ll-*`、Admin agent 15 個、SRE agent 1 個。

---

## 環境變數設定（依 agent 角色拆 .env）

⚠️ **`.env` 不放在各 skill 目錄下** — OpenClaw 載入機制只讀 `<dir>/SKILL.md`，**不讀** `<dir>/.env`。Skill 是給 agent 看的指示書；實際呼叫 API 用的環境變數來自 OpenClaw 啟動 shell 的 `process.env`。

故本 skill 包提供 **per-role `.env` 範本**（物理隔離 token）：

| 範本檔 | 用途 | 含 `TOKEN_MER` | 含 `TOKEN_ADMIN` |
|--------|------|:--:|:--:|
| [`.env.mer.example`](.env.mer.example) | 商戶 agent | ✅ | ❌（物理隔離）|
| [`.env.admin.example`](.env.admin.example) | Admin agent | ✅ | ✅ |
| [`.env.sre.example`](.env.sre.example) | SRE agent | ❌ | ❌（只 BASE_URL）|

> 商戶 agent 的 shell 只 source `.env.mer` → process env 中沒有 `TOKEN_ADMIN`，即便 agent 收到「請幫我綁定 chat」也呼不出綁定 API（缺 token）。這是**物理層隔離**，比僅靠 prompt 約束可靠。

### 使用方式

```bash
# 1. 複製對應角色的範本
cp skills/openclaw/.env.mer.example   skills/openclaw/.env.mer    # 商戶 agent
# 或
cp skills/openclaw/.env.admin.example skills/openclaw/.env.admin  # Admin agent
# 或
cp skills/openclaw/.env.sre.example   skills/openclaw/.env.sre    # SRE agent

# 2. 編輯填入實際 token / caller ID
$EDITOR skills/openclaw/.env.mer

# 3. 在啟動 OpenClaw 的 shell session 裡 export
set -a; source skills/openclaw/.env.mer; set +a
openclaw gateway start  # 或 restart
```

### 變數總表（含哪些角色用得到）

| 變數 | mer | admin | sre | 說明 |
|------|:--:|:----:|:--:|------|
| `ICPAY_TG_BASE_URL` | ✅ | ✅ | ✅ | 服務 base URL（**不含** `/api/v1`）|
| `ICPAY_TG_TOKEN_MER` | ✅ | ✅ | — | scope: `balance.read` / `transaction.read` / `transaction.refresh` / `market.read` / `binding.read` |
| `ICPAY_TG_TOKEN_ADMIN` | — | ✅ | — | scope: `binding.write` / `admin.write` |
| `ICPAY_TG_CHANNEL` | ✅ | ✅ | — | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | ✅ | ✅ | — | 呼叫端 chat；admin 操作要求是 admin chat |
| `ICPAY_TG_CALLER_USER_ID` | ✅ | ✅ | — | 呼叫端 user |

> ⚠️ 實際填值的 `.env.mer` / `.env.admin` / `.env.sre` 已在 [`.gitignore`](../../.gitignore)，**不可 commit**。token 透過後台分發或 testenv seed 取得，參考 [`docs/how-to-get-api-token.md`](../../docs/how-to-get-api-token.md)。

---

## 快速 smoke test

testenv stack 啟動後（Knife4j UI: <http://tgs.dev-smart.org:8091/doc.html>）：

```bash
# 1. healthcheck（無需 token）
curl -sS "${ICPAY_TG_BASE_URL}/readyz"

# 2. 餘額查詢（需 ICPAY_TG_TOKEN_MER + 三身份參數綁定存在）
curl -sS "${ICPAY_TG_BASE_URL}/api/v1/merchants/${MCHNT_CD}/balance?channel=TG&callerChatId=${ICPAY_TG_CALLER_CHAT_ID}&callerUserId=${ICPAY_TG_CALLER_USER_ID}" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"

# 3. 在 OpenClaw chat 端測：
openclaw agent --message "查商戶 ${MCHNT_CD} 在 TG channel 的餘額"
# → 預期 agent 自動選 ll-balance 並組對 URL
```

---

## 設計原則

1. **`ll-` 前綴**：對應 ll/multipay 集團；後續若有其他服務的 skill 套組（如 `ll-pp-*` 為主交易系統），可在同一 namespace 共存
2. **環境變數而非 plugin manifest**：本 skill 包不附 OpenClaw plugin 程式碼（純 SKILL.md），所有設定由 process env 注入；簡單可攜，缺點是設定 UI 較陽春
3. **business / admin / SRE 三軌**：對應三種 token / 三套守則；agent 在 description 中明確標示「何時觸發」「不該觸發」避免混用
4. **冪等語意明確**：`created` / `wasActive` / `removed` 等欄位語意在每份 SKILL.md 都單獨說明，避免 agent 把冪等命中誤報為錯誤
5. **高敏動作守則**：`ll-bind` / `ll-admin-*` 都有「執行前先 echo 給使用者確認」「審計事件名稱」等指示，降低誤操作風險

---

## 開發者指引

### 新增 skill

1. 在 `skills/<name>/` 建 `SKILL.md`，按既有 9 份的結構撰寫（frontmatter / 何時使用 / 端點 / 入參 / curl / 回傳 / 錯誤碼 / 守則）
2. 在 `README.md` 索引表加一行
3. 開 PR，CI 不會強制檢查 skill 文件，但建議在 description 附 manual smoke test 結果

### 跟 API_Spec.yaml 同步

當 `docs/API_Spec.yaml` 修訂端點 / 入參 / 錯誤碼，務必回頭檢視對應的 SKILL.md：

| API_Spec 變更類型 | 影響的 SKILL.md 段落 |
|-------------------|---------------------|
| 新增 / 移除參數 | `## 入參` 表格 + `## 範例 curl` |
| 新增錯誤碼 | `## 錯誤碼` 表格 |
| 改變授權規則 | `## 必要環境變數` + `## 使用守則` |
| 改變 base path | `## 端點` |

> Lint / 自動同步工具尚未建立；維護靠 PR review。

---

## 相關文件

- [`docs/01-1-PRD.md`](../../docs/01-1-PRD.md) — 8 個業務功能定義
- [`docs/01-5-API_Spec.md`](../../docs/01-5-API_Spec.md) — API 說明（人類友善版）
- [`docs/API_Spec.yaml`](../../docs/API_Spec.yaml) — OpenAPI 3.1 合約（source of truth）
- [`docs/how-to-get-api-token.md`](../../docs/how-to-get-api-token.md) — 取得 / seed / 撤銷 API token
- [OpenClaw 官方文檔](https://docs.openclaw.ai) — skill 系統 / plugin SDK
