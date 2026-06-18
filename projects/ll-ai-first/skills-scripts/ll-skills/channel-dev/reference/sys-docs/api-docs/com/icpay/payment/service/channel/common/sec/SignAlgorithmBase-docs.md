# SignAlgorithmBase -- 簽名演算法抽象基類

類別名稱：`com.icpay.payment.service.channel.common.sec.SignAlgorithmBase`

## 說明

簽名演算法的抽象基類，提供簽名與驗簽的統一介面，以及二進制編碼/解碼、字元集管理、訊息摘要計算、商戶參數讀取等共用基礎能力。所有具體簽名演算法類別皆繼承此類。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlBaseTools`（`com.icpay.payment.common.utils.ChnlBaseTools`）
- **已知子類別**: `SignAlgorithmExBase`、`SignAlgorithmMD5`、`SignAlgorithmMD5_noKeyConnector`、`SignAlgorithmSHA1`、`SignAlgorithmSHA256`、`SignAlgorithmSHA256SHA3_Gosm`、`SignAlgorithmRSA`、`SignAlgorithmEd25519`、`SignAlgorithmEd25519withSHA256twice`、`SignAlgorithmHmac`
- **主要相依性**: `ChnlBaseTools`、`MerParams`、`Utils`、`org.apache.commons.codec`（Hex、Base64）

## API說明

### Class: SignAlgorithmBase

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `charset` | 字符編碼 | `"UTF-8"` |
| `binaryEncoding` | 二進制數據編碼格式（HEX/BASE64/RAW） | `"HEX"` |
| `binaryEncodingForSignature` | 簽名專用的二進制編碼格式 | 繼承 `binaryEncoding` |
| `keyEncoding` | 密鑰的編碼格式 | 繼承 `binaryEncoding` |
| `keyEncodingForSignature` | 簽名專用密鑰的編碼格式 | 繼承 `keyEncoding` |
| `signAlgorithmOption` | 簽名演算法選項 | `null` |

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CHARSET` | `String` | `"charset"` | 字符集配置鍵 |
| `BINARY_ENCODING` | `String` | `"binaryEncoding"` | 二進制編碼配置鍵 |
| `KEY_ENCODING` | `String` | `"keyEncoding"` | 密鑰編碼配置鍵 |
| `BINARY_ENCODING_SIGN` | `String` | `"binaryEncodingForSignature"` | 簽名專用二進制編碼配置鍵 |
| `KEY_ENCODING_SIGN` | `String` | `"keyEncodingForSignature"` | 簽名專用密鑰編碼配置鍵 |
| `SIGN_ALG_OPT` | `String` | `"signAlgorithmOption"` | 簽名演算法選項配置鍵 |

##### 建構式

- **`SignAlgorithmBase()`**
  無參建構式。

- **`SignAlgorithmBase(String channel, String key, String verifyKey)`**
  指定渠道、簽名密鑰、驗簽密鑰。

- **`SignAlgorithmBase(String channel, String key, String verifyKey, Map<String,Object> options)`**
  指定渠道、簽名密鑰、驗簽密鑰及選項 Map。

##### 簽名與驗簽方法（抽象）

- **`String calcSignature(String signSrc)`** -- 抽象方法
  計算簽名。
  - `signSrc`：待簽名字串
  - 回傳：簽名結果字串
  - 拋出：`SignatureException`

  ```java
  // 使用範例（由子類別實現後呼叫）
  SignAlgorithmBase alg = new SignAlgorithmMD5("CH001", myKey, null);
  String signature = alg.calcSignature("amount=100&merchant=M001");
  ```

- **`boolean verifySignature(String signSrc, String signature)`** -- 抽象方法
  驗證簽名。
  - `signSrc`：待簽名字串
  - `signature`：簽名值
  - 回傳：驗簽結果
  - 拋出：`SignatureException`

##### 鏈式設定方法

- **`SignAlgorithmBase key(String key)`**
  設定簽名密鑰（鏈式呼叫）。

- **`SignAlgorithmBase option(String key, String value)`**
  設定選項（鏈式呼叫）。

- **`SignAlgorithmBase charset(String charset)`**
  設定字符集（鏈式呼叫）。

- **`SignAlgorithmBase signAlgorithmOption(String algOpt)`**
  設定簽名演算法選項（鏈式呼叫）。

