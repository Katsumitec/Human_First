"""GG-NewSKYpay 訂單查詢範例（含代收與代付）。

代收查單：POST /hpay/dt/vnd/query
代付查單：POST /hpay/wd/vnd/query
餘額查詢：POST /hpay/merchant/balance
"""
from __future__ import annotations

from datetime import datetime, timezone, timedelta
from typing import Any, Mapping

from common import (
    BALANCE_SIGN_FIELDS,
    DEPOSIT_QUERY_SIGN_FIELDS,
    WITHDRAW_QUERY_SIGN_FIELDS,
    load_config,
    post_json,
    pretty_print_request,
    pretty_print_response,
    sign_payload,
)


def query_deposit(cfg: Mapping[str, str], merchant_order_id: str,
                  pay_amount: int) -> dict[str, Any]:
    url = cfg["BASE_URL"].rstrip("/") + cfg["DEPOSIT_QUERY_PATH"]
    payload: dict[str, Any] = {
        "merchantId": int(cfg["MERCHANT_ID"]),
        "merchantOrderId": merchant_order_id,
        "payAmount": pay_amount,
    }
    payload["sign"] = sign_payload(payload, DEPOSIT_QUERY_SIGN_FIELDS, cfg["MERCHANT_KEY"])
    pretty_print_request("代收查單請求 (query_deposit)", url, payload)
    result = post_json(url, payload)
    pretty_print_response("代收查單響應 (query_deposit)", result)
    return result


def query_withdraw(cfg: Mapping[str, str], merchant_order_id: str,
                   pay_amount: int) -> dict[str, Any]:
    url = cfg["BASE_URL"].rstrip("/") + cfg["WITHDRAW_QUERY_PATH"]
    payload: dict[str, Any] = {
        "merchantId": int(cfg["MERCHANT_ID"]),
        "merchantOrderId": merchant_order_id,
        "payAmount": pay_amount,
    }
    payload["sign"] = sign_payload(payload, WITHDRAW_QUERY_SIGN_FIELDS, cfg["MERCHANT_KEY"])
    pretty_print_request("代付查單請求 (query_withdraw)", url, payload)
    result = post_json(url, payload)
    pretty_print_response("代付查單響應 (query_withdraw)", result)
    return result


def query_balance(cfg: Mapping[str, str]) -> dict[str, Any]:
    url = cfg["BASE_URL"].rstrip("/") + cfg["BALANCE_PATH"]
    # time 格式：yyyyMMddHH（東 8 區或當地，依文檔未指定，採 UTC+7 越南時區）
    vn_now = datetime.now(timezone(timedelta(hours=7)))
    payload: dict[str, Any] = {
        "merchantId": int(cfg["MERCHANT_ID"]),
        "time": vn_now.strftime("%Y%m%d%H"),
    }
    payload["sign"] = sign_payload(payload, BALANCE_SIGN_FIELDS, cfg["MERCHANT_KEY"])
    pretty_print_request("餘額查詢請求 (query_balance)", url, payload)
    result = post_json(url, payload)
    pretty_print_response("餘額查詢響應 (query_balance)", result)
    return result


# ---------- 訂單狀態判定輔助 ----------

ORDER_STATUS_MAP = {
    "0": "創建（處理中）",
    "1": "處理中",
    "3": "成功（最終）",
    "8": "失敗（最終）",
}


def is_terminal(order_status: Any) -> bool:
    """是否為最終態（3 成功 / 8 失敗）。"""
    return str(order_status).strip() in {"3", "8"}


def is_success(order_status: Any) -> bool:
    return str(order_status).strip() == "3"


if __name__ == "__main__":
    cfg = load_config()
    if not cfg.get("MERCHANT_KEY") or cfg["MERCHANT_KEY"].startswith("__REPLACE"):
        print("[警告] 尚未設定 MERCHANT_KEY，請先複製 .env.example 為 .env 並填入真實值。")

    moid = cfg["TEST_MERCHANT_ORDER_ID"]
    amt = int(cfg["TEST_PAY_AMOUNT"])

    print("\n--- 1. 代收查單 ---")
    query_deposit(cfg, moid + "_DEP", amt)

    print("\n--- 2. 代付查單 ---")
    query_withdraw(cfg, moid + "_WD", amt)

    print("\n--- 3. 餘額查詢 ---")
    query_balance(cfg)
