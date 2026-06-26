# EncryptUtil

類別名稱：`com.icpay.payment.common.utils.EncryptUtil`

## 說明

加密與編碼工具集，提供常見的雜湊、對稱加密、URL 編碼、字串遮蔽、Map 排序與連接等功能。廣泛用於支付系統中的簽名產生、資料加解密、請求參數排序與拼接等場景。

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **Maven Artifact**: `com.ppay:icpay-common-utils`
- **繼承**: 無（獨立工具類別）
- **相依性**:
  - `javax.crypto.Cipher` / `SecretKey` / `SecretKeySpec`
  - `java.security.MessageDigest`
  - `org.bouncycastle.jce.provider.BouncyCastleProvider`（BouncyCastle 加密庫）
  - `org.apache.commons.lang.ArrayUtils`
  - `com.icpay.payment.common.utils.Utils`
  - `com.icpay.payment.common.utils.StringUtil`
  - `com.icpay.payment.common.utils.EncodeUtils`
  - `com.icpay.payment.common.utils.SecureRandomUtil`
  - `com.icpay.payment.common.exception.BizzException`

## API 說明

### Class: EncryptUtil

#### Public 部分

##### 方法 — 雜湊（Hash）

###### `md5`

| 簽名 | 說明 |
|------|------|
| `md5(String str)` | 計算字串的 MD5 雜湊（UTF-8 編碼），回傳 hex 字串 |
| `md5(String str, String encoding)` | 指定編碼計算 MD5 |
| `md5(byte[] data)` | 計算 byte 陣列的 MD5，回傳 byte[] |

```java
// 基本用法：計算交易資料的 MD5 雜湊
String hash = EncryptUtil.md5("hello");
// 回傳: "5d41402abc4b2a76b9719d911017c592"

// 指定編碼（如渠道要求 GBK 編碼）
String hashGbk = EncryptUtil.md5("交易金額=100", "GBK");

// byte 陣列版本：對二進位報文計算 MD5
byte[] messageBody = "orderId=20260308001&amount=1000".getBytes("UTF-8");
byte[] md5Bytes = EncryptUtil.md5(messageBody);
```

###### `sha1`

```java
public static String sha1(byte[] raw)
```

計算 SHA-1 雜湊，回傳 hex 字串。

```java
// 計算支付通知內容的 SHA-1 摘要
String notifyBody = "transId=TXN20260308&status=SUCCESS&amount=5000";
String sha1Hash = EncryptUtil.sha1(notifyBody.getBytes("UTF-8"));
// 回傳 40 位 hex 字串，可用於驗證通知完整性
```

###### `sha256`

```java
public static String sha256(byte[] raw)
```

計算 SHA-256 雜湊，回傳 hex 字串。

```java
// 組裝簽名原文後計算 SHA-256 摘要
String signData = "appId=APP001&orderId=ORD20260308&amount=10000&key=SECRET_KEY";
String hash = EncryptUtil.sha256(signData.getBytes("UTF-8"));
// 回傳 64 位 hex 字串，常作為渠道簽名的摘要值
```

###### `isMd5String`

```java
public static boolean isMd5String(String str)
```

判斷字串是否為 MD5 雜湊格式（32 位小寫 hex）。

```java
// 判斷密碼是否已經過 MD5 加密
String password = "5d41402abc4b2a76b9719d911017c592";
if (EncryptUtil.isMd5String(password)) {
    // 已加密，直接使用
} else {
    // 明文，需先加密
    password = EncryptUtil.md5(password);
}
```

###### `isBase64String`

```java
public static boolean isBase64String(String str)
```

判斷字串是否為 Base64 格式。

```java
// 判斷渠道回傳的資料是否為 Base64 編碼
String responseData = "SGVsbG8gV29ybGQ=";
if (EncryptUtil.isBase64String(responseData)) {
    // 進行 Base64 解碼後再處理
    byte[] decoded = EncodeUtils.base64Decode(responseData);
}
```

---

##### 方法 — 密碼加密

###### `encryptPassword`

```java
public static String encryptPassword(String password, String loginName)
```

加密密碼：`md5(md5(password) + loginName)`。

###### `encryptPasswordWithSeed`

```java
public static String encryptPasswordWithSeed(String password, String loginName, String seed)
```

