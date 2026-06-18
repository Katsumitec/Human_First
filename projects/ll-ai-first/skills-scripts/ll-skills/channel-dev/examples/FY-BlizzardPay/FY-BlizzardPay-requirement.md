# FY-BlizzardPay 開發需求分析

> 提出日期：2026-02-25
> 分析日期：2026-02-25
> 渠道編號：FY
> 渠道名稱：BlizzardPay（暴雪支付）

---

## 任務摘要

| 交易類 | 類型 | 幣別 | 關鍵參數/規格 | 補充說明 |
|--------|------|------|---------------|----------|
| 0121 | 代收（銀行轉賬） | VND | channelId=110、跳轉類（payUrl）、固定金額 | 越南一類私戶銀行轉賬 |
| 5210 | 代付 | VND | POST /withdraw/apply、bankName + bankCard | 越南銀行代付，銀行編碼待確認 |

---

## 一、渠道基本資訊

| 項目 | 內容 |
|------|------|
| 渠道編號 | FY |
| 渠道名稱 | BlizzardPay（暴雪支付） |
| TG 對接群 | 🇻🇳 10977 NTDV458 - blizzardpay 【暴雪 XPay】越南一類私戶 #麥當當號 |
| 接口 URL | `http://api.blizzardpay.pw` |
| 對接文檔 | blizzardpay-api.docx / [Google Docs](https://docs.google.com/document/d/18VlIUs9N8Uj3LUVcjgZgTv4jrWGso46BZvb7Tvwt_Xw) |

---

## 二、對接交易類型

### 2.1 交易類 0121 — 代收（銀行轉賬）

| 項目 | 內容 |
|------|------|
| 交易類型 | 0121 銀行轉賬 |
| 接口分類 | 跳轉類代收（響應含 `payUrl` 跳轉地址） |
| 渠道通道編號 | channelId = `110`（越南-銀行轉賬） |
| 接口 URL | `POST http://api.blizzardpay.pw/order/v2/create` |
| 對接貨幣 | 704 - VND（越南盾） |
| 是否浮動金額 | **否**（廠商有支援浮動金額，但運營不允許） |
| 是否需要自定義收銀台 | 否（渠道返回 payUrl 跳轉至渠道收銀台） |
| Content-Type | `application/x-www-form-urlencoded` |
| 簽名算法 | MD5（非空參數按 ASCII 排序 + `&key={密鑰}`） |

**代收下單必填參數**：

| 參數 | 說明 | 備註 |
|------|------|------|
| appId | 商戶號 | 10977 |
| outTradeNo | 商戶訂單號 | — |
| channelId | 通道編號 | 固定 `110` |
| amount | 金額 | 單位元，保留 2 位小數 |
| callbackUrl | 異步回調地址 | — |
| successUrl | 支付成功跳轉 URL | — |
| clientUserIp | 下單用戶 IP | — |
| clientUserId | 用戶唯一標識 | 最大 32 位，可用用戶 ID 的 MD5 |
| sign | 簽名 | — |

**代收回調關鍵字段**：

| 字段 | 說明 |
|------|------|
| payStatus | `SUCCESS` 代表成功 |
| amount | 訂單創建金額 |
| amountTrue | 用戶真實付款金額（需比對是否一致） |
| 回覆格式 | 純文字 `SUCCESS` |

**代收訂單查詢**：
- URL：`GET http://api.blizzardpay.pw/order/query`
- 參數：appId + outTradeNo + sign
- 成功判斷：`data.paySuccess = true`

---

### 2.2 交易類 5210 — 代付

| 項目 | 內容 |
|------|------|
| 交易類型 | 5210 代付 |
| 接口分類 | 代付類（請求含目的地帳號、收款人姓名等出金資訊） |
| 接口 URL | `POST http://api.blizzardpay.pw/withdraw/apply` |
| 對接貨幣 | 704 - VND（越南盾） |
| Content-Type | `application/x-www-form-urlencoded` |
| 簽名算法 | MD5（非空參數按 ASCII 排序 + `&key={密鑰}`） |

**代付發起必填參數**：

| 參數 | 說明 | 備註 |
|------|------|------|
| appId | 商戶號 | 10977 |
| outOrderNo | 商戶訂單號 | — |
| amount | 提現金額 | 保留 2 位小數 |
| bankName | 銀行代碼簡稱 | ⚠️ 越南銀行編碼待確認（見待確認事項） |
| bankBranch | 開戶行 | 沒有時傳空字符串 |
| bankUserName | 收款人姓名 | — |
| bankCard | 銀行卡號 | — |
| currency | 貨幣編碼 | `VND` |
| callbackUrl | 代付回調地址 | 選填 |
| sign | 簽名 | — |

**代付回調關鍵字段**：

| 字段 | 說明 |
|------|------|
| orderStatus | `0`=未處理、`1`=已打款、`2`=駁回、`3`=處理中 |
| message | 失敗原因（駁回時返回） |
| 回覆格式 | 純文字 `SUCCESS` |

**代付訂單查詢**：
- URL：`GET http://api.blizzardpay.pw/withdraw/query`
- 成功判斷：`data.orderStatus = 1`

---

## 三、通用技術規格

| 項目 | 內容 |
|------|------|
| 通信協議 | HTTP（非 HTTPS） |
| 報文格式 | 請求：`application/x-www-form-urlencoded` / 響應：JSON |
| 身份驗證 | 商戶號（appId）+ 密鑰（key） |
| 簽名算法 | MD5 |
| 簽名規則 | 非空參數按 ASCII 排序 → `key1=value1&key2=value2&...&key={密鑰}` → MD5 |
| 成功狀態碼 | code = 200 |
| 回調回覆 | 純文字 `SUCCESS` |
| 是否支持反查 | **不支持** |
| 回調 IP | `8.222.131.138` |

---

## 四、商戶資料

| 項目 | 內容 |
|------|------|
| 商戶編碼（商戶號） | 10977 |
| 密鑰 | **見 email** |
| 商戶後台 | http://user.blizzardpay.pw/#/login |
| 登錄帳號 | NTDV458 |
| 密碼 | **見 email** |
| 接口 URL | http://api.blizzardpay.pw |
| 回調 IP | 8.222.131.138 |

---

## 五、待確認事項

1. **⚠️ 越南銀行代碼（代付用）**：原始 API 文檔第 9.2 節「越南銀行代碼」標題存在但內容為空，未列出具體的越南銀行編碼清單。需向渠道方（暴雪支付）確認越南代付所使用的銀行代碼列表（bankName 參數值）。

2. **⚠️ 交易類 5210 對應的渠道通道編號**：代付接口請求參數中不需要 channelId，但需確認是否有特定的代付通道限制或配置。

3. **⚠️ 通信協議為 HTTP**：接口 URL 使用 HTTP（非 HTTPS），安全性較低，需評估是否符合公司安全規範或是否需要額外的安全措施。

4. **⚠️ 代付發起接口響應報文**：原始文檔中代付發起接口（/withdraw/apply）的響應報文欄位未詳細列出，需向渠道方確認或在聯調時驗證。
