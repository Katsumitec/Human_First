# SignAlgorithmMD5 -- MD5 簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmMD5`

## 說明

基於 MD5 雜湊的簽名演算法實現。預設以 `&key=` 作為密鑰連接符，將待簽名字串附加密鑰後計算 MD5 雜湊值。驗簽時以相同方式計算簽名後進行不區分大小寫比對。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **已知子類別**: `SignAlgorithmMD5_2`、`SignAlgorithmMD5_connector`
- **主要相依性**: `SignAlgorithmBase`、`EncryptUtil`（MD5 計算）

## API說明

### Class: SignAlgorithmMD5

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` | 密鑰連接符配置鍵 |
| `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` | 簽名密鑰字段名配置鍵 |

##### 建構式

- **`SignAlgorithmMD5()`**
- **`SignAlgorithmMD5(String channel, String key, String verifyKey)`**
- **`SignAlgorithmMD5(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  計算 MD5 簽名。若未設定 `signatureKeyField`，則在待簽字串後附加 `{keyConnector}{key}` 再計算 MD5。
  - 預設連接格式：`signSrc&key=mySecretKey`

  ```java
  SignAlgorithmMD5 alg = new SignAlgorithmMD5("CH001", "mySecretKey", null);
  String sign = alg.calcSignature("amount=100&merchant=M001");
  // 實際計算 MD5("amount=100&merchant=M001&key=mySecretKey")
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證 MD5 簽名，不區分大小寫比對。

##### 配置存取方法

- **`String getKeyConnector()`**
  取得密鑰連接符，預設為 `"&key="`。

- **`SignAlgorithmMD5 keyConnector(String keyConnector)`**
  設定密鑰連接符（鏈式呼叫）。

  ```java
  SignAlgorithmMD5 alg = new SignAlgorithmMD5("CH001", "key123", null)
      .keyConnector("&secret=");
  ```

#### Protected 部分

- **`String getSignatureKeyField()`**
  取得簽名密鑰字段名。若此值非空，則不在待簽字串末尾附加密鑰（密鑰已作為字段包含在 Map 中）。
