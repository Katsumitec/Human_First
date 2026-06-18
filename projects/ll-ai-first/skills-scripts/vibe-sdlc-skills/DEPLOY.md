# Vibe-SDLC Skills 部署說明

## 檔案清單

```
skills/
├── README.md                        ← 完整使用說明與範例
├── DEPLOY.md                        ← 本說明文件
├── local-tunnel/
│   └── skill.md                     ← 發佈本地服務至公網
├── vibe-sdlc/
│   └── skill.md                     ← 總覽與導航
├── vibe-sdlc-spec/
│   ├── skill.md                     ← Phase 1：定義規格文件與計畫
│   ├── templates/
│   │   └── CLAUDE.md.template       ← 新專案 CLAUDE.md 骨架（空專案初始化用）
│   ├── references/
│   │   ├── multi-account-setup.md   ← 多帳號協作配置指南
│   │   └── UI_UX_Writing_Guidelines.md ← UI/UX 規格撰寫 9 條準則（含 HTML wireframe）
│   └── examples/docs/               ← 規格文件範例
│       ├── 00-Docs_Index.md         ← 文件入口與導航
│       ├── 01-1-PRD.md              ← 產品需求文件範例
│       ├── 01-2-SRD.md              ← 系統需求文件範例（v2.0，設計內容移至 SDD）
│       ├── 01-3-SDD.md              ← 系統設計文件範例
│       ├── 01-4-GDD.md              ← 遊戲設計文件範例（領域選用）
│       ├── 01-5-API_Spec.md         ← API 介面規格範例
│       ├── 01-6-UI_UX_Design.md     ← UI/UX 設計文件範例
│       ├── ui/                      ← HTML wireframe 視覺參考範例（6 份）
│       │   ├── home.html            ← 首頁 wireframe
│       │   ├── stats.html           ← 統計頁 wireframe
│       │   ├── history.html         ← 記錄頁 wireframe
│       │   ├── settings.html        ← 設定頁 wireframe
│       │   ├── login.html           ← 登入頁 wireframe
│       │   └── register.html        ← 註冊頁 wireframe
│       ├── 02-Dev_Plan.md           ← 開發計畫範例
│       ├── 03-Docs_Review_Report.md ← 規格審查報告範例
│       ├── 04-CI_CD_Spec.md         ← CI/CD 規格文件範例
│       └── API_Spec.yaml            ← OpenAPI 合約範例
├── vibe-sdlc-issues/
│   └── skill.md                     ← Phase 2：任務掛載
├── vibe-sdlc-dev/
│   └── skill.md                     ← Phase 3：開發循環
├── vibe-sdlc-pr/
│   └── skill.md                     ← Phase 4：CI 監控與合併後作業
├── vibe-sdlc-release/
│   └── skill.md                     ← Phase 5：回饋收集、Release 與迭代
└── vibe-sdlc-status/
    └── skill.md                     ← Agent 狀態查詢與彙整
```

## 目錄結構說明

Claude Code 的 skills 要求每個 skill 為**獨立子目錄**，目錄中包含一個 `skill.md` 檔案。格式如下：

```
<skills-dir>/<skill-name>/skill.md
```

其中 `skill.md` 的 frontmatter 定義了 skill 的名稱、描述與是否可由使用者呼叫：

```yaml
---
name: vibe-sdlc
description: >
  Vibe-SDLC 流程總覽與導航。
user_invocable: true
---
```

## 一鍵安裝（推薦）

在 Vibe-SDLC 專案根目錄下執行安裝腳本：

```bash
# 互動式安裝（會引導你選擇安裝模式）
./install.sh

# 或直接指定模式
./install.sh global                        # 全域安裝，所有專案可用
./install.sh project /path/to/my-project   # 安裝至指定專案
./install.sh shared  /path/to/my-project   # 安裝至指定專案並提交 Git
```

安裝腳本會自動：
- 檢查來源目錄是否完整
- 列出即將安裝的 skills 清單
- 複製 skills 至目標位置（若已存在則更新）
- 驗證安裝結果

## 手動部署

Claude Code 的 skills 支援三個層級的部署位置，依據你的需求選擇：

### 方式一：全域部署（所有專案皆可使用）

將 skill 子目錄複製到個人設定目錄：

```bash
cp -r skills/vibe-sdlc* ~/.claude/skills/
```

### 方式二：專案層級部署（僅限特定專案）

將 skill 子目錄複製到目標專案的 `.claude/skills/` 目錄：

```bash
mkdir -p /path/to/my-project/.claude/skills
cp -r skills/vibe-sdlc* /path/to/my-project/.claude/skills/
```

### 方式三：共享部署（團隊共用，納入版本控制）

將 skill 子目錄放在專案的 `.claude/skills/` 目錄並提交至 Git：

```bash
mkdir -p /path/to/my-project/.claude/skills
cp -r skills/vibe-sdlc* /path/to/my-project/.claude/skills/
cd /path/to/my-project
git add .claude/skills/vibe-sdlc*/
git commit -m "Add Vibe-SDLC skills for AI-assisted development workflow"
```

## 驗證部署

部署完成後，在 Claude Code 中輸入以下指令驗證：

```
/vibe-sdlc
```

若看到進度儀表板與 Phase 導航，表示部署成功。

## 使用方式

| 指令 | 用途 |
|------|------|
| `/vibe-sdlc` | 產出進度儀表板（里程碑進度、待審 PR、待驗證 Issue），自動判斷當前 Phase |
| `/vibe-sdlc-spec` | 撰寫或審查規格文件 |
| `/vibe-sdlc-issues` | 審核 Dev Plan → 建立 Issues（GitHub / GitLab 自動分派） |
| `/vibe-sdlc-dev` | 領取 Issue → 開發 → 測試 → Vibe Check → 自動建 PR |
| `/vibe-sdlc-pr` | 監控 CI → 修正失敗 → Merge 後更新 Dev Plan |
| `/vibe-sdlc-release` | 部署驗收 → 收集回饋 → 更新規格 |
| `/vibe-sdlc-status` | 查詢 Agent 狀態 → 彙整 STATUS.md |

## 典型工作流程

```
專案啟動
  └→ /vibe-sdlc-spec     撰寫規格 → 審查 → 定稿
      └→ /vibe-sdlc-issues   審核計畫 → 建立 Issues
          └→ /vibe-sdlc-dev       領取 Issue #1 → 開發 → Vibe Check → 自動建 PR
              └→ /vibe-sdlc-pr        監控 CI → 修正失敗 → Merge → 更新 Dev Plan
                  └→ /vibe-sdlc-dev       領取 Issue #2 → ...（重複）
                      └→ ...
                          └→ /vibe-sdlc-release   里程碑完成 → 部署 → 回饋
                              └→ /vibe-sdlc-issues   下一輪迭代
```

## 注意事項

- 這些 skills 同時支援 **GitHub** 與 **GitLab** 作為版本管理與 CI/CD 平台，依 `git remote -v` 自動偵測
- Phase 2 與 Phase 4 會使用 `gh`（GitHub）或 `glab`（GitLab）CLI：
  - GitHub 專案：`brew install gh && gh auth login`
  - GitLab 專案：`brew install glab && glab auth login --hostname <host>`
- 完整 gh / glab 對照與偵測邏輯見 `vibe-sdlc/references/git-platform-cli.md`
- 規格文件預設路徑為 `/docs`，可依專案需求調整 skill 內容中的路徑
