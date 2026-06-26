---
name: ll-admin-add
description: 將 targetUserId 加入指定 channel 的 admin user 清單（POST /api/v1/admin/users）。當運營要求「把 user X 設為 admin」「新增管理員」時觸發。冪等：已是 admin 回 200 + data.created=false。**嚴格 admin chat 授權**：呼叫端 callerChatId 必須是 admin chat（admin user 身份不夠）；響應為 envelope。
---

# ll-admin-add — 註冊 user 為 admin

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）

## 何時使用

- 「把 user 88912345 設為 admin」
- 「給某運營人員管理員權限」
- 「新增 channel TG 的 admin」

不是這個 skill 的場景：
- 把 chat 設為 admin chat → 不在本 API 範圍（admin chat 由運維直接配 `tbl_mer_params`）
- 把 chat 綁定到商戶 → `ll-bind`（這是商戶綁定，不是 admin 身份）

## 端點

```
POST ${ICPAY_TG_BASE_URL}/api/v1/admin/users
Content-Type: application/json
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: `admin.write`）|
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | **必須是 admin chat**（不可只是 admin user）|
| `ICPAY_TG_CALLER_USER_ID` | 審計用 |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `channel` | ✅ | `TG` / `SK` |
| `targetUserId` | ✅ | 欲設為 admin 的 user ID（最長 100，**不含分號**）|
| `callerChatId` | ✅ | 呼叫端 chat（嚴格 admin chat）|
| `callerUserId` | ✅ | 呼叫端 user（審計）|
| `comments` | ❌ | 備註，例「新進運營」（最長 256）|
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_ADMIN}` |

## 範例 curl

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/admin/users" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "TG",
    "targetUserId": "99900088",
    "callerChatId": "-268678324",
    "callerUserId": "88912345",
    "comments": "新進運營 alice"
  }'
```

## 回傳

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；既有回傳欄位放在 `envelope.data` 內。

**201 — 新增成功**

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "targetUserId": "99900088",
    "comments": "新進運營 alice",
    "registeredAt": "2026-04-29T05:00:00Z",
    "created": true
  }
}
```

**200 — 冪等命中**（已是 admin）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "targetUserId": "99900088",
    "comments": null,
    "registeredAt": "2026-03-15T10:30:00Z",
    "created": false
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `TARGET_USER_ID_INVALID` | targetUserId 含分號或超長 |
| 400 | `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 參數格式 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `admin.write` |
| 403 | `NOT_ADMIN_CHAT` | callerChatId 不在 admin chat 清單（admin user 身份不夠！）|
| 502 | `UPSTREAM_ERROR` | DB 故障 |

## 使用守則

- **嚴格 admin chat**：與 `ll-bind` 的 admin OR 不同 — 註冊 admin 是高敏動作，必須在 admin chat 內由 admin chat 成員發起；admin user 身份不夠
- 不要把這個跟「商戶綁定」混為一談 — admin 是 channel 層級的管理身份，不綁特定商戶
- 操作會寫入 audit `ADMIN_USER_REGISTER` 事件
- 提示給使用者：「user X 已加入 channel TG 的 admin 清單，現在他可以執行 admin OR 類操作（綁定 / 解綁）；但若要再註冊 / 移除 admin，仍需在 admin chat 內」
