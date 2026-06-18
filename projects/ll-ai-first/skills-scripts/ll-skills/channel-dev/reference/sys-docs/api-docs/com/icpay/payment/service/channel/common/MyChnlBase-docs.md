# MyChnlBase — 線上渠道支付服務基類（V1）

類別名稱：`com.icpay.payment.service.channel.common.MyChnlBase`

## 說明

線上渠道支付的第一代抽象基類，繼承自 `ChnlServiceBase`，提供基本的 MD5 簽名/驗章功能以及 `extConfig` 靜態配置的讀取能力。此類別為早期的渠道服務實現，後被 `MyChnlBaseV2` 取代。

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `ChnlServiceBase` → `ChnlServiceWithCasherBase` → `ChnlBaseTools`
- **已知子類別**: `PayMode1`
- **主要相依性**:
  - `ChnlServiceBase` — 渠道交易服務抽象基類，提供交易流程框架
  - `EncryptUtil` — 加密工具，用於 MD5 簽名與 Map 排序
  - `Utils` — 通用工具類

## API說明

### Class: MyChnlBase

#### Public 部分

##### 建構式

| 建構式 | 說明 |
|---|---|
| `MyChnlBase()` | 預設建構式，一般不需特別處理 |

#### Protected 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|---|---|---|---|
| `CAT_COMMON` | `String` | `"COMMON"` | 參數類別：通用 |
| `CAT_PAY` | `String` | `"PAY"` | 參數類別：支付 |
| `CAT_PAY_NOTIFY` | `String` | `"PAY_NOTIFY"` | 參數類別：支付回調 |
| `CAT_WITHDRAW` | `String` | `"WITHDRAW"` | 參數類別：提現 |
| `CAT_WITHDRAW_NOTIFY` | `String` | `"WITHDRAW_NOTIFY"` | 參數類別：提現回調 |
| `MODE_FORM_JSON` | `String` | `"FORM_JSON"` | 請求模式：表單提交，JSON 回應 |
| `MODE_JSON_JSON` | `String` | `"JSON_JSON"` | 請求模式：JSON 提交，JSON 回應 |
| `MODE_JSON` | `String` | `"JSON"` | 回調模式：JSON |
| `MODE_FORM` | `String` | `"FORM"` | 回調模式：表單 |

##### 屬性

| 屬性 | 類型 | 說明 |
|---|---|---|
| `extConfigMap` | `Map` | extConfig JSON 解析後的快取 Map |

##### 簽名方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `sign(Map, String, String, Map)` | `String` | 執行 MD5 簽名，支援模板轉換、自訂簽名欄位名稱 |
| `signForChnl(Map, String, Map)` | `String` | 渠道請求簽名（使用預設簽名欄位） |
| `signForChnlResp(Map, String, String)` | `String` | 渠道回應簽名計算（用於驗章比對） |
| `checkSignForChnlResp(Map, String)` | `void` | 驗證渠道回應簽名，不通過則拋出 `ChnlBizException` |
| `checkSignForChnlResp(String, String)` | `void` | 驗證渠道回應簽名（字串版本） |

使用範例：
```java
// 在渠道交易服務中簽名並發送請求
Map signedMap = new HashMap();
signForChnl(reqParams, "pay_req_sign.ftl", signedMap);
String reqBody = translateByTemplate("pay_req.ftl", signedMap);
```

##### 配置讀取方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `getExtConfigMap()` | `Map` | 取得 extConfig 的 Map（帶快取） |
| `extConfig(String)` | `String` | 讀取 extConfig 中的指定 key |
| `extConfig(String, String)` | `String` | 讀取 extConfig，支援預設值 |
| `getConfRequestMode()` | `String` | 取得請求格式配置 |
| `getConfNotifyMode()` | `String` | 取得回調模式配置 |
| `getConfSignConnector()` | `String` | 取得簽名連接符（預設 `&`） |
| `getConfKeyConnector()` | `String` | 取得密鑰連接符（預設 `&key=`） |
| `getConfSignatureUpper()` | `String` | 取得簽名是否大寫（預設 `true`） |
