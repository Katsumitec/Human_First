# PayV2Mode1 — V2 配置驅動單段式支付模式（Mode1）

類別名稱：`com.icpay.payment.service.channel.common.PayV2Mode1`

## 說明

基於 `MyChnlBaseV2` 的配置驅動單段式支付模式。服務自行完成與渠道的完整 HTTP 交互（Mode1），所有簽名/驗章行為透過可配置的 `signatureService` 委派執行。支援交易請求頭模板、查詢請求頭模板、多種請求模式等配置。

### 交易流程

1. **支付請求**（`doConvRequest`）：`doCommonTrans` 完成交互 → 取得支付 URL → 回傳跳轉指令
2. **異步通知**（`doConvResult`）：設定關鍵參數 → 驗章 → 模板轉換
3. **交易查詢**（`doQuery`）：簽名 → 發送 → 驗章 → 模板轉換

### 使用到的模板

| 模板 | 用途 |
|---|---|
| `txn_req_sign.ftl` | 交易請求簽名 |
| `txn_req.ftl` | 交易請求報文 |
| `txn_req_header.ftl` | 交易請求 HTTP Header（選用） |
| `txn_sync_resp.ftl` | 同步回應轉換 |
| `txn_sync_resp_sign.ftl` | 同步回應驗章（選用） |
| `txn_notify.ftl` | 異步通知轉換 |
| `txn_notify_sign.ftl` | 異步通知驗章（選用） |
| `txnQry_req_sign.ftl` | 查詢請求簽名 |
| `txnQry_req.ftl` | 查詢請求報文 |
| `txnQry_req_header.ftl` | 查詢請求 HTTP Header（選用） |
| `txnQry_resp.ftl` | 查詢回應轉換 |
| `txnQry_resp_sign.ftl` | 查詢回應驗章（選用） |

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV2` → `ChnlServiceBase`
- **已知子類別**: `PayV2Mode1Sec`

## API說明

### Class: PayV2Mode1

#### Protected 部分

##### 交易流程方法（覆寫自 ChnlServiceBase）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 轉換支付請求，產生跳轉 URL，將同步回應內容置入 syncParams |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 完整交易交互：可選簽名 → 模板轉換 → HTTP 發送 → 可選驗章 → 轉換結果 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 處理異步通知：設定關鍵參數 → 可選驗章 → 模板轉換 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 同步通知處理（跳轉類回傳 null） |
| `doQuery(Map, Map)` | `TxnResultContext` | 交易查詢：可選簽名 → HTTP 發送 → 可選驗章 → 模板轉換 |
