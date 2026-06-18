# SignatureProxyEd2259withSHA256Twice — Ed25519 結合雙重 SHA256 簽名代理（已棄用）

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxyEd2259withSHA256Twice`

## 說明
基於 Ed25519 結合雙重 SHA256 雜湊的簽名代理實作。在 `SignatureManager` 中以演算法名稱 `"ED2259withSHA256Twice"` 註冊。內部委派 `SignAlgorithmEd25519withSHA256twice` 執行實際的簽名與驗簽運算。

**此類別已標註 `@Deprecated`**，已移至 `icpay-service-chnl-onl-CoBoPay` 專案。靜態區塊中的 `init()` 呼叫已被註解，不會在 `SignatureManager` 初始化時自動註冊。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `SignatureProxy` -> `ChnlSignatureServiceBase`
- **主要相依性**: `SignAlgorithmEd25519withSHA256twice`, `SignatureManager`

## API說明

### Class: SignatureProxyEd2259withSHA256Twice

#### Public 部分

##### 初始化

###### `init()` [靜態]
向 `SignatureManager` 註冊演算法名稱 `"ED2259withSHA256Twice"` 與本類別的映射。注意：靜態區塊中未呼叫此方法，需手動呼叫才會註冊。

##### 簽名與驗簽

###### `signWithAlg(String alg, String signSrc, String key)`
使用 Ed25519 + 雙重 SHA256 演算法計算簽名。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `key` | `String` | Ed25519 私鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `String` | 簽名結果 |

**使用範例：**
```java
SignatureProxyEd2259withSHA256Twice.init(); // 手動註冊
SignatureProxy proxy = SignatureManager.newProxy("ED2259withSHA256Twice");
proxy.setService(signService);
String signature = proxy.signWithAlg("ED2259withSHA256Twice", "data", privateKey);
```

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)`
使用 Ed25519 + 雙重 SHA256 演算法驗證簽名。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `signature` | `String` | 待驗證的簽名值 |
| `key` | `String` | Ed25519 私鑰 |
| `verifyKey` | `String` | Ed25519 公鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `boolean` | 驗簽是否通過 |
