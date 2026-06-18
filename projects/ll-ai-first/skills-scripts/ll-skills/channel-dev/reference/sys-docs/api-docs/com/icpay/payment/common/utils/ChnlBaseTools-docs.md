# ChnlBaseTools

類別名稱：`com.icpay.payment.common.utils.ChnlBaseTools`

## 說明

`ChnlBaseTools` 是渠道基礎工具類，為整個支付渠道服務體系的根基類別。此類別提供了渠道服務開發中常用的基礎功能，包括：

- **JSON/Map 轉換**：JSON 字串、JSONObject、Map 之間的相互轉換
- **金額轉換**：本地金額與渠道金額之間的單位轉換與格式化
- **參數配置讀取**：透過 `getMerParam` / `getMerSecParam` 讀取商戶級別的參數配置（支援萬用字符匹配）
- **HTTP 請求代理**：透過轉發服務發起 HTTP POST/GET 請求
- **FreeMarker 模板處理**：模板載入、上下文建構與模板轉換
- **值檢查斷言**：assertNotEmpty、assertEqual、assertInSet 等檢查工具
- **日誌工具**：傳統模式（debug/info/warn/error）與新模式（ILog 鏈式）
- **時間工具**：取得當前時間及格式化
- **響應碼轉換**：透過 `tbl_chnl_translate` 表格進行渠道響應碼至系統響應碼的轉換
- **收銀台 URL 組裝**：產生收銀台頁面跳轉 URL

在 FreeMarker 模板中，此類別（或其子類別）的實例以 `svc` 變數存取。

## 架構

### Package

`com.icpay.payment.common.utils`

### 繼承關係

```
ChnlBaseTools （本類別，渠道基礎工具類）
├── ChnlServiceBase （交易服務抽象基類）
│   └── ChnlServiceWithCasherBase （含收銀台的交易服務）
│       ├── MyChnlBase → MyChnlBaseV2 （配置驅動 V3 模式）
│       │   ├── PayV3Mode1 / PayV3Mode2 / PayV3Mode3
│       │   └── PayV2Mode1 / PayV2Mode2
│       └── MyChnlBaseV5 （配置驅動 V5 模式）
│           └── PayV5Mode1
├── ChnlEncryptionServiceBase （加密服務基類）
└── ChnlSignatureServiceBase （簽名服務基類）
```

### 主要相依性

| 相依類別 | 說明 |
|---------|------|
| `com.alibaba.fastjson.JSON` / `JSONObject` | JSON 解析與序列化 |
| `com.icpay.payment.common.constants.RspCd` | 響應碼常數 |
| `com.icpay.payment.common.enums.CurrencyEnums.CurrType` | 幣別列舉 |
| `com.icpay.payment.common.exception.ChnlBizException` | 渠道業務異常 |
| `com.icpay.payment.common.utils.logger.Log` / `CriticalLog` / `ILog` | 日誌框架 |
| `com.icpay.payment.service.HttpProxyHelper` | HTTP 轉發服務 |
| `com.icpay.payment.service.MerParams` | 商戶參數查詢服務 |
| `com.icpay.payment.service.StoredHtmlUtil` | HTML 儲存工具 |
| `com.icpay.payment.service.api.HttpClientResponse` | HTTP 回應封裝 |
| `com.icpay.payment.service.cache.TxnChnlTranslateCache` | 渠道響應碼轉換快取 |
| `freemarker.template.Template` | FreeMarker 模板引擎 |
| `com.icpay.payment.common.utils.FreeMarkerDbTemplate` | FreeMarker 模板配置（DB 儲存） |
| `com.icpay.payment.common.utils.Amount` | 金額工具類 |
| `com.icpay.payment.common.utils.Utils` | 公用工具類 |
| `com.icpay.payment.common.utils.EncryptUtil` | 加密工具類 |
| `com.icpay.payment.common.utils.RandomUtils` | 隨機數工具類 |
| `com.icpay.payment.common.utils.Converter` | 轉換工具類 |

---

## API 說明

### Class: ChnlBaseTools

#### Public 部分

##### 常數

| 常數名稱 | 型別 | 值 | 說明 |
|---------|------|-----|------|
| `DEFAULT_ENCODING` | `String` | `"UTF-8"` | 預設字元編碼 |
| `DEFAULT_MER` | `String` | `"#DEFAULT#"` | 預設商戶號（萬用字符） |
| `ALLOWED_ERROR` | `BigDecimal` | `0.01` | 數值比較時的預設允許誤差 |
| `JSON_PARSER_FEATURES` | `Feature[]` | （見下方） | JSON 解析器特性配置陣列，包含 `InternFieldNames`、`UseBigDecimal`、`AllowUnQuotedFieldNames`、`AllowSingleQuotes`、`AllowArbitraryCommas`、`OrderedField`、`IgnoreNotMatch`、`AutoCloseSource` |

##### 內部類別：CATALOG

參數配置分類常數類別，用於 `getMerParam` 等方法的 `catalog` 參數。

| 常數名稱 | 型別 | 值 | 說明 |
|---------|------|-----|------|
| `SEC` | `String` | `"SEC"` | 機敏分類（敏感參數） |
| `URL` | `String` | `"URL"` | 網址類 |
| `IDS` | `String` | `"IDS"` | 識別碼類 |
| `TXNTYPE` | `String` | `"TXNTYPE"` | 交易分類 |
| `PARAM` | `String` | `"PARAM"` | 其它一般參數 |

##### 建構式

###### `ChnlBaseTools()`

預設建構式。

---

##### 方法

###### Parent / Memory 管理

---

**`setParent(ChnlBaseTools parent)`**

設定 Parent，並將 Parent 的 Memory 設定為自己的 Memory（即與 Parent 共用 Memory），同時繼承 Parent 的 `channel`、`intTxnType`、`chnlMerId`。若 parent 是自己則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `parent` | `ChnlBaseTools` | 父實例 |

使用範例：

```java
// 簽名服務繼承父服務的渠道資訊與暫存記憶體
ChnlSignatureServiceBase signService = new MySignService();
signService.setParent(this); // this 為 ChnlServiceBase 子類實例
// signService 現在與父服務共用 memory、channel、intTxnType、chnlMerId
```

---

**`getParent()`**

回傳目前設定的 Parent 實例。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `ChnlBaseTools` | Parent 實例，可能為 null |

---

**`setMemory(Map<String, Object> memory)`**

設定暫存記憶體 Map，用來存放處理過程中的資料。可由 Parent 設定。

| 參數 | 型別 | 說明 |
|------|------|------|
| `memory` | `Map<String, Object>` | 暫存 Map |

---

**`getMemory()`**

取得暫存記憶體 Map。若尚未初始化，會自動建立空的 `HashMap`。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map<String, Object>` | 暫存 Map |

---

**`clearMemory()`**

清除記憶體中的所有資料。

使用範例：

```java
// 在交易處理完成後清除暫存資料
svc.assign("signData", signResult);
svc.assign("respBody", responseBody);
// ... 處理完畢
svc.clearMemory(); // 清除所有暫存
```

---

**`assign(String key, Object val)`**

存放某個值到暫存記憶中。在 FreeMarker 模板中可透過 `mem.鍵名` 取得。

| 參數 | 型別 | 說明 |
|------|------|------|
| `key` | `String` | 鍵名 |
| `val` | `Object` | 值 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.assign("orderId", ctx.orderId)}
<#-- 之後可透過 mem.orderId 取得 -->
${mem.orderId}
```

---

**`retrieve(String key)`**

取得暫存記憶中的值。若不存在則回傳 `null`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `key` | `String` | 鍵名 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Object` | 暫存的值，若不存在則為 null |

---

**`retrieve(String key, Object defVal)`**

取得暫存記憶中的值。若不存在則回傳預設值 `defVal`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `key` | `String` | 鍵名 |
| `defVal` | `Object` | 預設值 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Object` | 暫存的值，若不存在則為 defVal |

使用範例：

```java
// 在交易服務中暫存中間結果，供後續步驟使用
svc.assign("chnlOrderNo", "20230411154245872772");
svc.assign("txnAmt", "10000");

// 取得暫存值
String orderNo = (String) svc.retrieve("chnlOrderNo");        // 輸出: "20230411154245872772"
String notExist = (String) svc.retrieve("notExistKey");        // 輸出: null
String withDef  = (String) svc.retrieve("notExistKey", "N/A"); // 輸出: "N/A"
```

```freemarker
<#-- 在 FreeMarker 模板中，先用 assign 暫存，之後用 mem 取得 -->
${svc.assign("originalAmt", ctx.txnAmt)}
<#-- 後續模板可直接使用 mem.originalAmt -->
"original_amount": "${mem.originalAmt}"
```

