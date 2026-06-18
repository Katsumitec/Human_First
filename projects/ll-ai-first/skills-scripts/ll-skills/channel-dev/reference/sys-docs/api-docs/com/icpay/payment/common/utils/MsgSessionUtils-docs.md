# MsgSessionUtils

類別名稱：`com.icpay.payment.common.utils.MsgSessionUtils`

## 說明

報文會話（Session）工具類，提供會話的建立、驗證、合併、刪除、超時管理等功能。

會話資料存放於 `SessionParams`（通常對應 Redis 等快取儲存），每個會話包含兩個部分：
1. **會話資料**（以 `PAY.SESS` 為 catalog 的 Map）：儲存交易類型、商戶號、訂單號、金額等關鍵參數。
2. **會話過期時間戳**（以 `PAY.SESS.EXPRTIME` 為 catalog 的字串值）：記錄會話到期的毫秒時間戳，用於精確判斷會話是否仍有效。

會話 ID 透過 `RandomUtils` 產生 32 位隨機字串，再經 `IdChecksumUtils.generate()` 附帶 Checksum 校驗碼，確保會話 ID 的合法性可被快速驗證（無需查詢快取）。

預設會話過期時間為 **15 分鐘**（900 秒）。實際寫入快取時會額外增加 10 秒緩衝，避免因時間差導致過早失效。

## 架構

### Package

```
com.icpay.payment.common.utils
```

### 相依性

| 類別 / 介面 | 用途 |
|---|---|
| `com.icpay.payment.common.data.utils.SessionParams` | 會話資料的底層儲存操作（put / get / delete Map 與字串） |
| `com.icpay.payment.gateway.msg.Context` | 閘道上下文物件，包含請求參數與客戶端 IP 等資訊 |
| `com.icpay.payment.common.utils.IdChecksumUtils` | 會話 ID 的 Checksum 產生與驗證 |
| `com.icpay.payment.common.utils.RandomUtils` | 產生隨機字串作為會話 ID 的基底 |
| `com.icpay.payment.common.utils.Utils` | 通用工具方法（isEmpty、copyValuesIfNotEmpty、mergerMaps） |
| `com.icpay.payment.common.utils.MapHelper` | Map 包裝器，提供型別安全的取值方法 |
| `com.icpay.payment.common.constants.Names.MSG` | 報文欄位名稱常數（txnType、merId、orderId 等） |
| `com.icpay.payment.common.constants.Names.INTER_MSG` | 內部報文欄位名稱常數（reqIps、sessionId） |
| `com.icpay.payment.common.constants.RspCd` | 回應碼常數 |
| `com.icpay.payment.common.exception.ChnlBizException` | 渠道業務異常 |
| `javax.servlet.http.HttpServletRequest` | HTTP 請求物件（用於 checkSession 的多載版本） |

---

## API 說明

### Class: MsgSessionUtils

此類別為純靜態工具類，所有方法皆為 `static`，不可實例化。使用 Lombok `@Slf4j` 註解產生日誌物件。

---

#### Public 部分

##### 常數

| 常數名稱 | 型別 | 值 | 說明 |
|---|---|---|---|
| `SESSION_CATALOG` | `String` | `"PAY.SESS"` | 會話資料在 SessionParams 中的 catalog 名稱前綴 |
| `SESSION_EXPRTIME_CATALOG` | `String` | `"PAY.SESS.EXPRTIME"` | 會話過期時間戳在 SessionParams 中的 catalog 名稱前綴 |
| `DEFAULT_SESSION_EXPIRE` | `int` | `900`（15\*60） | 預設會話過期時間，單位為秒（15 分鐘） |

---

##### 方法

###### `createSession(Context ctx, Integer expiredTime)`

```java
public static String createSession(Context ctx, Integer expiredTime)
```

