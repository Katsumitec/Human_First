# Converter

類別名稱：`com.icpay.payment.common.utils.Converter`

## 說明

型別轉換工具集，提供日期時間格式轉換、二進制/Base64/Hex 編碼轉換、物件序列化/反序列化、URL 參數與 Map 互轉、字串型別轉換、百分比字串解析、Base64 URL 編碼等功能。是支付系統中處理資料格式轉換的核心工具類別。在 FreeMarker 模板中以 `conv` 物件存取。

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **Maven Artifact**: `com.ppay:icpay-common-utils`
- **繼承**: 無（獨立工具類別）
- **相依性**:
  - `java.time.Instant` / `OffsetDateTime` / `LocalDateTime` / `DateTimeFormatter`
  - `org.apache.commons.codec.net.URLCodec`
  - `org.apache.commons.lang.StringUtils`
  - `com.icpay.payment.common.utils.Utils`
  - `com.icpay.payment.common.utils.EncodeUtils`
  - `com.icpay.payment.common.utils.SimpleDateFormatThreadSafe`（執行緒安全的日期格式化）

## API 說明

### Class: Converter

#### Public 部分

##### 方法 — 日期時間格式化

###### `DATETIME_FORMAT` / `DATE_FORMAT` / `TIME_FORMAT`

```java
public static DateFormat DATETIME_FORMAT()  // "yyyyMMddHHmmss"
public static DateFormat DATE_FORMAT()      // "yyyyMMdd"
public static DateFormat TIME_FORMAT()      // "HHmmss"
```

回傳執行緒安全的日期格式化物件。

```java
// 取得格式化物件，直接用於格式化或解析
DateFormat dtFmt = Converter.DATETIME_FORMAT();
String formatted = dtFmt.format(new Date());  // "20260308143025"

DateFormat dFmt = Converter.DATE_FORMAT();
String dateOnly = dFmt.format(new Date());    // "20260308"

DateFormat tFmt = Converter.TIME_FORMAT();
String timeOnly = tFmt.format(new Date());    // "143025"
```

###### `dateTimeToString`

```java
public static String dateTimeToString(Date dt)
```

轉換日期時間為標準字串（`yyyyMMddHHmmss`）。

```java
String s = Converter.dateTimeToString(new Date());
// 範例輸出: "20260308143025"
```

###### `dateTimeToStringFmt`

```java
public static String dateTimeToStringFmt(Date dt, String format)
```

依指定格式轉換日期時間為字串。

```java
String s = Converter.dateTimeToStringFmt(new Date(), "yyyy-MM-dd HH:mm:ss");
// 範例輸出: "2026-03-08 14:30:25"

// 常見於渠道要求的時間格式
String s2 = Converter.dateTimeToStringFmt(new Date(), "yyyy/MM/dd");
// 範例輸出: "2026/03/08"
```

###### `dateToString`

```java
public static String dateToString(Date d)
```

轉換日期為標準日期字串（`yyyyMMdd`）。

```java
String dateStr = Converter.dateToString(new Date());
// 範例輸出: "20260308"

// FreeMarker 模板中的典型用法
// ${conv.dateToString(.now)}
```

###### `timeToString`

```java
public static String timeToString(Date d)
```

轉換日期為標準時間字串（`HHmmss`）。

```java
String timeStr = Converter.timeToString(new Date());
// 範例輸出: "143025"
```

###### `stringToDateTime`

| 簽名 | 說明 |
|------|------|
| `stringToDateTime(String sdt)` | 標準日期時間字串（`yyyyMMddHHmmss`）轉 Date。若輸入長度為 8，自動補 `"000000"` |
| `stringToDateTime(String sd, String st)` | 分開的日期與時間字串轉 Date |

```java
// 完整日期時間字串
Date dt = Converter.stringToDateTime("20260308143025");

// 僅傳入日期（8 碼），自動補零為 "20260308000000"
Date dtDateOnly = Converter.stringToDateTime("20260308");

// 分開的日期與時間字串
Date dt2 = Converter.stringToDateTime("20260308", "143025");
```

###### `stringToDateTimeFmt`

```java
public static Date stringToDateTimeFmt(String sdt, String format) throws ParseException
```

依指定格式解析日期時間字串。