---

###### 屬性 Getter/Setter

---

**`getChannel()` / `setChannel(String channel)`**

取得/設定渠道編號。

---

**`getIntTxnType()` / `setIntTxnType(String intTxnType)`**

取得/設定交易類型。

---

**`getChnlMerId()` / `setChnlMerId(String chnlMerId)`**

取得/設定渠道商戶號。

---

**`getEncoding()` / `setEncoding(String encoding)`**

取得/設定字元編碼。預設為 `"UTF-8"`。

---

**`getChnlAmtUnit()` / `setChnlAmtUnit(BigDecimal chnlAmtUnit)`**

取得/設定渠道金額單位。預設為 `1.00`（元）。

---

**`setChnlAmtUnitStr(String chnlAmtUnit)`**

以字串設定渠道金額單位。

| 參數 | 型別 | 說明 |
|------|------|------|
| `chnlAmtUnit` | `String` | 金額單位字串，例如 `"0.01"` 表示分 |

使用範例：

```java
// 渠道以「分」為單位時的配置
svc.setChnlAmtUnitStr("0.01");
// 本地金額 100 元 → 渠道金額 10000 分
String chnlAmt = svc.toChnlAmt("100"); // 輸出: "10000"

// 渠道以「元」為單位（預設）
svc.setChnlAmtUnitStr("1.00");
String chnlAmt2 = svc.toChnlAmt("100"); // 輸出: "100"
```

---

**`getChnlAmtFormat()` / `setChnlAmtFormat(String chnlAmtFormat)`**

取得/設定渠道金額格式。設定後會自動建立對應的 `DecimalFormat` 格式化器。

| 參數 | 型別 | 說明 |
|------|------|------|
| `chnlAmtFormat` | `String` | 金額格式，例如 `"0.00"`, `"#,##0.00"` |

使用範例：

```java
// 渠道要求金額固定兩位小數
svc.setChnlAmtFormat("0.00");
svc.setChnlAmtUnitStr("1.00");
String chnlAmt = svc.toChnlAmt("100"); // 輸出: "100.00"
```

---

**`getLocalAmtFormat()` / `setLocalAmtFormat(String localAmtFormat)`**

取得/設定本地金額格式。預設為 `"#"`。

---

**`getCurrency()` / `setCurrency(CurrType currency)`**

取得/設定交易幣別。

---

**`setCurrencyByCode(String currencyCode)`**

以幣別代碼設定交易幣別。若代碼無效則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `currencyCode` | `String` | 幣別代碼 |

---

**`getStage()` / `setStage(TxnInteractiveStage stage)` / `setStage(String stageName)`**

取得/設定交易互動階段（`TxnInteractiveStage`）。可透過列舉值或字串名稱設定。

---

###### JSON/Map 轉換

---

**`toJson(HttpClientResponse resp)`**

將 HTTP 回應轉換成 JSON。若 HTTP 狀態碼非 2xx 開頭則拋出 `IOException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `resp` | `HttpClientResponse` | HTTP 回應物件 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `JSONObject` | JSON 物件 |

| 拋出 | 說明 |
|------|------|
| `IOException` | HTTP 狀態碼非 2xx 時 |

使用範例：

```java
// 發送 HTTP 請求後，將回應轉為 JSON
HttpClientResponse resp = httpProxy(chnlMerId).url(apiUrl).headers(header).post(postData);
JSONObject json = toJson(resp); // 若 HTTP 狀態碼非 2xx 則拋出 IOException
String code = json.getString("code");
```

---

**`toJson(String str)`**

將 JSON 字串轉換成 JSON 物件。若字串為空值則回傳 null。

| 參數 | 型別 | 說明 |
|------|------|------|
| `str` | `String` | JSON 字串 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `JSONObject` | JSON 物件，若輸入為空則為 null |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign respJson = svc.toJson(respBody)>
${respJson.code}
```

---

**`toJson(Object obj)`**

將物件（如 Map）轉換成 JSON 物件。若輸入為 null 則回傳 null。

| 參數 | 型別 | 說明 |
|------|------|------|
| `obj` | `Object` | 待轉換的物件 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `JSONObject` | JSON 物件 |

使用範例：

```java
// 將 Map 轉換成 JSONObject
Map<String, String> params = new HashMap<>();
params.put("mchntCd", "M100001");
params.put("orderNo", "ORD20230411001");
JSONObject json = svc.toJson(params);
String mchntCd = json.getString("mchntCd"); // 輸出: "M100001"
```

---

**`toJsonStr(Object obj)`**

將物件轉換成 JSON 字串。若輸入為 null 則回傳 null。

| 參數 | 型別 | 說明 |
|------|------|------|
| `obj` | `Object` | 待轉換的物件 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | JSON 字串 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign jsonStr = svc.toJsonStr(ctx)>
${jsonStr}
```

---

**`toMap(JSONObject json)`**

將 JSON 物件轉換成 `LinkedHashMap`（保持欄位順序）。

| 參數 | 型別 | 說明 |
|------|------|------|
| `json` | `JSONObject` | JSON 物件 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map` | LinkedHashMap |

使用範例：

```java
// 將 JSONObject 轉換成 Map 以便後續操作
JSONObject json = svc.toJson("{\"code\":200,\"msg\":\"ok\"}");
Map map = svc.toMap(json);
String code = map.get("code").toString(); // 輸出: "200"
```

---

**`toMap(String jsonStr)`**

將 JSON 字串轉換成 Map。內部使用 `toMapV2` 實作，支援寬鬆的 JSON 解析（允許單引號、無引號欄位名等）。若字串為空則回傳空的 `LinkedHashMap`。若解析失敗則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `jsonStr` | `String` | JSON 字串 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map` | 轉換後的 Map |

使用範例：

```java
// 支援寬鬆的 JSON 格式（允許單引號、無引號欄位名等）
String looseJson = "{code:200, 'msg':'ok', \"data\":{amount:'100'}}";
Map map = svc.toMap(looseJson);
// map = {code=200, msg=ok, data={amount=100}}
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign map = svc.toMap(respBody)>
${map.orderId}
```

---

**`toMap(Object obj)`**

將任意物件轉換成 Map。支援 Map、JSONObject、String 型別的輸入。若無法轉換則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `obj` | `Object` | 待轉換的物件 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map` | 轉換後的 Map |

---

**`tryParseJsonToMap(String jsonStr)`**

嘗試將 JSON 字串轉換成 Map。若轉換失敗則回傳 null（不拋出異常）。

| 參數 | 型別 | 說明 |
|------|------|------|
| `jsonStr` | `String` | JSON 字串 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map` | 轉換後的 Map，失敗則為 null |

使用範例：

```java
// 嘗試解析渠道回應，不確定是否為合法 JSON
String respBody = getResponseBody();
Map map = svc.tryParseJsonToMap(respBody);
if (map != null) {
    String code = svc.toStr(map.get("code"));
} else {
    // 回應不是 JSON 格式，嘗試其他解析方式
}
```

---

###### 字串/數值轉換

---

**`toStr(Object obj, String defVal)`**

將物件安全地轉換成字串。若物件為 null 則回傳預設值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `obj` | `Object` | 待轉換物件 |
| `defVal` | `String` | 預設值 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 字串或預設值 |

使用範例：

```java
// 安全地從 Map 取值並轉為字串
Map respMap = svc.toMap(respBody);
String code = svc.toStr(respMap.get("code"), "");          // 若 key 不存在則回傳 ""
String amount = svc.toStr(respMap.get("amount"), "0");     // 若 key 不存在則回傳 "0"
String nullVal = svc.toStr(null, "default");               // 輸出: "default"

// 不帶預設值的版本
String orderNo = svc.toStr(respMap.get("orderNo"));        // 若 key 不存在則回傳 null
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
"order_no": "${svc.toStr(ctx.orderNo, "")}"
```

---

**`toStr(Object obj)`**

將物件安全地轉換成字串。若物件為 null 則回傳 null。

---

**`toNumStr(Object obj, String fmt, String defVal)`**

將數值類型的物件安全地轉換成格式化字串。捨入模式為無條件捨去（`RoundingMode.DOWN`）。

| 參數 | 型別 | 說明 |
|------|------|------|
| `obj` | `Object` | 數值物件（可為 `String`、`Number`） |
| `fmt` | `String` | 格式，例如 `"#,##0.00"`, `"0.##"`, `"0.00"`, `"0"` |
| `defVal` | `String` | 預設值，若物件為 null 則回傳 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 格式化後的字串 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.toNumStr(ctx.txnAmt, "0.00", "0.00")}
```

