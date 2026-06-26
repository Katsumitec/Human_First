# GA-GoldPay API 接口文檔分析

> 渠道編號：GA
> 渠道名稱：GoldPay
> 文檔來源：https://api.goldpay8.site/#/guide（SPA 應用，透過 JS bundle 逆向提取）
> 分析日期：2026-03-11

---

## 通用協議規範

### 通信協議
- 協議類型：HTTP / HTTPS
- Base URL：`https://api.pgvn.vn-pay.co`（越南區域實際接口地址）
- 請求方式：POST

### 報文格式
- Content-Type：`application/x-www-form-urlencoded`
- 請求格式：Form 表單（URL 鍵值對，key-values）
- 響應格式：JSON
- 字符編碼：UTF-8

### 安全協議
- 簽名算法：**SHA256**
- 簽名字段：所有非空參數值
- 簽名位置：Body（作為 `sign` 字段提交）
- 加密方式：無（僅簽名驗證）
- 其他安全機制：IP 白名單（回調 IP：52.34.55.206）

### 簽名規則

**簽名步驟：**

1. 將所有**非空參數值**的參數按照參數名 **ASCII 碼從小到大排序**（字典序），使用 URL 鍵值對的格式（即 `key1=value1&key2=value2…`）拼接成字符串。
2. 在字符串最後拼接上 `&key=<商戶密鑰>`，得到待簽名字符串，對其進行 **SHA256** 運算，得到 `sign` 值。
3. 將 `sign` 加入表單參數中，提交完整表單。

> **注意**：所有非空參數都將包含在簽名中。

**簽名示例：**

假設參數為：
```
amount=100000&merchant_code=llpp8888&merchant_order_no=ORD20260310001&service_type=702
```

拼接密鑰後：
```
amount=100000&merchant_code=llpp8888&merchant_order_no=ORD20260310001&service_type=702&key=YOUR_SECRET_KEY
```

對上述字符串進行 SHA256 運算即得到 `sign` 值。

### 商戶對接資訊

取得商戶密鑰路徑：商戶後台 > 系統 > 賬戶信息 > 商戶環境
- 商戶後台：`https://bo.merc-mgmt.pgvn.vn-pay.co/#/login`

---

## 接口列表

### 接口總覽

| 序號 | 接口名稱 | URL | 請求方式 | 分類 |
|------|----------|-----|----------|------|
| 1 | 代收下單接口 | `<DOMAIN>/sha256/deposit` | POST | R:跳轉類代收接口 |
| 2 | 代付下單接口 | `<DOMAIN>/sha256/withdraw` | POST | W:代付類接口 |
| 3 | 代收回調通知 | `<MERCHANT_DEPOSIT_CALLBACK_URL>` | POST | N:異步通知接口 |
| 4 | 代付回調通知 | `<MERCHANT_WITHDRAW_CALLBACK_URL>` | POST | N:異步通知接口 |
| 5 | 查詢訂單接口 | `<DOMAIN>/sha256/query-order` | POST | Q:查詢類接口 |
| 6 | 餘額查詢接口 | `<DOMAIN>/sha256/balance` | POST | Q:查詢類接口 |

> DOMAIN = `https://api.pgvn.vn-pay.co`

---

## 代收接口

### 1. 代收下單接口（Deposit Request API）

**接口說明**
- 名稱：代收下單接口（Deposit Request API）
- 功能與目的：商戶發起代收（入金）請求，系統返回支付網關跳轉地址或 QR Code
- 接口 URL：`https://api.pgvn.vn-pay.co/sha256/deposit`
- 請求方式：POST
- 請求格式：Form（application/x-www-form-urlencoded）
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：R:跳轉類代收接口（響應包含 `transaction_url` 跳轉地址及 `qr_image_url`）

**接口協議**
與通用規範一致。

**請求 Header**