**說明：** 根據閘道上下文建立新會話。自動從 `ctx.getReqParams()` 中擷取關鍵交易欄位（txnType、txnSubType、merId、orderId、txnAmt、orderDate）及客戶端 IP，存入會話。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `ctx` | `Context` | 閘道上下文物件，包含請求參數與客戶端 IP |
| `expiredTime` | `Integer` | 會話過期時間（秒），若為 null 或 <= 0 則使用預設值 900 秒 |

**回傳值：** `String` — 建立的會話 ID；若 `ctx.getReqParams()` 為空則回傳 `null`。

**使用案例：**
```java
// 在閘道處理請求時建立會話，設定 10 分鐘過期
String sessionId = MsgSessionUtils.createSession(ctx, 600);
```

---

###### `createSession(Map<String, String> params, Integer expiredTime)`

```java
public static String createSession(Map<String, String> params, Integer expiredTime)
```

**說明：** 根據參數 Map 建立新會話。自動從 params 中擷取關鍵交易欄位（txnType、txnSubType、merId、orderId、txnAmt、orderDate、reqIps），存入會話。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `params` | `Map<String, String>` | 包含交易參數的 Map |
| `expiredTime` | `Integer` | 會話過期時間（秒），若為 null 或 <= 0 則使用預設值 900 秒 |

**回傳值：** `String` — 建立的會話 ID；若 params 為空則回傳 `null`。

**使用案例：**
```java
Map<String, String> params = new HashMap<>();
params.put("txnType", "01");
params.put("merId", "M001");
params.put("orderId", "ORD20260308001");
params.put("txnAmt", "10000");
String sessionId = MsgSessionUtils.createSession(params, 900);
```

---

###### `mergeSession(String sessionId, Map<String, String> params, boolean createIfNotExists, Integer expiredTime)`

```java
public static void mergeSession(String sessionId, Map<String, String> params, boolean createIfNotExists, Integer expiredTime)
```

**說明：** 將參數合併到指定的既有會話中。若會話不存在且 `createIfNotExists` 為 `false`，則拋出 `ChnlBizException`（回應碼 `Z_0513_025`）。合併後會以新的過期時間重新建立會話。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 目標會話 ID |
| `params` | `Map<String, String>` | 要合併的參數；若為 null 或空則直接返回不做任何操作 |
| `createIfNotExists` | `boolean` | 會話不存在時是否允許建立新會話；`false` 則拋出異常 |
| `expiredTime` | `Integer` | 會話過期時間（秒） |

**回傳值：** 無（`void`）

**例外：** `ChnlBizException` — 當會話不存在且 `createIfNotExists` 為 `false` 時拋出。

**使用案例：**
```java
// 將額外參數合併到既有會話，若會話不存在則拋出異常
Map<String, String> extra = new HashMap<>();
extra.put("extraKey", "extraValue");
MsgSessionUtils.mergeSession(sessionId, extra, false, 900);
```

---

###### `isValidSession(String sessionId)`

```java
public static boolean isValidSession(String sessionId)
```

**說明：** 檢查會話是否有效（未過期）。透過讀取會話的過期時間戳，比對當前系統時間判斷。不驗證會話內容。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID |

**回傳值：** `boolean` — `true` 表示會話有效且未過期；`false` 表示會話不存在、已過期或 sessionId 為空。

**使用案例：**
```java
if (MsgSessionUtils.isValidSession(sessionId)) {
    // 會話有效，繼續處理
} else {
    // 會話已過期或不存在
}
```

---

###### `checkSession(String sessionId, Map<String, ?> params, boolean falseOnException, String... checkKeys)`

```java
public static boolean checkSession(String sessionId, Map<String, ?> params, boolean falseOnException, String... checkKeys)
```

**說明：** 檢查會話是否有效，並驗證指定的鍵值對是否與會話中儲存的值匹配。若 `sessionId` 為空，會嘗試從 `params` 中以 `INTER_MSG.sessionId` 為鍵取得。驗證邏輯為逐一比對 `checkKeys` 中每個鍵在 `params` 與會話 Map 中的值是否相等。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID，可為 null（會自動從 params 中取得） |
| `params` | `Map<String, ?>` | 包含待驗證參數的 Map |
| `falseOnException` | `boolean` | 發生異常時是否回傳 `false`（`true`）或拋出 `ChnlBizException`（`false`） |
| `checkKeys` | `String...` | 要驗證的鍵名列表 |

