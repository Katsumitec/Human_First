---
name: git-workflow
description: Git 工作流程助手，封裝五大流程：開分支、提交、推送（含建立MR）、合併MR、同步。不熟 Git 的人只需用自然語言操作。觸發詞：開分支、新分支、new branch、提交、commit、推送、push、送審、submit、建立MR、合併、merge、同步、sync、更新main。
---

# Git 工作流程

## 技能目標

將本專案的 Git 分支與提交規範封裝為五個子流程，使用者只需用自然語言描述意圖，由 Claude 自動執行對應的 Git 操作，並在完成後建議下一步。

## 核心規則

- `main` 為受保護分支，**禁止直接 push**
- 所有變更必須透過 Merge Request (MR) 合入
- 功能分支合入後自動刪除遠端分支
- 每位開發者有一個 `dev/<username>` **常駐分支**，作為日常工作的起點
  - 混合性、探索性的變更直接在常駐分支上進行
  - 有明確任務（新渠道對接、修 bug 等）時，才從 main 建立專用功能分支

## 分支命名規則

| 前綴 | 用途 | 範例 |
|------|------|------|
| `dev/` | 個人常駐分支，日常開發、混合性工作 | `dev/robin` |
| `feat/` | 新功能、新渠道對接 | `feat/add-channel-GH` |
| `fix/` | 修復問題 | `fix/sign-verify-error` |
| `docs/` | 文檔更新 | `docs/update-readme` |
| `refactor/` | 重構 | `refactor/rename-stress-test` |
| `chore/` | 雜項維護（技能調整、CI 設定等） | `chore/improve-skills` |

> 若使用者未明確指定類型，根據描述內容自動推斷：
> - 新渠道、新功能 → `feat/`
> - 修復、修正 → `fix/`
> - 文檔、README → `docs/`
> - 重構、重命名 → `refactor/`
> - 雜項、維護 → `chore/`

## GitLab API 操作

本專案使用 GitLab，透過 API 進行 MR 建立與合併。

### 取得 Project ID

```bash
PROJECT_ID=$(python3 -c "import urllib.parse; print(urllib.parse.quote('ll/poc/vibe-channel-dev/ll-chnl', safe=''))")
```

### API 認證

使用環境變數 `GITLAB_TOKEN`（Personal Access Token，需有 `api` scope）。
若環境中未設定，**詢問使用者提供**。

### 常用 API

- **建立 MR**：`POST /projects/:id/merge_requests`
- **合併 MR**：`PUT /projects/:id/merge_requests/:iid/merge`
- **列出 MR**：`GET /projects/:id/merge_requests?state=opened`

---

## 流程一：開新分支（new-branch）

### 觸發詞

「開分支」「新分支」「new branch」

### 需要的輸入

| 參數 | 必填 | 說明 |
|------|------|------|
| 分支類型 | 是 | `dev` / `feat` / `fix` / `docs` / `refactor` / `chore` |
| 簡短描述 | 是 | 用於組成分支名稱，例如 `add-channel-GH` |

### 執行步驟

1. **確認當前狀態**：執行 `git status` 檢查是否有未提交的變更
   - 若有未提交變更，**警告使用者**並詢問是否要先 stash 或提交
2. **同步 main**：
   ```bash
   git checkout main && git pull
   ```
3. **建立並切換到新分支**：
   ```bash
   git checkout -b <type>/<description>
   ```
4. **回報結果並建議下一步**：
   > 已切換到分支 `<branch>`，可以開始開發。
   > 開發完成後，可以執行「提交」儲存變更。

---

## 流程二：提交（commit）

### 觸發詞

「提交」「commit」

### 執行步驟

1. **檢查前置條件**：
   - 確認當前**不在 main 分支**（若在 main，提醒使用者先開分支）
   - 執行 `git status` 和 `git diff` 查看變更內容
   - 若無變更，告知使用者並結束

2. **暫存變更**：
   - 向使用者展示變更摘要（新增/修改/刪除了哪些檔案）
   - 確認後執行 `git add`（優先加入具體檔案，避免 `git add -A`）
   - **不要**加入敏感檔案（`.env`、credentials 等）

3. **建立 Commit**：
   - 根據變更內容自動草擬 commit message
   - commit message 風格參考 `git log` 最近的提交記錄
   - 向使用者確認或讓其修改
   - 執行 `git commit`