同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Number | Y | 訂單金額（商戶會員支付金額） |
| service_type | Number | Y | 服務類型。詳見「服務類型列表」部分 |
| bank_code | String | Conditional | 代收銀行代碼。詳見「銀行列表」部分 |
| callback_url | String | N | 回調通知地址（若為空白，將使用商戶後台設置的回調地址） |
| hashed_mem_id | String | Y | 會員唯一識別碼的 Hashed 值（例如會員 ID 或其它唯一識別碼），用於信用評分 |
| merchant_code | String | Y | 商戶號 |
| merchant_order_no | String | Y | 支付平台返回商戶訂單號（商戶代碼必須是唯一的否則會被退回） |
| acct_name | String | Conditional | 用戶姓名 |
| acct_num | String | Conditional | 用戶帳號 |
| platform | String | Y | 請帶入常數值 `PC` |
| risk_level | Number | Y | 請帶入常數值 `1`（未驗證） |
| sign | String | Y | 簽名算法。詳見「簽名規則」部分 |

請求範例：
```
amount=100000&merchant_code=llpp8888&merchant_order_no=ORD20260311001&service_type=702&callback_url=https://example.com/callback&hashed_mem_id=abc123hash&platform=PC&risk_level=1&sign=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

CURL 範例：
```bash
curl -X POST https://api.pgvn.vn-pay.co/sha256/deposit \
-H "Content-Type: application/x-www-form-urlencoded" \
-d 'amount=100000&merchant_code=llpp8888&merchant_order_no=ORD20260311001&service_type=702&callback_url=https%3A%2F%2Fexample.com%2Fcallback&hashed_mem_id=abc123hash&platform=PC&risk_level=1&sign=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
```

**響應報文（Response）**

> 此為代收下單的同步響應。`status` 字段表示 API 調用是否成功（1=成功, 0=失敗），**非最終交易狀態**。
> 交易此時尚未完成，實際交易結果需透過「代收回調通知」或「查詢訂單接口」確認。

- 響應格式：JSON
- Content-Type：application/json

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Number | Y | 訂單金額 |
| transaction_url | String | Conditional | 交易連接：啟動支付網關鏈接的網址（跳轉地址） |
| qr_image_url | String | Conditional | 交易連接：支付渠道回傳的原始二維碼 |
| trans_id | Number | Y | 交易代碼：由支付系統生成 |
| trans_time | String | Y | 交易時間：收款時間的格式（JSON 日期格式） |
| status | Number | Y | 1 = 成功（API 調用成功）, 0 = 失敗 |
| error_code | String | N | 錯誤代碼。詳見「響應錯誤列表」部分 |
| error_msg | String | N | 錯誤信息 |
| sign | String | Y | 簽名算法，錯誤時為 null |

成功響應範例：
```json
{
  "status": 1,
  "amount": 100000,
  "trans_id": 123456789,
  "trans_time": "2026-03-11T12:00:00",
  "transaction_url": "https://payment-gateway.example.com/pay/123456",
  "qr_image_url": "https://payment-gateway.example.com/qr/123456.png",
  "sign": "a1b2c3d4e5f6..."
}
```

失敗響應範例：
```json
{
  "status": 0,
  "error_code": "E00009",
  "error_msg": "service type is not allowed for the merchant",
  "sign": null
}
```

---

## 代付接口

### 2. 代付下單接口（Withdraw Request API）

**接口說明**
- 名稱：代付下單接口（Withdraw Request API）
- 功能與目的：商戶發起代付（出金/提現）請求，將資金轉入指定銀行帳戶
- 接口 URL：`https://api.pgvn.vn-pay.co/sha256/withdraw`
- 請求方式：POST
- 請求格式：Form（application/x-www-form-urlencoded）
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：W:代付類接口

**接口協議**
與通用規範一致。

**請求 Header**

同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Number | Y | 提現金額 |
| service_type | Number | Y | 服務類型。詳見「服務類型列表」部分 |
| bank_code | String | Y | 代付銀行代碼。詳見「銀行列表」部分 |
| callback_url | String | N | 回調通知地址（若為空白，將使用商戶後台設置的回調地址） |
| card_name | String | Conditional | 銀行卡姓名，service_type 為 700 時必填 |
| card_num | String | Conditional | 銀行卡號，service_type 為 700 時必填 |
| merchant_code | String | Y | 商戶號 |
| merchant_order_no | String | Y | 商戶獨一生成的請求訂單交易號碼（必須唯一否則會被退回） |
| merchant_user | String | Y | 商戶會員真實姓名 |
| mobile_no | String | Conditional | 手機號。service_type 為 700 時 mobile_no = card_num，電子支付 mobile_no 必填 |
| platform | String | Y | 請帶入常數值 `PC` |
| risk_level | Number | Y | 請帶入常數值 `1`（未驗證） |
| sign | String | Y | 簽名算法。詳見「簽名規則」部分 |

