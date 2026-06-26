# Utils

類別名稱：`com.icpay.payment.common.utils.Utils`

## 說明

常用工具集，移植自 icpay-utils.jar。提供廣泛的靜態工具方法，包括：空值檢查、字串處理、隨機數生成、序號產生、Map 操作、集合操作、網路工具、日誌（Log4j MDC/NDC）操作、日期時間比對、正則比對等。是整個支付系統中最基礎的工具類別。

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **Maven Artifact**: `com.ppay:icpay-common-utils`
- **繼承**: 無（獨立工具類別）
- **相依性**:
  - `org.apache.commons.codec.binary.StringUtils`
  - `org.apache.log4j.MDC` / `NDC`
  - `com.icpay.payment.common.exception.BizzException`
  - `com.icpay.payment.common.exception.ChnlBizException`
  - `com.icpay.payment.common.utils.Converter`
  - `com.icpay.payment.common.utils.StringUtil`
  - `com.icpay.payment.common.utils.SysConfig`

## API 說明

### Class: Utils

#### Public 部分

##### 常數

| 常數 | 型別 | 說明 |
|------|------|------|
| `DEFAULT_UNIQUEID_SCOPE` | `String` | 預設之範圍識別碼，值為 `"_UNIQUE_ID_"` |
| `K_REQUEST` | `String` | MDC key，值為 `"request"` |
| `K_RESULT` | `String` | MDC key，值為 `"result"` |
| `K_SESSIONID` | `String` | MDC key，值為 `"sessionId"` |
| `K_LOGTIME` | `String` | MDC key，值為 `"logTime"` |

##### 屬性

| 屬性 | 型別 | 說明 |
|------|------|------|
| `LastRandomInt` | `int` | 最後產生的隨機整數 |
| `LastRandomLong` | `long` | 最後產生的隨機長整數 |

---

##### 方法 — 空值檢查

###### `isEmpty` 系列

多載方法，支援多種型別的空值判斷。

| 簽名 | 說明 |
|------|------|
| `isEmpty(String str)` | 檢查字串是否為 null 或空字串 |
| `isEmpty(Object obj)` | 檢查物件是否為 null 或 `toString()` 為空字串 |
| `isEmpty(Object[] array)` | 檢查陣列是否為 null 或長度為 0 |
| `isEmpty(byte[] array)` | 檢查 byte 陣列是否為 null 或長度為 0 |
| `isEmpty(Map obj)` | 檢查 Map 是否為 null 或 size 為 0 |
| `isEmpty(Collection obj)` | 檢查 Collection 是否為 null 或 size 為 0 |
| `isEmpty(StringBuilder buf)` | 檢查 StringBuilder 是否為 null 或長度為 0 |
| `isEmpty(StringBuffer buf)` | 檢查 StringBuffer 是否為 null 或長度為 0 |

```java
// 檢查交易金額字串是否為空
String txnAmt = request.getParameter("txnAmt");
if (Utils.isEmpty(txnAmt)) {
    throw new BizzException("交易金額不得為空");
}

// 檢查渠道回應參數 Map 是否為空
Map<String, String> respMap = parseChannelResponse(responseBody);
if (Utils.isEmpty(respMap)) {
    log.error("渠道回應解析失敗，回應為空");
}

// 檢查簽名 byte 陣列
byte[] signBytes = getSignatureBytes();
if (Utils.isEmpty(signBytes)) {
    throw new BizzException("簽名資料為空");
}
```

###### `isUndefined` 系列

判斷值是否為空或以 `${` 開頭（表示未被替換的佔位符）。

| 簽名 | 說明 |
|------|------|
| `isUndefined(String buf)` | 字串為空或以 `${` 開頭 |
| `isUndefined(Object buf)` | 物件為空或 toString 以 `${` 開頭 |
| `isUndefined(StringBuilder buf)` | StringBuilder 為空或以 `${` 開頭 |
| `isUndefined(StringBuffer buf)` | StringBuffer 為空或以 `${` 開頭 |

```java
// 檢查 FreeMarker 模板變數是否已被正確替換
String notifyUrl = merParams.get("notifyUrl");
if (Utils.isUndefined(notifyUrl)) {
    // notifyUrl 為空或仍為 "${notifyUrl}" 佔位符，使用預設值
    notifyUrl = SysConfig.getDefaultNotifyUrl();
}

// 檢查渠道設定中的 API 端點
String apiEndpoint = extConfig.get("apiUrl");
if (Utils.isUndefined(apiEndpoint)) {
    throw new BizzException("渠道 API 端點未設定");
}
```

###### `hasEmpty` / `isAllEmpty` / `hasNull` / `isAllNull`

| 簽名 | 說明 |
|------|------|
| `hasEmpty(Object... objs)` | 判斷是否有任一參數為 empty |
| `isAllEmpty(Object... objs)` | 判斷是否全部參數為 empty |
| `hasNull(Object... objs)` | 判斷是否有任一參數為 null |
| `isAllNull(Object... objs)` | 判斷是否全部參數為 null |

```java
// 驗證支付請求必填欄位
String merId = req.get("merId");
String txnAmt = req.get("txnAmt");
String orderId = req.get("orderId");
if (Utils.hasEmpty(merId, txnAmt, orderId)) {
    throw new BizzException("商戶號、交易金額、訂單號為必填欄位");
}

// 檢查是否所有備用渠道都無法使用
String chnl1 = getChnlStatus("CHNL_A");
String chnl2 = getChnlStatus("CHNL_B");
String chnl3 = getChnlStatus("CHNL_C");
if (Utils.isAllEmpty(chnl1, chnl2, chnl3)) {
    log.error("所有備用渠道均不可用");
}

// 檢查回傳結果是否有 null 值
Object respCode = resp.get("respCode");
Object respMsg = resp.get("respMsg");
if (Utils.hasNull(respCode, respMsg)) {
    log.warn("渠道回應缺少必要欄位");
}
```

