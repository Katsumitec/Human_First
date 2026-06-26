# ChnlServiceBase — 渠道交易服務抽象基類

類別名稱：`com.icpay.payment.common.utils.ChnlServiceBase`

## 說明

`ChnlServiceBase` 是渠道交易服務的核心抽象基類，定義了支付請求轉換、交易結果轉換、交易查詢、通用交易等完整的渠道交互流程框架。此類繼承自 `ChnlBaseTools`，並實作 `OnlTxnChnlServiceEx` 介面。

核心系統會建立此類（的子類）實例，建立時會指定渠道編號、交易類型、商戶號等屬性，可透過 `getChannel()`、`getIntTxnType()`、`getChnlMerId()` 取得。

重要設計特性：
- 報文轉換模板配置於資料表 `tbl_chnl_template` 中
- 渠道響應碼配置於資料表 `tbl_chnl_translate` 中
- 此類及子類中所有 public 方法都可以在 FreeMarker 模板中借由 `svc` 工具來使用
- `svc` 的內建工具方法可參考 `ChnlBaseTools`

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **繼承**: `ChnlBaseTools` (基礎工具類 / FreeMarker 模板工具)
- **實作介面**: `OnlTxnChnlServiceEx` (線上交易渠道服務擴展介面)
- **已知子類別**: `ChnlServiceWithCasherBase` (含收銀台功能的交易服務基類)
- **主要相依性**:
  - `ChnlBaseTools` — 基礎工具類，提供 FreeMarker 模板處理、日誌、配置讀取等能力
  - `ChnlRequestContext` — 渠道請求上下文
  - `TxnAsyncResultContext` — 非同步交易結果上下文
  - `TxnResultContext` — 同步交易結果上下文
  - `TxnChnlServiceInfo` — 渠道服務資訊
  - `TxnInteractiveStage` — 交易交互階段列舉
  - `ChnlBizException` — 渠道業務異常
  - `RspCd` — 響應碼常數

繼承體系全覽：

```
ChnlBaseTools (基礎工具 / FreeMarker 模板工具)
└── ChnlServiceBase (本類：渠道交易服務抽象基類)
    └── ChnlServiceWithCasherBase (含收銀台的交易服務)
        ├── MyChnlBase → MyChnlBaseV2 (配置驅動 V3 模式)
        │   ├── PayV3Mode1 / PayV3Mode2 / PayV3Mode3
        │   └── PayV2Mode1 / PayV2Mode2
        └── MyChnlBaseV5 (配置驅動 V5 模式)
            └── PayV5Mode1
```

## API說明

### Class: ChnlServiceBase

此為 `abstract` 類別，不可直接實例化。子類需實作五個 abstract 方法以完成渠道交互邏輯。

---

#### Public 部分

##### 屬性（透過 getter/setter 存取）

| 屬性 | 類型 | 說明 |
|---|---|---|
| `extConfig` | `String` | 渠道服務擴展設定（JSON 格式），定義在 `templates/chnlTemplate/{渠道代碼}/ext_configs.md` |
| `tags` | `String` | 渠道服務標籤 |

##### 方法

###### `stage(TxnInteractiveStage stage)` / `stage(String stage)`

設定服務的交易交互階段，回傳 `this` 以支援鏈式呼叫。

| 參數 | 類型 | 說明 |
|---|---|---|
| `stage` | `TxnInteractiveStage` 或 `String` | 交互階段。列舉值包含：`NONE`、`TXN_REQUEST`、`TXN_RESPONSE`、`QRY_REQUEST`、`QRY_RESPONSE`、`NOTIFY` |

| 回傳 | 說明 |
|---|---|
| `ChnlServiceBase` | 自身實例（鏈式呼叫） |

使用範例：
```java
// 設定交易交互階段為請求階段
service.stage(TxnInteractiveStage.TXN_REQUEST);

// 使用字串設定
service.stage("TxnRequest");
```

---

###### `getExtConfig()` / `setExtConfig(String extConfig)`

取得或設定渠道服務擴展設定。`extConfig` 為 JSON 格式字串，控制請求格式、簽名服務類、HTTP 方法等渠道行為。

使用範例：
```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#assign config = svc.getExtConfig()>
```

