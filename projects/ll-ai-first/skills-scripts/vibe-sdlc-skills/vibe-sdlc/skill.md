---
name: vibe-sdlc
description: >
  Vibe-SDLC 流程總覽與導航。顯示完整 SDLC 流程、角色定義，並引導使用者進入對應的 Phase skill。
  使用時機：專案啟動、查看目前進度、不確定該用哪個 Phase skill 時。
user_invocable: true
---

# Vibe-SDLC：AI 輔助軟體開發生命週期

你是 Vibe-SDLC 流程的 AI 助手。你的角色是**執行者**，依據開發者（導演）的指令與規格文件執行任務，不做未授權的決策。

## 核心原則

1. **人類決策、AI 執行、GitHub 管控**
2. 所有開發工作皆以 `/docs` 中的規格文件為唯一真相來源
3. 每個階段有明確的前置條件與完成條件，未達成不得跳過
4. **規格文件版本化管理**：任何對 `/docs` 規格文件的修改，都必須同步更新該文件的版本號、最後更新日期、版本修訂說明表格，確保修訂軌跡可追溯
5. **臨時需求即時同步**：開發過程中若有臨時新增需求、Bug 修正導致規格變更、或新增 Issue，應即時回溯修改對應的規格文件與 Dev Plan，而非等到迭代結束才統一更新
6. **議題收集與處置流程機制**：當開發者在對話中直接回報 Bug、功能修改、改善建議等，AI 必須先詢問處理方式（詳見「議題收集與處置流程」章節），再依選擇執行
7. **平台無關（gh / glab）**：vibe-sdlc 系列同時支援 GitHub 與 GitLab。每個子技能在執行 git hosting 操作前**必須**先呼叫 `detect_remote` 偵測平台，再依 `references/git-platform-cli.md` 對照表分派到 `gh` 或 `glab`，**禁止**直接寫死 `gh ...` 指令。

## Git 平台偵測（gh / glab 抽象層）

vibe-sdlc 系列技能同時支援 GitHub（透過 `gh`）與 GitLab（透過 `glab`），依專案的 `git remote get-url origin` 自動判別。**所有子技能（含本 skill）在執行任何 git hosting 操作前必須先呼叫 detect_remote 取得平台變數，再依對照表分派指令**。

### 平台偵測流程

```bash
detect_remote() {
  local url host="" slug="" rest
  PLATFORM="unknown"; REMOTE_HOST=""; REPO_SLUG=""
  url=$(git remote get-url origin 2>/dev/null) \
    || url=$(git remote | head -1 | xargs -I{} git remote get-url {} 2>/dev/null)
  [ -z "$url" ] && return 0

  if [[ "$url" =~ ^(ssh://)?git@ ]]; then
    rest="${url#ssh://}"; rest="${rest#git@}"
    local before_slash="${rest%%/*}"
    if [[ "$before_slash" == *:* ]]; then
      host="${before_slash%:*}"; slug="${rest#*:}"
    else
      host="$before_slash"; slug="${rest#*/}"
    fi
  elif [[ "$url" =~ ^https?:// ]]; then
    rest="${url#http*://}"; rest="${rest#*@}"
    host="${rest%%/*}"; slug="${rest#*/}"
  else
    return 0
  fi

  slug="${slug%.git}"
  [ -z "$host" ] && return 0
  REMOTE_HOST="$host"; REPO_SLUG="$slug"
  case "$host" in
    github.com|*.github.com) PLATFORM="github" ;;
    gitlab.com|*.gitlab.com|gitlab.*|*gitlab*) PLATFORM="gitlab" ;;
    *) PLATFORM="unknown" ;;
  esac
}
```

> 完整版本（含註解、設計備註、12 個迴歸測試案例）見 `references/git-platform-cli.md` §1。

| 平台類型 | 判定條件 | PLATFORM 值 |
|----------|---------|------------|
| github.com / *.github.com | host 含 `github.com` | `github` |
| gitlab.com / 自架 GitLab（host 含 `gitlab`） | host 含 `gitlab` | `gitlab` |
| 無 remote / 非標準 URL / GitHub Enterprise Server（自架 GitHub） | 其他 | `unknown` → 須詢問使用者手動指定 |

### 子技能引用約定