> **注意**：實際提現金額有可能跟請求金額不一致，商戶方需自行判斷。

請求範例：
```
amount=500000&bank_code=9003&callback_url=https://example.com/callback&card_name=NGUYEN+VAN+A&card_num=1234567890&merchant_code=llpp8888&merchant_order_no=WD20260311001&merchant_user=NGUYEN+VAN+A&mobile_no=1234567890&platform=PC&risk_level=1&service_type=700&sign=a1b2c3d4e5f6...
```

CURL 範例：
```bash
curl -X POST https://api.pgvn.vn-pay.co/sha256/withdraw \
-H "Content-Type: application/x-www-form-urlencoded" \
-d 'amount=500000&bank_code=9003&callback_url=https%3A%2F%2Fexample.com%2Fcallback&card_name=NGUYEN+VAN+A&card_num=1234567890&merchant_code=llpp8888&merchant_order_no=WD20260311001&merchant_user=NGUYEN+VAN+A&mobile_no=1234567890&platform=PC&risk_level=1&service_type=700&sign=a1b2c3d4e5f6...'
```

**響應報文（Response）**

> 此為代付下單的同步響應。`status` 字段表示 API 調用是否成功（1=成功, 0=失敗），**非最終交易狀態**。
> 代付交易結果需透過「代付回調通知」或「查詢訂單接口」確認。
> **特別注意**：代付交易失敗的判定必須以回調通知或查詢訂單的 `trans_status = F` 為準，同步響應的 `status=0` 僅表示 API 調用失敗（如參數錯誤），誤判可能導致系統賠付或虧損。

- 響應格式：JSON
- Content-Type：application/json

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| status | String | Y | 1 = 成功（API 調用成功）, 0 = 失敗 |
| sign | String | Y | 簽名算法，錯誤時為 null |
| error_code | String | N | 錯誤代碼。詳見「響應錯誤列表」部分 |
| error_msg | String | N | 錯誤信息 |
| trans_id | String | Y | 交易代碼：由支付系統生成 |
| trans_time | String | Y | 交易時間：收款時間的格式（JSON 日期格式） |

成功響應範例：
```json
{
  "status": 1,
  "trans_id": 987654321,
  "trans_time": "2026-03-11T12:00:00",
  "sign": "f6e5d4c3b2a1..."
}
```

失敗響應範例：
```json
{
  "status": 0,
  "error_code": "E00006",
  "error_msg": "insufficient merchant balance",
  "sign": null
}
```

---

## 異步通知接口

### 3. 代收回調通知（Deposit Callback API）

**接口說明**
- 名稱：代收回調通知（Deposit Callback API）
- 功能與目的：訂單完成時向商戶方系統指定地址發送請求，並將訂單相關數據使用 POST 參數的形式發送給商戶方系統
- 通知方式：HTTP POST（渠道主動推送至商戶回調地址）
- 通知的請求格式：Form（application/x-www-form-urlencoded）
- Content-Type：`application/x-www-form-urlencoded`

**接口協議**
與通用規範一致。

**回調請求 Header**

同通用規範。

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Number | Y | 商戶會員支付金額 |
| deposit_time | String | Y | 請求時間（yyyyMMdd hh24:mi:ss） |
| error_code | String | N | 回調錯誤代碼。請參考「回調錯誤列表」部分（無錯誤時不傳此參數） |
| merchant_order_no | String | Y | 商戶訂單號 |
| process_time | String | Y | 回調時間（yyyyMMdd hh24:mi:ss） |
| status | Number | Y | **1 = 成功, 0 = 失敗** |
| trans_id | Number | Y | 轉帳代碼：支付存款交易代碼 |
| sign | String | Y | 簽名算法 |

