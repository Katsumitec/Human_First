# FY-BlizzardPay API 接口文檔分析

> 文檔來源：FY-BlizzardPay/blizzardpay-api.docx
> 分析日期：2026-02-26
> 渠道編號：FY
> 渠道名稱：BlizzardPay（暴雪支付）

---

## 通用協議規範

### 通信協議

- 協議類型：HTTP
- Base URL：`http://api.blizzardpay.pw`
- 請求方式：POST / GET（依接口而定）

### 報文格式

- Content-Type：`application/x-www-form-urlencoded`
- 請求格式：Form（表單鍵值對）
- 響應格式：JSON
- 字符編碼：UTF-8

### 安全協議

- **簽名算法**：MD5
- **簽名字段**：所有**非空**參數值（排除 `sign` 本身），參與簽名的字段在各接口表中以「參與簽名」欄標示
- **簽名位置**：Body（表單參數 `sign`）
- **加密方式**：無（僅簽名驗證）
- **其他安全機制**：商戶號（appId）+ 密鑰（key）身份識別
- **簽名規則**：
  1. 取所有**非空**參數值（排除 `sign` 本身），按參數名 ASCII 碼由小到大排序（字典序）
  2. 以 URL 鍵值對格式拼接為 `key1=value1&key2=value2&...` 得到 `stringA`
  3. 在 `stringA` 末尾拼接 `&key={你的密鑰}` 得到 `stringSignTemp`
  4. 對 `stringSignTemp` 進行 MD5 運算，得到 `sign` 值
- **簽名示例**：
  ```
  stringA = "amount=10000.00&appId=10977&callbackUrl=https://example.com/callback&channelId=110&clientUserIp=1.2.3.4&clientUserId=abc123&outTradeNo=ORDER001&successUrl=https://example.com/success"
  stringSignTemp = stringA + "&key=YOUR_SECRET_KEY"
  sign = MD5(stringSignTemp)
  ```
- **簽名注意事項**：
  - sign 值忽略大小寫（回調驗簽中 sign 為小寫字符串）
  - 參數值為空時不參與簽名

---

## 接口列表

| 序號 | 接口名稱 | URL | 請求方式 | 接口分類 |
|------|----------|-----|----------|----------|
| 1 | 代收下單 | `/order/v2/create` | POST | R:跳轉類代收接口 |
| 2 | 代收異步回調通知 | 商戶回調地址 | POST（渠道推送） | N:異步通知接口 |
| 3 | 代收訂單查詢 | `/order/query` | GET | Q:查詢類接口 |
| 4 | 代收 UTR 補單 | `/order/inr/submitUtr` | POST | Q:查詢類接口（僅印度） |
| 5 | 代付發起 | `/withdraw/apply` | POST | W:代付類接口 |
| 6 | 代付異步回調通知 | 商戶回調地址 | POST（渠道推送） | N:異步通知接口 |
| 7 | 代付訂單查詢 | `/withdraw/query` | GET | Q:查詢類接口 |
| 8 | 代付憑證查詢 | `/withdraw/proof` | GET | Q:查詢類接口（僅泰國） |
| 9 | 餘額查詢 | `/withdraw/balance` | GET | Q:查詢類接口 |

---

## 一、代收接口

### 1. 代收下單接口

