# GA-GoldPay 渠道對接需求分析

> 渠道編號：GA
> 渠道名稱：GoldPay（越南）
> 提出日期：2026/3/7
> 分析日期：2026-03-10

---

## 任務摘要表

| txn_type | 類型 | 幣別 | 關鍵規格 |
|----------|------|------|----------|
| 0121 | 代收-銀行轉賬 | 704-VND | service_type=702，跳轉上游收銀台 |
| 014d | 代收-MoMo | 704-VND | service_type=420，跳轉上游收銀台 |
| 014e | 代收-ZaloPay | 704-VND | service_type=440，跳轉上游收銀台 |
| 5210 | 代付-銀行轉賬 | 704-VND | service_type=700 |
| 0010 | 代收查詢 | - | 共用查詢接口 |
| 0050 | 代付查詢 | - | 共用查詢接口 |

---

## 基本資訊

| 項目 | 值 |
|------|-----|
| 渠道編號 | GA |
| 渠道名稱 | GoldPay |
| 對接幣別 | 704-越南盾（VND） |
| 代收浮動金額 | 不浮動 |
| 是否支持反查 | 不支持 |
| 回調 IP | 52.34.55.206 |
| 簽名算法 | SHA256 |
| 請求格式 | Form（application/x-www-form-urlencoded） |
| 響應格式 | JSON |
| 通知格式 | Form（application/x-www-form-urlencoded） |

---

## 各交易類型詳細需求

### 代收（0121 - 銀行轉賬）
- service_type：702
- platform：常數 `PC`
- risk_level：常數 `1`
- 交互方式：跳轉上游收銀台（transaction_url）
- 備註：待上游調整完成後可改用 qr_image_url 自製收銀台

### 代收（014d - MoMo）
- service_type：420
- platform：常數 `PC`
- risk_level：常數 `1`
- 交互方式：跳轉上游收銀台（transaction_url）

### 代收（014e - ZaloPay）
- service_type：440
- platform：常數 `PC`
- risk_level：常數 `1`
- 交互方式：跳轉上游收銀台（transaction_url）

### 代付（5210 - 銀行轉賬）
- service_type：700
- platform：常數 `PC`
- risk_level：常數 `1`
- card_name：銀行卡姓名（ctx.accName）
- card_num：銀行卡號（ctx.accNum）
- merchant_user：銀行卡姓名（= card_name）
- mobile_no：= card_num
- 備註：實際提現金額可能與請求金額不一致

---

## 商戶資料

| 項目 | 值 |
|------|-----|
| 商戶編碼（商戶號） | llpp8888 |
| 密鑰 | *見 email* |
| 商戶後台 | https://bo.merc-mgmt.pgvn.vn-pay.co/#/login |
| 登錄帳號 | llpp8888 |

---

## 接口 URL 配置

> 注意：需求文件中的 URL 標籤有誤（代收查詢與代付提單標籤互換），以下以 API 文件為準。

| 用途 | URL |
|------|-----|
| 代收提單 | https://api.pgvn.vn-pay.co/sha256/deposit |
| 代付提單 | https://api.pgvn.vn-pay.co/sha256/withdraw |
| 訂單查詢（代收+代付共用） | https://api.pgvn.vn-pay.co/sha256/query-order |
| 餘額查詢 | https://api.pgvn.vn-pay.co/sha256/balance |

---

## 待確認事項

1. **查詢接口 trans_status 枚舉值**：API 文件中查詢響應的 `trans_status` 字段僅示例 `"completed"`，缺少完整枚舉。需向渠道方確認所有可能的狀態值（如 pending、failed 等）。
2. **通知回覆格式**：渠道要求回覆 JSON 格式 `{"status":"success","error_msg":""}`，需確認是否接受純文字 `success`。
3. **需求文件 URL 標籤錯誤**：需求文件中「代收查詢」和「代付提單」的 URL 互換了，已依 API 文件修正。
