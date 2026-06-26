#!/usr/bin/env python3
"""渠道資訊擷取腳本 - 從 MySQL 擷取指定渠道的配置、參數、模板、響應碼對照表"""

import argparse
import json
import os
import sys

import pymysql
from dotenv import load_dotenv


# ---------------------------------------------------------------------------
# SQL helpers
# ---------------------------------------------------------------------------

def format_sql_value(value):
    """將 Python 值格式化為 SQL 字面值"""
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    # 字串：轉義單引號
    s = str(value).replace("\\", "\\\\").replace("'", "\\'")
    return f"'{s}'"


def generate_replace_into(db_name, table, columns, rows):
    """產生 REPLACE INTO 語句"""
    col_list = ", ".join(f"`{c}`" for c in columns)
    header = f"REPLACE INTO `{db_name}`.`{table}` (\n    {col_list}\n) VALUES"

    value_lines = []
    for row in rows:
        vals = ", ".join(format_sql_value(row[c]) for c in columns)
        value_lines.append(f"({vals})")

    return header + "\n" + ",\n".join(value_lines) + ";\n"


# ---------------------------------------------------------------------------
# Extract: configs
# ---------------------------------------------------------------------------

def extract_configs(cursor, chnl_id, output_dir, db_name):
    """擷取渠道配置 (tbl_chnl_service_conf)"""
    cursor.execute(
        f"SELECT * FROM `{db_name}`.`tbl_chnl_service_conf` WHERE `chnl_id` = %s LIMIT 1000",
        (chnl_id,),
    )
    rows = cursor.fetchall()
    if not rows:
        print(f"  [configs] 無資料")
        return

    columns = [desc[0] for desc in cursor.description]
    dest = os.path.join(output_dir, "configs")
    os.makedirs(dest, exist_ok=True)

    # --- SQL ---
    sql_path = os.path.join(dest, f"{chnl_id}-config.sql")
    with open(sql_path, "w", encoding="utf-8") as f:
        f.write(generate_replace_into(db_name, "tbl_chnl_service_conf", columns, rows))
    print(f"  [configs] {sql_path}")

    # --- Markdown ---
    md_path = os.path.join(dest, f"{chnl_id}-config.md")
    # 表格要顯示的欄位（排除 ext_config）
    table_cols = [
        "chnl_id", "txn_type", "chnl_svc_type", "svc_addr", "svc_interactive",
        "svc_invoke", "bypass_chnl_http_status", "allow_notify", "svc_state",
        "jar_file_name", "protocol_ver", "tags", "memo",
    ]
    # 只保留實際存在的欄位
    table_cols = [c for c in table_cols if c in columns]

    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"## {chnl_id}\n\n")

        # Section 1: Channel Config 表格
        f.write("### 1. Channel Config\n\n")
        f.write("| " + " | ".join(table_cols) + " |\n")
        f.write("| " + " | ".join("---" for _ in table_cols) + " |\n")
        for row in rows:
            vals = []
            for c in table_cols:
                v = row[c]
                vals.append(str(v) if v is not None else "")
            f.write("| " + " | ".join(vals) + " |\n")

        # Section 2: Channel Extend Config
        f.write("\n### 2. Channel Extend Config\n\n")
        for row in rows:
            ext = row.get("ext_config")
            f.write(f"chnl_id: {row['chnl_id']}\n")
            f.write(f"txn_type: {row.get('txn_type', '')}\n")
            f.write("ext_config:\n")
            if ext:
                try:
                    parsed = json.loads(ext)
                    f.write("```json\n")
                    f.write(json.dumps(parsed, indent=4, ensure_ascii=False))
                    f.write("\n```\n\n")
                except json.JSONDecodeError:
                    f.write(f"```\n{ext}\n```\n\n")
            else:
                f.write("```\n(empty)\n```\n\n")

    print(f"  [configs] {md_path}")


# ---------------------------------------------------------------------------
# Extract: params
# ---------------------------------------------------------------------------

