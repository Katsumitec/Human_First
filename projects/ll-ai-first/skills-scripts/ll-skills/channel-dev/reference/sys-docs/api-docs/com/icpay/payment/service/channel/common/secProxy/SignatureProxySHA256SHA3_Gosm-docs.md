# SignatureProxySHA256SHA3_Gosm — SHA256/SHA3 國密簽名代理

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxySHA256SHA3_Gosm`

## 說明
基於 SHA-256 結合 SHA-3 國密標準的簽名代理實作。在 `SignatureManager` 中以演算法名稱 `"SHA256SHA3_Gosm"` 註冊。內部委派 `SignAlgorithmSHA256SHA3_Gosm` 執行實際的簽名與驗簽運算，適用於需要符合中國國家商用密碼標準的渠道。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `SignatureProxy` -> `ChnlSignatureServiceBase`
- **主要相依性**: `SignAlgorithmSHA256SHA3_Gosm`, `SignatureManager`

## API說明

### Class: SignatureProxySHA256SHA3_Gosm

#### Public 部分

##### 初始化

###### `init()` [靜態]
向 `SignatureManager` 註冊演算法名稱 `"SHA256SHA3_Gosm"` 與本類別的映射。類別載入時透過靜態區塊自動呼叫。

##### 簽名與驗簽

###### `signWithAlg(String alg, String signSrc, String key)`
使用 SHA256/SHA3 國密演算法計算簽名。建立 `SignAlgorithmSHA256SHA3_Gosm` 實例，傳入渠道資訊、密鑰與 extConfig，呼叫 `calcSignature`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `key` | `String` | 簽名密鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `String` | 國密簽名結果 |

**使用範例：**
```java
SignatureProxy proxy = SignatureManager.newProxy("SHA256SHA3_Gosm");
proxy.setService(signService);
proxy.setExtConfig(extConfig);
String signature = proxy.signWithAlg("SHA256SHA3_Gosm", "data_to_sign", secretKey);
```

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)`
使用 SHA256/SHA3 國密演算法驗證簽名。

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
boolean valid = proxy.checkSignWithAlg("SHA256SHA3_Gosm", "data_to_sign", signature, secretKey, verifyKey);
```
