# MyChnlBaseV2 — 配置驅動線上渠道支付基類（V2）

類別名稱：`com.icpay.payment.service.channel.common.MyChnlBaseV2`

## 說明

第二代線上渠道支付抽象基類，採用**配置驅動**設計，將簽名/驗章/加解密行為委派給可配置的服務類別（`ChnlSignatureServiceBase` / `ChnlEncryptionServiceBase`），而非在基類中硬編碼。透過 `extConfig`（靜態配置）和 `MerParams`（動態參數）控制渠道行為，是目前主要使用的基類。

### 使用到的 MerParams 參數（para_cat 為交易類）

| 參數 | 說明 | 預設值 |
|---|---|---|
| `sign.action.req.sign` | 請求是否簽名 | `1` |
| `sign.action.resp.check` | 同步回應是否驗章 | `0` |
| `sign.action.resp.check.by.template` | 同步回應驗章是否用模板 | `0` |
| `sign.action.notify.check` | 異步通知是否驗章 | `1` |
| `sign.action.notify.check.by.template` | 異步通知驗章是否用模板 | `0` |
| `sign.action.qry.sign` | 查詢請求是否簽名 | `1` |
| `sign.action.qry.check` | 查詢回應是否驗章 | `1` |
| `sign.field.name` | 簽名欄位名稱 | — |
| `sign.field.ignore.names` | 簽名忽略欄位 | — |
| `encrypt.action.req` | 請求是否加密 | `0` |
| `decrypt.action.resp` | 同步回應是否解密 | `0` |
| `decrypt.action.notify` | 回調是否解密 | `0` |

### 使用到的 ExtConfig 參數

| 參數 | 說明 | 預設值 |
|---|---|---|
| `signatureService` | 簽名服務類別完整名稱 | — |
| `encryptionService` | 加密服務類別完整名稱 | — |
| `requestMode` | 請求格式：`FORM_JSON` / `JSON_JSON` | `FORM_JSON` |
| `notifyMode` | 回調模式：`FORM` / `JSON` | `FORM` |
| `chnlReqMethod` | HTTP 方法：`GET` / `POST` | `POST` |
| `templateNamePrefix` | 模板名稱前綴 | `""` |
| `useTemplateForRequestHeader` | 是否使用模板產生請求頭 | `0` |
| `useTemplateForQueryHeader` | 是否使用模板產生查詢請求頭 | `0` |
| `trimTemplate` | 是否去除模板空格 | `false` |
| `removeEmptyForReq` | 請求是否移除空欄位 | `false` |

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `ChnlServiceBase` → `ChnlBaseTools`
- **已知子類別**: `PayV2Mode1`, `PayV2Mode2`, `PayV2Mode2Sec`, `PayV2Mode2SecVariation`, `PayV3Mode1`, `PayV3Mode1USDTCOBO`
- **主要相依性**:
  - `ChnlSignatureServiceBase` — 簽名服務抽象基類
  - `ChnlEncryptionServiceBase` — 加密服務抽象基類
  - `HttpProxyHelper` — HTTP 代理工具
  - `ClsUtils` — 動態類別載入工具

## API說明

### Class: MyChnlBaseV2

#### Public 部分

##### 建構式

| 建構式 | 說明 |
|---|---|
| `MyChnlBaseV2()` | 預設建構式 |

##### 參數查詢方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `getMerParamW(String[], String, String)` | `String` | 依多個 catalog 查詢商戶參數 |
| `getMerParamW(String, String)` | `String` | 依交易類查詢商戶參數（搜尋順序：交易類 → PARAM → *） |
| `ensureMap(Map)` | `Map<String, ?>` | 確保 Map 不為 null，若為 null 則回傳空 Map |

##### URL 處理方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `calcUrl(String, Map)` | `String` | 解析 URL 中的 `${var}` 變數並替換為 model 中的值 |

##### 日誌方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `debugLog(Object)` | `void` | 可在 FreeMarker 模板中呼叫的 debug 日誌 |
| `infoLog(Object)` | `void` | 可在 FreeMarker 模板中呼叫的 info 日誌 |

使用範例：
```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
${svc.debugLog("目前處理的訂單號: " + orderId)}
${svc.infoLog("渠道回應成功")}
```

##### 模板處理方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `translateByTemplate(String, Object)` | `String` | 覆寫父類方法，支援 `trimTemplate` 配置 |

#### Protected 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|---|---|---|---|
| `CAT_COMMON` | `String` | `"COMMON"` | 參數類別：通用 |
| `CAT_PAY` | `String` | `"PAY"` | 參數類別：支付 |
| `CAT_PAY_NOTIFY` | `String` | `"PAY_NOTIFY"` | 參數類別：支付回調 |
| `CAT_WITHDRAW` | `String` | `"WITHDRAW"` | 參數類別：提現 |
| `CAT_WITHDRAW_NOTIFY` | `String` | `"WITHDRAW_NOTIFY"` | 參數類別：提現回調 |
| `M_REQ_HEADERS` | `String` | `"reqHdr"` | Memory key：請求 Header |
| `M_RESP_HEADERS` | `String` | `"rspHdr"` | Memory key：回應 Header |
| `M_SIGN_SRC` | `String` | `"sgSrc"` | Memory key：待簽內容 |
| `MODE_FORM_JSON` | `String` | `"FORM_JSON"` | 請求模式常數 |
| `MODE_JSON_JSON` | `String` | `"JSON_JSON"` | 請求模式常數 |
| `MODE_JSON` | `String` | `"JSON"` | 回調模式常數 |
| `MODE_FORM` | `String` | `"FORM"` | 回調模式常數 |