---

**`toNumStr(Object obj, String fmt)`**

將數值類型的物件安全地轉換成格式化字串。預設值為 null。

使用範例：

```java
// toNumStr 各種格式化用法（捨入模式為無條件捨去 RoundingMode.DOWN）
svc.toNumStr("123.50", "0.00");      // 輸出: "123.50"
svc.toNumStr("123.50", "0.0#");      // 輸出: "123.5"
svc.toNumStr("123.55", "0.0");       // 輸出: "123.5"（無條件捨去）
svc.toNumStr(123.55, "0.0");         // 輸出: "123.5"
svc.toNumStr(123456.555, "#,##0.00");// 輸出: "123,456.55"
svc.toNumStr("0", "0.00");           // 輸出: "0.00"
svc.toNumStr(null, "0.00", "0.00");  // 輸出: "0.00"（使用預設值）
svc.toNumStr(null, "0.00");          // 輸出: null（無預設值）
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 將交易金額格式化為固定兩位小數 -->
"amount": "${svc.toNumStr(ctx.txnAmt, "0.00", "0.00")}"
<#-- 將手續費格式化為帶千分位 -->
"fee": "${svc.toNumStr(ctx.fee, "#,##0.00", "0.00")}"
```

---

**`toBigDecimal(Object a)`**

將物件轉換成 `BigDecimal`。支援 `BigDecimal` 及任意可透過 `toString()` 轉為數字的物件。

| 參數 | 型別 | 說明 |
|------|------|------|
| `a` | `Object` | 待轉換物件 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `BigDecimal` | 轉換結果，輸入為 null 則回傳 null |

使用範例：

```java
// 支援多種輸入型別
BigDecimal a = svc.toBigDecimal("100.50");  // 字串轉 BigDecimal
BigDecimal b = svc.toBigDecimal(100.50);    // double 轉 BigDecimal
BigDecimal c = svc.toBigDecimal(100);       // int 轉 BigDecimal
BigDecimal d = svc.toBigDecimal(null);      // 輸出: null
```

---

###### 巢狀路徑取值

---

**`getNestedValue(JSONObject jsonObject, String path)`**

從 JSON 物件中取得巢狀路徑的值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `jsonObject` | `JSONObject` | JSON 物件 |
| `path` | `String` | 路徑，以 `.` 分隔，例如 `"data.result.code"` |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Object` | 路徑對應的值，若路徑無效則為 null |

使用範例：

```java
// 從巢狀 JSON 中取得深層欄位值
String jsonStr = "{\"code\":200,\"resp\":{\"data\":{\"order_no\":\"ORD001\",\"amount\":\"100\"},\"sign\":\"abc123\"}}";
Map map = svc.toMap(jsonStr);

// 取得一層欄位
String code = svc.getNestedString(map, "code");             // 輸出: "200"
// 取得二層巢狀欄位
String sign = svc.getNestedString(map, "resp.sign");         // 輸出: "abc123"
// 取得三層巢狀欄位
String orderNo = svc.getNestedString(map, "resp.data.order_no"); // 輸出: "ORD001"
// 路徑無效時回傳 null
Object invalid = svc.getNestedValue(map, "resp.notExist");   // 輸出: null
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign code = svc.getNestedString(respJson, "data.result.code")>
<#assign orderNo = svc.getNestedString(respMap, "resp.data.order_no")>
```

---

**`getNestedString(JSONObject jsonObject, String path)`**

從 JSON 物件中取得巢狀路徑的字串值。內部呼叫 `getNestedValue` 並透過 `toStr` 轉換。

---

**`getNestedValue(Map jsonObject, String path)`**

從 Map 物件中取得巢狀路徑的值。與 JSONObject 版本功能相同，但接受 Map 型別輸入。

---

**`getNestedString(Map jsonObject, String path)`**

從 Map 物件中取得巢狀路徑的字串值。

---

**`removeMapKey(Map<String, ?> map, String keyPath)`**

從 Map 中移除指定路徑的 key。支援以 `.` 分隔的巢狀路徑。

| 參數 | 型別 | 說明 |
|------|------|------|
| `map` | `Map<String, ?>` | 要處理的 Map |
| `keyPath` | `String` | 鍵路徑，用 `.` 分隔 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `boolean` | 是否成功移除 |

使用範例：

```java
// 移除巢狀 Map 中的簽名欄位（驗簽前需移除 sign 欄位）
String jsonStr = "{\"code\":200,\"resp\":{\"data\":{\"order_no\":\"ORD001\",\"sign\":\"abc\"},\"sign\":\"xyz\"}}";
Map map = svc.toMap(jsonStr);

boolean r1 = svc.removeMapKey(map, "resp.data.sign"); // true，移除 resp.data.sign
boolean r2 = svc.removeMapKey(map, "resp.sign");       // true，移除 resp.sign
boolean r3 = svc.removeMapKey(map, "notExist.key");    // false，路徑不存在
// map = {code=200, resp={data={order_no=ORD001}}}
```

---

###### 名稱處理

---

**`getRightName(String fullName)`**

取得全名的簡稱（去掉前面的路徑），例如：`"resp.data.sign"` 回傳 `"sign"`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fullName` | `String` | 完整名稱 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 最右邊一層的名稱 |

使用範例：

```java
// 取得類別簡稱
svc.getRightName("com.icpay.payment.service.IcpaySecExchangeService");
// 輸出: "IcpaySecExchangeService"

// 取得 JSON 路徑最後一層
svc.getRightName("resp.data.sign");  // 輸出: "sign"
svc.getRightName("aaa");             // 輸出: "aaa"（無 . 分隔則原樣回傳）
svc.getRightName(null);              // 輸出: ""
```

---

**`getRightName(String fullName, int deepth)`**

取得全名的簡稱，可指定保留深度。例如 `deepth=2` 時，`"a.b.c.d"` 回傳 `"c.d"`；`deepth=0` 回傳完整名稱。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fullName` | `String` | 完整名稱 |
| `deepth` | `int` | 保留的層級深度，0 表示完整名稱 |

使用範例：

```java
String cls = "com.icpay.payment.service.IcpaySecExchangeService";
svc.getRightName(cls, 1); // 輸出: "IcpaySecExchangeService"
svc.getRightName(cls, 2); // 輸出: "service.IcpaySecExchangeService"
svc.getRightName(cls, 3); // 輸出: "payment.service.IcpaySecExchangeService"
svc.getRightName(cls, 0); // 輸出: "com.icpay.payment.service.IcpaySecExchangeService"（完整名稱）
```

---

###### Map 操作工具

---

**`mergeMaps(Map... maps)`**

將多個 Map 合併。後面 Map 的值會覆蓋前面 Map 的值。此方法允許空值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `maps` | `Map...` | 待合併的 Maps |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map<String,String>` | 合併後的 Map |

使用範例：

```java
// 合併多個參數 Map，後者覆蓋前者
Map<String, String> baseParams = Utils.newMap("merId", "M001", "channel", "AX");
Map<String, String> txnParams  = Utils.newMap("txnAmt", "100", "channel", "BX");
Map<String, String> merged = svc.mergeMaps(baseParams, txnParams);
// merged = {merId=M001, channel=BX, txnAmt=100}（channel 被後者覆蓋）
```

---

**`mergeMaps(boolean allowNullValue, Map... maps)`**

將多個 Map 合併，可控制是否允許空值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `allowNullValue` | `boolean` | 是否允許空值 |
| `maps` | `Map...` | 待合併的 Maps |

使用範例：

```java
// 不允許空值：null 值的 key 不會被加入
Map<String, String> params = Utils.newMap("key1", "val1");
Map<String, String> extra  = Utils.newMap("key2", null, "key3", "val3");
Map<String, String> merged = svc.mergeMaps(false, params, extra);
// merged = {key1=val1, key3=val3}（key2 的 null 值被過濾）
```

---

**`mergeObjMaps(Map... maps)`**

將多個 Map 合併（Object 值版本）。允許空值。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map<String,Object>` | 合併後的 Map |

---

**`mergeObjMaps(boolean allowNullValue, Map... maps)`**

將多個 Map 合併（Object 值版本），可控制是否允許空值。

---

**`getNotEmpty(Object... vals)`**

取得第一個非空值的內容。若全部為空則回傳空字串。

| 參數 | 型別 | 說明 |
|------|------|------|
| `vals` | `Object...` | 待檢查的值 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 第一個非空值的字串 |

使用範例：

```java
// 依優先順序取得非空值
String name = svc.getNotEmpty(null, "", "M100001");     // 輸出: "M100001"（前兩個為空）
String name2 = svc.getNotEmpty("Alice", "", "default"); // 輸出: "Alice"（第一個非空）
String name3 = svc.getNotEmpty(null, null);             // 輸出: ""（全部為空）
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 依優先順序取得商戶名稱 -->
${svc.getNotEmpty(ctx.merchantName, ctx.merId, "UNKNOWN")}
```

---

**`getObjFromMaps(String key, Map... maps)`**

由數個 Map 中依序取得指定 key 的值（Object）。回傳第一個找到的值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `key` | `String` | 鍵值 |
| `maps` | `Map...` | 包含內容的 Maps |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Object` | 找到的值，若都無則為 null |

