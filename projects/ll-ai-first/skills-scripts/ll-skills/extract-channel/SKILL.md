---
name: extract-channel
description: >
  Extract payment channel configuration from MySQL database by channel ID (chnl_id).
  Outputs SQL (REPLACE INTO), Markdown summaries, and FTL template files.
  Use when user says "extract channel", "dump channel from db", "由數據庫擷取渠道",
  or provides a channel ID like FY, FX, 99 and wants its config/params/templates/responses exported.
---

# Extract Channel

從 MySQL 資料庫擷取指定渠道的配置資訊，輸出 SQL / Markdown / FTL 檔案。

## Prerequisites

- Python 3 with `pymysql` and `python-dotenv` installed
- A `.env` file in the working directory containing DB connection info:
  ```
  DB_HOST=<host>
  DB_PORT=<port>
  DB_USER=<user>
  DB_PASSWORD=<password>
  DB_NAME=icpay
  ```

## Usage

Run the bundled script with a channel ID:

```bash
python3 {SKILL_DIR}/scripts/extract_channel.py <chnl_id> [--output-dir ./channels]
```

**Arguments:**
- `chnl_id` (required): Channel ID, e.g. `FY`, `FX`, `99`
- `--output-dir`: Output directory (default: `./channels`)
- `--host`, `--port`, `--user`, `--password`, `--database`: Override `.env` values

## Output Structure

```
./channels/<chnl_id>/
├── configs/
│   ├── <chnl_id>-config.sql      # REPLACE INTO SQL
│   └── <chnl_id>-config.md       # Config summary + ext_config JSON
├── params/
│   ├── <chnl_id>-params.sql
│   └── <chnl_id>-params.md
├── templates/
│   ├── <chnl_id>-templates.sql
│   ├── <chnl_id>-templates.md
│   └── templates/                 # Individual .ftl files
│       ├── txn_req.ftl
│       └── ...
└── responses/
    ├── <chnl_id>-translate.sql
    └── <chnl_id>-translate.md
```

## Workflow

1. Verify `.env` exists in the working directory; if not, prompt user for DB connection info
2. Run the script: `python3 {SKILL_DIR}/scripts/extract_channel.py <chnl_id>`
3. Report output file paths and any errors to the user
4. If user wants to review the output, read the generated Markdown files

## Data Sources

| Table | Content | Query Key |
|-------|---------|-----------|
| `tbl_chnl_service_conf` | Channel config + ext_config | `chnl_id` |
| `tbl_mer_params` | Channel parameters | `chnl_id` |
| `tbl_chnl_template` | Message templates (FTL) | `catalog` |
| `tbl_chnl_translate` | Response code mapping | `chnl_id` |