###### `defaultIfNull`

```java
public static <T> T defaultIfNull(T testVal, T defaulVal)
```

如果 `testVal` 為空（isEmpty）則回傳 `defaulVal`，否則回傳 `testVal`。

```java
// 預設編碼
String charset = Utils.defaultIfNull(reqCharset, "UTF-8");

// 預設交易幣別
String currency = Utils.defaultIfNull(merParams.get("currency"), "TWD");

// 預設逾時設定
String timeout = Utils.defaultIfNull(extConfig.get("connectTimeout"), "30000");
```

###### `isTrue` / `isFalse`

```java
public static boolean isTrue(Object val)
public static boolean isFalse(Object val)
```

- `isTrue`: 判斷值是否明確為真（`true`, `"true"`, `"1"`, `"yes"`）
- `isFalse`: 判斷值是否明確為假（`false`, `"false"`, `"0"`, `"no"`）

```java
// 根據 MerParams 設定決定是否啟用簽名
if (Utils.isTrue(merParams.get("enableSign"))) {
    String sign = signService.sign(reqBody);
    reqMap.put("sign", sign);
}

// 檢查是否停用加密
if (Utils.isFalse(extConfig.get("enableEncrypt"))) {
    log.info("該渠道已停用加密");
}
```

---

##### 方法 — 字串處理

###### `toString`

| 簽名 | 說明 |
|------|------|
| `toString(Object obj)` | 若 null 回傳 `""`，否則回傳 `obj.toString()` |
| `toString(Object obj, String defaultVal)` | 若 null 回傳 defaultVal |

```java
// 安全取得交易類型，避免 NullPointerException
String txnType = Utils.toString(reqMap.get("txnType"));

// 取得渠道代碼，null 時使用預設值
String chnlId = Utils.toString(reqMap.get("chnlId"), "DEFAULT");
```

###### `getAsString`

```java
public static String getAsString(Object obj)
```

等同 `toString(Object)`。

```java
// 將渠道回傳的物件轉為字串
String respCode = Utils.getAsString(channelResp.get("code"));
```

###### `beginWith` / `endWith`

```java
public static boolean beginWith(String src, String find)
public static boolean endWith(String src, String find)
```

判斷字串的起始或結束。

```java
// 檢查交易回應碼是否以 "00" 開頭（表示成功）
String respCode = resp.get("respCode");
if (Utils.beginWith(respCode, "00")) {
    log.info("交易成功");
}

// 檢查回呼 URL 是否為 HTTPS
String notifyUrl = merParams.get("notifyUrl");
if (!Utils.beginWith(notifyUrl, "https")) {
    log.warn("回呼 URL 非 HTTPS，安全風險較高");
}

// 檢查檔案名稱是否為 XML 格式
if (Utils.endWith(fileName, ".xml")) {
    parseXmlResponse(content);
}
```

###### `getStrFirst` / `getStrLast`

```java
public static String getStrFirst(String src, int len)
public static String getStrLast(String src, int len)
```

擷取字串開頭或結尾指定長度的部分。

```java
// 取得卡號末四碼用於顯示
String last4 = Utils.getStrLast("6226890012345678", 4); // "5678"

// 取得商戶號前三碼（機構代碼）
String orgCode = Utils.getStrFirst("001M00012345", 3); // "001"
```

###### `removeQuotation`

| 簽名 | 說明 |
|------|------|
| `removeQuotation(String str)` | 移除單引號或雙引號 |
| `removeQuotation(String str, String startQuotation, String endQuotation)` | 指定引號字元移除 |

```java
// 移除渠道回傳值中的多餘引號
String rawValue = "\"SUCCESS\"";
String cleanValue = Utils.removeQuotation(rawValue); // "SUCCESS"

// 移除自訂的包圍字元
String wrapped = "[ORDER_12345]";
String orderId = Utils.removeQuotation(wrapped, "[", "]"); // "ORDER_12345"
```

###### `getUrlSafeString`

```java
public static String getUrlSafeString(String s)
```

將字串中的 URL 不安全字元（`/`, `=`, `:`, `+`, `%`, `&`）替換為安全字元。

```java
// 將 Base64 編碼結果轉為 URL 安全格式
String base64Sign = Base64.getEncoder().encodeToString(signBytes);
String urlSafeSign = Utils.getUrlSafeString(base64Sign);
// 可安全用於 URL query string
String redirectUrl = "https://pay.example.com/callback?sign=" + urlSafeSign;
```

###### `concat`

```java
public static String concat(Object... args)
```

串接多個物件為字串。

```java
// 組合日誌訊息
String logMsg = Utils.concat("商戶[", merId, "]發起交易, 金額=", txnAmt, ", 幣別=", currency);
log.info(logMsg);

// 組合簽名原文
String signSrc = Utils.concat(merId, "|", orderId, "|", txnAmt, "|", key);
```

###### `append` / `appendln`

| 簽名 | 說明 |
|------|------|
| `append(StringBuilder buf, Object... args)` | 多個物件附加到 StringBuilder |
| `append(StringBuffer buf, Object... args)` | 多個物件附加到 StringBuffer |
| `appendln(StringBuilder buf, Object... args)` | 附加後加換行 |
| `appendln(StringBuffer buf, Object... args)` | 附加後加換行 |

