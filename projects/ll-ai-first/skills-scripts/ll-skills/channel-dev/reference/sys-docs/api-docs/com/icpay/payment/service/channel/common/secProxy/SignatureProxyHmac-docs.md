# SignatureProxyHmac — HMAC 簽名代理

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxyHmac`

## 說明
基於 HMAC 演算法的簽名代理實作。在 `SignatureManager` 中以演算法名稱 `"HMAC"` 註冊。內部委派 `SignAlgorithmHmac` 執行實際的簽名與驗簽運算，並透過 `getHmacKey()` 取得 HMAC 專用密鑰。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `SignatureProxy` -> `ChnlSignatureServiceBase`
- **主要相依性**: `SignAlgorithmHmac`, `SignatureManager`

## API說明

### Class: SignatureProxyHmac

#### Public 部分

##### 初始化

###### `init()` [靜態]
向 `SignatureManager` 註冊演算法名稱 `"HMAC"` 與本類別的映射。類別載入時透過靜態區塊自動呼叫。

##### 簽名與驗簽

###### `signWithAlg(String alg, String signSrc, String key)`
使用 HMAC 演算法計算簽名。建立 `SignAlgorithmHmac` 實例，設定渠道資訊、密鑰、extConfig，並注入 hmacKey 後呼叫 `calcSignature`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `key` | `String` | 簽名密鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `String` | 簽名結果 |

**使用範例：**
```java
SignatureProxy proxy = SignatureManager.newProxy("HMAC");
proxy.setService(signService);
proxy.setHmacKey(hmacSecret);
proxy.setExtConfig(extConfig);
String signature = proxy.signWithAlg("HMAC", "data_to_sign", key);
```

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)`
使用 HMAC 演算法驗證簽名。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `signature` | `String` | 待驗證的簽名值 |
| `key` | `String` | 簽名密鑰 |
| `verifyKey` | `String` | 驗證密鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `boolean` | 驗簽是否通過 |

**使用範例：**
```java
boolean valid = proxy.checkSignWithAlg("HMAC", "data_to_sign", signature, key, verifyKey);
```
