# GG-NewSKYpay API 接口文檔分析

> 文檔來源：http://18.163.184.55/doc （線上多頁式 API 文檔站）
> 子頁面 URL 列表：見 `input/api-doc-urls.md`
> 分析日期：2026-04-27
> 對接需求：`input/project-require.md`、`GG-requirement.md`

---

## 通用協議規範

### 通信協議

- 協議類型：**HTTP**（API 文檔站本身為 http://18.163.184.55/doc，且實際 API 端點 `http://api.newsky.vip` 也未強制 HTTPS）
- Base URL：`http://api.newsky.vip`
- 請求方式：**POST**（所有業務接口；唯獨**反查接口**為「商戶提供的查單地址」，由我方對外提供）

### 報文格式

- Content-Type：
  - 業務接口（代收下單 / 代收查單 / 代付下單 / 代付查單 / 餘額查詢 / 異步通知）：`application/json`
  - **反查商戶接口**（上游 → 我方）：`application/x-www-form-urlencoded`（POST form 表單）
- 請求格式：JSON（除反查接口為 form）
- 響應格式：
  - 業務接口：JSON
  - 異步通知響應（我方回給上游）：純文字字串（`success` 或 `ok`）
  - 反查接口響應（我方回給上游）：純文字字串（`success` 或 `fail`）
- 字符編碼：UTF-8

### 安全協議

- 簽名算法：**MD5（小寫，32 字元）**
- 簽名算法總覽：`toLower(md5(欄位拼接 + "&key=" + 商戶密鑰))`
- 簽名規則（共通）：
  1. **按文檔指定欄位順序**拼接（**非字母排序**），格式為 `key1=value1&key2=value2&...`
  2. 拼接結尾追加 `&key=<商戶密鑰>`
  3. 整串做 MD5 後**轉小寫**
  4. **空字段不參與簽名**（部分接口明確說明「空字段不參與簽名」，例如查單／通知）
  5. **paidAmount** 欄位特殊：「**支付成功時參與簽名**，未成功時不參與簽名」（適用代收/代付通知）
- 各接口參與簽名的欄位（按順序）：
  | 接口 | 參與簽名欄位（順序） |
  |------|--------------------|
  | 代收下單 | `merchantId, merchantOrderId, payAmount` |
  | 代收查單 | `merchantId, merchantOrderId, payAmount` |
  | 代收通知 | `merchantId, merchantOrderId, payOrderId, payAmount, paidAmount`（paidAmount 僅成功時參與） |
  | 代付下單 | `merchantId, merchantOrderId, payAmount, bankNum, bankAccount` |
  | 代付查單 | `merchantId, merchantOrderId, payAmount` |
  | 代付通知 | `merchantId, merchantOrderId, payOrderId, payAmount, paidAmount, bankNum, bankAccount`（paidAmount 僅成功時參與） |
  | 餘額查詢 | `merchantId, time` |
  | **反查接口** | **無簽名**（僅靠回調 IP 白名單與訂單號+金額比對） |
  | 響應內 `data.sign` | 通常以 `merchantId, merchantOrderId, payOrderId, payAmount` 順序簽名（用於我方驗響應） |
- 簽名位置：JSON Body 中的 `sign` 字段
- 加密方式：無（純 HTTP + 簽名）
- 其他安全機制：
  - **回調 IP 白名單**：18.163.181.38 / 43.199.133.253 / 43.199.58.235 / 95.40.139.72 / 18.162.79.67 / 18.166.1.107 / 18.166.44.1
  - 反查接口無驗簽，須以 IP 白名單把關
- 簽名示例：
  - 代付下單： `toLower(md5(merchantId=5100&merchantOrderId=88&payAmount=10000&bankNum=12345&bankAccount=lisa&key=7ce0127))`
  - 代收下單： `toLower(md5(merchantId=500000&merchantOrderId=88&payAmount=10000&key=xxxx))`
  - 代收通知： `toLower(md5(merchantId=5100&merchantOrderId=88&payOrderId=123&payAmount=1000&paidAmount=1000&key=xxxx))`
  - 餘額查詢： `toLower(md5(merchantId=500000&time=2021072512&key=xxxx))`

