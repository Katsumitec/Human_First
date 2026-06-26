---
name: ll-balance
description: 查詢 icpay 平台某商戶於各幣別的可用 / 義務 / 凍結餘額（GET /api/v1/merchants/{mchntCd}/balance）。當使用者問「商戶 X 的餘額」「USD 可用多少」「凍結了多少」時觸發。未指定 mchntCd 時自動使用 caller-aggregated 變體（GET /api/v1/balance），由 callerChatId 反查綁定商戶；綁多個時回 400 MULTIPLE_BINDINGS 要求顯式指定。響應為 envelope。
---

# ll-balance — 商戶餘額查詢

> 版本：v3.1（對齊 PRD §9 / Issue #42 已落地的 API）

## 何時使用

- 「商戶 GG999999 的餘額」
- 「我商戶在 USD 的可用餘額」
- 「凍結了多少」
- 「現在帳上能動的錢」

不是這個 skill 的場景：
- 查交易明細 → `ll-transactions`
- 查單一訂單 → `ll-order`
- 行情 / 匯率 → `ll-market`

## 端點

### 主端點（指定商戶）

```
GET ${ICPAY_TG_BASE_URL}/api/v1/merchants/{mchntCd}/balance
```

### caller-aggregated 變體（省略 mchntCd；caller-bound）

```
GET ${ICPAY_TG_BASE_URL}/api/v1/balance
```

由 callerChatId 反查綁定商戶：caller 綁 1 個 → 自動使用；綁 ≥ 2 個 → 400 `MULTIPLE_BINDINGS`（要求顯式指定）；無綁定 → 403 `CHAT_NOT_BOUND_TO_MCHNT`（或 401 早期失敗）。

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL，例：`http://tgs.dev-smart.org:8091` |
| `ICPAY_TG_TOKEN_MER` | Bearer token（scope: `balance.read`）|
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端 chat ID |
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID |

## 入參

| 位置 | 名稱 | 必填 | 說明 |
|------|------|:---:|------|
| path | `mchntCd` | ⚠️ | 商戶號（最長 100，`[0-9A-Za-z_]+`）；**省略則走 caller-aggregated 變體**（`GET /api/v1/balance`，不在 path 也不在 query），由 callerChatId 反查綁定商戶 |
| query | `channel` | ✅ | 列舉值 `TG` / `SK` |
| query | `callerChatId` | ✅ | 從 `ICPAY_TG_CALLER_CHAT_ID` |
| query | `callerUserId` | ✅ | 從 `ICPAY_TG_CALLER_USER_ID` |
| query | `currency` | ❌ | 幣別過濾；接受 ISO 數字（`156`）/ 字母（`CNY`）/ 中文（`人民幣`）|
| header | `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_MER}` |

## 範例 curl

```bash
# 指定商戶
curl -sS "${ICPAY_TG_BASE_URL}/api/v1/merchants/889000000000001/balance?channel=TG&callerChatId=-268678324&callerUserId=88912345&currency=CNY" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"

# caller-aggregated（省略 mchntCd；caller 必須綁定唯一商戶）
curl -sS "${ICPAY_TG_BASE_URL}/api/v1/balance?channel=TG&callerChatId=-268678324&callerUserId=88912345&currency=CNY" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"
```

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；`mchntCd` / `balances` 欄位放在 `envelope.data` 內。

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "mchntCd": "889000000000001",
    "balances": [
      {
        "currCd": "156",
        "currAlpha": "CNY",
        "currName": "人民幣",
        "availableBalance": "1,234,567.89",
        "obligatedBalance": "1,000.00",
        "frozenT1Balance": "200.00",
        "frozenBalance": "0.00",
        "unit": "0.01",
        "state": "1"
      }
    ]
  }
}
```

金額單位為「元」（已換算自最小單位 `unit`），可直接顯示給使用者。

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `MCHNT_CD_INVALID` | mchntCd 格式不合 |
| 400 | `MULTIPLE_BINDINGS` | caller 綁多個商戶但呼叫 caller-aggregated 變體未指定 mchntCd；應改用主端點顯式指定 |
| 400 | `CHANNEL_INVALID` | channel 不在 `TG`/`SK` |
| 400 | `CALLER_ID_INVALID` | callerChatId / callerUserId 格式不合 |
| 400 | `CURRENCY_INVALID` | 幣別格式 / 代碼不合 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `balance.read` |
| 403 | `MCHNT_NOT_AUTHORIZED` | token 不能查此商戶 |
| 403 | `CHAT_NOT_BOUND_TO_MCHNT` | caller chat 沒綁定此商戶 |
| 404 | `MCHNT_NOT_FOUND` | 商戶不存在 |
| 404 | `CURRENCY_NOT_ALLOWED` | 商戶結算白名單沒開該幣別 |

## 使用守則

- *使用者沒指定 mchntCd 時，先嘗試 caller-aggregated 變體*（呼叫 `/api/v1/balance`）；若回 400 `MULTIPLE_BINDINGS` 才反問「你要查哪個商戶」
- 不要主動猜 mchntCd
- caller 通常只綁一個商戶，caller-aggregated 變體可省 80%+ 的提問
- 不要把 token、callerChatId、callerUserId 寫進 commit 訊息或公開 log
- `state="0"` 的幣別代表已停用；不必特意顯示
- 回應建議格式：「{currName} 可用 {availableBalance}（凍結 {frozenBalance}）」一行一幣
- **金額欄位原樣顯示、保留千分位逗號**：`availableBalance` / `obligatedBalance` / `frozenT1Balance` / `frozenBalance` 後端回傳的字串已是最終顯示格式（固定兩位小數、千位以上含千分位逗號，例：`1,005.00`、`1,234,567.89`）。直接原樣輸出該字串、**完整保留其中的逗號**（後端給 `1,005.00` 就顯示 `1,005.00`，不可寫成 `1005.00`），不可改寫、四捨五入、補 / 去零或移除任何數字格式