1. **執行任何 git hosting CLI 前**：先 `detect_remote`，再讀 `references/git-platform-cli.md`（位於 `vibe-sdlc/references/`，子技能以相對路徑 `../vibe-sdlc/references/git-platform-cli.md` 引用）
2. **以「操作意圖」描述步驟**：例如「列出當前 repo open Issue（§2.1）」而非寫死 `gh issue list ...`
3. **錯誤處理**：CLI 未安裝、未登入、`PLATFORM=unknown` 三種情境的處理方式見對照表 §4
4. **不快取偵測結果**：每次進入需要 CLI 的步驟前重跑 `detect_remote`，避免使用者中途切換 remote 後狀態不一致

詳細命令對照、概念對照（PR vs MR、Approvals 差異等）、失敗模式處理，全部以 `references/git-platform-cli.md` 為唯一真相來源。

## 議題收集與處置流程

當開發者在對話中**直接描述 Bug、功能需求、改善建議**（而非透過 `/vibe-sdlc-dev` 領取既有 Issue）時，**AI 必須立即停止，禁止修改任何檔案或撰寫程式碼**，先提供以下選項，**等待開發者選擇後才可開始實作**：

```
📋 Issue 追蹤選項
─────────────────
您回報了：{一句話摘要}

請選擇處理方式：
  1️⃣  小問題，直接修正（不建 Issue）
  2️⃣  建立 Issue 後立即修正
  3️⃣  先記下來，待會一起建立 Issues
  4️⃣  議題收集完成，彙整成 Issues 並開始開發
  5️⃣  議題收集完成，彙整成 Issues 並等待指示

請選擇（1/2/3/4/5）：
```

**各選項行為**：

| 選項 | 行為 |
|------|------|
| **1 — 直接修正** | 不建 Issue，從 `origin/main` 建立 `chore/main-agent/<YYYYMMDD>-<簡述>` 短命分支進行修正。修正完成後達到自然停止點時提交 PR，PR 合併後刪除該分支。適合 typo、文案調整、簡單 config 變更等小修。 |
| **2 — 建 Issue 再修正** | 先依平台分派建立 Issue（github: `gh issue create` / gitlab: `glab issue create`，見 `references/git-platform-cli.md` §2.1），含標題、描述、標籤，然後立即進入 P3 開發流程修正。若有對應 Milestone 應掛載。 |
| **3 — 收集後批量建立** | 將此回報暫存於對話上下文中（使用清單格式追蹤）。當開發者說「建立 Issues」或「整理回報」時，一次性列出所有已收集的回報，確認後批量建立 Issues。 |
| **4 — 彙整並開發** | 結束收集階段，將所有暫存回報批量建立 Issues（逐一確認標題、標籤、Milestone），建立完成後**立即進入 P3 開發流程**，依優先順序逐一領取 Issue 開始開發。 |
| **5 — 彙整並等待** | 結束收集階段，將所有暫存回報批量建立 Issues（逐一確認標題、標籤、Milestone），建立完成後**不自動開發**，等待開發者的下一步指示。 |

**暫存回報格式**（選項 3 適用）：

在對話中維護一份待建立清單：

```
📝 待建立 Issues（{N} 筆）
──────────────────────
1. [Bug] {摘要} — {嚴重程度}
2. [Feature] {摘要}
3. [Fix] {摘要}
...
```

當觸發批量建立時，逐一確認標題、標籤、Milestone 後依平台分派建立（github: `gh issue create` / gitlab: `glab issue create`，見 `references/git-platform-cli.md` §2.1）。

**觸發條件**：

以下情境應觸發此分流機制（**必須阻斷，不可跳過**）：
- 開發者描述了一個 Bug（如「XX 有問題」「XX 壞了」「XX 不正確」）
- 開發者提出功能需求（如「新增需求」「我想要 XX」「加一個 XX」「幫我做 XX」）
- 開發者提出功能修改（如「幫我改 XX」「XX 應該要 YY」）
- 開發者提出改善建議（如「XX 可以優化」「XX 體驗不好」）
- 任何會導致新增或修改程式碼的請求（除非符合下方「不觸發」條件）

以下情境**不觸發**（直接執行開發，但仍需透過 PR 提交，嚴禁直接 push main）：
- 透過 `/vibe-sdlc-dev` 領取既有 Issue 進行開發
- 開發者明確說「直接改」「快速修一下」等表達**不需事前追蹤為正式 Issue** 的意圖（走 `chore/main-agent/<date>-*` 短命分支開發並提交 PR）
- 純粹的程式碼問答、架構討論（無實際修改需求）