### 訂單狀態碼（共通）

| `orderStatus` | 含義 |
|:---:|------|
| `0` | 創建（待處理） |
| `1` | 處理中 |
| `3` | 成功（最終狀態） |
| `8` | 失敗（最終狀態） |

> ⚠️ **重要**：判斷代收成功 / 代付失敗均以 `orderStatus` 為準，**不可**用同步響應的 `status` 判定最終狀態。
> - 同步響應的 `status` 僅代表「下單請求是否被受理」，**非交易最終狀態**。
> - 交易最終狀態由 **異步通知** + **訂單查詢** 共同確認。

### 響應狀態碼（`status`，全接口共用）

| `status` | 含義 |
|:---:|------|
| `1` | 成功（請求受理 / 業務正常） |
| `0` | 失敗（業務失敗，例如訂單不存在） |
| `-1` | 異常（系統錯誤） |

---

## 接口列表（總表）

| # | 接口名稱 | 方向 | URL（相對） | 方法 | Content-Type | 分類 |
|---|---------|------|------|------|------|------|
| 1 | 代收下單（充值下單） | 我方 → 上游 | `/hpay/dt/vnd/ct` | POST | application/json | C：複合類代收（同時可能回 `payUrl` 或 `qrCode`） |
| 2 | 代收查單（充值訂單查詢） | 我方 → 上游 | `/hpay/dt/vnd/query` | POST | application/json | Q：查詢類 |
| 3 | 代收異步通知 | 上游 → 我方 | 商戶通知地址 | POST | application/json | N：異步通知 |
| 4 | 代付下單（出款下單） | 我方 → 上游 | `/hpay/wd/vnd/ct` | POST | application/json | W：代付類 |
| 5 | 代付查單（出款查單） | 我方 → 上游 | `/hpay/wd/vnd/query` | POST | application/json | Q：查詢類 |
| 6 | 代付異步通知 | 上游 → 我方 | 商戶通知地址 | POST | application/json | N：異步通知 |
| 7 | **反查商戶接口** | **上游 → 我方** | **我方提供的反查地址** | **POST** | **application/x-www-form-urlencoded** | **N：反查回調（特殊）** |
| 8 | 商戶餘額查詢 | 我方 → 上游 | `/hpay/merchant/balance` | POST | application/json | Q：查詢類 |
| 9 | 銀行類型對照表 | 參考 | （靜態頁面） | — | — | 附錄：銀行編碼 |

---

## 代收接口

### 1. 代收下單（充值下單）

**接口說明**
- 名稱：充值下單
- 功能與目的：商戶向上游發起代收（用戶充值）下單，取得二維碼字符串或支付地址作為自製收銀台展示
- 接口 URL：`POST http://api.newsky.vip/hpay/dt/vnd/ct`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：application/json

**接口分類**：C：複合類代收（響應可能含 `qrCode` 或 `payUrl`）

**接口協議**：同通用規範

**請求 Header**：同通用規範

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號（本案 `30038`） |
| merchantOrderId | string | 是 | ✅ | 商戶訂單號（≤64 字元） |
| payAmount | number | 是 | ✅ | 支付金額（整數金額，如 10000） |
| bankAccount | string | 否 | ❌ | 充值姓名 |
| payType | int | 是 | ❌ | 支付方式（**固定 `1060`**） |
| userId | string | 是 | ❌ | 會員 ID（最長 36 位） |
| notifyUrl | string | 是 | ❌ | 異步通知地址 |
| bankType | string | 否 | ❌ | 銀行類型（編碼，見銀行類型表） |
| userIp | string | 否 | ❌ | 會員 IP |
| sign | string | 是 | ❌ | MD5 簽名 |

