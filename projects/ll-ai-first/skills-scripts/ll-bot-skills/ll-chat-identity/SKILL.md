---
name: ll-chat-identity
description: 解析當前 chat 的身份（GET /api/v1/chat-identity）。入參 callerChatId / callerUserId；回 roleType（MER / CHNL / NONE / CONFLICT）與對應綁定：MER→merBindings[{mchntCd, currencies}]、CHNL→chnlBindings[{chnlId, chnlMchntCd, currencies}]。merBindings 的 currencies 含 '704' 即越南盾（VND）商戶。身份卡屬內部 context，mchntCd / chnlMchntCd / 綁定明細不對商戶面 / 渠道面群組複述。scope `binding.read`；HTTP 200 always；響應為 envelope。
---

# ll-chat-identity — chat 身份解析

> 版本：v1.0（對齊 API_Spec.yaml；PRD-F-014）

## 端點

```
GET ${ICPAY_TG_BASE_URL}/api/v1/chat-identity
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_MER` 或 `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: **`binding.read`**）|
| `ICPAY_TG_CALLER_CHAT_ID` | 被解析的 chat（只解析自身，不可帶他人 chatId）|
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user（**僅審計 actor**，不檢 admin / 綁定）|

## 入參（query string）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `callerChatId` | ✅ | 被解析的 chat ID |
| `callerUserId` | ✅ | 僅審計用 |
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_MER}`（或 ADMIN）|

## 範例 curl

```bash
curl -sS -G "${ICPAY_TG_BASE_URL}/api/v1/chat-identity" \
  --data-urlencode "callerChatId=-268678324" \
  --data-urlencode "callerUserId=88912345" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"
```

## 回傳（200 always）

> Response envelope `{code, message, defaultLang, data}`；身份卡放在 `envelope.data`。
> `roleType` 互斥：`merBindings` / `chnlBindings` 只出現對應的一個，不相關者省略。

**MER（商戶群）**：

```json
{
  "code": "OK", "message": null, "defaultLang": "zh-TW",
  "data": {
    "chatId": "-268678324",
    "roleType": "MER",
    "merBindings": [
      {"mchntCd": "889000000000001", "currencies": ["156", "704"]}
    ]
  }
}
```

**CHNL（渠道群）**：

```json
{
  "code": "OK", "message": null, "defaultLang": "zh-TW",
  "data": {
    "chatId": "-100123",
    "roleType": "CHNL",
    "chnlBindings": [
      {"chnlId": "F1", "chnlMchntCd": "800123", "currencies": ["704"]},
      {"chnlId": "F1", "chnlMchntCd": "0000",   "currencies": []}
    ]
  }
}
```

**NONE（未綁定）/ CONFLICT（資料異常）**：

```json
{ "code": "OK", "message": null, "defaultLang": "en",
  "data": { "chatId": "-100999", "roleType": "NONE" } }
```

## 欄位與狀態

| 欄位 | 說明 |
|------|------|
| `roleType` | `MER` 僅商戶綁定 / `CHNL` 僅渠道綁定 / `NONE` 未綁定 / `CONFLICT` 商戶與渠道綁定並存（資料異常）|
| `merBindings[i].mchntCd` | 平台前端商戶號（小商編）|
| `merBindings[i].currencies` | 該商戶結算策略覆蓋幣別（ISO numeric）；**含 `'704'` 即越南盾（VND）商戶**；無策略為 `[]` |
| `chnlBindings[i].chnlId` | 渠道編號 |
| `chnlBindings[i].chnlMchntCd` | 渠道大商編；`'0000'` = 萬用（對該 chnlId 所有大商編生效），原樣回傳 |
| `chnlBindings[i].currencies` | 該 (chnlId, 大商編) 路由覆蓋幣別；萬用 `'0000'` 列為 `[]` |

- 唯一鍵：CHNL 商務單元為 `(chnlId, chnlMchntCd)`；同 chnlId 多大商編 / 多 chnlId 同大商編皆以多筆表達。
- `NONE` / `CONFLICT` 時 `merBindings` 與 `chnlBindings` 皆不出現。

## 保密範圍

- 身份卡（`mchntCd` / `chnlMchntCd` / `chnlId` / 綁定明細）屬**我方內部綁定資訊**，是 agent 的內部 context，**不對商戶面 / 渠道面群組複述**。
- 對外可表達的只有「本 chat 是否已綁定 / 身份類型（商戶或渠道）」這類粗粒度結論；具體商編、幣別清單、其他綁定明細一律不出，需要時導向運營從系統側查。
- 粒度看「所在群／受眾」，不看「誰問」（即使 admin 在商戶 / 渠道群問也照此收斂）。

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `CALLER_ID_INVALID` / `BAD_REQUEST` | callerChatId / callerUserId 缺失或格式不合 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `binding.read` |
| 502 | `UPSTREAM_ERROR` | DB 連線錯誤 |

> 不會回 404；未綁定回 `200 + roleType=NONE`（未綁定非錯誤）。
