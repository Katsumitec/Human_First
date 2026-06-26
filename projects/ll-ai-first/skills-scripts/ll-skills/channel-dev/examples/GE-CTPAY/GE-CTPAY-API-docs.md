# GE-CTPAY API 接口文檔分析

> 文檔來源：https://tianciv420428.com/docs
> 分析日期：2026-03-23

---

## 通用協議規範

### 通信協議

- 協議類型：HTTPS
- Base URL：`https://tianciv420428.com`
- 請求方式：GET（查詢類）、POST（交易類）

### 報文格式

- Content-Type：`application/json`
- 請求格式：JSON
- 響應格式：JSON
- 字符編碼：UTF-8

### 安全協議

- **認證方式**：Bearer Token（每個請求 Header 必須帶 `Authorization: Bearer api_token`）
- **簽名算法**：MD5（小寫 HEX 輸出）
- **代收請求簽名**：選填（API 說「非必要請勿填寫」）
- **代付請求簽名**：**必填**
- **回調通知簽名**：使用特殊 4 欄位簽名方式（見下）

#### 回調簽名規則

```
1. 取固定 4 個欄位：trade_no, amount, out_trade_no, state
   （代收回調額外排除：request_amount, callback_url, sign）
   （代付回調額外排除：callback_url, sign）
2. 對這 4 個欄位按 key 的 ASCII 碼遞增排序（PHP ksort）
3. 串接為 key=value&key=value... 格式
4. 在串接結果後直接拼接 api_token（無分隔符）
5. 再直接拼接 notify_token（無分隔符）
6. 對上述完整字串做 MD5 hash（小寫 hex 輸出）

示例：
md5("amount=300000&out_trade_no=lt0085DB4AE5444B&state=completed&trade_no=fdd49c43api_tokennotify_token")
→ 1ed30abda08395adb9cacabca1d669ad
```

#### 代付請求簽名規則

```
1. 取請求 body 中除 sign 外所有欄位
2. 按 key 的 ASCII 碼遞增排序（ksort）
3. 串接為 key=value&key=value... 格式
4. 在串接結果後直接拼接 api_token + notify_token
5. MD5（小寫 hex）

示例：
md5("VerifyChannelNo=1&account_number=...&amount=500&bank_id=ACB&bank_owner=DAO VAN THANG&callback_url=...&out_trade_no=...api_tokennotify_token")
→ e986a215c570506f480e6d3acb6b0135
```

### 通用請求 Header

```
Accept: application/json
Content-Type: application/json
Authorization: Bearer api_token
```

---

## 接口列表

### 代收接口

| 接口名稱 | URL | 方法 | 分類 |
|----------|-----|------|------|
| 代收銀行列表 | /api/bank | GET | Q:查詢 |
| 代收啟用銀行列表 | /api/bank/published | GET | Q:查詢 |
| 代收查詢 | /api/transaction/{out_trade_no} | GET | Q:查詢 |
| 代收接口（純卡網關） | /api/transaction | POST | C:複合類 |
| 代收接口（純卡網關-JSON） | /api/transaction | POST | I:轉入資訊類 |
| 代收接口（銀行直連） | /api/transaction | POST | C:複合類 |
| 代收接口（網銀掃碼） | /api/transaction | POST | C:複合類 |
| 代收接口（Zalo） | /api/transaction | POST | R:跳轉類 |
| 代收接口（MoMo） | /api/transaction | POST | R:跳轉類 |
| 代收接口（ViettelMoney） | /api/transaction | POST | R:跳轉類 |
| 代收回調 | callback_url（商戶提供） | POST | N:異步通知 |

### 代付接口

| 接口名稱 | URL | 方法 | 分類 |
|----------|-----|------|------|
| 代付銀行列表 | /api/payment-bank | GET | Q:查詢 |
| 代付查詢 | /api/payment/{out_trade_no} | GET | Q:查詢 |
| 代付接口 | /api/payment | POST | W:代付類 |
| 代付回調 | callback_url（商戶提供） | POST | N:異步通知 |

### 其他接口

| 接口名稱 | URL | 方法 | 分類 |
|----------|-----|------|------|
| 餘額查詢 | /api/balance/inquiry | GET | Q:查詢 |
| 錯誤訊息規範 | — | — | 附錄 |

---

## 代收接口詳細說明

### 1. 代收銀行列表接口

