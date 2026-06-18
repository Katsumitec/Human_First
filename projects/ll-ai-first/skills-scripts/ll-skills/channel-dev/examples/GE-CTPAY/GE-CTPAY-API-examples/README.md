# GE-CTPAY API 範例程式碼

## 環境準備

```bash
pip install requests python-dotenv
cp .env.example .env
# 編輯 .env，填入真實的 api_token 和 notify_token
```

## 範例程式碼清單

| 文件 | 說明 | 對應接口 |
|------|------|----------|
| `ctpay_utils.py` | 工具模塊（簽名、Header、驗簽） | 共用 |
| `collection_request.py` | 代收請求（純卡網關，返回 qrcode） | POST /api/transaction |
| `collection_query.py` | 代收訂單查詢 | GET /api/transaction/{id} |
| `collection_notify_verify.py` | 代收回調驗簽處理 | 商戶回調端點 |
| `payment_request.py` | 代付請求（必須簽名） | POST /api/payment |
| `payment_query.py` | 代付訂單查詢 | GET /api/payment/{id} |
| `payment_notify_verify.py` | 代付回調驗簽處理 | 商戶回調端點 |

## 使用方式

### 發起代收請求

```bash
python collection_request.py
```

### 查詢代收訂單

```bash
python collection_query.py
```

### 發起代付請求

```bash
python payment_request.py
```

## 簽名說明

```python
# 簽名公式：
# 1. 對指定字段按 key ASCII 碼排序（ksort）
# 2. 拼接為 key=value&key=value...
# 3. 直接拼接 api_token + notify_token（無分隔符）
# 4. MD5（小寫 hex）

import hashlib
fields = {"amount": "500", "out_trade_no": "ORDER001"}
raw = "&".join(f"{k}={v}" for k, v in sorted(fields.items()))
raw += api_token + notify_token
sign = hashlib.md5(raw.encode("utf-8")).hexdigest()
```

## 重要注意事項

1. **代收簽名為選填**（API 文件說「非必要請勿填寫」），但帶上可增加安全性
2. **代付簽名為必填**
3. **代收回調只通知 completed（成功）訂單**
4. **代付回調在成功/沖回/失敗時觸發**
5. 回調驗簽欄位固定為：`trade_no`, `amount`, `out_trade_no`, `state`（4個字段）
6. `sign.key = api_token + notify_token`（直接拼接，無分隔符）