**回傳值：** `boolean` — `true` 表示會話存在且所有指定鍵值對均匹配；`false` 表示驗證失敗。

**例外：** `ChnlBizException` — 當 `falseOnException` 為 `false` 且發生異常時拋出。

**使用案例：**
```java
// 驗證請求參數中的商戶號和訂單號是否與會話中的一致
boolean valid = MsgSessionUtils.checkSession(
    sessionId, requestParams, true,
    "merId", "orderId", "txnAmt"
);
```

---

###### `checkSession(String sessionId, HttpServletRequest request, boolean falseOnException, String... checkKeys)`

```java
public static boolean checkSession(String sessionId, HttpServletRequest request, boolean falseOnException, String... checkKeys)
```

**說明：** 與 Map 版本功能相同，但從 `HttpServletRequest` 中取得待驗證的參數值。若 `sessionId` 為空，會嘗試從 `request.getParameter(INTER_MSG.sessionId)` 取得。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID，可為 null（會自動從 request 參數中取得） |
| `request` | `HttpServletRequest` | HTTP 請求物件 |
| `falseOnException` | `boolean` | 發生異常時是否回傳 `false`（`true`）或拋出 `ChnlBizException`（`false`） |
| `checkKeys` | `String...` | 要驗證的鍵名列表 |

**回傳值：** `boolean` — `true` 表示會話存在且所有指定鍵值對均匹配；`false` 表示驗證失敗。

**例外：** `ChnlBizException` — 當 `falseOnException` 為 `false` 且發生異常時拋出。

**使用案例：**
```java
// 在 Servlet 中驗證請求的會話
boolean valid = MsgSessionUtils.checkSession(
    sessionId, request, true,
    "merId", "orderId"
);
```

---

###### `createSessionMap(Map<String, String> map, Integer timeToExpiryInSecs)`

```java
public static String createSessionMap(Map<String, String> map, Integer timeToExpiryInSecs)
```

**說明：** 底層會話建立方法。產生新的會話 ID，將 Map 資料與過期時間戳分別寫入 `SessionParams`。實際寫入快取的 TTL 會比指定的過期時間多 10 秒作為緩衝。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `map` | `Map<String, String>` | 要存入會話的資料；若為 null 則回傳 null |
| `timeToExpiryInSecs` | `Integer` | 會話過期時間（秒），若為 null 或 <= 0 則使用預設值 900 秒 |

**回傳值：** `String` — 建立的會話 ID；若 map 為 null 則回傳 `null`。

**使用案例：**
```java
Map<String, String> data = new HashMap<>();
data.put("key1", "value1");
String sessionId = MsgSessionUtils.createSessionMap(data, 600);
```

---

###### `isValidSessionId(String sessionId)`

```java
public static boolean isValidSessionId(String sessionId)
```

**說明：** 透過 Checksum 校驗快速驗證會話 ID 格式是否合法。此方法不查詢快取，僅驗證 ID 本身的結構正確性。可用於在查詢快取前先行過濾非法 ID，提升效能。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID |

**回傳值：** `boolean` — `true` 表示 ID 格式合法；`false` 表示 ID 為空或格式不合法。

**使用案例：**
```java
if (!MsgSessionUtils.isValidSessionId(sessionId)) {
    // 會話 ID 格式不合法，直接拒絕，不需查詢快取
    return;
}
```

---

###### `deleteSession(String sessionId)`

```java
public static void deleteSession(String sessionId)
```

**說明：** 刪除指定的會話，同時刪除會話資料與過期時間戳。若刪除過程發生異常，僅記錄警告日誌，不拋出異常。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID；若為空則直接返回 |

**回傳值：** 無（`void`）

**使用案例：**
```java
// 交易完成後清除會話
MsgSessionUtils.deleteSession(sessionId);
```

