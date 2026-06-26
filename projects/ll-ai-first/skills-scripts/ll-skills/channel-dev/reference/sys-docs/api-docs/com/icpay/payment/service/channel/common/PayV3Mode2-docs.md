# PayV3Mode2 — V3 兩段式交易模式（Mode2）

類別名稱：`com.icpay.payment.service.channel.common.PayV3Mode2`

## 說明

繼承自 `PayV3Mode1` 的兩段式交易模式。將交易拆為兩段：`doConvRequest` 組裝請求上下文交由系統框架發送，`doConvSyncResultForAsync` 處理同步回應。繼承了 V3 的所有特性（Header 支援、JWT、URL 變數）。

### 與 PayV3Mode1 的差異

- `doConvRequest`：不直接發送 HTTP，而是組裝 `ChnlRequestContext` 回傳給系統
- `doConvSyncResultForAsync`：實作同步回應處理（非 null）
- `doCommonTrans`：串接兩段完成交互
- 異步通知和查詢：繼承自 `PayV3Mode1`

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `PayV3Mode1` → `MyChnlBaseV2` → `ChnlServiceBase`

## API說明

### Class: PayV3Mode2

#### Protected 部分

##### 交易流程方法（覆寫）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 簽名 → 模板轉換 → assign headers → 組裝 `ChnlRequestContext` |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 可選驗章 → 模板轉換同步回應 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 串接：`doConvRequest` → HTTP 發送 → `doConvSyncResultForAsync` |