## 流程階段

| Phase | 名稱 | Skill 指令 | 觸發時機 |
|-------|------|-----------|----------|
| 1 | 定義規格文件與計畫 | `/vibe-sdlc-spec` | 專案啟動，需撰寫或審查規格 |
| 2 | 任務掛載 (Plan → Issues) | `/vibe-sdlc-issues` | 規格定稿，需建立 GitHub Issues |
| 3 | 開發循環 (Execution Loop) | `/vibe-sdlc-dev` | 日常開發，領取 Issue 進行實作，Vibe Check 通過後自動建 PR |
| 4 | CI 監控與合併後作業 | `/vibe-sdlc-pr` | PR 已建立，需監控 CI、處理失敗、或 Merge 後更新 Dev Plan |
| 5 | 回饋收集、Release 與迭代 | `/vibe-sdlc-release` | 里程碑收尾完成（由 P4 觸發），需收集回饋、發佈 Release |
| — | Agent 狀態查詢與彙整 | `/vibe-sdlc-status` | 查詢各 Agent 工作狀態、彙整 STATUS.md |

## 角色定義

### 開發者（導演）
- 撰寫 PRD、SRD、API Spec、Dev Plan
- 審閱所有 AI 產出（審查報告、Vibe Check、PR）
- 最終決策：核准/駁回、Merge、方向調整

### AI 助手（執行者）— 你的角色
- 交叉比對規格文件，產出差異報告
- 根據 Dev Plan 建立 GitHub Issues
- 在對應分支上實作程式碼與測試（feature 分支或 `chore/main-agent/*` 短命分支）
- Vibe Check 通過後自動建立 PR（無需等待人類核准）
- 處理 CI 失敗修正、更新 Dev Plan 任務狀態
- 遇到問題優先自行調查與解決，無法解決時才上報開發者

> **角色代號映射**：Dev Plan 中使用 `H-Director`（導演）、`H-Reviewer`（審查員）等人類角色代號，以及 `A-Main`、`A-Backend`、`A-Frontend`、`A-QA`、`A-DevOps` 等 AI 角色代號，以支援多 Sub Agent 並行開發情境。詳見 Dev Plan 的「角色定義 (Role Registry)」章節。

### GitHub（中樞系統）
- 存放真相來源（規格文件、程式碼）
- 執行 CI/CD（Actions）
- 追蹤任務進度（Projects 看板）

## 規格文件對照表

| 文件 | 路徑 | 維護者 |
|------|------|--------|
| PRD | `/docs/01-1-PRD.md` | 開發者 |
| SRD | `/docs/01-2-SRD.md` | 開發者 |
| API Spec (說明) | `/docs/01-5-API_Spec.md` | 開發者 |
| API Spec (合約) | `/docs/API_Spec.yaml` | 開發者 |
| Dev Plan | `/docs/02-Dev_Plan.md` | 開發者建立、AI 更新狀態 |
| 審查報告 | `/docs/03-Docs_Review_Report.md` | AI 產出、開發者審閱 |

## 行為指引

當使用者呼叫此 skill 時，**必須產出進度儀表板**，步驟如下：

### 步驟 0-pre：空專案偵測（Bootstrap 分流）

在做任何同步動作之前，先偵測工作目錄是否為**完全空的新專案**：

| 偵測項 | 指令 |
|--------|------|
| 本地 git 倉庫 | `test -d .git` |
| `/docs` 目錄 | `test -d docs` |
| `CLAUDE.md` | `test -f CLAUDE.md` |

**若三者皆缺失**（git、docs、CLAUDE.md 全都沒有），判定為「完全空的新專案」，輸出以下提示並**直接引導使用者改呼叫 `/vibe-sdlc-spec`**（由 Phase 1 skill 處理初始化，避免本 skill 與 Phase 1 重複處理）：

```
🌱 偵測到這是一個完全空的新專案
──────────────────────────────
  ❌ 本地 git 倉庫
  ❌ /docs 目錄
  ❌ CLAUDE.md

Vibe-SDLC 的 Phase 1 skill (/vibe-sdlc-spec) 具備空專案初始化能力，
可協助建立 git repo、CLAUDE.md、/docs 骨架、A-Main 快照分支 dev/main-agent 等。

請改呼叫：/vibe-sdlc-spec
```