---

**`getFromMaps(String key, Map... maps)`**

由數個 Map 中依序取得指定 key 的字串值。回傳第一個找到的值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `key` | `String` | 鍵值 |
| `maps` | `Map...` | 包含內容的 Maps |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 找到的字串值 |

使用範例：

```java
String txnType = getFromMaps("intTxnType", req, params, exParams);
```

---

**`getFirstMapObject(Map map, Object defaultVal, String... keys)`**

以數個可能的鍵值尋找 Map 中的值。若無法取得則回傳預設值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `map` | `Map` | 來源 Map |
| `defaultVal` | `Object` | 預設值 |
| `keys` | `String...` | 可能的鍵值 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Object` | 找到的值或預設值 |

使用範例：

```java
String chnlId = toStr(getFirstMapObject(map, null, "channel", "chnlId", "channelId"));
```

---

**`getFirstMapValue(Map map, String defaultVal, String... keys)`**

以數個可能的鍵值尋找 Map 中的字串值。若無法取得則回傳預設值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `map` | `Map` | 來源 Map |
| `defaultVal` | `String` | 預設值 |
| `keys` | `String...` | 可能的鍵值 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 找到的字串值或預設值 |

使用範例：

```java
// 渠道回應中，不同渠道使用不同的 key 表示渠道編號
Map respMap = svc.toMap(respBody);
String chnlId = svc.getFirstMapValue(respMap, "", "channel", "chnlId", "channelId");
// 依序檢查 channel → chnlId → channelId，回傳第一個找到的值
```

---

###### 值檢查斷言

---

**`assertNotEmpty(String msg, Object val)`**

檢查值是否為空。若為空則拋出 `ChnlBizException`（響應碼 `Z_7015`）。

| 參數 | 型別 | 說明 |
|------|------|------|
| `msg` | `String` | 錯誤訊息，若為空則預設為 `"值不能为空"` |
| `val` | `Object` | 待檢查的值 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.assertNotEmpty("商戶號不能為空", ctx.merId)}
```

---

**`assertNotEmpty(String msg, Object... vals)`**

檢查多個值是否為空。若任一為空則拋出異常。

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 一次檢查多個必填欄位 -->
${svc.assertNotEmpty("必填欄位不能為空", ctx.merId, ctx.orderNo, ctx.txnAmt)}
```

---

**`assertEqual(String msg, Object val1, Object val2)`**

檢查兩個值是否相等。若不相等則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `msg` | `String` | 錯誤訊息，若為空則預設為 `"The values are not equal : %s != %s"` |
| `val1` | `Object` | 比較值 1 |
| `val2` | `Object` | 比較值 2 |

使用範例：

```java
// 驗證渠道回傳的商戶號與請求一致
assertEqual("渠道回傳商戶號不一致", ctx.get("merId"), resp.get("merId"));

// 驗證渠道回傳的訂單號
assertEqual("訂單號不一致", reqOrderNo, respOrderNo);
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.assertEqual("渠道回傳商戶號不一致", ctx.merId, resp.mch_id)}
```

---

**`assertNotEqual(String msg, Object val1, Object val2)`**

檢查兩個值是否不相等。若相等則拋出 `ChnlBizException`。

使用範例：

```java
// 確保新密碼與舊密碼不同
assertNotEqual("新密碼不能與舊密碼相同", oldPassword, newPassword);
```

---

**`assertNumberEquals(String msg, Object val1, Object val2, Object error)`**

檢查兩個數值是否相等（允許指定誤差範圍）。若不相等則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `msg` | `String` | 錯誤訊息 |
| `val1` | `Object` | 比較值 1 |
| `val2` | `Object` | 比較值 2 |
| `error` | `Object` | 允許誤差 |

使用範例：

```java
// 驗證渠道回傳金額與請求金額是否一致（允許 0.01 誤差）
assertNumberEquals("交易金額不一致", ctx.get("txnAmt"), resp.get("amount"), "0.01");

// 精確比較（不允許誤差）
assertNumberEquals("手續費不一致", localFee, chnlFee, "0");
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.assertNumberEquals("交易金額不一致", ctx.txnAmt, svc.fromChnlAmt(resp.amount), "0.01")}
```

---

**`assertNumberEquals(String msg, Object val1, Object val2)`**

檢查兩個數值是否相等（使用預設誤差 `ALLOWED_ERROR = 0.01`）。

---

**`assertTrue(String msg, boolean val)`**

檢查值是否為 `true`。若為 `false` 則拋出 `ChnlBizException`。

使用範例：

```java
// 檢查簽名驗證結果
boolean signValid = verifySignature(respData, sign);
assertTrue("簽名驗證失敗", signValid);
```

---

**`assertFalse(String msg, boolean val)`**

檢查值是否為 `false`。若為 `true` 則拋出 `ChnlBizException`。

使用範例：

```java
// 檢查交易是否已存在（防止重複交易）
boolean exists = checkOrderExists(orderNo);
assertFalse("訂單已存在，不可重複提交", exists);
```

---

**`assertInSet(String msg, Object val, Object... set)`**

檢查值是否包含在集合中。若不在集合中則拋出 `ChnlBizException`。適合檢查是否為正常的響應碼。

| 參數 | 型別 | 說明 |
|------|------|------|
| `msg` | `String` | 錯誤訊息 |
| `val` | `Object` | 待檢查的值 |
| `set` | `Object...` | 集合 |

使用範例：

```java
assertInSet("渠道響應不符預期", httpCode, "200", "301", "302");
```

---

**`assertNotInSet(String msg, Object val, Object... set)`**

檢查值是否不包含在集合中。若在集合中則拋出 `ChnlBizException`。適合檢查是否為錯誤代碼。

使用範例：

```java
assertNotInSet("渠道響應錯誤", httpCode, "401", "402", "403", "404", "500", "502");
```

---

**`assertMatchRegex(String msg, String val, String regex)`**

檢查值是否符合預期格式（正則表達式）。若不符合則拋出 `ChnlBizException`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `msg` | `String` | 錯誤訊息 |
| `val` | `String` | 待檢查的值 |
| `regex` | `String` | 正則表達式 |

使用範例：

```java
// 檢查渠道訂單號格式是否正確
assertMatchRegex("渠道訂單號格式錯誤", chnlOrderNo, "[0-9]{18,32}");

