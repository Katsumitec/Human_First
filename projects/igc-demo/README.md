# IGC Dungeon Ruins Demo：設計到 HTML 的可行性探索

## 基本資訊

- 分享者：Erin
- 專案類型：AI 輔助 UI/UX 設計、設計到互動實作的可行性探索
- Figma 設計圖：[IGC 202605地下城遺跡 IGC DEMO](https://www.figma.com/design/iJWW8DyRluQyPrAOdMjhxH/IGC-202605%E5%9C%B0%E4%B8%8B%E5%9F%8E%E9%81%BA%E8%B7%A1--IGC-DEMO-?node-id=0-1&t=xv8Y8Ys7qxJF80eC-1)
- Demo source：[demo/](demo/)
- 原始 repo：[erinlin968/IGC-Demo](https://github.com/erinlin968/IGC-Demo)
- 投影片：[20260608_Erin_用ai輔助UIUX設計.pdf](slides/20260608_Erin_用ai輔助UIUX設計.pdf)

## 分享主旨

這個成果想分享一個願景：設計到實作可以更接近 1:1，但設計仍然源自於人類的意圖、審美判斷與 UX 判斷。AI 生成只是開始，真正讓結果成立的是人類不斷用 reference、screenshot、回饋與整理，讓畫面逐步收斂成可使用、可維護的狀態。

這不是在主張「多生成幾次就會得到好設計」，也不是已經工程化拆分完成的 skill 或公司級工作流；它比較像是一個可行性探索：如果設計師能交付包含互動、狀態、資料長度與 RWD 的 HTML demo，很多過去到實作階段才需要工程端猜測或補齊的問題，可以在設計階段就先浮現並落地。

## 專案簡介

這個成果以 IGC 地下城遺跡大廳為主題，展示如何用 AI 協助 UI/UX 設計迭代，從風格參考、元件生成、Figma 驗證，到可互動的靜態 HTML demo。

Demo 內容包含手機版遊戲大廳、搜尋、篩選、排序、底部導覽與迷你廳入口等互動狀態，用來驗證遊戲 lobby 的視覺方向、操作流程與不同狀態下的使用問題。

## 產出內容

- AI 輔助 UI/UX 設計分享投影片
- Figma 設計圖
- IGC Dungeon Ruins 靜態互動 demo
- 可延伸為設計審查、prototype 驗收與前端實作溝通素材

## 後續議題

若要實際導入公司流程，仍需要另外討論 PM 發給設計師的需求應具備到什麼程度、設計師需要補足哪些互動與實作判斷，以及團隊如何定義 demo HTML 與正式工程實作之間的責任邊界。

## Demo 預覽

Demo 是純前端靜態頁面，可以直接開啟 `demo/index.html`，或在專案資料夾啟動本機 server：

```bash
cd projects/igc-demo/demo
python3 -m http.server 8765
```

再開啟：

```text
http://127.0.0.1:8765/
```
