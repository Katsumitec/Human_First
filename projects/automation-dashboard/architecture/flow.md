# 自動化通知控台 — 架構流程圖

## 系統架構

```mermaid
graph TD
    subgraph 前端 Web UI
        A[控台首頁<br/>通知列表]
        B[卡片編輯器<br/>表單 / JSON 雙模式]
        C[發送記錄頁]
    end

    subgraph 後端 Node.js + Express
        D[API Server]
        E[Cron Scheduler<br/>node-cron]
    end

    subgraph Lark 生態
        F[Lark Open API<br/>卡片發送]
        G[Lark Bitable<br/>員工名單 / 發送 log]
    end

    H[n8n<br/>進階自動化 webhook]
    I[員工 / 收件人<br/>收到 Lark 卡片]

    A --> B
    B -->|發送請求| D
    C -->|查詢 log| D
    D -->|送出卡片| F
    D -->|觸發 webhook| H
    D -->|讀員工清單| G
    D -->|寫發送 log| G
    E -->|每日定時觸發| D
    F -->|Lark 推送| I
    H -->|進階流程| I
```

## 資料流說明

| 操作 | 路徑 |
|------|------|
| HR 手動發送 | 前端 → API Server → Lark API → 員工 |
| 活動通知（含 webhook）| 前端 → API Server → n8n → Lark API → 員工 |
| 生日卡自動排程 | Cron 10:00 → 讀 Bitable 生日欄位 → Lark API → 員工 |
| 發送記錄查詢 | 前端 → API Server → Bitable |

## 部署說明

- **平台**：Render（Web Service，Node.js）
- **啟動指令**：`npm start`
- **環境變數**：Bot 憑證、Session secret、登入密碼均存於 Render 環境變數，不進 git
- **自動部署**：push 到 main branch 即觸發重新部署
