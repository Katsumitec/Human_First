# FX-WTpay API 接口文檔分析

> 文檔來源：https://tianciv690215.com/docs/
> 分析日期：2026-02-23
> 渠道編號：FX
> 渠道名稱：WTpay

---

## 通用協議規範

### 通信協議

- 協議類型：HTTPS
- Base URL：`https://tianciv690215.com`
- 請求方式：GET / POST（依接口而定）

### 報文格式

- Content-Type：`application/json`
- 請求格式：JSON
- 響應格式：JSON
- 字符編碼：UTF-8

### 安全協議

- **身份驗證**：Bearer Token，放置於 HTTP Header `Authorization: Bearer {api_token}`
- **簽名算法**：MD5
- **簽名適用範圍**：
  - 代付發起接口（Request）：`sign` 為**必填**
  - 代收發起接口（Request）：`sign` 為**選填**
  - 異步回調（Callback）：回調報文中包含 `sign`，商戶需驗簽
- **簽名規則**：
  1. 取參與簽名的字段（排除 `sign` 本身）
  2. 依字段名稱的 ASCII 碼由小到大排序
  3. 拼接為 `key1=val1&key2=val2&...` 格式
  4. 末尾直接拼接 `api_token` 和 `notify_token`（無分隔符）
  5. 對整體字符串取 MD5（小寫 hex）
- **簽名示例（回調驗簽）**：
  ```
  amount=300000&out_trade_no=lt0085DB4AE5444B_60509043_112159&state=completed&trade_no=fdd49c43-e1c1-49da-9d23-8027f5412fe6{api_token}{notify_token}
  ```
  → MD5 → `sign`
- **其他安全機制**：`notify_token` 僅用於簽名驗證，不傳輸於請求頭

---

## 接口列表

---

## 一、代收接口

### 1. 代收銀行列表接口

**接口說明**
- 名稱：代收銀行列表
- 功能與目的：獲取平台支持的所有代收銀行列表，`id` 字段即為其他接口使用的銀行代碼
- 接口 URL：`GET https://tianciv690215.com/api/bank`

**接口分類**：查詢類接口

**接口協議**：與通用規範一致

**請求報文（Request）**

> 無請求體，僅需 Header 認證。

| Header 字段 | 必填 | 說明 |
|-------------|------|------|
| Accept | 是 | `application/json` |
| Content-Type | 是 | `application/json` |
| Authorization | 是 | `Bearer {api_token}` |

請求範例：
```bash
curl -X GET https://tianciv690215.com/api/bank \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data | Array | 銀行列表 |
| data[].id | String | 銀行代碼（用於提交訂單時的 `bank_id` 或 `bank`） |
| data[].name | String | 銀行全名 |

響應範例：
```json
{
    "success": true,
    "data": [
        {
            "id": "ACB",
            "name": "NGAN HANG TMCP A CHAU (ACB)"
        },
        {
            "id": "VCB",
            "name": "NGAN HANG TMCP NGOAI THUONG VIET NAM (VCB)"
        }
    ]
}
```

---

### 2. 代收啟用銀行列表接口

**接口說明**
- 名稱：代收啟用銀行列表
- 功能與目的：獲取當前渠道已啟用（可用）的銀行代碼列表，建議在發起代收訂單前調用以確認可用銀行
- 接口 URL：`GET https://tianciv690215.com/api/bank/published`

**接口分類**：查詢類接口

**接口協議**：與通用規範一致

**請求報文（Request）**

> 無請求體，僅需 Header 認證。

| Header 字段 | 必填 | 說明 |
|-------------|------|------|
| Accept | 是 | `application/json` |
| Content-Type | 是 | `application/json` |
| Authorization | 是 | `Bearer {api_token}` |

請求範例：
```bash
curl -X GET https://tianciv690215.com/api/bank/published \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data | Array\<String\> | 已啟用的銀行代碼列表 |

響應範例：
```json
{
    "success": true,
    "data": ["ACB", "BIDV", "SACOMBANK", "TCB", "VCB"]
}
```

---

### 3. 代收查詢接口

**接口說明**
- 名稱：代收訂單查詢
- 功能與目的：以商戶訂單號查詢代收訂單的當前狀態與金額資訊
- 接口 URL：`GET https://tianciv690215.com/api/transaction/{out_trade_no}`

**接口分類**：查詢類接口

**接口協議**：與通用規範一致

**請求報文（Request）**

> 訂單號放於 URL Path，無請求體。