簽名方式：`toLower(md5(merchantId=...&merchantOrderId=...&payAmount=...&key=<商戶密鑰>))`

請求範例：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "23542sdf55252s5w14w",
  "payType": 1060,
  "payAmount": 10000,
  "bankType": "CMB",
  "bankAccount": "liudehua",
  "notifyUrl": "http://example.com",
  "userId": "78",
  "sign": "xxxx"
}
```

CURL 範例：
```bash
curl -X POST http://api.newsky.vip/hpay/dt/vnd/ct \
  -H "Content-Type: application/json" \
  -d '{
    "merchantId": 50000,
    "merchantOrderId": "23542sdf55252s5w14w",
    "payType": 1060,
    "payAmount": 10000,
    "userId": "78",
    "notifyUrl": "http://example.com",
    "sign": "xxxx"
  }'
```

**響應報文（Response）**

> ⚠️ 同步響應僅代表下單請求的處理結果，並不代表「用戶已完成支付」。
> 用戶實際支付結果以**異步通知**為準。
> - `status=1` 僅表示「上游受理」 + `data.orderStatus` 通常為 `0`（創建）或 `1`（處理中）；
> - 真正交易成功須等到通知或查詢回 `data.orderStatus=3`。

- 響應格式：JSON
- Content-Type：application/json

| 字段名 | 類型 | 參與簽名 | 說明 |
|--------|------|:---:|------|
| status | int | ❌ | 響應狀態（-1/0/1） |
| msg | string | ❌ | 描述信息 |
| data.merchantId | int | ✅ | 商戶號 |
| data.merchantOrderId | string | ✅ | 商戶訂單號 |
| data.payOrderId | string | ✅ | 上游支付訂單號 |
| data.payAmount | number | ✅ | 金額 |
| data.orderStatus | string | ❌ | 訂單狀態（0/1/3/8） |
| data.remark | string | ❌ | 附言 / 失敗原因 |
| data.receiveNum | string | ❌ | 收款卡號 / 手機號 |
| data.receiveAccount | string | ❌ | 收款卡帳戶名 |
| data.receiveType | string | ❌ | 收款銀行編碼 |
| **data.qrCode** | string | ❌ | **二維碼字符串**（自製收銀台核心欄位） |
| **data.payUrl** | string | ❌ | **支付地址**（URL，跳轉式收銀台時用） |
| data.createTime | string | ❌ | 創建時間 |
| data.sign | string | ❌ | 響應簽名 |

> 響應 `data.qrCode` 與 `data.payUrl` 互斥或擇一可能存在。本案需求為自製收銀台 → 取 `data.qrCode` 渲染 QR Code。

響應範例（推測，參考查單）：
```json
{
  "status": 1,
  "msg": "下单成功",
  "data": {
    "merchantId": 50000,
    "merchantOrderId": "23542sdf55252s5w14w",
    "payOrderId": "P2026042701234",
    "payAmount": 10000,
    "orderStatus": "0",
    "qrCode": "00020101021238...VND...6304ABCD",
    "createTime": "2026-04-27 18:30:00",
    "sign": "abcdef0123456789..."
  }
}
```

---

### 2. 代收查單（充值訂單查詢）

**接口說明**
- 名稱：查詢支付充值訂單
- 功能與目的：依商戶訂單號 + 金額查詢上游訂單狀態
- 接口 URL：`POST http://api.newsky.vip/hpay/dt/vnd/query`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：application/json

**接口分類**：Q：查詢類

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號 |
| merchantOrderId | string | 是 | ✅ | 商戶訂單號 |
| payAmount | number | 是 | ✅ | 支付金額 |
| sign | string | 是 | ❌ | MD5 簽名 |

簽名：`toLower(md5(merchantId=...&merchantOrderId=...&payAmount=...&key=...))`

