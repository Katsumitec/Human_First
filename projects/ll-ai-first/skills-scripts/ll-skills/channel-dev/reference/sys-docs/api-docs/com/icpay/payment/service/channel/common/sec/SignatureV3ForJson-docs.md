# SignatureV3ForJson -- JSON 格式通用簽名服務（V3，代理模式）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV3ForJson`

## 說明

V3 版通用型簽名服務，以 JSON 字串作為簽名來源。相較 V2 版，V3 引入了 `SignatureProxy` 代理模式，透過 `SignatureManager` 動態載入簽名代理，取代硬編碼的 switch-case 演算法選擇。這使得新增簽名演算法時無需修改本類。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlSignatureServiceBase`
- **已知子類別**: `SignatureV3ForMap`
- **主要相依性**: `ChnlSignatureServiceBase`、`SignatureManager`（`secProxy` package）、`SignatureProxy`

## API說明

### Class: SignatureV3ForJson

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `keyConnector` | 密鑰連接符 | `"&key="` |
| `sortMessageForSign` | 是否排序 | `"true"` |
| `sortWthKeyForSign` | 排序是否含密鑰 | `"false"` |
| `signatureKeyField` | 密鑰字段名 | `null` |
| `removeEmptyForSign` | 是否移除空字段 | `"false"` |
| `removeNullForSign` | 是否移除 null 值 | `"false"` |
| `signatureUpper` | 簽名是否轉大寫 | `"false"` |
| `signSourceUpper` | 簽名原文是否轉大寫 | `"false"` |
| `signSourceLower` | 簽名原文是否轉小寫 | `"false"` |
| `signAlgorithm` | 簽名演算法 | `"MD5"` |
| `charset` | 字符集 | `"UTF-8"` |

##### 建構式

- **`SignatureV3ForJson()`**

##### 簽名與驗簽方法

- **`String sign(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行簽名，透過 `SignatureProxy` 代理計算。

- **`boolean checkSign(Map msg, Map params)`**
  驗證報文簽名，透過 `SignatureProxy` 代理驗證。

##### 配置存取方法

- **`String getKeyConnector()`** -- 密鑰連接符，預設 `"&key="`
- **`boolean shouldSortMessage()`** -- 是否排序，預設 `true`
- **`boolean shouldSortWithKey()`** -- 排序是否含密鑰，預設 `false`
- **`boolean shouldRemoveEmpty()`** -- 是否移除空字段，預設 `false`
- **`boolean shouldRemoveNull()`** -- 是否移除 null 值，預設 `false`
- **`boolean shouldSignatureToUppercase()`** -- 簽名是否轉大寫，預設 `false`
- **`boolean shouldSignSourceToUppercase()`** -- 簽名原文是否轉大寫，預設 `false`
- **`boolean shouldSignSourceToLowercase()`** -- 簽名原文是否轉小寫，預設 `false`
- **`String getSignAlgorithm()`** -- 取得簽名演算法，支援按 stage 配置
- **`String getEncoding()`** -- 取得字符集

#### Protected 部分

- **`String calcSignSource(Map msg, Map params, Map outputMap)`**
  計算簽名原文（JSON 格式）。

- **`String signWithAlg(String signSrc, String key)`** / **`String signWithAlg(String alg, String signSrc, String key)`**
  透過 `SignatureManager.newProxy(alg)` 建立代理並計算簽名。

- **`boolean checkSignWithAlg(String signSrc, String signature, String key, String verifyKey)`**
  透過代理驗證簽名。

- **`String mapToJson(Map map)`** -- Map 轉 JSON
- **`String getSignatureKeyField()`** -- 密鑰字段名
- **`String tryGetKey(String keyId)`** -- 嘗試取得密鑰
- **`static String getMaskedKey(String key)`** -- 遮蔽密鑰
