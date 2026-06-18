# GB-EzPay API 範例程式碼

本目錄包含 GB-EzPay 所有 API 接口的 Python 範例程式碼。

## 環境準備

### 1. 安裝依賴

```bash
pip install requests python-dotenv
```

### 2. 配置環境變數

```bash
cp .env.example .env
```

編輯 `.env` 文件，填入實際的 API 配置值：
- `BASE_URL` — API 基礎地址
- `CUSTOMER_ID` — 平台分配的商戶編號
- `API_KEY` — 平台提供的 API 密鑰
- `PAY_CHANNEL_ID` — 代收通道編號
- `NOTIFY_URL` — 回調通知地址

## 檔案清單

| 檔案 | 接口 | 說明 |
|------|------|------|
| `common.py` | — | 通用工具模組（簽名計算、配置讀取） |
| `.env.example` | — | 環境變數配置範本 |
| `01_pay_order.py` | `POST /api/pay_order` | 代收-支付下單 |
| `02_pay_callback.py` | Callback | 代收-異步通知處理 |
| `03_query_transaction.py` | `POST /api/query_transaction` | 代收-查詢訂單 |
| `04_query_rate.py` | `POST /api/rate` | 代收-匯率查詢（選用） |
| `05_pay_refund.py` | `POST /api/pay_refund` | 代收-原路退款銀行資訊（選用） |
| `06_payout_order.py` | `POST /api/payments/pay_order` | 代付-申請下單 |
| `07_payout_callback.py` | Callback | 代付-支付結果異步通知處理 |
| `08_payout_query.py` | `POST /api/payments/query_transaction` | 代付-查詢訂單 |
| `09_payout_balance.py` | `POST /api/payments/balance` | 代付-餘額查詢（選用） |

## 使用方式

每個範例都可以獨立執行：

```bash
# 代收-支付下單
python 01_pay_order.py

# 代收-查詢訂單
python 03_query_transaction.py

# 代付-申請下單
python 06_payout_order.py

# 代付-餘額查詢
python 09_payout_balance.py
```

### 作為模組引用

```python
from common import generate_sign, verify_sign, current_timestamp
from _01_pay_order import create_pay_order
from _06_payout_order import create_payout_order

# 代收下單
result = create_pay_order(order_id="MY_ORDER_001", amount=200.00, user_name="TestUser")

# 代付下單
result = create_payout_order(
    order_id="PAYOUT_001",
    amount=500.00,
    account_name="Nguyen Van A",
    card_no="1234567890",
    bank_name="VIETCOMBANK",
)
```

## 簽名算法說明

所有主動請求接口均使用 MD5 簽名，流程如下：

1. 將須簽名的參數按鍵名**升序排序**
2. 將**非空值**以 `key=value&` 格式拼接
3. 末尾追加 `key={API_KEY}`
4. 對整個字串做 MD5 雜湊，結果轉**大寫**

簽名函數位於 `common.py` 中的 `generate_sign()` 和 `verify_sign()`。

## 回調處理注意事項

- 代收回調（`02_pay_callback.py`）和代付回調（`07_payout_callback.py`）為被動接收接口
- 收到回調後**必須返回純文字 `OK`**（大寫，無雙引號），否則平台會持續重發
- 回調數據中的 `sign` 字段不參與驗簽計算