> **交易狀態判定（極為重要）**：
> - `status = 1`：代收交易**成功**（已入金）。**若誤判此狀態，可能導致系統賠付或虧損。**
> - `status = 0`：代收交易**失敗**。
> - 收到回調後，商戶系統應先驗證簽名，確認合法後再更新訂單狀態。

回調請求範例：
```
amount=100000&deposit_time=20260311+120000&merchant_order_no=ORD20260311001&process_time=20260311+120100&status=1&trans_id=123456789&sign=a1b2c3d4e5f6...
```

CURL 回調請求範例：
```bash
curl -X POST https://merchant.example.com/callback/deposit \
-H "Content-Type: application/x-www-form-urlencoded" \
-d 'amount=100000&deposit_time=20260311+120000&merchant_order_no=ORD20260311001&process_time=20260311+120100&status=1&trans_id=123456789&sign=a1b2c3d4e5f6...'
```

**回調響應報文（Response，商戶收到後需回覆的內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| error_msg | String | 錯誤信息 |
| status | String | 回應狀態 |

回調響應範例（JSON 格式）：
```json
{
  "status": "success",
  "error_msg": ""
}
```

---

### 4. 代付回調通知（Withdraw Callback API）

**接口說明**
- 名稱：代付回調通知（Withdraw Callback API）
- 功能與目的：代付訂單完成時向商戶方系統指定地址發送請求，並將訂單相關數據使用 POST 參數的形式發送給商戶方系統
- 通知方式：HTTP POST（渠道主動推送至商戶回調地址）
- 通知的請求格式：Form（application/x-www-form-urlencoded）
- Content-Type：`application/x-www-form-urlencoded`

**接口協議**
與通用規範一致。

**回調請求 Header**

同通用規範。

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Number | Y | **實際提現金額**（可能與請求金額不一致，商戶方需自行判斷） |
| error_code | String | N | 錯誤信息，只顯示有錯誤單子（無錯誤時不傳此參數） |
| merchant_order_no | String | Y | 商戶獨一生成的請求訂單交易號碼（必須唯一否則會被退回） |
| process_time | String | Y | 回調時間（yyyyMMdd hh24:mi:ss） |
| status | Number | Y | **1 = 成功, 0 = 失敗** |
| trans_id | Number | Y | 交易代碼：由支付系統生成 |
| sign | String | Y | 簽名算法 |

> **交易狀態判定（極為重要）**：
> - `status = 1`：代付交易**成功**（已出款）。
> - `status = 0`：代付交易**失敗**。**若誤判此狀態（將失敗判為成功），可能導致系統賠付或虧損。**
> - 收到回調後，商戶系統應先驗證簽名，確認合法後再更新訂單狀態。
> - **注意**：`amount` 為實際提現金額，可能與請求金額不一致。

回調請求範例：
```
amount=500000&merchant_order_no=WD20260311001&process_time=20260311+120500&status=1&trans_id=987654321&sign=f6e5d4c3b2a1...
```

CURL 回調請求範例：
```bash
curl -X POST https://merchant.example.com/callback/withdraw \
-H "Content-Type: application/x-www-form-urlencoded" \
-d 'amount=500000&merchant_order_no=WD20260311001&process_time=20260311+120500&status=1&trans_id=987654321&sign=f6e5d4c3b2a1...'
```

**回調響應報文（Response，商戶收到後需回覆的內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| error_msg | String | 錯誤信息 |
| status | String | 回應狀態 |

回調響應範例（JSON 格式）：
```json
{
  "status": "success",
  "error_msg": ""
}
```

---

## 查詢接口

### 5. 查詢訂單接口（Query Order API）

**接口說明**
- 名稱：查詢訂單接口（Query Order API）
- 功能與目的：查詢先前提交的代收或代付訂單狀態
- 接口 URL：`https://api.pgvn.vn-pay.co/sha256/query-order`
- 請求方式：POST
- 請求格式：Form（application/x-www-form-urlencoded）
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：Q:查詢類接口

**接口協議**
與通用規範一致。

**請求 Header**

同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| merchant_order_no | String | Y | 先前提交的商戶獨一生成的訂單交易號碼 |
| merchant_code | String | Y | 商戶代碼 |
| sign | String | Y | 簽名算法。詳見「簽名規則」部分 |

