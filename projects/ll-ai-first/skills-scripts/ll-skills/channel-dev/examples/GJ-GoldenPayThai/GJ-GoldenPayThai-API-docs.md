# GJ-GoldenPayThai API 接口文檔分析

> 文檔來源：https://integration.gpbli.top/reference/
> 擷取輔助：agent-browser + URL 清單見 `input/api-doc-urls.md`
> 分析日期：2026-04-24

---

## 通用協議規範

### 通信協議

- 協議類型：**HTTPS**
- Base URL：`https://ds-api.goldenpaythai.com`
- 請求方式：**POST（下單／回調）**、**GET（查詢）**

### 報文格式

- Content-Type：`application/json`（POST 接口）；查詢為 URL Query String
- 請求格式：JSON（POST）／Query String（GET 查詢）
- 響應格式：**JSON**
- 字符編碼：UTF-8

### 響應結構（通用）

成功：
```json
{
  "code": 200,
  "payload": { ... }
}
```

失敗：
```json
{
  "code": 400,
  "errors": { "message": "失败原因" }
}
```

> `code = 200` 表示**接口調用成功**，不代表交易成功。`code = 400` 表示接口調用失敗（如簽名錯誤）。

### 固定參數（每次調用必帶）

| 字段 | 型別 | 說明 |
|---|---|---|
| `nonce` | string | 隨機字串，**至少 6 位**（文檔首頁稱「32 字符以內」）；建議用 `rand.getStr(16)` |
| `timestamp` | string | **10 位 UNIX 時間戳**（秒），字串型別 |
| `sign` | string | 參數簽名 |

### 安全協議（簽名算法）

- 簽名算法：**MD5**（預設）或 RSA（需設 `alg=rsa`；本次對接僅用 MD5）
- 簽名字段：**除 `sign` 外所有非空參數**，按 key ASCII 字典序
- 簽名位置：Body（POST）／Query（GET）
- 加密方式：無
- 其他安全機制：API Token（商戶密鑰）
- 簽名結果：MD5 十六進制字串，**不區分大小寫**（建議用小寫）

#### MD5 簽名流程

1. 把除 `sign` 以外的**非空參數**按 **key ASCII 字典序**排序
2. 組成 `key1=value1&key2=value2&...` 格式字串
3. 將 **API Token 放在最前面**，用 `&` 連接：`{API_TOKEN}&key1=value1&...`
4. 對該字串做 MD5，得十六進制字串（32 位）

> 注意事項：
> - **空值參數不參與簽名**
> - 路徑參數（Path 參數）也需一同排序簽名
> - Body 中的 `amount` 可以是 `"200.00"` 字串或 `200` 數字，但**參與簽名時以字串形式為準**

#### 簽名示例（官方）

請求 Body：
```json
{
  "mch_id": "M3pZtGCTQg7rJeoLy",
  "trans_id": 20181230213948,
  "amount": "200.00",
  "channel": "alipay",
  "remarks": "memo",
  "nonce": "7886356ioiasdf",
  "timestamp": 1678132123,
  "callback_url": "http://hd3tcp.javawebdata9.com/api/recharge/onlinePayAsyncCallback/20200627132036809474",
  "ip": "47.244.122.36"
}
```

API Token = `xoJb3BS8j40OCuPc6kzE`

拼接後字串：
```
xoJb3BS8j40OCuPc6kzE&amount=200.00&callback_url=http://hd3tcp.javawebdata9.com/api/recharge/onlinePayAsyncCallback/20200627132036809474&channel=alipay&ip=47.244.122.36&mch_id=M3pZtGCTQg7rJeoLy&nonce=7886356ioiasdf&remarks=memo&trans_id=20181230213948
```

MD5 結果：`3147c167da0392a2317542c18d0017e1`

---

## 接口列表

### 接口總表

| 分類 | 接口 | Method | URL | 備註 |
|---|---|---|---|---|
| R/C | 代收下單 | POST | `/api/v1/mch/pmt-orders` | 返回 `url`（收銀台）+ `meta`（越南專用）；泰國主要用 `url` |
| Q | 代收查詢 | GET | `/api/v1/mch/pmt-orders?id=...` | Query String |
| N | 代收回調 | POST | 商戶 `callback_url` | status=60 成功 |
| W | 代付下單 | POST | `/api/v1/mch/wdl-orders` | 需帶收款人資訊 |
| Q | 代付查詢 | GET | `/api/v1/mch/wdl-orders?id=...` | Query String |
| N | 代付回調 | POST | 商戶 `callback_url` | status=50 取消/失敗 |
| Q | 商戶餘額／資訊 | GET | `/api/v1/mch/balance`、`/api/v1/mch/info` | 不在本次對接範圍 |

