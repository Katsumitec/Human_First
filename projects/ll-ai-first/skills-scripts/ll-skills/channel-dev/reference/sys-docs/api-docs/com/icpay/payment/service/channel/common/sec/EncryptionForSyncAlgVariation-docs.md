# EncryptionForSyncAlgVariation -- 對稱加解密服務變體

類別名稱：`com.icpay.payment.service.channel.common.sec.EncryptionForSyncAlgVariation`

## 說明

`EncryptionForSyncAlg` 的變體版本，新增以 `~` 分隔的鍵值對格式（而非 JSON）作為加解密資料的處理方式。提供 `decryptVariation` 方法用於解密後將 `key=value~key=value` 格式的字串轉為 Map，以及 `sortedMapToString` 方法將 Map 排序後以 `~` 分隔串接。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlEncryptionServiceBase`（`com.icpay.payment.common.utils.ChnlEncryptionServiceBase`）
- **主要相依性**: `ChnlEncryptionServiceBase`、`javax.crypto.Cipher`

## API說明

### Class: EncryptionForSyncAlgVariation

#### Public 部分

##### 常數

| 常數 | 類型 | 值 |
|------|------|----|
| `ENCRYPTION_TOUPPER` | `String` | `"encryptionUpper"` |
| `ENCRYPTION_ALG` | `String` | `"encryptionAlgorithm"` |
| `ENCRYPTION_KEY_SPEC` | `String` | `"encryptionKeySpec"` |
| `CHARSET` | `String` | `"charset"` |

##### 建構式

- **`EncryptionForSyncAlgVariation()`**

##### 加解密方法

- **`String encrypt(String data)`**
  加密字串資料。使用 Cipher 以配置的演算法、密鑰、IV 加密。

- **`String encrypt(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行加密。

- **`String decrypt(Map msg, Map params, Map outputMap)`**
  對報文中的加密字段進行解密。

- **`String decryptVariation(String strEncrypted, Map outputMap)`**
  變體解密方法。解密後使用 `stringToMap_decode` 將 `~` 分隔的鍵值對轉為 Map。

  ```java
  EncryptionForSyncAlgVariation enc = new EncryptionForSyncAlgVariation();
  Map<String, String> result = new HashMap<>();
  enc.decryptVariation(encryptedString, result);
  // 解密後 result 包含如 {amount=100, merchant=M001}
  ```

- **`String encryptData(String plainData)`** -- 未實現（回傳 null）
- **`String decryptData(String encryptedData)`** -- 未實現（回傳 null）

##### 工具方法

- **`String sortedMapToString(Map<String,Object> map)`**
  將 Map 按 key 排序後，以 `key=value~key=value` 格式串接。

  ```java
  Map<String, Object> data = new LinkedHashMap<>();
  data.put("amount", "100");
  data.put("merchant", "M001");
  String result = enc.sortedMapToString(data);
  // 回傳 "amount=100~merchant=M001"
  ```

- **`static void addToMap(Map<String,String> map, String key, String value)`**
  靜態工具方法，將鍵值對加入 Map。

- **`static Map<String,String> stringToMap_decode(String inputString)`**
  靜態工具方法，將 `~` 分隔的 `key=value` 字串解析為 Map。

##### 配置存取方法

- **`boolean shouldEncryptionToUppercase()`** -- 密文是否轉大寫，預設 `false`
- **`String getEncryptionAlgorithm()`** -- 加密演算法，預設 `"AES"`
- **`String getEncryptionKeySpec()`** -- 密鑰規格，預設 `"AES"`
- **`void setEncryptionIv(String iv)`** -- 設定加密 IV
- **`void setDecryptionIv(String iv)`** -- 設定解密 IV

#### Protected 部分

- **`String decrypt(String encryptedData)`** -- 實際解密函數
- **`String getEncryptionIv()`** / **`String getDecryptionIv()`** -- 取得加解密 IV
- **`byte[] getEncryptionIvBytes()`** / **`byte[] getDecryptionIvBytes()`** -- IV 解碼為 byte 陣列
- **`String mapToJson(Map map)`** -- Map 轉 JSON
- **`String tryGetNestedValue(Map msg, String fieldName)`** -- 嘗試從巢狀 Map 中取值