```java
// 建構 XML 請求報文
StringBuilder xml = new StringBuilder();
Utils.appendln(xml, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
Utils.appendln(xml, "<request>");
Utils.appendln(xml, "  <merId>", merId, "</merId>");
Utils.appendln(xml, "  <orderId>", orderId, "</orderId>");
Utils.appendln(xml, "  <txnAmt>", txnAmt, "</txnAmt>");
Utils.appendln(xml, "</request>");
String reqBody = xml.toString();
```

###### `appendListStr`

```java
public static String appendListStr(String src, String splitor, Object... args)
```

以分隔符號串接參數列到字串列。

```java
// 動態新增需簽名的欄位清單
String signFields = "merId,orderId";
signFields = Utils.appendListStr(signFields, ",", "txnAmt", "currency", "txnTime");
// 結果: "merId,orderId,txnAmt,currency,txnTime"
```

###### `strSplit` 系列

| 簽名 | 說明 |
|------|------|
| `strSplit(String src, String splitor)` | 切割字串為陣列 |
| `strSplit(String src, String splitor, int arrLen)` | 切割為固定長度陣列，空值以 `""` 填充 |
| `strSplit(String src, String splitor, int arrLen, String defaultStrVal)` | 切割為固定長度陣列，空值以指定預設值填充 |
| `strSplitToList(String src, String splitor, boolean ignoreEmpty)` | 切割為 List，可忽略空項目 |

```java
// 解析渠道回傳的分隔符格式資料
String[] parts = Utils.strSplit("00|交易成功|20240101120000", "|", 5);
// 結果: ["00", "交易成功", "20240101120000", "", ""]
String respCode = parts[0]; // "00"
String respMsg = parts[1];  // "交易成功"

// 解析設定中的支援交易類型列表，忽略空項目
String supportedTypes = "PAY,,REFUND,,QUERY";
List<String> typeList = Utils.strSplitToList(supportedTypes, ",", true);
// 結果: ["PAY", "REFUND", "QUERY"]
```

###### `isMatch`

```java
public static boolean isMatch(String regex, CharSequence input)
```

先用 `equals` 比對，若不等再用正則表示式比對。

```java
// 驗證訂單號格式（字母開頭 + 數字，10~32 位）
if (!Utils.isMatch("^[A-Za-z]\\d{9,31}$", orderId)) {
    throw new BizzException("訂單號格式不正確");
}

// 驗證金額格式（整數或兩位小數）
if (!Utils.isMatch("^\\d+(\\.\\d{1,2})?$", txnAmt)) {
    throw new BizzException("金額格式不正確");
}
```

###### `escapeHtml`

```java
public static String escapeHtml(String input)
public static String escapeHtml(Object input)
```

替換 HTML 特殊字元（`<`, `>`, `"`, `'`, `&`）。

```java
// 將商戶名稱進行 HTML 跳脫，避免 XSS
String merName = Utils.escapeHtml(req.get("merName"));
// 輸入: "<script>alert('xss')</script>"
// 輸出: "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"
```

###### `retriveJson`

```java
public static String retriveJson(String content)
```

從字串中擷取 JSON 格式的部分（`{...}` 之間的內容）。

```java
// 從渠道回應中擷取 JSON（回應可能包含額外文字）
String rawResp = "OK\n{\"code\":\"00\",\"msg\":\"success\"}\n";
String json = Utils.retriveJson(rawResp);
// 結果: "{\"code\":\"00\",\"msg\":\"success\"}"
```

###### `lineSeparator`

```java
public static String lineSeparator()
```

回傳換行符號，固定為 `"\n"`。

```java
// 建構多行日誌訊息
String msg = "交易摘要：" + Utils.lineSeparator()
    + "商戶號：" + merId + Utils.lineSeparator()
    + "訂單號：" + orderId;
```

---

##### 方法 — 隨機數與序號

###### `getRandomInt` / `getRandomLong`

```java
public static int getRandomInt(int min, int max)      // min <= x < max
public static long getRandomLong(long min, long max)   // min <= x < max
```

產生隨機數。

```java
// 產生隨機延遲時間（1~5 秒），用於重試間隔
int delayMs = Utils.getRandomInt(1000, 5001);
Utils.sleep(delayMs);

// 產生隨機交易追蹤號
long traceNo = Utils.getRandomLong(100000L, 999999L);
reqMap.put("traceNo", String.valueOf(traceNo));
```

###### `getRandomString` / `getRandomString2`

| 簽名 | 說明 |
|------|------|
| `getRandomString(int len)` | 產生指定長度隨機字串（小寫字母 + 數字） |
| `getRandomString2(int len)` | 產生指定長度隨機字串（大小寫字母 + 數字） |

```java
// 產生 32 位隨機字串作為 nonce（防重放攻擊）
String nonceStr = Utils.getRandomString2(32);
reqMap.put("nonceStr", nonceStr);

// 產生 16 位小寫隨機字串作為請求 ID
String requestId = Utils.getRandomString(16);
```

###### `getRandomBytes`

```java
public static byte[] getRandomBytes(int len)
```

產生指定長度的隨機位元組陣列。

```java
// 產生 16 位元組的 AES 加密金鑰
byte[] aesKey = Utils.getRandomBytes(16);

// 產生 IV 向量
byte[] iv = Utils.getRandomBytes(16);
```

###### `genUniqueSerial` 系列

```java
public static String genUniqueSerial(int len)   // 自訂長度
public static String genUniqueSerial16()         // 固定長度 16
public static String genUniqueSerial24()         // 固定長度 24
public static String genUniqueSerial32()         // 固定長度 32
```

產生具順序性與唯一性的序號（時間戳轉 36 進制 + 隨機字串）。

```java
// 產生系統交易流水號
String sysTraceNo = Utils.genUniqueSerial16();
// 範例輸出: "hiol7iy5t5itaeje"

// 產生 32 位唯一序號作為系統訂單號
String sysOrderId = Utils.genUniqueSerial32();
reqMap.put("sysOrderId", sysOrderId);

// 產生 24 位唯一序號作為批次號
String batchNo = Utils.genUniqueSerial24();
```