**接口說明**
- 名稱：代收銀行列表
- 功能：獲取支持的銀行列表及代碼
- 接口 URL：`https://tianciv420428.com/api/bank`
- 請求方式：GET
- 請求格式：無 body

**接口分類**：Q:查詢類

**請求 Header**：同通用規範

**請求報文（Request）**：無 body

CURL 範例：
```bash
curl -X GET https://tianciv420428.com/api/bank \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 狀態 true/false |
| data[].id | String | 銀行代碼（提交時使用，如 ACB） |
| data[].name | String | 銀行名稱 |

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

### 2. 代收啟用銀行列表接口

**接口說明**
- 名稱：代收啟用銀行列表
- 功能：獲取當前可用（已啟用）的銀行代碼列表
- 接口 URL：`https://tianciv420428.com/api/bank/published`
- 請求方式：GET

**接口分類**：Q:查詢類

CURL 範例：
```bash
curl -X GET https://tianciv420428.com/api/bank/published \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

響應範例：
```json
{
    "data": ["ACB", "BIDV", "SACOMBANK", "TCB", "VCB"],
    "success": true
}
```

---

### 3. 代收查詢接口

**接口說明**
- 名稱：代收訂單查詢
- 功能：透過商戶訂單號查詢代收訂單狀態
- 接口 URL：`https://tianciv420428.com/api/transaction/{out_trade_no}`
- 請求方式：GET

**接口分類**：Q:查詢類

**請求 Header**：同通用規範

CURL 範例：
```bash
curl -X GET https://tianciv420428.com/api/transaction/2014072300007148 \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

> ⚠️ 交易狀態碼說明（重要）：

| state 值 | 說明 | 映射狀態 |
|----------|------|----------|
| `new` | 新訂單 | 01（處理中） |
| `processing` | 處理中 | 01（處理中） |
| `verify` | 待確認 | 01（處理中） |
| `completed` | **成功** | **10（成功）** |
| `failed` | 失敗 | 20（失敗） |
| `reject` | 拒絕 | 20（失敗） |
| `refund` | 沖回 | 20（失敗） |

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | true/false |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.request_amount | String | 請求支付金額 |
| data.amount | String | 實際支付金額 |
| data.state | String | 狀態碼（見上表） |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "774757bb-23e5-4fee-89f6-6be9171fd59e",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "request_amount": "500",
        "state": "completed"
    }
}
```

---

### 4. 代收接口（純卡網關）

**接口說明**
- 名稱：代收接口（純卡網關）
- 功能：提交代收訂單，返回 QR 碼內容與跳轉 URL，供商戶自製收銀台展示
- 接口 URL：`https://tianciv420428.com/api/transaction`
- 請求方式：POST
- Content-Type：`application/json`
- **業務說明**：返回 `data.uri`（跳轉到平台收銀台）和 `data.qrcode`（供商戶自行生成 QR 碼）

**接口分類**：C:複合類代收接口

**請求 Header**：同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 支付請求金額（VND） |
| callback_url | String | 是 | 異步回調通知 URL |
| out_trade_no | String | 是 | 商戶訂單號 |
| bank_id | String | 否 | 銀行代碼（選填） |
| available_bank_random | Bool | 否 | 自動隨機匹配可用銀行 |
| memo | String | 否 | 客制備注（非必要請勿填寫） |
| paid_name | String | 否 | 銀行實名（非必要請勿填寫） |
| sign | String | 否 | 簽名（非必要請勿填寫） |

請求範例：
```json
{
    "amount": "500",
    "out_trade_no": "2014072300007148",
    "callback_url": "https://www.example.com/notify"
}
```

CURL 範例：
```bash
curl -X POST https://tianciv420428.com/api/transaction \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json' \
  -d '{
    "amount": "500",
    "out_trade_no": "2014072300007148",
    "callback_url": "https://www.example.com/notify"
  }'
```

**響應報文（Response）**

> 同步響應僅表示提交成功，交易狀態為處理中（01），最終結果由異步通知確認。

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 提交狀態 true/false |
| data.trade_no | String | 平台訂單號 |
| data.amount | String | 支付請求金額 |
| data.out_trade_no | String | 商戶訂單號 |
| data.uri | String | 收銀台跳轉 URL |
| data.qrcode | String | QR 碼內容（供商戶自製收銀台使用） |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500.00",
        "uri": "https://qr.example.com/xxxxx",
        "qrcode": "071421410002956985030697004BDV0514CN"
    }
}
```

---

### 5. 代收接口（純卡網關-JSON）

**接口說明**
- 名稱：代收接口（純卡網關-JSON）
- 功能：與純卡網關相同，但響應包含完整銀行轉帳資訊（帳號、行名、戶名、金額、附言），供商戶客制化收銀台
- 接口 URL：`https://tianciv420428.com/api/transaction`
- 請求方式：POST（需加 `"type":"json"` 參數）

