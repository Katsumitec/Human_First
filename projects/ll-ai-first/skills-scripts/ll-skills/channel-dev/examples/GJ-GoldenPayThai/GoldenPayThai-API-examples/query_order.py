"""
GoldenPay 泰國 訂單查詢範例

代收查詢：GET {BASE_URL}/api/v1/mch/pmt-orders?id=...&mch_id=...&nonce=...&timestamp=...&sign=...
代付查詢：GET {BASE_URL}/api/v1/mch/wdl-orders?id=...&mch_id=...&nonce=...&timestamp=...&sign=...
"""
from __future__ import annotations

import sys
import requests

from common import (
    get_config, gen_nonce, unix_ts,
    sign_with_source, print_request, print_response,
)


def build_query_params(order_id: str) -> dict:
    c = get_config()
    return {
        "id": order_id,
        "mch_id": c["MCH_ID"],
        "nonce": gen_nonce(),
        "timestamp": unix_ts(),
    }


def query(order_id: str, kind: str = "deposit") -> requests.Response:
    c = get_config()
    params = build_query_params(order_id)
    signature, source = sign_with_source(params, c["API_TOKEN"])
    full_params = {**params, "sign": signature}

    path = c["URL_DEPOSIT_QUERY"] if kind == "deposit" else c["URL_WITHDRAW_QUERY"]
    url = c["BASE_URL"].rstrip("/") + path
    print_request(url, full_params, source, signature)

    resp = requests.get(url, params=full_params, timeout=30)
    print_response(resp)
    return resp


def query_deposit(order_id: str) -> requests.Response:
    return query(order_id, kind="deposit")


def query_withdraw(order_id: str) -> requests.Response:
    return query(order_id, kind="withdraw")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法：python query_order.py <order_id> [deposit|withdraw]")
        sys.exit(1)

    order_id = sys.argv[1]
    kind = sys.argv[2] if len(sys.argv) > 2 else "deposit"
    query(order_id, kind)
