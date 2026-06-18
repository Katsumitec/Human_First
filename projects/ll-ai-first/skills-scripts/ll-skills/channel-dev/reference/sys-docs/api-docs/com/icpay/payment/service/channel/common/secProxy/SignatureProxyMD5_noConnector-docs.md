# SignatureProxyMD5_noConnector — MD5 簽名代理（無密鑰連接符）

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxyMD5_noConnector`

## 說明
MD5 雜湊演算法的變體簽名代理，簽名時不使用密鑰連接符。在 `SignatureManager` 中以演算法名稱 `"MD5_NoConnector"` 註冊。內部委派 `SignAlgorithmMD5_noKeyConnector` 執行實際的簽名與驗簽運算，與標準 `SignatureProxyMD5` 的差異在於簽名時密鑰直接附加到簽名原串後方，不插入連接符（如 `&key=`）。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `SignatureProxy` -> `ChnlSignatureServiceBase`
- **主要相依性**: `SignAlgorithmMD5_noKeyConnector`, `SignatureManager`, `ChnlBaseTools`

## API說明

### Class: SignatureProxyMD5_noConnector

#### Public 部分

##### 初始化

###### `init()` [靜態]
向 `SignatureManager` 註冊演算法名稱 `"MD5_NoConnector"` 與本類別的映射。類別載入時透過靜態區塊自動呼叫。

##### 簽名與驗簽

###### `signWithAlg(String alg, String signSrc, String key)`
使用 MD5（無連接符）演算法計算簽名。建立 `SignAlgorithmMD5_noKeyConnector` 實例，傳入渠道資訊、密鑰與服務實例的 extConfig，呼叫 `calcSignature`。

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
SignatureProxy proxy = SignatureManager.newProxy("MD5_NoConnector");
proxy.setService(signService);
// 簽名原串直接與密鑰拼接，無 "&key=" 連接符
String signature = proxy.signWithAlg("MD5_NoConnector", "amount=100&orderId=123", secretKey);
```

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)`
使用 MD5（無連接符）演算法驗證簽名。驗簽時仍會使用 `keyConnector` 設定。

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
