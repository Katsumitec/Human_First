---
name: ll-bind
description: 建立外部 chat（如 Telegram chatId）與 icpay 商戶號（mchntCd）之間的綁定關係（POST /api/v1/chat-binding）。當運營 / admin 要求「把 chat X 綁到商戶 Y」「新商戶開通」時觸發；可選 defaultLang 設定群組默認語系。冪等：相同綁定重複呼叫回 200 + data.created=false（state=0 會復活成 1）；授權 admin OR；響應為 envelope。
---

# ll-bind — 商戶 chat 綁定

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）

## 何時使用

- 「把 chat -100123 綁到商戶 GG999999」
- 「新商戶開通群組」
- 「把這個群組設為某商戶的客服群」
- 「重新啟用之前 unbind 過的綁定」（冪等重綁會把 state 從 0 復活成 1）

不是這個 skill 的場景：
- 解綁 → `ll-unbind`
- 設某 user 為 admin → `ll-admin-add`（admin 身份 ≠ 商戶綁定）

## 端點

```
POST ${ICPAY_TG_BASE_URL}/api/v1/chat-binding
Content-Type: application/json
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: `binding.write`）|
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端 chat（必為 admin chat 或 admin user 之一）|
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `channel` | ✅ | `TG` / `SK` |
| `mchntCd` | ✅ | 欲綁定的商戶號（最長 100）|
| `chatId` | ✅ | **欲綁定的目標 chat ID**（最長 100；與 `callerChatId` 是不同概念）|
| `callerChatId` | ✅ | 呼叫端所在 chat |
| `callerUserId` | ✅ | 呼叫端 user |
| `tags` | ❌ | 標籤；多值用半形分號分隔，例 `"MER;VIP;"`（最長 255）|
| `comments` | ❌ | 備註，例「新商戶開通」（最長 256）|
| `defaultLang` | ❌ | chat 群組默認語系；BCP 47 格式（如 `zh-TW` / `en-US` / `zh-CN`）；後端**不做格式校驗**，僅長度上限 16；未指定時讀取側 fallback 為 `en`。**冪等命中（created=false）時不覆寫**既存 defaultLang；新建 / reactivate 時寫入 |
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_ADMIN}` |

## 範例 curl

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/chat-binding" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "TG",
    "mchntCd": "889000000000001",
    "chatId": "-100123456789",
    "callerChatId": "-268678324",
    "callerUserId": "88912345",
    "tags": "MER;",
    "comments": "新商戶 GG999999 開通客服群",
    "defaultLang": "zh-TW"
  }'
```

> `defaultLang` 可省略；省略時讀取側 fallback 為 `en`。

## 回傳

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；綁定欄位放在 `envelope.data` 內。`envelope.defaultLang` 為 server 預設語系 hint（與 `data.defaultLang` 是不同概念：前者是 server hint，後者是該綁定的設定值）。

**201 — 新建成功**

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "mchntCd": "889000000000001",
    "chatId": "-100123456789",
    "state": "1",
    "tags": "MER;",
    "comments": "新商戶 GG999999 開通客服群",
    "defaultLang": "zh-TW",
    "recCrtTs": "2026-04-29T05:00:00Z",
    "created": true
  }
}
```

**200 — 冪等命中**（同綁定已存在；含「將 state=0 復活成 1」的情境）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "channel": "TG",
    "mchntCd": "889000000000001",
    "chatId": "-100123456789",
    "state": "1",
    "tags": "MER;",
    "comments": "...",
    "defaultLang": "zh-TW",
    "recCrtTs": "2026-03-15T10:30:00Z",
    "created": false
  }
}
```

> `data.defaultLang` 缺失或解析失敗 → `null`。冪等命中時即使本次入參帶了新值也**不會覆寫**既存值。

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `MCHNT_CD_INVALID` / `CHANNEL_INVALID` / `CALLER_ID_INVALID` / `VALIDATION_FAILED` | 參數格式不合（`defaultLang` 長度 > 16 → `VALIDATION_FAILED`） |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `binding.write` |
| 403 | `MCHNT_NOT_AUTHORIZED` | token 不能綁此商戶 |
| 403 | `NOT_ADMIN` | callerChatId 不在 admin chat 清單，且 callerUserId 也不在 admin user 清單（admin OR 失敗）|
| 502 | `UPSTREAM_ERROR` | DB 故障 |

## 使用守則

- **權限模型 (admin OR)**：callerChatId 是 admin chat **或** callerUserId 是 admin user，二擇一即可
- **`chatId` ≠ `callerChatId`**：前者是被綁的目標 chat，後者是發起綁定的 admin chat；agent 提示時要明確區分，使用者容易混
- 重綁同一筆 → `created=false` 屬正常（冪等），不需報錯；若回 `state="1"` 但 `created=false` 表示原本被解綁過，現已復活
- `tags` 用半形分號分隔（不是逗號），且 trailing 分號是慣例
- **`defaultLang` 是純語系標籤**：後端不校驗 BCP 47 格式，但只接受長度 ≤ 16 字元；若使用者需要更改既有綁定的 `defaultLang`，請先 `ll-unbind` 後重新 `ll-bind`（冪等命中不會覆寫）
- 操作會寫入 audit log（`CHAT_BINDING_CREATE` / `_REACTIVATE` / `_IDEMPOTENT_HIT`）— 是高敏動作，回應給使用者前確認 mchntCd / chatId 兩端都對
