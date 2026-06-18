# FreeMarkerDbTemplate

類別名稱：`com.icpay.payment.common.utils.FreeMarkerDbTemplate`

## 說明

`FreeMarkerDbTemplate` 是 FreeMarker 模板引擎的資料庫版實現，用於渠道支付系統中的模板管理與渲染。與傳統的檔案系統模板載入方式不同，此類別支援從**資料庫快取**或**本地文件**讀取 FreeMarker 模板，並透過 `StringTemplateLoader` 將模板內容動態載入至 FreeMarker `Configuration` 中。

### 模板讀取優先順序

1. **DB 快取**：優先從 `TxnChnlTemplateCache` 快取中以 `(catalog, className, ftlName)` 作為鍵讀取模板。
2. **本地文件**：若快取未命中，嘗試從 classpath 下的 `chnlTemplate/{catalog}/{className}/{tmplName}` 路徑讀取本地模板文件，並自動寫入資料庫快取。
3. **通配符模板**：若本地文件也不存在，嘗試以通配符 `*` 作為 className 再次從快取中查找通用模板。

### 自訂 TemplateExceptionHandler

此類別內建自訂的 `TMPL_ERROR_HANDLER`，會遞迴遍歷異常鏈，若發現 `BizzException` 則將其訊息提取後重新包裝為 `TemplateException` 拋出。另有一個簡化版的 `TMPL_ERROR_SIMPLE_HANDLER`（未啟用），僅取直接 cause 的訊息。

## 架構

### Package

```
com.icpay.payment.common.utils
```

### 相依性

| 相依類別 / 套件 | 說明 |
|---|---|
| `freemarker.template.Configuration` | FreeMarker 核心配置類別 |
| `freemarker.cache.StringTemplateLoader` | 以字串形式載入模板的 TemplateLoader |
| `freemarker.template.Template` | FreeMarker 模板物件 |
| `freemarker.template.TemplateExceptionHandler` | 模板例外處理介面 |
| `freemarker.core.Environment` | FreeMarker 模板執行環境 |
| `com.icpay.payment.service.cache.TxnChnlTemplateCache` | 渠道模板資料庫快取服務，提供模板的讀取與新增 |
| `com.icpay.payment.common.data.model.ChnlTemplate` | 渠道模板資料模型，包含模板內容與更新時間戳 |
| `com.icpay.payment.common.exception.BizzException` | 業務邏輯例外，模板錯誤處理器會特別辨識此類例外 |
| `com.icpay.payment.common.utils.Utils` | 通用工具類別（`isEmpty` 等判斷方法） |
| `com.icpay.payment.common.utils.ClsUtils` | ClassLoader 工具類別 |
| `com.icpay.payment.common.utils.logger.Log` | 日誌工具 |
| `org.apache.commons.io.IOUtils` | Apache Commons IO，用於讀取 InputStream 為字串 |

## API 說明

### Class: FreeMarkerDbTemplate

---

#### Public 部分

##### 常數

| 常數名稱 | 型別 | 值 | 說明 |
|---|---|---|---|
| `ENCODING` | `String` | `"utf-8"` | FreeMarker 模板的預設編碼 |

##### 建構式

###### `FreeMarkerDbTemplate(Class clazz, String catalog)`

建立 `FreeMarkerDbTemplate` 實例。

| 參數 | 型別 | 說明 |
|---|---|---|
| `clazz` | `Class` | 渠道服務類別，用於決定模板路徑中的類別名稱部分及 ClassLoader 來源 |
| `catalog` | `String` | 渠道代碼（目錄名稱），用於定位模板所屬的渠道分類 |

**使用案例：**
```java
FreeMarkerDbTemplate tmplEngine = new FreeMarkerDbTemplate(MyChannelService.class, "CHNL001");
```

##### 方法

###### `Configuration getConfig()`

取得 FreeMarker `Configuration` 實例。若尚未初始化，會先呼叫 `initConfig()` 進行初始化。

- **回傳值：** `Configuration` — FreeMarker 配置實例（使用 `StringTemplateLoader`，編碼為 UTF-8，搭配自訂例外處理器）

**使用案例：**
```java
Configuration cfg = tmplEngine.getConfig();
```

---

###### `Template getTemplate(String fltName) throws IOException`

根據模板名稱取得已編譯的 FreeMarker `Template` 物件。內部會透過 `getTmplFromCache()` 依優先順序（DB 快取 → 本地文件 → 通配符）取得模板內容，並以 `ChnlTemplate.recUpdTs` 作為 `lastModified` 時間戳放入 `StringTemplateLoader`，最後從 `Configuration` 取得編譯後的模板。

| 參數 | 型別 | 說明 |
|---|---|---|
| `fltName` | `String` | 模板檔案名稱（例如 `txn_req.ftl`） |

- **回傳值：** `Template` — 編譯後的 FreeMarker 模板物件
- **拋出：** `IOException` — 模板讀取或解析失敗時

**使用案例：**
```java
Template tmpl = tmplEngine.getTemplate("txn_req.ftl");
```

---

###### `boolean hasTemplate(String fltName)`

檢查指定名稱的模板是否存在（DB 快取、本地文件或通配符模板中任一處存在即為 `true`）。

| 參數 | 型別 | 說明 |
|---|---|---|
| `fltName` | `String` | 模板檔案名稱 |

- **回傳值：** `boolean` — 模板存在回傳 `true`，不存在或發生例外回傳 `false`