###### `genSerialNumber`

```java
public static String genSerialNumber(int len)
```

產生純數字型態的可排序序號（時間戳 + 隨機長整數），最大長度 32。

```java
// 產生 20 位純數字序號，適用於要求全數字的渠道介面
String numericSerial = Utils.genSerialNumber(20);
reqMap.put("merOrderId", numericSerial);
// 範例輸出: "20240315143025817384"
```

###### `toRadix36Str`

```java
public static String toRadix36Str(Long n)
```

將長整數轉換為 36 進制字串。

```java
// 將時間戳轉為 36 進制以縮短長度
Long timestamp = System.currentTimeMillis();
String shortTimestamp = Utils.toRadix36Str(timestamp);
// 例如 1710489600000L -> "jz1q2n9c"
```

---

##### 方法 — byte[] 操作

###### `bytesEquals`

| 簽名 | 說明 |
|------|------|
| `bytesEquals(byte[] a, byte[] b)` | 比較兩個 byte 陣列是否完全相等 |
| `bytesEquals(byte[] a, byte[] b, int offset, int len)` | 比較指定偏移與長度 |

```java
// 驗證簽名：比較計算出的簽名與渠道回傳的簽名
byte[] calculatedSign = signService.computeSign(respBody, signKey);
byte[] receivedSign = Base64.getDecoder().decode(resp.get("sign"));
if (!Utils.bytesEquals(calculatedSign, receivedSign)) {
    throw new BizzException("驗簽失敗");
}

// 比較 ISO8583 報文標頭（前 4 個位元組）
byte[] header = new byte[]{0x60, 0x00, 0x00, 0x00};
if (Utils.bytesEquals(msgBytes, header, 0, 4)) {
    log.info("ISO8583 報文標頭驗證通過");
}
```

---

##### 方法 — Map 操作

###### `newMap` / `newLinkedMap`

```java
public static <T> Map<String, T> newMap(Object... args)
public static Map<String, String> newMap(String... args)
public static <T> Map<String, T> newLinkedMap(Object... args)
public static Map<String, String> newLinkedMap(String... args)
```

以 key-value 配對形式快速建立 Map。

```java
// 快速建立交易請求參數
Map<String, String> params = Utils.newMap(
    "merId", "001M00012345",
    "txnAmt", "10000",
    "currency", "TWD",
    "orderId", "ORD20240315001"
);

// 使用 LinkedMap 保持鍵值順序（簽名時常需要）
Map<String, String> signParams = Utils.newLinkedMap(
    "appId", appId,
    "merId", merId,
    "orderId", orderId,
    "txnAmt", txnAmt,
    "timestamp", Utils.getTimeStamp()
);
```

###### `newList` / `newSet`

```java
public static List<String> newList(String... args)
public static Set<String> newSet(String... args)
```

快速建立 List 或 Set。

```java
// 建立支援的交易類型清單
List<String> supportedTxnTypes = Utils.newList("PAY", "REFUND", "QUERY", "CLOSE");

// 建立需排除的欄位集合（簽名時跳過）
Set<String> excludeFields = Utils.newSet("sign", "signType", "cert");
```

###### `getMapValue`

| 簽名 | 說明 |
|------|------|
| `getMapValue(Map map, String key, String defaultVal)` | 取值，null 時回傳預設值（String） |
| `getMapValue(Map map, Object key, Object defaultVal)` | 取值，null 時回傳預設值（Object） |

```java
// 取得渠道回應碼，預設為 "99"（未知錯誤）
String respCode = Utils.getMapValue(respMap, "respCode", "99");

// 取得逾時設定，預設 30 秒
String timeout = Utils.getMapValue(extConfig, "timeout", "30000");
int timeoutMs = Integer.parseInt(timeout);
```

###### `getFirstMapValue`

```java
public static Object getFirstMapValue(Map map, Object defaultVal, String... keys)
```

以多個可能的鍵值搜尋 Map，回傳第一個有值的內容。

```java
// 不同渠道使用不同的欄位名稱表示渠道代碼
String chnlId = (String) Utils.getFirstMapValue(respMap, "UNKNOWN",
    "channelId", "chnlId", "channel", "chnl_id");

// 不同渠道回傳的金額欄位名稱不同
String amount = (String) Utils.getFirstMapValue(respMap, "0",
    "txnAmt", "amount", "totalAmount", "orderAmt");
```

###### `getObjFromMaps` / `getStrFromMaps` / `getFromMaps`

```java
public static Object getObjFromMaps(String key, Map... maps)
public static String getStrFromMaps(String key, Map... maps)
public static <T> T getFromMaps(String key, Map... maps)
```

從多個 Map 中搜尋指定 key 的值。

```java
// 依優先順序從多個設定來源取得商戶金鑰
// 先找請求參數，再找商戶參數，最後找全域設定
String signKey = Utils.getStrFromMaps("signKey", reqParams, merParams, globalConfig);

// 從交易參數或渠道設定中取得通知 URL
String notifyUrl = Utils.getStrFromMaps("notifyUrl", txnParams, chnlConfig);
```

###### `getObjFromMap` / `getStrFromMap` / `getFromMap`

```java
public static Object getObjFromMap(Map map, String... keys)
public static String getStrFromMap(Map map, String... keys)
public static <T> T getFromMap(Map map, String... keys)
```

從單一 Map 中，以多個可能的 key 搜尋第一個有值的內容。