```java
// 解析渠道回傳的自訂格式時間
Date dt = Converter.stringToDateTimeFmt("2026-03-08 14:30:25", "yyyy-MM-dd HH:mm:ss");

// 解析僅含日期的字串
Date dt2 = Converter.stringToDateTimeFmt("2026/03/08", "yyyy/MM/dd");
```

---

##### 方法 — UTC 時間轉換

###### `dateTimeToUTC`

```java
public static String dateTimeToUTC(Date date)
```

將 Date 轉換為 UTC 格式字串（ISO 8601）。

```java
String utc = Converter.dateTimeToUTC(new Date());
// 範例輸出: "2026-03-08T06:30:25Z"

// null 安全
String nullResult = Converter.dateTimeToUTC(null);
// 回傳: null
```

###### `utcToDateTime`

```java
public static Date utcToDateTime(String utcTimeStr)
```

將 UTC 格式字串轉換為 Date。支援多種格式：
- `yyyy-MM-dd'T'HH:mm:ss'Z'`（UTC）
- `yyyy-MM-dd'T'HH:mm:ss.SSS'+08:00'`（帶時區偏移）
- `yyyy-MM-dd'T'HH:mm:ss`（不帶時區，使用本地時區）

解析失敗回傳 null。

```java
// 標準 UTC 格式
Date dt1 = Converter.utcToDateTime("2026-03-08T06:30:25Z");

// 帶時區偏移（常見於亞洲渠道回傳）
Date dt2 = Converter.utcToDateTime("2026-03-08T14:30:25.000+08:00");

// 不帶時區資訊（使用本地時區解析）
Date dt3 = Converter.utcToDateTime("2026-03-08T14:30:25");

// 格式錯誤時安全回傳 null
Date dtErr = Converter.utcToDateTime("invalid");
// 回傳: null
```

---

##### 方法 — 時間差計算

###### `timeDiff`

| 簽名 | 說明 |
|------|------|
| `timeDiff(Date start, Date end)` | 計算時間差（毫秒），可為負數 |
| `timeDiff(String startTimeUtc, String endTimeUtc)` | UTC 字串版本 |

###### `timeDiffAbs`

| 簽名 | 說明 |
|------|------|
| `timeDiffAbs(Date start, Date end)` | 計算時間差的絕對值（毫秒） |
| `timeDiffAbs(String startTimeUtc, String endTimeUtc)` | UTC 字串版本 |

```java
// 使用 Date 物件計算時間差
Date start = Converter.stringToDateTime("20260308140000");
Date end = Converter.stringToDateTime("20260308143025");
Long diff = Converter.timeDiff(start, end);
// 回傳: 1825000 (正值，表示 end 晚於 start)

Long diffAbs = Converter.timeDiffAbs(end, start);
// 回傳: 1825000 (絕對值，不論順序)

// 使用 UTC 字串計算時間差（適用於渠道回傳的 UTC 時間戳比對）
Long utcDiff = Converter.timeDiff("2026-03-08T06:00:00Z", "2026-03-08T06:30:25Z");
// 回傳: 1825000

Long utcDiffAbs = Converter.timeDiffAbs("2026-03-08T06:30:25Z", "2026-03-08T06:00:00Z");
// 回傳: 1825000

// null 安全
Long nullDiff = Converter.timeDiff((Date) null, new Date());
// 回傳: null
```

---

##### 方法 — 二進制 / Base64 / Hex 轉換

###### `binToBase64String`

```java
public static String binToBase64String(byte[] bin)
```

二進制資料轉 Base64 字串。

```java
byte[] data = "Hello Payment".getBytes("UTF-8");
String base64 = Converter.binToBase64String(data);
// 範例輸出: "SGVsbG8gUGF5bWVudA=="

// 空陣列安全處理
String empty = Converter.binToBase64String(null);
// 回傳: ""
```

###### `base64StringToBin`

```java
public static byte[] base64StringToBin(String base64Str)
```

Base64 字串轉二進制資料。

```java
byte[] decoded = Converter.base64StringToBin("SGVsbG8gUGF5bWVudA==");
String text = new String(decoded, "UTF-8");
// text = "Hello Payment"

// 空值安全處理
byte[] nullResult = Converter.base64StringToBin(null);
// 回傳: null
```

###### `binToHexString`