| 參數 | 位置 | 類型 | 必填 | 說明 |
|------|------|------|------|------|
| out_trade_no | Path | String | 是 | 商戶訂單號 |

請求範例：
```bash
curl -X GET https://tianciv690215.com/api/transaction/2014072300007148 \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.request_amount | String | 商戶請求金額 |
| data.amount | String | 實際到帳金額 |
| data.state | String | 訂單狀態，見下表 |

**訂單狀態說明（state）**

| 狀態值 | 說明 |
|--------|------|
| new | 新建，待支付 |
| processing | 處理中 |
| verify | 驗證中 |
| reject | 已拒絕 |
| completed | 已完成 |
| failed | 已失敗 |
| refund | 已退款 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "774757bb-23e5-4fee-89f6-6be9171fd59e",
        "out_trade_no": "2014072300007148",
        "request_amount": "500",
        "amount": "500",
        "state": "completed"
    }
}
```

---

### 4. 代收接口（純卡網關）

**接口說明**
- 名稱：代收接口 - 純卡網關
- 功能與目的：發起銀行卡代收訂單，響應收銀台跳轉地址（uri）與 QR code 內容（qrcode），商戶可選擇引導客戶跳轉收銀台或掃碼付款
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：複合類代收接口（同時返回收銀台跳轉地址 `uri` 與帳戶轉入參考 `qrcode`）

**接口協議**：與通用規範一致

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank_id | String | 否 | 指定銀行代碼，例如 `ACB` |
| available_bank_random | Boolean | 否 | `true` 時自動匹配可用銀行 |
| memo | String | 否 | 自定義備注 |
| paid_name | String | 否 | 付款人姓名 |
| sign | String | 否 | 簽名（見通用簽名規則） |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "memo": "custom_memo_test",
    "paid_name": "王小明",
    "sign": "aae763662eac995a82d10b2071ee98ae"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.uri | String | 收銀台網址，供客戶瀏覽器跳轉 |
| data.qrcode | String | QR code 內容，由商戶自行生成 QR 圖片供客戶掃描 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "uri": "https://tianciv690215.com/checkout/abc123",
        "qrcode": "VietcomBank0529THAI"
    }
}
```

---

### 5. 代收接口（純卡網關-JSON）

**接口說明**
- 名稱：代收接口 - 純卡網關（JSON 返回帳戶資訊）
- 功能與目的：發起銀行卡代收訂單，直接響應轉入銀行帳戶的詳細資訊（行名、帳號、戶名、備注），客戶依此資訊進行銀行轉帳
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：轉入資訊類代收接口

**接口協議**：與通用規範一致

> **注意**：此接口與 [4. 代收接口（純卡網關）] 使用相同 URL，需由後台配置或渠道分配決定響應格式。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank_id | String | 否 | 指定銀行代碼，例如 `ACB` |
| available_bank_random | Boolean | 否 | `true` 時自動匹配可用銀行 |
| memo | String | 否 | 自定義備注 |
| paid_name | String | 否 | 付款人姓名 |
| sign | String | 否 | 簽名（見通用簽名規則） |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "memo": "custom_memo_test",
    "paid_name": "王小明"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.bank_id | String | 轉入銀行代碼 |
| data.bank_name | String | 轉入銀行名稱 |
| data.account_number | String | 轉入帳號 |
| data.bank_owner | String | 收款帳戶戶名 |
| data.memo | String | 轉帳備注（付款時需填入此備注） |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "bank_id": "ACB",
        "bank_name": "NGAN HANG TMCP A CHAU (ACB)",
        "account_number": "1234567890",
        "bank_owner": "NGUYEN VAN A",
        "memo": "custom_memo_test"
    }
}
```

---

### 6. 代收接口（銀行直連）

**接口說明**
- 名稱：代收接口 - 銀行直連
- 功能與目的：通過銀行直連方式發起代收，響應收銀台地址與 QR code，`bank` 為必填字段
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：複合類代收接口

**接口協議**：與通用規範一致

> **注意**：此接口的銀行字段名稱為 `bank`（必填），與其他代收接口使用 `bank_id`（選填）不同。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank | String | 是 | 銀行代碼（例如 `ACB`），此接口為**必填** |
| paid_name | String | 否 | 付款人姓名 |
| sign | String | 否 | 簽名 |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank": "ACB",
    "paid_name": "王小明"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.uri | String | 收銀台網址，供客戶跳轉 |