**接口說明**
- 名稱：代收下單
- 功能與目的：發起代收（入金）訂單，響應收銀台跳轉地址（payUrl），商戶引導客戶跳轉至該地址完成付款
- 接口 URL：`POST http://api.blizzardpay.pw/order/v2/create`
- 請求方式：POST
- 請求格式：Form
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：R:跳轉類代收接口（響應含 `payUrl` 跳轉地址）

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| outTradeNo | String | 是 | 是 | 商戶訂單號 |
| channelId | String | 是 | 是 | 通道編號（見附錄 8.1 支付通道編號） |
| bankCode | String | 否 | 是 | 銀行編碼（113 通道生效，其他通道忽略；泰國實名通道必填見 9.1） |
| amount | String | 是 | 是 | 金額，單位元，保留 2 位小數 |
| callbackUrl | String | 是 | 是 | 服務端異步通知回調 URL |
| successUrl | String | 是 | 是 | 支付成功跳轉的 URL |
| clientUserIp | String | 是 | 是 | 下單用戶的 IP 地址 |
| clientUserId | String | 是 | 是 | 下單用戶唯一標識，最大 32 位字符串（可使用用戶 ID 的 MD5 值） |
| cnic | String | 否 | 是 | 巴基斯坦證件號，長度 13 位（巴基斯坦必填，其他通道忽略） |
| cpf | String | 否 | 是 | 有效的 CPF（巴西通道） |
| userName | String | 否 | 是 | 姓名（泰國實名通道必填、土耳其通道必填） |
| userPhone | String | 否 | 是 | 付款人手機（印尼/巴西/埃及/巴基斯坦通道字段必填） |
| userEmail | String | 否 | 是 | 用戶郵箱（俄羅斯 SBP/SberPay 必填） |
| bankCardNo | String | 否 | 是 | 付款人卡號（泰國實名通道必填、俄羅斯 MirCard 必填） |
| cvc | String | 否 | 是 | 信用卡 CVC（俄羅斯 MirCard 通道必填） |
| expDate | String | 否 | 是 | 信用卡有效日期，格式 yyyyMM（俄羅斯 MirCard 通道必填） |
| sign | String | 是 | 否 | 簽名（忽略大小寫） |

請求範例：
```
appId=10977&outTradeNo=ORDER20260226001&channelId=110&amount=500000.00&callbackUrl=https%3A%2F%2Fexample.com%2Fcallback&successUrl=https%3A%2F%2Fexample.com%2Fsuccess&clientUserIp=1.2.3.4&clientUserId=user123md5hash&sign=a1b2c3d4e5f6...
```

CURL 範例：
```bash
curl -X POST http://api.blizzardpay.pw/order/v2/create \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "appId=10977&outTradeNo=ORDER20260226001&channelId=110&amount=500000.00&callbackUrl=https%3A%2F%2Fexample.com%2Fcallback&successUrl=https%3A%2F%2Fexample.com%2Fsuccess&clientUserIp=1.2.3.4&clientUserId=user123md5hash&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Int | 狀態碼，200 代表成功，其他為失敗 |
| msg | String | 詳細說明 |
| data | Object | code=200 時返回數據對象 |
| data.appId | String | 商戶號 |
| data.channelId | String | 通道編號 |
| data.orderNo | String | 系統訂單號（平台訂單號） |
| data.amount | String | 金額 |
| data.outTradeNo | String | 商戶訂單號 |
| data.payUrl | String | 付款的收銀台跳轉鏈接地址 |
| data.payData | Object/String | 付款數據對象（巴西通道返回字符串；印度返回對象含 qrCode、upi） |

響應範例：
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "appId": "10977",
    "channelId": "110",
    "orderNo": "BP20260226000001",
    "amount": "500000.00",
    "outTradeNo": "ORDER20260226001",
    "payUrl": "http://api.blizzardpay.pw/cashier/pay/BP20260226000001"
  }
}
```

---

### 2. 代收訂單查詢

**接口說明**
- 名稱：代收訂單查詢
- 功能與目的：以商戶訂單號查詢代收訂單的當前狀態與金額資訊
- 接口 URL：`GET http://api.blizzardpay.pw/order/query`
- 請求方式：GET
- 請求格式：Form（Query Parameters）
- Content-Type：`x-www-form-urlencoded`

**接口分類**：Q:查詢類接口

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| outTradeNo | String | 是 | 是 | 商戶訂單號 |
| sign | String | 是 | 否 | 簽名（忽略大小寫） |

CURL 範例：
```bash
curl -X GET "http://api.blizzardpay.pw/order/query?appId=10977&outTradeNo=ORDER20260226001&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Int | 狀態碼，code=200 請求成功，其他為失敗 |
| msg | String | 狀態消息 |
| data | Object | code=200 時返回 |
| data.appId | String | 商戶號 |
| data.channelId | String | 通道編號 |
| data.orderNo | String | 系統訂單號 |
| data.outTradeNo | String | 商戶訂單號 |
| data.amount | String | 訂單金額 |
| data.amountTrue | String | 真實付款金額 |
| data.paySuccess | Boolean | 是否支付成功（true/false） |
| data.utr | String | UTR（印度通道返回） |
| data.payAccountNo | String | 用戶支付賬號（貨幣 PKR 才會返回） |

響應範例：
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "appId": "10977",
    "channelId": "110",
    "orderNo": "BP20260226000001",
    "outTradeNo": "ORDER20260226001",
    "amount": "500000.00",
    "amountTrue": "500000.00",
    "paySuccess": true
  }
}
```