// 檢查金額格式
assertMatchRegex("金額格式錯誤", txnAmt, "[0-9]+(\\.[0-9]{1,2})?");
```

---

**`isNumberEquals(Object a, Object b, Object error)`**

檢查兩個數值物件是否相等（允許指定誤差）。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `boolean` | 是否相等 |

使用範例：

```java
// 比較兩個金額是否一致（允許 0.01 誤差）
boolean eq1 = svc.isNumberEquals("100.00", "100.005", "0.01"); // true
boolean eq2 = svc.isNumberEquals("100.00", "100.02", "0.01");  // false
boolean eq3 = svc.isNumberEquals("100", 100, "0");             // true
```

---

**`isNumberEquals(BigDecimal a, BigDecimal b, BigDecimal error)`**

檢查兩個 `BigDecimal` 是否相等（允許指定誤差）。若 error 為 null 則使用預設 `ALLOWED_ERROR`。

---

###### HTTP 狀態碼檢查

---

**`checkHttpStatusCode(String respCode, String expects)`**

檢查是否為預期的 HTTP 響應碼。

| 參數 | 型別 | 說明 |
|------|------|------|
| `respCode` | `String` | 響應碼，如 `"200"`, `"302"`, `"404"` |
| `expects` | `String` | 預期的響應碼，以分號區隔，例如 `"200;300;302;"` |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `boolean` | 是否為預期的響應碼 |

使用範例：

```java
// 檢查自訂的預期響應碼
boolean ok = svc.checkHttpStatusCode("200", "200;201;202;"); // true
boolean redirect = svc.checkHttpStatusCode("302", "200;301;302;"); // true
boolean fail = svc.checkHttpStatusCode("500", "200;201;");   // false
```

---

**`checkHttpStatusCode(String respCode)`**

檢查是否為預期的 HTTP 響應碼，使用預設值 `"200;201;202;204;"`。

使用範例：

```java
// 使用預設預期碼檢查
HttpClientResponse resp = httpProxy().url(apiUrl).post(data);
if (!checkHttpStatusCode(resp.getCode())) {
    throwError(RspCd.Z_7015, "HTTP請求失敗，狀態碼：" + resp.getCode());
}
```

---

**`checkHttpStatusPrefix(String respCode, String expectPrefixs)`**

檢查響應碼的前綴是否符合預期。

| 參數 | 型別 | 說明 |
|------|------|------|
| `respCode` | `String` | 響應碼 |
| `expectPrefixs` | `String` | 預期前綴，以分號區隔，例如 `"2;3;"` |

使用範例：

```java
// 接受 2xx 和 3xx 的響應碼
boolean ok = svc.checkHttpStatusPrefix("200", "2;3;"); // true
boolean redirect = svc.checkHttpStatusPrefix("302", "2;3;"); // true
boolean fail = svc.checkHttpStatusPrefix("404", "2;3;"); // false
```

---

**`checkHttpStatusPrefix(String respCode)`**

檢查響應碼是否為 2xx（預設前綴 `"2;"`）。

---

###### 金額轉換

---

**`toChnlAmt(String txnAmt)`**

將本地金額格式轉換成渠道的金額格式。預設由交易幣別的預設單位轉換成渠道金額單位 `getChnlAmtUnit()`。若有設定 `chnlAmtFormat` 則會套用格式化。子類別可覆寫此方法。

| 參數 | 型別 | 說明 |
|------|------|------|
| `txnAmt` | `String` | 本地金額 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 渠道金額字串 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 若渠道金額單位為分(0.01)，本地為元(1.00)，則 100 會轉為 10000 -->
"amount": "${svc.toChnlAmt(ctx.txnAmt)}"
```

---

**`fromChnlAmt(String txnAmt)`**

從渠道的金額格式轉換成本地金額格式。預設由渠道金額單位轉換成交易幣別的預設單位。若有設定 `localAmtFormat` 則會套用格式化。子類別可覆寫此方法。

| 參數 | 型別 | 說明 |
|------|------|------|
| `txnAmt` | `String` | 渠道金額 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 本地金額字串 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign localAmt = svc.fromChnlAmt(resp.amount)>
```

使用範例：

```java
// 完整的金額轉換流程範例
svc.setChnlAmtUnitStr("0.01");  // 渠道以分為單位
svc.setChnlAmtFormat("0");       // 不帶小數

// 本地 100 元 → 渠道 10000 分
String chnlAmt = svc.toChnlAmt("100");    // 輸出: "10000"
// 渠道 10000 分 → 本地 100 元
String localAmt = svc.fromChnlAmt("10000"); // 輸出: "100"
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 發送請求時轉換金額 -->
"amount": "${svc.toChnlAmt(ctx.txnAmt)}"

<#-- 收到回應時轉換金額 -->
<#assign localAmt = svc.fromChnlAmt(resp.amount)>
${svc.assertNumberEquals("金額不一致", ctx.txnAmt, localAmt)}
```

---

**`fromChnlAmtObj(Object txnAmt)`**

從渠道的金額格式轉換成本地金額格式（接受 Object 型別輸入）。內部先透過 `toStr` 轉成字串再呼叫 `fromChnlAmt`。

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- resp.amount 可能是數值型別，用 fromChnlAmtObj 可安全轉換 -->
<#assign localAmt = svc.fromChnlAmtObj(resp.amount)>
```

---

###### 響應碼轉換

---

**`getTranslated(String catalog, String code)`**

交易狀態/響應碼轉換。實際內容定義於表格 `tbl_chnl_translate`。會先以當前類別名稱查找，若查無則以萬用字符 `"*"` 查找。

| 參數 | 型別 | 說明 |
|------|------|------|
| `catalog` | `String` | 分類，例如 `"PAY_NOTIFY"` |
| `code` | `String` | 原始交易狀態/響應碼，例如 `"5001"` |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `StrCodeMsg` | 轉換後的代碼與訊息物件，若查無則為 null |

使用範例：

```java
String code = "5001";
StrCodeMsg codeMsg = getTranslated("PAY_NOTIFY", code);
String txnStatus = codeMsg.getCode();       // 例如: "20"
String txnStatusDesc = codeMsg.getMessage(); // 例如: "超過支付限額"
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign translated = svc.getTranslated("PAY_NOTIFY", resp.code)>
<#if translated??>
  ${translated.code}
</#if>
```

---

**`getTranslated(String catalog, Integer code)`**

響應碼轉換（Integer 版本）。

---

**`getTranslated(String catalog, Long code)`**

響應碼轉換（Long 版本）。

---

**`getTranslatedCode(String catalog, String code)`**

取得轉換後的代碼。回傳 `StrCodeMsg.getCode()` 的值。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 轉換後的代碼，查無則為 null |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign txnStatus = svc.getTranslatedCode("PAY_NOTIFY", resp.code)!"">
```

---

**`getTranslatedCode(String catalog, Integer code)` / `getTranslatedCode(String catalog, Long code)`**

取得轉換後的代碼（Integer / Long 版本）。

---

**`getTranslatedMsg(String catalog, String code)`**

取得轉換後的訊息。回傳 `StrCodeMsg.getMessage()` 的值。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 轉換後的訊息，查無則為 null |

---

**`getTranslatedMsg(String catalog, Integer code)` / `getTranslatedMsg(String catalog, Long code)`**

取得轉換後的訊息（Integer / Long 版本）。

---

###### 參數配置讀取

---

**`getMerParam(String merId, String catalog, String paramId, boolean throwErrorIfNotExist)`**

取得一般參數配置（支援商戶號配置萬用字符）。若 catalog 符合交易類型格式（如 `"1001"`），會先查 catalog 再以 `"*"` 查找。

| 參數 | 型別 | 說明 |
|------|------|------|
| `merId` | `String` | 商戶號，會優先匹配此商戶號，若查無則查找 `"*"` 或 `"#DEFAULT#"` |
| `catalog` | `String` | 參數分類 |
| `paramId` | `String` | 參數名（ID） |
| `throwErrorIfNotExist` | `boolean` | 若無值是否拋出錯誤 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 參數值 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign apiKey = svc.getMerParam(ctx.chnlMerId, "IDS", "apiKey", true)>
```

---

**`getMerParam(String merId, String catalog, String paramId, String defaultValue)`**

取得一般參數配置，若查無值則回傳預設值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `merId` | `String` | 商戶號 |
| `catalog` | `String` | 參數分類 |
| `paramId` | `String` | 參數名 |
| `defaultValue` | `String` | 預設值 |

---

**`getMerParam(String merId, String[] catalogs, String paramId, String defaultValue)`**

取得一般參數配置，支援多個分類依序查找。

使用範例：

```java
// 依序查找多個分類，取得第一個找到的值
String[] catalogs = new String[] { "1001", "PARAM", "*" };
String apiUrl = svc.getMerParam(chnlMerId, catalogs, "apiUrl", "");
```

---

**`getMerParam(String paramId, String defaultValue)`**

取得一般參數配置的簡化版本。自動使用當前的 `chnlMerId` 和 `intTxnType` 作為商戶號和分類。若以交易類型查無，再以 `"*"` 查找。

| 參數 | 型別 | 說明 |
|------|------|------|
| `paramId` | `String` | 參數名 |
| `defaultValue` | `String` | 預設值 |

使用範例：

```java
// 在子類別中使用簡化版取得參數
String notifyUrl = getMerParam("notifyUrl", "");
String signType = getMerParam("signType", "MD5");
String timeout = getMerParam("timeout", "30");
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign notifyUrl = svc.getMerParam("notifyUrl", "")>
<#assign signType = svc.getMerParam("signType", "MD5")>
```

---

**`getMerParam(String paramId, boolean throwErrorIfNotExist)`**

取得一般參數配置的簡化版本。自動使用當前的 `chnlMerId` 和 `intTxnType`。

使用範例：

```java
// 必填參數：查無時拋出異常
String apiUrl = getMerParam("apiUrl", true);

// 選填參數：查無時回傳 null
String remark = getMerParam("remark", false);
```

---

**`getMerSecParam(String merId, String paramId, boolean throwErrorIfNotExist)`**

取得敏感（分類 `SEC`）參數配置（支援商戶號配置萬用字符）。