請求範例：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "1j23h4hj5k67lk65",
  "payAmount": 10000,
  "sign": "xxxx"
}
```

**響應報文（Response）**

> ⚠️ **交易最終狀態判定**：以 `data.orderStatus` 為準
> - `3` → 成功（最終狀態）
> - `8` → 失敗（最終狀態）
> - `0` / `1` → 處理中（**不可**入帳）

| 字段名 | 類型 | 參與簽名 | 說明 |
|--------|------|:---:|------|
| status | int | ❌ | 響應狀態 |
| msg | string | ❌ | 描述 |
| data.merchantId | int | ✅ | 商戶號 |
| data.merchantOrderId | string | ✅ | 商戶訂單號 |
| data.payAmount | number | ✅ | 訂單金額 |
| data.payOrderId | string | ❌ | 上游支付訂單號 |
| data.paidAmount | number | ❌ | 到帳金額 |
| data.orderStatus | string | ❌ | 訂單狀態 |
| data.remark | string | ❌ | 失敗原因 |
| data.createTime | string | ❌ | 創建時間 |
| data.updateTime | string | ❌ | 更新時間 |
| data.sign | string | ❌ | MD5 簽名 |

響應範例：
```json
{
  "status": 1,
  "msg": "订单存在",
  "data": {
    "merchantId": 50000,
    "merchantOrderId": "xxx",
    "payOrderId": "xxx",
    "payAmount": 10000,
    "paidAmount": 10000,
    "orderStatus": 3,
    "sign": "xxx"
  }
}
```

---

### 3. 代收異步通知（充值通知）

**接口說明**
- 名稱：通知商戶（充值）
- 功能與目的：上游將最終代收訂單狀態推送至商戶下單時提交的 `notifyUrl`
- 通知方式：HTTP POST（上游 → 我方 `notifyUrl`）
- 通知請求格式：JSON
- Content-Type：application/json

**接口分類**：N：異步通知

**回調請求 Header**：同通用規範

**回調請求報文（Request，渠道推送內容）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號 |
| merchantOrderId | string | 是 | ✅ | 訂單號 |
| payOrderId | string | 是 | ✅ | 支付訂單號 |
| payAmount | number | 是 | ✅ | 支付金額 |
| paidAmount | number | 否 | ✅（成功時） | 實際支付金額（**支付成功才參與簽名**） |
| remark | string | 否 | ❌ | 失敗原因 |
| orderStatus | string | 是 | ❌ | 訂單狀態（0/1/3/8） |
| bankAccount | string | 否 | ❌ | 收款帳戶名 |
| sign | string | 是 | ❌ | MD5 簽名 |

簽名（成功時）：`toLower(md5(merchantId=...&merchantOrderId=...&payOrderId=...&payAmount=...&paidAmount=...&key=...))`
簽名（非成功時）：`toLower(md5(merchantId=...&merchantOrderId=...&payOrderId=...&payAmount=...&key=...))`（無 `paidAmount`）

回調請求範例：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "23542sdf55252s5w14w",
  "payType": 1060,
  "payAmount": 10000,
  "paidAmount": 10000,
  "bankAccount": "liudehua",
  "sign": "d4we5322812e693412"
}
```

> ⚠️ **代收交易最終成功判定**（誤判將賠付）：
> - `orderStatus = 3` 才算成功；
> - 同時須驗證 `payAmount == paidAmount`（不浮動金額）；
> - 必須通過簽名校驗。

**回調響應報文（Response，商戶需回覆內容）**

純文字字串：`success` 或 `ok`（兩者皆可）

回調響應範例：
```
success
```

---

## 代付接口

### 4. 代付下單（出款下單）

**接口說明**
- 名稱：出款下單
- 功能與目的：商戶向上游發起代付（出款）下單
- 接口 URL：`POST http://api.newsky.vip/hpay/wd/vnd/ct`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：application/json

