# GJ-GoldenPayThai API 範例程式

對應渠道：**GJ / GoldenPay泰国**
對接文檔：https://integration.gpbli.top/reference/
API 分析文件：`../GJ-GoldenPayThai-API-docs.md`

---

## 環境準備

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install requests python-dotenv flask
cp .env.example .env
# 編輯 .env，填入 MCH_ID 與 API_TOKEN（見 email）
```

---

## 程式碼清單

| 檔案 | 說明 |
|---|---|
| `common.py` | 共用：配置載入、簽名計算（MD5 + API_TOKEN 前綴）、驗簽、請求／回應列印 |
| `deposit.py` | 代收下單：POST `/api/v1/mch/pmt-orders` |
| `withdraw.py` | 代付下單：POST `/api/v1/mch/wdl-orders` |
| `query_order.py` | 訂單查詢（代收／代付共用）：GET + Query String |
| `callback_handler.py` | 回調接收（Flask）：驗簽 + 回純文字 `success` |
| `.env.example` | 環境變數範本（複製為 `.env` 使用） |

---

## 使用方法

### 1. 驗證簽名算法

`common.py` 直接執行會用官方範例自檢：

```bash
python common.py
```

應印出 `Signature: 3147c167da0392a2317542c18d0017e1` 並通過 assertion。

### 2. 代收下單

```bash
python deposit.py [trans_id] [amount]
# 例：
python deposit.py TEST20260424001 100.00
```

### 3. 代付下單

```bash
python withdraw.py [trans_id] [amount]
# 例：
python withdraw.py WD20260424001 500.00
```

### 4. 訂單查詢

```bash
# 代收查詢
python query_order.py <order_id> deposit

# 代付查詢
python query_order.py <order_id> withdraw
```

### 5. 啟動回調接收

```bash
python callback_handler.py
# 監聽 0.0.0.0:5000
#   POST /callback/deposit   代收
#   POST /callback/withdraw  代付
```

---

## 簽名算法說明

```
source = API_TOKEN + "&" + key1=value1&key2=value2&...
signature = md5(source).hex()  # 小寫
```

規則：
1. 取出除 `sign` 外的所有**非空**參數
2. 按 **key ASCII 字典序**排序
3. 以 `key=value` 格式用 `&` 連接成 body
4. **在 body 最前面附加 `API_TOKEN`，用 `&` 分隔**
5. 對最終字串做 MD5，取十六進制字串（不區分大小寫）

範例見 `common.py` 的 `__main__`，可直接執行驗證。

---

## 重要規範

1. **HTTPS + JSON**：下單接口一律 `Content-Type: application/json`
2. **固定參數**：每次調用必帶 `nonce`（≥6 位）、`timestamp`（10 位 UNIX 秒）、`sign`
3. **currency 用字母碼**（`THB`），不是數字碼
4. **amount 為字串**，例 `"100.00"`（法幣標準單位）
5. **代收回調**需回覆純文字 `success`；超時 5 秒；失敗每 60 秒重試，共 3 次
6. **代付回調**需回覆純文字 `success`；超時 10 秒；失敗每 30 秒重試，共 5 次
7. **泰國實名場景**：代收需帶 `payer_account_no / payer_account_name / payer_account_org`
8. **回調 IP 白名單**：`15.152.252.49`、`16.209.30.115`

---

## 狀態碼映射（對照樂力）

| 場景 | 上游 status | 語義 |
|---|---|---|
| 代收下單（同步） | 20 | 新創建（處理中） |
| 代收查詢 | 60 | 支付成功 |
| 代收查詢 | 其他 | 未支付 |
| 代收通知 | 60 | 成功，其他失敗 |
| 代付下單（同步） | 20 | 已受理（處理中） |
| 代付查詢 | 20 | 已受理；50 取消/失敗；其他已成功 |
| 代付通知 | 50 | 取消/失敗；其他成功 |