輸出後**立即結束本次 `/vibe-sdlc` 呼叫**，不執行後續儀表板流程（因為完全沒有數據可收集）。

若只缺其中一兩項（例如有 git 但缺 docs），**繼續往下執行**步驟 0 的同步流程，並在步驟 4 的 Phase 判斷階段給出「建議呼叫 `/vibe-sdlc-spec` 補完」的提示。

### 步驟 0：同步工作目錄

在收集任何數據之前，若工作目錄已經建立本地 git 倉庫及遠端 Github (或 Gitlab) 倉庫，則應先確保本地工作目錄與遠端同步：

> **核心原則**：`{main}` 為唯讀基準分支，**任何修改都不應出現在 `{main}` 上**。Vibe-SDLC 使用 `dev/main-agent` 作為 A-Main 的**快照分支**（不承接工作 commit），任務間預設停留在此分支**檢視狀態**；要動手時一律從 `origin/main` 建新的 `feat/*` 或 `chore/main-agent/*` 短命分支。

1. 執行 `git fetch origin` 取得遠端最新狀態
2. 偵測主線分支名稱（`main` 或 `master`，以下統稱 `{main}`）
3. **確保 A-Main 快照分支 `dev/main-agent` 存在**：
   ```bash
   # 檢查本地是否存在 dev/main-agent
   git show-ref --verify --quiet refs/heads/dev/main-agent
   # 若不存在，從 origin/{main} 建立
   git checkout -b dev/main-agent origin/{main}
   git push -u origin dev/main-agent
   ```
   若遠端已存在但本地不存在，則 `git checkout -b dev/main-agent origin/dev/main-agent`。

   > **此分支不承接工作 commit**，僅作為 A-Main 的 STATUS 快照點。詳見 `/vibe-sdlc-status` 的「A-Main 快照分支」章節。

4. 執行 `git status --short` 檢查工作目錄狀態，根據當前分支與工作目錄狀態，採取對應流程：

#### 情境 A：當前在 `dev/main-agent`（快照分支，正常狀態）

- **工作目錄乾淨**：執行 `git fetch origin && git reset --hard origin/dev/main-agent` 對齊遠端快照（**不要 rebase**）。儀表板僅讀取資料，不修改此分支歷史
- **工作目錄有未提交變更**（⚠️ 異常：快照分支不該有未提交變更）：提示使用者並建議將變更搬移至 `chore/main-agent/<date>-*` 短命分支後再執行儀表板流程

> **⛔ 禁止顯示 ahead/behind**：不得在儀表板或任何輸出中顯示 `dev/main-agent` 相對於 `main` 的 `ahead/behind` commit 數量。原因：快照分支每次 `main` 合入新 PR 後都會自動「落後」，這是設計上的預期行為，不是需要同步的警告；歷次實測中使用者會把 `behind: N` 誤讀為警告並反覆追問。若需要表達快照時效，**唯一允許**的方式是相對時間字串（如「2 小時前」），取得方式：`git log -1 --format='%cr' dev/main-agent`。詳見步驟 3 的「快照分支顯示規則」。

#### 情境 B：當前在 `{main}` 分支（應避免）

- **工作目錄乾淨**：執行 `git pull origin {main}` 後切回快照分支：`git checkout dev/main-agent && git reset --hard origin/dev/main-agent`
- **工作目錄有未提交變更**（⚠️ 異常狀態）：以下列格式警告，並**暫停等待使用者指示**：

  ```
  ⚠️ 主線分支有未提交變更（{main} 應為唯讀，禁止 commit）
  ├─ 當前分支：{main}
  ├─ 未提交變更：
  │  {git status --short 輸出，逐行列出}
  └─ 建議操作：
     1. 搬移至 chore/main-agent/<date>-* 短命分支（推薦）
     2. 暫存變更（git stash）→ pull main → 切回 dev/main-agent → 建 chore 分支 → stash pop
     3. 捨棄全部變更（⚠️ 不可逆，慎用）

  請選擇操作（1/2/3），或輸入其他指示：
  ```

  - 選擇 **1**：`git checkout -b chore/main-agent/$(date +%Y%m%d)-<簡述>`（未提交變更會自動帶過去）
  - 選擇 **2**：`git stash` → `git pull origin {main}` → `git checkout dev/main-agent && git reset --hard origin/dev/main-agent` → `git checkout -b chore/main-agent/$(date +%Y%m%d)-<簡述> origin/{main}` → `git stash pop`
  - 選擇 **3**：再次確認後 `git checkout -- . && git clean -fd` → `git pull origin {main}` → `git checkout dev/main-agent && git reset --hard origin/dev/main-agent`