| 簽名 | 說明 |
|------|------|
| `binToHexString(byte[] binData)` | 二進制轉大寫 Hex 字串 |
| `binToHexString(byte[] binData, boolean toLowerCase)` | 可選大小寫 |
| `binToHexString(byte[] binData, int offset, int len)` | 指定偏移與長度 |

```java
// 預設大寫
String hex = Converter.binToHexString(new byte[]{(byte)0xAB, (byte)0xCD});
// 回傳: "ABCD"

// 轉小寫（常見於某些渠道簽名要求小寫 hex）
String hexLower = Converter.binToHexString(new byte[]{(byte)0xAB}, true);
// 回傳: "ab"

// 指定偏移與長度（擷取部分資料）
byte[] fullData = new byte[]{0x01, 0x02, 0x03, 0x04, 0x05};
String partial = Converter.binToHexString(fullData, 1, 3);
// 回傳: "020304" (從 offset=1 開始取 3 個 byte)
```

###### `hexStringToBin`

```java
public static byte[] hexStringToBin(String hexStr)
```

Hex 字串轉二進制資料。若長度為奇數自動前補 `"0"`。

```java
byte[] bin = Converter.hexStringToBin("ABCD");
// bin = {(byte)0xAB, (byte)0xCD}

// 奇數長度自動前補 0
byte[] bin2 = Converter.hexStringToBin("ABC");
// 等同於 hexStringToBin("0ABC")，bin2 = {(byte)0x0A, (byte)0xBC}

// Hex 與 Base64 互轉範例（常見於簽名處理）
byte[] signData = Converter.hexStringToBin("48656C6C6F");
String base64Sign = Converter.binToBase64String(signData);
```

---

##### 方法 — Base64 URL 編碼

###### `base64UrlEncode`

```java
public static String base64UrlEncode(byte[] input)
```

Base64 URL 安全編碼：替換 `+` 為 `-`，`/` 為 `_`，移除 `=` 填充。

```java
// 常用於 JWT token 的 header/payload 編碼
byte[] payload = "{\"sub\":\"1234567890\",\"name\":\"test\"}".getBytes("UTF-8");
String encoded = Converter.base64UrlEncode(payload);
// 輸出不含 +, /, = 等 URL 不安全字元
```

###### `base64UrlDecode`

```java
public static byte[] base64UrlDecode(String input)
```

解碼 Base64 URL 編碼字串，自動還原填充。

```java
// 解碼 JWT token 中的 Base64 URL 編碼內容
byte[] decoded = Converter.base64UrlDecode(encoded);
String json = new String(decoded, "UTF-8");
// json = "{\"sub\":\"1234567890\",\"name\":\"test\"}"

// 編碼與解碼往返驗證
byte[] original = "Payment Data".getBytes("UTF-8");
String enc = Converter.base64UrlEncode(original);
byte[] dec = Converter.base64UrlDecode(enc);
// new String(dec) 等於 "Payment Data"
```

---

##### 方法 — 序列化 / 反序列化

###### `serializeToBin`

```java
public static byte[] serializeToBin(Serializable obj) throws IOException
```

將物件序列化為 byte[]。

###### `serialize`

```java
public static String serialize(Serializable obj) throws IOException
```

將物件序列化為 Base64 字串。

###### `deserializeFromBin`

```java
public static Object deserializeFromBin(byte[] bin) throws IOException, ClassNotFoundException
```

從 byte[] 反序列化物件。

###### `deserialize`

```java
public static Object deserialize(String base64Str) throws IOException, ClassNotFoundException
```

從 Base64 字串反序列化物件。

```java
// --- 使用 Base64 字串序列化（適合存入資料庫文字欄位或傳輸） ---
HashMap<String, String> txnData = new HashMap<>();
txnData.put("orderId", "ORD20260308001");
txnData.put("amount", "1000");

// 序列化為 Base64 字串
String serialized = Converter.serialize(txnData);

// 反序列化還原
HashMap<String, String> restored = (HashMap<String, String>) Converter.deserialize(serialized);
// restored.get("orderId") = "ORD20260308001"

// --- 使用 byte[] 序列化（適合二進制儲存或快取） ---
byte[] bin = Converter.serializeToBin(txnData);
HashMap<String, String> restored2 = (HashMap<String, String>) Converter.deserializeFromBin(bin);

// null 安全
String nullSerialized = Converter.serialize(null);
// 回傳: ""
```

