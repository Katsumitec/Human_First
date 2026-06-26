# GJ-GoldenPayThai 渠道對接需求分析

## 需求來源

- GitLab Issue：https://gitlab.sky-net.tw/ll/dashboard-ll/-/issues/12
- 原始需求文件：`GJ-GoldenPayThai/input/project-require.md`

---

## 任務摘要

| 交易類 | 類型 | 幣別 | 關鍵參數/規格 | 補充說明 |
|---|---|---|---|---|
| `0121` | 代收（網銀類／跳轉） | THB（764） | `channel=bank`、`mch_id`、`trans_id`、`amount`、`currency`、`timestamp`、`sign`、`callback_url`、`return_url` | 金額不浮動；泰國場景下額外必填 `payer_account_no / payer_account_name / payer_account_org` |
| `013d` | 代收（H5 掃碼類／PromptPay？） | THB（764） | `channel=bank`、`mch_id`、`trans_id`、`amount`、`currency`、`timestamp`、`sign`、`callback_url`、`return_url`、`payer_account_no/name/org`（013d 需新增 `bankNum` 參數傳遞） | 金額不浮動；需求文件提示「泰國 PromptPay→3d」，疑似對應 PromptPay |
| `5210` | 代付 | THB（764） | `mch_id`、`trans_id`、`channel=bank`、`amount`、`currency`、`account_no`、`account_name`、`account_org`、`account_org_code`、`callback_url`、`nonce`、`timestamp`、`sign` | 需要收款人帳號 / 姓名 / 銀行名稱 / 銀行代碼 |

---

## 基本資訊

| 項目 | 內容 |
|---|---|
| 渠道編號（chnl_id） | **GJ** |
| 渠道名稱 | GoldenPay泰国（GoldenPayThai） |
| 對接文檔 | https://integration.gpbli.top/ |
| 對接貨幣 | **THB（泰銖，數字代碼 764）** |
| 是否支持反查 | **不支持** |
| 回調 IP | `15.152.252.49`、`16.209.30.115` |
| TG 對接群 | 🇹🇭 4133-ZX777-GoldenPay 2.2+0.5 / #麦当当号 |

---

## 交易類型詳細需求

### 代收（Inbound）

#### 0121 — 網銀類（跳轉）

| 項目 | 內容 |
|---|---|
| 接口分類 / channel 代碼 | `bank`（測試：`mock`） |
| 下單接口 URL | `POST https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders` |
| 查詢接口 URL | `https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders` |
| 貨幣 | THB（764） |
| 金額是否浮動 | 否（不浮動） |
| 是否需要自訂收銀台 | **未明確說明，但可能需要**（見「待確認事項」） |

#### 013d — H5 類（可能為 PromptPay）

| 項目 | 內容 |
|---|---|
| 接口分類 / channel 代碼 | `bank`（測試：`mock`）；需求提示「PromptPay→3d」 |
| 下單接口 URL | `POST https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders` |
| 查詢接口 URL | `https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders` |
| 貨幣 | THB（764） |
| 金額是否浮動 | 否（不浮動） |
| 是否需要自訂收銀台 | **未明確說明，但可能需要**（見「待確認事項」） |
| 新增參數 | 需求文件明示「013d 需新增參數」——`payer_account_org` 對應 `bankNum`，可能需在 ctx / params 層新增對應欄位 |

#### 代收共用欄位對照（上游 ⇄ 樂力）

| 上游欄位 | 型別 | 必填 | 對應樂力欄位 / 說明 |
|---|---|---|---|
| `mch_id` | number | Y | 商戶號 → `svc.getChnlMerId()` |
| `trans_id` | string | Y | 訂單號 → `ctx.chnlOrderId` |
| `currency` | string | Y | 幣別數字代碼（THB→`764`） |
| `amount` | string | Y | 法幣標準單位（如 "100.00"）；樂力內部分 → `svc.toChnlAmt(ctx.txnAmt)` |
| `channel` | string | Y | 0121→`bank`；013d→`bank`；測試→`mock` |
| `payer_account_no` | string | Y（**僅泰國**） | `ctx.accNum`（付款人帳號） |
| `payer_account_name` | string | Y（**僅泰國**） | `ctx.accName`（付款人姓名） |
| `payer_account_org` | string | Y（**僅泰國**） | `ctx.bankNum` 或 `ctx.productDesc`（付款機構名稱；013d 需新增） |
| `callback_url` | string | Y | `ctx.chnlNotifyUrl` |
| `return_url` | string | N | `ctx.chnlPageRetUrl` |
| `timestamp` | string | Y | UNIX 秒（10 位）→ `svc.nowSecs()` |
| `sign` | string | Y | 簽名演算法見 API 文檔 |

### 代付（Outbound）

#### 5210

| 項目 | 內容 |
|---|---|
| 接口分類 / channel 代碼 | `bank`（測試：`mock`） |
| 下單接口 URL | `POST https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders` |
| 查詢接口 URL | `https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders` |
| 貨幣 | THB（764） |