**接口分類**：W：代付類

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號 |
| merchantOrderId | string | 是 | ✅ | 商戶訂單號（≤64 字元） |
| payAmount | number | 是 | ✅ | 支付金額（如 10000） |
| bankNum | string | 是 | ✅ | 收款號碼（銀行卡或手機號） |
| bankAccount | string | 是 | ✅ | 收款帳戶名（收款人姓名） |
| bankType | string | 是 | ❌ | 銀行類型（銀行編碼，見附錄） |
| payType | int | 是 | ❌ | 支付方式（**固定 `1060`**） |
| notifyUrl | string | 是 | ❌ | 通知地址 |
| sign | string | 是 | ❌ | MD5 簽名 |

> 額外（出現在範例但未在表格中，視為可選）：`commonType`、`withdrawQueryUrl`、`bankAddress`、`userId`、`userIp`

簽名：`toLower(md5(merchantId=...&merchantOrderId=...&payAmount=...&bankNum=...&bankAccount=...&key=...))`

請求範例：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "23542sdf55252s5w14w",
  "payAmount": 10000,
  "bankType": "ACB",
  "bankNum": "36954697135656",
  "bankAccount": "liudehua",
  "payType": 1060,
  "commonType": "viettel_qr",
  "withdrawQueryUrl": "http://merchantOrderQueryAddress",
  "bankAddress": "Thành phố Hồ Chí Minh",
  "notifyUrl": "http://ptdene.jm/xrdsms",
  "userId": "78",
  "userIp": "212.139.172.110",
  "sign": "d4we5322812e693412"
}
```

**響應報文（Response）**

> ⚠️ **代付失敗判定**（誤判將虧損 / 重複扣款）：
> - 同步響應 `status=1` 並**不**代表代付成功；
> - 須以**異步通知** + **查單** 中的 `orderStatus=8` 為失敗最終態；
> - **「無法判定狀態」時應視為「處理中」並重試查單**，不可貿然失敗 → 退款。

| 字段名 | 類型 | 參與簽名 | 說明 |
|--------|------|:---:|------|
| status | int | ❌ | 響應狀態（-1 異常 / 0 失敗 / 1 成功） |
| msg | string | ❌ | 描述 |
| data | json | ❌ | 響應對象 |
| data.merchantId | int | ✅ | 商戶號 |
| data.merchantOrderId | string | ✅ | 商戶訂單號 |
| data.payOrderId | string | ✅ | 上游訂單號 |
| data.payAmount | number | ✅ | 金額 |
| data.paidAmount | number | ❌ | 實際支付金額 |
| data.orderStatus | number | ❌ | 訂單狀態（0/1/3/8） |
| data.createTime | string | ❌ | 創建時間 |
| data.sign | string | ❌ | 響應簽名 |

響應範例：
```json
{
  "status": 1,
  "msg": "提款下单成功",
  "data": {
    "merchantId": 50000,
    "merchantOrderId": "5565e5w6e5rw6er56w",
    "payOrderId": "52w653654634",
    "orderStatus": 0,
    "payAmount": 20000,
    "sign": "d4k5k4l6l4645"
  }
}
```

---

### 5. 代付查單（出款查單）

**接口說明**
- 名稱：出款查單
- 接口 URL：`POST http://api.newsky.vip/hpay/wd/vnd/query`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：application/json

**接口分類**：Q：查詢類

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號 |
| merchantOrderId | string | 是 | ✅ | 商戶訂單號 |
| payAmount | number | 是 | ✅ | 金額 |
| sign | string | 是 | ❌ | MD5 簽名 |

簽名規則同代收查單（**空字段不參與簽名**）：
`merchantId=...&merchantOrderId=...&payAmount=...&key=...`