---

##### 方法 — URL 參數與 Map 互轉

###### `mapToParamStr`

| 簽名 | 說明 |
|------|------|
| `mapToParamStr(Map map)` | Map 轉 URL 參數字串（UTF-8） |
| `mapToParamStr(Map map, String charset)` | 指定字符集 |

```java
Map<String, String> params = new HashMap<>();
params.put("name", "測試");
params.put("amount", "100");
String paramStr = Converter.mapToParamStr(params);
// 範例輸出: "name=%E6%B8%AC%E8%A9%A6&amount=100"

// 指定字符集（部分渠道使用 GBK 編碼）
String paramStrGbk = Converter.mapToParamStr(params, "GBK");
```

###### `paramStrToMap`

| 簽名 | 說明 |
|------|------|
| `paramStrToMap(String paramStr)` | URL 參數字串轉 Map（UTF-8） |
| `paramStrToMap(String paramStr, String charset)` | 指定字符集 |

```java
// 解析渠道回傳的參數字串
Map map = Converter.paramStrToMap("name=%E6%B8%AC%E8%A9%A6&amount=100");
// map.get("name") = "測試"
// map.get("amount") = "100"

// 處理渠道回呼通知的參數
String notifyBody = "orderNo=ORD001&status=SUCCESS&sign=abc123";
Map notifyMap = Converter.paramStrToMap(notifyBody);
String orderNo = (String) notifyMap.get("orderNo");
String status = (String) notifyMap.get("status");
```

---

##### 方法 — LLVAR 格式

###### `getAsLLLVAR`

```java
public static byte[] getAsLLLVAR(byte[] data)
```

將資料包裝成 LLLVAR 格式（3 位長度前綴 + 資料）。用於 ISO8583 協議。

```java
// ISO8583 報文欄位包裝
byte[] fieldData = "Hello".getBytes();
byte[] lllvar = Converter.getAsLLLVAR(fieldData);
// lllvar 內容為 "005Hello" 的 byte 表示
// 前 3 個 byte 為長度 "005"，後面接原始資料
```

---

##### 方法 — 型別轉換

###### `strToDouble`

| 簽名 | 說明 |
|------|------|
| `strToDouble(String val)` | 字串轉 Double，空值預設 0.0 |
| `strToDouble(String val, Double defaultVal)` | 指定預設值 |

```java
Double amount = Converter.strToDouble("100.50");
// 回傳: 100.5

Double zero = Converter.strToDouble("");
// 回傳: 0.0 (空值預設)

Double custom = Converter.strToDouble(null, -1.0);
// 回傳: -1.0 (指定預設值)
```

###### `strToFloat`

| 簽名 | 說明 |
|------|------|
| `strToFloat(String val)` | 字串轉 Float，空值預設 0.0 |
| `strToFloat(String val, Float defaultVal)` | 指定預設值 |

```java
Float rate = Converter.strToFloat("3.14");
// 回傳: 3.14f

Float zero = Converter.strToFloat("");
// 回傳: 0.0f
```

###### `strToLong`

| 簽名 | 說明 |
|------|------|
| `strToLong(String val)` | 字串轉 Long，空值預設 0。含小數點時自動去除 |
| `strToLong(String val, Long defaultVal)` | 指定預設值 |

```java
Long amount = Converter.strToLong("1000");
// 回傳: 1000L

// 含小數點時自動截斷（先轉 Double 再取 long 值）
Long truncated = Converter.strToLong("1000.99");
// 回傳: 1000L

Long zero = Converter.strToLong("");
// 回傳: 0L
```

###### `strToInteger`

| 簽名 | 說明 |
|------|------|
| `strToInteger(String val)` | 字串轉 Integer，空值預設 0。含小數點時自動去除 |
| `strToInteger(String val, Integer defaultVal)` | 指定預設值 |

```java
Integer amount = Converter.strToInteger("100.50");
// 回傳: 100

Integer count = Converter.strToInteger("5");
// 回傳: 5

Integer defaultVal = Converter.strToInteger("", -1);
// 回傳: -1
```

###### `strPercentToDouble`

```java
public static Double strPercentToDouble(String val)
```

智慧判斷，轉換百分比字串為浮點數。

