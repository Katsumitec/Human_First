# GE-CTPAY 渠道對接需求分析

> 文檔來源：`input/project-require.md`
> 分析日期：2026-03-23

## 任務摘要表

| txn_type | 類型 | 幣別 | 關鍵規格 |
|----------|------|------|----------|
| 0121 | 代收（純卡網關，自製收銀台） | VND（704） | POST /api/transaction，返回 data.qrcode 展示 QR |
| 014d | 代收（銀行直連，自製收銀台） | VND（704） | POST /api/transaction，bank 必填，返回 data.qrcode |
| 014e | 代收（網銀掃碼，自製收銀台） | VND（704） | POST /api/transaction，bank 選填，返回 data.qrcode |
| 5210 | 代付（銀行轉帳） | VND（704） | POST /api/payment，必須簽名 |
| 0010 | 代收查詢 | — | GET /api/transaction/{out_trade_no} |
| 0050 | 代付查詢 | — | GET /api/payment/{out_trade_no} |

## 基本資訊

| 項目 | 說明 |
|------|------|
| 渠道編號 | GE |
| 渠道名稱 | CTPAY |
| 廠商名稱 | CTPAY |
| 對接群 | 『CTPAY對接群』#麥當當號 |
| 提出日期 | 2026-03-22 |
| 是否支持反查 | 不支持 |
| 回調 IP | 3.113.1.152 |

## 代收需求

### 交易類型 0121（純卡網關）

| 項目 | 說明 |
|------|------|
| 接口 URL | https://tianciv420428.com/api/transaction |
| 自製收銀台 | **是**，依 data.qrcode 在收銀台呈現 QR Code |
| 金額浮動 | **不浮動** |
| 銀行代碼 | 選填（由系統自動隨機匹配） |
| 關鍵響應欄位 | data.qrcode（QR 內容），data.uri（跳轉 URL） |

### 交易類型 014d（銀行直連）

| 項目 | 說明 |
|------|------|
| 接口 URL | https://tianciv420428.com/api/transaction |
| 自製收銀台 | **是**，依 data.qrcode 在收銀台呈現 QR Code |
| 金額浮動 | **不浮動** |
| 銀行代碼 | **必填**（`bank` 字段，如 ACB） |
| 關鍵響應欄位 | data.qrcode，data.uri |

### 交易類型 014e（網銀掃碼）

| 項目 | 說明 |
|------|------|
| 接口 URL | https://tianciv420428.com/api/transaction |
| 自製收銀台 | **是**，依 data.qrcode 在收銀台呈現 QR Code |
| 金額浮動 | **不浮動** |
| 銀行代碼 | 選填 |
| 關鍵響應欄位 | data.qrcode，data.uri |

### 代收查詢（0010）

| 項目 | 說明 |
|------|------|
| 查詢 URL | https://tianciv420428.com/api/transaction/{out_trade_no} |
| 方法 | GET |
| 狀態碼 | new / processing / verify / reject / completed / failed / refund |

## 代付需求

### 交易類型 5210（銀行轉帳）

| 項目 | 說明 |
|------|------|
| 接口 URL | https://tianciv420428.com/api/payment |
| 方法 | POST JSON |
| 必填字段 | out_trade_no, bank_id, bank_owner, account_number, amount, callback_url, sign |
| **簽名必填** | **是**（代付強制簽名） |

### 代付查詢（0050）

| 項目 | 說明 |
|------|------|
| 查詢 URL | https://tianciv420428.com/api/payment/{out_trade_no} |
| 方法 | GET |
| 狀態碼 | new / processing / reject / completed / failed / refund / verify |

## 商戶資料

| 項目 | 說明 |
|------|------|
| chnlMerId（商戶號） | vvdd222 |
| 密鑰 | **見 email**（api_token + notify_token） |
| 後台地址 | https://yd.user.3a.cash/ |
| 後台帳號 | zzzfb16888 |

## 接口 URL 配置

| 用途 | URL |
|------|-----|
| 代收請求 | https://tianciv420428.com/api/transaction |
| 代收查詢 | https://tianciv420428.com/api/transaction/{out_trade_no} |
| 代付請求 | https://tianciv420428.com/api/payment |
| 代付查詢 | https://tianciv420428.com/api/payment/{out_trade_no} |

## 安全認證機制

| 項目 | 說明 |
|------|------|
| 請求認證 | Bearer Token（Authorization: Bearer api_token） |
| 簽名算法 | MD5 |
| 簽名格式 | ksort(fields) 以 key=value&key=value 串接後直接拼接 api_token + notify_token |
| 代收請求簽名 | 選填（API 說「非必要請勿填寫」） |
| 代付請求簽名 | **必填** |
| 回調驗簽欄位 | 代收回調：4欄位（trade_no, amount, out_trade_no, state）；代付回調：同上 |
| 回調回覆 | 純文字 `ok` |

## sign.key 組成說明

```
sign.key = api_token_value + notify_token_value
（兩個值直接拼接，無分隔符號）

簽名字串 = ksort過的 key=value 串接（&分隔）+ api_token + notify_token
MD5(簽名字串) → 小寫 hex
```

## 待確認事項

1. `VerifyChannelNo=1` 是否為所有代付請求的必填欄位？（API文件未明確說明，但出現在官方簽名示例中）
2. 代收請求是否應該帶 sign？（API 說可選，建議先帶）
3. api_token 和 notify_token 的具體值 → 見 email
