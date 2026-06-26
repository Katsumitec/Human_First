---
name: ll-unbind
description: 軟刪 chat ↔ 商戶綁定（state 從 1 改為 0；保留審計軌跡，DELETE /api/v1/chat-binding）。當運營 / admin 要求「解除 chat X 與商戶 Y 的綁定」「員工離職停用群組」時觸發。冪等：已解綁回 200 + data.wasActive=false；綁定從未建立過會回 404 BINDING_NOT_FOUND（與 ll-chat-channel-unbind 不同）；授權 admin OR；響應為 envelope。
---

# ll-unbind — 商戶 chat 解綁

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）

## 何時使用

- 「解除 chat -100123 跟商戶 GG999999 的綁定」
- 「員工離職把這個群關閉」
- 「停用過期商戶的群組」

不是這個 skill 的場景：
- 重新綁定 → `ll-bind`（也支援冪等復活）
- 移除 admin 身份 → `ll-admin-remove`

## 端點

```
DELETE ${ICPAY_TG_BASE_URL}/api/v1/chat-binding
Content-Type: application/json
```

> 雖然是 DELETE，仍要帶 JSON body（v1.4 ADR：避免 query string 過長與審計留痕）。

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: `binding.write`）|
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | 必為 admin chat 或 admin user 之一 |
| `ICPAY_TG_CALLER_USER_ID` | 同上 |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `channel` | ✅ | `TG` / `SK` |
| `mchntCd` | ✅ | 商戶號 |
| `chatId` | ✅ | 欲解綁的目標 chat |
| `callerChatId` | ✅ | 呼叫端 chat |
| `callerUserId` | ✅ | 呼叫端 user |
| `comments` | ❌ | 解綁原因，例「員工離職」（最長 256）|
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_ADMIN}` |

## 範例 curl

```bash
curl -sS -X DELETE "${ICPAY_TG_BASE_URL}/api/v1/chat-binding" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "TG",
    "mchntCd": "889000000000001",
    "chatId": "-100123456789",
    "callerChatId": "-268678324",
    "callerUserId": "88912345",
    "comments": "員工離職"
  }'
```

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；既有回傳欄位放在 `envelope.data` 內。

**`data.wasActive=true`** — 實際變更（state 1 → 0）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "mchntCd": "889000000000001",
    "chatId": "-100123456789",
    "state": "0",
    "wasActive": true,
    "unboundAt": "2026-04-29T05:00:00Z"
  }
}
```

**`data.wasActive=false`** — 冪等命中（原本就是 state=0）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "mchntCd": "889000000000001",
    "chatId": "-100123456789",
    "state": "0",
    "wasActive": false,
    "unboundAt": "2026-03-15T10:30:00Z"
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `MCHNT_CD_INVALID` / `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 參數格式 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` / `MCHNT_NOT_AUTHORIZED` / `NOT_ADMIN` | 越權 / 非 admin |
| 404 | `BINDING_NOT_FOUND` | 該綁定關係從未建立過（≠ 已解綁；那是 200 + wasActive=false）|
| 502 | `UPSTREAM_ERROR` | DB 故障 |

## 使用守則

- **soft delete**：DB 紀錄保留（state=0），不物理刪除；審計可追溯
- `wasActive=false`（冪等）≠ `BINDING_NOT_FOUND`（不存在）— 兩者語意截然不同
  - 冪等：「之前已經解綁過了」→ 對使用者回「狀態已是解綁」即可
  - 不存在：「沒這筆綁定」→ 反問使用者是不是搞錯 mchntCd / chatId
- 留 `comments` 是好習慣，未來查 audit log 比較有上下文
- 操作會寫入 audit `CHAT_UNBIND` 事件