| 參數 | 型別 | 說明 |
|------|------|------|
| `merId` | `String` | 商戶號 |
| `paramId` | `String` | 參數名 |
| `throwErrorIfNotExist` | `boolean` | 若無值是否拋出錯誤 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign secretKey = svc.getMerSecParam(ctx.chnlMerId, "secretKey", true)>
```

---

**`getMerSecParam(String merId, String paramId, String defaultValue)`**

取得敏感參數配置，若查無值則回傳預設值。

---

**`getFrontMerParam(String merId, String paramId, String defaultValue)`**

取得前端（渠道 `"00"`）的商戶參數配置。先以當前交易類型查找，再以 `"*"` 查找。

| 參數 | 型別 | 說明 |
|------|------|------|
| `merId` | `String` | 商戶號 |
| `paramId` | `String` | 參數名 |
| `defaultValue` | `String` | 預設值 |

使用範例：

```java
// 取得前端商戶的頁面回跳 URL
String pageRetUrl = getFrontMerParam(merId, "pageReturnUrl", "");
```

---

###### 時間工具

---

**`now()`**

回傳當前時間。同一實例中多次呼叫會回傳相同的時間物件（synchronized 延遲初始化）。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Date` | 當前時間 |

---

**`nowStr()`**

回傳當前時間的字串，格式 `yyyyMMddHHmmss`。

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
"timestamp": "${svc.nowStr()}"
<#-- 範例輸出: "timestamp": "20260308143025" -->
```

---

**`nowStr(String fmt)`**

回傳當前時間的字串，格式自訂。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fmt` | `String` | 日期時間格式，例如 `"yyyyMMddHHmmss"` |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
"timestamp": "${svc.nowStr("yyyy-MM-dd'T'HH:mm:ss")}"
```

---

**`nowStr(String fmt, String timeZone)`**

回傳當前時間的字串，格式自訂，指定時區。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fmt` | `String` | 日期時間格式 |
| `timeZone` | `String` | 時區，例如 `"GMT+8"` |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 渠道要求使用 GMT+8 時區 -->
"timestamp": "${svc.nowStr("dd/MM/yyyy HH:mm:ss", "GMT+8")}"
<#-- 範例輸出: "timestamp": "08/03/2026 14:30:25" -->

<#-- 渠道要求使用 GMT+6 時區 -->
"timestamp": "${svc.nowStr("yyyy-MM-dd'T'HH:mm:ssXXX", "GMT+6")}"
```

---

**`nowMillis()`**

回傳當前時間的毫秒數。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Long` | 毫秒數 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 部分渠道要求毫秒級時間戳 -->
"timestamp": "${svc.nowMillis()?c}"
<#-- 範例輸出: "timestamp": "1741420225000" -->
```

---

**`nowSecs()`**

回傳當前時間的秒數。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Long` | 秒數 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 部分渠道要求秒級 Unix 時間戳 -->
"timestamp": "${svc.nowSecs()?c}"
<#-- 範例輸出: "timestamp": "1741420225" -->
```

---

**`dateStr(Date date)`**

回傳指定時間的字串，格式 `yyyyMMddHHmmss`。

---

**`dateStr(Date date, String fmt)`**

回傳指定時間的字串，格式自訂。

---

**`dateStr(Date date, String fmt, String timeZone)`**

回傳指定時間的字串，格式自訂，指定時區。

| 參數 | 型別 | 說明 |
|------|------|------|
| `date` | `Date` | 日期時間 |
| `fmt` | `String` | 格式 |
| `timeZone` | `String` | 時區，例如 `"GMT+6"` |

---

**`dateStr(String dateStr, String fmt)`**

將 `yyyyMMddHHmmss` 格式的日期時間字串重新格式化為指定格式。

| 參數 | 型別 | 說明 |
|------|------|------|
| `dateStr` | `String` | 原始日期時間字串（格式 `yyyyMMddHHmmss`） |
| `fmt` | `String` | 新格式，例如 `"yyyy-MM-dd HH:mm:ss"` |

使用範例：

```java
// 將系統日期格式轉為渠道要求的格式
String sysDate = "20260308143025";
String formatted = svc.dateStr(sysDate, "yyyy-MM-dd HH:mm:ss");
// 輸出: "2026-03-08 14:30:25"

String isoFormat = svc.dateStr(sysDate, "yyyy-MM-dd'T'HH:mm:ss");
// 輸出: "2026-03-08T14:30:25"
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 將交易日期重新格式化 -->
"order_date": "${svc.dateStr(ctx.orderDate, "yyyy-MM-dd")}"
```

---

###### 條件工具

---

**`iif(Boolean condition, Object trueVal, Object falseVal)`**

三元條件運算。若 condition 為 null 回傳 null，為 true 回傳 trueVal，為 false 回傳 falseVal。

| 參數 | 型別 | 說明 |
|------|------|------|
| `condition` | `Boolean` | 條件 |
| `trueVal` | `Object` | 條件為真時的值 |
| `falseVal` | `Object` | 條件為假時的值 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
"type": "${svc.iif(ctx.isCredit, "credit", "debit")}"
```

---

**`ifEmpty(Object testVal, Object defaulVal)`**

檢查值是否為空（包含 null、空集合、空字串）。若為空則回傳預設值。

| 參數 | 型別 | 說明 |
|------|------|------|
| `testVal` | `Object` | 待檢查的值 |
| `defaulVal` | `Object` | 預設值 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
"name": "${svc.ifEmpty(ctx.name, "N/A")}"
```

---

###### Unicode 轉換

---

**`unicode(String source)`**

將字串轉換成 Unicode 格式。例如：`"中文"` 轉為 `"\u4e2d\u6587"`。

使用範例：

```java
String result = svc.unicode("中文");        // 輸出: "\u4e2d\u6587"
String result2 = svc.unicode("付款成功");    // 輸出: "\u4ed8\u6b3e\u6210\u529f"
```

---

**`decodeUnicode(String unicode)`**

將 Unicode 格式轉換成字串。例如：`"\u4e2d\u6587"` 轉為 `"中文"`。

使用範例：

```java
String result = svc.decodeUnicode("\\u4e2d\\u6587"); // 輸出: "中文"
```

---

###### JSON 轉義與壓縮

---

**`escapeJson(String input)`** *(static)*

將任意字串轉義為 JSON-safe 格式。處理 `"`, `\`, `\b`, `\f`, `\n`, `\r`, `\t` 及其他控制字元。

| 參數 | 型別 | 說明 |
|------|------|------|
| `input` | `String` | 輸入字串 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 轉義後的字串 |

使用範例：

```java
// 將含特殊字元的字串轉義為 JSON-safe 格式
String raw = "He said \"hello\" \n and left";
String escaped = ChnlBaseTools.escapeJson(raw);
// 輸出: "He said \\\"hello\\\" \\n and left"
```

---

**`escapeJson(String input, String lineSeparator)`** *(static)*

將字串轉義為 JSON-safe 格式，並將換行符替換為指定的行分隔符。

| 參數 | 型別 | 說明 |
|------|------|------|
| `input` | `String` | 輸入字串 |
| `lineSeparator` | `String` | 指定的行分隔符 |

使用範例：

```java
// 將渠道回應（多行 JSON）嵌入到另一個 JSON 中
String chnlResp = "{\n  \"code\": 200,\n  \"msg\": \"ok\"\n}";
String compacted = ChnlBaseTools.compactJsonStr(chnlResp);
String escaped = ChnlBaseTools.escapeJson(compacted, "\n");
// 可安全嵌入另一個 JSON 的值中
String wrapper = "{\"tag\":\"TEST\",\"body_info\":\"" + escaped + "\"}";
Map map = svc.toMap(wrapper); // 可正常解析
```

---

**`compactJsonStr(String jsonStr)`** *(static)*

將 JSON 字串壓縮為緊湊格式（去除多餘空白與換行）。解析時使用 `JSON_PARSER_FEATURES` 保持欄位順序。

使用範例：

```java
// 將格式化的 JSON 壓縮為一行
String pretty = "{\n  \"code\": 200,\n  \"msg\": \"ok\"\n}";
String compact = ChnlBaseTools.compactJsonStr(pretty);
// 輸出: {"code":200,"msg":"ok"}
```

---

**`compactJsonObj(Object obj)`** *(static)*

將物件壓縮為緊湊的 JSON 字串。若物件為 `String` 則先以 `compactJsonStr` 處理。

使用範例：

```java
// 將 Map 壓縮為緊湊 JSON
Map<String, String> params = Utils.newMap("merId", "M001", "orderNo", "ORD001");
String compact = ChnlBaseTools.compactJsonObj(params);
// 輸出: {"merId":"M001","orderNo":"ORD001"}
```

---