---

### 3. 代收 UTR 補單（僅印度通道）

**接口說明**
- 名稱：代收 UTR 補單
- 功能與目的：針對印度通道的代收訂單，提交 UTR 進行補單操作
- 接口 URL：`POST http://api.blizzardpay.pw/order/inr/submitUtr`
- 請求方式：POST
- 請求格式：Form
- Content-Type：`x-www-form-urlencoded`

**接口分類**：Q:查詢類接口（僅適用於印度通道）

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| orderNo | String | 是 | 是 | 平台訂單號（注意：此處為平台訂單號，非商戶訂單號） |
| utr | String | 是 | 是 | UTR 號碼 |
| sign | String | 是 | 否 | 簽名（忽略大小寫） |

CURL 範例：
```bash
curl -X POST http://api.blizzardpay.pw/order/inr/submitUtr \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "appId=10977&orderNo=BP20260226000001&utr=123456789012&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Int | 200/400/500，等於 200 代表補單成功 |
| msg | String | 消息 |

響應範例：
```json
{
  "code": 200,
  "msg": "success"
}
```

---

## 二、代付接口

### 4. 代付發起接口

**接口說明**
- 名稱：代付（出金）接口
- 功能與目的：向指定銀行帳戶發起代付（提現）請求，包含目的地帳號、收款人姓名及銀行資訊
- 接口 URL：`POST http://api.blizzardpay.pw/withdraw/apply`
- 請求方式：POST
- 請求格式：Form
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：W:代付類接口

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| outOrderNo | String | 是 | 是 | 商戶訂單號 |
| amount | String | 是 | 是 | 提現金額，保留 2 位小數 |
| bankName | String | 是 | 是 | 銀行代碼簡稱（印度使用 IFSC code，其他見附錄 9.x 銀行編碼） |
| bankBranch | String | 否 | 是 | 開戶行（沒有時傳空字符串） |
| bankUserName | String | 是 | 是 | 收款人姓名 |
| bankCard | String | 是 | 是 | 銀行卡號 / 錢包賬號 |
| currency | String | 是 | 是 | 貨幣編碼（如 VND、THB、INR 等） |
| callbackUrl | String | 否 | 是 | 代付回調地址 |
| phone | String | 否 | 是 | 手機號碼（印尼/巴西通道字段必填） |
| email | String | 否 | 是 | 郵箱（印尼通道字段必填） |
| address | String | 否 | 是 | 客戶地址（印尼通道字段必填） |
| taxNumber | String | 否 | 是 | 稅號，個人 CPF / 公司 CNPJ（巴西必填，其他忽略） |
| cnic | String | 否 | 是 | 巴基斯坦證件號，長度 13 位（巴基斯坦必填，其他忽略） |
| citizenshipId | String | 否 | 是 | 哥倫比亞身份證號 8-11 位（哥倫比亞代付必填，其他忽略） |
| sign | String | 是 | 否 | 簽名（忽略大小寫） |

請求範例：
```
appId=10977&outOrderNo=PAY20260226001&amount=1000000.00&bankName=VCB&bankBranch=&bankUserName=NGUYEN+VAN+A&bankCard=1234567890&currency=VND&callbackUrl=https%3A%2F%2Fexample.com%2Fcallback&sign=a1b2c3d4e5f6
```

CURL 範例：
```bash
curl -X POST http://api.blizzardpay.pw/withdraw/apply \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "appId=10977&outOrderNo=PAY20260226001&amount=1000000.00&bankName=VCB&bankBranch=&bankUserName=NGUYEN+VAN+A&bankCard=1234567890&currency=VND&callbackUrl=https%3A%2F%2Fexample.com%2Fcallback&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

> **注意**：原始文檔中代付發起接口的響應報文未詳細列出字段，需聯調時確認。預期結構如下：

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Int | 狀態碼，200 代表成功 |
| msg | String | 消息 |
| data | Object | code=200 時返回 |

---

### 5. 代付訂單查詢

**接口說明**
- 名稱：代付訂單查詢
- 功能與目的：以商戶訂單號查詢代付訂單的狀態與詳細資訊
- 接口 URL：`GET http://api.blizzardpay.pw/withdraw/query`
- 請求方式：GET
- 請求格式：Form（Query Parameters）
- Content-Type：`x-www-form-urlencoded`

