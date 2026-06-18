---
name: run-sql
description: 執行 MySQL SQL 腳本檔案。給定一個或多個 .sql 檔案路徑，透過 MySQL 連線依序執行。支援指定 Database、錯誤處理策略。觸發詞：執行SQL、run sql、跑SQL。
---

# 執行 MySQL SQL 腳本

## 技能目標

透過本 skill 內建的 `scripts/run_sql.py` 腳本，連線 MySQL 並依序執行指定的 SQL 檔案。

## 腳本位置

所有腳本與設定均位於本 skill 目錄下：

```
.claude/skills/run-sql/
├── SKILL.md              # 本文件
└── scripts/
    ├── run_sql.py        # 主程式
    ├── requirements.txt  # Python 依賴
    └── .env.example      # 環境變數範本
```

**重要**：以下指令中的 `SKILL_DIR` 代表本 skill 的絕對路徑，執行時請替換為實際路徑。
可透過以下方式取得：

```bash
SKILL_DIR="$(cd "$(dirname "$0")/.claude/skills/run-sql" && pwd)"
```

或直接使用專案根目錄拼接：`<project_root>/.claude/skills/run-sql`

## 前置條件

1. 安裝 Python 依賴：
   ```bash
   pip install -r .claude/skills/run-sql/scripts/requirements.txt
   ```
2. 在 `scripts/` 目錄下建立 `.env`（從範本複製）：
   ```bash
   cp .claude/skills/run-sql/scripts/.env.example .claude/skills/run-sql/scripts/.env
   ```
   然後編輯 `.env` 填入連線資訊：
   ```
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=<密碼>
   DB_NAME=<預設資料庫>
   ```

## 執行流程

### Step 1: 確認參數

向使用者確認以下資訊：
- **SQL 檔案路徑**（必填）：一個或多個 `.sql` 檔案的路徑
- **Database 名稱**（選填）：限定 SQL 執行的資料庫範圍，未指定則從 `.env` 讀取
- **錯誤處理策略**（選填）：`exit`（預設，遇錯停止）或 `continue`（遇錯繼續）

### Step 2: Dry Run 預覽

先用 `--dry-run` 預覽將執行的 SQL 語句，讓使用者確認：

```bash
python .claude/skills/run-sql/scripts/run_sql.py \
  --env-file .claude/skills/run-sql/scripts/.env \
  --dry-run [--db <database>] <sql_files...>
```

展示預覽結果，請使用者確認是否執行。

### Step 3: 正式執行

使用者確認後，移除 `--dry-run` 正式執行：

```bash
python .claude/skills/run-sql/scripts/run_sql.py \
  --env-file .claude/skills/run-sql/scripts/.env \
  [--db <database>] [--on-error continue|exit] <sql_files...>
```

### Step 4: 回報結果

回報執行結果，包含：
- 成功 / 失敗語句數
- 若有錯誤，列出錯誤摘要

## 命令列參數參考

| 參數 | 說明 | 預設值 |
|------|------|--------|
| `sql_files` | SQL 檔案路徑（可多個） | （必填） |
| `--host` | MySQL 主機 | .env `DB_HOST` |
| `--port` | MySQL 埠號 | .env `DB_PORT` |
| `--user` | MySQL 使用者 | .env `DB_USER` |
| `--password` | MySQL 密碼 | .env `DB_PASSWORD` |
| `--db` | Database 名稱 | .env `DB_NAME` |
| `--on-error` | 錯誤策略：`exit` / `continue` | `exit` |
| `--env-file` | .env 檔案路徑 | `.env` |
| `--dry-run` | 僅預覽不執行 | false |

## 安全注意事項

- 執行前**務必先 dry-run** 預覽，避免誤操作
- `--db` 參數會在執行前 `USE <database>`，限定操作範圍
- 密碼不會顯示在輸出中
- 腳本使用 `autocommit=True`，每條語句立即生效