---

## 代收接口

### 1. 代收下單（POST /api/v1/mch/pmt-orders）

**接口說明**
- 名稱：代收下單
- 功能：發起支付請求，獲取收銀台 URL 或收款帳號
- 接口 URL：`POST https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：R（跳轉類代收）／C（複合類；若 `cashier_type=9`）

**接口協議**：同通用規範

**請求 Header**：同通用規範（`Content-Type: application/json`）

**請求報文（Request）**

| 字段 | 型別 | 必填（泰國） | 必填（其他） | 說明 |
|---|---|---|---|---|
| `mch_id` | number | ✅ | ✅ | 商戶 ID |
| `trans_id` | string | ✅ | ✅ | 商戶交易 ID |
| `currency` | string | ✅ | ✅ | 幣種（字母碼；THB=`THB`；見「貨幣代碼」） |
| `amount` | string | ✅ | ✅ | 訂單金額（法幣標準單位，字串）例 `"100.00"` |
| `channel` | string | ✅ | ✅ | 通道代碼（泰國：`bank` / `truemoney`；測試：`mock`） |
| `payer_account_no` | string | ✅（實名場景） | ⭕️ | 付款帳號（泰國必填） |
| `payer_account_name` | string | ✅（實名場景） | ⭕️ | 付款人姓名（泰國必填） |
| `payer_account_org` | string | ✅（實名場景） | ⭕️ | 付款機構名稱（泰國必填） |
| `callback_url` | string | ✅ | ✅ | 支付完成異步通知 URL |
| `mode` | string | ⭕️ | ⭕️ | `auto`（預設，自動分配收款帳號）或 `manual`（玩家自選銀行） |
| `return_url` | string | ⭕️ | ⭕️ | 支付成功後跳轉頁面 |
| `uid` | string | ⭕️ | ⭕️ | 用戶 ID；USDT 通道必填 |
| `remarks` | string | ⭕️ | ⭕️ | 訂單備註，回調時原樣返回 |
| `nonce` | string | ✅ | ✅ | 隨機字串 ≥6 位 |
| `timestamp` | string | ✅ | ✅ | 10 位 UNIX 秒 |
| `sign` | string | ✅ | ✅ | 簽名 |

請求範例：
```json
{
  "mch_id": "4133",
  "trans_id": "20260424001",
  "currency": "THB",
  "amount": "100.00",
  "channel": "bank",
  "payer_account_no": "898123767665",
  "payer_account_name": "THAN NHA TRONG",
  "payer_account_org": "KBANK",
  "callback_url": "https://merchant.example.com/api/callback",
  "return_url": "https://merchant.example.com/pay/return",
  "nonce": "abcd1234ef",
  "timestamp": "1714000000",
  "sign": "3147c167da0392a2317542c18d0017e1"
}
```

CURL 範例：
```bash
curl -X POST "https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders" \
  -H "Content-Type: application/json" \
  -d '{...}'
