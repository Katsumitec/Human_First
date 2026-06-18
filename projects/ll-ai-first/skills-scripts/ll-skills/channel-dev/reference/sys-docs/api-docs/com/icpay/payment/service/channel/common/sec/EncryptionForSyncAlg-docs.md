# EncryptionForSyncAlg -- 對稱加解密服務

類別名稱：`com.icpay.payment.service.channel.common.sec.EncryptionForSyncAlg`

## 說明

通用型對稱加解密服務，支援 AES 等對稱加密演算法。可對 Map 報文進行加密（轉 JSON 後加密）與解密（解密後嘗試轉回 Map）。加解密使用 IV（初始化向量）模式，密鑰與 IV 透過 MerParams 配置管理。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlEncryptionServiceBase`（`com.icpay.payment.common.utils.ChnlEncryptionServiceBase`）
- **主要相依性**: `ChnlEncryptionServiceBase`、`javax.crypto.Cipher`、`javax.crypto.spec.SecretKeySpec`、`javax.crypto.spec.IvParameterSpec`

## API說明

### Class: EncryptionForSyncAlg

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `encryptionUpper` | 密文是否轉大寫 | `"false"` |
| `encryptionAlgorithm` | 加密演算法（如 `"AES/CBC/PKCS5Padding"`） | `"AES"` |
| `encryptionKeySpec` | 密鑰規格 | `"AES"` |
| `charset` | 字符集 | 繼承父類 |

##### 常數

| 常數 | 類型 | 值 |
|------|------|----|
| `ENCRYPTION_TOUPPER` | `String` | `"encryptionUpper"` |
| `ENCRYPTION_ALG` | `String` | `"encryptionAlgorithm"` |
| `ENCRYPTION_KEY_SPEC` | `String` | `"encryptionKeySpec"` |
| `CHARSET` | `String` | `"charset"` |

##### 建構式

- **`EncryptionForSyncAlg()`**

##### 加解密方法

- **`String encrypt(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行加密。若有加密模板則用模板轉換，否則轉 JSON。加密結果放入 outputMap 的加密字段。

  ```java
  EncryptionForSyncAlg enc = new EncryptionForSyncAlg();
  Map<String, Object> outputMap = new HashMap<>();
  String encrypted = enc.encrypt(msgMap, paramsMap, outputMap);
  ```

- **`String decrypt(Map msg, Map params, Map outputMap)`**
  對報文中的加密字段進行解密。解密結果嘗試轉為 Map 後合併到 outputMap，若無法轉換則以字串存入。

- **`String encryptData(String plainData)`**
  直接加密字串。

- **`String decryptData(String encryptedData)`**
  直接解密字串。

##### 配置存取方法

- **`boolean shouldEncryptionToUppercase()`** -- 密文是否轉大寫，預設 `false`
- **`String getEncryptionAlgorithm()`** -- 加密演算法，支援按 stage 配置，預設 `"AES"`
- **`String getEncryptionKeySpec()`** -- 密鑰規格，支援按 stage 配置，預設 `"AES"`
- **`void setEncryptionIv(String iv)`** -- 設定加密 IV
- **`void setDecryptionIv(String iv)`** -- 設定解密 IV

#### Protected 部分

##### 核心加解密

- **`String encrypt(String data)`**
  實際加密函數。使用 `Cipher` 以配置的演算法、密鑰、IV 加密資料。

- **`String decrypt(String encryptedData)`**
  實際解密函數。使用 `Cipher` 以配置的演算法、密鑰、IV 解密資料。

##### IV 管理

- **`String getEncryptionIv()`** -- 從 MerParams 取得加密 IV（key: `enc.iv`）
- **`String getDecryptionIv()`** -- 從 MerParams 取得解密 IV（key: `dec.iv`）
- **`byte[] getEncryptionIvBytes()`** -- 加密 IV 解碼為 byte 陣列
- **`byte[] getDecryptionIvBytes()`** -- 解密 IV 解碼為 byte 陣列

##### 其他

- **`String mapToJson(Map map)`** -- Map 轉 JSON
- **`String tryGetNestedValue(Map msg, String fieldName)`** -- 嘗試從巢狀 Map 中取值
