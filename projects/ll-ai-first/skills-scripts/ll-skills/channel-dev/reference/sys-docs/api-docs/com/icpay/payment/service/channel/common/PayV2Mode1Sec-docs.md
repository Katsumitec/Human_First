# PayV2Mode1Sec — V2 單段式支付模式（含加解密）

類別名稱：`com.icpay.payment.service.channel.common.PayV2Mode1Sec`

## 說明

繼承自 `PayV2Mode1`，在其基礎上新增**加密/解密**能力。交易請求可在簽名後進行加密，同步回應可在驗章前進行解密，異步通知也支援解密處理。適用於渠道要求加密通訊的場景。

### 與 PayV2Mode1 的差異

1. `doCommonTrans`：簽名後可選加密（`shouldEncryptRequest`），回應可選解密（`shouldDecryptForResponse`）再驗章
2. `doConvResult`：通知可選解密（`shouldDecryptForNotify`）再驗章
3. `doQuery`：查詢可選加密（`shouldEncryptRequestForQuery`），回應可選解密（`shouldDecryptForResponse`）再驗章

### 額外使用到的模板

| 模板 | 用途 |
|---|---|
| `txn_req_enc.ftl` | 交易請求加密 |
| `txnQry_req_enc.ftl` | 查詢請求加密 |

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `PayV2Mode1` → `MyChnlBaseV2` → `ChnlServiceBase`

## API說明

### Class: PayV2Mode1Sec

#### Protected 部分

##### 交易流程方法（覆寫自 PayV2Mode1）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 同父類 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 簽名 → 可選加密 → 發送 → 可選解密 → 可選驗章 → 轉換結果 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 可選解密 → 可選驗章 → 模板轉換 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 同父類（回傳 null） |
| `doQuery(Map, Map)` | `TxnResultContext` | 簽名 → 可選加密 → 發送 → 可選解密 → 可選驗章 → 轉換結果 |