def mask_sec_value(value):
    """將機敏參數值隱碼，格式：senc.v1::前4碼......後4碼"""
    if value is None:
        return value
    s = str(value)
    if len(s) <= 8:
        return "senc.v1::******"
    return f"senc.v1::{s[:4]}......{s[-4:]}"


def mask_params_rows(rows):
    """回傳隱碼後的 rows（param_cat == 'SEC' 的 param_value 會被遮蔽）"""
    masked = []
    for row in rows:
        if row.get("param_cat") == "SEC":
            row = dict(row)
            row["param_value"] = mask_sec_value(row.get("param_value"))
        masked.append(row)
    return masked


def extract_params(cursor, chnl_id, output_dir, db_name):
    """擷取渠道參數 (tbl_mer_params)"""
    cursor.execute(
        f"SELECT * FROM `{db_name}`.`tbl_mer_params` WHERE `chnl_id` = %s LIMIT 1000",
        (chnl_id,),
    )
    rows = cursor.fetchall()
    if not rows:
        print(f"  [params] 無資料")
        return

    columns = [desc[0] for desc in cursor.description]
    dest = os.path.join(output_dir, "params")
    os.makedirs(dest, exist_ok=True)

    masked_rows = mask_params_rows(rows)

    # --- SQL ---
    sql_path = os.path.join(dest, f"{chnl_id}-params.sql")
    with open(sql_path, "w", encoding="utf-8") as f:
        f.write(generate_replace_into(db_name, "tbl_mer_params", columns, masked_rows))
    print(f"  [params] {sql_path}")

    # --- Markdown ---
    md_path = os.path.join(dest, f"{chnl_id}-params.md")
    table_cols = [
        "chnl_id", "mchnt_cd", "param_cat", "param_id", "param_value",
        "orderSeq", "param_desc", "last_oper_id", "param_st",
    ]
    table_cols = [c for c in table_cols if c in columns]

    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"## {chnl_id}\n\n")
        f.write("### Channel Params\n\n")
        f.write("| " + " | ".join(table_cols) + " |\n")
        f.write("| " + " | ".join("---" for _ in table_cols) + " |\n")
        for row in masked_rows:
            vals = []
            for c in table_cols:
                v = row[c]
                vals.append(str(v).replace("|", "\\|") if v is not None else "")
            f.write("| " + " | ".join(vals) + " |\n")

    print(f"  [params] {md_path}")


# ---------------------------------------------------------------------------
# Extract: templates
# ---------------------------------------------------------------------------

def extract_templates(cursor, chnl_id, output_dir, db_name):
    """擷取報文模板 (tbl_chnl_template)"""
    cursor.execute(
        f"SELECT * FROM `{db_name}`.`tbl_chnl_template` WHERE `catalog` = %s LIMIT 500",
        (chnl_id,),
    )
    rows = cursor.fetchall()
    if not rows:
        print(f"  [templates] 無資料")
        return

    columns = [desc[0] for desc in cursor.description]
    dest = os.path.join(output_dir, "templates")
    os.makedirs(dest, exist_ok=True)

    # --- SQL ---
    sql_path = os.path.join(dest, f"{chnl_id}-templates.sql")
    with open(sql_path, "w", encoding="utf-8") as f:
        f.write(generate_replace_into(db_name, "tbl_chnl_template", columns, rows))
    print(f"  [templates] {sql_path}")

    # --- FTL files ---
    ftl_dest = os.path.join(dest, "templates")
    os.makedirs(ftl_dest, exist_ok=True)
    ftl_files = []
    for row in rows:
        template_id = row.get("template_id", "")
        template_content = row.get("template", "")
        if template_id:
            # template_id 本身可能已含 .ftl，若無則加上
            fname = template_id if template_id.endswith(".ftl") else f"{template_id}.ftl"
            ftl_path = os.path.join(ftl_dest, fname)
            with open(ftl_path, "w", encoding="utf-8") as f:
                f.write(template_content or "")
            ftl_files.append(fname)
            print(f"  [templates] {ftl_path}")

    # --- Markdown ---
    md_path = os.path.join(dest, f"{chnl_id}-templates.md")
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"## {chnl_id}\n\n")
        f.write("### Channel Templates\n\n")
        f.write(f"共 {len(ftl_files)} 個模板檔案：\n\n")
        for fname in ftl_files:
            memo = ""
            for row in rows:
                tid = row.get("template_id", "")
                if tid == fname or (not fname.endswith(".ftl") and tid == fname):
                    memo = row.get("memo", "") or ""
                    break
            f.write(f"- `{fname}`")
            if memo:
                f.write(f" — {memo}")
            f.write("\n")

    print(f"  [templates] {md_path}")


