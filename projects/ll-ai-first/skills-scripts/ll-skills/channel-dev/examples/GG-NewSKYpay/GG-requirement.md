# GG-NewSKYpay 對接需求分析

## 任務摘要

| txn_type | 類型 | 幣別 | 自製收銀台 | 浮動金額 | 備註 |
|----------|------|------|-----------|---------|------|
| `0121` | 代收（網銀類，跳轉/收銀台） | VND | 視 API 文件決定 | 否 | payType=1060 |
| `014d` | 代收（H5/掃碼類） | VND | 是（顯示 qrCode 字符串） | 否 | payType=1060 |
| `014e` | 代收（H5/掃碼類） | VND | 是（顯示 qrCode 字符串） | 否 | payType=1060 |
| `0010` | 代收訂單查詢 | VND | — | — | — |
| `5210` | 代付 | VND | — | — | — |
| `0050` | 代付訂單查詢 | VND | — | — | — |
| `0098` | **渠道反查回調**（上游建單後回調我方反查訂單存在性） | VND | — | — | **使用者明確要求；反查不驗簽** |

---

## 基本資訊

| 項目 | 值 |
|------|-----|
| 渠道編號 | `GG` |
| 渠道名稱 | NewSKYpay |
| 廠商 TG 群 | NewSKY-lv7688-0.55%+0 / #麥當當號 |
| 對接貨幣 | VND（704） |
| 對接方式 | API（POST，application/json;charset=UTF-8） |
| 是否支援反查 | 不支援標準機制 → **客製建立 0098 反查接口** |
| 商戶後台 | http://sys.newsky.vip（帳號 lv7688，密碼見 email） |
| 商戶編號 | `30038` |
| 簽名密鑰 | 見 email |

---

## 接口 URL 配置

| 用途 | 端點 |
|------|------|
| 代收下單 | `POST http://api.newsky.vip/hpay/dt/vnd/ct` |
| 代收查單 | `POST http://api.newsky.vip/hpay/dt/vnd/query` |
| 代付下單 | `POST http://api.newsky.vip/hpay/wd/vnd/ct` |
| 代付查單 | `POST http://api.newsky.vip/hpay/wd/vnd/query` |
| 商戶餘額查詢 | `POST http://api.newsky.vip/hpay/merchant/balance` |
| API 文檔 | http://18.163.184.55/doc |

---

## 各交易類型詳細需求

### 代收（0121 / 014d / 014e）

- **必填參數**：
  - `payType`：固定傳 `1060`
  - 會員 ID：傳隨機值（依 API 必填要求採 `rand.*` 或具體欄名待定）
- **響應收銀台欄位**：
  - `data.payAmount`：金額
  - `data.qrCode`：二維碼字符串（用於我方自製收銀台展示）
- **金額**：不浮動（需在 `txn_notify.ftl` 中校驗）
- **收銀台類型**：因響應為 `qrCode 字符串`（非 URL），需我方自製收銀台渲染 QR Code 給用戶掃碼。
  - 0121 / 014d / 014e 皆走 `PayV5Mode1 + commonTrans + Redirect`（自製收銀台）。
  - `casher.url` 配置至 `*` × 對應 `txn_type`。

### 代付（5210）

- **特殊規則：上游反查機制**
  - 上游收到代付建單後，會「**回調反查**」我方系統，確認該訂單存在。
  - 我方需建立 0098 交易類作為反查回調接口的處理類（見下方 0098 規格）。

### 訂單查詢（0010 / 0050）

- 端點：`/hpay/dt/vnd/query`（代收）/ `/hpay/wd/vnd/query`（代付）
- 簽名規則待 Step 2 API 文件分析確認。

### 0098 反查回調（使用者明確指示）

- **svc_addr**：`com.icpay.payment.service.channel.common.PayV3Mode1`
- **svc_invoke**：`convResult`
- **svc_interactive**：依 PayV3Mode1 預設（`Async`），但實際對外仍是同步回應 OK / ERROR。
- **ext_config**：
  ```json
  {
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "chnlReqMethod": "POST",
    "templateNamePrefix": "0098_"
  }
  ```
- **模板**：`0098_txn_notify.ftl`，職責：
  1. 用 `svc.queryOrderByChnlOrderIdWithAmt(ctx.merOrderId, ctx.amount)` 比對訂單存在 + 金額一致；
  2. 結果 `0000` → 回 `OK`，否則 `ERROR`；
  3. `respContentType: text/plain`（純文字回應）。
- **不驗簽**：
  - `sign.action.notify.check = 0`
  - `sign.action.notify.check.by.template = 0`

> **0098 與 5210 的關聯**：上游在收到代付（5210）建單後，會回調本反查接口（路由由系統依 channel + intTxnType 判定）。實際反查接口的「我方對外 URL」需等系統部署或聯調時確認；此處先按既定規格建模板與配置。

---

## 商戶資料

| 欄位 | 值 |
|------|-----|
| `mchnt_cd`（商戶碼） | 待補（聯調對接時確定我方賦予該客戶的商戶碼） |
| 上游商戶號 `chnlMerId` | `30038` |
| 簽名密鑰 | 見 email（先以佔位符 `(KEY)` 寫入 SQL，上線前替換） |
| 後台 URL | http://sys.newsky.vip |

---

## 回調 IP 白名單

| IP |
|----|
| 18.163.181.38 |
| 43.199.133.253 |
| 43.199.58.235 |
| 95.40.139.72 |
| 18.162.79.67 |
| 18.166.1.107 |
| 18.166.44.1 |

---

## 待確認事項（聯調前需釐清）

1. **API 文件實際內容**：簽名演算法（MD5 / SHA256 / 其他）、欄位排序規則、密鑰拼接方式（`&key=` 或直接拼接）、字符串連接符、是否含欄位名。
2. **代收響應結構巢狀層級**：`data.payAmount`、`data.qrCode` 已知是 2 層巢狀，需在 `txn_sync_resp.ftl` 加 `<#if>` 分支（成功取 `ctx.data.qrCode`，失敗只回 `txnStatus=01` 處理中）。
3. **代付響應/通知欄位**：完整欄位需 Step 2 從 API 文件擷取。
4. **狀態碼定義**：成功碼、失敗碼、處理中碼，分別需映射至 `PAY_NOTIFY` / `PAY_QRY` / `WITHDRAW` / `WITHDRAW_NOTIFY` / `WITHDRAW_QRY`。
5. **0098 反查接口 URL**：上游配置反查地址時應指向我方哪個路由？（待聯調釐清，通常為 `gateway-onl/notifyService/{channel}/{intTxnType}` 之類，由 0098 服務配置處理）。
6. **会员ID 欄位名**：API 文件中對應欄位名待確認，目前以 `rand.getInt(10000,99999)` 或 `rand.getStr(8)` 暫代。
7. **付類查詢類型 `chnl.qryType`**：API 文件可能要求查詢時帶特定 type，待確認。

---

## 實作策略

1. 先依本需求文件建立基礎配置（configs / params / responses / templates）；
2. Step 2 完成 API 文件擷取後，針對：
   - 簽名規則（MD5/SHA256、key 拼接、欄位順序）
   - 響應欄位實際結構
   - 狀態碼映射
   逐一精修；
3. 使用者後續會提供「實際上線內容」作為最終調校材料來源。