**接口分類**：I:轉入資訊類代收接口

**請求報文**：與純卡網關相同，另加 `"type": "json"` 字段

請求範例：
```json
{
    "type": "json",
    "amount": "500",
    "out_trade_no": "2014072300007148",
    "callback_url": "https://www.example.com/notify"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | 提交狀態 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.bank_id | String | 轉帳銀行代碼 |
| data.bank_name | String | 轉帳銀行名稱 |
| data.account_number | String | 轉入卡號 |
| data.bank_owner | String | 轉入帳戶姓名 |
| data.amount | String | 轉帳金額 |
| data.memo | String | 附言（轉帳時需填寫） |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "bank_id": "ABC",
        "bank_name": "NGAN HANG TMCP A CHAU (ACB)",
        "account_number": "123457890",
        "bank_owner": "王小明",
        "amount": "100000",
        "memo": "43983"
    }
}
```

---

### 6. 代收接口（銀行直連）

**接口說明**
- 名稱：代收接口（銀行直連）
- 功能：指定銀行提交代收訂單，`bank` 字段**必填**
- 接口 URL：`https://tianciv420428.com/api/transaction`
- 請求方式：POST

**接口分類**：C:複合類代收接口

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 支付金額 |
| callback_url | String | 是 | 異步回調 URL |
| out_trade_no | String | 是 | 商戶訂單號 |
| bank | String | **是** | 銀行代碼（**必填**，與純卡網關的 bank_id 字段名不同！） |
| paid_name | String | 否 | 銀行實名 |
| sign | String | 否 | 簽名 |

請求範例：
```json
{
    "amount": "500",
    "out_trade_no": "2014072300007148",
    "callback_url": "https://www.example.com/notify",
    "bank": "ACB"
}
```

**響應報文**：與純卡網關相同（含 data.uri 和 data.qrcode）

---

### 7. 代收接口（網銀掃碼）

**接口說明**
- 名稱：代收接口（網銀掃碼）
- 功能：網銀掃碼支付，bank 字段選填
- 接口 URL：`https://tianciv420428.com/api/transaction`
- 請求方式：POST

**接口分類**：C:複合類代收接口

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Float | 是 | 支付金額 |
| callback_url | String | 是 | 異步回調 URL |
| out_trade_no | String | 是 | 商戶訂單號 |
| bank | String | 否 | 銀行代碼（選填） |
| memo | String | 否 | 客制備注 |
| paid_name | String | 否 | 銀行實名 |
| sign | String | 否 | 簽名 |

**響應報文**：與純卡網關相同（含 data.uri 和 data.qrcode）

---

### 8. 代收接口（Zalo / MoMo / ViettelMoney）

- 接口 URL、請求/響應格式與純卡網關相同
- 不在本次對接範圍

---

### 9. 代收回調（異步通知）

**接口說明**
- 名稱：代收異步通知
- 功能：代收完成後，渠道以 POST 方式推送通知至商戶提供的 callback_url
- 通知方式：HTTP POST（渠道主動推送）
- **重要**：**只回調成功（completed）的訂單**
- 回調成功需回覆純文字 `ok`

**接口分類**：N:異步通知接口

**回調請求 Header**

| Header 名稱 | 說明 |
|-------------|------|
| Content-Type | application/json |

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| trade_no | String | 平台訂單號 |
| request_amount | Int | 支付請求金額 |
| amount | Int | 支付實際金額 |
| out_trade_no | String | 商戶訂單號（對應我方 chnlOrderId） |
| state | String | 狀態碼（completed = 成功） |
| sign | String | 驗簽用簽名 |
| callback_url | String | 回調地址 |

> ⚠️ 簽名驗證：4 欄位（trade_no, amount, out_trade_no, state）+ api_token + notify_token 的 MD5
> 排除欄位：sign, request_amount, callback_url