| data.qrcode | String | QR code 內容，商戶自行生成 QR 圖片 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "uri": "https://tianciv690215.com/checkout/abc123",
        "qrcode": "VietcomBank0529THAI"
    }
}
```

---

### 7. 代收接口（網銀掃碼）

**接口說明**
- 名稱：代收接口 - 網銀掃碼
- 功能與目的：通過網銀掃碼方式發起代收，響應收銀台地址與 QR code
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：複合類代收接口

**接口協議**：與通用規範一致

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank | String | 否 | 銀行代碼 |
| memo | String | 否 | 自定義備注 |
| paid_name | String | 否 | 付款人真實姓名（掃碼支付使用） |
| sign | String | 否 | 簽名 |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank": "ACB",
    "paid_name": "王小明"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.uri | String | 收銀台網址，供客戶跳轉 |
| data.qrcode | String | QR code 內容，商戶自行生成 QR 圖片 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "uri": "https://tianciv690215.com/checkout/abc123",
        "qrcode": "VietcomBank0529THAI"
    }
}
```

---

### 8. 代收接口（Zalo）

**接口說明**
- 名稱：代收接口 - Zalo 錢包
- 功能與目的：通過越南 Zalo 電子錢包發起代收，響應收銀台地址與 QR code
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：複合類代收接口

**接口協議**：與通用規範一致

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank_id | String | 否 | 銀行代碼 |
| available_bank_random | Boolean | 否 | 自動匹配可用銀行 |
| memo | String | 否 | 自定義備注 |
| paid_name | String | 否 | 付款人姓名 |
| sign | String | 否 | 簽名 |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "memo": "custom_memo_test",
    "paid_name": "王小明"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.uri | String | 收銀台網址（供客戶跳轉） |
| data.qrcode | String | QR code 內容，商戶自行生成 QR 圖片 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "uri": "https://tianciv690215.com/checkout/abc123",
        "qrcode": "VietcomBank0529THAI"
    }
}
```

---

### 9. 代收接口（MoMo）

**接口說明**
- 名稱：代收接口 - MoMo 電子錢包
- 功能與目的：通過越南 MoMo 電子錢包發起代收，響應收銀台地址與 QR code
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：複合類代收接口

**接口協議**：與通用規範一致

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank_id | String | 否 | 銀行代碼 |
| available_bank_random | Boolean | 否 | 自動匹配可用銀行 |
| memo | String | 否 | 自定義備注 |
| paid_name | String | 否 | 付款人姓名 |
| sign | String | 否 | 簽名 |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "paid_name": "王小明"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.uri | String | 收銀台網址（供客戶跳轉） |
| data.qrcode | String | QR code 內容，商戶自行生成 QR 圖片 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "uri": "https://tianciv690215.com/checkout/abc123",
        "qrcode": "VietcomBank0529THAI"
    }
}
```

---

### 10. 代收接口（ViettelMoney）

**接口說明**
- 名稱：代收接口 - ViettelMoney 電子錢包
- 功能與目的：通過越南 ViettelMoney 電子錢包發起代收，響應收銀台地址與 QR code
- 接口 URL：`POST https://tianciv690215.com/api/transaction`

**接口分類**：複合類代收接口

**接口協議**：與通用規範一致

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 代收金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank_id | String | 否 | 銀行代碼 |
| available_bank_random | Boolean | 否 | 自動匹配可用銀行 |
| memo | String | 否 | 自定義備注 |
| paid_name | String | 否 | 付款人姓名 |
| sign | String | 否 | 簽名 |

請求範例：
```json
{
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "memo": "custom_memo_test",
    "paid_name": "王小明",
    "sign": "aae763662eac995a82d10b2071ee98ae"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.uri | String | 收銀台網址（供客戶跳轉） |
| data.qrcode | String | QR code 內容，商戶自行生成 QR 圖片 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "uri": "https://tianciv690215.com/checkout/abc123",
        "qrcode": "VietcomBank0529THAI"
    }
}
```

---

## 二、代付接口

### 11. 代付銀行列表接口

**接口說明**
- 名稱：代付銀行列表
- 功能與目的：獲取平台支持代付的所有銀行列表，`id` 字段用於代付訂單的 `bank_id` 參數
- 接口 URL：`GET https://tianciv690215.com/api/payment-bank`

**接口分類**：查詢類接口

**接口協議**：與通用規範一致

**請求報文（Request）**

> 無請求體，僅需 Header 認證。

| Header 字段 | 必填 | 說明 |
|-------------|------|------|
| Accept | 是 | `application/json` |
| Content-Type | 是 | `application/json` |
| Authorization | 是 | `Bearer {api_token}` |