#### 代付欄位對照

| 上游欄位 | 型別 | 必填 | 對應樂力欄位 / 說明 |
|---|---|---|---|
| `mch_id` | number | Y | 商戶號 → `svc.getChnlMerId()` |
| `trans_id` | string | Y | 訂單號 → `ctx.chnlOrderId` |
| `channel` | string | Y | 5210→`bank`；測試→`mock` |
| `amount` | string | Y | 法幣標準單位 → `svc.toChnlAmt(ctx.txnAmt)` |
| `currency` | string | Y | 幣別數字代碼（THB→`764`）→ `ctx.currencyCode` 或 setCurrencyByCode |
| `account_no` | string | Y | `ctx.accNum` |
| `account_name` | string | Y | `ctx.accName` |
| `account_org` | string | Y | `ctx.bankName` |
| `account_org_code` | string | Y | `ctx.bankNum`（泰國應為銀行代碼） |
| `callback_url` | string | Y | `ctx.chnlNotifyUrl` |
| `nonce` | string | Y | 隨機字串（至少 6 位）→ `rand.getStr(n)` |
| `timestamp` | string | Y | UNIX 秒 → `svc.nowSecs()` |
| `sign` | string | Y | 簽名演算法見 API 文檔 |

---

## 商戶資料

| 項目 | 內容 |
|---|---|
| 商戶別名 | `4133-ZX777` |
| 商戶 ID（`mch_id`） | `4133` |
| 密鑰（sign key） | **見 email** |
| 商戶後台 | https://mch.goldenpaythai.com |
| 商戶後台帳號 | `ZX777` |
| 商戶後台密碼 | **見 email** |

---

## 接口 URL 配置（彙整）

| 用途 | URL | 對應 param_id |
|---|---|---|
| 接口域名 | `https://ds-api.goldenpaythai.com` | — |
| 餘額查詢 | `https://ds-api.goldenpaythai.com/api/v1/mch/balance` | —（系統暫無餘額查詢接口，不必配置） |
| 代收下單 | `https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders` | `url.txn.req`（param_cat=`*`） |
| 代收查詢 | `https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders` | `url.txn.query`（param_cat=`*`）— 具體路徑格式待看 API 文檔（可能需帶訂單號為 URL path 或 query） |
| 代付下單 | `https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders` | `url.txn.req`（param_cat=`5210`） |
| 代付查詢 | `https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders` | `url.txn.query`（param_cat=`0050`） |

---

## 待確認事項

下列項目在需求文件中**未明確說明或有歧義**，需要後續透過 API 文件分析（Step 2）或向 PM 確認：

1. **是否需要自訂收銀台**（0121 / 013d）
   - 需求文件要求代收下單時帶 `payer_account_no / payer_account_name / payer_account_org`（泰國必填）。這些欄位屬「付款人」資訊，一般情境下我方無現成來源。
   - 若採「自訂收銀台」模式，需讓付款人在我方收銀台頁面先輸入上述資訊，我方再轉發給上游。
   - 若上游其實會在其收銀台頁面收集這些欄位（我方只需把部分欄位帶過去），則可採跳轉類（`convRequest` + `Redirect`）。
   - 待 Step 2 分析 API 文檔後確認實際互動流程。

2. **0121 vs 013d 的區分邏輯**
   - 需求文件中 `channel` 欄位值兩者皆為 `bank`，難以從請求欄位區分。
   - 需求另提到「泰國 PromptPay→3d」，疑似 013d 對應 PromptPay 管道。
   - 可能的解讀：上游透過 URL 路徑 / 其他欄位決定，或我方需依 txn_type 傳不同 `channel` 值（需 API 文檔佐證）。若確實需以 `channel` 區分，應在 params 中配置 `type`（param_cat=`0121` / `013d`）。

3. **013d 新增的 `bankNum` 參數**
   - 需求文件標註「013d 需新增參數」，代表樂力系統 / 下游下單介面要新增 `bankNum` 欄位給這個 txn_type？或是我方只要在 ctx 取 `ctx.bankNum` 即可？
   - 待與 PM 或對接窗口確認「新增參數」的具體技術動作。

4. **簽名演算法**
   - 需求文件僅提到「簽名演算法與樂力不同，需各自獨立計算」，具體演算法（MD5？SHA256？拼接規則？空值排除？）需待 Step 2 從 API 文檔取得。

5. **密鑰 / 後台密碼**
   - 需求文件標註「見 email」。測試聯調階段需取得實際密鑰與後台密碼。

6. **代收查詢 URL 是否帶路徑參數**
   - 需求僅列接口域名，未明示查詢時是否透過 URL path 傳訂單號（如 `/pmt-orders/{trans_id}`）或 query string。待 Step 2 從 API 文檔確認。

7. **代付是否支援反查**
   - 需求文件說「是否支持反查：不支持」，但同時提供了代付查詢 URL。需釐清「不支持反查」的具體範圍（可能是指不支援商戶主動查詢代收訂單，但代付查詢 OK，或其他語義）。
