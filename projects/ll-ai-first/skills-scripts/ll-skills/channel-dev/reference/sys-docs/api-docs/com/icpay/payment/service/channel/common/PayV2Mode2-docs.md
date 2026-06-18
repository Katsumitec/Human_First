# PayV2Mode2 — V2 配置驅動兩段式交易模式（Mode2）

類別名稱：`com.icpay.payment.service.channel.common.PayV2Mode2`

## 說明

基於 `MyChnlBaseV2` 的兩段式交易模式。與 Mode1 不同，Mode2 將交易拆為兩段：`doConvRequest` 組裝請求上下文（含 URL、Header、Body），交由系統框架發送 HTTP 請求；`doConvSyncResultForAsync` 處理系統框架收到的同步回應。此模式適用於需要由系統統一管理 HTTP 連線的場景。

### 交易流程

1. **第一段** `doConvRequest`：簽名 → 模板轉換 → 組裝 `ChnlRequestContext`（不直接發送）
2. **第二段** `doConvSyncResultForAsync`：接收系統發送後的同步回應 → 驗章 → 模板轉換
3. **異步通知** `doConvResult`：同 Mode1
4. **查詢** `doQuery`：同 Mode1（單段完成）
5. **通用交易** `doCommonTrans`：串接第一段和第二段，由 `httpProxy` 發送

### 使用到的模板

同 `PayV2Mode1`（見其文件）。

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV2` → `ChnlServiceBase`

## API說明

### Class: PayV2Mode2

#### Protected 部分

##### 交易流程方法（覆寫自 ChnlServiceBase）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 第一段：簽名 → 模板轉換 → 組裝 `ChnlRequestContext`（含 URL、Header、Body、ContentType、Method） |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 第二段：接收同步回應 → 可選驗章 → 模板轉換 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 串接兩段：`doConvRequest` → HTTP 發送 → `doConvSyncResultForAsync` |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 處理異步通知：驗章 → 模板轉換 |
| `doQuery(Map, Map)` | `TxnResultContext` | 交易查詢（單段完成） |