帶隨機種子加密密碼：`md5(encryptPassword(password, loginName) + seed)`。

###### `encryptLoginPasswordWithSeed`

```java
public static String encryptLoginPasswordWithSeed(String securePassword, String seed)
```

登入密碼加密：`md5(securePassword + seed)`。

```java
// 場景：商戶後台用戶註冊時加密密碼
String loginName = "merchant_admin";
String rawPassword = "P@ssw0rd123";
String encryptedPwd = EncryptUtil.encryptPassword(rawPassword, loginName);
// 存入資料庫: md5(md5("P@ssw0rd123") + "merchant_admin")

// 場景：帶隨機種子的密碼加密（更高安全性）
String seed = String.valueOf(System.currentTimeMillis());
String seededPwd = EncryptUtil.encryptPasswordWithSeed(rawPassword, loginName, seed);

// 場景：用戶登入驗證（前端已做過一次 encryptPassword）
String frontendEncrypted = "a1b2c3d4e5f6..."; // 前端傳來的已加密密碼
String loginSeed = "1709856000000";
String loginPwd = EncryptUtil.encryptLoginPasswordWithSeed(frontendEncrypted, loginSeed);
```

---

##### 方法 — 對稱加密（DES / 3DES）

###### `TripleDESEncrypt` / `TripleDESDecrypt`

```java
public static byte[] TripleDESEncrypt(byte[] key, byte[] data) throws NoSuchAlgorithmException, GeneralSecurityException
public static byte[] TripleDESDecrypt(byte[] key, byte[] data) throws NoSuchAlgorithmException, GeneralSecurityException
```

3DES（DESede/ECB/NoPadding）加解密。使用 BouncyCastle Provider，內部使用 synchronized 確保執行緒安全。

```java
// 場景：對敏感卡號資料進行 3DES 加密傳輸
byte[] key = new byte[24]; // 24 bytes 的 3DES 金鑰
System.arraycopy(masterKeyBytes, 0, key, 0, 24);

// 注意：NoPadding 模式要求資料長度為 8 的倍數
byte[] plainData = "62258801".getBytes("UTF-8"); // 8 bytes 卡號片段
byte[] encrypted = EncryptUtil.TripleDESEncrypt(key, plainData);

// 接收端解密
byte[] decrypted = EncryptUtil.TripleDESDecrypt(key, encrypted);
String cardSegment = new String(decrypted, "UTF-8"); // "62258801"
```

###### `DESEncrypt` / `DESDecrypt`

```java
public static byte[] DESEncrypt(byte[] key, byte[] data) throws NoSuchAlgorithmException, GeneralSecurityException
public static byte[] DESDecrypt(byte[] key, byte[] data) throws NoSuchAlgorithmException, GeneralSecurityException
```

DES（DES/ECB/NoPadding）加解密。使用 BouncyCastle Provider，執行緒安全。

```java
// 場景：DES 加密 PIN Block（常見於 ISO8583 報文）
byte[] desKey = new byte[8]; // 8 bytes 的 DES 金鑰
byte[] pinBlock = new byte[]{0x06, 0x12, 0x34, 0x56, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF};

byte[] encryptedPin = EncryptUtil.DESEncrypt(desKey, pinBlock);
byte[] decryptedPin = EncryptUtil.DESDecrypt(desKey, encryptedPin);
```

---

##### 方法 — 位元運算

###### `xor`

```java
public static byte[] xor(byte[] a, byte[] b) throws GeneralSecurityException
```

兩個等長 byte 陣列的 XOR 運算。若長度不等丟出 `GeneralSecurityException`。

###### `not`

```java
public static byte[] not(byte[] ba)
```

byte 陣列的 NOT（位元取反）運算。

###### `bytesEquals`

```java
public static boolean bytesEquals(byte[] a, byte[] b)
```

判斷兩個 byte 陣列是否相等（null-safe）。

###### `xorHash16To8Bytes`

```java
public static byte[] xorHash16To8Bytes(byte[] byteToConvert16)
```

以 XOR 演算法將 16 bytes 雜湊為 8 bytes（前 8 bytes XOR 後 8 bytes）。