##### 屬性

| 屬性 | 類型 | 說明 |
|---|---|---|
| `extConfigMap` | `Map` | extConfig 解析後的快取 |
| `encryptionService` | `ChnlEncryptionServiceBase` | 加密服務實例 |

##### 簽名服務管理

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `signatureSvc()` | `ChnlSignatureServiceBase` | 取得簽名服務實例（懶載入） |
| `signatureSvc(boolean)` | `ChnlSignatureServiceBase` | 取得簽名服務實例，可強制建構新實例 |
| `newSignatureSvc()` | `ChnlSignatureServiceBase` | 建構新的簽名服務實例（synchronized） |

使用範例：
```java
// 在支付模式類別中使用簽名服務
signatureSvc(true).setSignTemplateName(tmplName("txn_req_sign.ftl"));
signatureSvc().stage(TxnInteractiveStage.TXN_REQUEST);
signatureSvc().sign(reqParams, null, signedMap);
```

##### 加密服務管理

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `encryptionSvc()` | `ChnlEncryptionServiceBase` | 取得加密服務實例（懶載入） |
| `encryptionSvc(boolean)` | `ChnlEncryptionServiceBase` | 取得加密服務實例，可強制建構新實例 |
| `newEncryptionSvc()` | `ChnlEncryptionServiceBase` | 建構新的加密服務實例（synchronized） |

##### 配置讀取方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `getExtConfigMap()` | `Map` | 取得 extConfig 的 Map |
| `extConfig(String)` | `String` | 讀取 extConfig 值 |
| `extConfig(String, String)` | `String` | 讀取 extConfig 值，支援預設值 |
| `getConfRequestMode()` | `String` | 請求格式 |
| `getConfNotifyMode()` | `String` | 回調模式 |
| `getConfRemoveEmptyForRequest()` | `Boolean` | 請求是否移除空欄位 |
| `getChnlRequestMethod()` | `HttpMethod` | HTTP 方法 |

##### 行為開關方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `shouldSignRequest()` | `boolean` | 交易請求是否需要簽名 |
| `shouldCheckSignForRequest()` | `boolean` | 同步回應是否需要驗章 |
| `shouldCheckSignForRequestByTmpl()` | `boolean` | 驗章時是否使用模板 |
| `shouldCheckSignForNotify()` | `boolean` | 異步通知是否需要驗章 |
| `shouldCheckSignForNotifyByTemplate()` | `boolean` | 異步通知驗章是否用模板 |
| `shouldSignQryRequest()` | `boolean` | 查詢請求是否需要簽名 |
| `shouldCheckSignForQry()` | `boolean` | 查詢回應是否需要驗章 |
| `shouldCheckSignForQueryByTmpl()` | `boolean` | 查詢驗章是否用模板 |
| `shouldEncryptRequest()` | `boolean` | 交易請求是否需要加密 |
| `shouldDecryptForResponse()` | `boolean` | 同步回應是否需要解密 |
| `shouldEncryptRequestForQuery()` | `boolean` | 查詢請求是否需要加密 |
| `shouldDecryptForQueryResponse()` | `boolean` | 查詢回應是否需要解密 |
| `shouldDecryptForNotify()` | `boolean` | 回調是否需要解密 |
| `shouldUserTemplateForReqHeader()` | `boolean` | 是否用模板產生交易請求頭 |
| `shouldUserTemplateForQueryHeader()` | `boolean` | 是否用模板產生查詢請求頭 |
| `shouldTrimTemplate()` | `boolean` | 是否去除模板空格 |

##### HTTP 發送方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `send(HttpProxyHelper, String)` | `HttpClientResponse` | 發送 HTTP 請求（字串 body） |
| `send(HttpProxyHelper, Map)` | `HttpClientResponse` | 發送 HTTP 請求（Map 表單） |

##### 其他工具方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `tmplName(String)` | `String` | 加上模板名稱前綴 |
| `setChnlCirtialParams(Map)` | `void` | 從 Map 中設定 channel、chnlMerId、intTxnType |
| `tryRemoveEmptyForRequest(Map)` | `Map` | 依配置嘗試移除空欄位 |
| `getJwt(Map, String)` | `String` | 從 Header 中提取 JWT |
| `putJwt(Map, String, String)` | `boolean` | 將 JWT 寫入 Header（帶 Bearer 前綴） |
| `resolveValue(String, Map)` | `String` | 解析 URL 佔位符的值（URL 編碼） |
| `classLoader()` | `ClassLoader` | 取得 ClassLoader（用於動態載入簽名/加密服務） |
| `tryLogChnlQryResult(Map, String)` | `void` | 嘗試記錄渠道查詢結果（非成功時記錄） |