#### 情境 C：當前在 feature 分支（`feat/<agent>/issue-N-簡述`）

- **工作目錄乾淨**：提示使用者目前所在 feature/chore 分支，詢問是否切回 `dev/main-agent` 檢視，若使用者不想切換則直接在當前分支繼續（儀表板數據以當前分支為準）
- **工作目錄有未提交變更**：以下列格式警告，並**暫停等待使用者指示**：

  ```
  ⚠️ 非主線分支且有未提交變更
  ├─ 當前分支：{branch-name}
  ├─ 未提交變更：
  │  {git status --short 輸出，逐行列出}
  └─ 建議操作：
     1. 提交變更 → 推送分支 → 建立/更新 PR → 切回 dev/main-agent
     2. 暫存變更（git stash）→ 切回 dev/main-agent
     3. 忽略，直接在當前分支查看儀表板

  請選擇操作（1/2/3），或輸入其他指示：
  ```

  - 選擇 **1**：`git add` 相關檔案（排除 `.env`）→ 引導 commit → `git push` → 檢查 PR → `git checkout dev/main-agent && git reset --hard origin/dev/main-agent`
  - 選擇 **2**：`git stash` → `git checkout dev/main-agent && git reset --hard origin/dev/main-agent`
  - 選擇 **3**：繼續後續步驟（不切換分支）

5. 檢查是否有已合併的本地分支、遠端已合併分支或無用的 worktree，若有則列出清單提醒開發者可清理（詳細清理流程見 P3 skill「清理已合併分支與 Worktree」章節）

**受保護分支**（以下分支無論是否已合併，皆**不可刪除**）：

| 類型 | 分支名稱 |
|------|---------|
| 主線 | `main`, `master` |
| A-Main 快照 | `dev/main-agent`（A-Main 的 STATUS / dashboard 快照分支，不承接工作 commit） |
| 開發 | `develop`, `dev` |
| 測試 | `testing`, `test` |
| 預發 | `staging`, `uat` |
| 發布 | `release/*`（如 `release/1.0.0`） |

**必須執行以下三項檢查**（可並行），並在結果中排除受保護分支：

```bash
# 受保護分支的 grep 排除模式（本地與遠端共用）
PROTECTED='main$\|master$\|dev/main-agent$\|develop$\|dev$\|testing$\|test$\|staging$\|uat$\|release/'

# 5a. 已合併至 main 的本地分支（排除受保護分支）
git branch --merged main | grep -v "^\*\|$PROTECTED"

# 5b. 已合併至 main 的遠端分支（排除受保護分支與 HEAD）
git branch -r --merged origin/main | grep -v "origin/HEAD\|$PROTECTED"

# 5c. 列出所有 worktree，檢查是否有指向已合併分支的 worktree
git worktree list
```

若任一項有輸出結果，以下列格式彙整提醒：

```
🧹 可清理資源
├─ 本地已合併分支：{N} 個
│  - {branch-name}
├─ 遠端已合併分支：{N} 個
│  - {remote/branch-name}
└─ 無用 Worktree：{N} 個
   - {path} [{branch}]
🔒 受保護分支（已自動排除）：main, master, develop, dev, testing, test, staging, uat, release/*

💡 執行清理指令：
   git branch -d {branch}              # 刪除本地分支
   git push origin --delete {branch}   # 刪除遠端分支
   git worktree remove {path}          # 移除 worktree
```

若三項皆無輸出，顯示 `✅ 無需清理的分支或 worktree`。

> **注意**：此步驟確保後續的 GitHub 數據收集與本地 Dev Plan 讀取基於一致的最新狀態。

### 步驟 1：收集數據（並行執行）

**先呼叫 `detect_remote`** 取得 `PLATFORM` / `REPO_SLUG`，再依下表分派指令收集最新狀態。完整對照見 `references/git-platform-cli.md` §2。