```

**響應報文（Response）**

> 代收同步響應僅代表「訂單已受理」（status=20），交易狀態為**處理中**，最終結果由回調或查詢確認。

- 響應格式：JSON
- Content-Type：`application/json`

`payload` 字段：

| 字段 | 型別 | 說明 |
|---|---|---|
| `id` | string | 平台唯一訂單 ID |
| `mch_id` | number | 商戶 ID |
| `trans_id` | string | 商戶交易 ID |
| `order_amount` | number | 訂單金額 |
| `channel` | string | 通道代碼 |
| `status` | number | **20 = 新創建**（處理中） |
| `cashier_type` | number | 0=僅 url、1=僅 meta、9=兩者皆有 |
| `url` | string | 收銀台 H5 頁面 URL |
| `meta` | object | （越南 bank 專用）收款帳號資訊；泰國場景通常為空 |
| `meta.account_no/name/org/org_code/remarks/qr_url` | string | 越南 bank 專用 |
| `sign` | string | 響應簽名 |

響應範例：
```json
{
  "code": 200,
  "payload": {
    "id": "ET1729187424AJCT",
    "mch_id": "8888",
    "trans_id": "商户提交的订单号",
    "channel": "bank",
    "order_amount": 101,
    "status": 20,
    "cashier_type": 9,
    "url": "http://cashier.money.com/cashier/order?id=abcdefg123",
    "meta": {
      "account_no": "898123767665",
      "account_name": "THAN NHA TRONG",
      "account_org": "CIMB",
      "account_org_code": "422589",
      "remarks": "n1ttzxd6"
    },
    "sign": "e0c0a5a0c5ddeb3f3887e273df49568b"
  }
}
```

---

### 2. 代收訂單查詢（GET /api/v1/mch/pmt-orders）

**接口說明**
- 名稱：代收訂單查詢
- 接口 URL：`GET https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders`
- 請求方式：GET（參數透過 Query String）

**接口分類**：Q

**請求參數（Query）**

| 字段 | 必填 | 說明 |
|---|---|---|
| `id` | ✅ | 平台訂單 ID 或交易 ID；**參與簽名** |
| `mch_id` | ✅ | 商戶 ID |
| `nonce` | ✅ | 隨機字串 |
| `timestamp` | ✅ | UNIX 秒 |
| `sign` | ✅ | 簽名 |

請求範例：
```
GET /api/v1/mch/pmt-orders?id=EOu154sgKfZB&mch_id=4133&nonce=abc&timestamp=1714000000&sign=xxx
```

**響應報文（Response）**

| 字段 | 型別 | 說明 |
|---|---|---|
| `id` | string | 平台訂單 ID |
| `mch_id` | number | 商戶 ID |
| `trans_id` | string | 商戶交易 ID |
| `order_amount` | number | 訂單金額 |
| `payed_amount` | number | **實付金額**；與下單金額不一致時不建議上分 |
| `channel` | string | 通道代碼 |
| `status` | number | **60 = 支付成功**，其他 = 未支付（處理中） |
| `created_at` | string | 創建時間 |
| `sign` | string | 響應簽名 |

響應範例：
```json
{
  "code": 200,
  "payload": {
    "id": "EOu154sgKfZB",
    "mch_id": "8888",
    "trans_id": "商户的交易ID",
    "order_amount": 100,
    "channel": "bank",
    "status": 20,
    "created_at": "2020-09-09 12:21:44",
    "sign": "e0c0a5a0c5ddeb3f3887e273df49568b"
  }
}
```

> **交易狀態碼**（查詢）：
> - `60` → 成功（已支付）
> - 其他 → 處理中 / 未支付（含新創建 20）

---

## 代付接口

### 3. 發起代付（POST /api/v1/mch/wdl-orders）

**接口說明**
- 名稱：發起代付
- 接口 URL：`POST https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：W

**注意事項**（官方提示）：
- 提現金額超商戶限額 → 回 `提现金额超出限制`
- 銀行卡無效 → 回 `无效卡号……`，請將錯誤原樣展示給下游
- 支付寶下發：`account_org=支付宝`、`account_sub_org` 留空、`account_no` 填手機號或 Email

**請求報文（Request）**

| 字段 | 型別 | 越南 | 泰國 | 巴西 | 印度 | 菲律賓 | 說明 |
|---|---|---|---|---|---|---|---|
| `mch_id` | number | ✅ | ✅ | ✅ | ✅ | ✅ | 商戶 ID |
| `trans_id` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 商戶交易 ID |
| `channel` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 通道代碼（泰國：`bank` / `truemoney`；測試：`mock`） |
| `amount` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 訂單金額，字串法幣單位 |
| `currency` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 字母碼（THB） |
| `account_no` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 收款帳號／錢包地址／手機號（GCash） |
| `account_name` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 收款帳戶姓名 |
| `account_org` | string | ✅ | ✅ | ✅ | ✅ | ⭕️ | 收款銀行名稱 |
| `account_org_code` | string | ✅ | ✅ | ⭕️ | ⭕️ | ⭕️ | 收款銀行代碼（泰國見附錄） |
| `account_sub_org` | string | ⭕️ | ⭕️ | ⭕️ | ⭕️ | ⭕️ | 開戶行 |
| `account_type` | string | ⭕️ | ⭕️ | ✅ | ⭕️ | ⭕️ | 巴西專用 |
| `account_tin` | string | ⭕️ | ⭕️ | ✅ | ⭕️ | ⭕️ | 巴西專用（CPF/CNPJ） |
| `account_phone` | string | ⭕️ | ⭕️ | ✅ | ⭕️ | ⭕️ | 巴西專用 |
| `account_email` | string | ⭕️ | ⭕️ | ✅ | ⭕️ | ⭕️ | 巴西專用 |
| `callback_url` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 異步通知 URL |
| `nonce` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 隨機字串 ≥6 位 |
| `timestamp` | string | ✅ | ✅ | ✅ | ✅ | ✅ | UNIX 秒 |
| `sign` | string | ✅ | ✅ | ✅ | ✅ | ✅ | 簽名 |