請求範例：
```
merchant_code=llpp8888&merchant_order_no=ORD20260311001&sign=a1b2c3d4e5f6...
```

CURL 範例：
```bash
curl -X POST https://api.pgvn.vn-pay.co/sha256/query-order \
-H "Content-Type: application/x-www-form-urlencoded" \
-d 'merchant_code=llpp8888&merchant_order_no=ORD20260311001&sign=a1b2c3d4e5f6...'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：application/json

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| amount | Number | Y | 收付金額 |
| status | — | Y | **1 = 成功, 0 = 失敗, 3 = 部分出款** |
| trans_id | Number | Y | 交易代碼：由支付系統生成 |
| trans_status | String | Y | **交易狀態**（見下方說明） |
| sign | String | Y | 簽名算法 |
| error_code | String | N | 錯誤代碼 |
| error_msg | String | N | 錯誤信息 |

> **交易狀態碼 `trans_status`（極為重要）**：
>
> **代收（Deposit）交易狀態：**
> | 狀態碼 | 說明 |
> |--------|------|
> | `S` | **已處理（Processed）**— 代收成功 |
> | `F` | 失敗或駁回（Failed or Rejected） |
> | `P` | 待處理（Pending） |
> | `C` | 已退款（Refunded） |
>
> **代付（Withdraw）交易狀態：**
> | 狀態碼 | 說明 |
> |--------|------|
> | `Y` | **已出款（Paid out）**— 代付成功 |
> | `F` | 失敗或駁回（Failed or Rejected） |
> | `P` | 待處理（Pending） |
> | `I` | 處理中（Processing） |
> | `C` | 已退款（Refunded） |
>
> **判定規則：**
> - 代收成功：`trans_status = "S"`。**若誤判此狀態，可能導致系統賠付或虧損。**
> - 代付失敗：`trans_status = "F"`。**若誤判此狀態（將失敗判為成功），可能導致系統賠付或虧損。**
> - 代付成功：`trans_status = "Y"`。
> - 待處理/處理中：`trans_status = "P"` 或 `"I"`，需繼續等待或重新查詢。

成功響應範例：
```json
{
  "status": 1,
  "amount": 100000,
  "trans_id": 123456789,
  "trans_status": "S",
  "sign": "a1b2c3d4e5f6..."
}
```

失敗響應範例：
```json
{
  "status": 0,
  "error_code": "E00015",
  "error_msg": "order number does not exist",
  "sign": null
}
```

---

### 6. 餘額查詢接口（Query Balance API）

**接口說明**
- 名稱：餘額查詢接口（Query Balance API）
- 功能與目的：查詢商戶帳戶餘額
- 接口 URL：`https://api.pgvn.vn-pay.co/sha256/balance`
- 請求方式：POST
- 請求格式：Form（application/x-www-form-urlencoded）
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：Q:查詢類接口

**接口協議**
與通用規範一致。

> **注意**：帳戶餘額請求請勿在 5 秒內重複嘗試。

**請求 Header**

同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| merchant_order_no | String | Y | 先前提交的商戶獨一生成的訂單交易號碼，可帶入 `"-"` |
| merchant_code | String | Y | 商戶代碼 |
| sign | String | Y | 簽名算法。詳見「簽名規則」部分 |

請求範例：
```
merchant_code=llpp8888&merchant_order_no=-&sign=a1b2c3d4e5f6...
```