```bash
# 前置：偵測平台（必須）
detect_remote   # 設定 PLATFORM, REPO_SLUG
```

| 目的 | github（PLATFORM=github） | gitlab（PLATFORM=gitlab） |
|------|---------------------------|---------------------------|
| 1. 各 Milestone 的 Issue 統計（open vs closed） | `gh issue list -R "$REPO_SLUG" --state all --json number,title,state,milestone,labels --limit 100` | `glab issue list -R "$REPO_SLUG" --all --output json` |
| 2. 待審合併請求 | `gh pr list -R "$REPO_SLUG" --state open --json number,title,labels,checks` | `glab mr list -R "$REPO_SLUG" --opened --output json` |
| 3. 最近合併的合併請求 | `gh pr list -R "$REPO_SLUG" --state merged --limit 5 --json number,title,mergedAt` | `glab mr list -R "$REPO_SLUG" --merged --output json \| jq '.[:5]'` |
| 4. CI 最新狀態（若有 open 合併請求） | `gh pr checks <N> -R "$REPO_SLUG"` | `glab ci status -R "$REPO_SLUG"` 或 `glab mr view <N> --output json` 取 `pipeline` 欄位 |
| 5. 部署現況偵測（若專案有部署腳本） | — 見「步驟 1a」 | — 見「步驟 1a」 |
| 6. Agent 狀態 | 讀取 `/docs/status/A-*.md`；若無，從 Issue 推斷（見 `/vibe-sdlc-status`） | 同左 |

> **錯誤處理**：若 `PLATFORM=unknown`、CLI 未安裝或未登入，依 `references/git-platform-cli.md` §4 提示使用者並中止。

### 步驟 1a：偵測部署現況

若專案根目錄存在 `docker-compose.yml`（或 `docker-compose.yaml`、`compose.yml`），則偵測部署相關服務的運行狀態。此步驟可與步驟 1 的其他指令並行執行。

**偵測項目與指令**：

```bash
# 1a-1. Docker 容器狀態
docker compose ps --format json 2>/dev/null || echo "DOCKER_NOT_RUNNING"

# 1a-2. Cloudflare Tunnel 狀態（若使用 Tunnel 部署）
#   優先檢查 PID 檔（路徑從 scripts/start.sh 中解析，預設為 {project_root}/.tunnel.pid）
#   若 PID 檔不存在，則 fallback 透過 ps 偵測 cloudflared 進程
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "TUNNEL_RUNNING (PID: $(cat "$PID_FILE"))"
else
    # Fallback：直接搜尋 cloudflared 進程（涵蓋非透過 start.sh 啟動的情況）
    TUNNEL_PID=$(ps aux | grep 'cloudflared tunnel' | grep -v grep | awk '{print $2}' | head -1)
    if [ -n "$TUNNEL_PID" ]; then
        # 嘗試從進程參數取得 config 檔名
        TUNNEL_INFO=$(ps aux | grep 'cloudflared tunnel' | grep -v grep | head -1)
        echo "TUNNEL_RUNNING_NO_PID_FILE (PID: $TUNNEL_PID)"
    else
        echo "TUNNEL_NOT_RUNNING"
    fi
fi

# 1a-3. 服務健康檢查（從 docker-compose.yml 解析 ports 與環境變數）
#   後端：curl -sf http://localhost:{backend_port}/health
#   前端：curl -sf -o /dev/null -w "%{http_code}" http://localhost:{frontend_port}

# 1a-4. 公網端點檢查（從 docker-compose.yml 環境變數中解析對外 URL）
#   例：CORS_ORIGIN, VITE_API_BASE_URL 等可能包含公網域名
#   curl -sf -o /dev/null -w "%{http_code}" {public_url}
```

**偵測邏輯**：

1. **解析 `docker-compose.yml`**：讀取 services 定義，取得各服務的 port mapping 與環境變數
2. **解析啟動腳本**（如 `scripts/start.sh`）：取得 Tunnel 設定檔路徑、PID 檔路徑、公網 URL 等
3. **判定部署狀態**：

| 狀態 | 條件 |
|------|------|
| 🟢 運行中 | Docker 容器 running + 健康檢查通過 |
| 🟡 部分運行 | 部分容器 running 或健康檢查失敗 |
| 🔴 未運行 | 無容器運行或 Docker 未啟動 |
| ⚪ 未配置 | 無 docker-compose.yml |