###### HTML 頁面產生

---

**`toAutoPostHtml(String url, Map paramMap)`**

產生自動 POST 提交的 HTML 內容。

| 參數 | 型別 | 說明 |
|------|------|------|
| `url` | `String` | 目標網址 |
| `paramMap` | `Map` | POST 參數 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | HTML 內容 |

使用範例：

```java
// 產生自動 POST 跳轉頁面（常用於銀行閘道跳轉）
Map<String, String> paramMap = Utils.newMap(
    "merId", "M100001",
    "orderNo", "ORD20230411001",
    "txnAmt", "10000",
    "sign", signResult
);
String html = svc.toAutoPostHtml(bankGatewayUrl, paramMap);
// 回傳含 <form> 與自動 submit 的 HTML
```

---

**`getStoredHtmlForPost(String url, Map paramMap)`**

產生自動 POST 提交的 HTML 並儲存，回傳儲存後的 URL。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 儲存後的 HTML URL |

使用範例：

```java
// 產生並儲存自動 POST 頁面，回傳可存取的 URL
String redirectUrl = svc.getStoredHtmlForPost(bankGatewayUrl, paramMap);
// redirectUrl 可回傳給前端進行跳轉
```

---

**`toAutoRedirectHtml(String url)`**

產生自動跳轉的 HTML 內容。

| 參數 | 型別 | 說明 |
|------|------|------|
| `url` | `String` | 目標跳轉網址 |

使用範例：

```java
// 產生 GET 方式的自動跳轉頁面
String payUrl = "https://pay.example.com/cashier?orderNo=ORD001&token=abc123";
String html = svc.toAutoRedirectHtml(payUrl);
```

---

**`getStoredHtmlForGet(String url)`**

產生自動跳轉的 HTML 並儲存，回傳儲存後的 URL。

使用範例：

```java
// 產生並儲存自動跳轉頁面
String storedUrl = svc.getStoredHtmlForGet(payUrl);
// storedUrl 可回傳給前端進行跳轉
```

---

**`getCasherUrl(Object ctx, String... extParams)`**

產生收銀台頁面跳轉 URL。會建立 Session 並儲存必要參數，組裝收銀台頁面的 POST 表單 URL。

| 參數 | 型別 | 說明 |
|------|------|------|
| `ctx` | `Object` | 上下文資料（可為 Map 或 JSONObject） |
| `extParams` | `String...` | 額外參數（key-value 對） |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 收銀台跳轉 URL |

使用範例：

```java
// 產生收銀台跳轉 URL
String casherUrl = svc.getCasherUrl(ctx);

// 帶額外參數
String casherUrl2 = svc.getCasherUrl(ctx, "theme", "dark", "lang", "zh-TW");
```

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign redirectUrl = svc.getCasherUrl(ctx)>
```

---

###### 格式化工具

---

**`format(String fmt, Object... args)`**

格式化字串，等同 `String.format(fmt, args)`。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fmt` | `String` | 格式字串 |
| `args` | `Object...` | 格式化參數 |

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.format("Order-%s-%s", ctx.merId, ctx.orderId)}
```

---

###### FreeMarker 模板處理

---

**`translateByTemplate(String fltName, Object ctx)`**

由 FreeMarker 模板轉換資料內容。會自動建構 Context（包含 `svc`、`mem`、`utils`、`enc`、`rand`、`conv` 工具物件），並以 `ctx` 作為模板中的上下文變數名稱。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fltName` | `String` | 模板名稱，例如 `"txn_req.ftl"` |
| `ctx` | `Object` | 內容，可以是 Map 或 JSONObject |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 模板處理後的字串 |

| 拋出 | 說明 |
|------|------|
| `ChnlBizException` | 模板處理發生錯誤時 |

使用範例：

```java
// 使用 FreeMarker 模板產生請求報文
Map<String, Object> ctx = new HashMap<>();
ctx.put("merId", "M100001");
ctx.put("orderNo", "ORD20230411001");
ctx.put("txnAmt", "100");

String reqBody = svc.translateByTemplate("txn_req.ftl", ctx);
// 模板中可用 ${ctx.merId}、${svc.toChnlAmt(ctx.txnAmt)} 等
```

---

#### Protected 部分

##### 常數

| 常數名稱 | 型別 | 值 | 說明 |
|---------|------|-----|------|
| `DefaultExpectCodes` | `String` | `"200;201;202;204;"` | 預設預期的 HTTP 響應碼集合 |
| `DefaultExpectCodePrefix` | `String` | `"2;"` | 預設預期的 HTTP 響應碼前綴 |

##### 屬性（靜態工具實例）

| 屬性名稱 | 型別 | 說明 |
|---------|------|------|
| `utils` | `Utils` | 公用工具類實例，供 FreeMarker 模板中 `utils` 使用 |
| `encUtils` | `EncryptUtil` | 加密工具類實例，供 FreeMarker 模板中 `enc` 使用 |
| `randUtils` | `RandomUtils` | 隨機數工具類實例，供 FreeMarker 模板中 `rand` 使用 |
| `convUtils` | `Converter` | 轉換工具類實例，供 FreeMarker 模板中 `conv` 使用 |

##### 方法

###### 日誌（傳統模式）

---

**`getLogger()`**

取得 Log4j Logger 實例。延遲初始化，以當前類別建立。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Logger` | Log4j Logger |

---

**`debug(String message)` / `debug(String fmt, Object... args)`**

輸出 DEBUG 等級日誌，自動加上日誌前綴。

---

**`info(String message)` / `info(String fmt, Object... args)`**

輸出 INFO 等級日誌，自動加上日誌前綴。

---

**`warn(String message)` / `warn(String fmt, Object... args)`**

輸出 WARN 等級日誌，自動加上日誌前綴。

---

**`error(String message)` / `error(String fmt, Object... args)`**

輸出 ERROR 等級日誌，自動加上日誌前綴。

---

**`error(String message, Throwable t)` / `error(Throwable t, String fmt, Object... args)`**

輸出 ERROR 等級日誌，含例外物件。

使用範例：

```java
// 傳統日誌模式（在子類別中使用）
debug("開始處理交易");
info("交易參數: merId=%s, orderNo=%s", merId, orderNo);
warn("渠道回應延遲: %dms", elapsed);
error("HTTP請求失敗: %s", e.getMessage());
error(e, "處理模板發生錯誤: %s", templateName);
// 日誌輸出範例: [CH-AX]開始處理交易
```

---

**`getLogPrefix()`**

取得日誌前綴，格式為 `"[CH-{渠道編號}]"`。若渠道編號為空則回傳空字串。

---

###### 日誌（新模式 - ILog 鏈式）

---

**`debug()`**

取得 DEBUG 等級的 `ILog` 日誌器。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `ILog` | 鏈式日誌器 |

---

**`info()`**

取得 INFO 等級的 `ILog` 日誌器。

---

**`warn()`**

取得 WARN 等級的 `ILog` 日誌器。

---

**`error()`**

取得 ERROR 等級的 `ILog` 日誌器。

---

**`crInfo()`**

取得重要的 INFO 等級 `CriticalLog` 日誌器。

---

**`crWarn()`**

取得重要的 WARN 等級 `CriticalLog` 日誌器。

---

**`crError()`**

取得重要的 ERROR 等級 `CriticalLog` 日誌器。

使用範例：

```java
// 新模式日誌（鏈式呼叫，在子類別中使用）
info().message("收到渠道回應: code=%s, msg=%s", respCode, respMsg).submit();
warn().message("交易金額異常: 本地=%s, 渠道=%s", localAmt, chnlAmt).submit();
error().throwError(e).message("簽名驗證失敗: %s", e.getMessage()).submit();

