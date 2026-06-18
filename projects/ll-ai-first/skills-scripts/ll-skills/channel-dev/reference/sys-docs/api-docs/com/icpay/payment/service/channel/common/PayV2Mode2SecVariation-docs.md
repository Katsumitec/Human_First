# PayV2Mode2SecVariation — V2 兩段式交易模式（加解密變體）

類別名稱：`com.icpay.payment.service.channel.common.PayV2Mode2SecVariation`

## 說明

`PayV2Mode2Sec` 的變體實現，使用自訂的 `EncryptionForSyncAlgVariation` 加密服務（而非通用的 `ChnlEncryptionServiceBase`）。加密時將簽名後的 Map 排序為字串再加密，加密結果放入 `ENCDATA` 欄位；解密時從 `ENCDATA` 欄位中取出密文進行解密。

### 與 PayV2Mode2Sec 的差異

1. 使用硬編碼的 `EncryptionForSyncAlgVariation` 加密服務（非配置驅動）
2. 加密請求時透過 `sortedMapToString` 將 Map 轉為有序字串再加密
3. 加密結果放入 `ENCDATA` 欄位
4. 解密時從同步回應的 `ENCDATA` 欄位中取出密文

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV2` → `ChnlServiceBase`
- **主要相依性**:
  - `EncryptionForSyncAlgVariation` — 自訂加解密服務

## API說明

### Class: PayV2Mode2SecVariation

#### Protected 部分

##### 屬性

| 屬性 | 類型 | 說明 |
|---|---|---|
| `encryptionService` | `EncryptionForSyncAlgVariation` | 加密服務實例（覆蓋父類型別） |

##### 加密服務管理

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `newEncryptionSvc()` | `EncryptionForSyncAlgVariation` | 建構新加密服務實例（硬編碼 `EncryptionForSyncAlgVariation`） |
| `encryptionSvc(boolean)` | `EncryptionForSyncAlgVariation` | 取得加密服務實例 |
| `encryptionSvc()` | `EncryptionForSyncAlgVariation` | 取得加密服務實例（懶載入） |

##### 交易流程方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 簽名 → Map 排序轉字串 → 加密放入 ENCDATA → 組裝請求 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 從 ENCDATA 解密 → 可選驗章 → 模板轉換 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 串接兩段 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 可選解密 → 可選驗章 → 模板轉換 |
| `doQuery(Map, Map)` | `TxnResultContext` | 簽名 → 可選加密 → 發送 → 可選解密 → 可選驗章 |
