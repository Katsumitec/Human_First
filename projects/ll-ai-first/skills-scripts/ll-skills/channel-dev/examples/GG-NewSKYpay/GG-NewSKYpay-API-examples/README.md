# GG-NewSKYpay API 範例程式碼

本目錄為 GG-NewSKYpay 渠道對接的 Python 範例程式碼，涵蓋代收 / 代付 / 查單 / 通知 / **反查** 全部接口。

## 目錄結構

```
GG-NewSKYpay-API-examples/
├── .env.example          # 配置範本（複製為 .env 後填入真實密鑰）
├── README.md             # 使用說明（本檔）
├── common.py             # 通用：簽名、驗簽、HTTP、配置
├── deposit.py            # 代收下單（POST /hpay/dt/vnd/ct）
├── withdraw.py           # 代付下單（POST /hpay/wd/vnd/ct）
├── query_order.py        # 查單（代收 / 代付）+ 餘額查詢
└── callback_handler.py   # Flask：代收通知 / 代付通知 / **反查接口** 處理
```

## 環境需求

```
Python >= 3.9
requests
flask
```

安裝：

```bash
pip install requests flask
```

## 快速開始

### 1. 設定 .env

```bash
cp .env.example .env
# 編輯 .env，填入真實 MERCHANT_KEY 與 NOTIFY_URL / QUERY_MERCHANT_ORDER_URL
```

`.env` 重要欄位：

| 欄位 | 說明 |
|---|---|
| `BASE_URL` | 上游 API 基礎地址（`http://api.newsky.vip`） |
| `MERCHANT_ID` | 我方商戶號（本案 `30038`） |
| `MERCHANT_KEY` | 商戶簽名密鑰（**敏感資訊**，見 email） |
| `NOTIFY_URL` | 我方對外的「異步通知」接收地址 |
| `QUERY_MERCHANT_ORDER_URL` | 我方對外的「**反查接口**」地址（提供給上游） |
| `PAY_TYPE` | 固定 `1060` |

### 2. 自我測試（驗證簽名計算）

```bash
python common.py
```

會用文檔的兩個範例字串驗證 `build_sign_string()` 與 `md5_lower()` 是否正確。

### 3. 代收下單

```bash
python deposit.py
```

呼叫 `POST /hpay/dt/vnd/ct`。同步響應 `data.qrCode` 是二維碼字符串，須用我方收銀台渲染為 QR 圖片給用戶掃。

### 4. 代付下單

```bash
python withdraw.py
```

呼叫 `POST /hpay/wd/vnd/ct`。注意：上游可能在收到後**主動回調我方反查接口**確認，因此務必先啟動 `callback_handler.py`。

### 5. 訂單查詢 + 餘額查詢

```bash
python query_order.py
```

依序呼叫代收查單、代付查單、餘額查詢。

### 6. 啟動回調 / 反查 Flask 服務

```bash
python callback_handler.py
```

預設聽 `0.0.0.0:5000`，提供 4 個端點：

| 路徑 | 用途 |
|---|---|
| `POST /callback/gg/notify/deposit` | 代收異步通知（驗簽 + 入帳） |
| `POST /callback/gg/notify/withdraw` | 代付異步通知（驗簽 + 結算） |
| `POST /callback/gg/query_merchant_order` | **反查接口**（form, **無簽名**, 回 `success`/`fail`） |
| `POST /_dev/seed_order` | 測試輔助：建立假訂單到記憶體 |
| `GET /health` | 健康檢查 |

## 簽名算法

**通用公式**：`toLower(md5(欄位順序拼接 + "&key=" + 商戶密鑰))`

- 「欄位順序」**依文檔指定順序**（**不是**字母排序）。
- **空字段不參與簽名**（值為 `None` 或空字串時跳過該欄位）。
- 通知接口的 `paidAmount` 在「**支付成功**（`orderStatus=3`）」時才參與簽名，其他狀態不參與。

各接口參與簽名欄位：

