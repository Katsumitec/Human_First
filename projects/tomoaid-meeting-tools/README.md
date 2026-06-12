# 專案名稱：TomoAid Meeting Tools — 會議錄音 → 具名會議記錄

> Claude Code plugin：把會議錄音變成「知道誰說了什麼」的結構化會議記錄，全程在 Claude Code 裡一句指令完成。

## 基本資訊
- **團隊／負責人**：TomoAid / cave
- **聯絡方式**（Email / GitHub）：cave@tomoaid.com / [tomoaid/claude-plugin](https://github.com/tomoaid/claude-plugin)
- **一句話介紹**：錄音檔丟進去，產出具名（Alice/Bob，不是 SPEAKER_00）逐字稿與含 Action Items 的會議記錄 .md。

## 這個專案在做什麼
- **解決的問題 / 痛點**：
  - 一般轉錄工具的逐字稿沒有 speaker、整段混在一起——誰說的、誰答應的，事後對不回去
  - 專有名詞（人名、產品名、客戶代號）常被 ASR 聽錯
  - 會後人工整理會議記錄、收斂 Action Items 很花時間
- **使用者 / 適用情境**：用 Claude Code 的團隊。例會、kickoff、客戶會議的錄音 → 結構化會議記錄；Action Items 直接對到人，會後可直接開單指派任務。

## 用了哪些 AI 工具與技術
- **AI 工具 / 模型**：Claude Code（plugin / SKILL）、OpenAI whisper-1 與 gpt-4o-transcribe（ASR）、pyannote.ai（diarization 與 voiceprint 聲紋識別）
- **框架 / 技術棧**：Python（僅標準庫，免 pip install）+ ffmpeg + curl；Claude Code plugin（2 個 skill + 6 支 script）
- **可重用的 SKILL / SCRIPT / prompt**：都在原 repo，安裝 plugin 即可直接使用（見下方專案位置），此處不重複放

## 成果與效益
- **做出了什麼**：兩個 slash command
  - `/tomoaid:voiceprint-setup`：一段多人會議錄音 → diarization 自動切出每位 speaker 樣本 → 本地網頁試聽標人名 → 建立全團隊聲紋庫（一次建好，之後重複用）
  - `/tomoaid:meeting-notes`：錄音 → 聲紋識別具名逐字稿（含時間戳）→ 清理贅詞/ASR 幻覺 → 會議記錄 .md（決策、Action Items、Open Questions）
- **量化效益**：一場一小時會議的逐字稿＋會議記錄，從人工數小時縮短為一句指令、等數分鐘；API 成本約一次 pyannote diarization/identify job + 一小時 whisper-1 轉錄。詞彙表 priming 大幅減少專有名詞聽錯，speaker 識別錯誤標注（而非亂猜），人只需 review 不確定點清單。

## 架構簡述
- 錄音檔兩路並行處理：**pyannote.ai `/v1/identify`** 用團隊聲紋庫認出「誰、何時說話」；**OpenAI whisper-1**（帶詞彙表 priming）轉出「說了什麼」（含 segment 時間戳）→ 官方 segment-level **max-overlap 合併** → 清理（贅詞、無語音區段的 ASR 幻覺標注、錯字）→ 會議記錄 .md。長音檔自動切段、上下文跨段傳遞。流程圖見 `slides/` 簡報第 3 頁。
- 隱私：音檔會送 OpenAI 與 pyannote.ai（暫存 48 小時自動刪除）；voiceprint 是不可逆 feature vector，無法還原成原音。

## Demo / 連結
- 簡報：[`slides/tomoaid-meeting-tools-intro.pdf`](slides/tomoaid-meeting-tools-intro.pdf)（HTML 原始檔同資料夾，瀏覽器開啟可放映）
- **專案位置（想用的人直接裝）**：https://github.com/tomoaid/claude-plugin

  ```
  /plugin marketplace add tomoaid/claude-plugin
  /plugin install tomoaid@tomoaid
  ```

  需求：`OPENAI_API_KEY`、`PYANNOTEAI_API_KEY`、ffmpeg、Python 3.10+（免 pip install）。
  第一次先跑 `/tomoaid:voiceprint-setup` 建聲紋庫，之後每場會議一句 `/tomoaid:meeting-notes <錄音檔>`。

---
### 內容物清單
- [x] `slides/` — 投影片（PDF + HTML 原始檔）
- [ ] `architecture/` —（略，流程圖在簡報內，完整說明見原 repo README）
- [ ] `skills-scripts/` —（略，SKILL 與 script 安裝原 repo plugin 即可取得）