// 重要日誌（會寫入 CriticalLog）
crInfo().message("交易成功: orderNo=%s, txnAmt=%s", orderNo, txnAmt).submit();
crError().message("渠道連線失敗: channel=%s", channel).submit();
```

---

###### 值比較

---

**`isEqual(Object val1, Object val2)`**

比較兩個物件是否相等（null-safe）。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `boolean` | 是否相等 |

使用範例：

```java
// null-safe 的值比較
boolean eq1 = isEqual("200", "200"); // true
boolean eq2 = isEqual("200", "201"); // false
boolean eq3 = isEqual(null, null);   // true
boolean eq4 = isEqual("200", null);  // false
```

---

###### Map 工具

---

**`putIfNotEmpty(Map<String, String> map, String key, Object val)`**

若值非空，則將值放入 Map。

---

**`putIfNotEmpty(JSONObject map, String key, Object val)`**

若值非空，則將值放入 JSONObject。

使用範例：

```java
// 組裝請求參數，只加入非空值
Map<String, String> params = new HashMap<>();
putIfNotEmpty(params, "merId", merId);           // merId 非空則加入
putIfNotEmpty(params, "subMerId", subMerId);       // subMerId 為空則不加入
putIfNotEmpty(params, "orderNo", orderNo);
// params 中只會包含非空的 key-value
```

---

###### 例外拋出

---

**`throwError(String channel, String errorCode, String errorMsg, Throwable e, Map<String, String> context)`**

拋出 `ChnlBizException` 錯誤（完整版本），含渠道編號、錯誤代碼、錯誤訊息、原始例外與附帶內容。

---

**`throwError(String errorCode, String errorMsg, Throwable e, Map<String, String> context)`**

拋出 `ChnlBizException` 錯誤，使用預設分類。

---

**`throwError(String channel, String errorCode, String errorMsg)`**

拋出 `ChnlBizException` 錯誤（簡化版本），含渠道編號。

---

**`throwError(String code, String msg)`**

拋出 `ChnlBizException` 錯誤（最簡版本）。

使用範例：

```java
// 各種 throwError 用法（在子類別中使用）
// 最簡版本
throwError(RspCd.Z_7015, "渠道回應格式錯誤");

// 含渠道編號
throwError("AX", RspCd.Z_7015, "渠道回應格式錯誤");

// 含原始例外
try {
    // ... HTTP 請求
} catch (IOException e) {
    throwError(RspCd.Z_7015, "HTTP請求失敗: " + e.getMessage(), e, null);
}
```

---

###### FreeMarker 模板處理

---

**`getTemplate(Class<? extends ChnlBaseTools> classz, String catalog)`**

取得 FreeMarker 模板配置。

| 參數 | 型別 | 說明 |
|------|------|------|
| `classz` | `Class<? extends ChnlBaseTools>` | 渠道服務的實作類別，null 表示自己的類別 |
| `catalog` | `String` | 分類，null 表示渠道編號 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `FreeMarkerDbTemplate` | 模板配置物件 |

---

**`getTemplate()`**

取得 FreeMarker 模板配置（使用預設的類別與渠道編號）。

---

**`processTemplate(String fltName, Object rootMap)`**

處理 FreeMarker 模板。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fltName` | `String` | 模板名稱 |
| `rootMap` | `Object` | 模板資料模型 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `String` | 模板處理結果 |

| 拋出 | 說明 |
|------|------|
| `ChnlBizException` | 模板處理錯誤時 |

---

**`hasTemplate(String fltName)`**

判斷是否有指定的模板。

| 參數 | 型別 | 說明 |
|------|------|------|
| `fltName` | `String` | 模板名稱 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `boolean` | 是否存在此模板 |

使用範例：

```java
// 根據模板是否存在決定處理方式
if (hasTemplate("txn_req_sign.ftl")) {
    String signData = processTemplate("txn_req_sign.ftl", rootMap);
    // 使用專用簽名模板
} else {
    // 使用預設簽名邏輯
}
```

---

**`createContext(Object ctx, String ctxName)`**

建構 FreeMarker 模板的 Context Map，包含以下工具變數：

| 變數名 | 型別 | 說明 |
|--------|------|------|
| `svc` | `ChnlBaseTools`（本實例） | 服務類別實例 |
| `mem` | `Map<String, Object>` | 暫存記憶體 Map |
| `utils` | `Utils` | 公用工具類 |
| `enc` | `EncryptUtil` | 加密工具類 |
| `rand` | `RandomUtils` | 隨機數工具類 |
| `conv` | `Converter` | 轉換工具類 |

| 參數 | 型別 | 說明 |
|------|------|------|
| `ctx` | `Object` | 上下文資料（Map 或 JSONObject 等） |
| `ctxName` | `String` | 上下文在模板中的變數名稱 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `Map<String, Object>` | 完整的模板 Context |

使用範例：

```java
// 手動建構 Context 並處理模板
Map<String, Object> txnData = new HashMap<>();
txnData.put("merId", "M100001");
txnData.put("orderNo", "ORD001");
txnData.put("txnAmt", "100");

Map<String, Object> context = createContext(txnData, "ctx");
// context 包含: {ctx=txnData, svc=this, mem=memory, utils=..., enc=..., rand=..., conv=...}
// 模板中可用: ${ctx.merId}, ${svc.toChnlAmt(ctx.txnAmt)}, ${utils.isEmpty(ctx.remark)}

String result = processTemplate("txn_req.ftl", context);
```

---

###### 金額格式化器

---

**`getChnlAmtFormater()`**

取得渠道金額格式化器。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `DecimalFormat` | 渠道金額格式化器，若未設定則為 null |

---

**`getLocalAmtFormater()`**

取得本地金額格式化器。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `DecimalFormat` | 本地金額格式化器 |

---

###### HTTP 請求代理

---

**`httpPost(String chnlMerId, String reqUrl, String postData, Map<String, String> header)`**

透過轉發服務發起 HTTP POST 請求（字串資料版本）。

| 參數 | 型別 | 說明 |
|------|------|------|
| `chnlMerId` | `String` | 渠道商戶號 |
| `reqUrl` | `String` | 請求 URL |
| `postData` | `String` | POST 的資料 |
| `header` | `Map<String, String>` | HTTP 標頭 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `HttpClientResponse` | HTTP 回應 |

| 拋出 | 說明 |
|------|------|
| `IOException` | 請求失敗時 |

---

**`httpPost(String chnlMerId, String reqUrl, Map<String,String> postData, Map<String, String> header)`**

透過轉發服務發起 HTTP POST 請求（Map 資料版本）。

---

**`httpGet(String chnlMerId, String reqUrl, String data, Map<String, String> header)`**

透過轉發服務發起 HTTP GET 請求（字串資料版本）。

---

**`httpGet(String chnlMerId, String reqUrl, Map<String,String> data, Map<String, String> header)`**

透過轉發服務發起 HTTP GET 請求（Map 資料版本）。

---

**`httpProxy(String chnlMerId)`**

取得 HTTP 轉發服務 Helper，可鏈式設定 URL、Header、編碼等後發送請求。

| 參數 | 型別 | 說明 |
|------|------|------|
| `chnlMerId` | `String` | 渠道商戶號 |

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `HttpProxyHelper` | HTTP 轉發服務實例 |

使用範例：

```java
// 使用鏈式呼叫發送 POST 請求
Map<String, String> header = Utils.newMap("Content-Type", "application/json");
HttpClientResponse resp = httpProxy(chnlMerId)
    .url(apiUrl).headers(header).post(jsonBody);
String respBody = resp.getBody();
String httpCode = resp.getCode();
```

---

**`httpProxy()`**

取得 HTTP 轉發服務 Helper（使用當前的 `chnlMerId`）。

使用範例：

```java
// 使用當前 chnlMerId 發送請求
Map<String, String> header = Utils.newMap(
    "Content-Type", "application/x-www-form-urlencoded"
);
HttpClientResponse resp = httpProxy()
    .url(apiUrl).headers(header).post(formData);

// 發送 GET 請求
HttpClientResponse getResp = httpProxy()
    .url(queryUrl).headers(header).get(queryParams);
```

---

###### 分類判斷

---

**`isCatalogAsTxnType(String catalog)`**

判斷 catalog 是否符合交易類型的格式（正則 `[0-9][0-9a-zA-Z]{3,7}`）。

| 回傳 | 型別 | 說明 |
|------|------|------|
| 回傳值 | `boolean` | 是否為交易類型格式 |

使用範例：

```java
// 判斷 catalog 是否為交易類型格式
isCatalogAsTxnType("1001");   // true（4 位數字）
isCatalogAsTxnType("10A1");   // true（數字+英文混合）
isCatalogAsTxnType("SEC");    // false（不符合格式）
isCatalogAsTxnType("PARAM");  // false
isCatalogAsTxnType("URL");    // false
```

---

###### 收銀台工具

---

**`getCasherPageUrl()`**

取得收銀台頁面 URL，從參數 `casher.url` 讀取。

---

**`getCasherTimeout()`**

取得收銀台超時時間（秒），從參數 `casher.timeout` 讀取，預設 960 秒（16 分鐘）。

---

###### JSON/Map 轉換（內部版本）

---

**`toMapV1(String jsonStr)`**

將 JSON 字串轉換成 Map（V1 版本，使用標準 `JSON.parseObject`）。

---

**`toMapV2(String jsonStr)`**

將 JSON 字串轉換成 Map（V2 版本，使用 `JSON_PARSER_FEATURES` 寬鬆解析）。此為 `toMap(String)` 的實際實作。
