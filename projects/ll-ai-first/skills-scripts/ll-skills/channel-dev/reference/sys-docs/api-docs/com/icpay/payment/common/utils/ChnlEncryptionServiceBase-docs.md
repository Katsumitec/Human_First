# ChnlEncryptionServiceBase -- 渠道加密服務抽象基類

類別名稱：`com.icpay.payment.common.utils.ChnlEncryptionServiceBase`

## 說明

渠道加密服務的抽象基類，為所有渠道加解密服務提供共用基礎設施。主要功能包括：

1. **字符集管理** -- 透過 extConfig 配置加解密使用的字符集（預設 UTF-8）
2. **二進制編碼/解碼** -- 支援 HEX、BASE64、RAW 三種二進制編碼格式，可分別針對簽名用途與加密用途設定不同的編碼方式
3. **密鑰管理** -- 從 MerParams（`para_cat` 為 `SEC`）取得加密密鑰與解密密鑰，支援按交易類型區分
4. **加解密欄位名稱管理** -- 管理加密目標欄位、解密來源欄位、解密目標欄位的名稱
5. **extConfig 配置存取** -- 支援靜態配置與 `@` 前綴動態轉向 MerParams 取值
6. **加密模板管理** -- 設定與取得加密用的 FreeMarker 模板名稱

使用到的加密參數（`para_cat` 為 `SEC`）：
- `enc.key.<交易類>` / `enc.key` -- 加密密鑰
- `dec.key.<交易類>` / `dec.key` -- 解密密鑰

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **繼承**: `ChnlBaseTools`（`com.icpay.payment.common.utils.ChnlBaseTools`）
- **實作介面**: `OnlTxnChnlEncryptionService`（`com.icpay.payment.service.OnlTxnChnlEncryptionService`）
- **主要相依性**: `ChnlBaseTools`、`TxnInteractiveStage`、`org.apache.commons.codec.binary.Hex`、`org.apache.commons.codec.binary.Base64`

### 繼承體系

```
ChnlBaseTools
└── ChnlEncryptionServiceBase (implements OnlTxnChnlEncryptionService)
    └── EncryptionForSyncAlg 等具體實作...
```

## API說明

### Class: ChnlEncryptionServiceBase

#### Public 部分

##### 建構式

- **`ChnlEncryptionServiceBase()`** -- 預設建構式

##### 交互階段設定方法

- **`ChnlEncryptionServiceBase stage(TxnInteractiveStage stage)`**
  設定服務的交互階段（列舉型別），回傳 `this` 以支援鏈式呼叫。

- **`ChnlEncryptionServiceBase stage(String stage)`**
  設定服務的交互階段（字串型別），回傳 `this` 以支援鏈式呼叫。

  ```java
  ChnlEncryptionServiceBase encService = ...;
  encService.stage(TxnInteractiveStage.TXN_REQUEST);
  // 或使用字串
  encService.stage("TxnRequest");
  ```

##### 加密模板管理

- **`void setEncryptionTemplateName(String signTemplateName)`** -- 設定加密模板名稱
- **`String getEncryptionTemplateName()`** -- 取得加密模板名稱

##### extConfig 配置管理

- **`Map<String, Object> getExtConfig()`** -- 取得完整 extConfig Map，若為 null 則自動初始化為空 Map
- **`void setExtConfig(Map config)`** -- 以 Map 設定整份 extConfig（會複製為 `Map<String, Object>`）
- **`void setExtConfig(String key, Object value)`** -- 設定單筆 extConfig 配置項

##### 加解密欄位名稱管理