回調請求範例：
```json
{
    "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
    "amount": "300000",
    "request_amount": "300000",
    "out_trade_no": "lt0085DB4AE5444B_60509043_112159",
    "state": "completed",
    "callback_url": "https://www.example.com/notify",
    "sign": "1ed30abda08395adb9cacabca1d669ad"
}
```

CURL 回調請求範例：
```bash
curl -X POST https://www.example.com/notify \
  -H 'Content-Type: application/json' \
  -d '{
    "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
    "amount": "300000",
    "request_amount": "300000",
    "out_trade_no": "lt0085DB4AE5444B_60509043_112159",
    "state": "completed",
    "callback_url": "https://www.example.com/notify",
    "sign": "1ed30abda08395adb9cacabca1d669ad"
  }'
```

**回調響應報文（Response，商戶需回覆）**

```
ok
```

---

## 代付接口詳細說明

### 10. 代付銀行列表接口

**接口說明**
- 接口 URL：`https://tianciv420428.com/api/payment-bank`
- 請求方式：GET
- 響應格式與代收銀行列表相同

---

### 11. 代付查詢接口

**接口說明**
- 名稱：代付訂單查詢
- 接口 URL：`https://tianciv420428.com/api/payment/{out_trade_no}`
- 請求方式：GET

**接口分類**：Q:查詢類

CURL 範例：
```bash
curl -X GET https://tianciv420428.com/api/payment/2014072300007148 \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json'
```

**響應報文（Response）**

> ⚠️ 代付查詢狀態碼說明（重要）：

| state 值 | 說明 | 映射狀態 |
|----------|------|----------|
| `new` | 新訂單 | 01（處理中） |
| `processing` | 處理中 | 01（處理中） |
| `verify` | 待審核 | 01（處理中） |
| `completed` | **成功** | **10（成功）** |
| `failed` | **失敗** | **20（失敗）** |
| `reject` | **拒絕** | **20（失敗）** |
| `refund` | **沖回** | **20（失敗）** |

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | true/false |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 支付請求金額 |
| data.bank_id | String | 交易方銀行代碼 |
| data.account_number | String | 入款銀行卡號 |
| data.bank_owner | String | 交易方名稱 |
| data.state | String | 狀態碼 |
| data.bank_account | String | 出款交易卡號末五碼 |

響應範例：
```json
{
    "success": true,
    "data": {
        "trade_no": "774757bb-23e5-4fee-89f6-6be9171fd59e",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "bank_id": "ACB",
        "account_number": "6212262000000000001",
        "bank_owner": "測試帳號",
        "state": "completed",
        "bank_account": "12345"
    }
}
```

---

### 12. 代付接口

**接口說明**
- 名稱：代付接口
- 功能：發起出金/轉帳請求，**sign 必填**
- 接口 URL：`https://tianciv420428.com/api/payment`
- 請求方式：POST
- Content-Type：`application/json`

**接口分類**：W:代付類接口

**請求 Header**：同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| out_trade_no | String | 是 | 商戶訂單號 |
| bank_id | String | 是 | 銀行代碼 |
| bank_owner | String | 是 | 收款人姓名 |
| account_number | String | 是 | 收款銀行卡號 |
| amount | Float | 是 | 請求金額（VND） |
| callback_url | String | 是 | 異步回調 URL |
| sign | String | 是 | **簽名（必填）** |
| VerifyChannelNo | String | （？） | 驗證渠道號（官方示例含此字段，值固定為"1"） |

> ⚠️ `VerifyChannelNo=1` 出現在官方簽名示例中，建議帶上。

請求範例：
```json
{
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "bank_owner": "DAO VAN THANG",
    "account_number": "6212262000000000001",
    "amount": "500",
    "callback_url": "https://www.example.com/notify",
    "VerifyChannelNo": "1",
    "sign": "e986a215c570506f480e6d3acb6b0135"
}
```

CURL 範例：
```bash
curl -X POST https://tianciv420428.com/api/payment \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer api_token' \
  -H 'Content-Type: application/json' \
  -d '{
    "out_trade_no": "2014072300007148",
    "bank_id": "ACB",
    "bank_owner": "DAO VAN THANG",
    "account_number": "6212262000000000001",
    "amount": "500",
    "callback_url": "https://www.example.com/notify",
    "VerifyChannelNo": "1",
    "sign": "e986a215c570506f480e6d3acb6b0135"
  }'
```

**響應報文（Response）**

> 代付同步響應只表示「提交成功/失敗」，交易狀態通常為 `new`（新訂單/處理中），最終成功/失敗依異步通知確認。

