# Lark 自動化通知控台

> 讓 HR/行政人員透過 Web 介面管理 Lark 卡片通知，不需要直接操作 n8n 或 API。

## 基本資訊
- **團隊／負責人**：天網科技 / Joyce（行政）
- **聯絡方式**：joyce@sky-net.tw
- **一句話介紹**：選收件人、編輯卡片、按發送，Lark 通知就出去了——HR 不需要碰任何 API 或自動化工具。

## 這個專案在做什麼
- **解決的問題 / 痛點**：
  - HR 要發通知得請工程師改 n8n、或手動組 API payload，門檻高、出錯率高
  - 卡片內容每次都要重新寫，沒有統一模板管理
  - 發出去的通知無從追蹤，不知道發給誰、發了幾次
- **使用者 / 適用情境**：HR、行政人員。適合需要定期對員工發送結構化 Lark 卡片的公司（活動通知、生日賀卡、週期性提醒等）。

## 用了哪些 AI 工具與技術
- **AI 工具 / 模型**：Claude Code（協助開發與除錯）
- **框架 / 技術棧**：Node.js + Express、Lark Open API、node-cron、Render 雲端部署
- **可重用的設定範本**：`skills-scripts/automations.example.json`

## 成果與效益
- **做出了什麼**：
  - Web 控台：列出所有通知類型，點進去編輯、選收件人、一鍵發送
  - 卡片編輯器：表單模式（填欄位）與 JSON 模式（直接改卡片）雙模式，即時預覽
  - 收件人選擇器：從 Lark Bitable 撈員工清單勾選，或手動輸入 email
  - 自動排程：生日卡每天 10:00 對照 Bitable 自動發送，人工介入為零
  - 發送記錄：每筆記錄寫回 Bitable，可依通知類型、日期篩選
- **量化效益**：通知發送流程從「只有懂 API 的人才能動」變成「行政團隊任何成員都能自助操作」；工程師不再是通知發送的必要條件，行政成員有需求時直接進控台完成，無需交辦、無需等待

## 架構簡述
見 `architecture/flow.md`

三層結構：
1. **前端**（純 HTML + Vanilla JS）— 控台、編輯器、發送記錄頁
2. **後端**（Node.js + Express）— 管理 Lark Bot 憑證、路由發送請求、記錄 log
3. **外部整合**（Lark API + Bitable + n8n）— 卡片發送、員工名單來源、進階排程觸發

## Demo / 連結
- **架構圖**：[`architecture/flow.md`](architecture/flow.md)
- **設定範本**：[`skills-scripts/automations.example.json`](skills-scripts/automations.example.json)
- **原始碼**：私有 repo，有需要請聯絡 joyce@sky-net.tw

---
### 內容物清單
- [x] `architecture/` — 架構流程圖（Mermaid，GitHub 直接渲染）
- [x] `skills-scripts/` — automations.json 通用設定範本
- [ ] `slides/` — 暫無
