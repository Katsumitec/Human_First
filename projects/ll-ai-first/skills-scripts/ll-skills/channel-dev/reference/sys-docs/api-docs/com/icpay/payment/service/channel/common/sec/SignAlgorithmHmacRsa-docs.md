# SignAlgorithmHmacRsa -- HMAC + RSA 複合簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmHmacRsa`

## 說明

結合 HMAC 與 RSA 的複合簽名演算法。簽名時先以 HMAC 計算摘要，再以 RSA 私鑰加密摘要值。驗簽時先以 RSA 公鑰解密簽名，再與 HMAC 計算結果比對。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmRSA`
- **主要相依性**: `SignAlgorithmRSA`、`javax.crypto.Mac`、`RSAUtility`

## API說明

### Class: SignAlgorithmHmacRsa

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `HMAC_ALG` | `String` | `"algForHmac"` | HMAC 演算法名稱配置鍵 |

##### 建構式

- **`SignAlgorithmHmacRsa()`**
- **`SignAlgorithmHmacRsa(String channel, String key, String verifyKey)`**
- **`SignAlgorithmHmacRsa(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  計算 HMAC + RSA 複合簽名。流程：
  1. 以 hmacKey 和指定 HMAC 演算法計算摘要
  2. 以 RSA 私鑰（key）加密摘要
  3. 以 BASE64 編碼回傳

  ```java
  SignAlgorithmHmacRsa alg = new SignAlgorithmHmacRsa("CH001", rsaPrivKey, rsaPubKey)
      .hmacKey("myHmacSecret")
      .algForHmac("HmacSHA256");
  String signature = alg.calcSignature("amount=100");
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證簽名。流程：
  1. 以 hmacKey 計算 HMAC 摘要
  2. 以 RSA 公鑰（verifyKey）解密簽名
  3. 比對兩者是否相等

##### 鏈式設定方法

- **`SignAlgorithmHmacRsa hmacKey(String hmacKey)`**
  設定 HMAC 密鑰（鏈式呼叫）。

- **`SignAlgorithmHmacRsa algForHmac(String algForHmac)`**
  設定 HMAC 演算法（鏈式呼叫）。

##### 配置存取方法

- **`String getAlgForHmac()`**
  取得 HMAC 演算法名稱，預設為 `"HmacSHA1"`。

#### Protected 部分

- **`String getHmacKey()`** -- 取得 HMAC 密鑰。
- **`byte[] getHmacKeyBytes()`** -- 將 HMAC 密鑰解碼為 byte 陣列。
- **`String generateHmacSignature(byte[] keyBytes, String message, String algorithm)`** -- 核心 HMAC 簽名方法。
