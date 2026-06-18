# SignAlgorithmMD5_noKeyConnector -- MD5 簽名演算法（無密鑰連接符）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmMD5_noKeyConnector`

## 說明

MD5 簽名演算法實現，與 `SignAlgorithmMD5` 類似但在附加密鑰時**不使用連接符**。若未設定 `signatureKeyField`，則直接在待簽字串後方附加密鑰（無分隔符號），格式為 `signSrckey`。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmBase`、`EncryptUtil`

## API說明

### Class: SignAlgorithmMD5_noKeyConnector

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` | 密鑰連接符配置鍵 |
| `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` | 簽名密鑰字段名配置鍵 |

##### 建構式

- **`SignAlgorithmMD5_noKeyConnector()`**
- **`SignAlgorithmMD5_noKeyConnector(String channel, String key, String verifyKey)`**
- **`SignAlgorithmMD5_noKeyConnector(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  計算 MD5 簽名。若未設定 `signatureKeyField`，直接在待簽字串後附加密鑰（無連接符），然後計算 MD5。

  ```java
  SignAlgorithmMD5_noKeyConnector alg = new SignAlgorithmMD5_noKeyConnector("CH001", "myKey", null);
  String sign = alg.calcSignature("amount=100");
  // 實際計算 MD5("amount=100myKey")
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證簽名，不區分大小寫比對。

- **`String getKeyConnector()`**
  取得密鑰連接符，預設為 `"&key="`（但此類在 calcSignature 中不使用連接符）。

- **`SignAlgorithmMD5_noKeyConnector keyConnector(String keyConnector)`**
  設定密鑰連接符（鏈式呼叫）。

#### Protected 部分

- **`String getSignatureKeyField()`**
  取得簽名密鑰字段名。若此值非空，則不在待簽字串末尾附加密鑰。