請求範例：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "1j23h4hj5k67lk65",
  "payAmount": 10000,
  "sign": "f1h2j3k4m5n6b7o8i91cx2"
}
```

**響應報文（Response）**

> ⚠️ **代付最終狀態判定**：以 `data.orderStatus` 為準（誤判可能造成虧損）
> - `3` → 成功（最終態，視為已出款）
> - `8` → 失敗（最終態，可退款回帳）
> - `0` / `1` → 處理中（**不可**退款回帳）

| 字段名 | 類型 | 參與簽名 | 說明 |
|--------|------|:---:|------|
| status | int | ❌ | 響應狀態 |
| msg | string | ❌ | 描述 |
| data.merchantId | int | ✅ | 商戶號 |
| data.merchantOrderId | string | ✅ | 商戶訂單號 |
| data.payAmount | number | ✅ | 金額 |
| data.payOrderId | string | ❌ | 上游訂單號 |
| data.paidAmount | number | ❌ | 實際支付金額 |
| data.orderStatus | string | ❌ | 訂單狀態 |
| data.remark | string | ❌ | 失敗原因 |
| data.createTime | string | ❌ | 創建時間 |
| data.updateTime | string | ❌ | 更新時間 |
| data.sign | string | ❌ | MD5 簽名 |

響應範例：
```json
{
  "status": 1,
  "msg": "订单存在",
  "data": {
    "merchantId": 50000,
    "merchantOrderId": "q1w2e3r4g5h6j7k8l9",
    "payOrderId": "k8j7h6g5f4d3s2a1",
    "payAmount": 10000,
    "sign": "a1s3d4f5g6h7j8k9l0",
    "paidAmount": 10000,
    "orderStatus": 3,
    "createTime": "1976-12-18 15:41:33"
  }
}
```

---

### 6. 代付異步通知

**接口說明**
- 名稱：通知商戶（出款）
- 功能與目的：上游將代付最終結果推送至商戶 `notifyUrl`
- 通知方式：HTTP POST（上游 → 我方）
- 請求格式：JSON
- Content-Type：application/json

**接口分類**：N：異步通知

**回調請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號 |
| merchantOrderId | string | 是 | ✅ | 商戶訂單號 |
| payOrderId | string | 是 | ✅ | 支付訂單號 |
| payAmount | number | 是 | ✅ | 支付金額 |
| paidAmount | number | 否 | ✅（成功時） | 實際支付金額 |
| bankNum | string | 是 | ✅ | 支付號碼（銀行卡 / 手機號） |
| bankAccount | string | 是 | ✅ | 支付帳戶名 |
| orderStatus | number | 是 | ❌ | 訂單狀態 |
| remark | string | 否 | ❌ | 失敗原因 |
| sign | string | 是 | ❌ | MD5 簽名 |

簽名（成功）：`toLower(md5(merchantId=...&merchantOrderId=...&payOrderId=...&payAmount=...&paidAmount=...&bankNum=...&bankAccount=...&key=...))`
簽名（非成功）：去除 `paidAmount`：`toLower(md5(merchantId=...&merchantOrderId=...&payOrderId=...&payAmount=...&bankNum=...&bankAccount=...&key=...))`

回調請求範例：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "23542sdf55252s5w14w",
  "payType": 1060,
  "payAmount": 10000,
  "paidAmount": 10000,
  "bankNum": "36954697135656",
  "bankAccount": "liudehua",
  "sign": "d4we5322812e693412"
}
```

**回調響應報文（Response）**

純文字字串：`success` 或 `ok`

---

### 7. 反查商戶接口（**重點接口** — 上游 → 我方）

**接口說明**
- 名稱：反查商戶訂單（POST form 表單）
- 功能與目的：上游在收到我方代付下單後，會主動回調我方系統的「反查地址」確認該訂單存在；我方需依訂單號 + 金額確認後回應字串。
- 通知方向：**上游 → 我方**
- 接口 URL：`${商戶提供的查單地址}`（**由我方對外提供**，非上游接口；通常配置在我方系統的某個 gateway 路由）
- 請求方式：**POST**
- 請求格式：**form 表單**（`application/x-www-form-urlencoded`）
- Content-Type：application/x-www-form-urlencoded

**接口分類**：N：反查回調（特殊 / 必接）

**接口協議**：與通用規範**不同**：
- 請求是 form 而非 JSON
- **無 `sign` 欄位，不驗簽**（按使用者 / 文檔約定，依靠回調 IP 白名單把關）
- 響應為純文字字串

