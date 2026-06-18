# SignAlgorithmSHA256SHA3_Gosm -- SHA-256 + SHA3-256 雙重雜湊簽名演算法

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmSHA256SHA3_Gosm`

## 說明

結合 SHA-256 與 SHA3-256 的雙重雜湊簽名演算法。先對待簽字串計算 SHA-256，再將 SHA-256 結果與密鑰一起計算 SHA3-256，產生最終簽名。適用於國密相關的渠道對接場景。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmBase`、`java.security.MessageDigest`

## API說明

### Class: SignAlgorithmSHA256SHA3_Gosm

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` | 密鑰連接符配置鍵 |
| `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` | 簽名密鑰字段名配置鍵 |

##### 建構式

- **`SignAlgorithmSHA256SHA3_Gosm()`**
- **`SignAlgorithmSHA256SHA3_Gosm(String channel, String key, String verifyKey)`**
- **`SignAlgorithmSHA256SHA3_Gosm(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  計算雙重雜湊簽名。若未設定 `signatureKeyField`，在待簽字串後直接附加密鑰，然後呼叫 `calcSha256toSha3String` 計算。

  ```java
  SignAlgorithmSHA256SHA3_Gosm alg = new SignAlgorithmSHA256SHA3_Gosm("CH001", "myKey", null);
  String sign = alg.calcSignature("amount=100");
  // 流程：SHA-256(signSrc) -> SHA3-256(hash + key)
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證簽名，不區分大小寫比對。

- **`String calcSha256toSha3String(String val, String secKey)`**
  核心計算方法：先對 `val` 計算 SHA-256，再將 SHA-256 結果與 `secKey` 作為輸入計算 SHA3-256。
  - 拋出：`SignatureException`

##### 配置存取方法

- **`String getKeyConnector()`**
  取得密鑰連接符，預設為空字串 `""`。

- **`SignAlgorithmSHA256SHA3_Gosm keyConnector(String keyConnector)`**
  設定密鑰連接符（鏈式呼叫）。

#### Protected 部分

- **`String getSignatureKeyField()`**
  取得簽名密鑰字段名。若非空，密鑰已包含在簽名來源中，不再額外附加。
