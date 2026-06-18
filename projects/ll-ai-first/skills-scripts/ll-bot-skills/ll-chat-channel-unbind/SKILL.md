---
name: ll-chat-channel-unbind
description: 軟刪 chat ↔ 渠道綁定（state 從 1 改為 0；保留審計軌跡，DELETE /api/v1/chat-channel-binding）。當運營 / admin 要求「解除這群組與渠道 08 的綁定」「該渠道下架不再通知此群」時觸發。冪等：已解綁或從未存在的 4-tuple 都回 200 + data.wasActive=false（不像 ll-unbind 會回 404）。授權 admin OR；PK 4-tuple 必須與原綁定完全一致才命中；響應為 envelope。
---

# ll-chat-channel-unbind — chat ↔ 渠道解綁

> 版本：v3.1（對齊 API_Spec.yaml v4.1.0）
> **PK 4-tuple `(category, chnl_id, chnl_mchnt_cd, chat_id)` 必須完整指定 — 入參帶具體大商編時不得用 `'0000'` 替代**。

## 何時使用

- 「解除這群組跟渠道 08 的綁定」
- 「渠道 F1 下架，停止通知這個群」
- 「員工離職把這個 chat-channel 綁定關閉」

不是這個 skill 的場景：
- 重新綁定 → `ll-chat-channel-bind`（也支援 reactivate 復活）
- 解 chat ↔ 商戶 綁定 → `ll-unbind`（PRD-F-002，不是渠道）
- 移除 admin 身份 → `ll-admin-remove`

## 端點

```
DELETE ${ICPAY_TG_BASE_URL}/api/v1/chat-channel-binding
Content-Type: application/json
```

> 雖然是 DELETE，仍要帶 JSON body（與 `ll-unbind` 同款設計）。

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: `binding.write`）|
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端所在 chat；用於 admin OR 判定（**與被解綁的 `chatId` 是不同概念**）|
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID；用於 admin OR 判定 |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `callerChatId` | ✅ | 呼叫端所在 chat；用於 admin OR 判定（**與 `chatId` 不同概念**）|
| `callerUserId` | ✅ | 呼叫端 user ID；用於 admin OR 判定 |
| `chatId` | ✅ | 被解綁的目標 chat ID（DB `chat_id` 條件）；ASCII printable，最長 100；與 `callerChatId` 解耦 |
| `chnlId` | ✅ | 要解綁的渠道編號（2 字英數，case-insensitive，後端 normalize 為大寫）|
| `chnlMchntCd` | ❌ | 渠道商戶號（大商編；語意對齊 `tbl_txn_routing.chnl_mchnt_cd`）；預設 `'0000'`（萬用 row）。**PK 命中必須一致**：原綁定用具體大商編就用具體值，原綁定用 `'0000'` 就用 `'0000'`；不一致則 4-tuple 不命中 → 冪等回 `wasActive=false` 但 DB 實際沒解綁 |
| `comments` | ❌ | 解綁原因（最長 256），UPDATE 至 DB `comments` |
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_ADMIN}` |

## 範例 curl

**解綁萬用 fallback row（原綁定未指定 `chnlMchntCd`，預設 `'0000'`）**：

```bash
curl -sS -X DELETE "${ICPAY_TG_BASE_URL}/api/v1/chat-channel-binding" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "callerChatId": "-1001234567890",
    "callerUserId": "88912345",
    "chatId": "-1001234567890",
    "chnlId": "08",
    "comments": "渠道 08 已下架"
  }'
```

**解綁精準綁定 row（原綁定指定具體 `chnlMchntCd`）；admin 代為解綁他人 chat（`chatId` ≠ `callerChatId`）**：

```bash
curl -sS -X DELETE "${ICPAY_TG_BASE_URL}/api/v1/chat-channel-binding" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "callerChatId": "-1009999999999",
    "callerUserId": "88912345",
    "chatId": "-1001234567890",
    "chnlId": "F1",
    "chnlMchntCd": "ALI_M88",
    "comments": "員工離職清理綁定"
  }'
```

> `chnlMchntCd` 必須與原綁定 PK 一致才命中。若原綁定是 `'0000'` 而解綁傳具體值（或反之），4-tuple 不命中 → 冪等回 `wasActive=false`，但 DB 中該 row 仍存在。

## 回傳（200 always）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；解綁欄位放在 `envelope.data` 內。

**`data.wasActive=true`** — 實際變更（state 1 → 0）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "category": "TG",
    "chnlId": "08",
    "mchntCd": "0000",
    "chatId": "-1001234567890",
    "wasActive": true,
    "unboundAt": "2026-05-08T05:54:17Z"
  }
}
```

**`data.wasActive=false`** — 冪等命中（原本已 state=0；**或 4-tuple 完全不存在**）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "category": "TG",
    "chnlId": "08",
    "mchntCd": "0000",
    "chatId": "-1001234567890",
    "wasActive": false,
    "unboundAt": null
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `BAD_REQUEST` | 入參缺失（含 `chatId`）或 chnlId 格式不合（非 2 字英數）|
| 400 | `VALIDATION_FAILED` | 欄位驗證失敗，例 `chatId` 長度 > 100 / 非 ASCII printable |
| 400 | `MCHNT_CD_INVALID` | `chnlMchntCd` 格式不合 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | 沒 `binding.write` |
| 403 | `NOT_ADMIN` | callerUserId 不在 admin user 清單 **且** callerChatId 不在 admin chat 清單（admin OR 兩條件都不滿足）|
| 403 | `MCHNT_NOT_AUTHORIZED` | `chnlMchntCd` ≠ `'0000'` 且不在 token allowedMchntCds |
| 502 | `UPSTREAM_ERROR` | DB 故障 |

> 對比 `ll-unbind`：本 skill **不會回 404 BINDING_NOT_FOUND**。4-tuple 不存在時冪等視為解綁成功 wasActive=false（與 PRD-F-002 解綁慣例略有差異）。

## 使用守則

- **不存在 vs 已解綁回應一致**：拿到 `wasActive=false` 時無法直接區分「沒這筆綁定」vs「之前已解綁」；agent 對使用者一律回「已是解綁狀態」即可，不需追問
- **admin OR 授權**：callerUserId ∈ `{channel}.users.admin` **或** callerChatId ∈ `{channel}.chats.admin`，兩條件擇一即可；兩者皆不滿足回 403 `NOT_ADMIN`
- **`chatId` vs `callerChatId`**：`chatId` 是要解綁的目標 chat（DB 命中條件），`callerChatId` 是發起呼叫的 chat（僅用於 admin OR 判定）；兩者可相同（一般情境）或不同（admin 從其他 chat 代為解綁）
- **chnlId 大小寫**：input 大小寫無所謂，後端 normalize 為大寫
- **`chnlMchntCd` PK 完整性**：解綁的 4-tuple `(category, chnl_id, chnl_mchnt_cd, chat_id)` 必須與原綁定完全一致 — 若原綁定用 `'0000'` 則解綁也必須用 `'0000'`（或省略，後端 default `'0000'`）；若原綁定用具體大商編（如 `ALI_M88`）則必須帶該具體值。**入參帶具體大商編時不得當作 `'0000'` 替代**；不一致則 4-tuple 不命中，冪等回 `wasActive=false` 但 DB 並未真的解綁
- 留 `comments` 是好習慣，未來查 audit log 比較有上下文
- 操作會寫入 audit `CHAT_CHANNEL_UNBIND` 或 `CHAT_CHANNEL_UNBIND_IDEMPOTENT_HIT` 事件