**回調請求 Header**：標準 form POST，無特別 Header 需求。

**請求報文（Request，上游推送內容）**

| 字段名 | 類型 | 必填 | 說明 |
|--------|------|:---:|------|
| merchantId | int | 是 | 商戶號 |
| merchantOrderId | string | 是 | 商戶訂單號 |
| payAmount | number | 是 | 支付金額 |

請求範例（form-urlencoded）：
```
merchantId=50000&merchantOrderId=1j23h4hj5k67lk65&payAmount=1000
```

或文檔展示的等價 JSON 寫法（僅作說明）：
```json
{
  "merchantId": 50000,
  "merchantOrderId": "1j23h4hj5k67lk65",
  "payAmount": 1000
}
```

CURL 範例：
```bash
curl -X POST http://<我方反查地址> \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "merchantId=50000&merchantOrderId=1j23h4hj5k67lk65&payAmount=1000"
```

**響應報文（Response，我方需回覆內容）**

- 響應格式：純文字字串（**非 JSON**）
- Content-Type：`text/plain`
- 僅可返回兩種值：

| 響應值 | 含義 |
|---|---|
| `success` | 訂單存在 |
| `fail` | 訂單不存在 |

> ⚠️ **重要差異提示**：本案專案需求文檔（`GG-requirement.md` 第 0098 章節 / `0098_txn_notify.ftl`）中設定的反查回應為 **`OK` / `ERROR`**，但**官方 API 文檔實際規範為 `success` / `fail`**。
> 對接時應**以官方 API 文檔為準**，請務必修正 0098 模板：
> ```freemarker
> <#assign respToChannel = 'fail' />
> <#if orderResult.result_code == '0000'>
>   <#assign respToChannel = 'success' />
> </#if>
> ```

我方反查邏輯：
1. 接收 form：`merchantId`、`merchantOrderId`、`payAmount`
2. 用 `merchantOrderId` + 金額查詢我方資料庫；
3. 訂單存在且金額一致 → 回 `success`
4. 否則 → 回 `fail`

---

## 餘額接口

### 8. 商戶餘額查詢

**接口說明**
- 名稱：商戶餘額查詢
- 接口 URL：`POST http://api.newsky.vip/hpay/merchant/balance`
- 請求方式：POST
- 請求格式：JSON
- Content-Type：application/json

**接口分類**：Q：查詢類

**請求報文（Request）**

| 字段名 | 類型 | 必填 | 參與簽名 | 說明 |
|--------|------|:---:|:---:|------|
| merchantId | int | 是 | ✅ | 商戶號 |
| time | string | 是 | ✅ | 時間戳（格式 `yyyyMMddHH`，例如 `1994051908`） |
| sign | string | 是 | ❌ | MD5 簽名 |

簽名：`toLower(md5(merchantId=...&time=...&key=...))`

請求範例：
```json
{
  "merchantId": 60001,
  "time": "1994051908",
  "sign": "xxxx"
}
```

**響應報文（Response）**

| 字段名 | 類型 | 參與簽名 | 說明 |
|--------|------|:---:|------|
| status | int | ❌ | 響應狀態 |
| msg | string | ❌ | 描述 |
| data.balance | number | ✅ | 可用餘額 |

響應範例：
```json
{
  "status": 1,
  "msg": "余额查询成功",
  "data": {
    "balance": 190000
  }
}
```

---

## 附錄

### A. 銀行類型對照表（越南銀行）

