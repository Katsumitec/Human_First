# SignAlgorithmHmac -- HMAC 簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmHmac`

## 說明

基於 HMAC（Hash-based Message Authentication Code）的簽名演算法實現。支援多種 HMAC 變體（HmacSHA1、HmacSHA256 等），透過配置項 `algForHmac` 切換。密鑰可透過 `hmacKey()` 方法或繼承自基類的 `key` 設定。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmBase`、`javax.crypto.Mac`、`javax.crypto.spec.SecretKeySpec`

## API說明

### Class: SignAlgorithmHmac

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `HMAC_ALG` | `String` | `"algForHmac"` | HMAC 演算法名稱配置鍵 |

##### 建構式

- **`SignAlgorithmHmac()`**
- **`SignAlgorithmHmac(String channel, String key, String verifyKey)`**
- **`SignAlgorithmHmac(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  使用 HMAC 計算簽名。以 `getHmacKeyBytes()` 取得密鑰，以 `getAlgForHmac()` 取得演算法名稱。

  ```java
  SignAlgorithmHmac alg = new SignAlgorithmHmac("CH001", null, null)
      .hmacKey("myHmacSecret")
      .algForHmac("HmacSHA256")
      .binaryEncoding("BASE64");
  String signature = alg.calcSignature("amount=100&merchant=M001");
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證 HMAC 簽名，不區分大小寫比對。

##### 鏈式設定方法

- **`SignAlgorithmHmac hmacKey(String hmacKey)`**
  設定 HMAC 專用密鑰（鏈式呼叫）。若未設定，則使用基類的 `key`。

- **`SignAlgorithmHmac algForHmac(String algForHmac)`**
  設定 HMAC 演算法名稱（鏈式呼叫）。

##### 配置存取方法

- **`String getAlgForHmac()`**
  取得 HMAC 演算法名稱，預設為 `"HmacSHA1"`。

#### Protected 部分

- **`String getHmacKey()`**
  取得 HMAC 專用密鑰。

- **`String getKey()`**
  覆寫基類方法，優先回傳 hmacKey，若為空則回傳基類的 key。

- **`byte[] getHmacKeyBytes()`**
  將 HMAC 密鑰依 keyEncodingForSignature 解碼為 byte 陣列。

- **`String generateHmacSignature(byte[] keyBytes, String message, String algorithm)`**
  核心 HMAC 簽名方法。使用 `javax.crypto.Mac` 進行簽名，結果以 binaryEncode 編碼。
