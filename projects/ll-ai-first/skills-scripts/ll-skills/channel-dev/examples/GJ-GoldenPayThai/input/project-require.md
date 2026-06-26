# GJ-GoldenPayThai 渠道對接需求（原始需求）

> 來源：https://gitlab.sky-net.tw/ll/dashboard-ll/-/issues/12
> 標題：【LL】對接上游_GoldenPay泰国_GJ
> 提出日期：2026/4/24
> 狀態：opened
> 標籤：優先級::高、模組::渠道、類型::功能

---

## 基本資訊

- 厂商名称：GoldenPay泰国
- TG 對接群：🇹🇭 4133-ZX777-GoldenPay 2.2+0.5 / #麦当当号
- 渠道編號：**GJ**
- 對接貨幣：**764-泰銖（THB）**
- 代收是否浮動金額：**不浮動**
- 是否支援反查：**不支援**
- 回調 IP：`15.152.252.49`、`16.209.30.115`

---

## 對接交易類

### 代收（Inbound）

- 交易類：`0121`、`013d`

**參數說明**：

| 渠道參數 | 類型 | 備註 | 對應樂力參數 |
|---|---|---|---|
| `mch_id` | number | 商戶 ID，泰國與其他國家皆必填 | |
| `trans_id` | string | 商戶交易 ID，泰國與其他國家皆必填 | |
| `currency` | string | 幣種代碼，泰國與其他國家皆必填（需轉換為樂力數字代碼，如 THB→764） | |
| `amount` | string | 訂單金額（法幣標準單位，如 "100.00"）。⚠️ 需 ×100 換算為「分」再傳給樂力 | `txnAmt` |
| `channel` | string | 通道代碼，泰國與其他國家皆必填（需映射為樂力子類，如泰國 PromptPay→3d）。0121：bank；013d：bank；測試用：mock | |
| `payer_account_no` | string | （實名場景）付款帳號，**僅泰國必填** | `accNum` |
| `payer_account_name` | string | （實名場景）付款人姓名，**僅泰國必填** | `accName` |
| `payer_account_org` | string | （實名場景）付款機構名稱，**僅泰國必填**（樂力無直接對應欄位，建議放 `bankNum` 或 `productDesc`）| `bankNum`（013d 需新增參數） |
| `callback_url` | string | 支付成功後台通知 URL，泰國與其他國家皆必填 | `notifyUrl` |
| `return_url` | string | 支付成功後跳轉頁面，選填 | `pageReturnUrl` |
| `timestamp` | string | UNIX 時間戳（10 位），泰國與其他國家皆必填 | |
| `sign` | string | 參數簽名，泰國與其他國家皆必填 | |

### 代付（Outbound）

- 交易類：`5210`

**參數說明**：

| 渠道參數 | 類型 | 備註 | 對應樂力參數 |
|---|---|---|---|
| `mch_id` | number | 商戶 ID，請在商戶後台配置中查看 | |
| `trans_id` | string | 商戶交易 ID，由商戶提供 | |
| `channel` | string | 通道代碼，測試使用 mock。5210：bank；測試用：mock | |
| `amount` | string | 訂單金額（法幣標準單位，如 "100.00"）。⚠️ 需 ×100 換算為「分」再傳給樂力 | `txnAmt` |
| `currency` | string | 幣種代碼 | `currencyCode` |
| `account_no` | string | 收款帳號或數字錢包帳號/地址 | `accNum` |
| `account_name` | string | 收款帳戶姓名 | `accName` |
| `account_org` | string | 收款銀行名稱 | `bankName` |
| `account_org_code` | string | 收款銀行代碼（越南見附錄，印度用 IFSC） | `bankNum` |
| `callback_url` | string | 回調 URL，用於通知代付結果 | `notifyUrl` |
| `nonce` | string | 隨機字串，至少 6 位 | 傳隨機值 |
| `timestamp` | string | UNIX 時間戳（10 位） | `timeStamp` |
| `sign` | string | 參數簽名 | |

---

## 商戶資料

### 商戶 API 資訊

- 商戶：`4133-ZX777`
- 商戶 ID：`4133`
- 密鑰：**見 email**

### 商戶後台

- 後台：https://mch.goldenpaythai.com
- 帳號：`ZX777`
- 密碼：**見 email**

### 接口 URL

- 接口域名：`https://ds-api.goldenpaythai.com`
- 餘額查詢：`https://ds-api.goldenpaythai.com/api/v1/mch/balance`
- 代收下單：`https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders`
- 代收查詢：`https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders`
- 代付網關：`https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders`
- 代付查詢：`https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders`

### 回調 IP

- `15.152.252.49`
- `16.209.30.115`

---

## 對接文檔

- 對接文檔（官方）：https://integration.gpbli.top/