**使用案例：**
```java
if (tmplEngine.hasTemplate("txn_notify.ftl")) {
    // 處理通知模板
}
```

---

###### `void process(String flt, Object rootMap, Writer out) throws TemplateException, IOException`

渲染模板並將結果輸出至指定的 `Writer`。

| 參數 | 型別 | 說明 |
|---|---|---|
| `flt` | `String` | 模板檔案名稱 |
| `rootMap` | `Object` | 模板資料模型（通常為 `Map<String, Object>`） |
| `out` | `Writer` | 輸出目標 |

- **拋出：** `TemplateException` — 模板渲染錯誤（含 `BizzException` 的訊息提取）；`IOException` — IO 錯誤

**使用案例：**
```java
Map<String, Object> dataModel = new HashMap<>();
dataModel.put("svc", chnlBaseTools);
dataModel.put("mem", memMap);
StringWriter writer = new StringWriter();
tmplEngine.process("txn_req.ftl", dataModel, writer);
String result = writer.toString();
```

---

###### `String process(String flt, Object rootMap) throws TemplateException, IOException`

渲染模板並以字串形式回傳結果。內部建立 `ByteArrayOutputStream` 搭配 `BufferedWriter`，呼叫另一個 `process` 多載方法後將結果轉為 UTF-8 字串。

| 參數 | 型別 | 說明 |
|---|---|---|
| `flt` | `String` | 模板檔案名稱 |
| `rootMap` | `Object` | 模板資料模型 |

- **回傳值：** `String` — 模板渲染後的字串結果
- **拋出：** `TemplateException`、`IOException`

**使用案例：**
```java
Map<String, Object> dataModel = new HashMap<>();
dataModel.put("svc", chnlBaseTools);
String requestBody = tmplEngine.process("txn_req.ftl", dataModel);
```

---

###### 屬性存取方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `getClazz()` | `Class` | 取得渠道服務類別 |
| `setClazz(Class clazz)` | `void` | 設定渠道服務類別 |
| `getCatalog()` | `String` | 取得渠道代碼 |
| `setCatalog(String catalog)` | `void` | 設定渠道代碼 |
| `isThrowTemplateError()` | `boolean` | 取得是否拋出模板錯誤（預設 `true`） |
| `setThrowTemplateError(boolean)` | `void` | 設定是否拋出模板錯誤 |

---

#### Protected 部分

##### 方法

###### `void initConfig()`

初始化 FreeMarker `Configuration` 與 `StringTemplateLoader`。設定預設編碼為 `ENCODING`（UTF-8），並註冊自訂的 `TMPL_ERROR_HANDLER` 作為模板例外處理器。

**說明：** 由 `getConfig()` 在首次呼叫時自動觸發。

---

###### `StringTemplateLoader getTmplLoader()`

取得當前的 `StringTemplateLoader` 實例。透過 `getConfig().getTemplateLoader()` 取得，確保 `Configuration` 已初始化。

- **回傳值：** `StringTemplateLoader` — 字串模板載入器

---

###### `String readLocalTmplFile(String tmplName)`

從 classpath 讀取本地模板文件內容。模板路徑格式為：
```
chnlTemplate/{catalog}/{clazz.simpleName}/{tmplName}
```

| 參數 | 型別 | 說明 |
|---|---|---|
| `tmplName` | `String` | 模板檔案名稱 |

- **回傳值：** `String` — 模板內容字串；若文件不存在或讀取失敗回傳 `null`

**說明：** 使用 `ClsUtils.getClassLoader(clazz)` 取得 ClassLoader，以 UTF-8 編碼讀取。找不到資源或讀取失敗時記錄錯誤日誌並回傳 `null`。

---

###### `ChnlTemplate tryReadTmplFromLocalFile(String ftlName)`

嘗試從本地文件讀取模板，若讀取成功則透過 `TxnChnlTemplateCache.tryInsertTemplate()` 將模板內容寫入資料庫快取。

| 參數 | 型別 | 說明 |
|---|---|---|
| `ftlName` | `String` | 模板檔案名稱 |

- **回傳值：** `ChnlTemplate` — 模板資料模型物件；若本地文件不存在回傳 `null`

---

###### `ChnlTemplate getTmplFromCache(String ftlName)`

依優先順序取得模板的核心方法：

1. 從 `TxnChnlTemplateCache.getTemplate(catalog, className, ftlName)` 讀取 DB 快取
2. 若快取未命中，呼叫 `tryReadTmplFromLocalFile()` 從本地文件讀取並寫入快取
3. 若本地文件也不存在，以通配符 `*` 作為 className 再次查詢快取（`TxnChnlTemplateCache.getTemplate(catalog, "*", ftlName)`）

| 參數 | 型別 | 說明 |
|---|---|---|
| `ftlName` | `String` | 模板檔案名稱 |

- **回傳值：** `ChnlTemplate` — 模板資料模型物件；若所有來源皆無模板則回傳 `null`

**使用案例（內部呼叫流程）：**
```
getTemplate("txn_req.ftl")
  └─ getTmplFromCache("txn_req.ftl")
       ├─ TxnChnlTemplateCache.getTemplate("CHNL001", "com.xxx.MyService", "txn_req.ftl")  // 1. DB快取
       ├─ tryReadTmplFromLocalFile("txn_req.ftl")  // 2. 本地文件 → 寫入快取
       └─ TxnChnlTemplateCache.getTemplate("CHNL001", "*", "txn_req.ftl")  // 3. 通配符模板
```