```java
// 從渠道回應 Map 中取得訂單號（不同渠道欄位名稱可能不同）
String orderId = Utils.getStrFromMap(respMap,
    "orderId", "order_id", "orderNo", "out_trade_no");

// 泛型版本
Integer retryCount = Utils.getFromMap(configMap, "retryCount", "retry_count");
```

###### `mergerMaps` 系列

| 簽名 | 說明 |
|------|------|
| `mergerMaps(Map... maps)` | 合併多個 Map，後者覆蓋前者 |
| `mergerMaps(boolean allowNullValue, Map... maps)` | 合併，可選是否允許空值 |
| `mergerMaps(Class<Map<K,V>> cls, Map<K,V>... maps)` | 合併，指定回傳 Map 類型 |
| `mergerObjMaps(Map<K,V>... maps)` | 泛型版本合併 |
| `mergerObjMaps(boolean allowNullValue, Map<K,V>... maps)` | 泛型版本合併，可控制空值 |
| `mergerMapsByKey(Map src, Map map, String... keys)` | 合併，僅覆蓋指定的鍵值 |

```java
// 合併基本參數與擴展參數（擴展參數覆蓋基本參數）
Map<String, String> baseParams = Utils.newMap("charset", "UTF-8", "version", "1.0");
Map<String, String> extParams = Utils.newMap("signType", "RSA2", "version", "2.0");
Map<String, String> merged = Utils.mergerMaps(baseParams, extParams);
// 結果: {charset=UTF-8, version=2.0, signType=RSA2}

// 合併時排除空值
Map<String, String> safeParams = Utils.mergerMaps(false, reqParams, chnlParams);

// 僅合併指定欄位
Utils.mergerMapsByKey(targetMap, sourceMap, "merId", "orderId", "txnAmt");
```

###### `putMap`

```java
public static Map<String, String> putMap(Map<String, String> res, Map target)
```

將 target Map 的內容放入 res Map。

```java
// 將渠道回應參數加入結果 Map
Map<String, String> result = new HashMap<>();
result.put("sysOrderId", sysOrderId);
Utils.putMap(result, channelRespMap);
```

###### `mergeList`

```java
public static List mergeList(Collection... lists)
```

合併多個 Collection 為一個 List。

```java
// 合併多個渠道的支援交易類型
List<String> chnlATypes = Utils.newList("PAY", "REFUND");
List<String> chnlBTypes = Utils.newList("PAY", "QUERY", "CLOSE");
List allTypes = Utils.mergeList(chnlATypes, chnlBTypes);
// 結果: ["PAY", "REFUND", "PAY", "QUERY", "CLOSE"]
```

###### `copyValueIfNotEmpty` / `copyValuesIfNotEmpty` / `copyValues`

```java
public static void copyValueIfNotEmpty(Map<String, String> src, Map<String, String> dest, String key)
public static Map<String, String> copyValuesIfNotEmpty(Map<String, String> src, Map<String, String> dest, String... keys)
public static void copyValues(Map<String, String> src, Map<String, String> dest, String... keys)
```

將來源 Map 指定鍵值複製到目標 Map。`IfNotEmpty` 版本僅複製非空值。

```java
// 從渠道回應中複製關鍵欄位到交易結果（僅非空值）
Map<String, String> txnResult = new HashMap<>();
Utils.copyValuesIfNotEmpty(channelResp, txnResult,
    "respCode", "respMsg", "chnlOrderId", "payTime");

// 複製必要欄位（包含空值）
Utils.copyValues(reqMap, logMap, "merId", "orderId", "txnAmt", "txnType");
```

###### `describeMapValues`

```java
public static String describeMapValues(Map<String, String> map, String... keys)
```

描述 Map 中指定鍵值的內容（排序後輸出）。

```java
// 產生交易參數描述，用於日誌記錄
String desc = Utils.describeMapValues(txnMap, "merId", "orderId", "txnAmt", "respCode");
log.info("交易參數: " + desc);
// 輸出範例: "merId=001M00012345, orderId=ORD20240315001, respCode=00, txnAmt=10000"
```

###### `removeEmpty` / `removeNull`

```java
public static <K, V> Map<K, V> removeEmpty(Map<K, V> map)
public static <K, V> Map<K, V> removeNull(Map<K, V> map)
```

移除 Map 中的空值或 null 值，遞歸處理巢狀 Map。保留原始 Map 類型（LinkedHashMap / TreeMap / HashMap）。

```java
// 組簽名前移除空值欄位，避免簽名錯誤
Map<String, String> signMap = Utils.removeEmpty(reqParams);
String signSrc = buildSignString(signMap);

// 移除 null 值後再序列化為 JSON
Map<String, Object> jsonMap = Utils.removeNull(responseMap);
String json = objectMapper.writeValueAsString(jsonMap);
```

###### `findInRegexMap`

```java
public static <T> T findInRegexMap(Map<String, T> map, String key)
```

Map 鍵值為正則表達式時，搜尋符合的鍵並回傳其值。

```java
// 依交易類型正則匹配路由規則
Map<String, String> routeMap = new LinkedHashMap<>();
routeMap.put("PAY.*",    "chnl_A");  // PAY 開頭的交易走渠道 A
routeMap.put("REFUND.*", "chnl_B");  // REFUND 開頭走渠道 B
routeMap.put(".*",       "chnl_C");  // 預設走渠道 C

String targetChnl = Utils.findInRegexMap(routeMap, "PAY_QUICK");
// 結果: "chnl_A"
```

###### `findInMapByPattern`

```java
public static <T> List<T> findInMapByPattern(Map<String, T> map, String keyPattern)
```

以正則表達式搜尋 Map 中所有符合條件的值。

```java
// 從設定 Map 中找出所有簽名相關的設定
Map<String, String> config = loadChnlConfig();
List<String> signConfigs = Utils.findInMapByPattern(config, "sign.*");
// 可能回傳 signType、signKey、signAlgorithm 等欄位的值
```