CURL 範例：
```bash
curl -X POST https://api.pgvn.vn-pay.co/sha256/balance \
-H "Content-Type: application/x-www-form-urlencoded" \
-d 'merchant_code=llpp8888&merchant_order_no=-&sign=a1b2c3d4e5f6...'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：application/json

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|------|------|
| current_balance | Number | Y | 現有餘額 |
| error_code | Number | N | 錯誤代碼 |
| error_msg | String | N | 錯誤信息 |
| holding_balance | Number | Y | 持有餘額（凍結中） |
| outstanding_balance | Number | Y | 未清餘額 |
| status | Number | Y | 1 = 成功, 0 = 失敗 |
| sign | String | Y | 簽名算法 |

成功響應範例：
```json
{
  "status": 1,
  "current_balance": 5000000,
  "holding_balance": 200000,
  "outstanding_balance": 0,
  "sign": "a1b2c3d4e5f6..."
}
```

失敗響應範例：
```json
{
  "status": 0,
  "error_code": "E00017",
  "error_msg": "get balance API to be used every 5 seconds only",
  "sign": null
}
```

---

## 附錄

### 附錄一：越南區域服務類型列表（Service Type）

| 代碼 | 說明 | 類型 |
|------|------|------|
| 704 | VN Deposit ONLINE DIRECT（越南線上直連代收） | 代收 |
| 703 | VN Deposit ONLINE INDIRECT（越南線上間接代收） | 代收 |
| 702 | VN Deposit OFFLINE DIRECT（越南離線直連代收） | 代收 |
| 701 | VN Deposit OFFLINE INDIRECT（越南離線間接代收） | 代收 |
| 440 | ZALO Deposit（ZaloPay 代收） | 代收 |
| 422 | MOBK Deposit（Mobile Banking 代收） | 代收 |
| 421 | VIET Deposit（ViettelMoney 代收） | 代收 |
| 420 | MOMO Deposit（MoMo 代收） | 代收 |
| 700 | VN Withdraw（越南代付） | 代付 |

### 附錄二：越南區域銀行代碼列表（Bank Code）—— 代付銀行

| 代碼 | 銀行名稱 |
|------|----------|
| 9000 | TPBank |
| 9001 | ACBBank |
| 9002 | SHB |
| 9003 | MBBank |
| 9004 | VietinBank |
| 9005 | VPBank |
| 9006 | TechcomBank |
| 9007 | MSBBank |
| 9008 | VietcomBank |
| 9009 | HDBank |
| 9010 | AgriBank |
| 9011 | OCBBank |
| 9012 | EximBank |
| 9013 | SacomBank |
| 9014 | SCBBank |
| 9015 | SaigonBank |
| 9016 | BacABank |
| 9017 | DongA |
| 9018 | BidvBank |
| 9019 | PVComBank |
| 9020 | VibBank |
| 9021 | NCB |
| 9022 | ShinHanBank |
| 9023 | ABBank |
| 9024 | BaovietBank |
| 9025 | SeABank |
| 9026 | LPB |
| 9027 | KienlongBank |
| 9028 | HSBCBank |
| 9029 | BizMBBank |
| 9030 | IBK |
| 9031 | VRB |
| 9032 | NASB |
| 9033 | VIETCAPITAL BANK |
| 9034 | BVB |
| 9035 | OCEANBANK |
| 9036 | GPB |
| 9037 | NAMABANK |
| 9038 | VAB |
| 9039 | VIETBANK |
| 9040 | PGBANK |
| 9041 | CIMB |
| 9042 | PBVN |
| 9043 | UOB |
| 9044 | NGANHANGWOORIBANK |
| 9045 | MBVbank |

### 附錄三：響應錯誤碼列表（Response Error List）

| 錯誤碼 | 中文說明 | 英文說明 |
|--------|----------|----------|
| E00001 | 商戶不存在 | merchant not found |
| E00002 | 缺少參數 | missing required parameter |
| E00003 | 簽名檔錯誤 | sign error |
| E00004 | 請求金額無效 | invalid request amount |
| E00005 | 訂單號已存在 | merchant_order_no already exists |
| E00006 | 商戶餘額不足 | insufficient merchant balance |
| E00007 | 錯誤的銀行代碼 | invalid bank code |
| E00008 | 系統維護中 | maintenance mode |
| E00009 | 商戶不允許使用此服務類型 | service type is not allowed for the merchant |
| E00010 | 未知的伺服器錯誤 | unknown service error |
| E00011 | 系統不支持該銀行代碼 | bank_code is not supported by system |
| E00012 | IP 不允許訪問，需要加白名單 | ip is not allowed |
| E00013 | 無效的參數格式 | invalid parameter format |
| E00014 | 此商戶沒有可用的渠道，商戶帳號設置錯誤 | no channel is available for this merchant |
| E00015 | 訂單號不存在 | order number does not exist |
| E00016 | 商戶充值額度已達上限 | merchant is over the deposit quota limit |
| E00017 | 帳戶餘額請求請勿在 5 秒內重複嘗試 | get balance API to be used every 5 seconds only |
| E00018 | 交易已經存在 | transaction already exist |
| E00019 | 交易不存在 | transaction does not exist |
| E00020 | 交易狀態無效 | invalid transaction status |
| E00021 | 第三方錯誤 | third party error |
| E00022 | 無效的加密公鑰 | invalid encryption key |
| E00023 | 商戶公鑰未提交 | missing encryption public/private key |
| E00026 | 缺少卡號 | missing card number |
| E00027 | 缺少卡片名稱 | missing card name |
| E03001 | 此服務類型必須提供渠道 | Channel must be supplied for this service type |
| E03002 | 未提供手機號碼 | Mobile Number not provided |

### 附錄四：回調錯誤碼列表（Callback Error List）

#### 代收回調錯誤碼

| 錯誤碼 | 中文說明 | 英文說明 |
|--------|----------|----------|
| DP_MIN_BAL | 餘額不足 | Insufficient Balance |
| DP_AMT_TXN | 金額（每筆交易）超限 | Amount (Per Txn) Exceeded |
| DP_AMT_DAY | 金額（每日限額）超限 | Amount (Daily Limit) Exceeded |
| DP_AMT_MTH | 金額（每月限額）超限 | Amount (Monthly Limit) Exceeded |
| DP_TXN_DAY | 次數（每日限額）超限 | Count (Daily Limit) Exceeded |
| DP_TXN_MTH | 次數（每月限額）超限 | Count (Monthly Limit) Exceeded |

#### 代付回調錯誤碼

| 錯誤碼 | 中文說明 | 英文說明 |
|--------|----------|----------|
| WD_MAX_BAL | 超出最大餘額 | Max Balance Exceeded |
| WD_AMT_TXN | 金額（每筆交易）超限 | Amount (Per Txn) Exceeded |
| WD_AMT_DAY | 金額（每日限額）超限 | Amount (Daily Limit) Exceeded |
| WD_AMT_MTH | 金額（每月限額）超限 | Amount (Monthly Limit) Exceeded |
| WD_TXN_DAY | 次數（每日限額）超限 | Count (Daily Limit) Exceeded |
| WD_TXN_MTH | 次數（每月限額）超限 | Count (Monthly Limit) Exceeded |

#### 通用回調錯誤碼

| 錯誤碼 | 中文說明 | 英文說明 |
|--------|----------|----------|
| ACCT_ABN | 賬戶異常狀態 | Abnormal status |
| UNKNOWN_ERR | 未知錯誤 | Unknown Error |

### 附錄五：商戶資料

| 項目 | 值 |
|------|-----|
| 商戶編碼（商戶號） | llpp8888 |
| 密鑰 | *見 email* |
| 商戶後台 | https://bo.merc-mgmt.pgvn.vn-pay.co/#/login |
| 登錄賬號 | llpp8888 |
| 代收提單 URL | https://api.pgvn.vn-pay.co/sha256/deposit |
| 代付提單 URL | https://api.pgvn.vn-pay.co/sha256/withdraw |
| 查詢訂單 URL | https://api.pgvn.vn-pay.co/sha256/query-order |
| 餘額查詢 URL | https://api.pgvn.vn-pay.co/sha256/balance |
| 回調 IP | 52.34.55.206 |
| 是否支持反查 | 不支持 |
| 對接貨幣 | 704-越南盾 |
| 代收是否浮動金額 | 不浮動 |

### 附錄六：對接交易類型（來自需求文件）

#### 代收交易類型

| 交易碼 | service_type | platform | risk_level | 備註 |
|--------|-------------|----------|------------|------|
| 0121 | 702 | PC | 1 | 越南離線直連代收 |
| 014d | 420 | PC | 1 | MoMo 代收（未驗證） |
| 014e | 440 | PC | 1 | ZaloPay 代收（未驗證） |

#### 代付交易類型

| 交易碼 | service_type | platform | risk_level | 額外必填欄位 |
|--------|-------------|----------|------------|-------------|
| 5210 | 700 | PC | 1 | card_name=銀行卡姓名, card_num=銀行卡號, merchant_user=銀行卡姓名, mobile_no=card_num |