- **`void setEncryptionFieldName(String encFieldName)`** -- 設定加密欄位名稱
- **`String getEncryptionFieldName()`** -- 取得加密欄位名稱，若未設定則從 MerParams 的 `crypto.field.name.enc` 取得
- **`void setDecryptionSrcFieldName(String decFieldName)`** -- 設定解密來源欄位名稱
- **`String getDecryptionSrcFieldName()`** -- 取得解密來源欄位名稱，若未設定則從 MerParams 的 `crypto.field.name.dec.src` 取得
- **`void setDecryptionFieldName(String decFieldName)`** -- 設定解密目標欄位名稱
- **`String getDecryptionFieldName()`** -- 取得解密目標欄位名稱，若未設定則從 MerParams 的 `crypto.field.name.dec` 取得

##### 密鑰設定

- **`void setEncryptionKey(String key)`** -- 直接設定加密密鑰
- **`void setDecryptionKey(String key)`** -- 直接設定解密密鑰

##### 字符集設定

- **`void setCharset(String charset)`** -- 設定字符集（寫入 extConfig 的 `charset` 配置項）

##### 二進制編碼設定

- **`void setBinaryEncoding(String encoding)`** -- 設定通用二進制編碼格式（`HEX`/`BASE64`/`RAW`）
- **`void setBinaryEncodingForSignature(String encoding)`** -- 設定簽名專用二進制編碼格式
- **`void setBinaryEncodingForEncryption(String encoding)`** -- 設定加密專用二進制編碼格式

##### 解密方法

- **`String decrypt(String msgBody, Map params, Map outputMap)`**
  將字串報文轉為 Map 後委派給 `decrypt(Map, Map, Map)`（由子類實作）。

#### Protected 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `CHARSET` | `String` | `"charset"` | extConfig 中字符集的配置鍵 |
| `BINARY_ENCODING` | `String` | `"binaryEncoding"` | 通用二進制編碼格式配置鍵（HEX/BASE64/RAW） |
| `KEY_ENCODING` | `String` | `"keyEncoding"` | 通用密鑰編碼格式配置鍵 |
| `BINARY_ENCODING_SIGN` | `String` | `"binaryEncodingForSignature"` | 簽名用二進制編碼配置鍵 |
| `KEY_ENCODING_SIGN` | `String` | `"keyEncodingForSignature"` | 簽名用密鑰編碼配置鍵 |
| `BINARY_ENCODING_ENC` | `String` | `"binaryEncodingForEncryption"` | 加密用二進制編碼配置鍵 |
| `KEY_ENCODING_ENC` | `String` | `"keyEncodingForEncryption"` | 加密用密鑰編碼配置鍵 |

##### extConfig 配置項總覽

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `charset` | 加解密字符集 | `"UTF-8"` |
| `binaryEncoding` | 通用二進制編碼格式 | `"HEX"` |
| `keyEncoding` | 通用密鑰編碼格式 | 回退到 `binaryEncoding` |
| `binaryEncodingForSignature` | 簽名專用二進制編碼 | 回退到 `binaryEncoding` |
| `keyEncodingForSignature` | 簽名專用密鑰編碼 | 回退到 `keyEncoding` |
| `binaryEncodingForEncryption` | 加密專用二進制編碼 | 回退到 `binaryEncoding` |
| `keyEncodingForEncryption` | 加密專用密鑰編碼 | 回退到 `keyEncoding` |

##### extConfig 取值方法

- **`String extConfig(String key)`**
  取得 extConfig 配置值。若值以 `@` 開頭，則將 `@` 後的部分作為 key 從 MerParams 中查詢（先查當前交易類型，再查通用 `*`）。

- **`String extConfig(String key, String defaultValue)`**
  取得 extConfig 配置值，若為 null 則回傳預設值。

  ```freemarker
  <#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
  <#-- 此方法為 protected，無法直接在模板中呼叫，但子類可透過公開方法暴露 -->
  ```

##### 字符集取得方法

- **`String getCharsetName()`** -- 取得字符集名稱，預設 `"UTF-8"`
- **`Charset getCharset()`** -- 取得 `Charset` 物件

##### 二進制編碼取得方法