請求範例：
```bash
curl -X GET https://tianciv690215.com/api/payment-bank \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data | Array | 銀行列表 |
| data[].id | String | 銀行代碼（用於代付接口的 `bank_id`） |
| data[].name | String | 銀行全名 |

響應範例：
```json
{
    "success": true,
    "data": [
        {"id": "ACB", "name": "NGAN HANG TMCP A CHAU (ACB)"},
        {"id": "TCB", "name": "NGAN HANG TMCP KY THUONG VIET NAM (TCB)"}
    ]
}
```

---

### 12. 代付查詢接口

**接口說明**
- 名稱：代付訂單查詢
- 功能與目的：以商戶訂單號查詢代付訂單的狀態與詳細資訊
- 接口 URL：`GET https://tianciv690215.com/api/payment/{out_trade_no}`

**接口分類**：查詢類接口

**接口協議**：與通用規範一致

**請求報文（Request）**

> 訂單號放於 URL Path，無請求體。

| 參數 | 位置 | 類型 | 必填 | 說明 |
|------|------|------|------|------|
| out_trade_no | Path | String | 是 | 商戶訂單號 |

請求範例：
```bash
curl -X GET https://tianciv690215.com/api/payment/2014072300007148 \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 代付金額 |
| data.bank_id | String | 收款銀行代碼 |
| data.account_number | String | 收款帳號 |
| data.bank_owner | String | 收款帳戶戶名 |
| data.state | String | 訂單狀態，見下表 |

**訂單狀態說明（state）**

| 狀態值 | 說明 |
|--------|------|
| new | 新建，待處理 |
| processing | 處理中 |
| verify | 驗證中 |
| reject | 已拒絕 |
| completed | 已完成 |
| failed | 已失敗 |
| refund | 已退款 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "774757bb-23e5-4fee-89f6-6be9171fd59e",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "bank_id": "ACB",
        "account_number": "1234567890",
        "bank_owner": "NGUYEN VAN A",
        "state": "completed"
    }
}
```

---

### 13. 代付接口

**接口說明**
- 名稱：代付（出金）接口
- 功能與目的：向指定銀行帳戶發起代付（出金/提現）請求，包含目的地帳號、收款人姓名及銀行資訊。此接口的 `sign` 為**必填**。
- 接口 URL：`POST https://tianciv690215.com/api/payment`

**接口分類**：代付類接口

**接口協議**：與通用規範一致，但 `sign` 字段為**必填**（與代收接口不同）

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| out_trade_no | String | 是 | 商戶訂單號（全局唯一） |
| bank_id | String | 是 | 收款銀行代碼（例如 `ACB`） |
| bank_owner | String | 是 | 收款帳戶戶名（收款人姓名） |
| account_number | String | 是 | 收款銀行帳號 |
| amount | Float | 是 | 代付金額 |
| callback_url | String | 是 | 異步回調通知地址 |
| sign | String | 是 | 簽名（**必填**，見通用簽名規則） |

**簽名說明**：

排除 `sign` 字段，將其餘字段按 key 的 ASCII 碼排序，拼接後附加 `api_token` 和 `notify_token`，取 MD5：

```
account_number=1234567890&amount=500&bank_id=ACB&bank_owner=NGUYEN VAN A&callback_url=https://www.example.com/notify&out_trade_no=2014072300007148{api_token}{notify_token}
```
→ MD5 → `sign`

請求範例：
```json
{
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "bank_owner": "NGUYEN VAN A",
    "account_number": "1234567890",
    "amount": 500,
    "callback_url": "https://www.example.com/notify",
    "sign": "aae763662eac995a82d10b2071ee98ae"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 代付金額 |
| data.bank_id | String | 收款銀行代碼 |
| data.account_number | String | 收款帳號 |
| data.bank_owner | String | 收款帳戶戶名 |
| data.callback_url | String | 回調地址 |
| data.state | String | 訂單狀態（new / processing / reject / completed / failed / refund） |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "bank_id": "ACB",
        "account_number": "1234567890",
        "bank_owner": "NGUYEN VAN A",
        "callback_url": "https://www.example.com/notify",
        "state": "new"
    }
}
```

---

## 三、異步通知接口（Webhook / Callback）

### 14. 代收異步回調

**接口說明**
- 名稱：代收異步回調通知
- 功能與目的：訂單達到終態（completed / refund / failed）時，平台以 HTTP POST 主動推送結果至商戶在請求中提供的 `callback_url`。商戶需驗簽後更新訂單狀態。

