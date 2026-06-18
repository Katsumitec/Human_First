# GB-EzPay API 接口文檔分析

> 文檔來源：
> - 代收接口文檔：`./input/代收_对接文件v2.0.3.pdf`（v2.0.3, 2023/05/19）
> - 代付接口文檔：`./input/代付_对接文件v2.0.5.pdf`（v2.0.5, 2023/06/26）
> - 銀行編碼：`./input/越南銀行編碼-.docx`
>
> 分析日期：2026-03-09

---

## 通用協議規範

### 通信協議
- 協議類型：HTTP / HTTPS
- Base URL：未提供（需由平台分配）
- 請求方式：POST

### 報文格式
- Content-Type：`application/json`（**務必傳送，否則簽名會失敗**）
- 請求格式：JSON
- 響應格式：JSON
- 字符編碼：UTF-8

### 安全協議
- 簽名算法：MD5
- 簽名步驟：
  1. 將須簽名之組數，按照鍵名進行升序排序（ksort）
  2. 將組數**非空值**轉換為字串，並且以 `鍵名=數值&` 方式連接
  3. 最後加上 `key=平台提供的api_key`
  4. 再將此字串進行 MD5 加密
  5. 最後轉換為**大寫字母**
- 簽名位置：Body（`pay_md5_sign` 字段 / `sign` 字段）
- 加密方式：無（僅 MD5 簽名）
- 其他安全機制：無特別說明

#### 代收簽名示例

MD5 加密前字串：
```
pay_amount=500&pay_apply_date=1602659172&pay_channel_id=100&pay_customer_id=50003&pay_notify_url=http://test&pay_order_id=T12345678&key=a4f3d1b62c31e6905059a09b6bb8102047c7a604e6cb1a8a3d8837ed1986854b
```

MD5 加密後字串（大寫）：
```
F8FD4D7D991A05769690C20E16747C47
```

#### 代付簽名示例

MD5 加密前字串：
```
pay_account_name=张阿猫&pay_amount=1000&pay_apply_date=1602659172&pay_bank_name=中国邮政储蓄银行&pay_card_no=00000000000000000&pay_customer_id=50003&pay_notify_url=http://test&pay_order_id=P1113111123&key=a4f3d1b62c31e6905059a09b6bb8102047c7a604e6cb1a8a3d8837ed1986854b
```

MD5 加密後字串（大寫）：
```
6B141F565703C4DA6B0EF7E4722D4FFC
```

#### PHP 簽名示例

```php
public static function sing($arr, $api_key)
{
    ksort($arr);
    $md5str = "";
    foreach ($arr as $key => $val) {
        if ($val != null && $val != "") {
            $md5str = $md5str . $key . "=" . $val . "&";
        }
    }
    return strtoupper(md5($md5str . "key=" . $api_key));
}
```

---

## 接口列表

| 序號 | 接口名稱 | URL | 請求方式 | 分類 |
|------|--------|-----|--------|------|
| 1 | 代收-支付下單 | `/api/pay_order` | POST | C:複合類代收接口 |
| 2 | 代收-異步通知 | 商戶回調地址 | POST | N:異步通知接口 |
| 3 | 代收-查詢訂單 | `/api/query_transaction` | POST | Q:查詢類接口 |
| 4 | 代收-匯率查詢 | `/api/rate` | POST | Q:查詢類接口 |
| 5 | 代收-原路退款銀行資訊 | `/api/pay_refund` | POST | W:代付類接口 |
| 6 | 代付-申請下單 | `/api/payments/pay_order` | POST | W:代付類接口 |
| 7 | 代付-支付結果異步通知 | 商戶回調地址 | POST | N:異步通知接口 |
| 8 | 代付-查詢訂單 | `/api/payments/query_transaction` | POST | Q:查詢類接口 |
| 9 | 代付-餘額查詢 | `/api/payments/balance` | POST | Q:查詢類接口 |

---

## 代收接口

### 1. 代收-支付下單

**接口說明**
- 名稱：支付下單
- 功能與目的：商戶發起代收請求，創建支付訂單。響應中同時包含支付跳轉地址（view_url）與收銀台轉入資訊（bank_no、bank_name 等），為複合類接口。
- 接口 URL：`/api/pay_order`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：C:複合類代收接口

**接口協議**
與通用規範一致。

**請求 Header**