Tunnel 狀態獨立判定：

| 狀態 | 條件 |
|------|------|
| 🟢 連線中 | PID 檔或 ps 偵測到 cloudflared 進程運行中 + 公網端點可達 |
| 🟡 程序運行但端點不可達 | cloudflared 進程存在但公網 curl 失敗 |
| 🔴 未運行 | PID 檔不存在且 ps 未偵測到 cloudflared 進程 |
| ⚪ 未配置 | 無啟動腳本或 Tunnel 設定 |

> **注意**：Tunnel 可能透過 `scripts/start.sh`（產生 PID 檔）或直接以 `cloudflared tunnel run` 啟動（無 PID 檔）。偵測時應同時檢查 PID 檔與 `ps aux | grep cloudflared` 兩種途徑。

### 步驟 2：讀取 Dev Plan 任務狀態

讀取 `/docs/02-Dev_Plan.md` 附錄的任務執行狀態追蹤區塊，統計 `- [ ]` 與 `- [x]` 數量。

### 步驟 3：產出進度儀表板

使用以下格式輸出：

```
📊 Vibe-SDLC 進度儀表板
========================
專案：{repo-name}
日期：{today}
目前階段：Phase {N}（{phase-name}）

┌─ 里程碑進度 ────────────────────────────────┐
│ M1 {名稱}  {進度條} {closed}/{total} ({%})  │
│ M2 {名稱}  {進度條} {closed}/{total} ({%})  │
│ M3 {名稱}  {進度條} {closed}/{total} ({%})  │
│ M4 {名稱}  {進度條} {closed}/{total} ({%})  │
│                                              │
│ 總進度      {進度條} {closed}/{total} ({%})  │
└──────────────────────────────────────────────┘

┌─ 待處理事項 ─────────────────────────────────┐
│ 🔀 待審 PR：{N} 個                           │
│    - #{num} {title} (CI: ✅/❌)              │
│ 📋 進行中 Issue：{N} 個                      │
│    - #{num} {title}                          │
│ 🔍 待驗證：{N} 個                            │
│    - #{num} {title}                          │
└──────────────────────────────────────────────┘

┌─ Agent 活動 ──────────────────────────────────┐
│ {🟢/🟡/🔴/⚪} {Agent}  #{N} {簡述} ({耗時})  │
│ {🟢/🟡/🔴/⚪} {Agent}  #{N} {簡述} ({狀態})  │
│                                               │
│ 💡 詳細資訊：/vibe-sdlc-status                │
└───────────────────────────────────────────────┘

┌─ 部署現況 ───────────────────────────────────┐
│ 🐳 Docker：{🟢 運行中 / 🟡 部分運行 / 🔴 未運行 / ⚪ 未配置}  │
│    - {service_name}: {status} (port: {port})  │
│    - {service_name}: {status} (port: {port})  │
│ 🔗 Tunnel：{🟢 連線中 / 🔴 未運行 / ⚪ 未配置}               │
│ 🌐 公網端點：                                 │
│    - {url} → {HTTP status / 不可達}           │
│    - {url} → {HTTP status / 不可達}           │
│ 📅 上次部署 commit：{short_hash} {message}    │
└──────────────────────────────────────────────┘

┌─ 最近動態 ───────────────────────────────────┐
│ ✅ #{num} {title} — merged {date}            │
│ ✅ #{num} {title} — merged {date}            │
└──────────────────────────────────────────────┘

📌 建議下一步：{具體建議}
```

**進度條規則**：
- 使用 `█`（已完成）和 `░`（未完成），共 10 格
- 例：60% → `██████░░░░`

**部署現況區塊規則**：
- 若專案無 `docker-compose.yml` 且無部署腳本，則**省略整個「部署現況」區塊**，不顯示
- 「上次部署 commit」：比對目前正在運行的容器 image 與本地最新 commit，若無法取得容器資訊則顯示最近一次與部署相關的 commit（搜尋關鍵字：`deploy`, `部署`, `release`, `docker`, `tunnel`）
- 公網端點：從 `docker-compose.yml` 的環境變數（如 `CORS_ORIGIN`、`VITE_API_BASE_URL`）或啟動腳本中解析；若無公網端點則省略該行
- 健康檢查逾時設為 5 秒（`curl --max-time 5`）

