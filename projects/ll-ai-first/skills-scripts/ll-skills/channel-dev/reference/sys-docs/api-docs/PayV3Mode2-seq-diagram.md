# PayV3Mode2 交互模式順序圖

`com.icpay.payment.service.channel.common.PayV3Mode2`

PayV3Mode2 繼承自 `PayV3Mode1 → MyChnlBaseV2 → ChnlServiceBase`，屬於 **Mode2（兩段式交互模式）**。與 Mode1 不同，Mode2 的支付請求分為兩個階段：服務先組裝請求（`doConvRequest`），由系統代發 HTTP 請求，再由服務處理同步回應（`doConvSyncResultForAsync`）。此外，`doCommonTrans` 方法也可將兩階段合併為一步完成。

異步通知（`doConvResult`）與交易查詢（`doQuery`）流程繼承自 PayV3Mode1，未覆寫。

---

## 1. 支付請求流程（兩段式）

### 1.1 第一階段：組裝請求（doConvRequest）

系統呼叫 `convRequest()` 時，PayV3Mode2 組裝渠道請求報文並回傳 `ChnlRequestContext`（InteractiveMode = **Async**），由系統代為發送 HTTP 請求。

```mermaid
sequenceDiagram
    autonumber
    participant Core as 核心系統
    participant SvcBase as ChnlServiceBase
    participant V3M2 as PayV3Mode2
    participant SignSvc as SignatureService
    participant FTL as FreeMarker 模板引擎

    Core->>SvcBase: convRequest(req, params)
    SvcBase->>V3M2: doConvRequest(req, params)

    Note over V3M2: reqParams = merge(req, params)
    Note over V3M2: 取得渠道請求 URL（url.txn.req）

    %% 簽名階段
    alt shouldSignRequest() = true
        V3M2->>SignSvc: signatureSvc(true) 建構簽名服務實例
        V3M2->>SignSvc: setSignTemplateName("txn_req_sign.ftl")
        V3M2->>SignSvc: stage(TXN_REQUEST)
        V3M2->>SignSvc: sign(reqParams, null, signedMap)
        SignSvc->>FTL: 渲染簽名模板
        FTL-->>SignSvc: 待簽字串
        SignSvc-->>V3M2: signedMap（含簽名值）
    else shouldSignRequest() = false
        Note over V3M2: signedMap = reqParams（不簽名）
    end

    %% 組裝請求報文
    Note over V3M2: allReqParams = merge(reqParams, signedMap)
    V3M2->>FTL: translateByTemplate("txn_req.ftl", allReqParams)
    FTL-->>V3M2: chnlReqStr（渠道請求報文）

    %% 可選：組裝自訂 Header
    opt useTemplateForRequestHeader = true
        V3M2->>FTL: translateByTemplate("txn_req_header.ftl", allReqParams)
        FTL-->>V3M2: headers
    end

    Note over V3M2: assign headers 至 mem.reqHdr

    %% 建構請求上下文
    alt requestMode = FORM_JSON
        Note over V3M2: Content-Type: application/x-www-form-urlencoded
        Note over V3M2: 將報文轉為 Map，設定 requestDataByMap
    else requestMode = JSON_JSON
        Note over V3M2: Content-Type: application/json
        Note over V3M2: 直接設定 requestData（JSON 字串）
    end

    Note over V3M2: InteractiveMode = Async（由系統代發請求）

    V3M2-->>SvcBase: ChnlRequestContext（Async 模式）
    SvcBase-->>Core: ChnlRequestContext
    Note over Core: 系統根據 ChnlRequestContext 代發 HTTP 請求至渠道
```

### 1.2 第二階段：處理同步回應（doConvSyncResultForAsync）

系統代發 HTTP 請求後，將渠道的同步回應交由 `doConvSyncResultForAsync` 處理。

```mermaid
sequenceDiagram
    autonumber
    participant Core as 核心系統
    participant SvcBase as ChnlServiceBase
    participant V3M2 as PayV3Mode2
    participant SignSvc as SignatureService
    participant FTL as FreeMarker 模板引擎

    Note over Core: 系統已代發 HTTP 請求並收到渠道回應

    Core->>SvcBase: convSyncResultForAsync(chnlResp, params)
    SvcBase->>V3M2: doConvSyncResultForAsync(chnlResp, params)

    Note over V3M2: 檢查 chnlResp 非空（空則拋 ChnlBizException Z_7001）

    %% 同步回應驗章
    opt shouldCheckSignForRequest() = true
        V3M2->>SignSvc: signatureSvc(true) 建構簽名服務實例
        V3M2->>SignSvc: stage(TXN_RESPONSE)
        opt shouldCheckSignForRequestByTmpl() = true
            V3M2->>SignSvc: setSignTemplateName("txn_sync_resp_sign.ftl")
        end
        V3M2->>SignSvc: checkSign(chnlResp, params)
        SignSvc-->>V3M2: 驗章結果（失敗則拋 ChnlBizException Z_7012）
    end

    %% 解析同步回應
    Note over V3M2: chnlRespMap = toMap(chnlResp)
    V3M2->>FTL: translateByTemplate("txn_sync_resp.ftl", merge(params, chnlRespMap))
    FTL-->>V3M2: respMap（系統內部格式）

    Note over V3M2: 建立 TxnAsyncResultContext（InteractiveMode = Async）

    V3M2-->>SvcBase: TxnAsyncResultContext
    SvcBase-->>Core: TxnAsyncResultContext
```