**接口分類**：Q:查詢類接口

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

> 原始文檔中未列出請求參數，預期與代收查詢類似：

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| outOrderNo | String | 是 | 是 | 商戶訂單號 |
| sign | String | 是 | 否 | 簽名（忽略大小寫） |

CURL 範例：
```bash
curl -X GET "http://api.blizzardpay.pw/withdraw/query?appId=10977&outOrderNo=PAY20260226001&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Int | 狀態碼，code=200 成功，其他為失敗 |
| msg | String | 狀態消息 |
| data | Object | code=200 時返回 |
| data.appId | String | 商戶號 |
| data.orderNo | String | 系統訂單號 |
| data.outOrderNo | String | 商戶訂單號 |
| data.apply | String | 訂單金額 |
| data.fee | String | 手續費 |
| data.orderStatus | String | 訂單狀態：0=未處理，1=成功，2=失敗，3=處理中 |
| data.utr | String | UTR（印度通道才會返回） |

響應範例：
```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "appId": "10977",
    "orderNo": "BP20260226000001",
    "outOrderNo": "PAY20260226001",
    "apply": "1000000.00",
    "fee": "10000.00",
    "orderStatus": "1"
  }
}
```

---

### 6. 代付憑證查詢（僅泰國通道）

**接口說明**
- 名稱：代付憑證查詢
- 功能與目的：查詢泰國通道代付訂單的打款憑證
- 接口 URL：`GET http://api.blizzardpay.pw/withdraw/proof`
- 請求方式：GET
- 請求格式：Form（Query Parameters）
- Content-Type：`x-www-form-urlencoded`

**接口分類**：Q:查詢類接口（僅適用於泰國通道）

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| orderNo | String | 是 | 是 | 平台訂單號 |
| sign | String | 是 | 否 | 簽名 |

