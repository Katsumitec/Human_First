# PayV3Mode3 — V3 兩段式交易模式變體（Mode3）

類別名稱：`com.icpay.payment.service.channel.common.PayV3Mode3`

## 說明

繼承自 `PayV3Mode1` 的兩段式交易模式變體。與 `PayV3Mode2` 結構相同，差異在於 `doConvRequest` 和 `doConvSyncResultForAsync` 的具體實現邏輯。繼承了 V3 的所有特性（Header 支援、JWT、URL 變數）。

### 與 PayV3Mode2 的差異

功能上基本相同，均為兩段式交易模式。兩者的差異體現在特定渠道的處理邏輯細節上。

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `PayV3Mode1` → `MyChnlBaseV2` → `ChnlServiceBase`

## API說明

### Class: PayV3Mode3

#### Protected 部分

##### 交易流程方法（覆寫）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 簽名 → 模板轉換 → assign headers → 組裝 `ChnlRequestContext` |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 可選驗章 → 模板轉換同步回應 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 串接兩段 |
