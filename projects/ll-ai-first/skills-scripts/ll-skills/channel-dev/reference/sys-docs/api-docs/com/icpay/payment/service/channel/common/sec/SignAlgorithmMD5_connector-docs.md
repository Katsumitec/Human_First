# SignAlgorithmMD5_connector -- MD5 簽名演算法變體（密鑰前置無連接符）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmMD5_connector`

## 說明

`SignAlgorithmMD5` 的變體，將密鑰直接拼接在待簽字串**前方**，預設不使用連接符。簽名計算格式為 `keysignSrc`（密鑰與待簽字串直接串接）。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmMD5`
- **主要相依性**: `SignAlgorithmMD5`、`EncryptUtil`

## API說明

### Class: SignAlgorithmMD5_connector

#### Public 部分

##### 建構式

- **`SignAlgorithmMD5_connector()`**
- **`SignAlgorithmMD5_connector(String channel, String key, String verifyKey)`**
- **`SignAlgorithmMD5_connector(String channel, String key, String verifyKey, Map<String,Object> options)`**
- **`SignAlgorithmMD5_connector(String channel, String key, Object object, Map<String,Object> extConfig)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  覆寫父類方法。將密鑰直接拼接在待簽字串前方：`keysignSrc`，然後計算 MD5。

  ```java
  SignAlgorithmMD5_connector alg = new SignAlgorithmMD5_connector("CH001", "myKey", null);
  String sign = alg.calcSignature("amount=100");
  // 實際計算 MD5("myKeyamount=100")
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證簽名，不區分大小寫比對。

- **`String getKeyConnector()`**
  覆寫父類方法。預設回傳空字串 `""`，可透過 `keyConnector` 選項自訂。
