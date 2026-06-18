# SignatureManager — 簽名代理管理器

類別名稱：`com.icpay.payment.service.channel.common.secProxy.SignatureManager`

## 說明
簽名代理的註冊中心與工廠類別。負責在系統啟動時初始化所有簽名代理子類別，將演算法名稱與對應的代理類別名稱建立映射關係，並透過 `newProxy` 工廠方法根據演算法名稱動態建立對應的 `SignatureProxy` 實例。

繼承自 `ChnlBaseTools`，本身為抽象類別，不可直接實例化，僅提供靜態方法使用。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.secProxy`
- **繼承**: `ChnlBaseTools`
- **主要相依性**: `ChnlBaseTools`, `ChnlBizException`, `RspCd`, `ClsUtils`, `Log`, `SignatureV2ForJson`, `Reflections`

## API說明

### Class: SignatureManager

#### Public 部分

##### 註冊與建立代理

###### `register(String algName, String signatureProxyName)` [靜態]
將演算法名稱與對應的簽名代理類別完整名稱註冊到快取中。通常由各 `SignatureProxy` 子類別的 `init()` 方法呼叫。

| 參數 | 型別 | 說明 |
|------|------|------|
| `algName` | `String` | 演算法識別名稱（如 `"MD5"`, `"SHA256"`, `"RSA"` 等） |
| `signatureProxyName` | `String` | 簽名代理類別的完整類別名稱 |

**使用範例：**
```java
// 在 SignatureProxyMD5.init() 中
SignatureManager.register("MD5", SignatureProxyMD5.class.getName());
```

###### `newProxy(String algName)` [靜態]
根據演算法名稱建立對應的 `SignatureProxy` 實例。若演算法未註冊則拋出例外。

| 參數 | 型別 | 說明 |
|------|------|------|
| `algName` | `String` | 已註冊的演算法識別名稱 |

| 回傳型別 | 說明 |
|----------|------|
| `SignatureProxy` | 新建的簽名代理實例 |

| 例外 | 說明 |
|------|------|
| `ChnlBizException` | 演算法未支持（錯誤碼 `Z_7012`）或代理類別載入失敗 |

**使用範例：**
```java
SignatureProxy proxy = SignatureManager.newProxy("SHA256");
proxy.setService(mySignatureService);
proxy.setExtConfig(extConfigMap);
String signature = proxy.signWithAlg("SHA256", signSrc, key);
```

##### 初始化

###### `init()` [靜態, 同步]
初始化所有內建簽名代理。採用同步機制確保只初始化一次。初始化時依序呼叫以下代理類別的 `init()` 方法：
- `SignatureProxySHA256SHA3_Gosm`
- `SignatureProxyMD5`
- `SignatureProxySHA1`
- `SignatureProxySHA256`
- `SignatureProxyHmac`
- `SignatureProxyHmacRsa`
- `SignatureProxyEd2259`
- `SignatureProxyRsa`
- `SignatureProxyMD5_Key_Front`
- `SignatureProxyMD5_Key_Front_connector`
- `SignatureProxyMD5_noConnector`

###### `init0()` [靜態]
備用初始化方法，透過 `Reflections` 函式庫自動掃描 `secProxy` package 下所有 `SignatureProxy` 子類別並呼叫其 `init()` 方法。目前未在主初始化流程中使用。

#### Protected 部分

##### 屬性

| 修飾 | 屬性名稱 | 型別 | 說明 |
|------|----------|------|------|
| `protected static` | `cache` | `Map<String, String>` | 演算法名稱 -> 代理類別名稱的映射快取 |
| `protected static` | `inited` | `Boolean` | 是否已完成初始化 |

##### 類別載入

###### `classLoader()` [靜態]
取得當前類別的 ClassLoader，供 `loadSignatureProxy` 動態載入代理類別時使用。

| 回傳型別 | 說明 |
|----------|------|
| `ClassLoader` | `SignatureManager` 的 ClassLoader |
