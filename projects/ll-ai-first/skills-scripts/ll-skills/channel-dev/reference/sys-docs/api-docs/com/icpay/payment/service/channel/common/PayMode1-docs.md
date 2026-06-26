# PayMode1 — V1 單段式支付模式（Mode1）

類別名稱：`com.icpay.payment.service.channel.common.PayMode1`

## 說明

基於 `MyChnlBase`（V1）的通用支付模式實現。服務自行完成與渠道的完整 HTTP 交互：組裝請求、發送到渠道、處理同步回應、處理異步通知、處理查詢。使用 MD5 簽名，行為由 `extConfig` 配置控制。

### 交易流程

1. **支付請求**（`doConvRequest`）：呼叫 `doCommonTrans` 完成與渠道的交互，取得支付 URL 後回傳跳轉指令
2. **異步通知**（`doConvResult`）：驗章後透過模板轉換為系統內部格式
3. **交易查詢**（`doQuery`）：簽名後向渠道查詢交易狀態

### 使用到的模板

| 模板 | 用途 |
|---|---|
| `pay_req_sign.ftl` | 支付請求簽名 |
| `pay_req.ftl` | 支付請求報文 |
| `pay_sync_resp.ftl` | 支付同步回應轉換 |
| `pay_notify.ftl` | 支付異步通知轉換 |
| `payQry_req_sign.ftl` | 查詢請求簽名 |
| `payQry_req.ftl` | 查詢請求報文 |
| `payQry_resp.ftl` | 查詢回應轉換 |

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBase` → `ChnlServiceBase`

## API說明

### Class: PayMode1

#### Protected 部分

##### 交易流程方法（覆寫自 ChnlServiceBase）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 轉換支付請求：呼叫 `doCommonTrans` 取得結果後產生跳轉 URL |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 完整交易交互：簽名 → 發送 → 轉換同步回應 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 處理異步通知：驗章 → 模板轉換 → 回傳結果 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 同步通知處理（跳轉類不需實作，回傳 null） |
| `doQuery(Map, Map)` | `TxnResultContext` | 交易查詢：簽名 → 發送 → 轉換查詢結果 |