```java
// 場景：ISO8583 MAC 計算中的 XOR 運算
byte[] blockA = new byte[]{0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
byte[] blockB = new byte[]{0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70, (byte)0x80};
byte[] xorResult = EncryptUtil.xor(blockA, blockB);
// xorResult: {0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88}

// NOT 運算
byte[] inverted = EncryptUtil.not(blockA);

// 比較兩個 MAC 值是否一致
byte[] calculatedMac = calculateMac(data);
byte[] receivedMac = parseFromMessage(msg);
if (EncryptUtil.bytesEquals(calculatedMac, receivedMac)) {
    // MAC 驗證通過
}

// 將 16 bytes MD5 壓縮為 8 bytes 作為 DES 金鑰
byte[] md5Result = EncryptUtil.md5("secret_key".getBytes("UTF-8")); // 16 bytes
byte[] desKey = EncryptUtil.xorHash16To8Bytes(md5Result); // 8 bytes
```

---

##### 方法 — 填充與位元組操作

###### `padding`

```java
public static byte[] padding(byte[] data, int blockLength, byte byteToPad)
```

密碼學區塊填充。在資料末端標記 `0x80`，剩餘空間以 `byteToPad` 填充。

```java
// 場景：對不足 8 bytes 倍數的報文進行 ISO/IEC 9797-1 填充（用於 MAC 計算）
byte[] macData = "AMOUNT=1000&CURRENCY=CNY".getBytes("UTF-8"); // 24 bytes
byte[] padded = EncryptUtil.padding(macData, 8, (byte) 0x00);
// padded 長度為 32 bytes：原始 24 bytes + 0x80 + 7 bytes 的 0x00
```

###### `fillBytes`

| 簽名 | 說明 |
|------|------|
| `fillBytes(int val, int len)` | 產生指定長度及內容的 byte 陣列 |
| `fillBytes(byte[] data, int val)` | 填充指定值到現有 byte 陣列 |

```java
// 產生 8 bytes 全零陣列（常用作初始向量）
byte[] zeroBlock = EncryptUtil.fillBytes(0x00, 8);

// 將現有陣列全部填充為 0xFF
byte[] buffer = new byte[16];
EncryptUtil.fillBytes(buffer, 0xFF);
```

###### `getRandomInt` / `getRandomLong` / `getRandomBytes`

```java
public static int getRandomInt(int min, int max)     // min <= x <= max
public static long getRandomLong(long min, long max)  // min <= x <= max
public static byte[] getRandomBytes(int len)
```

委託 `SecureRandomUtil` 產生安全隨機數。

```java
// 產生 6 位數隨機驗證碼
int verifyCode = EncryptUtil.getRandomInt(100000, 999999);

// 產生隨機交易流水號
long traceNo = EncryptUtil.getRandomLong(100000000000L, 999999999999L);

// 產生 16 bytes 隨機數作為 AES 初始向量
byte[] iv = EncryptUtil.getRandomBytes(16);
```

---

##### 方法 — URL 編碼

###### `urlencode`

```java
public static String urlencode(String str, String encoding, String spaceReplacement)
```

URL 編碼。支援自訂空格替換字元（如 `%20` 以符合 RFC3986）。

```java
// 場景：組裝支付回調 URL 的查詢參數
String merchantName = "測試商戶 A";
String encoded = EncryptUtil.urlencode(merchantName, "UTF-8", "%20");
// 回傳: "%E6%B8%AC%E8%A9%A6%E5%95%86%E6%88%B6%20A"

// 使用預設空格處理（+號）
String encoded2 = EncryptUtil.urlencode("hello world", "UTF-8", null);
// 回傳: "hello+world"
```

###### `urldecode`

```java
public static String urldecode(String str, String encoding)
```

URL 解碼。

```java
// 場景：解碼渠道回傳的 URL 編碼通知內容
String encodedNotify = "%E4%BA%A4%E6%98%93%E6%88%90%E5%8A%9F";
String decoded = EncryptUtil.urldecode(encodedNotify, "UTF-8");
// 回傳: "交易成功"
```

---

##### 方法 — 字串格式化

###### `escapeForRegex`

```java
public static String escapeForRegex(String input)
```

轉義正則表達式特殊字元。

```java
// 場景：在日誌中搜尋含有特殊字元的商戶 ID
String merchantId = "MER.001(test)";
String escaped = EncryptUtil.escapeForRegex(merchantId);
// 回傳: "MER\\.001\\(test\\)"，可安全用於正則比對
```

