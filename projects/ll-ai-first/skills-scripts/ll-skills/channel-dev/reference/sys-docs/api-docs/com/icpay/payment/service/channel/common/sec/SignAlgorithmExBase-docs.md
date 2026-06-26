# SignAlgorithmExBase -- 擴展簽名演算法抽象基類（支援 Map 輸入）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmExBase`

## 說明

在 `SignAlgorithmBase` 基礎上擴展，新增以 `Map` 作為簽名來源的抽象方法。適用於需要以結構化資料（而非已串接字串）進行簽名的場景，例如 JWT 簽名。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **已知子類別**: `SignAlgorithmJwt`
- **主要相依性**: `SignAlgorithmBase`、`EncryptUtil`、`Utils`

## API說明

### Class: SignAlgorithmExBase

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` | 密鑰連接符配置鍵 |

##### 建構式

- **`SignAlgorithmExBase()`**
  無參建構式。

- **`SignAlgorithmExBase(String channel, String key, String verifyKey)`**
  指定渠道、簽名密鑰、驗簽密鑰。

- **`SignAlgorithmExBase(String channel, String key, String verifyKey, Map<String,Object> options)`**
  指定渠道、簽名密鑰、驗簽密鑰及選項 Map。

##### 簽名與驗簽方法（抽象）

- **`String calcSignature(Map<String,?> signSrc)`** -- 抽象方法
  以 Map 為來源計算簽名。
  - `signSrc`：待簽名的 Map 資料
  - 回傳：簽名結果字串
  - 拋出：`SignatureException`

- **`boolean verifySignature(Map<String,?> signSrc, String signature)`** -- 抽象方法
  以 Map 為來源驗證簽名。
  - `signSrc`：待簽名的 Map 資料
  - `signature`：簽名值
  - 回傳：驗簽結果
  - 拋出：`SignatureException`

  ```java
  // 使用範例
  SignAlgorithmExBase alg = new SignAlgorithmJwt("CH001", myKey, myVerifyKey);
  Map<String, Object> payload = new HashMap<>();
  payload.put("merchant_id", "M001");
  payload.put("amount", "100");
  String token = alg.calcSignature(payload);
  boolean valid = alg.verifySignature(payload, token);
  ```