請求範例：
```json
{
  "mch_id": "4133",
  "trans_id": "WD20260424001",
  "channel": "bank",
  "amount": "500.00",
  "currency": "THB",
  "account_no": "1234567890",
  "account_name": "SOMCHAI SUKPAN",
  "account_org": "KBANK",
  "account_org_code": "KBANK",
  "callback_url": "https://merchant.example.com/api/wd-callback",
  "nonce": "xyz789ab",
  "timestamp": "1714000000",
  "sign": "..."
}
```

**響應報文（Response）**

> 代付同步響應：`code=200` 代表**提交成功**，實際代付結果待回調確認。

`payload` 字段：

| 字段 | 型別 | 說明 |
|---|---|---|
| `id` | string | 平台訂單 ID |
| `mch_id` | string | 商戶 ID |
| `trans_id` | string | 交易 ID |
| `channel` | string | 通道代碼 |
| `order_amount` | number | 訂單金額 |
| `currency` | string | 幣種 |
| `account_name/no/org/org_code/sub_org` | string | 收款資訊 |
| `created_at` | string | 下單時間 |
| `status` | number | **20 = 已受理**，**50 = 取消/失敗**，**其他 = 已成功** |

響應範例：
```json
{
  "code": 200,
  "payload": {
    "id": "WT1729187424AJCT",
    "trans_id": "2019uZP8KImVd2Xbzae",
    "mch_id": "8888",
    "channel": "bank",
    "order_amount": 100,
    "account_no": "2333667799212341",
    "account_name": "Nguyễn Xuân Hưng",
    "account_org": "PVCOMOBANK",
    "account_org_code": "970425",
    "currency": "VND",
    "created_at": "2019-04-12 14:12:31",
    "status": 20
  }
}
```

---

### 4. 代付訂單查詢（GET /api/v1/mch/wdl-orders）

**接口說明**
- 接口 URL：`GET https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders`

**接口分類**：Q

**請求參數（Query）**：同代收查詢（`id`、`mch_id`、`nonce`、`timestamp`、`sign`）

請求範例：
```
GET /api/v1/mch/wdl-orders?id=WOu154sgKfZB&mch_id=4133&nonce=abc&timestamp=1714000000&sign=xxx
```

**響應報文（Response）**

`payload` 字段：

| 字段 | 型別 | 說明 |
|---|---|---|
| `id`, `mch_id`, `trans_id` | | 訂單識別 |
| `order_amount` | number | 訂單金額 |
| `currency` | string | 幣種（預設 CNY，以本次對接實際為 THB） |
| `account_*` | string | 收款資訊 |
| `attachments` | string[] | 代付憑證文件 |
| `created_at` | string | 提現時間 |
| `status` | number | **20 = 已受理**，**50 = 取消/失敗**，**其他 = 已成功** |

---

## 異步通知接口

### 5. 代收回調（POST 商戶 callback_url）

**接口說明**
- 通知方式：HTTP POST
- 請求格式：JSON
- Content-Type：`application/json`

**回調請求報文（Request）**

| 字段 | 型別 | 說明 |
|---|---|---|
| `id` | string | 平台唯一訂單 ID |
| `mch_id` | number | 商戶 ID |
| `trans_id` | string | 商戶訂單 ID |
| `channel` | string | 通道 |
| `order_amount` | number | 訂單金額 |
| `payed_amount` | number | **實付金額**（不一致時不要上分） |
| `created_at` | string | 訂單創建時間 |
| `payed_at` | string | 支付時間（成功時才有） |
| `status` | number | **60 = 成功**，其他 = 失敗 |
| `sign` | string | 簽名 |

回調請求範例：
```json
{
  "id": "ET1729187424AJCT",
  "mch_id": 4133,
  "trans_id": "20260424001",
  "channel": "bank",
  "order_amount": 100,
  "payed_amount": 100,
  "created_at": "2026-04-24 12:00:00",
  "payed_at": "2026-04-24 12:05:00",
  "status": 60,
  "sign": "..."
}
```