# ---------------------------------------------------------------------------
# Extract: responses (translate)
# ---------------------------------------------------------------------------

def extract_responses(cursor, chnl_id, output_dir, db_name):
    """擷取響應碼對照表 (tbl_chnl_translate)"""
    cursor.execute(
        f"SELECT * FROM `{db_name}`.`tbl_chnl_translate` WHERE `chnl_id` = %s LIMIT 500",
        (chnl_id,),
    )
    rows = cursor.fetchall()
    if not rows:
        print(f"  [responses] 無資料")
        return

    columns = [desc[0] for desc in cursor.description]
    dest = os.path.join(output_dir, "responses")
    os.makedirs(dest, exist_ok=True)

    # --- SQL ---
    sql_path = os.path.join(dest, f"{chnl_id}-translate.sql")
    with open(sql_path, "w", encoding="utf-8") as f:
        f.write(generate_replace_into(db_name, "tbl_chnl_translate", columns, rows))
    print(f"  [responses] {sql_path}")

    # --- Markdown ---
    md_path = os.path.join(dest, f"{chnl_id}-translate.md")
    table_cols = [
        "chnl_id", "class_name", "catalog", "src_code", "dest_code",
        "dest_msg", "memo",
    ]
    table_cols = [c for c in table_cols if c in columns]

    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"## {chnl_id}\n\n")
        f.write("### Channel Translate\n\n")
        f.write("| " + " | ".join(table_cols) + " |\n")
        f.write("| " + " | ".join("---" for _ in table_cols) + " |\n")
        for row in rows:
            vals = []
            for c in table_cols:
                v = row[c]
                vals.append(str(v).replace("|", "\\|") if v is not None else "")
            f.write("| " + " | ".join(vals) + " |\n")

    print(f"  [responses] {md_path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    load_dotenv()

    parser = argparse.ArgumentParser(description="擷取渠道資訊並輸出 SQL / Markdown / ftl 檔案")
    parser.add_argument("chnl_id", help="渠道編號（如 FY, FX, 99）")
    parser.add_argument("--host", default=os.getenv("DB_HOST", "localhost"))
    parser.add_argument("--port", type=int, default=int(os.getenv("DB_PORT", "3306")))
    parser.add_argument("--user", default=os.getenv("DB_USER", "root"))
    parser.add_argument("--password", default=os.getenv("DB_PASSWORD", ""))
    parser.add_argument("--database", default=os.getenv("DB_NAME", "icpay"))
    parser.add_argument("--output-dir", default="./channels")
    args = parser.parse_args()

    chnl_id = args.chnl_id
    output_dir = os.path.join(args.output_dir, chnl_id)
    db_name = args.database

    print(f"渠道: {chnl_id}")
    print(f"資料庫: {args.host}:{args.port}/{db_name}")
    print(f"輸出目錄: {output_dir}")
    print()

    try:
        conn = pymysql.connect(
            host=args.host,
            port=args.port,
            user=args.user,
            password=args.password,
            database=db_name,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
        )
    except pymysql.Error as e:
        print(f"資料庫連線失敗: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        with conn.cursor() as cursor:
            extract_configs(cursor, chnl_id, output_dir, db_name)
            extract_params(cursor, chnl_id, output_dir, db_name)
            extract_templates(cursor, chnl_id, output_dir, db_name)
            extract_responses(cursor, chnl_id, output_dir, db_name)
    finally:
        conn.close()

    print(f"\n完成！檔案已輸出至 {output_dir}")


if __name__ == "__main__":
    main()