CURL 範例：
```bash
curl -X GET "http://api.blizzardpay.pw/withdraw/proof?appId=10977&orderNo=BP20260226000001&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

> 原始文檔中未列出響應字段，需聯調時確認。

---

## 三、異步通知接口

### 7. 代收異步回調通知（Webhook）

**接口說明**
- 名稱：代收異步回調通知
- 功能與目的：訂單支付成功後，平台以 HTTP POST 主動推送結果至商戶在代收下單時提供的 `callbackUrl`。商戶需驗簽後更新訂單狀態。
- 通知方式：HTTP POST（渠道主動推送至商戶回調地址）
- 通知的請求格式：Form
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：N:異步通知接口

**接口協議**：與通用規範一致

**回調請求 Header**

同通用規範

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| outTradeNo | String | 是 | 是 | 商戶訂單號 |
| orderNo | String | 是 | 是 | 平台訂單號 |
| channelId | String | 是 | 是 | 通道編號 |
| amount | String | 是 | 是 | 訂單創建金額，單位元，保留 2 位小數 |
| amountTrue | String | 是 | 是 | 用戶真實付款金額，單位元，保留 2 位小數 |
| payStatus | String | 是 | 是 | 狀態，`SUCCESS` 代表成功 |
| utr | String | 否 | 是 | UTR（印度通道才會返回） |
| payAccountNo | String | 否 | 是 | 用戶支付賬號（貨幣 PKR 才會返回） |
| sign | String | 是 | 否 | 簽名（小寫字符串） |

回調請求範例：
```
appId=10977&outTradeNo=ORDER20260226001&orderNo=BP20260226000001&channelId=110&amount=500000.00&amountTrue=500000.00&payStatus=SUCCESS&sign=a1b2c3d4e5f6
```

CURL 回調請求範例：
```bash
curl -X POST https://example.com/callback \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "appId=10977&outTradeNo=ORDER20260226001&orderNo=BP20260226000001&channelId=110&amount=500000.00&amountTrue=500000.00&payStatus=SUCCESS&sign=a1b2c3d4e5f6"
```

**驗簽規則**：與通用簽名規則一致，取所有非空參數值（排除 sign），按 ASCII 排序拼接後加 `&key={密鑰}`，MD5 驗簽。

**重要提醒**：如果訂單拉起金額（amount）和用戶真實付款金額（amountTrue）不一致，請根據業務需求自行處理。

**回調響應報文（Response，商戶收到後需回覆的內容）**

> 商戶必須回覆純文字字串 `SUCCESS`，否則平台將重複推送。

回調響應範例：
```
SUCCESS
```

---

### 8. 代付異步回調通知（Webhook）

**接口說明**
- 名稱：代付異步回調通知
- 功能與目的：代付訂單處理完成後，平台以 HTTP POST 主動推送結果至商戶提供的 `callbackUrl`。
- 通知方式：HTTP POST（渠道主動推送至商戶回調地址）
- 通知的請求格式：Form
- Content-Type：`application/x-www-form-urlencoded`

**接口分類**：N:異步通知接口

**接口協議**：與通用規範一致

**回調請求 Header**

同通用規範

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| orderNo | String | 是 | 是 | 平台訂單號 |
| outOrderNo | String | 是 | 是 | 商戶訂單號 |
| currency | String | 是 | 是 | 貨幣 |
| amount | String | 是 | 是 | 金額 |
| orderStatus | String | 是 | 是 | 訂單狀態：0=未處理，1=已打款，2=駁回，3=處理中 |
| utr | String | 否 | 是 | UTR（印度通道才會返回） |
| message | String | 否 | 是 | 失敗原因 |
| sign | String | 是 | 否 | 簽名（小寫） |

回調請求範例：
```
appId=10977&orderNo=BP20260226000001&outOrderNo=PAY20260226001&currency=VND&amount=1000000.00&orderStatus=1&sign=a1b2c3d4e5f6
```

CURL 回調請求範例：
```bash
curl -X POST https://example.com/callback \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "appId=10977&orderNo=BP20260226000001&outOrderNo=PAY20260226001&currency=VND&amount=1000000.00&orderStatus=1&sign=a1b2c3d4e5f6"
```

**驗簽規則**：與通用簽名規則一致。

**回調響應報文（Response，商戶收到後需回覆的內容）**

> 商戶必須回覆純文字字串 `SUCCESS`，否則平台將重複推送。

回調響應範例：
```
SUCCESS
```

---

## 四、其他接口

### 9. 餘額查詢

**接口說明**
- 名稱：帳戶餘額查詢
- 功能與目的：查詢商戶帳戶當前餘額
- 接口 URL：`GET http://api.blizzardpay.pw/withdraw/balance`
- 請求方式：GET
- 請求格式：Form（Query Parameters）
- Content-Type：`x-www-form-urlencoded`

**接口分類**：Q:查詢類接口

**接口協議**：與通用規範一致

**請求 Header**

同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|------|----------|------|
| appId | String | 是 | 是 | 平台分配的商戶號 |
| currency | String | 是 | 是 | 貨幣（如 VND、THB、INR、USD 等） |
| sign | String | 是 | 否 | 簽名（忽略大小寫） |

CURL 範例：
```bash
curl -X GET "http://api.blizzardpay.pw/withdraw/balance?appId=10977&currency=VND&sign=a1b2c3d4e5f6"
```

**響應報文（Response）**

- 響應格式：JSON
- Content-Type：`application/json`

| 字段名 | 類型 | 說明 |
|--------|------|------|
| code | Int | 狀態碼，200 為成功 |
| data | Float | 餘額 |

響應範例：
```json
{
  "code": 200,
  "data": 100.00
}
```

---

## 附錄

### 附錄 A：支付通道編號（8.1）