###### `formatDouble`

```java
public static String formatDouble(double d)
```

格式化浮點數為字串（格式：`#.##`）。

```java
// 場景：格式化交易金額（元）
double amount = 100.50;
String formatted = EncryptUtil.formatDouble(amount);
// 回傳: "100.5"

String formatted2 = EncryptUtil.formatDouble(99.0);
// 回傳: "99"
```

###### `formatMessage`

```java
public static String formatMessage(String msg, Object... args)
```

使用 `MessageFormat.format` 格式化訊息。

```java
// 場景：組裝錯誤訊息或日誌內容
String errorMsg = EncryptUtil.formatMessage(
    "交易 {0} 失敗，渠道回傳碼: {1}，金額: {2}",
    "TXN20260308001", "E001", "1000.00"
);
// 回傳: "交易 TXN20260308001 失敗，渠道回傳碼: E001，金額: 1000.00"
```

###### `toFixLenStr`

```java
public static String toFixLenStr(String str, int length, char padChar)
```

取固定長度字串，不足時以 padChar 右填充，null 時全填充。

```java
// 場景：組裝定長報文欄位（如 ISO8583 報文中的固定長度域）
String amount = EncryptUtil.toFixLenStr("1000", 12, '0');
// 回傳: "100000000000"

// null 值全填充
String empty = EncryptUtil.toFixLenStr(null, 8, ' ');
// 回傳: "        "（8 個空格）
```

###### `listEnumAsQuotedString`

```java
public static <T> String listEnumAsQuotedString(Class<T> clazz)
```

將 enum 所有值以逗號分隔的引號字串列出。

```java
// 場景：產生 SQL IN 條件或錯誤訊息中列出有效值
// 假設有 enum TxnStatus { SUCCESS, FAILED, PENDING }
String validValues = EncryptUtil.listEnumAsQuotedString(TxnStatus.class);
// 回傳: "\"SUCCESS\",\"FAILED\",\"PENDING\""
```

###### `join`

```java
public static String join(int[] array, String separator)
```

將整數陣列以指定分隔符連接為字串。

```java
// 場景：記錄批次交易的序號列表
int[] batchIds = {1001, 1002, 1003, 1004};
String idList = EncryptUtil.join(batchIds, ",");
// 回傳: "1001,1002,1003,1004"
```

---

##### 方法 — 遮蔽（Mask）

###### `maskCardNumber`

```java
public static String maskCardNumber(String cardNumber)
```

遮蔽卡號，保留前 4 位和後 4 位，中間最多 4 個 `*`。

###### `maskPhoneNumber`

```java
public static String maskPhoneNumber(String phoneNumber)
```

遮蔽手機號，保留前 3 位和後 4 位，中間最多 3 個 `*`。

###### `addMask`

```java
public static String addMask(String str, int lenBeforeMask, int lenAfterMask, int maxMaskLength)
```

通用遮蔽方法。

```java
// 場景：日誌輸出或前端顯示中遮蔽敏感資訊
String card = EncryptUtil.maskCardNumber("6225880159874321");
// 回傳: "6225****4321"

String phone = EncryptUtil.maskPhoneNumber("13812345678");
// 回傳: "138***5678"（實際保留前3後4，中間最多3個*，故為 "138****5678"）

// 自訂遮蔽規則：遮蔽身份證號（保留前3後3，最多遮蔽6位）
EncryptUtil.addMask("110101199001011234", 3, 3, 6);
// 回傳: "110******234"

// 自訂遮蔽規則
EncryptUtil.addMask("1234567890", 3, 3, 3);  // "123***890"
EncryptUtil.addMask("1234567890", 3, 3, 2);  // "123**7890"
```

---

##### 方法 — Map 排序與連接

###### `sort`

| 簽名 | 說明 |
|------|------|
| `sort(Map<String, String> request)` | 排序 Map 並以 `a=v1&b=v2` 格式連接 |
| `sort(Map<String, String> request, String separator)` | 指定項目分隔符 |