- **`SignAlgorithmBase binaryEncoding(String encoding)`**
  設定二進制編碼格式（鏈式呼叫）。

- **`void setBinaryEncodingForSignature(String encoding)`**
  設定簽名專用的二進制編碼格式。

##### 商戶參數讀取方法

- **`String getMerParam(String merId, String catalog, String paramId, boolean throwErrorIfNotExist)`**
  取得商戶參數，支援交易類型回退到萬用目錄 `"*"`。

- **`String getMerParam(String merId, String catalog, String paramId, String defaultValue)`**
  取得商戶參數，找不到時回傳預設值。

- **`String getMerParam(String merId, String[] catalogs, String paramId, String defaultValue)`**
  以多個目錄搜尋商戶參數。

- **`String getMerParam(String paramId, String defaultValue)`**
  以當前交易上下文（渠道、商戶、交易類型）取得參數。

- **`String getMerParam(String paramId, boolean throwErrorIfNotExist)`**
  以當前交易上下文取得參數，可選擇是否拋出例外。

- **`String getMerSecParam(String merId, String paramId, boolean throwErrorIfNotExist)`**
  取得商戶安全參數（目錄固定為 `"SEC"`）。

- **`String getMerSecParam(String merId, String paramId, String defaultValue)`**
  取得商戶安全參數，找不到時回傳預設值。

  ```java
  // 使用範例
  String apiKey = alg.getMerSecParam("M001", "apiKey", true);
  String timeout = alg.getMerParam("timeout", "30000");
  ```

#### Protected 部分

##### 密鑰存取

- **`String getKey()`** / **`void setKey(String key)`**
  取得/設定簽名密鑰。

- **`String getVerifyKey()`** / **`String setVerifyKey(String verifyKey)`**
  取得/設定驗簽密鑰。

- **`byte[] getKeyBytes()`**
  將簽名密鑰依 `keyEncodingForSignature` 解碼為 byte 陣列。

- **`byte[] getVerifyKeyBytes()`**
  將驗簽密鑰依 `keyEncodingForSignature` 解碼為 byte 陣列。

- **`String getKey(String keyId)`**
  從商戶安全參數中讀取指定 keyId 的密鑰，優先以 `{keyId}.{txnType}` 查找。

- **`String tryGetKey(String keyId)`**
  同 `getKey(String)`，但找不到時回傳 `null` 而非拋出例外。

##### 選項存取

- **`Object getOption(String key)`** / **`Object getOption(String key, Object defaultValue)`**
  取得選項值。

- **`String getOptionStr(String key)`** / **`String getOptionStr(String key, String defaultValue)`**
  取得選項值（轉換為字串）。

##### 編碼與解碼工具

- **`String getCharsetName()`** / **`Charset getCharset()`**
  取得目前設定的字符集。

- **`String getBinaryEncoding()`** / **`String getBinaryEncodingForSignature()`**
  取得二進制編碼格式。

- **`String geKeyEncoding()`** / **`String geKeyEncodingForSignature()`**
  取得密鑰編碼格式。

- **`byte[] binaryDecode(String data)`** / **`byte[] binaryDecode(String data, String encoding)`**
  將字串依指定編碼（HEX/BASE64/RAW）解碼為 byte 陣列。

- **`String binaryEncode(byte[] data)`** / **`String binaryEncode(byte[] data, String encoding)`**
  將 byte 陣列依指定編碼（HEX/BASE64/RAW）編碼為字串。

##### 訊息摘要

- **`String msgDigest(String data, String algorithm)`**
  計算字串的訊息摘要（如 MD5、SHA-256），回傳編碼後字串。

- **`byte[] msgDigest(byte[] data, String algorithm)`**
  計算 byte 陣列的訊息摘要，回傳原始 byte 陣列。

##### 其他工具

- **`String getMaskedKey(String key)`**
  遮蔽密鑰，僅保留前 4 碼與後 4 碼，中間以 `***` 取代（用於日誌輸出）。

- **`boolean isCatalogAsTxnType(String catalog)`**
  判斷目錄字串是否符合交易類型格式（數字開頭、3-7 位英數字）。

- **`String getSignAlgorithmOption()`** / **`String getSignAlgorithmOption(String defaultValue)`**
  取得簽名演算法選項配置值。