| 編號 | 名稱 | 貨幣 |
|------|------|------|
| 104 | 泰國-卡卡 | THB |
| 105 | 泰國-Promptpay | THB |
| 108 | 印度 | INR |
| 109 | 越南-銀行掃碼 | VND |
| **110** | **越南-銀行轉賬** | **VND** |
| 112 | 越南-Momo | VND |
| 113 | 印尼-銀行卡VA | IDR |
| 114 | 印尼-QRIS | IDR |
| 115 | 印尼-電子錢包 | IDR |
| 117 | USDT-TRC20 | USDT |
| 118 | 巴西-PIX | BRL |
| 119 | 埃及-電子錢包 | EGP |
| 120 | 菲律賓-Gcash | PHP |
| 201 | 菲律賓-Maya | PHP |
| 209 | 菲律賓-Gcash掃碼 | PHP |
| 210 | 墨西哥-SPEI | MXN |
| 214 | 尼日利亞網銀 | NGN |
| 215 | 尼日利亞卡卡 | NGN |
| 216 | 越南-ZALO | VND |
| 219 | 巴基斯坦-JAZZ CASH | PKR |
| 220 | 巴基斯坦-EASYPAISA | PKR |
| 221 | 馬來西亞-RMQR | MYR |
| 222 | 馬來西亞-RMQuickPay | MYR |
| 223 | 孟加拉-BKASH | BDT |
| 224 | 孟加拉-Nagad | BDT |
| 225 | 孟加拉-UPAY | BDT |
| 226 | 孟加拉-Rocket | BDT |
| 227 | 哥倫比亞-錢包 | COP |
| 228 | 俄羅斯-MIR Card | RUB |
| 229 | 俄羅斯-T-pay | RUB |
| 230 | 俄羅斯-SberPay | RUB |
| 231 | 俄羅斯-SBP | RUB |
| 232 | 俄羅斯-銀行卡 | RUB |
| 233 | 土耳其-papara | TRY |
| 234 | 土耳其-bankpay | TRY |
| 235 | 土耳其-mefete | TRY |
| 236 | 土耳其-pep | TRY |
| 237 | 土耳其-parolapara | TRY |
| 238 | 土耳其-popypara | TRY |
| 239 | 土耳其-bankin | TRY |
| 240 | 土耳其-payco | TRY |
| 241 | 土耳其-papel | TRY |
| 243 | 墨西哥-OXXO | MXN |
| 244 | 墨西哥-CODI | MXN |

---

### 附錄 B：代收銀行編碼

#### B.1 印尼 VA 代收銀行編碼（8.2）

| 銀行編碼 | 銀行名稱 |
|----------|----------|
| PERMATA | Permata Bank Virtual Account |
| BNI | BNI Virtual Account |
| CIMB | CIMB Niaga Virtual Account |
| BCA | BCA Virtual Account |
| BRI | BRI Virtual Account |
| MANDIRI | Bank Mandiri Virtual Account |
| DANAMON | Bank DANAMON Virtual Account |

#### B.2 印尼電子錢包代收編碼（8.2）

| 編碼 |
|------|
| DANA |
| OVO |
| SHOPEEPAY |
| LINKAJA |

---

### 附錄 C：代付銀行編碼

#### C.1 泰國銀行代碼（9.1）

| 銀行簡稱 | 銀行名稱 |
|----------|----------|
| KBANK | Kasikorn Bank Plc. |
| BBL | Bangkok Bank Plc. |
| KTB | Krung Thai Bank |
| ABN | ABN Amro Bank N.V. |
| TTB | TMBThanachart |
| SCB | Siam Commercial Bank |
| UOB | UOB Bank Plc. |
| BAY | Bank of Ayudhya / Krungsri |
| CIMB | CIMB Thai Bank Public Company Limited |
| LHBANK | Land and Houses Bank Public Company Limited |
| GSB | Government Savings Bank |
| KKP | Kiatnakin Phatra Bank Public Company Limited |
| CITI | Citibank N.A. |
| GHB | Government Housing Bank |
| BAAC | Bank for Agriculture and Agricultural Cooperatives |
| MHCB | Mizuho Corporate Bank Limited |
| IBANK | Islamic Bank of Thailand |
| TISCO | TISCO Bank Plc. |

#### C.2 越南銀行代碼（9.2）

> ⚠️ 原始文檔 9.2 節標題存在但**未列出具體銀行代碼**，需向渠道方確認。

#### C.3 印尼銀行代碼（9.3.1）

> 原始文檔 9.3.1 節標題存在但未列出具體編碼，需向渠道方確認。

#### C.4 印尼錢包代付編碼（9.3.2）

| 編碼 | 名稱 |
|------|------|
| DANA | DANA |
| OVO | OVO |
| SHOPEEPAY | SHOPEEPAY |
| LINKAJA | LINKAJA |
| GOPAY | GOPAY |

#### C.5 菲律賓銀行編碼（9.4）

| 編碼 | 名稱 |
|------|------|
| GCASH | gcash |
| PMP | paymaya |

#### C.6 巴西代付編碼（9.5）

