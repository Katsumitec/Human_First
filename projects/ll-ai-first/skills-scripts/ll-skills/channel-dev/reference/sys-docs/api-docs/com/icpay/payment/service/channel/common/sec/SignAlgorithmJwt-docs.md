# SignAlgorithmJwt -- JWT 簽名演算法實現

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmJwt`

## 說明

基於 JWT（JSON Web Token）的簽名演算法實現。使用 `io.jsonwebtoken`（JJWT）函式庫產生與驗證 JWT。支援 HS256、RS256、RS512、ES256 等多種 JWT 簽名演算法。簽名以 Map 作為 Payload 輸入，不支援字串直接簽名。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmExBase` -> `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmExBase`、`io.jsonwebtoken`（Jwts、SignatureAlgorithm）

## API說明

### Class: SignAlgorithmJwt

#### Public 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` | 密鑰連接符配置鍵 |

##### 建構式

- **`SignAlgorithmJwt()`**
- **`SignAlgorithmJwt(String channel, String key, String verifyKey)`**
- **`SignAlgorithmJwt(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名方法

- **`String calcSignature(Map<String,?> signSrc)`**
  以 Map 為 Payload 計算 JWT 簽名。回傳值帶有 `"Bearer "` 前綴。

  ```java
  SignAlgorithmJwt alg = new SignAlgorithmJwt("CH001", hmacKeyHex, hmacKeyHex)
      .signAlgorithmOption("HS256");
  Map<String, Object> payload = new HashMap<>();
  payload.put("merchant_id", "M001");
  payload.put("amount", 100);
  String jwtToken = alg.calcSignature(payload);
  // 回傳 "Bearer eyJhbGciOiJIUzI1Ni..."
  ```

- **`String calcSignature(String signSrc)`**
  **不支援**。呼叫時直接拋出 `SignatureException`。

##### 驗簽方法

- **`boolean verifySignature(Map<String,?> signSrc, String signature)`**
  驗證 JWT 簽名。自動處理 `"Bearer "` 前綴。驗證成功時，JWT Body 會被存入 `jwtBody` 變數。

- **`boolean verifySignature(String signSrc, String signature)`**
  驗證 JWT 簽名（字串版本），內部委派給 Map 版本。

##### 配置存取方法

- **`String getKeyConnector()`**
  取得密鑰連接符，預設為 `"&key="`。

- **`SignAlgorithmJwt keyConnector(String keyConnector)`**
  設定密鑰連接符（鏈式呼叫）。

#### Protected 部分

##### JWT 簽名核心方法

- **`String jwtSign(String alg, Map<String,?> payload, Key key)`**
  使用指定演算法與密鑰產生 JWT。將 Payload 存入 `jwtBody` 變數。

- **`String jwtSign(String alg, Map<String,?> payload, byte[] keyBytes)`**
  以 byte 陣列密鑰產生 JWT。內部將 keyBytes 包裝為 `SecretKeySpec`。

##### JWT 驗簽核心方法

- **`boolean verifyJwtSignature(String jwt, Key key)`**
  驗證 JWT 簽名。驗證成功時將 Claims 存入 `jwtBody` 變數。

- **`boolean verifyJwtSignature(String alg, String jwt, byte[] keyBytes)`**
  以指定演算法與 byte 陣列密鑰驗證 JWT。

##### 內部方法

- **`String doCalcSignature(Map<String,?> signSrc)`**
  實際簽名邏輯，讀取 `signAlgorithmOption` 配置（預設 `"HS256"`），呼叫 `jwtSign`。

- **`boolean doVerifySignature(Map<String,?> signSrc, String signature)`**
  實際驗簽邏輯，自動移除 `"Bearer "` 前綴後驗證。