- **`String getBinaryEncoding()`** -- 取得通用二進制編碼格式，預設 `"HEX"`
- **`String getBinaryEncodingForSignature()`** -- 取得簽名專用二進制編碼，回退到 `getBinaryEncoding()`
- **`String getBinaryEncodingForEncryption()`** -- 取得加密專用二進制編碼，回退到 `getBinaryEncoding()`

##### 密鑰編碼取得方法

- **`String geKeyEncoding()`** -- 取得通用密鑰編碼格式，回退到 `getBinaryEncoding()`
- **`String geKeyEncodingForSignature()`** -- 取得簽名用密鑰編碼，回退到 `geKeyEncoding()`
- **`String geKeyEncodingForEncryption()`** -- 取得加密用密鑰編碼，回退到 `geKeyEncoding()`

##### 二進制編解碼方法

- **`byte[] binaryDecode(String data)`**
  使用簽名用二進制編碼格式解碼字串為 byte 陣列。

- **`byte[] binaryDecode(String data, String encoding)`**
  依指定編碼格式解碼字串為 byte 陣列。支援 `RAW`（直接依字符集轉換）、`HEX`、`BASE64` 三種格式。

- **`String binaryEncode(byte[] data)`**
  使用簽名用二進制編碼格式將 byte 陣列編碼為字串。

- **`String binaryEncode(byte[] data, String encoding)`**
  依指定編碼格式將 byte 陣列編碼為字串。支援 `RAW`、`HEX`、`BASE64` 三種格式。

  ```java
  // 使用 HEX 編碼
  byte[] data = "Hello".getBytes(StandardCharsets.UTF_8);
  String hex = binaryEncode(data, "HEX");    // "48656c6c6f"
  byte[] decoded = binaryDecode(hex, "HEX"); // 還原為原始 bytes

  // 使用 BASE64 編碼
  String b64 = binaryEncode(data, "BASE64"); // "SGVsbG8="
  ```

##### 密鑰專用編解碼方法

- **`byte[] binaryKeyDecode(String keyData, String encoding)`** -- 密鑰解碼，委派給 `binaryDecode`
- **`String binaryKeyEncode(byte[] keyData, String encoding)`** -- 密鑰編碼，委派給 `binaryEncode`

##### 密鑰取得方法

- **`String getEncryptionKey()`**
  取得加密密鑰。優先使用直接設定的值，否則從 MerParams（`para_cat` 為 `SEC`）查詢 `enc.key.<交易類型>`，若無則查詢 `enc.key`。

- **`String getDecryptionKey()`**
  取得解密密鑰。查詢邏輯同上，key 為 `dec.key.<交易類型>` / `dec.key`。

- **`byte[] getEncryptionKeyBytes()`** -- 取得加密密鑰的 byte 陣列（依加密用密鑰編碼解碼）
- **`byte[] getDecryptionKeyBytes()`** -- 取得解密密鑰的 byte 陣列（依加密用密鑰編碼解碼）

##### 通用密鑰與參數查詢方法

- **`String getKey(String fieldValue, String keyId)`**
  取得密鑰：若 fieldValue 非空則直接回傳，否則依 keyId 查詢 MerParams。

- **`String getKey(String keyId)`**
  從 MerParams（`para_cat` 為 `SEC`）查詢密鑰，先查 `{keyId}.{交易類型}`，再查 `{keyId}`。

- **`String getParam(String fieldValue, String paramId)`**
  取得參數：若 fieldValue 非空則直接回傳，否則從 MerParams 查詢。

##### 密鑰遮蔽方法

- **`String getMaskedKey(String key)`**
  將密鑰遮蔽為安全格式，僅保留前 4 碼與後 4 碼，中間以 `***` 取代。若密鑰長度不足 4 則原樣回傳。用於日誌輸出時保護敏感資訊。

  ```java
  getMaskedKey("abcdefghijklmnop"); // "abcd***mnop"
  getMaskedKey("ab");               // "ab" (長度不足，原樣回傳)
  ```
