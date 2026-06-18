---
name: ll-admin-remove
description: 從指定 channel 的 admin 清單移除某個 user 或 chat（DELETE /api/v1/admin）。當運營要求「移除 admin」「離職撤權」時觸發。**Lock-out 保護**：不允許移除最後一個 admin chat（409 LAST_ADMIN_CHAT）。**嚴格 admin chat 授權**：呼叫端 callerChatId 必須是 admin chat；響應為 envelope。
---

# ll-admin-remove — 移除 admin user / chat

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）

## 何時使用

- 「把 user 99900088 從 admin 清單移除」
- 「下線某個 admin chat（群組）」
- 「離職員工撤權」

不是這個 skill 的場景：
- 解除 chat ↔ 商戶綁定 → `ll-unbind`（不一樣的概念）
- 新增 admin → `ll-admin-add`

## 端點

```
DELETE ${ICPAY_TG_BASE_URL}/api/v1/admin
Content-Type: application/json
```

> 雖是 DELETE，仍要帶 JSON body（v1.4 改 body-only；原本是 path style `/admin/{targetType}/{targetId}`）。

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: `admin.write`）|
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | **必為 admin chat** |
| `ICPAY_TG_CALLER_USER_ID` | 審計用 |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `channel` | ✅ | `TG` / `SK` |
| `targetType` | ✅ | `USER`（移除 admin user）/ `CHAT`（移除 admin chat）|
| `targetId` | ✅ | userId 或 chatId（最長 100，**不含分號**）|
| `callerChatId` | ✅ | 呼叫端 chat（嚴格 admin chat）|
| `callerUserId` | ✅ | 呼叫端 user（審計用，不參與授權）|
| `comments` | ❌ | 備註（最長 256）|
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_ADMIN}` |

## 範例 curl

**移除 admin user**

```bash
curl -sS -X DELETE "${ICPAY_TG_BASE_URL}/api/v1/admin" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "TG",
    "targetType": "USER",
    "targetId": "99900088",
    "callerChatId": "-268678324",
    "callerUserId": "88912345",
    "comments": "離職撤權"
  }'
```

**移除 admin chat**（要小心 Lock-out）

```bash
curl -sS -X DELETE "${ICPAY_TG_BASE_URL}/api/v1/admin" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "TG",
    "targetType": "CHAT",
    "targetId": "-100123456789",
    "callerChatId": "-268678324",
    "callerUserId": "88912345"
  }'
```

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；既有回傳欄位放在 `envelope.data` 內。

**`data.removed=true`** — 實際移除

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "targetType": "USER",
    "targetId": "99900088",
    "removed": true,
    "remainingCount": 5
  }
}
```

**`data.removed=false`** — 冪等命中（原本就不在清單）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "targetType": "USER",
    "targetId": "99900088",
    "removed": false,
    "remainingCount": 5
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `TARGET_TYPE_INVALID` | targetType 不在 `USER` / `CHAT` |
| 400 | `TARGET_ID_INVALID` | targetId 含分號或超長 |
| 400 | `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 參數格式 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `admin.write` |
| 403 | `NOT_ADMIN_CHAT` | callerChatId 不在 admin chat 清單 |
| **409** | **`LAST_ADMIN_CHAT`** | **Lock-out 保護：欲移除最後一個 admin chat 被擋下** |
| 502 | `UPSTREAM_ERROR` | DB 故障 |

## 使用守則

- ⚠️ **Lock-out 保護**：移除 admin chat 前，先 dry-run 概念上確認 `remainingCount > 1`；後端會擋下「移除最後一個」回 `409 LAST_ADMIN_CHAT`，不會讓系統陷入「沒人能管」的死局
- 移除 admin user 沒有 Lock-out 限制（admin chat 才是真正的「不可被刪光」資產）
- `removed=false`（冪等）≠ 錯誤；對使用者回「狀態已是非 admin」即可
- `remainingCount` 永遠是「移除後」該 type 的剩餘數；用來輔助提示「目前 channel 還有 N 個 admin chat / user」
- 操作會寫入 audit `ADMIN_REMOVE_USER` / `ADMIN_REMOVE_CHAT` 事件（含 remainingCount，對齊 Issue #20 F-004 驗收）
- 高敏動作 — 執行前最好 echo 給使用者確認 `targetType` + `targetId` 一遍
