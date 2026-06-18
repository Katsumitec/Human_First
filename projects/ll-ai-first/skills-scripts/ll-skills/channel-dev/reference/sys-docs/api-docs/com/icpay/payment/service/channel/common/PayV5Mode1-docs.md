# PayV5Mode1 — V5 單段式支付模式（含收銀台提交）

類別名稱：`com.icpay.payment.service.channel.common.PayV5Mode1`

## 說明

基於 `MyChnlBaseV5` 的第五代單段式支付模式。在 V3 的基礎上新增**收銀台提交**（`doCasherSubmit`）功能，適用於需要 GW 收銀台 submit 後再執行額外交互的場景。此外，異步通知處理中的模板 context 增加了 `x_params` 欄位，存放系統原始訂單資訊。

### 與 PayV3Mode1 的差異

1. 繼承 `MyChnlBaseV5`（支援 `doCasherSubmit`）
2. `doConvResult`：`notifyParams` 中增加 `x_params`（存放 `extParams`）
3. 新增 `doCasherSubmit`：收銀台提交的簽名 → 發送 → 驗章 → 轉換

### 收銀台提交使用的模板

| 模板 | 用途 |
|---|---|
| `txnCasherSubmit_req_sign.ftl` | 收銀台提交請求簽名 |
| `txnCasherSubmit_req.ftl` | 收銀台提交請求報文 |
| `txnCasherSubmit_req_header.ftl` | 收銀台提交 HTTP Header（選用） |
| `txnCasherSubmit_resp.ftl` | 收銀台提交回應轉換 |
| `txnCasherSubmit_resp_sign.ftl` | 收銀台提交回應驗章（選用） |

### 收銀台提交使用的 MerParams

| 參數 | 說明 |
|---|---|
| `url.txn.casher.submit` | 收銀台提交請求 URL |
| `sign.action.casherSubmit.sign` | 是否簽名（預設 `1`） |
| `sign.action.casherSubmit.check` | 回應是否驗章（預設 `0`） |

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV5` → `ChnlServiceWithCasherBase` → `ChnlServiceBase`

## API說明

### Class: PayV5Mode1

#### Protected 部分

##### 交易流程方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 支付請求：`doCommonTrans` → 取得 URL → 跳轉 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 完整交互：簽名 → assign headers → `calcUrl` → 發送 → 驗章 → 轉換 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 異步通知（含 `x_params`）：驗章 → 轉換 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 回傳 null（跳轉類） |
| `doQuery(Map, Map)` | `TxnResultContext` | 查詢：簽名 → assign headers → `calcUrl` → 發送 → 驗章 → 轉換 |
| `doCasherSubmit(Map, Map)` | `TxnResultContext` | 收銀台提交：簽名 → assign headers → `calcUrl` → 發送 → 驗章 → 轉換 |
