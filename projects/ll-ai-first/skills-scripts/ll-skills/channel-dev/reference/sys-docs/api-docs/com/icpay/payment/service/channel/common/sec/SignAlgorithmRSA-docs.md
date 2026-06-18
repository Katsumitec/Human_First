# SignAlgorithmRSA -- RSA 非對稱簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmRSA`

## 說明

基於 RSA 非對稱加密的簽名演算法實現。使用私鑰簽名、公鑰驗簽。支援多種密鑰格式（BASE64、PEM、PFX）及多種簽名演算法（SHA256withRSA、SHA1withRSA、SHA512withRSA 等）。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **已知子類別**: `SignAlgorithmHmacRsa`
- **主要相依性**: `SignAlgorithmBase`、`RSAUtility`（`com.icpay.payment.common.utils.RSAUtility`）

## API說明

### Class: SignAlgorithmRSA

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `rsaPublicKeyFormat` | RSA 公鑰格式（BASE64/PEM/PFX_BASE64） | `"BASE64"` |
| `rsaPrivateKeyFormat` | RSA 私鑰格式（BASE64/PEM/PFX_BASE64） | `"BASE64"` |
| `rsaEncryptionAlgorithm` | 加解密演算法 | `"RSA"` |
| `rsaSignatureAlgorithm` | 簽名算法 | `"SHA256withRSA"` |

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `RSA_PUB_KEY_FORMAT` | `String` | `"rsaPublicKeyFormat"` | 公鑰格式配置鍵 |
| `RSA_PRI_KEY_FORMAT` | `String` | `"rsaPrivateKeyFormat"` | 私鑰格式配置鍵 |
| `ENCRYPTION_ALGORITHM` | `String` | `"rsaEncryptionAlgorithm"` | 加密演算法配置鍵 |
| `SIGNATURE_ALGORITHM` | `String` | `"rsaSignatureAlgorithm"` | 簽名演算法配置鍵 |

##### 建構式

- **`SignAlgorithmRSA()`**
- **`SignAlgorithmRSA(String channel, String key, String verifyKey)`**
- **`SignAlgorithmRSA(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  使用 RSA 私鑰對待簽字串計算簽名。
  - 流程：取得私鑰 -> 使用指定簽名演算法簽名 -> 以 binaryEncoding 編碼回傳

  ```java
  SignAlgorithmRSA alg = new SignAlgorithmRSA("CH001", privateKeyBase64, publicKeyBase64);
  String signature = alg.calcSignature("amount=100&merchant=M001");
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  使用 RSA 公鑰（verifyKey）驗證簽名。

#### Protected 部分

##### 密鑰處理

- **`RSAUtility rsaUtil()`**
  取得或初始化 RSAUtility 實例，設定加密與簽名演算法。

- **`PublicKey getPublicKey(String key)`**
  根據 `rsaPublicKeyFormat` 配置，從字串解析 RSA 公鑰。支援 BASE64、PEM、PFX_BASE64 格式。

- **`PrivateKey getPrivateKey(String key)`**
  根據 `rsaPrivateKeyFormat` 配置，從字串解析 RSA 私鑰。支援 BASE64、PEM、PFX_BASE64 格式。

##### 配置存取

- **`String getRsaPublicKeyFormat()`** -- 取得公鑰格式，預設 `"BASE64"`
- **`String getRsaPrivateKeyFormat()`** -- 取得私鑰格式，預設 `"BASE64"`
- **`String getEncryptionAlgorithm()`** -- 取得加密演算法，預設 `"RSA"`
- **`String getSignatureAlgorithm()`** -- 取得簽名演算法，預設 `"SHA256withRSA"`

##### 內部簽名/驗簽

- **`String calcSignature(String signSrc, String key)`**
  以指定密鑰計算 RSA 簽名。

- **`boolean verifySignature(String signSrc, String signature, String key)`**
  以指定公鑰驗證 RSA 簽名。