| Header 名稱 | 必填 | 說明 |
|-------------|------|------|
| Content-Type | 是 | `application/json`（務必傳送，否則簽名會失敗） |

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 簽名 | 說明 |
|--------|------|------|------|------|
| pay_customer_id | Integer | 是 | 是 | 平台分配商戶編號 |
| pay_apply_date | Integer | 是 | 是 | 當下時間戳（timestamp），格式 1582539115，單位秒 |
| pay_order_id | String | 是 | 是 | 商戶訂單，字符長度最大 32 |
| pay_notify_url | String | 是 | 是 | 服務端回調地址，字符長度最大 255，**不轉義反斜杠** |
| pay_amount | Float | 是 | 是 | 提單金額（元），支持到兩位小數 |
| pay_channel_id | Integer | 是 | 是 | 通道編號，請向客服索取 |
| pay_md5_sign | String | 是 | 否 | MD5 簽名值（參考簽名算法） |
| pay_product_name | String | 否 | 是 | 商品名稱，字符長度最大 20 |
| user_name | String | 否 | 是 | 玩家姓名，字符長度最大 20。**如通道需實名制，為必填** |
| bank_id | String | 否 | 是 | 收款指定銀行，字符長度最大 5（僅部分通道支持） |
| pay_currency | String | 否 | 是 | 匯率查詢接口的查詢結果，例如選擇人民幣轉換 USDT 時，帶入 `CNYUSDT` 則提單金額自動轉換為 USDT 單位 |

請求範例：
```json
{
    "pay_customer_id": 50003,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order0001",
    "pay_notify_url": "https://api.test/notify",
    "pay_amount": 100,
    "pay_channel_id": 1,
    "pay_md5_sign": "C6F60D10FF5415A573531A576304BBFF",
    "pay_product_name": "商品名称",
    "user_name": "玩家姓名",
    "bank_id": 103
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/pay_order \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 50003,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order0001",
    "pay_notify_url": "https://api.test/notify",
    "pay_amount": 100,
    "pay_channel_id": 1,
    "pay_md5_sign": "C6F60D10FF5415A573531A576304BBFF",
    "pay_product_name": "商品名称",
    "user_name": "玩家姓名",
    "bank_id": 103
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

通用響應結構：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Integer | 返回狀態代碼，0 為成功，其他參考附錄 |
| message | String | 返回信息描述 |
| data | Object | 返回數據對象 |

`data` 對象 — 固定參數：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| order_id | String | 商戶訂單號 |
| transaction_id | String | 平台訂單號 |
| view_url | String | 支付地址（跳轉 URL） |
| qr_url | String | 支付地址二維碼 |
| expired | String | 訂單過期時間 |
| user_name | String | 玩家姓名 |

`data` 對象 — 收銀台參數（僅部分通道支持）：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| bill_price | Float | 提單金額 |
| real_price | Float | 玩家實際支付金額 |
| bank_no | String | 收款卡號 |
| bank_name | String | 收款銀行名稱 |
| bank_from | String | 收款銀行支行 |
| bank_owner | String | 收款人姓名 |
| remark | String | 附言 |

響應範例（類型一：僅支付地址）：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "order_id": "99523425405591",
        "transaction_id": "T202012081925511001637559l",
        "view_url": "http://view",
        "qr_url": "http://qr",
        "expired": "2020-12-08 19:40:52",
        "user_name": "玩家姓名"
    }
}
```