### 1.3 合併模式：doCommonTrans（服務端完整交互）

`doCommonTrans` 將兩段式流程合併為一步：服務自行組裝請求、發送 HTTP、處理回應。可由子類或其他方法直接呼叫。

```mermaid
sequenceDiagram
    autonumber
    participant Caller as 呼叫方
    participant V3M2 as PayV3Mode2
    participant SignSvc as SignatureService
    participant FTL as FreeMarker 模板引擎
    participant HTTP as HttpProxyHelper
    participant Chnl as 渠道 API

    Caller->>V3M2: doCommonTrans(req, params)

    %% 第一階段：組裝請求
    V3M2->>V3M2: doConvRequest(req, params)
    Note over V3M2: （詳見 1.1 組裝請求流程）
    Note over V3M2: 回傳 ChnlRequestContext

    %% 發送 HTTP 請求
    V3M2->>HTTP: httpProxy(chnlMerId).url(requestUrl)
    V3M2->>HTTP: encoding / Content-Type / headers

    alt requestMode = FORM_JSON
        alt chnlReqMethod = GET
            HTTP->>Chnl: HTTP GET（Form 參數）
        else chnlReqMethod = POST
            HTTP->>Chnl: HTTP POST（Form 參數）
        end
    else requestMode = JSON_JSON
        alt chnlReqMethod = GET
            HTTP->>Chnl: HTTP GET（JSON Body）
        else chnlReqMethod = POST
            HTTP->>Chnl: HTTP POST（JSON Body）
        end
    end

    Chnl-->>HTTP: HTTP 回應
    HTTP-->>V3M2: chnlResp0（HttpClientResponse）

    %% 第二階段：處理同步回應
    V3M2->>V3M2: doConvSyncResultForAsync(chnlResp0.body, merge(req, params))
    Note over V3M2: （詳見 1.2 處理同步回應流程）

    Note over V3M2: 建立 TxnResultContext（InteractiveMode = Async）

    V3M2-->>Caller: TxnResultContext
```

## 2. 異步通知（回調）處理流程

繼承自 PayV3Mode1，流程不變。

```mermaid
sequenceDiagram
    autonumber
    participant Chnl as 渠道 API
    participant GW as 閘道層
    participant SvcBase as ChnlServiceBase
    participant V3M1 as PayV3Mode1（繼承）
    participant SignSvc as SignatureService
    participant FTL as FreeMarker 模板引擎

    Chnl->>GW: 異步通知（HTTP POST）
    GW->>SvcBase: convResult3(chnlResp, params, extParams, headers)
    SvcBase->>V3M1: doConvResult(chnlResp, params, extParams, headers)

    Note over V3M1: 解析 chnlResp 為 Map（若非空）
    Note over V3M1: notifyParams = merge(extParams, params, chnlRespMap)
    Note over V3M1: 設定渠道關鍵參數（channel, chnlMerId, intTxnType）
    Note over V3M1: 儲存 headers 至 mem.rspHdr

    %% 驗章
    alt shouldCheckSignForNotify() = true
        V3M1->>SignSvc: signatureSvc(true) 建構簽名服務實例
        alt notifyMode = FORM
            opt shouldCheckSignForNotifyByTemplate() = true
                V3M1->>SignSvc: setSignTemplateName("txn_notify_sign.ftl")
            end
            V3M1->>SignSvc: stage(NOTIFY)
            V3M1->>SignSvc: checkSign(params, notifyParams)
        else notifyMode = JSON
            opt shouldCheckSignForNotifyByTemplate() = true
                V3M1->>SignSvc: setSignTemplateName("txn_notify_sign.ftl")
            end
            V3M1->>SignSvc: stage(NOTIFY)
            V3M1->>SignSvc: checkSign(chnlRespMap, notifyParams)
        end
        SignSvc-->>V3M1: 驗章結果（失敗則拋 ChnlBizException）
    end

    %% 模板轉換
    V3M1->>FTL: translateByTemplate("txn_notify.ftl", notifyParams)
    FTL-->>V3M1: respMap（系統內部格式）

    Note over V3M1: 建立 TxnAsyncResultContext
    Note over V3M1: respToChannel = "success"

    V3M1-->>SvcBase: TxnAsyncResultContext
    SvcBase-->>GW: TxnAsyncResultContext
    GW-->>Chnl: 回應 "success"
```