| 簡稱 | 名稱 |
|------|------|
| PIX_CPF | PIX CPF 11 位數字 |
| PIX_CNPJ | PIX CNPJ 14 位數字 |
| PIX_EMAIL | 郵箱格式 |
| PIX_PHONE | +55{10-11 位數字} |
| PIX_EVP | UUID 格式（8-4-4-4-12） |

#### C.7 孟加拉錢包代付編碼（9.7）

| 編碼 |
|------|
| UPAY |
| NAGAD |
| BKASH |
| ROCKET |

#### C.8 馬來西亞代付編碼（9.11）

| 編碼 | 名稱 |
|------|------|
| ABB | Affin Bank Berhad |
| ABMB | Alliance Bank Malaysia Berhad |
| AGRO | Agrobank |
| AMBG | Ambank Berhad |
| ARB | Al Rajhi Corporation (Malaysia) Berhad |
| BIMB | BANK ISLAM MALAYSIA BERHAD |
| BKRM | Bank Kerjasama Rakyat Malaysia Berhad |
| BMMB | Bank Muamalat Malaysia Berhad |
| BSN | Bank Simpanan Nasional Berhad |
| CIMB | CIMB Bank Berhad |
| CITI | Citibank Berhad |
| HLB | Hong Leong Bank Berhad |
| HSBC | HSBC Bank Malaysia Berhad |
| MBB | Maybank Berhad |
| MBSB | MBSB Bank Berhad |
| OCBC | OCBC Bank (Malaysia) Berhad |
| PBB | Public Bank Berhad |
| RHB | RHB Bank Berhad (RHB) |
| SCB | Standard Chartered Bank Malaysia |
| TNGD | Touch n Go eWallet |
| UOB | United Overseas Bank Berhad |

> 其餘銀行編碼（BBB、BIGPAY、BNPP、BOCM、BOFA、DBB、FCSD、ICBC、JPMC、KFH、MCBM、MUFG、PCBC、SMBC）見原始文檔。

#### C.9 USDT 代付編碼（9.12）

| 編碼 | 名稱 |
|------|------|
| USDT-TRC20 | USDT-TRC20 |

#### C.10 土耳其代付編碼（9.15）

| 編碼 | 格式 | 代付範圍 |
|------|------|----------|
| papara | 10 位數字 | 1,000 - 250,000 |
| bankpay | 26 位，前綴 TR | 10,000 - 250,000 |
| mefete | 10 位數字 | 50 - 250,000 |
| pep | 9 位數字 | 50 - 250,000 |
| papel | 10 位數字 | 1,000 - 250,000 |
| parolapara | 10 位數字 | 250 - 250,000 |
| popypara | 10 位數字 | 150 - 100,000 |
| bankin | 26 位，前綴 TR | 10,000 - 100,000 |
| payco | 10 位數字 | 100 - 100,000 |

> 其餘國家（哥倫比亞 9.13、俄羅斯 9.14、墨西哥 9.6、尼日利亞 9.9、巴基斯坦 9.10）的代付銀行編碼見原始文檔。

---

### 附錄 D：狀態碼對照

#### D.1 代收回調狀態

| payStatus 值 | 說明 |
|--------------|------|
| SUCCESS | 支付成功 |

#### D.2 代付回調狀態（orderStatus）

| 狀態值 | 說明 |
|--------|------|
| 0 | 未處理 |
| 1 | 已打款 |
| 2 | 駁回 |
| 3 | 處理中 |

#### D.3 代付查詢狀態（orderStatus）

| 狀態值 | 說明 |
|--------|------|
| 0 | 未處理 |
| 1 | 成功 |
| 2 | 失敗 |
| 3 | 處理中 |

#### D.4 代收查詢狀態

| 字段 | 值 | 說明 |
|------|----|------|
| paySuccess | true | 支付成功 |
| paySuccess | false | 支付未成功 |

---

### 附錄 E：文檔缺失與待確認項目

| 項目 | 說明 |
|------|------|
| 越南銀行代碼（9.2） | 文檔標題存在但內容為空，需向渠道方索取 |
| 印尼銀行代碼（9.3.1） | 文檔標題存在但內容為空，需向渠道方索取 |
| 代付發起響應報文 | 文檔第 4 節未列出響應字段，需聯調確認 |
| 代付憑證查詢響應報文 | 文檔第 6.1 節未列出響應字段，需聯調確認 |
| 代付查詢請求參數 | 文檔第 6 節未列出請求參數，已按照慣例推斷 |
