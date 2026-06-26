# PayV2Mode2Sec — V2 兩段式交易模式（含加解密）

類別名稱：`com.icpay.payment.service.channel.common.PayV2Mode2Sec`

## 說明

繼承自 `MyChnlBaseV2` 的兩段式交易模式，在 `PayV2Mode2` 基礎上新增**加密/解密**能力。交易流程中可在簽名後加密請求、在驗章前解密回應、在驗章前解密異步通知。

### 與 PayV2Mode2 的差異

1. `doConvRequest`：簽名後可選加密（`shouldEncryptRequest`）
2. `doConvSyncResultForAsync`：可選解密（`shouldDecryptForResponse`）→ 可選驗章
3. `doConvResult`：可選解密（`shouldDecryptForNotify`）→ 可選驗章
4. `doQuery`：簽名後可選加密（`shouldEncryptRequestForQuery`），回應可選解密

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV2` → `ChnlServiceBase`

## API說明

### Class: PayV2Mode2Sec

#### Protected 部分

##### 交易流程方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 簽名 → 可選加密 → 組裝請求上下文 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 可選解密 → 可選驗章 → 模板轉換 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 串接兩段 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 可選解密 → 可選驗章 → 模板轉換 |
| `doQuery(Map, Map)` | `TxnResultContext` | 簽名 → 可選加密 → 發送 → 可選解密 → 可選驗章 → 轉換 |
