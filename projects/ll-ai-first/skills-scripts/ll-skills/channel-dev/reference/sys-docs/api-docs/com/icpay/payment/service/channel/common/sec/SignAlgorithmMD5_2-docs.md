# SignAlgorithmMD5_2 -- MD5 簽名演算法變體（密鑰前置）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmMD5_2`

## 說明

`SignAlgorithmMD5` 的變體，將密鑰放在待簽字串**前方**（而非後方），以 `&` 作為固定連接符。簽名計算順序為 `key&signSrc`，而非 `signSrc&key=key`。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmMD5`
- **主要相依性**: `SignAlgorithmMD5`、`EncryptUtil`

## API說明

### Class: SignAlgorithmMD5_2

#### Public 部分

##### 建構式

- **`SignAlgorithmMD5_2()`**
- **`SignAlgorithmMD5_2(String channel, String key, String verifyKey)`**
- **`SignAlgorithmMD5_2(String channel, String key, String verifyKey, Map<String,Object> options)`**
- **`SignAlgorithmMD5_2(String channel, String key, Object object, Map<String,Object> extConfig)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  覆寫父類方法。將密鑰放在前方：`key&signSrc`，然後計算 MD5。

  ```java
  SignAlgorithmMD5_2 alg = new SignAlgorithmMD5_2("CH001", "myKey", null);
  String sign = alg.calcSignature("amount=100");
  // 實際計算 MD5("myKey&amount=100")
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證簽名，不區分大小寫比對。

- **`String getKeyConnector()`**
  覆寫父類方法，固定回傳 `"&"`。
