# MyChnlBaseV5 — 含收銀台的配置驅動渠道支付基類（V5）

類別名稱：`com.icpay.payment.service.channel.common.MyChnlBaseV5`

## 說明

第五代線上渠道支付抽象基類，繼承自 `ChnlServiceWithCasherBase`，在 V2 的配置驅動基礎上新增了收銀台提交（`doCasherSubmit`）功能。其 API 與 `MyChnlBaseV2` 基本相同，額外提供收銀台提交相關的行為開關方法。

### 相比 MyChnlBaseV2 的差異

1. 繼承 `ChnlServiceWithCasherBase`（非 `ChnlServiceBase`），支援 `doCasherSubmit()` 方法
2. 新增收銀台提交的簽名/驗章開關：`shouldSignCasherSubmitRequest()`、`shouldCheckSignForCasherSubmit()` 等

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `ChnlServiceWithCasherBase` → `ChnlServiceBase` → `ChnlBaseTools`
- **已知子類別**: `PayV5Mode1`
- **主要相依性**:
  - `ChnlSignatureServiceBase` — 簽名服務抽象基類
  - `ChnlEncryptionServiceBase` — 加密服務抽象基類
  - `HttpProxyHelper` — HTTP 代理工具

## API說明

### Class: MyChnlBaseV5

> 大部分 API 與 `MyChnlBaseV2` 相同，以下僅列出差異部分。完整的共用 API 請參閱 [MyChnlBaseV2-docs.md](./MyChnlBaseV2-docs.md)。

#### Public 部分

##### 建構式

| 建構式 | 說明 |
|---|---|
| `MyChnlBaseV5()` | 預設建構式 |

#### Protected 部分

##### 收銀台提交行為開關（V5 新增）

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `shouldSignCasherSubmitRequest()` | `boolean` | 收銀台提交請求是否需要簽名（MerParam: `sign.action.casherSubmit.sign`，預設 `1`） |
| `shouldCheckSignForCasherSubmitByTmpl()` | `boolean` | 收銀台提交驗章是否使用模板（MerParam: `sign.action.casherSubmit.check.by.template`，預設 `0`） |
| `shouldCheckSignForCasherSubmit()` | `boolean` | 收銀台提交回應是否需要驗章（MerParam: `sign.action.casherSubmit.check`，預設 `0`） |
