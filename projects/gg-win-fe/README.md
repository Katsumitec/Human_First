# 專案名稱：Figma ↔ 前端 1:1 換版工作流（/ui-to-code）

> Human First · 前端應用討論會（2026.07.02）分享。把「外部設計稿」變成「可一比一落地的工程資產」——以 KR 新平台「快速換版（Reskin）」為核心。

## 基本資訊
- **團隊／負責人**：包網前端 / Satoshi
- **聯絡方式**：satoshi@katsumitec.com
- **一句話介紹**：讓每次 Figma 換版都變成機械式、可預期、可批量的動作——既有 Angular 元件 ↔ Figma 節點一對一對應，只換外觀不動功能。

## 這個專案在做什麼
- **解決的問題 / 痛點**：
  - 設計是**外部人員**，不在工程流程內，溝通成本高、迭代慢。
  - 拿到的 Figma 多是 **Sketch 轉檔**——扁平、絕對定位的圖層，缺 Auto Layout / Variables / Component+Variants / Constraints，前端只能做逆向工程。
  - 新平台核心需求是**快速換版**：同一套功能要跨多平台、多套皮膚（classic / pink / blue / green / 宇宙紫…）產線化。
- **使用者 / 適用情境**：前端切版工程師收到外部設計稿、要把新平台/新皮膚「一比一」落地時；以及設計端想知道「交稿要附什麼」才能讓前端直接開跑。

## 用了哪些 AI 工具與技術
- **AI 工具 / 模型**：Claude Code（`/ui-to-code` skill）＋ Figma MCP（get_metadata / get_screenshot / get_variable_defs 讀設計結構、視覺與變數）。
- **框架 / 技術棧**：Angular 13、TailwindCSS、SCSS 皮膚 token（`scss/skins/*`）、Apollo GraphQL；後端 PHP / ThinkPHP。
- **可重用的 SKILL / SCRIPT / prompt**：`/ui-to-code` 換版前置作業 skill（放在 `skills-scripts/`）。

## 成果與效益
- **做出了什麼**：一套「設計交付規範（給設計端 5 條）＋ `/ui-to-code` 標準工作流（給前端）」，把換版流程從人工逆向工程變成可審查、可預估工時的標準動作。實戰案例：**KRM 新手福利 · 宇宙紫換版**，設計稿 → 完成版幾乎像素對齊。
- **量化效益**：
  - **設計多花 1 分鐘結構化，前端少花 1 小時逆向工程**（間距 / token / RWD 都有依據，不必逐節點手量）。
  - 換版邊際成本遞減——節點對照表＋token 清單沉澱成資產，新平台/新皮膚可批量複用。
  - 安全性：**只動 .html / .scss、TS 不動**，功能不會被換皮改壞；真正涉及行為（C 類落差）一定停下由人把關。

## 架構簡述
- 核心模型：**Component ↔ Figma Node，一個對一個**。換版＝換「外觀＋間距＋比例」，不是換功能。
- `/ui-to-code` 是「**前置盤點＋規劃**」工具（先規劃、後動手），產出 4 大交付物 → 經使用者確認「決策 Gate」後才進實際切版。
- 落差分 **A（純外觀，繼續）/ B（結構，繼續）/ C（涉及 TS/UX，停下問人）**——這就是 Human First：判斷留給人，重複勞動交給流程。
- 詳細資料流與規範對照見 `architecture/`。

## Demo / 連結
- 簡報：`slides/`（Figma 與前端設計規範，建議匯出 PDF）
- 實戰截圖：原本 → Figma 設計稿 → 完成版 1:1 對照（見 `slides/` 與 `architecture/`）

---
### 內容物清單（依 info.md 四步驟：複製範本 → 改名 → 填 README → 放檔案）
- [x] `README.md` — 專案介紹（填表完成）
- [x] `slides/` — 投影片（Figma 與前端設計規範）
- [x] `architecture/` — 換版工作流架構與規範對照
- [x] `skills-scripts/` — `/ui-to-code` skill 使用說明
