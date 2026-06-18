# SignatureV2ForJson -- JSON 格式通用簽名服務（V2，多演算法支援）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV2ForJson`

## 說明

V2 版通用型簽名服務，以 JSON 字串作為簽名來源。相較 V1 版（SignatureForJson），新增多種簽名演算法支援（MD5、SHA1、SHA256、ED25519、RSA、HMAC、HMAC_RSA），可透過 `signAlgorithm` 配置項切換。同時支援按階段（stage）設定不同演算法。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlSignatureServiceBase`
- **已知子類別**: `SignatureV2ForMap`
- **主要相依性**: `ChnlSignatureServiceBase`、`SignAlgorithmMD5`、`SignAlgorithmSHA1`、`SignAlgorithmSHA256`、`SignAlgorithmEd25519`、`SignAlgorithmRSA`、`SignAlgorithmHmac`、`SignAlgorithmHmacRsa`

## API說明

### Class: SignatureV2ForJson

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

- **`SignatureV2ForJson()`**

##### 簽名與驗簽方法

- **`String sign(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行簽名。使用 `signWithAlg` 依配置的演算法計算。

- **`boolean checkSign(Map msg, Map params)`**
  驗證報文簽名。從報文或回應標頭中取出簽名值，使用 `checkSignWithAlg` 驗證。

##### 配置存取方法

- **`String getKeyConnector()`** -- 密鑰連接符，預設 `"&key="`
- **`boolean shouldSortMessage()`** -- 是否排序，預設 `true`
- **`boolean shouldSortWithKey()`** -- 排序是否含密鑰，預設 `false`
- **`boolean shouldRemoveEmpty()`** -- 是否移除空字段，預設 `false`
- **`boolean shouldRemoveNull()`** -- 是否移除 null 值，預設 `false`
- **`boolean shouldSignatureToUppercase()`** -- 簽名是否轉大寫，預設 `false`
- **`boolean shouldSignSourceToUppercase()`** -- 簽名原文是否轉大寫，預設 `false`
- **`boolean shouldSignSourceToLowercase()`** -- 簽名原文是否轉小寫，預設 `false`
- **`String getSignAlgorithm()`** -- 取得簽名演算法，支援按 stage 配置（`signAlgorithm_{stage}`）
- **`String getEncoding()`** -- 取得字符集

#### Protected 部分

##### 簽名計算

- **`String calcSignSource(Map msg, Map params, Map outputMap)`**
  計算簽名原文。負責模板轉換、字段過濾、排序、JSON 序列化等前置處理。

- **`String signWithAlg(String signSrc, String key)`** / **`String signWithAlg(String alg, String signSrc, String key)`**
  依指定演算法計算簽名。內部根據 `alg` 值建立對應的 `SignAlgorithm*` 實例。

  支援的演算法值：`"MD5"`、`"SHA1"`、`"SHA256"`、`"ED25519"`、`"RSA"`、`"HMAC"`、`"HMAC_RSA"`

- **`boolean checkSignWithAlg(String signSrc, String signature, String key, String verifyKey)`**
  依演算法驗證簽名。

##### 其他

- **`String mapToJson(Map map)`** -- Map 轉 JSON
- **`String getSignatureKeyField()`** -- 密鑰字段名
- **`String tryGetKey(String keyId)`** -- 嘗試取得密鑰
- **`static String getMaskedKey(String key)`** -- 遮蔽密鑰