## 3. 交易查詢流程

繼承自 PayV3Mode1，流程不變。

```mermaid
sequenceDiagram
    autonumber
    participant Core as 核心系統 / 輪詢
    participant SvcBase as ChnlServiceBase
    participant V3M1 as PayV3Mode1（繼承）
    participant SignSvc as SignatureService
    participant FTL as FreeMarker 模板引擎
    participant HTTP as HttpProxyHelper
    participant Chnl as 渠道 API

    Core->>SvcBase: query(req, params)
    SvcBase->>V3M1: doQuery(req, params)

    Note over V3M1: reqParams = merge(req, params)
    Note over V3M1: 取得查詢 URL（url.txn.query）

    %% 簽名
    alt shouldSignQryRequest() = true
        V3M1->>SignSvc: signatureSvc(true)
        V3M1->>SignSvc: setSignTemplateName("txnQry_req_sign.ftl")
        V3M1->>SignSvc: stage(QRY_REQUEST)
        V3M1->>SignSvc: sign(reqParams, null, signedMap)
        SignSvc-->>V3M1: signedMap
    end

    %% 組裝查詢報文
    V3M1->>FTL: translateByTemplate("txnQry_req.ftl", allReqParams)
    FTL-->>V3M1: chnlReqStr

    opt useTemplateForQueryHeader = true
        V3M1->>FTL: translateByTemplate("txnQry_req_header.ftl", allReqParams)
        FTL-->>V3M1: headers
    end

    Note over V3M1: calcUrl() 解析 URL 變數

    %% 發送查詢請求
    V3M1->>HTTP: send(httpHelper, reqBody)
    HTTP->>Chnl: HTTP POST/GET 查詢請求
    Chnl-->>HTTP: HTTP 回應
    HTTP-->>V3M1: chnlResp0

    Note over V3M1: 檢查回應非空，儲存回應 Header

    %% 查詢回應驗章
    opt shouldCheckSignForQry() = true
        V3M1->>SignSvc: stage(QRY_RESPONSE)
        V3M1->>SignSvc: checkSign(chnlResp0.body, reqParams)
        SignSvc-->>V3M1: 驗章結果
    end

    %% 解析查詢結果
    V3M1->>FTL: translateByTemplate("txnQry_resp.ftl", merge(reqParams, chnlRespMap))
    FTL-->>V3M1: respMap

    V3M1-->>SvcBase: TxnResultContext
    SvcBase-->>Core: TxnResultContext
```

---

## Mode1 vs Mode2 對比

| 項目 | PayV3Mode1（Mode1） | PayV3Mode2（Mode2） |
|------|---------------------|---------------------|
| **交互模式** | 服務端完整交互 | 兩段式交互 |
| **doConvRequest** | 呼叫 `doCommonTrans` 完成 HTTP 交互，回傳 **Redirect** | 僅組裝請求報文，回傳 **Async**，由系統代發 |
| **doConvSyncResultForAsync** | 回傳 `null`（不需要） | 處理系統代發後的渠道同步回應 |
| **doCommonTrans** | 組裝 → 發送 HTTP → 解析回應（一步完成） | 覆寫：組裝 → 發送 HTTP → 解析回應（一步完成，供內部使用） |
| **InteractiveMode** | `Redirect`（跳轉） | `Async`（異步等待結果） |
| **異步通知** | 繼承 PayV3Mode1 | 繼承 PayV3Mode1（相同） |
| **交易查詢** | 自行實作 | 繼承 PayV3Mode1（相同） |

---

## 角色對照表

