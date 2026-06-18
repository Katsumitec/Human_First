#!/usr/bin/env python3
"""MySQL SQL 腳本執行工具 - 透過命令列參數執行 SQL 腳本檔案"""

import argparse
import os
import sys
import time

import pymysql
import sqlparse
from dotenv import load_dotenv


def parse_args():
    parser = argparse.ArgumentParser(
        description="執行 MySQL SQL 腳本檔案",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
範例:
  python run_sql.py schema.sql data.sql
  python run_sql.py --db icpay --on-error continue schema.sql
  python run_sql.py --host 10.0.0.1 --port 3307 --user admin schema.sql
        """,
    )
    parser.add_argument("sql_files", nargs="+", help="SQL 檔案路徑（可多個）")
    parser.add_argument("--host", default=None, help="MySQL 主機（預設從 .env 讀取）")
    parser.add_argument("--port", type=int, default=None, help="MySQL 埠號（預設從 .env 讀取）")
    parser.add_argument("--user", default=None, help="MySQL 使用者（預設從 .env 讀取）")
    parser.add_argument("--password", default=None, help="MySQL 密碼（預設從 .env 讀取）")
    parser.add_argument("--db", default=None, help="Database 名稱，限定執行範圍（預設從 .env 的 DB_NAME 讀取）")
    parser.add_argument(
        "--on-error",
        choices=["exit", "continue"],
        default="exit",
        help="錯誤處理策略：exit=報錯退出（預設），continue=繼續執行",
    )
    parser.add_argument("--env-file", default=".env", help=".env 檔案路徑（預設為 .env）")
    parser.add_argument("--dry-run", action="store_true", help="僅顯示將執行的 SQL，不實際執行")
    return parser.parse_args()


def get_connection_params(args):
    """從 .env 與命令列參數取得連線資訊，命令列參數優先"""
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), args.env_file)
    if os.path.exists(env_path):
        load_dotenv(env_path)
    elif os.path.exists(args.env_file):
        load_dotenv(args.env_file)

    return {
        "host": args.host or os.getenv("DB_HOST", "127.0.0.1"),
        "port": args.port or int(os.getenv("DB_PORT", "3306")),
        "user": args.user or os.getenv("DB_USER", "root"),
        "password": args.password or os.getenv("DB_PASSWORD", ""),
        "database": args.db or os.getenv("DB_NAME"),
    }


def split_statements(sql_text):
    """使用 sqlparse 分割 SQL 語句，過濾空白與純註解"""
    statements = sqlparse.split(sql_text)
    result = []
    for stmt in statements:
        stripped = stmt.strip()
        if not stripped:
            continue
        # 過濾純註解（只有 -- 或 /* */ 開頭且無實際 SQL）
        parsed = sqlparse.parse(stripped)[0]
        has_real_token = any(
            t.ttype not in (sqlparse.tokens.Comment.Single, sqlparse.tokens.Comment.Multiline, sqlparse.tokens.Newline, sqlparse.tokens.Whitespace)
            for t in parsed.flatten()
        )
        if has_real_token:
            result.append(stripped)
    return result


def execute_sql_file(cursor, filepath, on_error):
    """執行單一 SQL 檔案，回傳 (成功數, 失敗數, 錯誤列表)"""
    with open(filepath, "r", encoding="utf-8") as f:
        sql_text = f.read()

    statements = split_statements(sql_text)
    success_count = 0
    fail_count = 0
    errors = []

    for i, stmt in enumerate(statements, 1):
        stmt_preview = stmt[:80].replace("\n", " ")
        try:
            cursor.execute(stmt)
            affected = cursor.rowcount
            print(f"  [OK] 語句 #{i}: {stmt_preview}...  (affected: {affected})")
            success_count += 1
        except pymysql.Error as e:
            fail_count += 1
            err_msg = f"語句 #{i}: {e}"
            errors.append(err_msg)
            print(f"  [FAIL] {err_msg}")
            print(f"         SQL: {stmt_preview}...")
            if on_error == "exit":
                raise

    return success_count, fail_count, errors


def main():
    args = parse_args()

    # 檢查 SQL 檔案是否存在
    for filepath in args.sql_files:
        if not os.path.isfile(filepath):
            print(f"[ERROR] SQL 檔案不存在: {filepath}")
            sys.exit(1)

    conn_params = get_connection_params(args)

    # 顯示連線資訊（隱藏密碼）
    db_display = conn_params["database"] or "(未指定)"
    print(f"連線目標: {conn_params['user']}@{conn_params['host']}:{conn_params['port']}")
    print(f"Database: {db_display}")
    print(f"錯誤策略: {args.on_error}")
    print(f"SQL 檔案: {', '.join(args.sql_files)}")
    print("-" * 60)

    if args.dry_run:
        for filepath in args.sql_files:
            print(f"\n=== [DRY RUN] {filepath} ===")
            with open(filepath, "r", encoding="utf-8") as f:
                statements = split_statements(f.read())
            for i, stmt in enumerate(statements, 1):
                print(f"  #{i}: {stmt[:120]}")
        print("\n[DRY RUN] 未實際執行任何 SQL")
        return

    # 建立連線
    try:
        conn = pymysql.connect(
            host=conn_params["host"],
            port=conn_params["port"],
            user=conn_params["user"],
            password=conn_params["password"],
            database=conn_params["database"],
            charset="utf8mb4",
            autocommit=True,
        )
    except pymysql.Error as e:
        print(f"[ERROR] 無法連線 MySQL: {e}")
        sys.exit(1)

    total_success = 0
    total_fail = 0
    all_errors = []
    start_time = time.time()

    try:
        with conn.cursor() as cursor:
            # 若有指定 database，再次確認切換
            if conn_params["database"]:
                cursor.execute(f"USE `{conn_params['database']}`")

            for filepath in args.sql_files:
                print(f"\n=== 執行: {filepath} ===")
                try:
                    s, f, errs = execute_sql_file(cursor, filepath, args.on_error)
                    total_success += s
                    total_fail += f
                    all_errors.extend(errs)
                except pymysql.Error:
                    # on_error=exit 時會拋出，中斷後續檔案
                    break
    finally:
        conn.close()

    elapsed = time.time() - start_time

    # 報告
    print("\n" + "=" * 60)
    print(f"執行完成 ({elapsed:.2f}s)")
    print(f"  成功: {total_success} 條語句")
    print(f"  失敗: {total_fail} 條語句")

    if all_errors:
        print("\n錯誤摘要:")
        for err in all_errors:
            print(f"  - {err}")
        sys.exit(1)
    else:
        print("\n全部執行成功！")


if __name__ == "__main__":
    main()