| 字段名 | 類型 | 說明 |
|--------|------|------|
| success | Boolean | true=提交成功，false=提交失敗 |
| data.trade_no | String | 平台訂單號 |
| data.out_trade_no | String | 商戶訂單號 |
| data.amount | String | 支付請求金額 |
| data.bank_id | String | 銀行代碼 |
| data.account_number | String | 收款卡號 |
| data.bank_owner | String | 收款人 |
| data.state | String | 初始狀態（通常為 new） |

響應範例：
```json
{
    "data": {
        "trade_no": "2f43e840-79f6-4f6b-ae69-1c2085b32106",
        "out_trade_no": "2014072300007148",
        "amount": "500",
        "bank_id": "ACB",
        "account_number": "6212262000000000001",
        "bank_owner": "王小明",
        "callback_url": "https://www.example.com/notify",
        "state": "new"
    },
    "success": true
}
```

---

### 13. 代付回調（異步通知）

**接口說明**
- 名稱：代付異步通知
- 功能：代付完成後推送通知
- **觸發條件**：僅在訂單狀態為 **成功 / 沖回 / 失敗** 時回調
- 回調成功需回覆純文字 `ok`

**接口分類**：N:異步通知接口

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| trade_no | String | 平台訂單號 |
| amount | Int | 支付請求金額 |
| out_trade_no | String | 商戶訂單號 |
| state | String | 狀態碼（completed/refund/failed） |
| sign | String | 驗簽簽名 |
| callback_url | String | 回調地址 |
| errors | String | 失敗原因（需申請開啟，僅失敗訂單有此字段） |

> ⚠️ 代付狀態碼（回調）：
> - `completed` → **成功（10）**
> - `failed` → **失敗（20）**
> - `refund` → **沖回（20）**
>
> ⚠️ 簽名驗證：4 欄位（trade_no, amount, out_trade_no, state）+ api_token + notify_token 的 MD5
> 排除欄位：sign, callback_url

回調請求範例：
```json
{
    "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
    "amount": "300000",
    "out_trade_no": "lt0085DB4AE5444B_60509043_112159",
    "state": "completed",
    "callback_url": "https://www.example.com/notify",
    "sign": "1ed30abda08395adb9cacabca1d669ad"
}
```

**回調響應（商戶需回覆）**：
```
ok
```

---

## 其他接口

### 14. 餘額查詢

- 接口 URL：`https://tianciv420428.com/api/balance/inquiry`
- 請求方式：GET
- 響應：`data.balance`（Float，可下發餘額）

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

## 附錄

### 錯誤訊息格式

```json
{
    "success": false,
    "status_code": 422,
    "message": "validation error",
    "errors": {
        "out_trade_no": ["out trade no 栏位为必填"]
    }
}
```

### Status Code 定義

| Status Code | 描述 |
|-------------|------|
| 401 | token 錯誤 |
| 404 | 找不到資料 |
| 422 | 傳送資料有誤 |
| 429 | 請求次數過多 |
| 1000 | 通道數量不足 |
| 1001 | 代付稽核錯誤 |
| 1002 | 有重複「金額+付款人+附言」訂單進行中 |

### 代收狀態碼彙整

| state | 中文 | 代收 notify | 代收查詢 |
|-------|------|------------|---------|
| new | 新訂單 | —（不回調） | 01 |
| processing | 處理中 | —（不回調） | 01 |
| verify | 待確認 | —（不回調） | 01 |
| completed | 成功 | 10 | 10 |
| failed | 失敗 | —（不回調） | 20 |
| reject | 拒絕 | —（不回調） | 20 |
| refund | 沖回 | —（不回調） | 20 |

> 代收回調：只回調 completed（成功）訂單！

### 代付狀態碼彙整

| state | 中文 | 代付 sync resp | 代付 notify | 代付查詢 |
|-------|------|---------------|------------|---------|
| new | 新訂單 | 01 | —（不回調） | 01 |
| processing | 處理中 | 01 | —（不回調） | 01 |
| verify | 待審核 | 01 | —（不回調） | 01 |
| completed | 成功 | — | 10 | 10 |
| failed | 失敗 | — | 20 | 20 |
| reject | 拒絕 | — | 20 | 20 |
| refund | 沖回 | — | 20 | 20 |

> 代付同步響應只判斷 success 字段（true=01處理中，false=20失敗）