---

###### `getTags()` / `setTags(String tags)`

取得或設定渠道服務標籤。

---

###### `getServiceInfo()`

取得渠道服務資訊，回傳包含渠道編號與交易類型的 `TxnChnlServiceInfo` 物件。

| 回傳 | 說明 |
|---|---|
| `TxnChnlServiceInfo` | 包含 `channel` 及 `intTxnType` 的服務資訊 |

---

###### `convRequest(Map<String, String> req, Map<String, String> params)`

轉換支付請求至渠道側格式。此方法為 `OnlTxnChnlServiceEx` 介面的實作，內部委派給 `doConvRequest()`。若發生 `ChnlBizException` 會直接拋出；其他異常則轉換為 `Z_7015` 錯誤碼。

| 參數 | 類型 | 說明 |
|---|---|---|
| `req` | `Map<String, String>` | ICPAY 支付請求 |
| `params` | `Map<String, String>` | 其他參數（保留） |

| 回傳 | 說明 |
|---|---|
| `ChnlRequestContext` | 渠道側支付請求（可能是 JSON 或 XML 等格式） |

---

###### `convResult(String chnlResp, Map<String, String> params)`

轉換渠道側非同步通知（後台通知）至 ICPAY 格式。不會拋出異常，錯誤會被轉換成響應結果。內部委派給 `doConvResult()`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側後台通知（可能是 JSON 或 XML 等） |
| `params` | `Map<String, String>` | 其他參數 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | ICPAY 後台通知結果 |

---

###### `convResult3(String chnlResp, Map<String, String> params, Map<String, String> extParams, Map<String, String> headers)`

`convResult` 的增強版本，額外支援擴展參數與請求報文頭。內部委派給 `doConvResult()`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側後台通知 |
| `params` | `Map<String, String>` | 其他參數 |
| `extParams` | `Map<String, String>` | 額外擴展參數 |
| `headers` | `Map<String, String>` | 請求報文頭 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | ICPAY 後台通知結果 |

---

###### `convSyncResultForAsync(String chnlResp, Map<String, String> params)`

當交易模式為非同步（Async）時，處理當下同步回傳的資訊。不會拋出異常。內部委派給 `doConvSyncResultForAsync()`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側同步回應 |
| `params` | `Map<String, String>` | 其他參數 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 同步結果 |

---

###### `convFrontResult(String chnlResp, Map<String, String> params)`

轉換渠道側前台（跳轉）通知至 ICPAY 前台通知格式。不會拋出異常。內部委派給 `doConvFrontResult()`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側前台（跳轉）通知 |
| `params` | `Map<String, String>` | 其他參數 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 前台通知結果 |

---

###### `query(Map<String, String> req, Map<String, String> params)`

執行交易查詢，可能由 BM 或輪詢發起。若發生 `ChnlBizException` 會直接拋出；其他異常則轉換為 `Z_7015` 錯誤碼。內部委派給 `doQuery()`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `req` | `Map<String, String>` | ICPAY 支付狀態查詢請求（同步） |
| `params` | `Map<String, String>` | 其他參數（保留） |

| 回傳 | 說明 |
|---|---|
| `TxnResultContext` | 查詢結果 |

---

###### `commonTrans(Map<String, String> req, Map<String, String> params)`

執行其他同步交易。交易送出前的錯誤會直接拋出，交易送出後的錯誤會轉換成響應內容。內部委派給 `doCommonTrans()`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `req` | `Map<String, String>` | ICPAY 請求（同步） |
| `params` | `Map<String, String>` | 其他參數（保留） |

| 回傳 | 說明 |
|---|---|
| `TxnResultContext` | 交易結果 |

---

##### 內部類別

###### `NoExceptionProc`（abstract）

無異常處理器。提供一種安全的業務處理模式：子類在 `procBizz()` 中實作業務邏輯，可放心拋出異常，外層的 `proc()` 方法會自動將異常捕獲並轉換為 `TxnAsyncResultContext` 響應結果。

此模式常用於驗簽等可能失敗的業務邏輯，確保不會因未預期的異常而中斷整體交易流程。

**方法：**

