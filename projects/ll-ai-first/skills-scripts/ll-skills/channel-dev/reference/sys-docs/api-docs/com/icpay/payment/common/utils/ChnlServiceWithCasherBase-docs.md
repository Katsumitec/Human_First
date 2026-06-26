# ChnlServiceWithCasherBase — 含收銀台的渠道交易服務基類

類別名稱：`com.icpay.payment.common.utils.ChnlServiceWithCasherBase`

## 說明

含收銀台提交功能的渠道交易服務抽象基類。繼承自 `ChnlServiceBase`，並實作 `OnlTxnCasherService` 介面，增加了收銀台提交（`casherSubmit`）的交易流程支援。

此類別為核心系統建立實例後使用，建立時會指定渠道編號、交易類型及商戶號等屬性。此類（及子類）中所有 public 方法都可以在 FreeMarker 模板中透過 `svc` 工具來使用。

主要特性：
- 報文轉換模板配置於資料表 `tbl_chnl_template` 中
- 渠道響應碼配置於資料表 `tbl_chnl_translate` 中
- 提供收銀台提交的模板方法模式（Template Method），由 `casherSubmit` 處理例外與日誌，子類只需實作 `doCasherSubmit`

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **繼承**: `ChnlBaseTools` → `ChnlServiceBase` → **`ChnlServiceWithCasherBase`**
- **實作介面**: `OnlTxnCasherService`
- **已知子類別**:
  - `MyChnlBase` → `MyChnlBaseV2`（配置驅動 V3 模式）
    - `PayV3Mode1` / `PayV3Mode2` / `PayV3Mode3`
    - `PayV2Mode1` / `PayV2Mode2`
  - `MyChnlBaseV5`（配置驅動 V5 模式，增加收銀台提交）
    - `PayV5Mode1`
- **主要相依性**:
  - `ChnlServiceBase` — 渠道交易服務抽象基類，提供交易請求轉換、結果轉換、查詢等流程框架
  - `OnlTxnCasherService` — 收銀台服務介面，定義 `casherSubmit` 方法
  - `TxnResultContext` — 同步交易結果上下文

```
ChnlBaseTools
└── ChnlServiceBase (implements OnlTxnChnlServiceEx)
    └── ChnlServiceWithCasherBase (implements OnlTxnCasherService)  <-- 本類別
        ├── MyChnlBase → MyChnlBaseV2
        │   ├── PayV3Mode1 / PayV3Mode2 / PayV3Mode3
        │   └── PayV2Mode1 / PayV2Mode2
        └── MyChnlBaseV5
            └── PayV5Mode1
```

## API說明

### Class: ChnlServiceWithCasherBase

> **注意**：此類別為 `abstract`，無法直接實例化，需由子類別繼承實作。

#### Public 部分

##### 方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `casherSubmit(Map<String, String> req, Map<String, String> params)` | `TxnResultContext` | 收銀台提交入口方法（實作 `OnlTxnCasherService` 介面） |

###### `casherSubmit(Map<String, String>, Map<String, String>)`

收銀台提交的公開入口方法，實作自 `OnlTxnCasherService` 介面。此方法採用**模板方法模式**：

1. 建立預設失敗結果（`createDefaultResult(false)`）
2. 記錄 debug 日誌（請求參數）
3. 委派給子類別的 `doCasherSubmit` 執行實際業務邏輯
4. 若發生例外，透過 `toResultByError` 將錯誤轉換為響應結果（不會向上拋出例外）
5. 記錄 debug 日誌（回傳結果）

**參數**:
- `req` — 收銀台提交的同步請求資訊
- `params` — 其他參數（保留）

**回傳**: `TxnResultContext` — 交易結果上下文

使用範例：

```freemarker
<#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
<#-- 收銀台提交通常由核心系統呼叫，模板中較少直接使用此方法 -->
<#-- 以下僅為說明參數結構 -->
${svc.getChannel()}
${svc.getIntTxnType()}
```

> 備註：`casherSubmit` 通常由核心系統在收銀台流程中自動呼叫，渠道開發者主要需要實作 `doCasherSubmit`。

#### Protected 部分

##### 方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doCasherSubmit(Map<String, String> req, Map<String, String> params)` | `TxnResultContext` | **（abstract）** 子類別必須實作的收銀台提交業務邏輯 |

###### `doCasherSubmit(Map<String, String>, Map<String, String>)`

抽象方法，子類別必須實作此方法以處理自定義收銀台提交的業務邏輯。此方法由 `casherSubmit` 呼叫，外層已處理例外捕獲與日誌記錄，因此實作時可直接拋出例外。

**參數**:
- `req` — 收銀台提交資訊（同步請求）
- `params` — 其他參數（保留）

**回傳**: `TxnResultContext` — 交易結果上下文

**例外**: 可拋出 `Exception`，由外層 `casherSubmit` 統一處理

使用範例（子類別實作）：

```java
// 在子類別（如 PayV5Mode1）中實作收銀台提交邏輯
@Override
protected TxnResultContext doCasherSubmit(Map<String, String> req, Map<String, String> params) throws Exception {
    // 1. 從請求中取得必要欄位
    String orderId = req.get("orderId");

    // 2. 使用 FreeMarker 模板轉換收銀台請求報文
    Map<String, String> reqMap = new HashMap<>();
    reqMap.putAll(req);
    String reqBody = translateByTemplate("casher_req.ftl", reqMap);

    // 3. 發送 HTTP 請求至渠道
    String resp = httpPost(getUrl(), reqBody);

    // 4. 解析回應並組裝結果
    TxnResultContext result = new TxnResultContext();
    // ... 處理回應邏輯
    return result;
}
```
