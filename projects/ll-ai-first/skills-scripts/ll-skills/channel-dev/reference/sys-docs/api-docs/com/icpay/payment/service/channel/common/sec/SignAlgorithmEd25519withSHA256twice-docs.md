# SignAlgorithmEd25519withSHA256twice -- Ed25519 + 雙重 SHA-256 簽名演算法（已棄用）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmEd25519withSHA256twice`

## 說明

**已標記 `@Deprecated`**，已移至 `icpay-service-chnl-onl-CoBoPay` 專案。

結合雙重 SHA-256 雜湊與 Ed25519 簽名的演算法。先對待簽字串計算兩次 SHA-256，再以 Ed25519 私鑰對雜湊結果進行簽名。簽名輸出固定使用 HEX 編碼。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignAlgorithmBase`
- **主要相依性**: `SignAlgorithmBase`、`org.bouncycastle`（Ed25519PrivateKeyParameters、Ed25519PublicKeyParameters）

## API說明

### Class: SignAlgorithmEd25519withSHA256twice

#### Public 部分

##### 建構式

- **`SignAlgorithmEd25519withSHA256twice()`**
- **`SignAlgorithmEd25519withSHA256twice(String channel, String key, String verifyKey)`**
- **`SignAlgorithmEd25519withSHA256twice(String channel, String key, String verifyKey, Map<String,Object> options)`**

##### 簽名與驗簽方法

- **`String calcSignature(String signSrc)`**
  計算簽名。流程：
  1. 對待簽字串計算 SHA-256
  2. 對步驟 1 結果再次計算 SHA-256
  3. 以 Ed25519 私鑰對雙重雜湊結果簽名
  4. 以 HEX 編碼回傳

  ```java
  SignAlgorithmEd25519withSHA256twice alg = new SignAlgorithmEd25519withSHA256twice();
  String sign = alg.calcSignature("POST|/v2/payments|timestamp||{...}", privKeyHex);
  ```

- **`boolean verifySignature(String signSrc, String signature)`**
  使用 verifyKey 驗證簽名。

##### 測試方法

- **`static void main(String[] args)`**
  內建測試方法，示範簽名與驗簽流程。

#### Protected 部分

- **`String calcSignature(String signSrc, String key)`**
  以指定私鑰計算簽名。私鑰以 32 位元組原始格式解碼，透過 BouncyCastle 的 `Ed25519PrivateKeyParameters` 轉換為 PKCS8 格式後簽名。

- **`boolean verifySignature(String signSrc, String signatureHex, String pubKey)`**
  以指定公鑰驗證簽名。公鑰以 32 位元組原始格式解碼，透過 BouncyCastle 的 `Ed25519PublicKeyParameters` 轉換為 X509 格式後驗簽。