| 順序圖角色 | 完整類別名稱 |
|-----------|-------------|
| 核心系統 | `com.icpay.payment.service.OnlTxnChnlServiceEx`（介面，由核心系統呼叫） |
| ChnlServiceBase | `com.icpay.payment.common.utils.ChnlServiceBase` |
| PayV3Mode2 | `com.icpay.payment.service.channel.common.PayV3Mode2` |
| PayV3Mode1（繼承） | `com.icpay.payment.service.channel.common.PayV3Mode1`（異步通知與查詢邏輯） |
| SignatureService | `com.icpay.payment.common.utils.ChnlSignatureServiceBase`（抽象基類，實際由 `extConfig.signatureService` 指定具體實作） |
| FreeMarker 模板引擎 | `com.icpay.payment.common.utils.ChnlBaseTools.translateByTemplate()` 驅動，模板位於 `templates/chnlTemplate/{渠道代碼}/` |
| HttpProxyHelper | `com.icpay.payment.service.HttpProxyHelper` |
| 閘道層 | `com.icpay.payment.gateway`（閘道 Servlet，負責接收渠道異步通知並分派至對應服務） |
| 渠道 API | 外部第三方支付渠道 HTTP 端點 |

---

## 重點說明

### 架構定位

| 項目 | 說明 |
|------|------|
| **類別** | `PayV3Mode2 → PayV3Mode1 → MyChnlBaseV2 → ChnlServiceBase → ChnlBaseTools` |
| **模式** | Mode2 — 兩段式交互，服務組裝請求交由系統發送，再由服務處理回應 |
| **交互結果** | 支付請求回傳 `Async`（系統代發 HTTP 請求，非跳轉），後續由渠道異步通知結果 |

### 覆寫方法與繼承關係

| 方法 | 來源 | 說明 |
|------|------|------|
| `doConvRequest()` | **PayV3Mode2 覆寫** | 組裝請求報文，InteractiveMode = Async |
| `doConvSyncResultForAsync()` | **PayV3Mode2 覆寫** | 處理渠道同步回應（驗章 + 模板轉換） |
| `doCommonTrans()` | **PayV3Mode2 覆寫** | 合併兩段式流程：組裝 → HTTP → 回應處理 |
| `doConvResult()` | PayV3Mode1 繼承 | 異步通知處理 |
| `doQuery()` | PayV3Mode1 繼承 | 交易查詢 |

### 使用到的模板

| 階段 | 模板 | 說明 |
|------|------|------|
| **支付請求** | `txn_req_sign.ftl` | 交易請求簽名 |
| | `txn_req.ftl` | 交易請求報文（簽名完成後） |
| | `txn_req_header.ftl` | 請求 Header（可選） |
| **同步回應** | `txn_sync_resp_sign.ftl` | 同步回應驗章（可選） |
| | `txn_sync_resp.ftl` | 同步回應解析 |
| **異步通知** | `txn_notify_sign.ftl` | 通知驗章（可選） |
| | `txn_notify.ftl` | 通知報文轉換 |
| **交易查詢** | `txnQry_req_sign.ftl` | 查詢請求簽名 |
| | `txnQry_req.ftl` | 查詢請求報文 |
| | `txnQry_req_header.ftl` | 查詢請求 Header（可選） |
| | `txnQry_resp_sign.ftl` | 查詢回應驗章（可選） |
| | `txnQry_resp.ftl` | 查詢回應解析 |

### 配置驅動的開關控制

所有簽名/驗章行為由 `MerParams` 資料庫參數控制，預設值如下：

| 參數 | 預設值 | 作用 |
|------|--------|------|
| `sign.action.req.sign` | `1`（啟用） | 支付請求是否簽名 |
| `sign.action.resp.check` | `0`（停用） | 同步回應是否驗章 |
| `sign.action.resp.check.by.template` | `0`（停用） | 驗章是否使用模板 |
| `sign.action.notify.check` | `1`（啟用） | 異步通知是否驗章 |
| `sign.action.notify.check.by.template` | `0`（停用） | 通知驗章是否使用模板 |
| `sign.action.qry.sign` | `1`（啟用） | 查詢請求是否簽名 |
| `sign.action.qry.check` | `1`（啟用） | 查詢回應是否驗章 |
| `sign.action.qry.check.by.template` | `0`（停用） | 查詢驗章是否使用模板 |

### extConfig 靜態配置

| 參數 | 預設值 | 說明 |
|------|--------|------|
| `requestMode` | `FORM_JSON` | 請求格式：`FORM_JSON`（表單）或 `JSON_JSON`（JSON） |
| `notifyMode` | `FORM` | 異步通知格式：`FORM`（表單）或 `JSON` |
| `signatureService` | （必填） | 簽名服務類別全名 |
| `chnlReqMethod` | `POST` | HTTP 方法：`GET` 或 `POST` |
| `useTemplateForRequestHeader` | `0` | 是否用模板組裝交易請求 Header |
| `useTemplateForQueryHeader` | `0` | 是否用模板組裝查詢請求 Header |
| `templateNamePrefix` | `""` | 模板名稱前綴，用於區隔不同交易類型的模板集 |
| `trimTemplate` | `false` | 是否去除模板輸出的首尾空白 |
