# SignatureProxyEd2259 — Ed25519 簽名代理

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxyEd2259`

## 說明
基於 Ed25519 橢圓曲線演算法的簽名代理實作。在 `SignatureManager` 中以演算法名稱 `"ED2259"` 註冊。內部委派 `SignAlgorithmEd25519` 執行實際的簽名與驗簽運算。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `SignatureProxy` -> `ChnlSignatureServiceBase`
- **主要相依性**: `SignAlgorithmEd25519`, `SignatureManager`

## API說明

### Class: SignatureProxyEd2259

#### Public 部分

##### 初始化

###### `init()` [靜態]
向 `SignatureManager` 註冊演算法名稱 `"ED2259"` 與本類別的映射。類別載入時透過靜態區塊自動呼叫。

##### 簽名與驗簽

###### `signWithAlg(String alg, String signSrc, String key)`
使用 Ed25519 演算法計算簽名。建立 `SignAlgorithmEd25519` 實例，傳入渠道資訊、私鑰與 extConfig，呼叫 `calcSignature` 產生簽名。

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
SignatureProxy proxy = SignatureManager.newProxy("ED2259");
proxy.setService(signService);
proxy.setExtConfig(extConfig);
String signature = proxy.signWithAlg("ED2259", "data_to_sign", privateKey);
```

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)`
使用 Ed25519 演算法驗證簽名。建立 `SignAlgorithmEd25519` 實例，傳入私鑰與驗證公鑰，呼叫 `verifySignature` 進行驗簽。

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

**使用範例：**
```java
boolean valid = proxy.checkSignWithAlg("ED2259", "data_to_sign", signature, privateKey, publicKey);
```
