---
name: ll-market
description: 查詢 OKX P2P 市場 USDT/CNY 即時行情（GET /api/v1/market/okx-p2p）。當使用者問「OKX 行情」「USDT 對人民幣多少錢」「現在匯率」「P2P 報價」時觸發。資料從 Redis 快取讀取，由 legacy scraper 定時寫入；caller 必須有 state='1' 綁定（防白嫖）；響應為 envelope。
---

# ll-market — OKX P2P 匯率行情

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）

## 何時使用

- 「OKX 現在匯率多少」
- 「USDT 對人民幣 P2P 報價」
- 「支付寶收 USDT 多少錢一個」
- 「行情中位數」

不是這個 skill 的場景：
- 商戶結算 / 帳戶餘額 → `ll-balance`（不一樣的概念）
- 其他交易所 / 法幣對 → 暫不支援

## 端點

```
GET ${ICPAY_TG_BASE_URL}/api/v1/market/okx-p2p
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端 chat ID（須有 `state='1'` 綁定）|
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID |

> ⚠️ 雖然「公開行情」概念上不需 token，本端點仍要求三身份參數（防止白嫖）。`Authorization` header 視部署而定 —— testenv 上預設仍要求 `BearerAuth`，可帶 `ICPAY_TG_TOKEN_MER`。

## 入參

| 位置 | 名稱 | 必填 | 說明 |
|------|------|:---:|------|
| query | `channel` | ✅ | `TG` / `SK` |
| query | `callerChatId` | ✅ | 從環境變數；須有 `state='1'` 綁定 |
| query | `callerUserId` | ✅ | 從環境變數 |
| query | `tradeMode` | ❌ | `C2C`（預設）/ `BLOCK_TRADE` |
| query | `paymentMethod` | ❌ | `alipay` / `wxpay` / `bank` / `all`（預設）|
| query | `limit` | ❌ | `1..10`，預設 `10` |
| header | `Authorization` | 視部署 | `Bearer ${ICPAY_TG_TOKEN_MER}` |

## 範例 curl

```bash
curl -sS "${ICPAY_TG_BASE_URL}/api/v1/market/okx-p2p?channel=TG&callerChatId=-268678324&callerUserId=88912345&tradeMode=C2C&paymentMethod=alipay&limit=5" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"
```

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；行情欄位放在 `envelope.data` 內。

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "tradeMode": "C2C",
    "paymentMethod": "alipay",
    "list": [
      {
        "merchantName": "OKX商家A",
        "price": "7.0450",
        "paymentMethods": ["alipay"],
        "limitMin": "100",
        "limitMax": "50000",
        "updateTs": "2026-04-29T05:00:00Z"
      }
    ],
    "stats": {
      "min": "7.0450",
      "max": "7.0680",
      "avg": "7.0560",
      "median": "7.0555",
      "cachedAt": "2026-04-29T05:01:00Z"
    }
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `TRADE_MODE_INVALID` / `PAYMENT_METHOD_INVALID` | 列舉值不合 |
| 400 | `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 三身份參數問題 |
| 403 | `CALLER_NOT_BOUND` | caller 在指定 channel 下沒任何 `state='1'` 綁定 |
| 503 | `OKX_CACHE_MISS` | Redis 快取缺失（scraper 未跑 / 過期）|

## 使用守則

- 行情有快取延遲（`stats.cachedAt` 可看），別宣稱「即時」；建議說「最近一次更新」
- `limit` 上限 10，要看更多筆暫無 API 支援
- `OKX_CACHE_MISS` 503 屬於上游異常，重試 1-2 次後仍失敗 → 提示「行情暫不可用」
- 統計欄位 `stats` 比逐筆 `list` 對使用者更直覺；先報 `min` / `max` / `median`，要詳細再列 `list`
- 不要把行情當交易報價對外承諾（這只是參考數據）