---

##### 方法 — 集合操作

###### `isInSet`

| 簽名 | 說明 |
|------|------|
| `isInSet(Object test, Object... items)` | 測試值是否在集合中 |
| `isInSet(String test, String... items)` | 字串版本 |
| `isInSet(Object test, Set items)` | Set 版本 |

```java
// 判斷交易類型是否為支援的類型
if (Utils.isInSet(txnType, "PAY", "REFUND", "QUERY")) {
    processTxn(txnType, reqMap);
}

// 判斷回應碼是否為成功碼
if (Utils.isInSet(respCode, "00", "0000", "SUCCESS")) {
    updateTxnStatus(orderId, "SUCCESS");
}
```

###### `isMatchInSet`

```java
public static boolean isMatchInSet(String test, String... items)
```

測試值是否在集合中，集合元素可為正則表達式。

```java
// 使用正則匹配判斷錯誤碼是否屬於可重試類型
if (Utils.isMatchInSet(respCode, "E001", "E002", "E1\\d{2}", "TIMEOUT.*")) {
    log.info("錯誤碼 {} 可重試", respCode);
    retryTransaction(reqMap);
}
```

###### `selectItem` / `selectFirst`

```java
public static String selectItem(String[] list, int index)
public static <T> T selectItem(List<T> list, int index)
public static <T> T selectFirst(List<T> list)
```

安全取得陣列或 List 中指定索引的元素，超出範圍回傳 null。

```java
// 安全解析渠道回傳的分隔符字串
String[] parts = Utils.strSplit(channelResp, "|");
String respCode = Utils.selectItem(parts, 0);  // 回應碼
String respMsg = Utils.selectItem(parts, 1);   // 回應訊息
String chnlOrderId = Utils.selectItem(parts, 2); // 可能為 null（不一定有）

// 取得路由結果中的第一個可用渠道
List<String> availableChannels = routeService.getChannels(merId, txnType);
String primaryChannel = Utils.selectFirst(availableChannels);
```

###### `unduplicate`

```java
public static <T> List<T> unduplicate(List<T> list)
```

去除 List 中的重複元素，保留原始順序。

```java
// 合併多個來源的商戶支援渠道清單後去重
List<String> allChannels = Utils.mergeList(dbChannels, configChannels);
List<String> uniqueChannels = Utils.unduplicate(allChannels);
```

###### `listToString`

```java
public static <T> String listToString(List<T> list, String splitor)
```

將 List 轉換為分隔符連接的字串。

```java
// 將支援的交易類型列表轉為逗號分隔字串，存入設定
List<String> types = Utils.newList("PAY", "REFUND", "QUERY");
String typesStr = Utils.listToString(types, ",");
// 結果: "PAY,REFUND,QUERY"
config.put("supportedTypes", typesStr);
```

---

##### 方法 — 網路工具

###### `getLocalIp` / `getLocalHostName` / `getLocalHostIp`

```java
public static String getLocalIp()
public static String getLocalHostName()
public static String getLocalHostIp()
```

獲取本機 IP 地址或主機名稱。

```java
// 在交易日誌中記錄處理節點資訊
String localIp = Utils.getLocalIp();
String hostName = Utils.getLocalHostName();
log.info("交易由節點 {}({}) 處理", hostName, localIp);
txnLog.put("serverIp", localIp);
```

###### `getIpAddr` / `getHostname`

```java
public static String getIpAddr(String host)
public static String getHostname(String ipAddr)
```

解析域名取得 IP 或反向查詢主機名。

```java
// 解析渠道 API 域名的實際 IP，用於連線診斷
String chnlHost = "api.channel.com";
String ip = Utils.getIpAddr(chnlHost);
log.info("渠道 API {} 解析到 IP: {}", chnlHost, ip);
```

###### `printHostIp`

```java
public static String printHostIp(String host)
public static String printHostIp(String host, String splitter)
```

回傳可列印的域名及 IP 地址。

```java
// 記錄渠道連線目標
String hostInfo = Utils.printHostIp("api.channel.com");
log.info("連線至: {}", hostInfo);
// 輸出範例: "api.channel.com/203.0.113.50"
```

###### `catchLocalIP` / `catchHostIp`

```java
public static InetAddress catchLocalIP() throws UnknownHostException
public static InetAddress catchHostIp(String hostname) throws UnknownHostException
```

獲取本地或遠端主機的 InetAddress，本地 IP 有 1 小時快取。

```java
// 取得本機 InetAddress 用於網路操作
InetAddress localAddr = Utils.catchLocalIP();
log.info("本機地址: {}", localAddr.getHostAddress());

// 取得渠道主機地址
InetAddress chnlAddr = Utils.catchHostIp("api.channel.com");
```

###### `getLocalHostLANAddress`

```java
public static InetAddress getLocalHostLANAddress() throws UnknownHostException
```

掃描所有網路介面，回傳最可能的 LAN IP 地址。優先回傳 site-local 地址（如 192.168.x.x）。

```java
// 取得 LAN IP 用於服務註冊
InetAddress lanAddr = Utils.getLocalHostLANAddress();
String lanIp = lanAddr.getHostAddress();
log.info("服務註冊 LAN IP: {}", lanIp);
```

###### `ping`

```java
public static boolean ping(String host, int timeout) throws Exception
```

Ping 主機，需要權限才能成功。

```java
// 健康檢查：確認渠道主機是否可達
boolean reachable = Utils.ping("api.channel.com", 5000);
if (!reachable) {
    log.error("渠道主機不可達");
}
```

###### `connectTest`

```java
public static long connectTest(String host, int port, int timeout)
```