---

###### `getMapFromSession(String sessionId)`

```java
public static Map<String, String> getMapFromSession(String sessionId)
```

**說明：** 從快取中取得指定會話的資料 Map。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID |

**回傳值：** `Map<String, String>` — 會話中儲存的資料；若會話不存在、無效或 sessionId 為空則回傳 `null`。

**使用案例：**
```java
Map<String, String> sessionData = MsgSessionUtils.getMapFromSession(sessionId);
if (sessionData != null) {
    String merId = sessionData.get("merId");
}
```

---

###### `getSessionExpirationTime(String sessionId)`

```java
public static Long getSessionExpirationTime(String sessionId)
```

**說明：** 取得會話的過期時間戳（毫秒，epoch time）。若儲存的值無法解析為 Long，記錄警告日誌並回傳 null。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID |

**回傳值：** `Long` — 會話的過期時間戳（毫秒）；若會話不存在、無效或 sessionId 為空則回傳 `null`。

**使用案例：**
```java
Long expirationTime = MsgSessionUtils.getSessionExpirationTime(sessionId);
if (expirationTime != null) {
    Date expireDate = new Date(expirationTime);
}
```

---

###### `getSessionTimeout(String sessionId)`

```java
public static Long getSessionTimeout(String sessionId)
```

**說明：** 取得會話的剩餘超時時間，單位為毫秒。計算方式為過期時間戳減去當前系統時間。回傳值可能為負數（表示已過期）。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID |

**回傳值：** `Long` — 剩餘超時時間（毫秒）；若會話不存在或無效則回傳 `null`。

**使用案例：**
```java
Long remainingMs = MsgSessionUtils.getSessionTimeout(sessionId);
if (remainingMs != null && remainingMs > 0) {
    log.info("會話剩餘時間: {} 毫秒", remainingMs);
}
```

---

###### `getSessionTimeoutInSecs(String sessionId)`

```java
public static Long getSessionTimeoutInSecs(String sessionId)
```

**說明：** 取得會話的剩餘超時時間，單位為秒。為 `getSessionTimeout()` 的便利方法，將毫秒值除以 1000。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `sessionId` | `String` | 會話 ID |

**回傳值：** `Long` — 剩餘超時時間（秒）；若會話不存在或無效則回傳 `null`。

**使用案例：**
```java
Long remainingSecs = MsgSessionUtils.getSessionTimeoutInSecs(sessionId);
if (remainingSecs != null && remainingSecs > 60) {
    // 會話剩餘超過 1 分鐘
}
```

---

#### Protected 部分

##### 方法

###### `genSessionId()`

```java
protected static String genSessionId()
```

**說明：** 產生新的會話 ID。先透過 `RandomUtils.getStr(32)` 產生 32 位隨機字串，再透過 `IdChecksumUtils.generate(key, MODE_NUM)` 附加 Checksum 校驗碼（MODE_NUM = 21）。

**參數：** 無

**回傳值：** `String` — 附帶 Checksum 的會話 ID。

---

###### `strVal(Object obj, String defVal)`

```java
protected static String strVal(Object obj, String defVal)
```

**說明：** 將物件轉為字串，若物件為 null 則回傳預設值。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `obj` | `Object` | 待轉換的物件 |
| `defVal` | `String` | 物件為 null 時的預設值 |

**回傳值：** `String` — 物件的字串表示，或預設值。

---

###### `valEquals(Object a, Object b)`

```java
protected static boolean valEquals(Object a, Object b)
```

**說明：** 比較兩個物件的字串值是否相等。null 值視為空字串處理（透過 `strVal(obj, "")`）。用於 `checkSession` 方法中比對會話值與請求值。

**參數：**

| 參數 | 型別 | 說明 |
|---|---|---|
| `a` | `Object` | 比較值 A |
| `b` | `Object` | 比較值 B |

**回傳值：** `boolean` — `true` 表示兩者的字串值相等（null 與空字串視為相等）。
