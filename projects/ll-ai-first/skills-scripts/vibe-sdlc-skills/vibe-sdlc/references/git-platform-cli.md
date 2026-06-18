# Git 平台 CLI 抽象層 — `gh` / `glab` 偵測與對照

本文件是 `vibe-sdlc*` 系列技能在執行 Git 平台操作時的**唯一指令真相來源**。所有子技能不得直接硬編碼 `gh ...`，必須先依本文件 §1 偵測平台，再依 §2／§3 對照表分派到 `gh` 或 `glab`。

> **適用範圍**：vibe-sdlc, vibe-sdlc-spec, vibe-sdlc-issues, vibe-sdlc-dev, vibe-sdlc-pr, vibe-sdlc-release, vibe-sdlc-status

---

## 目錄

1. [平台偵測（detect_remote）](#1-平台偵測detect_remote)
2. [命令對照表](#2-命令對照表)
3. [概念對照](#3-概念對照)
4. [失敗模式與錯誤處理](#4-失敗模式與錯誤處理)
5. [使用範例](#5-使用範例)

---

## 1. 平台偵測（detect_remote）

### 1.1 偵測流程

每個 vibe-sdlc 子技能在進入需要呼叫 git hosting CLI 的步驟前，**必須**先執行下列偵測流程，取得 `PLATFORM`、`REMOTE_HOST`、`REPO_SLUG` 三個變數，後續所有命令據此分派。

```bash
# detect_remote — 輸出 PLATFORM / REMOTE_HOST / REPO_SLUG
# 使用字串切片（非 regex 回溯）以避免 bash regex 在 HTTPS URL 上的歧義
detect_remote() {
  local url host="" slug="" rest
  PLATFORM="unknown"; REMOTE_HOST=""; REPO_SLUG=""

  # 取得 origin URL（若無 origin 則嘗試第一個 remote）
  url=$(git remote get-url origin 2>/dev/null) \
    || url=$(git remote | head -1 | xargs -I{} git remote get-url {} 2>/dev/null)
  [ -z "$url" ] && return 0

  if [[ "$url" =~ ^(ssh://)?git@ ]]; then
    # SSH 形式：
    #   git@host:path             → SCP-like
    #   ssh://git@host/path       → 標準 SSH URL
    rest="${url#ssh://}"
    rest="${rest#git@}"
    local before_slash="${rest%%/*}"
    if [[ "$before_slash" == *:* ]]; then
      # SCP-like：host:path
      host="${before_slash%:*}"
      slug="${rest#*:}"
    else
      # ssh://git@host/path
      host="$before_slash"
      slug="${rest#*/}"
    fi
  elif [[ "$url" =~ ^https?:// ]]; then
    # HTTP(S) 形式：https://[user[:pass]@]host/path
    rest="${url#http*://}"
    rest="${rest#*@}"   # 移除可選的 user:pass@（無 @ 則不變）
    host="${rest%%/*}"
    slug="${rest#*/}"
  else
    return 0
  fi

  # 去掉 .git 後綴
  slug="${slug%.git}"
  [ -z "$host" ] && return 0

  REMOTE_HOST="$host"
  REPO_SLUG="$slug"

  # 平台分類
  case "$host" in
    github.com|*.github.com)
      PLATFORM="github" ;;
    gitlab.com|*.gitlab.com|gitlab.*|*gitlab*)
      PLATFORM="gitlab" ;;
    *)
      # 未匹配任何已知模式 — 由呼叫端決定是否提示使用者
      PLATFORM="unknown" ;;
  esac
}
```

> **設計備註**：早期版本使用單一 regex 解析所有 URL 形式，但 bash regex 回溯機制會把 `https://github.com/...` 的 host 誤判為 `b.com`（因為 `[^/]*([^/@]+\.[^/]+)` 的 lazy 捕獲組），故改用字串切片實作。已通過 12 種 URL 形式的迴歸測試（含 SSH、HTTPS、含 user:pass、巢狀 group、自架 host 等）。

### 1.2 偵測規則摘要

| 樣式 | 範例 | 判定 |
|------|------|------|
| `github.com` | `git@github.com:robin-li/Vibe-SDLC.git` | `github` |
| `*.github.com`（GitHub Enterprise Cloud） | `git@ent.github.com:org/repo.git` | `github` |
| `gitlab.com` | `https://gitlab.com/group/repo.git` | `gitlab` |
| `gitlab.*` / 自架 GitLab（host 含 `gitlab`） | `git@gitlab.acme.io:team/repo.git` | `gitlab` |
| GitHub Enterprise Server（自架 GitHub，host 不含 github） | `git@code.acme.com:org/repo.git` | `unknown` — 需呼叫端詢問使用者 |
| 無 `origin`、無任何 remote | — | `unknown` |
| 非 git/ssh/https 協定 | — | `unknown` |

### 1.3 邊界與決策

- **多 remote**：以 `origin` 為準；若無 `origin`，取 `git remote | head -1`。文件範例不假設多 remote 場景。
- **GitHub Enterprise Server（自架 GitHub）**：因 host 與 github.com 無關，無法自動辨識，回傳 `unknown`。子技能遇到 `unknown` 時應提示使用者：「無法自動辨識平台，請手動選擇 (1) github (2) gitlab」並把結果暫存於 session。
- **自架 GitLab**：只要 host 含 `gitlab` 字樣即判定為 gitlab。若使用者的自架 GitLab host 不含 `gitlab`（例如 `git.acme.com`），同樣需手動指定。
- **不快取**：每次需要使用平台 CLI 前重跑 `detect_remote`，避免使用者中途切換 remote 後狀態不一致。

---

## 2. 命令對照表

下列以「操作意圖」為主軸列出 `gh` 與 `glab` 的等效指令。子技能編寫時應依「操作意圖」描述行為，並引用本表分派。

> `${OWNER_REPO}` 在 GitHub 為 `owner/repo`；在 GitLab 為 `group/repo` 或 `group/subgroup/repo`。等同於 `REPO_SLUG`。

### 2.1 Issue

| 操作意圖 | GitHub (`gh`) | GitLab (`glab`) |
|---------|---------------|-----------------|
| 列出 Issue | `gh issue list -R ${OWNER_REPO} --state all --json number,title,state,labels,milestone --limit 100` | `glab issue list -R ${OWNER_REPO} --all --output json` |
| 查看單一 Issue | `gh issue view <N> -R ${OWNER_REPO} --json number,title,body,labels,assignees,milestone,state` | `glab issue view <N> -R ${OWNER_REPO} --output json` |
| 建立 Issue | `gh issue create -R ${OWNER_REPO} --title "..." --body-file ...` | `glab issue create -R ${OWNER_REPO} --title "..." --description-file ...` |
| 增加標籤 | `gh issue edit <N> -R ${OWNER_REPO} --add-label "..."` | `glab issue update <N> -R ${OWNER_REPO} --label "..."` |
| 指派 milestone | `gh issue edit <N> -R ${OWNER_REPO} --milestone "M1"` | `glab issue update <N> -R ${OWNER_REPO} --milestone "M1"` |
| 指派負責人 | `gh issue edit <N> -R ${OWNER_REPO} --add-assignee @me` | `glab issue update <N> -R ${OWNER_REPO} --assignee @me` |
| 關閉 Issue | `gh issue close <N> -R ${OWNER_REPO}` | `glab issue close <N> -R ${OWNER_REPO}` |
| 評論 Issue | `gh issue comment <N> -R ${OWNER_REPO} --body "..."` | `glab issue note <N> -R ${OWNER_REPO} --message "..."` |

### 2.2 PR / Merge Request

> GitHub 稱 **Pull Request**，GitLab 稱 **Merge Request**。在 vibe-sdlc 文案中統一以「合併請求」描述，依平台分派指令。

| 操作意圖 | GitHub (`gh`) | GitLab (`glab`) |
|---------|---------------|-----------------|
| 列出待審合併請求 | `gh pr list -R ${OWNER_REPO} --state open --json number,title,labels` | `glab mr list -R ${OWNER_REPO} --opened --output json` |
| 查看合併請求 | `gh pr view <N> -R ${OWNER_REPO} --json number,title,body,state,mergeable` | `glab mr view <N> -R ${OWNER_REPO} --output json` |
| 建立合併請求 | `gh pr create -R ${OWNER_REPO} --title "..." --body "..." --base main` | `glab mr create -R ${OWNER_REPO} --title "..." --description "..." --target-branch main` |
| 檢查 CI 狀態 | `gh pr checks <N> -R ${OWNER_REPO}` | `glab ci status -R ${OWNER_REPO}` 或 `glab mr view <N> --output json` 取 `pipeline` 欄位 |
| 合併 | `gh pr merge <N> -R ${OWNER_REPO} --squash` | `glab mr merge <N> -R ${OWNER_REPO} --squash-before-merge` |
| 評論 | `gh pr comment <N> -R ${OWNER_REPO} --body "..."` | `glab mr note <N> -R ${OWNER_REPO} --message "..."` |
| 列出最近合併 | `gh pr list -R ${OWNER_REPO} --state merged --limit 5 --json number,title,mergedAt` | `glab mr list -R ${OWNER_REPO} --merged --output json \| jq '.[:5]'` |

### 2.3 Release

| 操作意圖 | GitHub (`gh`) | GitLab (`glab`) |
|---------|---------------|-----------------|
| 建立 Release | `gh release create v1.0.0 -R ${OWNER_REPO} --title "..." --notes-file ...` | `glab release create v1.0.0 -R ${OWNER_REPO} --name "..." --notes-file ...` |
| 列出 Release | `gh release list -R ${OWNER_REPO}` | `glab release list -R ${OWNER_REPO}` |
| 查看 Release | `gh release view v1.0.0 -R ${OWNER_REPO}` | `glab release view v1.0.0 -R ${OWNER_REPO}` |

### 2.4 Repo / Label / Milestone

| 操作意圖 | GitHub (`gh`) | GitLab (`glab`) |
|---------|---------------|-----------------|
| 查看 Repo 資訊 | `gh repo view ${OWNER_REPO} --json name,defaultBranchRef,visibility` | `glab repo view ${OWNER_REPO} --output json` |
| 建立 Label | `gh label create "name" -R ${OWNER_REPO} --color "..." --description "..."` | `glab label create -R ${OWNER_REPO} --name "name" --color "#..." --description "..."` |
| 列出 Label | `gh label list -R ${OWNER_REPO}` | `glab label list -R ${OWNER_REPO}` |
| 建立 Milestone | （需走 API：`gh api repos/${OWNER_REPO}/milestones -f title=...`） | `glab api projects/:id/milestones -F title=...`（或 GitLab UI） |
| 列出 Milestone | `gh api repos/${OWNER_REPO}/milestones` | `glab api projects/:id/milestones` |

> Milestone 在兩個平台的 CLI 一級指令支援都有限，多走 API。子技能須在實作時保留這個限制的註記。

### 2.5 CI / Actions / Pipeline

| 操作意圖 | GitHub (`gh`) | GitLab (`glab`) |
|---------|---------------|-----------------|
| 列出最近執行 | `gh run list -R ${OWNER_REPO} --limit 10` | `glab ci list -R ${OWNER_REPO}` |
| 查看單次執行 | `gh run view <id> -R ${OWNER_REPO}` | `glab ci view <id> -R ${OWNER_REPO}` |
| 觸發手動執行 | `gh workflow run <name> -R ${OWNER_REPO}` | `glab ci trigger <id> -R ${OWNER_REPO}` |

---

## 3. 概念對照

| 概念 | GitHub | GitLab | 在 vibe-sdlc 文案中採用 |
|------|--------|--------|------------------------|
| 合併請求 | Pull Request (PR) | Merge Request (MR) | **合併請求**（PR/MR） |
| 標籤 | Labels | Labels | 標籤 |
| 里程碑 | Milestones | Milestones | 里程碑 |
| 看板 | Projects | Issue Boards | 看板 |
| 指派人 | Assignees | Assignees | 指派人 |
| 審查人 | Reviewers | Reviewers / Approvers | 審查人 |
| 合併前檢查 | Required checks | Pipelines must pass / Approvals | 合併前檢查 |
| CI/CD | Actions（YAML on push） | Pipelines（`.gitlab-ci.yml`） | CI/CD pipeline |
| 預設分支 | `main` | `main` | `main`（統稱 `{main}`） |

**重要差異**：

- **CI 觸發時機**：GitHub Actions 預設在 push / PR 事件觸發；GitLab CI 在 push / MR / tag 事件觸發。子技能若涉及「等待 CI 完成」必須使用平台對應 API。
- **Approvals**：GitLab 的 MR Approvals 是付費功能（Premium 以上）。`vibe-sdlc-pr` 在 GitLab 上不應依賴 approvals，改用「label = `approved`」這類 OSS-friendly 機制。
- **`@me` 用法**：兩者都支援，但 `glab` 在某些子指令下要求加引號（`'@me'`）。建議子技能一律加單引號。

---

## 4. 失敗模式與錯誤處理

子技能在執行任何平台 CLI 前，應檢查並處理以下情境：

| 失敗模式 | 偵測 | 處理 |
|---------|------|------|
| `PLATFORM=unknown` | `detect_remote` 後 PLATFORM 為 unknown | 詢問使用者：「無法自動辨識平台 (host=${REMOTE_HOST})，請手動選擇 (1) github (2) gitlab (3) 中止」 |
| `gh` 未安裝 | `command -v gh` 不存在 | 訊息：「需要 GitHub CLI。請執行 `brew install gh`（macOS）或見 https://cli.github.com」 |
| `glab` 未安裝 | `command -v glab` 不存在 | 訊息：「需要 GitLab CLI。請執行 `brew install glab`（macOS）或見 https://gitlab.com/gitlab-org/cli」 |
| `gh` 未登入 | `gh auth status` 非 0 | 引導：「請在終端執行 `gh auth login -h github.com`」 |
| `glab` 未登入 | `glab auth status` 非 0 | 引導：「請在終端執行 `glab auth login --hostname <gitlab-host>`」 |
| 自架 GitLab 未設定 host | `glab auth status` 報 host 未知 | 引導：「自架 GitLab 需先設定 host：`glab config set -h <gitlab-host> token <PAT>`」 |
| `gh` token 無效（HTTP 401） | 指令 stderr 含 `401` 或 `Bad credentials` | 引導重新 `gh auth login`，並提示可能 token 過期 |

> **錯誤訊息原則**：對 vibe-sdlc 使用者透明，**永遠**指出實際應該執行的指令，不要只說「請登入」。

---

## 5. 使用範例

### 5.1 子技能中如何呼叫

```bash
# Step 1: 偵測平台
source <(declare -f detect_remote)   # 或在 skill.md 中內聯定義
detect_remote

# Step 2: 檢查 CLI 安裝
case "$PLATFORM" in
  github)
    command -v gh >/dev/null || { echo "請安裝 gh"; exit 1; }
    gh auth status >/dev/null 2>&1 || { echo "請先 gh auth login"; exit 1; }
    ;;
  gitlab)
    command -v glab >/dev/null || { echo "請安裝 glab"; exit 1; }
    glab auth status >/dev/null 2>&1 || { echo "請先 glab auth login"; exit 1; }
    ;;
  unknown)
    echo "無法辨識遠端 (host=${REMOTE_HOST})。請手動指定平台或檢查 git remote。"
    exit 1
    ;;
esac

# Step 3: 依平台分派
if [ "$PLATFORM" = "github" ]; then
  gh issue list -R "$REPO_SLUG" --state open --json number,title,labels
else
  glab issue list -R "$REPO_SLUG" --opened --output json
fi
```

### 5.2 在 skill.md 中以「操作意圖」描述

子技能 skill.md 應以下列風格描述步驟，**不直接寫死 CLI**：

> 「列出當前 repo 所有 open Issue（依 §2.1 對照表執行 `gh issue list` 或 `glab issue list`）」

而非：

> ~~「執行 `gh issue list -R owner/repo --state open`」~~

這樣 AI 在執行時會先讀本對照表分派，避免在子技能中重複寫死指令。

---

## 6. 維護備註

- 本文件由 #3 建立。後續 #4 改寫 51 處子技能 gh 指令時，應全部對照本表。
- 若兩個 CLI 任一方有版本更新導致語法改變（如 `gh` 2.x → 3.x），須同步更新本表並在文件頂端記註。
- 自架 GitHub Enterprise Server 的支援為 best-effort，目前需使用者手動選擇平台。