TCP 連線測試，回傳實際連線耗時（毫秒），失敗回傳 -1。

```java
// 測試渠道 HTTPS 埠連線延遲
long latency = Utils.connectTest("api.channel.com", 443, 10000);
if (latency < 0) {
    log.error("無法連線渠道 API");
} else {
    log.info("渠道連線延遲: {}ms", latency);
}
```

###### `isIpv4Addr` / `isIpv4AddrList` / `containsIpv4Addr`

```java
public static boolean isIpv4Addr(String s)
public static boolean isIpv4AddrList(String s)
public static boolean containsIpv4Addr(String s)
```

IPv4 地址格式驗證。

```java
// 驗證商戶提供的白名單 IP 格式
String clientIp = req.get("clientIp");
if (!Utils.isIpv4Addr(clientIp)) {
    throw new BizzException("IP 格式不正確: " + clientIp);
}

// 驗證逗號分隔的 IP 白名單
String ipWhitelist = merConfig.get("ipWhitelist");
if (Utils.isIpv4AddrList(ipWhitelist)) {
    // "192.168.1.1,192.168.1.2" 格式正確
}
```

---

##### 方法 — 錯誤處理

###### `printErrorStackTrace`

```java
public static String printErrorStackTrace(Throwable err)
public static String printErrorStackTrace(Throwable err, String newLineStr, String tabStr)
```

將錯誤堆疊列印為字串。

```java
// 記錄交易異常的完整堆疊
try {
    processPayment(reqMap);
} catch (Exception e) {
    String stackTrace = Utils.printErrorStackTrace(e);
    log.error("交易處理異常: {}", stackTrace);
}

// 使用 HTML 格式列印堆疊（用於 Web 頁面顯示）
String htmlStack = Utils.printErrorStackTrace(e, "<br>", "&nbsp;&nbsp;");
```

###### `getStackTraceStr`

| 簽名 | 說明 |
|------|------|
| `getStackTraceStr(Throwable err)` | 獲取完整錯誤堆疊字串 |
| `getStackTraceStr(Throwable err, String lineSeprator)` | 指定分行符號 |
| `getStackTraceStr(Throwable err, int maxLength)` | 限制最大長度 |
| `getStackTraceStr(Throwable err, String lineSeprator, int maxLength)` | 指定分行符號與最大長度 |

```java
// 記錄截斷的堆疊資訊到資料庫（欄位長度有限制）
try {
    callChannelApi(reqBody);
} catch (Exception e) {
    // 限制堆疊字串最大 500 字元，存入交易日誌
    String shortStack = Utils.getStackTraceStr(e, 500);
    txnLog.put("errorDetail", shortStack);
}
```

###### `errorToResp`

```java
public static void errorToResp(Exception err, Map<String, String> resp)
```

將例外轉換到回應 Map（支援 ChnlBizException / BizzException）。

```java
// 統一錯誤處理：將例外轉為標準回應格式
Map<String, String> resp = new HashMap<>();
try {
    Map<String, String> result = channelService.pay(reqMap);
    resp.putAll(result);
} catch (Exception e) {
    Utils.errorToResp(e, resp);
    // resp 中將包含 respCode 和 respMsg
}
return resp;
```

---

##### 方法 — Log4j MDC/NDC

###### `logRequests` / `logResult`

```java
public static void logRequests(Map... maps)
public static void logResult(Map... maps)
```

將 Map 合併後加入 Log4j MDC（key 分別為 `"request"` / `"result"`）。

```java
// 記錄交易請求與回應到 MDC，便於日誌追蹤
Utils.logRequests(reqMap, extParams);  // 合併多個 Map 記錄請求

// 處理完成後記錄結果
Utils.logResult(respMap);
log.info("交易完成");  // 此行日誌將自動帶上 request 和 result 的 MDC 資訊
```

###### `logAttribute`

```java
public static void logAttribute(String key, Object val)
public static void logAttribute(String key, Object val, boolean overwrite)
```

將屬性加入 Log4j MDC。

```java
// 在 MDC 中加入交易追蹤資訊
Utils.logAttribute("merId", merId);
Utils.logAttribute("orderId", orderId);
Utils.logAttribute("txnType", txnType);

// 強制覆蓋已有的 MDC 值
Utils.logAttribute("status", "PROCESSING", true);
```

###### `logTimeStamp`

```java
public static void logTimeStamp(Long time)
public static void logTimeStamp(Date time)
```

記錄時間戳到 MDC。

```java
// 記錄交易開始時間
Utils.logTimeStamp(System.currentTimeMillis());

// 使用 Date 物件記錄
Utils.logTimeStamp(new Date());
```

###### `logPushNested` / `logPopNested`

```java
public static String logPushNested(String format, Object... args)
public static String logPopNested()
```

操作 Log4j NDC（巢狀診斷上下文）。

```java
// 使用 NDC 追蹤交易處理階段
Utils.logPushNested("PAY-%s-%s", merId, orderId);
try {
    log.info("開始處理支付");       // NDC: "PAY-001M00012345-ORD001"
    Utils.logPushNested("SIGN");
    log.info("執行簽名");           // NDC: "PAY-001M00012345-ORD001 SIGN"
    Utils.logPopNested();
    log.info("簽名完成，發送請求"); // NDC: "PAY-001M00012345-ORD001"
} finally {
    Utils.logPopNested();
}
```

###### `logRemove` / `logClearAttributes` / `logRemoveReqAndResult`

```java
public static void logRemove(String key)
public static void logClearAttributes()
public static void logRemoveReqAndResult()
```

清除 MDC 屬性。

