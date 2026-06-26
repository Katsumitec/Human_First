# skills-scripts — 可重用技術檔

從 PredictMarket 的 `.claude/` 抽出、**可直接拿去用**的產物。技術棧不限 Laravel / React，邏輯通用。

| 檔案 | 是什麼 | 怎麼用 |
|------|--------|--------|
| `block-env-read.sh` | PreToolUse hook：在工具呼叫層攔截任何想讀 / 印出 `.env` 內容的操作 | 見下方 |
| `lint-after-edit.sh` | PostToolUse hook：編輯檔案後自動跑 linter（`tsc --noEmit` / `php -l`） | 見下方 |
| `spec-then-build.SKILL.md` | 主編排 skill：規格 → 獨立審查 → 並行實作 → 整合驗證 → 品質門 | 放進 `.claude/skills/spec-then-build/SKILL.md` |
| `settings.example.json` | 權限白名單（43 allow / 9 deny）+ hooks 配置範例 | 對照改進你自己的 `.claude/settings.json` |

---

## `block-env-read.sh`（最推薦直接複用）

**目的**：規範「不准印 `.env`」不是靠 AI 自律，而是系統攔截——想違反也做不到。會擋 `Read` 工具讀 `.env`，以及 Bash 用 `cat`/`head`/`tail`/`less`/`grep`（無 `-c`）/`awk`（非取長度）/`source`/redirection 印出 `.env`。`.env.example`/`.template`/`.sample` 等範本檔放行。

**安裝**：
```jsonc
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-env-read.sh" }] },
      { "matcher": "Read", "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-env-read.sh" }] }
    ]
  }
}
```
**前置**：`jq`、bash。放進 `.claude/hooks/` 後 `chmod +x`。**通用、無專案耦合**。

---

## `lint-after-edit.sh`

**目的**：寫壞了馬上知道，不用等 commit 才發現。每次 Edit/Write 後依副檔名挑 linter。

**注意**：本檔含 **PredictMarket 專屬路徑**（`*/frontend/*.tsx` 走 `tsc`、`*/backend/*.php` 走 Docker 內 `php -l`）。複用時請改成你的目錄結構與執行方式。

**安裝**：
```jsonc
{ "hooks": { "PostToolUse": [
  { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/lint-after-edit.sh", "timeout": 30 }] }
]}}
```

---

## `spec-then-build.SKILL.md`

**目的**：中大型跨前後端功能的一條龍產線。五階段：
`Stage 0 前置判斷（要不要 RFC/ADR）→ 1 規格產出 → 1.5 獨立審查 → 2 雙線並行 BE+FE → 3 整合驗證 +3.5 E2E → 4 品質門 + commit`。

**關鍵設計**：
- 全程有 **human gate**（規格核可 / HIGH 問題 / push 前），輸出是「已測試、已審查、已掃描」的 commit，但**不自動 push**。
- Stage 1.5 用唯讀無記憶的 sub-agent 審查，避免「作者審自己」的偏見；主 agent 再 grep 反查引用的 method/class 是否真存在，擋幻覺。
- 強制 Blast Radius + `### Backend` / `### Frontend` 分層，讓並行 agent 精準切任務。

**注意**：內文有 PredictMarket 專屬細節（GraphQL schema、Filament、docker 指令、色彩 token），複用時當骨架、換掉專案專屬段落即可。

---

## `settings.example.json`

權限白名單 + hooks 的完整範例。**原則：白名單制——預設禁止，逐一開放安全操作；明確 deny 破壞性指令**（`rm -rf`、`git push --force`、`git reset --hard`、`migrate:fresh`、`DROP TABLE`…）。docker / artisan 相關 allow 條目為專案專屬，請按你的環境調整。