**接口協議**
- 推送方式：HTTP POST（由平台發起）
- Content-Type：`application/json`
- 觸發條件：僅在訂單成功、退款或失敗時觸發，處理中狀態不推送

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| trade_no | String | 平台訂單號 |
| out_trade_no | String | 商戶訂單號 |
| amount | Int | 實際到帳金額 |
| request_amount | Int | 商戶請求金額 |
| state | String | 訂單終態：`completed` / `refund` / `failed` |
| sign | String | 簽名（商戶需驗證） |
| callback_url | String | 本次回調的目標地址 |

**驗簽規則**：

取 `trade_no`、`amount`、`out_trade_no`、`state` 四個字段，按 ASCII 碼排序，拼接後附加 `api_token` 和 `notify_token`，MD5 驗簽：

```
amount=300000&out_trade_no=lt0085DB4AE5444B_60509043_112159&state=completed&trade_no=fdd49c43-e1c1-49da-9d23-8027f5412fe6{api_token}{notify_token}
```
→ MD5 → 應與 `sign` 一致

回調請求範例：
```json
{
    "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
    "out_trade_no": "lt0085DB4AE5444B_60509043_112159",
    "amount": 300000,
    "request_amount": 300000,
    "state": "completed",
    "sign": "d41d8cd98f00b204e9800998ecf8427e",
    "callback_url": "https://www.example.com/notify"
}
```

**回調響應報文（Response，商戶收到後需回覆的內容）**

> 商戶必須回覆純文字字串 `ok`，否則平台將重複推送。

```
ok
```

---

### 15. 代付異步回調

**接口說明**
- 名稱：代付異步回調通知
- 功能與目的：代付訂單達到終態（completed / refund / failed）時，平台以 HTTP POST 主動推送結果至商戶在請求中提供的 `callback_url`。商戶需驗簽後更新訂單狀態。

**接口協議**
- 推送方式：HTTP POST（由平台發起）
- Content-Type：`application/json`
- 觸發條件：僅在訂單成功、退款或失敗時觸發

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| trade_no | String | 平台訂單號 |
| out_trade_no | String | 商戶訂單號 |
| amount | Int | 代付金額 |
| state | String | 訂單終態：`completed` / `refund` / `failed` |
| sign | String | 簽名（商戶需驗證） |
| callback_url | String | 本次回調的目標地址 |
| errors | String | 失敗原因（選填，需後台開啟此功能） |

**驗簽規則**：與代收回調相同，取 `trade_no`、`amount`、`out_trade_no`、`state` 按 ASCII 排序，拼接後附加 `api_token` + `notify_token`，MD5 驗簽。

回調請求範例：
```json
{
    "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
    "out_trade_no": "2014072300007148",
    "amount": 500,
    "state": "completed",
    "sign": "d41d8cd98f00b204e9800998ecf8427e",
    "callback_url": "https://www.example.com/notify"
}
```

**回調響應報文（Response，商戶收到後需回覆的內容）**

> 商戶必須回覆純文字字串 `ok`。

```
ok
```

---

## 四、其他接口

### 16. 餘額查詢

**接口說明**
- 名稱：帳戶餘額查詢
- 功能與目的：查詢商戶帳戶當前剩餘可下發（代付）餘額
- 接口 URL：`GET https://tianciv690215.com/api/balance/inquiry`

**接口分類**：查詢類接口

**接口協議**：與通用規範一致

**請求報文（Request）**

> 無請求體，僅需 Header 認證。

請求範例：
```bash
curl -X GET https://tianciv690215.com/api/balance/inquiry \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 請求是否成功 |
| data.balance | Float | 剩餘可下發餘額 |

響應範例：
```json
{
    "success": true,
    "data": {
        "balance": 1910
    }
}
```

---

## 附錄：錯誤代碼

所有錯誤響應格式：

```json
{
    "success": false,
    "status_code": 422,
    "message": "傳送資料有誤",
    "errors": { ... }
}
```

| 狀態碼 | 說明 |
|--------|------|
| 401 | Token 錯誤或未授權 |
| 404 | 資源不存在 |
| 422 | 請求參數有誤（傳送資料有誤） |
| 429 | 請求頻率過高 |
| 1000 | 渠道容量不足 |
| 1001 | 代付稽核錯誤 |
| 1002 | 重複訂單（金額、付款人、備注完全相同的進行中訂單） |