```java
// 交易處理完畢，清除 MDC
try {
    processTransaction(reqMap);
} finally {
    // 僅清除 request 和 result
    Utils.logRemoveReqAndResult();

    // 或清除所有 MDC 屬性
    Utils.logClearAttributes();
}

// 移除特定 MDC 鍵值
Utils.logRemove("sessionId");
```

---

##### 方法 — 日期時間

###### `getTimeStamp`

```java
public static String getTimeStamp()
```

回傳目前時間的格式化字串（yyyyMMddHHmmss）。

```java
// 產生交易時間戳
String txnTime = Utils.getTimeStamp();
reqMap.put("txnTime", txnTime);
// 範例輸出: "20240315143025"
```

###### `isDateTimeEqual`

```java
public static boolean isDateTimeEqual(Date test, Date target, int errorBefore, int errorAfter)
```

模糊判斷時間是否相同，允許前後誤差（秒）。

```java
// 驗證渠道回傳的交易時間與本地記錄是否一致（允許前後 60 秒誤差）
Date localTxnTime = txnRecord.getCreateTime();
Date chnlTxnTime = parseDate(resp.get("txnTime"));
if (!Utils.isDateTimeEqual(chnlTxnTime, localTxnTime, 60, 60)) {
    log.warn("交易時間不一致，本地={}, 渠道={}", localTxnTime, chnlTxnTime);
}
```

###### `isDateTimeEqualNow`

```java
public static boolean isDateTimeEqualNow(Date test, int error)
public static boolean isDateTimeEqualNow(String strDateTime, int error) throws ParseException
```

模糊判斷指定時間是否等於現在，誤差前後分配為 75%/25%。

```java
// 驗證渠道回傳的時間戳是否為當前時間（允許 300 秒誤差）
// 75% 的誤差分配給「過去」，25% 分配給「未來」
String chnlTime = resp.get("timestamp"); // "20240315143025"
if (!Utils.isDateTimeEqualNow(chnlTime, 300)) {
    throw new BizzException("渠道回應時間戳超出允許範圍，可能為重放攻擊");
}
```

###### `isTimeEqualNow`

```java
public static boolean isTimeEqualNow(String strTime, int error) throws ParseException
```

模糊判斷時間（HHmmss 格式）是否等於現在時間。

```java
// 驗證通知回呼中的時間欄位
String notifyTime = notify.get("time"); // "143025"
if (!Utils.isTimeEqualNow(notifyTime, 600)) {
    log.warn("通知時間與當前時間差距過大");
}
```

---

##### 方法 — 其他工具

###### `iif`

```java
public static <T> T iif(boolean condition, T trueVal, T falseVal)
```

三元運算的工具方法。

```java
// 根據交易結果設定狀態碼
String status = Utils.iif("00".equals(respCode), "SUCCESS", "FAIL");

// 選擇正式或測試環境 URL
String apiUrl = Utils.iif(Utils.isTrue(merParams.get("isTest")),
    "https://test-api.channel.com/pay",
    "https://api.channel.com/pay");
```

###### `getFirstAvailable`

```java
public static <T> T getFirstAvailable(T... objs)
```

回傳第一個非 null 的物件。

```java
// 依優先順序取得可用的商戶金鑰
String signKey = Utils.getFirstAvailable(
    merParams.get("rsaPrivateKey"),   // 優先使用 RSA 金鑰
    merParams.get("md5Key"),          // 其次 MD5 金鑰
    globalConfig.get("defaultKey")    // 最後使用預設金鑰
);
```

###### `getHashCode`

```java
public static int getHashCode(Object val, int hashCount)
public static int getHashCode(Object val, int hashMin, int hashMax)
```

取得 hash code，限制在指定範圍內。

```java
// 根據商戶號 hash 分配到 10 個處理佇列中的一個
int queueIndex = Utils.getHashCode(merId, 10);
messageQueue.send("txn_queue_" + queueIndex, txnMsg);

// 根據訂單號 hash 分配到指定範圍的分表
int tableIndex = Utils.getHashCode(orderId, 0, 16);
String tableName = "t_txn_log_" + tableIndex;
```

###### `getLimitValue`

```java
public static Integer getLimitValue(Integer val, Integer min, Integer max, Integer defaultVal)
public static Long getLimitValue(Long val, Long min, Long max, Long defaultVal)
public static Float getLimitValue(Float val, Float min, Float max, Float defaultVal)
public static Double getLimitValue(Double val, Double min, Double max, Double defaultVal)
```

限制數值在指定範圍內，null 時回傳預設值。

```java
// 限制查詢筆數在 1~100 之間，預設 20
Integer pageSize = Converter.toInteger(req.get("pageSize"));
pageSize = Utils.getLimitValue(pageSize, 1, 100, 20);

// 限制重試次數
Integer retryCount = Converter.toInteger(config.get("retryCount"));
retryCount = Utils.getLimitValue(retryCount, 0, 5, 3);

// 限制逾時時間（毫秒）
Long timeout = Converter.toLong(merParams.get("timeout"));
timeout = Utils.getLimitValue(timeout, 3000L, 60000L, 30000L);
```

###### `sleep`

```java
public static void sleep(long millis)
```

執行緒休眠，自動處理 InterruptedException。

```java
// 交易重試前等待
for (int i = 0; i < maxRetry; i++) {
    try {
        return callChannelApi(reqBody);
    } catch (Exception e) {
        log.warn("第 {} 次呼叫失敗，等待後重試", i + 1);
        Utils.sleep(2000);  // 等待 2 秒後重試
    }
}
```

#### Protected 部分

##### 常數

| 常數 | 型別 | 說明 |
|------|------|------|
| `regexOptions` | `int` | 正則選項，包含 CASE_INSENSITIVE、UNICODE_CHARACTER_CLASS、UNICODE_CASE、DOTALL |