| 接口 | 順序 |
|---|---|
| 代收下單 | `merchantId, merchantOrderId, payAmount` |
| 代收查單 | `merchantId, merchantOrderId, payAmount` |
| 代收通知（成功） | `merchantId, merchantOrderId, payOrderId, payAmount, paidAmount` |
| 代收通知（其他） | `merchantId, merchantOrderId, payOrderId, payAmount` |
| 代付下單 | `merchantId, merchantOrderId, payAmount, bankNum, bankAccount` |
| 代付查單 | `merchantId, merchantOrderId, payAmount` |
| 代付通知（成功） | `merchantId, merchantOrderId, payOrderId, payAmount, paidAmount, bankNum, bankAccount` |
| 代付通知（其他） | `merchantId, merchantOrderId, payOrderId, payAmount, bankNum, bankAccount` |
| 餘額查詢 | `merchantId, time` |
| **反查接口** | **無簽名** |

範例（代付下單）：

```
toLower(md5(
  merchantId=5100&merchantOrderId=88&payAmount=10000&bankNum=12345&bankAccount=lisa&key=7ce0127
))
```

`common.py` 的 `sign_payload()`、`verify_sign()`、`verify_notify_sign()` 已封裝以上規則。

## 反查接口（**必看**）

- **方向**：上游 → 我方
- **觸發時機**：上游收到我方代付下單後，會主動回調我方反查地址確認該訂單是否存在
- **請求格式**：**`application/x-www-form-urlencoded`**（**非** JSON）
- **無簽名**（依 IP 白名單把關）
- **響應格式**：純文字字串 — `success` 或 `fail`
  - `success`：訂單存在且金額一致
  - `fail`：訂單不存在或金額對不上

> ⚠️ 注意：本案 `GG-requirement.md` 之前以 `OK` / `ERROR` 規格撰寫，但**官方 API 文檔規範為 `success` / `fail`**，請以 API 文檔為準（本範例已遵循官方規範）。

回調 IP 白名單（建議啟用）：

```
18.163.181.38
43.199.133.253
43.199.58.235
95.40.139.72
18.162.79.67
18.166.1.107
18.166.44.1
```

於 `callback_handler.py` 設置環境變數 `ENFORCE_IP_WHITELIST=1` 即可啟用 IP 白名單。

## 訂單狀態（`orderStatus`）

| 值 | 含義 | 是否最終態 |
|:--:|---|:--:|
| `0` | 創建（處理中） | 否 |
| `1` | 處理中 | 否 |
| `3` | 成功 | **是** |
| `8` | 失敗 | **是** |

> ⚠️ 同步響應的 `status` ≠ 交易最終狀態。**最終狀態以異步通知 + 訂單查詢的 `orderStatus` 為準**。

## 響應 `status`

| 值 | 含義 |
|:--:|---|
| `1` | 成功 |
| `0` | 失敗 |
| `-1` | 異常 |

## 端到端測試流程示意

```bash
# 1. 啟動 callback / 反查服務（另一個終端）
python callback_handler.py

# 2. 建立假訂單（讓反查時可以回 success）
curl -X POST http://localhost:5000/_dev/seed_order \
  -H "Content-Type: application/json" \
  -d '{"merchantOrderId":"GG_TEST_20260427_0001_WD","payAmount":10000}'

# 3. 發起代付下單
python withdraw.py

# 4. 模擬上游發起反查（form 格式）
curl -X POST http://localhost:5000/callback/gg/query_merchant_order \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "merchantId=30038&merchantOrderId=GG_TEST_20260427_0001_WD&payAmount=10000"
# 預期回 success

# 5. 查單
python query_order.py
```

## 常見錯誤排查

| 症狀 | 可能原因 |
|---|---|
| 簽名驗證失敗 | 1) 欄位順序錯（要按文檔順序，**非字母序**）2) 空字段沒有跳過 3) 金額型別轉換問題（`10000.0` vs `10000`） |
| 反查回 `fail` | 我方訂單庫尚未落單 / 金額對不上 / IP 不在白名單 |
| 通知收到但不入帳 | `orderStatus` 非 `3` 或 `paidAmount` 簽名段落沒處理「成功才參與」 |
| HTTP 連線失敗 | `BASE_URL` 強制 HTTPS（本渠道僅支援 HTTP） |

## 配置敏感資訊保護

- `.env` 已含敏感資訊（密鑰），**禁止**提交至 git。
- 範例提交時請僅提交 `.env.example`。