**快照分支顯示規則**（非常重要，違反會造成使用者困擾）：

| 顯示類型 | 允許 | 原因 |
|----------|:----:|------|
| `dev/main-agent` vs `main` 的 `ahead/behind` commit 數量 | ❌ | 快照分支在 main 合入新 PR 後天生會「落後」，這是預期行為；顯示數字會被誤讀為「需要同步的警告」 |
| 「dev/main-agent 落後 main N 個 commit」「需要 rebase」類語句 | ❌ | 誤導使用者，與 `/vibe-sdlc-status` 的設計合約衝突 |
| `git rev-list --left-right --count origin/main...HEAD` 的原始輸出 | ❌ | 同上；這類數據對快照分支無意義 |
| 相對時間字串的快照時效（如「2 小時前」「昨天」） | ✅ | 語意直觀，沒有「需要動作」的暗示 |
| 最新的快照 commit hash + 時效 | ✅ | 作為「A-Main 上次工作的時間點」參考 |

若需要在儀表板顯示快照時效，**在「Agent 活動」區塊底部**加一行（而非獨立區塊）：

```
│ 📸 A-Main 快照時效：{相對時間}（{short_hash}）
```

取得方式：`git log -1 --format='%cr %h' dev/main-agent`（範例輸出：`2 hours ago 7f7f32c`）。若快照時效超過 24 小時，可在 `建議下一步` 加一句「建議呼叫 `/vibe-sdlc-status` 刷新快照」，但**不得**呈現為警告。

> 此規則同時適用於 Claude 在儀表板以外的自由輸出 —— 不要在任何地方把快照分支的 git ahead/behind 當成需要處理的狀態來報告。

**同步 Dev Plan 狀態**

若已存在 Dev Plan ，則應視需要檢查  Dev Plan 任務狀態是否一致，若不一致，則應自動同步 Dev Plan 任務狀態，並提示使用者。


### 步驟 4：判斷當前 Phase 並建議

根據收集到的數據判斷：

| 條件 | 判定 Phase | 建議 |
|------|-----------|------|
| 缺 `CLAUDE.md` 或 `/docs` 目錄（部分缺） | Phase 1（Bootstrap） | 呼叫 `/vibe-sdlc-spec`，該 skill 會偵測並引導補完 CLAUDE.md / docs 骨架 |
| `/docs` 下缺少規格文件 | Phase 1 | 呼叫 `/vibe-sdlc-spec` |
| 規格文件齊全但無 Issues | Phase 2 | 呼叫 `/vibe-sdlc-issues` |
| 有 open Issues 且無 open PR | Phase 3 | 呼叫 `/vibe-sdlc-dev` 領取 Issue |
| 有 open Issues 且有 open PR | Phase 3 + 4 並行 | 先處理 Phase 4（監控 PR CI / Code Review），同時可領取下一個 Issue 進入 Phase 3 |
| 有 open PR 待審（無 open Issues） | Phase 4 | 審閱 PR，決定 Merge 或要求修改 |
| 某 Milestone 所有 Issue closed | Phase 4 收尾 → Phase 5 | 若尚未產出里程碑完成報告，先執行 P4 收尾；否則呼叫 `/vibe-sdlc-release` |
| 有待驗證 Issue（`verification` 標籤） | Phase 4 | 提醒進行手動驗證 |


### 步驟 5：Context 管理建議

在以下時機，主動提示使用者考慮開啟新 session 以節省 Context 空間與 Token 消耗：

| 觸發時機 | 提示條件 |
|----------|---------|
| **里程碑驗收完成後** | 驗收門 Issue 已關閉 |
| **PR 合併且部署成功後** | 無後續待處理任務 |
| **Session 任務量過大** | 本次 session 已處理 ≥ 3 個 Issue |

**提示格式**：

```
💡 目前 session 已處理多個任務，建議開啟新 session 以節省 Context。
   當前進度已同步至 GitHub，新 session 可透過 `/vibe-sdlc` 快速恢復狀態。
```

> **注意**：此提示僅為建議，不強制。若使用者選擇繼續，則正常執行後續操作。

### 步驟 6：若使用者不確定

協助釐清目前該做什麼，提供具體的 Issue 編號與操作建議。
