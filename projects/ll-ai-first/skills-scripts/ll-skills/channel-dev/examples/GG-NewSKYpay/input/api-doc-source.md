# API 文件來源

## 主要 API 文檔站點

- **URL**：http://18.163.184.55/doc
- **類型**：網頁式 API 文檔站（多頁面導覽）

## 必須擷取的子頁面

依需求文件，至少需涵蓋以下接口：

- 代收：下單、查單、反查（商戶反查接口）
- 代付：下單、查單
- 商戶餘額查詢

## 已知接口端點（來源：Issue #2 商戶資料）

| 用途 | 端點 |
|---|---|
| 代收下單 | `POST http://api.newsky.vip/hpay/dt/vnd/ct` |
| 代收查單 | `POST http://api.newsky.vip/hpay/dt/vnd/query` |
| 代付下單 | `POST http://api.newsky.vip/hpay/wd/vnd/ct` |
| 代付查單 | `POST http://api.newsky.vip/hpay/wd/vnd/query` |
| 商戶餘額查詢 | `POST http://api.newsky.vip/hpay/merchant/balance` |
| 反查（商戶反查接口） | 見 API 文檔「代收接口 → 反查商戶接口」 |

## 擷取要求

- 用 `agent-browser` 開啟主頁，截圖並抓取所有導覽連結
- 將所有子頁面 URL 寫入 `input/api-doc-urls.md`
- 逐一擷取每頁完整內容（請求/響應欄位、簽名規則、狀態碼）