**回調響應報文（商戶需回覆）**：純文字 `success`

```
success
```

**回調時序規則**：
- 超時 5 秒
- 失敗每 60 秒重試，共 3 次
- **可重複推送**，商戶需冪等處理

---

### 6. 代付回調（POST 商戶 callback_url）

**接口說明**
- 通知方式：HTTP POST
- 請求格式：JSON
- Content-Type：`application/json`

**回調請求報文（Request）**

| 字段 | 型別 | 說明 |
|---|---|---|
| `id` | string | 平台訂單 ID |
| `mch_id` | number | 商戶 ID |
| `trans_id` | string | 商戶訂單 ID |
| `order_amount` | number | 訂單金額 |
| `created_at` | string | 訂單創建時間 |
| `canceled_at` | string | 取消時間（取消時才有） |
| `payed_at` | string | 支付時間（成功時才有） |
| `status` | number | **50 = 取消**，其他 = 成功 |
| `sign` | string | 簽名 |

回調請求範例：
```json
{
  "id": "WT1729187424AJCT",
  "mch_id": 4133,
  "trans_id": "WD20260424001",
  "order_amount": 500,
  "created_at": "2026-04-24 12:00:00",
  "payed_at": "2026-04-24 12:05:00",
  "status": 60,
  "sign": "..."
}
```

**回調響應**：純文字 `success`

**回調時序規則**：
- 超時 10 秒
- 失敗每 30 秒重試，共 5 次

---

## 附錄

### 貨幣代碼（上游使用字母碼）

| 幣種 | 代碼 |
|---|---|
| 越南盾 | `VND` |
| 泰國泰銖 | `THB` |
| 菲律賓 PESO | `PHP` |
| USDT | `USDT` |

> ⚠️ 上游 API 接收**字母碼**，樂力內部使用 ISO 4217 數字碼（THB→764）。模板中需硬編字母碼或透過 `svc.getMerParam()` 取。

### 通道代碼（泰國）

| 通道名稱 | 通道代碼 |
|---|---|
| 銀行卡 | `bank` |
| TrueMoney | `truemoney` |
| 測試用 | `mock` |

> 需求提到「PromptPay→3d」與 013d，但官方文檔的泰國通道代碼僅列 `bank` / `truemoney`。建議向對接窗口確認 013d 實際 channel 值。

### 泰國銀行代碼（摘錄）

| 代碼 | 名稱 |
|---|---|
| `BKKB` | Bangkok Bank |
| `KBANK` | KASIKORNBANK |
| `KTB` | Krung Thai Bank |
| `SCB` | Siam Commercial Bank |
| `KSAB` | Krungsri Bank |
| `TTB` | TMBTHANACHART BANK |
| `GSB` | GOVERNMENT SAVINGS BANK |
| `CIMB` | CIMB THAI BANK |
| `TISC` | TISCO Bank |
| `UOBT` | United Overseas Bank (Thai) |
| `ICBC` | ICBC (THAI) |
| `BOC` | BANK OF CHINA (THAI) |

> 完整列表見 https://integration.gpbli.top/reference/support-banks-th/

### 交易狀態碼映射（樂力視角）

| 場景 | 上游 status | 語義 | 樂力 dest_code |
|---|---|---|---|
| 代收同步響應 | 20 | 新創建（處理中） | `01` |
| 代收查詢 | 60 | 支付成功 | `10` |
| 代收查詢 | 其他（含 20） | 未支付 | `01` |
| 代收通知 | 60 | 成功 | `10` |
| 代收通知 | 其他 | 失敗 | `20` |
| 代付同步響應（`code`） | 200 | 提交成功，處理中 | `01` |
| 代付同步響應（`code`） | 400/其他 | 提交失敗 | `20` |
| 代付查詢 | 20 | 已受理 | `01` |
| 代付查詢 | 50 | 取消/失敗 | `20` |
| 代付查詢 | 其他（60 等） | 已成功 | `10`（但保守起見可預設 `01`，待聯調確認成功碼） |
| 代付通知 | 50 | 取消/失敗 | `20` |
| 代付通知 | 其他 | 成功 | `10`（文檔明示；但為避免誤判，* 預設 `01` 更安全，實際成功碼聯調確認） |

### 回調 IP 白名單

- `15.152.252.49`
- `16.209.30.115`
