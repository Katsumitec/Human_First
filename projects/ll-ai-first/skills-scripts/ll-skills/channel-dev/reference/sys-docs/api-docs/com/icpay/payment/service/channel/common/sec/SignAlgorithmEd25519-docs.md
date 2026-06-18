# SignAlgorithmEd25519 -- Ed25519 簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmEd25519`

## 說明

基於 Ed25519 橢圓曲線的簽名演算法實現。使用 BouncyCastle（BC）作為安全提供者，以 PKCS8 格式的私鑰簽名、X509 格式的公鑰驗簽。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmBase`、`org.bouncycastle`（BouncyCastle 加密庫）

## API說明

### Class: SignAlgorithmEd25519

#### Public 部分

##### 建構式

- **`SignAlgorithmEd25519()`**
- **`SignAlgorithmEd25519(String channel, String key, String verifyKey)`**
- **`SignAlgorithmEd25519(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  使用 Ed25519 私鑰對待簽字串計算簽名。
  - 流程：解碼私鑰 -> PKCS8EncodedKeySpec 轉換 -> Ed25519 簽名 -> binaryEncode 輸出

  ```java
  SignAlgorithmEd25519 alg = new SignAlgorithmEd25519("CH001", privKeyHex, pubKeyHex);
  alg.binaryEncoding("HEX");
  String signature = alg.calcSignature("POST|/v2/payments|...");
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  使用 Ed25519 公鑰（verifyKey）驗證簽名。

#### Protected 部分

- **`String calcSignature(String signSrc, String key)`**
  以指定私鑰計算 Ed25519 簽名。

- **`boolean verifySignature(String signSrc, String signature, String key)`**
  以指定公鑰驗證 Ed25519 簽名。流程：解碼公鑰 -> X509EncodedKeySpec 轉換 -> 驗簽。