| 方法 | 修飾 | 回傳型別 | 說明 |
|---|---|---|---|
| `procBizz(Map<String, String> context, TxnAsyncResultContext result)` | `protected abstract` | `TxnAsyncResultContext` | 主業務邏輯，可拋出異常 |
| `proc(Map<String, String> context, TxnAsyncResultContext result)` | `public` | `TxnAsyncResultContext` | 執行入口，自動捕獲異常並轉換為錯誤響應 |

使用範例：
```java
// 使用 NoExceptionProc 安全地執行驗簽邏輯
TxnAsyncResultContext checkSignResult = new NoExceptionProc() {
    @Override
    protected TxnAsyncResultContext procBizz(Map<String, String> context, TxnAsyncResultContext result) throws Exception {
        // 業務處理：驗證簽名
        if (!check(sign)) {
            throw new ChnlBizException("1234", "驗簽錯誤");
        }
        return result;
    }
}.proc(params, result);
```

---

#### Protected 部分

##### 抽象方法（子類必須實作）

###### `doConvRequest(Map<String, String> req, Map<String, String> params)`

轉換 ICPAY 支付請求至渠道側支付請求格式。若發生錯誤應直接拋出異常。

| 參數 | 類型 | 說明 |
|---|---|---|
| `req` | `Map<String, String>` | ICPAY 支付請求 |
| `params` | `Map<String, String>` | 其他參數（保留） |

| 回傳 | 說明 |
|---|---|
| `ChnlRequestContext` | 渠道側支付請求（可能是 JSON 或 XML 等） |

使用範例：
```java
@Override
protected ChnlRequestContext doConvRequest(Map<String, String> req, Map<String, String> params) throws Exception {
    // 使用 FreeMarker 模板轉換請求
    String reqBody = translateByTemplate("txn_req.ftl", req);
    ChnlRequestContext ctx = new ChnlRequestContext();
    ctx.setRequestBody(reqBody);
    return ctx;
}
```

---

###### `doConvResult(String chnlResp, Map<String, String> params, Map<String, String> extParams, Map<String, String> headers)`

轉換渠道側後台通知（包含非同步通知 Async/Redirect 及同步回應 Sync）至 ICPAY 後台通知格式。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側後台通知（可能是 JSON 或 XML 等） |
| `params` | `Map<String, String>` | 其他參數 |
| `extParams` | `Map<String, String>` | 額外擴展參數 |
| `headers` | `Map<String, String>` | 請求報文頭 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | ICPAY 後台通知 |

使用範例：
```java
@Override
protected TxnAsyncResultContext doConvResult(String chnlResp, Map<String, String> params,
        Map<String, String> extParams, Map<String, String> headers) throws Exception {
    // 解析渠道回應並轉換為系統結果
    Map<String, String> respMap = parseJson(chnlResp);
    TxnAsyncResultContext result = createDefaultResult(true);
    result.getResult().putAll(respMap);
    return result;
}
```

---

###### `doConvSyncResultForAsync(String chnlResp, Map<String, String> params)`

當交易模式為非同步（Async）時，處理當下同步回傳的資訊。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側同步回應（可能是 JSON 或 XML 等） |
| `params` | `Map<String, String>` | 其他參數 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 同步結果 |

---

###### `doQuery(Map<String, String> req, Map<String, String> params)`

交易查詢，可能由 BM 或輪詢發起。

查詢時系統會帶入以下欄位：

| 欄位 | 說明 |
|---|---|
| `orgIntTxnType` | 原始交易類型碼 |
| `channel` | 渠道編號 |
| `chnlOrderId` | 渠道訂單號 |
| `chnlTxnId` | 渠道交易號 |
| `chnlMerId` | 渠道商戶號 |
| `chnlOrderTime` | 渠道訂單時間 |
| `chnlExtInfo` | 渠道擴展資訊 |
| `txnId` | 交易流水號 |
| `txnAmt` | 交易金額 |
| `chnlTxnFee` | 渠道交易費用 |
| `orderDate` | 訂單日期 |
| `orderTime` | 訂單時間 |
| `orderId` | 商戶訂單號 |
| `merId` | 商戶號 |

> 注意：`getIntTxnType()` 取得的值與 `orgIntTxnType` 相同。

