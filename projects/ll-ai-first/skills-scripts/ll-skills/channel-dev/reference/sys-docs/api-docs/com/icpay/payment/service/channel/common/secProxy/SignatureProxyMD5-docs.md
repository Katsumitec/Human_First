# SignatureProxyMD5 — MD5 簽名代理

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxyMD5`

## 說明
基於 MD5 雜湊演算法的簽名代理實作。在 `SignatureManager` 中以演算法名稱 `"MD5"` 註冊。內部委派 `SignAlgorithmMD5` 執行實際的簽名與驗簽運算。簽名時使用服務實例的 extConfig，驗簽時使用自身的 extConfig 並附加 keyConnector。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `SignatureProxy` -> `ChnlSignatureServiceBase`
- **主要相依性**: `SignAlgorithmMD5`, `SignatureManager`, `ChnlBaseTools`

## API說明

### Class: SignatureProxyMD5

#### Public 部分

##### 初始化

###### `init()` [靜態]
向 `SignatureManager` 註冊演算法名稱 `"MD5"` 與本類別的映射。類別載入時透過靜態區塊自動呼叫。

##### 簽名與驗簽

###### `signWithAlg(String alg, String signSrc, String key)`
使用 MD5 演算法計算簽名。建立 `SignAlgorithmMD5` 實例，傳入渠道資訊、密鑰與服務實例的 extConfig，呼叫 `calcSignature`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `key` | `String` | 簽名密鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `String` | MD5 簽名結果 |

**使用範例：**
```java
SignatureProxy proxy = SignatureManager.newProxy("MD5");
proxy.setService(signService);
String signature = proxy.signWithAlg("MD5", "amount=100&orderId=123", secretKey);
```

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)`
使用 MD5 演算法驗證簽名。驗簽時會附加 `keyConnector` 將密鑰接到簽名原串後方。

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
boolean valid = proxy.checkSignWithAlg("MD5", "amount=100&orderId=123", receivedSign, secretKey, null);
```