```java
// 場景：組裝支付請求的簽名原文（按 key 字母排序）
Map<String, String> params = new HashMap<>();
params.put("orderId", "ORD20260308001");
params.put("amount", "10000");
params.put("currency", "CNY");
params.put("appId", "APP001");

String signStr = EncryptUtil.sort(params);
// 回傳: "amount=10000&appId=APP001&currency=CNY&orderId=ORD20260308001"

// 使用自訂分隔符（如某些渠道要求用逗號分隔）
String signStr2 = EncryptUtil.sort(params, ",");
// 回傳: "amount=10000,appId=APP001,currency=CNY,orderId=ORD20260308001"
```

###### `sortMap` 系列

| 簽名 | 說明 |
|------|------|
| `sortMap(Map request, boolean allowEmpty)` | 排序 Map 並過濾空值，回傳 TreeMap |
| `sortMap(Map<String, ?> request, String separator, boolean allowEmpty)` | 排序並連接 |
| `sortMap(Map<String, ?> request, String kvSeparator, String itemSeparator, boolean allowEmpty)` | 自訂 KV 與項目分隔符 |
| `sortMap(Map<String, ?> request, String kvSeparator, String itemSeparator, boolean allowEmpty, boolean withFieldName)` | 可選是否包含欄位名 |

```java
// 場景：排序 Map 並過濾空值後回傳 TreeMap
Map<String, String> rawParams = new HashMap<>();
rawParams.put("orderId", "ORD001");
rawParams.put("remark", "");    // 空值
rawParams.put("amount", "500");
Map sortedMap = EncryptUtil.sortMap(rawParams, false);
// sortedMap 只含 "amount" 和 "orderId"（空值 "remark" 被過濾）

// 場景：排序並連接，自訂分隔符
String result = EncryptUtil.sortMap(rawParams, ":", "|", false);
// 回傳: "amount:500|orderId:ORD001"（空值被過濾）

// 不包含欄位名（僅連接值）
String valuesOnly = EncryptUtil.sortMap(rawParams, "=", "&", false, false);
// 回傳: "500&ORD001"
```

###### `sortMapV2` 系列

| 簽名 | 說明 |
|------|------|
| `sortMapV2(Map<String, ?> request, String kvSeparator, String itemSeparator, boolean allowEmpty)` | 排序並連接（V2 版） |
| `sortMapV2(..., boolean withFieldName)` | 可選是否包含欄位名 |
| `sortMapV2(..., boolean urlEncode, String charEncoding, String spaceReplacement)` | 支援 URL 編碼 |

```java
// 場景：排序 Map 並以 key=value 用 "&" 連接，跳過空值（最常見的簽名原文組裝方式）
Map<String, Object> payParams = new LinkedHashMap<>();
payParams.put("mchId", "MCH001");
payParams.put("outTradeNo", "T20260308001");
payParams.put("totalFee", 5000);
payParams.put("notifyUrl", "https://merchant.com/notify");

String signStr = EncryptUtil.sortMapV2(payParams, "=", "&", false);
// 回傳: "mchId=MCH001&notifyUrl=https://merchant.com/notify&outTradeNo=T20260308001&totalFee=5000"

// 場景：僅拼接排序後的值（無欄位名）
String valuesStr = EncryptUtil.sortMapV2(payParams, "=", "&", false, false);
// 回傳: "MCH001&https://merchant.com/notify&T20260308001&5000"

// 場景：排序連接並對值進行 URL 編碼（適用於 GET 請求參數）
String urlEncoded = EncryptUtil.sortMapV2(
    payParams, "=", "&", false, true, true, "UTF-8", "%20"
);
// notifyUrl 的值會被 URL 編碼
```

###### `sortMapNested`

| 簽名 | 說明 |
|------|------|
| `sortMapNested(Map<String, ?> srcMap)` | 遞歸排序巢狀 Map（回傳 TreeMap） |
| `sortMapNested(Map<String, ?> srcMap, String kvSeparator, String itemSeparator, boolean allowEmpty, boolean withFieldName, boolean urlEncode, String charEncoding, String spaceReplacement)` | 遞歸排序並連接為字串 |

