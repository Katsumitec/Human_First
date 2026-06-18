# SignAlgorithmSHA256 -- SHA-256 簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmSHA256`

## 說明

基於 SHA-256 訊息摘要的簽名演算法實現。將待簽字串附加密鑰後，使用 `java.security.MessageDigest` 計算 SHA-256 雜湊值。驗簽時以不區分大小寫方式比對。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmBase`

## API說明

### Class: SignAlgorithmSHA256

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` | 密鑰連接符配置鍵 |
| `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` | 簽名密鑰字段名配置鍵 |

##### 建構式

- **`SignAlgorithmSHA256()`**
- **`SignAlgorithmSHA256(String channel, String key, String verifyKey)`**
- **`SignAlgorithmSHA256(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  計算 SHA-256 簽名。若未設定 `signatureKeyField`，在待簽字串後附加 `{keyConnector}{key}`，然後計算 SHA-256 摘要。

  ```java
  SignAlgorithmSHA256 alg = new SignAlgorithmSHA256("CH001", "myKey", null);
  String sign = alg.calcSignature("amount=100&merchant=M001");
  // 計算 SHA-256("amount=100&merchant=M001&key=myKey")
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證 SHA-256 簽名，不區分大小寫比對。

##### 配置存取方法

- **`String getKeyConnector()`**
  取得密鑰連接符，預設為 `"&key="`。

- **`SignAlgorithmSHA256 keyConnector(String keyConnector)`**
  設定密鑰連接符（鏈式呼叫）。

#### Protected 部分

- **`String getSignatureKeyField()`**
  取得簽名密鑰字段名。若非空，密鑰已包含在簽名來源中，不再額外附加。