| 銀行名稱 | 銀行編碼 |
|---|---|
| VietinBank | ICB |
| Vietcombank | VCB |
| BIDV | BIDV |
| Agribank | VBA |
| OCB | OCB |
| MBBank | MB |
| Techcombank | TCB |
| ACB | ACB |
| VPBank | VPB |
| TPBank | TPB |
| Sacombank | STB |
| HDBank | HDB |
| VietCapitalBank | VCCB |
| SCB | SCB |
| VIB | VIB |
| SHB | SHB |
| Eximbank | EIB |
| MSB | MSB |
| CAKE | CAKE |
| Ubank | Ubank |
| ViettelMoney | VTLMONEY |
| Timo | TIMO |
| VNPTMoney | VNPTMONEY |
| SaigonBank | SGICB |
| BacABank | BAB |
| PVcomBank Pay | PVDB |
| PVcomBank | PVCB |
| MBV | MBV |
| NCB | NCB |
| ShinhanBank | SHBVN |
| ABBANK | ABB |
| VietABank | VAB |
| NamABank | NAB |
| PGBank | PGB |
| VietBank | VIETBANK |
| BaoVietBank | BVB |
| SeABank | SEAB |
| COOPBANK | COOPBANK |
| LPBank | LPB |
| KienLongBank | KLB |
| KBank | KBank |
| MAFC | MAFC |
| KEBHANAHN | KEBHANAHN |
| KEBHanaHCM | KEBHANAHCM |
| Citibank | CITIBANK |
| VBSP | VBSP |
| CBBank | CBB |
| CIMB | CIMB |
| DBSBank | DBS |
| PublicBank | PBVN |
| HSBC | HSBC |
| UOB | UOB |
| StandardChartered | SCVN |

### B. 狀態碼速查

#### B.1 響應 `status`
| 值 | 含義 |
|:--:|------|
| `1` | 成功 |
| `0` | 失敗 |
| `-1` | 異常 |

#### B.2 訂單 `orderStatus`（最關鍵）
| 值 | 含義 | 是否最終狀態 |
|:--:|------|:--:|
| `0` | 創建 | ❌ 處理中 |
| `1` | 處理中 | ❌ 處理中 |
| `3` | **成功** | ✅ 最終 |
| `8` | **失敗** | ✅ 最終 |

### C. 對接重點與注意事項（給開發者）

1. **簽名規則一致**：所有業務接口（含通知）均為 `toLower(md5(欄位順序拼接 + "&key=" + 商戶密鑰))`，**非字母排序**而是文檔指定順序。
2. **paidAmount 特殊規則**：通知接口在「支付成功時」`paidAmount` 才參與簽名。對接時須依 `orderStatus` 判斷是否將 `paidAmount` 加入簽名串。
3. **payType 固定 1060**：代收/代付下單時皆固定。
4. **金額單位**：依範例為**整數金額**（10000 應為 10000 VND，無小數），但 `payAmount` 類型為 `number`、查單響應金額有「保留兩位小數」字樣，須以聯調確認。
5. **反查接口**：
   - 是 **form-urlencoded**（非 JSON）
   - 無簽名 → 必須以**回調 IP 白名單**把關
   - 響應 **`success`** / **`fail`**（**非** `OK` / `ERROR`，請更正 0098 模板）
6. **回調 IP 白名單**：18.163.181.38、43.199.133.253、43.199.58.235、95.40.139.72、18.162.79.67、18.166.1.107、18.166.44.1
7. **代收響應為 `qrCode` 字符串**（非 URL）→ 需我方自製收銀台渲染 QR Code。
8. **同步 vs 異步狀態判斷**：所有最終狀態皆以**異步通知 / 查單**的 `data.orderStatus` 為準，同步響應的 `status` 僅為「請求受理」結果。

---

## 文檔差異警示（重要）

| 項 | 本案需求文檔記錄 | 官方 API 文檔實際 | 處理建議 |
|---|---|---|---|
| 反查回應 | `OK` / `ERROR` | **`success` / `fail`** | 修正 `0098_txn_notify.ftl` 模板 |
| 反查請求格式 | （未註明） | **form-urlencoded** | requestMode 應為 `FORM_TEXT`（非 `JSON_JSON`） |
| 反查歸屬分類 | 「代收 → 反查」 | **代付接口下「反查商戶接口規範(必須接)」** | 文檔位置以官方為準 |

