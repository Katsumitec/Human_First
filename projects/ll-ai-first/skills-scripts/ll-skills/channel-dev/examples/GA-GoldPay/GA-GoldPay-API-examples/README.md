# GA-GoldPay API 範例程式碼

## 環境準備

### 1. 安裝依賴

```bash
pip install requests python-dotenv flask
```

### 2. 配置環境變數

複製 `.env.example` 為 `.env` 並填入實際的商戶密鑰：

```bash
cp .env.example .env
```

編輯 `.env` 文件：
```
GOLDPAY_BASE_URL=https://api.pgvn.vn-pay.co
GOLDPAY_MERCHANT_CODE=llpp8888
GOLDPAY_SECRET_KEY=你的商戶密鑰
GOLDPAY_CALLBACK_URL=https://your-domain.com/callback
```

## 範例程式碼清單

| 文件 | 說明 | 對應接口 |
|------|------|----------|
| `common.py` | 通用模組：簽名計算、配置載入、回應列印 | - |
| `deposit.py` | 代收下單 | POST `/sha256/deposit` |
| `withdraw.py` | 代付下單 | POST `/sha256/withdraw` |
| `query_order.py` | 查詢訂單（含 trans_status 狀態碼解析） | POST `/sha256/query-order` |
| `query_balance.py` | 查詢餘額 | POST `/sha256/balance` |
| `callback_handler.py` | 回調處理（Flask 服務） | 代收/代付回調接收 |
| `.env.example` | 環境變數範本 | - |

## 使用方法

### 代收下單

```bash
python deposit.py
```

程式預設使用 `service_type=702`（VN Deposit OFFLINE DIRECT）。可修改 `__main__` 區塊調整參數：

```python
deposit(
    order_no="YOUR_ORDER_NO",
    amount=100000,
    service_type=702,    # 702=離線直連, 420=MoMo, 440=ZaloPay
    hashed_mem_id="member_hash_value",
)
```

### 代付下單

```bash
python withdraw.py
```

程式預設使用 `service_type=700`（VN Withdraw）：

```python
withdraw(
    order_no="YOUR_ORDER_NO",
    amount=500000,
    service_type=700,
    bank_code="9003",          # MBBank
    card_name="NGUYEN VAN A",
    card_num="1234567890",
    merchant_user="NGUYEN VAN A",
    mobile_no="1234567890",    # service_type=700 時等於 card_num
)
```

### 查詢訂單

```bash
python query_order.py
```

查詢結果會自動解析 `trans_status` 交易狀態碼：

| 業務類型 | 狀態碼 | 說明 |
|---------|--------|------|
| 代收 | S | 已處理（成功） |
| 代收 | F | 失敗或駁回 |
| 代收 | P | 待處理 |
| 代收 | C | 已退款 |
| 代付 | Y | 已出款（成功） |
| 代付 | F | 失敗或駁回 |
| 代付 | P | 待處理 |
| 代付 | I | 處理中 |
| 代付 | C | 已退款 |

> **注意**：`status` 字段值含義：1=成功, 0=失敗, **3=部分出款**

### 查詢餘額

```bash
python query_balance.py
```

> 注意：`merchant_order_no` 可帶入 `"-"` 作為佔位符。餘額查詢請勿在 5 秒內重複請求。

### 啟動回調處理服務

```bash
python callback_handler.py
```

服務啟動後監聽 `http://0.0.0.0:8080`，回調路徑：
- 代收回調：`POST /callback/deposit`
- 代付回調：`POST /callback/withdraw`

## 簽名算法說明

簽名計算邏輯在 `common.py` 的 `generate_sign()` 函數中實現：

1. 過濾所有空值參數
2. 按參數名 ASCII 碼升序排序
3. 拼接為 `key1=value1&key2=value2` 格式
4. 末尾拼接 `&key=<商戶密鑰>`
5. 對整個字串進行 SHA256 運算