```java
// 場景：巢狀 JSON 結構的簽名（如含子物件的支付請求）
Map<String, Object> request = new HashMap<>();
request.put("orderId", "ORD001");

Map<String, Object> goods = new HashMap<>();
goods.put("name", "商品A");
goods.put("price", "100");
request.put("goods", goods);

// 遞歸排序（回傳 TreeMap，巢狀 Map 也會被排序）
Map sorted = EncryptUtil.sortMapNested(request);

// 遞歸排序並連接為字串
String signStr = EncryptUtil.sortMapNested(
    request, "=", "&", false, true, false, null, null
);
// goods 的值會被遞歸展開並排序連接
```

###### `sortNoKey`

| 簽名 | 說明 |
|------|------|
| `sortNoKey(Map<?, ?> request)` | 排序 Map 並僅以 `;` 連接值 |
| `sortNoKey(Map<?, ?> request, String separator)` | 自訂分隔符 |

```java
// 場景：某些渠道簽名規則僅需排序後的值（不含 key）
Map<String, String> params = new HashMap<>();
params.put("b", "val2");
params.put("a", "val1");
params.put("c", "val3");

String result = EncryptUtil.sortNoKey(params);
// 回傳: "val1;val2;val3"（按 key 排序後僅連接值）

String result2 = EncryptUtil.sortNoKey(params, "|");
// 回傳: "val1|val2|val3"
```

###### `sortMapV1`

```java
public static String sortMapV1(Map<String, ?> request, String separator, boolean allowEmpty)
```

排序 Map 並連接（V1 版）。

```java
// 基本用法（行為與 sort 類似，但支援 Object 值和空值過濾）
String result = EncryptUtil.sortMapV1(params, "&", false);
// 回傳: "a=val1&b=val2&c=val3"
```

###### `concatMap` 系列

| 簽名 | 說明 |
|------|------|
| `concatMap(Map<String, ?> request, String kvSeparator, String itemSeparator, boolean allowEmpty)` | 按原序連接 Map |
| `concatMap(..., boolean withFieldName)` | 可選是否包含欄位名 |
| `concatMap(Map<?, ?> request, Collection<?> keys, ...)` | 指定 keys 順序連接 |
| `concatMap(..., boolean urlEncode, String charEncoding, String spaceReplacement)` | 支援 URL 編碼 |

```java
// 場景：按指定欄位順序連接（渠道要求固定欄位順序的簽名）
Map<String, String> txnData = new LinkedHashMap<>();
txnData.put("version", "1.0");
txnData.put("merId", "MCH001");
txnData.put("orderId", "ORD001");
txnData.put("txnAmt", "10000");

// 按原始插入順序連接
String concat = EncryptUtil.concatMap(txnData, "=", "&", false);
// 回傳: "version=1.0&merId=MCH001&orderId=ORD001&txnAmt=10000"

// 指定 key 順序連接（渠道規定的簽名欄位順序）
List<String> signFields = Arrays.asList("merId", "orderId", "txnAmt");
String signStr = EncryptUtil.concatMap(txnData, signFields, "=", "&", false);
// 回傳: "merId=MCH001&orderId=ORD001&txnAmt=10000"（僅含指定欄位）

// 不含欄位名，僅連接值
String valOnly = EncryptUtil.concatMap(txnData, signFields, "=", "|", false, false);
// 回傳: "MCH001|ORD001|10000"

// 含 URL 編碼
String urlEncoded = EncryptUtil.concatMap(
    txnData, txnData.keySet(), "=", "&", false, true, true, "UTF-8", "%20"
);
```

###### `concatMapNested`

```java
public static String concatMapNested(Map<?, ?> request, String kvSeparator, String itemSeparator, boolean allowEmpty, boolean withFieldName, boolean urlEncode, String charEncoding, String spaceReplacement)
```

按原序連接 Map，值為 Map 時遞歸處理。

```java
// 場景：含巢狀結構的請求參數連接（如 JSON 轉 Map 後的簽名）
Map<String, Object> outerMap = new LinkedHashMap<>();
outerMap.put("appId", "APP001");

Map<String, Object> bizContent = new LinkedHashMap<>();
bizContent.put("orderId", "ORD001");
bizContent.put("amount", "5000");
outerMap.put("bizContent", bizContent);

String result = EncryptUtil.concatMapNested(
    outerMap, "=", "&", false, true, false, null, null
);
// bizContent 的值會被遞歸展開為 "orderId=ORD001&amount=5000"
```

#### Protected 部分

無 protected 成員。
