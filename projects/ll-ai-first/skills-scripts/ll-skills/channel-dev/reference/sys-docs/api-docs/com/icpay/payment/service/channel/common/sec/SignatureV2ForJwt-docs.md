# SignatureV2ForJwt -- JWT 格式通用簽名服務（V2）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV2ForJwt`

## 說明

V2 版通用型簽名服務，專為 JWT（JSON Web Token）設計。將 Map 報文作為 JWT Payload，透過 `SignAlgorithmJwt` 產生 JWT Token。驗簽時從回應標頭或報文中取出 JWT 進行驗證。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlSignatureServiceBase`
- **主要相依性**: `ChnlSignatureServiceBase`、`SignAlgorithmJwt`、`SignAlgorithmExBase`

## API說明

### Class: SignatureV2ForJwt

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `sortMessageForSign` | 是否排序 | `"true"` |
| `sortWthKeyForSign` | 排序是否含密鑰 | `"false"` |
| `signatureKeyField` | 密鑰字段名 | `null` |
| `removeEmptyForSign` | 是否移除空字段 | `"false"` |
| `removeNullForSign` | 是否移除 null 值 | `"false"` |
| `signAlgorithm` | 簽名演算法 | `"MD5"` |
| `charset` | 字符集 | `"UTF-8"` |

##### 建構式

- **`SignatureV2ForJwt()`**

##### 簽名與驗簽方法

- **`String sign(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行 JWT 簽名。流程：
  1. 計算簽名來源（過濾、清理字段）
  2. 使用 `SignAlgorithmJwt` 產生 JWT Token
  3. 將 Token 放入 outputMap 的簽名字段

- **`boolean checkSign(Map msg, Map params)`**
  驗證 JWT 簽名。優先從回應標頭取得 JWT，其次從報文中取得。

##### 配置存取方法

- **`boolean shouldSortMessage()`** -- 是否排序，預設 `true`
- **`boolean shouldSortWithKey()`** -- 排序是否含密鑰，預設 `false`
- **`boolean shouldRemoveEmpty()`** -- 是否移除空字段，預設 `false`
- **`boolean shouldRemoveNull()`** -- 是否移除 null 值，預設 `false`
- **`String getSignAlgorithm()`** -- 取得簽名演算法，支援按 stage 配置
- **`String getEncoding()`** -- 取得字符集

#### Protected 部分

- **`void calcSignSource(Map msg, Map params, Map outputMap)`**
  計算簽名來源，將處理後的 Map 放入 outputMap（不回傳字串，因為 JWT 以 Map 為輸入）。

- **`String signWithAlg(Map signSrc, String key)`** / **`String signWithAlg(String alg, Map signSrc, String key)`**
  使用 `SignAlgorithmJwt` 計算 JWT 簽名。

- **`boolean checkSignWithAlg(Map<String,?> signSrc, String signature, String key, String verifyKey)`**
  使用 `SignAlgorithmJwt` 驗證 JWT 簽名。

- **`String getSignatureKeyField()`** -- 密鑰字段名
- **`String tryGetKey(String keyId)`** -- 嘗試取得密鑰
- **`String mapToJson(Map map)`** -- Map 轉 JSON
- **`static String getMaskedKey(String key)`** -- 遮蔽密鑰