4. **回報結果並建議下一步**：
   > 已提交：`<commit message>`
   > 接下來可以「推送」將變更送到遠端並建立 MR。

---

## 流程三：推送（push + 建立 MR）

### 觸發詞

「推送」「push」「送審」「submit」「建立 MR」

### 執行步驟

1. **檢查前置條件**：
   - 確認當前**不在 main 分支**
   - 確認有尚未推送的 commit（`git log origin/<branch>..HEAD`，若分支尚未推送到遠端則跳過此檢查）
   - 若工作目錄有未提交的變更，**詢問使用者**是否要先提交

2. **推送到遠端**：
   - 判斷當前分支是否為 `dev/*` 常駐分支
   - **常駐分支**（`dev/*`）：推送時**不刪除**來源分支
     ```bash
     git push -u origin HEAD
     ```
   - **功能分支**（非 `dev/*`）：推送時標記合入後刪除來源分支
     ```bash
     git push -u origin HEAD
     ```
   - 若 push 被拒絕（遠端有新 commit），先 `git pull --rebase` 再重試

3. **透過 GitLab API 建立 MR**：
   - `source_branch`：當前分支
   - `target_branch`：`main`
   - `title`：根據 commit 記錄自動生成，或使用者指定
   - `remove_source_branch`：`dev/*` 為 `false`，其他為 `true`
   - 若已有相同來源分支的 MR 存在（透過 API 查詢），告知使用者並跳過建立

4. **回報結果並建議下一步**：
   > MR !<iid> 已建立：<url>
   > 接下來可以「合併」此 MR，或等待審核後再合併。

---

## 流程四：合併 MR（merge）

### 觸發詞

「合併」「merge」「合併 MR」

### 執行步驟

1. **查詢開啟中的 MR**：
   - 透過 GitLab API 列出 `state=opened` 的 MR
   - 若只有一個，直接使用
   - 若有多個，列出清單讓使用者選擇
   - 若沒有，告知使用者

2. **合併 MR**：
   - 透過 GitLab API 合併
   - `should_remove_source_branch`：根據分支類型判斷（`dev/*` 為 `false`，其他為 `true`）

3. **回報結果並建議下一步**：
   > MR !<iid> 已合併。
   > 接下來可以「同步」更新本地 main 並切回常駐分支。

---

## 流程五：同步（sync）

### 觸發詞

「同步」「sync」「更新 main」「清理分支」

### 執行步驟

1. **檢查當前狀態**：確認是否有未提交的變更
   - 若有未提交變更，警告使用者並詢問處理方式（stash / 提交 / 放棄）
2. **切換到 main 並拉取最新**：
   ```bash
   git checkout main && git pull
   ```
3. **清理已合併的本地分支**（不刪除 `dev/*` 常駐分支）：
   ```bash
   git branch --merged main | grep -v '^\*\|main\|dev/' | xargs -r git branch -d
   ```
4. **同步常駐分支並切回**：
   - 取得當前使用者的 `dev/<username>` 常駐分支（透過 `git config user.name` 或詢問使用者）
   - 若常駐分支已存在，rebase 到最新的 main 後切回：
     ```bash
     git checkout dev/<username> && git rebase main
     ```
   - 若常駐分支不存在，從 main 建立：
     ```bash
     git checkout -b dev/<username>
     ```
5. **回報結果**：
   > 已同步完成，目前在 `dev/<username>` 分支上。
   > （若有清理的分支）已清理分支：`<branch list>`

---

## 組合流程

使用者可能一次要求多個動作，常見組合：

| 使用者說 | 執行流程 |
|---------|---------|
| 「提交推送」「提交並送審」 | 流程二（提交）→ 流程三（推送） |
| 「推送合併」 | 流程三（推送）→ 流程四（合併） |
| 「提交推送合併」 | 流程二 → 流程三 → 流程四 |
| 「合併同步」 | 流程四（合併）→ 流程五（同步） |

依序執行，每個步驟完成後簡要回報，最後統一建議下一步。

---

## 安全守則

- **絕不**對 main 執行 `git push`
- **絕不**執行 `git push --force`（除非使用者明確要求且確認風險）
- **絕不**執行 `git reset --hard`（除非使用者明確要求）
- 有疑慮時，**先問再做**