| 回傳 | 說明 |
|---|---|
| `TxnResultContext` | 查詢結果 |

---

###### `doCommonTrans(Map<String, String> req, Map<String, String> params)`

其他同步交易處理。

| 參數 | 類型 | 說明 |
|---|---|---|
| `req` | `Map<String, String>` | ICPAY 請求（同步） |
| `params` | `Map<String, String>` | 其他參數（保留） |

| 回傳 | 說明 |
|---|---|
| `TxnResultContext` | 交易結果 |

---

##### 一般方法

###### `doConvFrontResult(String chnlResp, Map<String, String> params)`

轉換渠道側前台（跳轉）通知至 ICPAY 前台通知格式。預設實作為呼叫 `doConvResult(chnlResp, params, null, null)`，子類可覆寫以提供不同的前台通知處理邏輯。

| 參數 | 類型 | 說明 |
|---|---|---|
| `chnlResp` | `String` | 渠道側前台（跳轉）通知 |
| `params` | `Map<String, String>` | 其他參數 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 前台通知結果 |

---

###### `getAutoPostVersion(String merId, String currCd)`

取得自動提交版本號，透過 `getFrontMerParam()` 從商戶參數中讀取 `autoPostVersion`，預設值為 `"1"`。

| 參數 | 類型 | 說明 |
|---|---|---|
| `merId` | `String` | 商戶號 |
| `currCd` | `String` | 幣別代碼 |

| 回傳 | 說明 |
|---|---|
| `String` | 自動提交版本號 |

---

###### `createDefaultResult(boolean defaultOK)`

建立預設的交易結果實例。

| 參數 | 類型 | 說明 |
|---|---|---|
| `defaultOK` | `boolean` | `true` 表示預設響應為成功（respCode=`00`, respMsg=`Processed`）；`false` 表示預設響應為失敗（respCode=`01`, respMsg=`交易失敗`） |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 新建立的結果實例 |

使用範例：
```java
// 建立預設成功的結果
TxnAsyncResultContext result = createDefaultResult(true);

// 建立預設失敗的結果
TxnAsyncResultContext failResult = createDefaultResult(false);
```

---

###### `toResultByError(Exception err, Map<String, String> context, TxnAsyncResultContext result)`

將異常轉換成系統響應結果。根據異常類型進行不同處理：
- `ChnlBizException`：使用異常中的渠道錯誤碼與訊息
- 其他異常：使用 `_91` 錯誤碼，訊息為 `"錯誤: " + err.getMessage()`

| 參數 | 類型 | 說明 |
|---|---|---|
| `err` | `Exception` | 錯誤 |
| `context` | `Map<String, String>` | 相關報文內容（可選） |
| `result` | `TxnAsyncResultContext` | 欲回傳的實例，若為 `null` 則建立新的實例 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 包含錯誤資訊的響應結果 |

---

###### `toResultByError(String channel, String code, String msg, Map<String, String> context, TxnAsyncResultContext result)`

將錯誤資訊轉換成前端響應結果。內部建立 `ChnlBizException` 後委派給上述 `toResultByError()` 方法。

| 參數 | 類型 | 說明 |
|---|---|---|
| `channel` | `String` | 渠道編號 |
| `code` | `String` | 錯誤碼 |
| `msg` | `String` | 錯誤訊息 |
| `context` | `Map<String, String>` | 相關報文內容（可選） |
| `result` | `TxnAsyncResultContext` | 欲回傳的實例，若為 `null` 則建立新的實例 |

| 回傳 | 說明 |
|---|---|
| `TxnAsyncResultContext` | 包含錯誤資訊的響應結果 |

使用範例：
```java
// 將渠道錯誤轉換為系統響應
TxnAsyncResultContext errorResult = toResultByError("CHNL001", "E001", "渠道回應逾時", params, null);
```

---

###### `printStackTrace(Throwable err)`

將異常堆疊資訊轉換為字串，用於除錯日誌。

| 參數 | 類型 | 說明 |
|---|---|---|
| `err` | `Throwable` | 異常物件 |

| 回傳 | 說明 |
|---|---|
| `String` | 異常堆疊字串 |