| 輸入 | 輸出 |
|------|------|
| `"100"` | `1.0` |
| `"100%"` | `1.0` |
| `"1.25%"` | `0.0125` |
| `"10.25％"` | `0.1025`（全型百分符號） |
| `"25‰"` | `0.025`（千分號） |
| `"0.15"` | `0.15`（以 0. 開頭視為已轉換） |
| `"test"` | `null` |

```java
// 渠道回傳的手續費率轉換
Double rate = Converter.strPercentToDouble("1.25%");
// 回傳: 0.0125

// 全型百分號（部分中文系統常見）
Double rate2 = Converter.strPercentToDouble("10.25％");
// 回傳: 0.1025

// 千分號（常見於銀行費率）
Double rate3 = Converter.strPercentToDouble("25‰");
// 回傳: 0.025

// 以 "0." 開頭視為已經是小數值
Double rate4 = Converter.strPercentToDouble("0.15");
// 回傳: 0.15

// 無百分號的純數字，預設除以 100
Double rate5 = Converter.strPercentToDouble("100");
// 回傳: 1.0

// 無法解析的字串
Double invalid = Converter.strPercentToDouble("test");
// 回傳: null
```

###### `fixIntegerStr`

```java
public static String fixIntegerStr(String s)
```

將字串去除小數點以後的部分。

```java
String s = Converter.fixIntegerStr("100.50");
// 回傳: "100"

String s2 = Converter.fixIntegerStr("200");
// 回傳: "200" (無小數點則原樣回傳)

String s3 = Converter.fixIntegerStr("");
// 回傳: ""
```

---

##### 方法 — 其他

###### `createMap`

```java
public static Map createMap(Object... context)
```

建立 Map，以 key-value 配對方式傳入。自動過濾 key 為空或 value 為 null 的項目。

```java
// 快速建立參數 Map
Map m = Converter.createMap("keyA", obj1, "keyB", obj2);

// 實際使用情境：組裝渠道請求參數
Map reqParams = Converter.createMap(
    "merchantId", "M001",
    "orderNo", "ORD20260308001",
    "amount", "1000",
    "currency", "TWD"
);

// value 為 null 的項目會自動過濾
Map filtered = Converter.createMap(
    "name", "test",
    "optional", null   // 此項不會加入 Map
);
// filtered 只包含 {"name": "test"}
```

###### `isBase64Str`

```java
public static boolean isBase64Str(String str)
```

判斷字串是否為 Base64 格式。

```java
boolean yes = Converter.isBase64Str("SGVsbG8=");
// 回傳: true

boolean no = Converter.isBase64Str("Hello World!");
// 回傳: false

// 常用於判斷渠道回傳資料是否需要 Base64 解碼
String responseBody = getChannelResponse();
if (Converter.isBase64Str(responseBody)) {
    byte[] decoded = Converter.base64StringToBin(responseBody);
    responseBody = new String(decoded, "UTF-8");
}
```

#### Protected 部分

##### 常數

| 常數 | 型別 | 說明 |
|------|------|------|
| `hexChars` | `String[]` | Hex 字元對照陣列 `{"0","1",...,"F"}` |

##### 方法

###### `strValue`

| 簽名 | 說明 |
|------|------|
| `strValue(Object v)` | 物件轉字串（trim），null 回傳 null |
| `strValue(Object v, String defaultVal)` | 物件轉字串（trim），null 回傳預設值 |

```java
// 在子類別中使用
String val = strValue(someObject);
// 回傳 trim 後的字串，若 someObject 為 null 則回傳 null

String valWithDefault = strValue(someObject, "N/A");
// someObject 為 null 時回傳 "N/A"
```

###### `strDoubleToLong`

```java
protected static Long strDoubleToLong(String sv)
```

字串先轉 Double 再轉 Long（用於處理帶小數點的整數字串）。

###### `strDoubleToInteger`

```java
protected static Integer strDoubleToInteger(String sv)
```

字串先轉 Double 再轉 Integer。

```java
// 這兩個方法主要由 strToLong / strToInteger 內部呼叫
// 處理如 "100.00" 這類帶小數點但實際為整數的字串
Long val = strDoubleToLong("100.99");
// 回傳: 100L

Integer val2 = strDoubleToInteger("50.75");
// 回傳: 50
```