響應範例（類型二：支持收銀台參數）：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "order_id": "11627721",
        "transaction_id": "T03300222211627721",
        "view_url": "https://today/order_T03300222211627721.html",
        "qr_url": "https://api.qrserver.com/v1/create-qr-code/?data=https://today/order_T033",
        "expired": "2021-03-30 02:32:21",
        "user_name": "安安",
        "bill_price": 199,
        "real_price": 199,
        "bank_no": "12345678901234567890",
        "bank_name": "中国工商银行",
        "bank_from": "",
        "bank_owner": "张三三",
        "remark": ""
    }
}
```

---

### 2. 代收-異步通知（Callback）

**接口說明**
- 名稱：代收異步通知
- 功能與目的：支付成功或退款後，平台主動推送交易結果至商戶回調地址
- 通知方式：HTTP POST（渠道主動推送至商戶回調地址）
- 通知的請求格式：JSON
- Content-Type：`application/json`
- **注意事項**：商戶收到平台回調**必須返回 `OK` 字串**（沒有雙引號，且字母均為**大寫**）

**接口分類**：N:異步通知接口

**接口協議**
與通用規範一致。

**回調請求 Header**

| Header 名稱 | 說明 |
|-------------|------|
| Content-Type | `application/json` |

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 簽名 | 說明 |
|--------|------|------|------|
| customer_id | Integer | 是 | 平台分配商戶編號 |
| order_id | String | 是 | 商戶訂單號 |
| transaction_id | String | 是 | 平台訂單號 |
| order_amount | Float | 是 | 提單金額 |
| real_amount | Float | 是 | 玩家實際支付金額 |
| sign | String | 否 | MD5 簽名值（參考簽名算法） |
| status | String | 是 | 訂單支付狀態，**30000 成功**，**50000 原路退款** |
| message | String | 是 | 支付結果描述 |
| extra | Object | 否 | 額外參數 |
| extra.refund | Object | 否 | 原路退款相關資訊（見下方說明） |

`extra.refund` 對象（當 status=50000 時）：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| refund_status | Integer | 退款狀態：1=退款中、2=退款成功、3=退款失敗 |
| bank_account_name | String | 戶名 |
| bank_name | String | 銀行名稱 |
| bank_no | String | 銀行帳號 |
| bank_province | String | 銀行省份 |
| bank_city | String | 銀行城市 |
| bank_sub_branch | String | 銀行支行 |
| phone | String | 手機號 |

回調請求範例：
```json
{
    "customer_id": 50003,
    "order_id": "99523425405591",
    "transaction_id": "T202012081925511001637559l",
    "order_amount": 500,
    "real_amount": 500,
    "sign": "1fc494c688dbe76693e9193d900000fd",
    "status": "30000",
    "message": "支付成功",
    "extra": {
        "user_name": "玩家姓名",
        "pay_product_name": null
    }
}
```

CURL 回調請求範例：
```bash
curl -X POST https://{MERCHANT_CALLBACK_URL} \
-H "Content-Type: application/json" \
-d '{
    "customer_id": 50003,
    "order_id": "99523425405591",
    "transaction_id": "T202012081925511001637559l",
    "order_amount": 500,
    "real_amount": 500,
    "sign": "1fc494c688dbe76693e9193d900000fd",
    "status": "30000",
    "message": "支付成功",
    "extra": {
        "user_name": "玩家姓名",
        "pay_product_name": null
    }
}'
```

**回調響應報文（Response，商戶收到後需回覆的內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| — | String | 純文字字串 `OK`（大寫，無雙引號） |

回調響應範例：
```
OK
```

---

### 3. 代收-查詢訂單

**接口說明**
- 名稱：查詢訂單
- 功能與目的：查詢代收訂單的交易狀態與詳細資訊
- 接口 URL：`/api/query_transaction`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：Q:查詢類接口

**接口協議**
與通用規範一致。

**請求 Header**
同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 簽名 | 說明 |
|--------|------|------|------|------|
| pay_customer_id | Integer | 是 | 是 | 平台分配商戶 ID |
| pay_apply_date | Integer | 是 | 是 | 當下時間戳（timestamp），格式 1582539115，單位秒 |
| pay_order_id | String | 是 | 是 | 商戶訂單號 |
| pay_md5_sign | String | 是 | 否 | MD5 簽名值（參考簽名算法） |

請求範例：
```json
{
    "pay_customer_id": 10000,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order0001",
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/query_transaction \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 10000,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order0001",
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

通用響應結構：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Integer | 返回狀態代碼 |
| message | String | 返回信息描述 |
| data | Object | 返回數據對象 |

`data` 對象：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| customer_id | Integer | 平台分配商戶編號 |
| order_id | String | 商戶訂單號 |
| transaction_id | String | 平台訂單號 |
| status | Integer | 訂單狀態，請參考附錄 |
| order_amount | String | 開單金額 |
| real_amount | String | 實際收到金額 |
| created | String | 訂單創立時間 |
| expired | String | 訂單過期時間 |
| notify_url | String | 商戶回調地址 |
| customer_callback | String | 商戶回調響應數據 |
| extra | Object | 額外參數 |
| rc_feeback | Object | 下單同步返回資訊 |

響應範例：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "customer_id": 50003,
        "order_id": "9952341111",
        "transaction_id": "T033002340805958871111",
        "status": 2,
        "order_amount": "500.00000000",
        "real_amount": "499.90000000",
        "created": "2021-03-30 02:34:08",
        "expired": "2021-03-30 02:44:09",
        "notify_url": "http://test.api.test:8077/api/testCustomerCallback",
        "customer_callback": "OK",
        "extra": {
            "user_name": "",
            "pay_product_name": null
        },
        "rc_feedback": {
            "rate": null,
            "display_price": null
        }
    }
}
```

---

### 4. 代收-匯率查詢（選用）

**接口說明**
- 名稱：匯率查詢
- 功能與目的：查詢平台支持的貨幣匯率，用於代收下單時帶入 `pay_currency` 參數
- 接口 URL：`/api/rate`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：Q:查詢類接口

**接口協議**
與通用規範一致。

**請求 Header**
同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| pay_customer_id | Integer | 平台分配商戶 ID |
| pay_apply_date | Integer | 下單時間戳（timestamp），格式 1582539115 |
| pay_md5_sign | String | MD5 簽名值（參考簽名算法） |

請求範例：
```json
{
    "pay_customer_id": 10000,
    "pay_apply_date": 1582539115,
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/rate \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 10000,
    "pay_apply_date": 1582539115,
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Integer | 返回狀態代碼 |
| message | String | 返回信息描述 |
| data | Array | 匯率列表 |

`data` 數組元素：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| currency | String | 貨幣對（例如 CNYUSDT、PHPUSDT、TWDUSDT） |
| rate | String | 匯率 |

響應範例：
```json
{
    "code": 0,
    "message": "success",
    "data": [
        {
            "currency": "CNYUSDT",
            "rate": "6"
        },
        {
            "currency": "PHPUSDT",
            "rate": "10"
        },
        {
            "currency": "TWDUSDT",
            "rate": "8"
        }
    ]
}
```

---

### 5. 代收-原路退款銀行資訊（選用）

**接口說明**
- 名稱：原路退款銀行資訊
- 功能與目的：提交退款所需的銀行資訊，用於原路退款作業
- 接口 URL：`/api/pay_refund`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：W:代付類接口

**接口協議**
與通用規範一致。

**請求 Header**
同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 簽名 | 說明 |
|--------|------|------|------|------|
| pay_customer_id | Integer | 是 | 是 | 平台分配商戶 ID |
| pay_apply_date | Integer | 是 | 是 | 下單時間戳（timestamp），格式 1582539115 |
| pay_order_id | String | 是 | 是 | 商戶訂單號 |
| pay_md5_sign | String | 是 | 否 | MD5 簽名值（參考簽名算法） |
| bank_account_name | String | 是 | 是 | 戶名 |
| bank_name | String | 否 | 是 | 銀行名稱 |
| bank_no | String | 否 | 是 | 銀行帳號 |
| bank_province | String | 否 | 是 | 銀行省份 |
| bank_city | String | 否 | 是 | 銀行城市 |
| bank_sub_branch | String | 否 | 是 | 銀行支行 |
| phone | String | 否 | 是 | 手機號 |

請求範例：
```json
{
    "pay_customer_id": 50003,
    "pay_apply_date": 1602657089,
    "pay_order_id": "ORDERTEST8",
    "pay_md5_sign": 123,
    "bank_account_name": "户名",
    "bank_name": "银行名称",
    "bank_no": "23432432432423",
    "bank_province": "银行省份",
    "bank_city": "银行城市",
    "bank_sub_branch": "银行支行",
    "phone": "1234567"
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/pay_refund \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 50003,
    "pay_apply_date": 1602657089,
    "pay_order_id": "ORDERTEST8",
    "pay_md5_sign": 123,
    "bank_account_name": "户名",
    "bank_name": "银行名称",
    "bank_no": "23432432432423",
    "bank_province": "银行省份",
    "bank_city": "银行城市",
    "bank_sub_branch": "银行支行",
    "phone": "1234567"
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

`data` 對象（同查詢訂單響應結構，含退款相關資訊）：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| customer_id | Integer | 平台分配商戶編號 |
| order_id | String | 商戶訂單號 |
| transaction_id | String | 平台訂單號 |
| status | Integer | 訂單狀態 |
| order_amount | String | 開單金額 |
| real_amount | String/null | 實際收到金額 |
| created | String | 訂單創立時間 |
| expired | String | 訂單過期時間 |
| notify_url | String | 商戶回調地址 |
| customer_callback | String | 商戶回調響應數據 |
| extra | Object | 額外參數（含 refund 退款資訊） |
| rc_feeback | Object | 下單同步返回資訊 |

響應範例：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "customer_id": 505055,
        "order_id": "ORDERTEST4",
        "transaction_id": "T112220572146729O4ST4",
        "status": 7,
        "order_amount": "3000.00000000",
        "real_amount": null,
        "created": "2021-11-22 20:57:21",
        "expired": "2021-11-22 21:07:21",
        "notify_url": "https:///testCustomerCallback",
        "customer_callback": "OK",
        "extra": {
            "refund": {
                "refund_status": 1,
                "bank_account_name": "户名",
                "bank_name": "银行名称",
                "bank_no": "23432432432423",
                "bank_province": "银行省份",
                "bank_city": "银行城市",
                "bank_sub_branch": "银行支行",
                "phone": "1234567"
            },
            "model_id": 1,
            "client_ip": "127.0.0.1",
            "user_name": "123",
            "pay_product_name": null
        },
        "rc_feedback": {
            "rate": null,
            "display_price": null
        }
    }
}
```

---

## 代付接口

### 6. 代付-申請下單

**接口說明**
- 名稱：代付申請下單
- 功能與目的：商戶發起代付（出金）請求，將款項轉至指定銀行帳號
- 接口 URL：`/api/payments/pay_order`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：W:代付類接口

**接口協議**
與通用規範一致。

**請求 Header**

| Header 名稱 | 必填 | 說明 |
|-------------|------|------|
| Content-Type | 是 | `application/json`（務必傳送，否則簽名會失敗） |

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 簽名 | 說明 |
|--------|------|------|------|------|
| pay_customer_id | Integer | 是 | 是 | 平台分配商戶 ID |
| pay_apply_date | Integer | 是 | 是 | 當下時間戳（timestamp），格式 1582539115，單位秒 |
| pay_order_id | String | 是 | 是 | 商戶訂單號，字符長度最大 32 |
| pay_notify_url | String | 是 | 是 | 服務端回調地址，字符長度最大 255 |
| pay_amount | Float | 是 | 是 | 下單金額，**支持小數至 2 位** |
| pay_md5_sign | String | 是 | 否 | MD5 簽名值（參考簽名算法） |
| pay_account_name | String | 是 | 是 | 銀行卡持有人姓名（USDT 模式：玩家名稱） |
| pay_card_no | String | 是 | 是 | 銀行卡號（USDT 模式：錢包地址） |
| pay_sub_branch | String | 否 | 是 | 銀行卡所屬支行。**幣別為印度時，IFSC Code 必填** |
| pay_city | String | 否 | 是 | 銀行卡所屬城市 |
| pay_bank_name | String | 是 | 是 | 銀行卡所屬銀行名稱（USDT 模式：`USDT`） |
| pay_validate_id | String | 否 | 是 | 查核編碼（**僅部分通道支持**） |
| pay_currency | String | 否 | 是 | 匯率查詢接口的查詢結果，例如選擇人民幣轉換 USDT 時，帶入 `CNYUSDT` 則提單金額自動轉換為 USDT 單位 |

請求範例：
```json
{
    "pay_customer_id": 58787,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order1231221",
    "pay_notify_url": "http://test.api-test.test/api/test",
    "pay_amount": 1000,
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec",
    "pay_account_name": "john",
    "pay_card_no": "43253432342342342",
    "pay_sub_branch": "ZhongShan Subbranch",
    "pay_city": "ZhongShan",
    "pay_bank_name": "邮储银行"
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/payments/pay_order \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 58787,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order1231221",
    "pay_notify_url": "http://test.api-test.test/api/test",
    "pay_amount": 1000,
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec",
    "pay_account_name": "john",
    "pay_card_no": "43253432342342342",
    "pay_sub_branch": "ZhongShan Subbranch",
    "pay_city": "ZhongShan",
    "pay_bank_name": "邮储银行"
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Integer | 返回狀態代碼，0 為成功，其他參考附錄 |
| message | String | 返回信息描述 |
| data | Object | 返回數據對象 |

`data` 對象：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| transaction_id | String | 平台訂單號 |
| amount | String | 金額 |

響應範例：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "transaction_id": "P2020041618492414790",
        "amount": "1000.0000"
    }
}
```

---

### 7. 代付-支付結果異步通知（Callback）

**接口說明**
- 名稱：代付支付結果異步通知
- 功能與目的：代付處理完成後，平台主動推送支付結果至商戶回調地址
- 通知方式：HTTP POST（渠道主動推送至商戶回調地址）
- 通知的請求格式：JSON
- Content-Type：`application/json`
- **注意事項**：成功響應值，必須為字符串 `OK`（無雙引號，且字母均為**大寫**）

**接口分類**：N:異步通知接口

**接口協議**
與通用規範一致。

**回調請求 Header**

| Header 名稱 | 說明 |
|-------------|------|
| Content-Type | `application/json` |

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 簽名 | 說明 |
|--------|------|------|------|
| customer_id | Integer | 是 | 平台分配商戶編號 |
| order_id | String | 是 | 商戶訂單號 |
| amount | String | 是 | 訂單金額 |
| datetime | String | 是 | 日期時間 |
| sign | String | 否 | MD5 簽名值（參考簽名算法） |
| transaction_id | String | 是 | 平台訂單號 |
| transaction_code | String | 是 | 訂單支付狀態，**30000 為成功**，**40000 為駁回** |
| transaction_msg | String | 是 | 結果描述 |

回調請求範例：
```json
{
    "customer_id": 58787,
    "order_id": "order1582539115",
    "amount": "300.0000",
    "datetime": "2020-05-12 21:06:57",
    "sign": "E6144CDA4177A00ED3F6731870DD06DD",
    "transaction_id": "P2020051215480616131",
    "transaction_code": "30000",
    "transaction_msg": "支付成功"
}
```

CURL 回調請求範例：
```bash
curl -X POST https://{MERCHANT_CALLBACK_URL} \
-H "Content-Type: application/json" \
-d '{
    "customer_id": 58787,
    "order_id": "order1582539115",
    "amount": "300.0000",
    "datetime": "2020-05-12 21:06:57",
    "sign": "E6144CDA4177A00ED3F6731870DD06DD",
    "transaction_id": "P2020051215480616131",
    "transaction_code": "30000",
    "transaction_msg": "支付成功"
}'
```

#### 代付異步通知簽名驗證

MD5 加密前字串範例：
```
amount=300.0000&customer_id=58787&datetime=2020-05-12 21:06:57&order_id=order1582539115&transaction_code=30000&transaction_id=P2020051215480616131&transaction_msg=支付成功&key=a4f3d1b62c31e6905059a09b6bb8102047c7a604e6cb1a8a3d8837ed1986854b
```

**回調響應報文（Response，商戶收到後需回覆的內容）**

| 字段名 | 類型 | 說明 |
|--------|------|------|
| — | String | 純文字字串 `OK`（大寫，無雙引號） |

回調響應範例：
```
OK
```

---

## 查詢接口

### 8. 代付-查詢訂單

**接口說明**
- 名稱：代付查詢訂單
- 功能與目的：查詢代付訂單的交易狀態與詳細資訊
- 接口 URL：`/api/payments/query_transaction`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：Q:查詢類接口

**接口協議**
與通用規範一致。

**請求 Header**
同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 簽名 | 說明 |
|--------|------|------|------|------|
| pay_customer_id | Integer | 是 | 是 | 平台分配商戶 ID |
| pay_apply_date | Integer | 是 | 是 | 當下時間戳（timestamp），格式 1582539115，單位秒 |
| pay_order_id | String | 是 | 是 | 商戶訂單號，字符長度最大 32 |
| pay_md5_sign | String | 是 | 否 | MD5 簽名值（參考簽名算法） |

請求範例：
```json
{
    "pay_customer_id": 58787,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order1231221",
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/payments/query_transaction \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 58787,
    "pay_apply_date": 1582539115,
    "pay_order_id": "order1231221",
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Integer | 返回狀態代碼 |
| message | String | 返回信息描述 |
| data | Object | 返回數據對象 |

`data` 對象：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| status | Integer | 訂單狀態代碼 |
| status_name | String | 訂單狀態名稱 |
| msg | String/null | 備注 |
| member_id | Integer | 平台分配商戶 ID |
| out_trade_no | String | 商戶訂單號 |
| amount | String | 訂單金額 |
| payment_id | String | 平台訂單號 |
| payment_success_time | String/null | 訂單完成時間 |

響應範例：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "status": 0,
        "status_name": "未处理",
        "msg": null,
        "member_id": 50003,
        "out_trade_no": "order1582539115",
        "amount": "1000.0000",
        "payment_id": "P2020051215480616131",
        "payment_success_time": null
    }
}
```

---

### 9. 代付-餘額查詢（選用）

**接口說明**
- 名稱：餘額查詢
- 功能與目的：查詢商戶帳戶的代付餘額
- 接口 URL：`/api/payments/balance`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：`application/json`

**接口分類**：Q:查詢類接口

**接口協議**
與通用規範一致。

**請求 Header**
同通用規範。

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 簽名 | 說明 |
|--------|------|------|------|------|
| pay_customer_id | Integer | 是 | 是 | 平台分配商戶 ID |
| pay_apply_date | Integer | 是 | 是 | 當下時間戳（timestamp），格式 1582539115 |
| pay_md5_sign | String | 是 | 否 | MD5 簽名值（參考簽名算法） |

請求範例：
```json
{
    "pay_customer_id": 56789,
    "pay_apply_date": 1582539115,
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}
```

CURL 範例：
```bash
curl -X POST https://{BASE_URL}/api/payments/balance \
-H "Content-Type: application/json" \
-d '{
    "pay_customer_id": 56789,
    "pay_apply_date": 1582539115,
    "pay_md5_sign": "fe49a35bb4eac60563cb4fb848d63aec"
}'
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Integer | 返回狀態代碼 |
| message | String | 返回信息描述 |
| data | Object | 返回數據對象 |

`data` 對象：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| balance | Float | 餘額 |

響應範例：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "balance": 100.1234
    }
}
```

---

## 附錄

### 代收-查詢訂單狀態代碼參考

| 代碼 | 描述 |
|------|------|
| 0 | 未處理（平台收到訂單，玩家尚未支付） |
| 1 | 成功，未返回（訂單成功，尚未成功通知商戶端） |
| 2 | 成功，已返回（訂單成功，成功通知商戶端） |
| 3 | 失敗，逾期失效（訂單過期，未收到款項） |
| 4 | 失敗，訂單金額不相符（提單金額與玩家實際支付金額不符） |
| 5 | 失敗，訂單異常（提單失敗） |

### 代收-返回結果代碼參考

| 代碼 | 描述 |
|------|------|
| 10002 | 驗證錯誤（請參考錯誤訊息） |
| 20000 | 未知錯誤，請聯絡客服（可能通道配置有誤） |
| 20001 | 簽名不正確 |
| 20002 | 商戶不存在 |
| 20003 | 請求時間不在許可範圍 |
| 20004 | 獲取支付通道失敗 |
| 20005 | 查無訂單號 |

### 代付-查詢訂單狀態代碼參考

| 代碼 | 描述 |
|------|------|
| 0 | 未處理 |
| 1 | 處理中 |
| 2 | 已打款 |
| 3 | 已駁回沖正 |
| 4 | 核實不成功 |
| 5 | 餘額不足 |

### 代付-返回結果代碼參考

| 代碼 | 描述 |
|------|------|
| 20001 | 簽名不正確 |
| 20004 | 獲取支付通道失敗 |
| 20005 | 查無訂單號 |
| 20010 | 下單金額大於商戶餘額 |
| 20015 | 商戶未啟用代付 |
| 20017 | 該銀行卡號已達最大提款次數 |
| 20018 | 訂單地址核實不成功，請聯絡客服 |
| 20021 | 未設定代付費率及核實地址 |
| 20022 | 核實地址不正確 |

### 代收異步通知-狀態代碼

| 代碼 | 描述 |
|------|------|
| 30000 | 支付成功 |
| 50000 | 原路退款 |

### 代付異步通知-狀態代碼

| 代碼 | 描述 |
|------|------|
| 30000 | 支付成功 |
| 40000 | 駁回 |

### 越南銀行編碼

| 編號 | 銀行名稱 | 編碼 |
|------|---------|------|
| 1 | Ngân hàng Á Châu | ACB |
| 2 | Ngân hàng Kỹ Thương Việt Nam | TECHCOMBANK |
| 3 | Ngân hàng Sài Gòn Thương Tín | SACOMBANK |
| 4 | Ngân hàng Ngoại thương Việt Nam | VIETCOMBANK |
| 5 | Ngân hàng Công Thương Việt Nam | VIETINBANK |
| 6 | Ngân hàng Đầu tư và Phát triển Việt Nam | BIDV |
| 7 | Ngân hàng Đại Dương | OCEANBANK |
| 8 | Ngân hàng Dầu Khí Toàn Cầu | GPBANK |
| 9 | Ngân hàng Nông nghiệp và Phát triển Nông thôn VN | AGRIBANK |
| 10 | Ngân hàng Tiên Phong | TPBANK |
| 11 | Ngân hàng Đông Á | DONGABANK |
| 12 | Ngân hàng Đông Nam Á | SEABANK |
| 13 | Ngân hàng An Bình | ABBANK |
| 14 | Ngân hàng Bắc Á | BACABANK |
| 15 | Ngân hàng Bản Việt | VIETCAPITALBANK |
| 16 | Ngân hàng Hàng Hải Việt Nam | MSB |
| 17 | Ngân hàng Kiên Long | KIENLONGBANK |
| 18 | Ngân hàng Nam Á | NAMABANK |
| 19 | Ngân hàng Quốc Dân | NCB |
| 20 | Ngân hàng Việt Nam Thịnh Vượng | VPBANK |
| 21 | Ngân hàng Phát triển nhà TP.HCM | HDBANK |
| 22 | Ngân hàng Phương Đông | OCB |
| 23 | Ngân hàng Quân đội | MB |
| 24 | Ngân hàng Đại chúng Việt Nam | PVCOMBANK |
| 25 | Ngân hàng Quốc tế | VIB |
| 26 | Ngân hàng Sài Gòn | SCB |
| 27 | Ngân hàng Sài Gòn Công Thương | SAIGONBANK |
| 28 | Ngân hàng Sài Gòn-Hà Nội | SHB |
| 29 | Ngân hàng Việt Á | VIETABANK |
| 30 | Ngân hàng Bảo Việt | BAOVIETBANK |
| 31 | Ngân hàng Xăng dầu Petrolimex | PGBANK |
| 32 | Ngân hàng Xuất Nhập khẩu Việt Nam | EXIMBANK |
| 33 | Ngân hàng Bưu điện Liên Việt | LVPB |
| 34 | Ngân hàng Công nghiệp Hàn Quốc - Chi nhánh Hà Nội | IBK |
| 35 | Ngân hàng TNHH MTV Shinhan Việt Nam | SHBVN |
| 36 | Ngân hàng UOB Việt Nam | UOB |
| 37 | Ngân hàng TNHH Indovina | IVB |
| 38 | Ngân hàng TNHH MTV CIMB Việt Nam | CIMB |
| 39 | Ngân hàng TNHH MTV Public Việt Nam | PBVN |
| 40 | Ngân hàng liên doanh Việt Nga | VRB |
| 41 | Ngân hàng Phát triển Nhà Đồng bằng Sông Cửu Long | MHB |
| 42 | Ngân hàng TNHH MTV Hong Leong Việt Nam | HLB |
| 43 | Ngân hàng Woori Bank Việt Nam | WOO |
| 44 | MB Ngân hàng Quân đội / MBBANK | MBBANK |
| 45 | EXIMBANK | EIB |
| 46 | Sacombank | STB |
| 47 | VietABank | VAB |
| 48 | Ngân hàng TMCP Việt Nam Thương Tín | VIETBANK |
| 49 | ViettelMoney | VTLMONEY |
| 50 | Bank Of Communications, HCM Branch | COMMB |
| 51 | Ngân hàng TM TNHH MTV Xây dựng Việt Nam (CB) | CBB |
| 52 | MOMOPAY | MOMO |
| 53 | Ngân hàng TNHH MTV HSBC (Việt Nam) | HSBC |
| 54 | ZALOPAY | ZALO |
| 55 | Ngân hàng Citibank, N.A. - Chi nhánh Hà Nội | CITIBANK |
| 56 | TMCP Việt Nam Thịnh Vượng - Ubank by VPBank | UBANK |
| 57 | Ngân hàng Đại chúng TNHH Kasikornbank | KBANK |
| 58 | DBS Bank Ltd - Chi nhánh TP.HCM | DBS |
| 59 | Ngân hàng Nonghyup - Chi nhánh Hà Nội | NHB |
| 60 | Ngân hàng số Timo by Ban Viet Bank | TIMO |
| 61 | Ngân hàng TNHH MTV Standard Chartered Bank Việt Nam | SCVN |
| 62 | Ngân hàng TNHH MTV Hong Leong Việt Nam | HLBVN |
| 63 | Ngân hàng Hợp tác xã Việt Nam | COOPBANK |
| 64 | Ngân hàng Kookmin - Chi nhánh Hà Nội | KBHN |
| 65 | Ngân hàng Kookmin - Chi nhánh TP.HCM | KBHCM |
| 66 | Ngân hàng KEB Hana – Chi nhánh TP.HCM | KEBHANAHCM |
| 67 | Ngân hàng KEB Hana – Chi nhánh Hà Nội | KEBHANAHN |
| 68 | Công ty Tài chính TNHH MTV Mirae Asset (Việt Nam) | MAFC |
| 69 | VNPT Money | VNPTMONEY |
| 70 | Ngân hàng Chính sách Xã hội | VBSP |
| 71 | TMCP Việt Nam Thịnh Vượng - CAKE by VPBank | CAKE |
