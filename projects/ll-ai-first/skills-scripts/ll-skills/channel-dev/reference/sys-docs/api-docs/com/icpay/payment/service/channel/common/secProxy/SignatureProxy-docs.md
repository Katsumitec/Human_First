# SignatureProxy — 簽名代理抽象基類

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureProxy`

## 說明
簽名代理的抽象基類，定義了簽名與驗簽的統一介面。所有具體簽名演算法的代理類別均繼承此類，透過 `signWithAlg` 和 `checkSignWithAlg` 方法委派給對應的簽名演算法實作。同時持有 `ChnlSignatureServiceBase` 服務實例與擴展配置（extConfig），供子類別在簽名/驗簽時使用。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `ChnlSignatureServiceBase`
- **已知子類別**: `SignatureProxyMD5`, `SignatureProxySHA1`, `SignatureProxySHA256`, `SignatureProxySHA256SHA3_Gosm`, `SignatureProxyHmac`, `SignatureProxyHmacRsa`, `SignatureProxyRsa`, `SignatureProxyEd2259`, `SignatureProxyEd2259withSHA256Twice`, `SignatureProxyMD5_Key_Front`, `SignatureProxyMD5_Key_Front_connector`, `SignatureProxyMD5_noConnector`
- **主要相依性**: `com.icpay.payment.common.utils.ChnlSignatureServiceBase`

## API說明

### Class: SignatureProxy

#### Public 部分

##### 常數（繼承自 Protected，對子類別可見）

| 修飾 | 常數名稱 | 型別 | 值 | 說明 |
|------|----------|------|-----|------|
| `protected static final` | `CONNECTOR_KEY` | `String` | `"keyConnector"` | extConfig 中密鑰連接符的配置鍵 |
| `protected static final` | `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` | extConfig 中簽名密鑰欄位的配置鍵 |

##### 服務實例管理

###### `setService(ChnlSignatureServiceBase svc)`
設定關聯的簽名服務實例。

| 參數 | 型別 | 說明 |
|------|------|------|
| `svc` | `ChnlSignatureServiceBase` | 簽名服務實例 |

**使用範例：**
```java
SignatureProxy proxy = SignatureManager.newProxy("MD5");
proxy.setService(myChnlSignatureService);
```

###### `getService()`
取得關聯的簽名服務實例。

| 回傳型別 | 說明 |
|----------|------|
| `ChnlSignatureServiceBase` | 已設定的簽名服務實例，未設定時為 `null` |

##### 擴展配置管理

###### `getExtConfig()`
取得擴展配置 Map，若尚未初始化則自動建立空 Map。

| 回傳型別 | 說明 |
|----------|------|
| `Map<String, Object>` | 擴展配置 |

###### `setExtConfig(Map config)`
設定擴展配置，內部會複製一份新的 `HashMap<String, Object>`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `config` | `Map` | 擴展配置（raw type） |

##### HMAC 密鑰管理

###### `getHmacKey()`
取得 HMAC 密鑰。

| 回傳型別 | 說明 |
|----------|------|
| `String` | HMAC 密鑰 |

###### `setHmacKey(String hmacKey)`
設定 HMAC 密鑰。

| 參數 | 型別 | 說明 |
|------|------|------|
| `hmacKey` | `String` | HMAC 密鑰 |

##### 密鑰連接符

###### `getKeyConnector()`
取得簽名原始字串與密鑰之間的連接符號，預設值為 `"&key="`。實際值從 extConfig 中以 `CONNECTOR_KEY` 鍵讀取。

| 回傳型別 | 說明 |
|----------|------|
| `String` | 密鑰連接符（預設 `"&key="`） |

**使用範例：**
```java
// 預設情況下，簽名原串 + "&key=" + 密鑰
String connector = proxy.getKeyConnector(); // "&key="
```

##### 簽名與驗簽（抽象方法）

###### `signWithAlg(String alg, String signSrc, String key)` [抽象]
使用指定演算法對簽名原串進行簽名。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `key` | `String` | 簽名密鑰 |

| 回傳型別 | 說明 |
|----------|------|
| `String` | 簽名結果 |

| 例外 | 說明 |
|------|------|
| `SignatureException` | 簽名過程發生錯誤 |

###### `checkSignWithAlg(String alg, String signSrc, String signature, String key, String verifyKey)` [抽象]
使用指定演算法驗證簽名。

| 參數 | 型別 | 說明 |
|------|------|------|
| `alg` | `String` | 演算法名稱 |
| `signSrc` | `String` | 待簽名字串 |
| `signature` | `String` | 待驗證的簽名值 |
| `key` | `String` | 簽名密鑰 |
| `verifyKey` | `String` | 驗證密鑰（非對稱演算法時為公鑰） |

| 回傳型別 | 說明 |
|----------|------|
| `boolean` | 驗簽是否通過 |

| 例外 | 說明 |
|------|------|
| `SignatureException` | 驗簽過程發生錯誤 |

##### 覆寫的簽名服務方法

###### `sign(Map var1, Map var2, Map var3)`
覆寫自 `ChnlSignatureServiceBase`，目前回傳 `null`（未實作）。

###### `checkSign(Map var1, Map var2)`
覆寫自 `ChnlSignatureServiceBase`，目前回傳 `false`（未實作）。
