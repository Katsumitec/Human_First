"""
GoldenPay 泰國 代收下單範例（0121 / 013d）

接口：POST {BASE_URL}/api/v1/mch/pmt-orders
"""
from __future__ import annotations

import sys
import requests

from common import (
    get_config, gen_nonce, unix_ts,
    sign_with_source, print_request, print_response,
)


def build_deposit_params(
    trans_id: str,
    amount: str,
    *,
    payer_account_no: str,
    payer_account_name: str,
    payer_account_org: str,
    mode: str = "auto",
) -> dict:
    c = get_config()
    return {
        "mch_id": c["MCH_ID"],
        "trans_id": trans_id,
        "currency": c["CURRENCY"],          # THB
        "amount": amount,                    # 字串，如 "100.00"
        "channel": c["CHANNEL"],             # bank / truemoney / mock
        "payer_account_no": payer_account_no,
        "payer_account_name": payer_account_name,
        "payer_account_org": payer_account_org,
        "callback_url": c["CALLBACK_URL"],
        "return_url": c["RETURN_URL"],
        "mode": mode,
        "nonce": gen_nonce(),
        "timestamp": unix_ts(),
    }


def place_deposit_order(params: dict) -> requests.Response:
    c = get_config()
    signature, source = sign_with_source(params, c["API_TOKEN"])
    body = {**params, "sign": signature}

    url = c["BASE_URL"].rstrip("/") + c["URL_DEPOSIT"]
    print_request(url, body, source, signature)

    resp = requests.post(url, json=body, timeout=30)
    print_response(resp)
    return resp


if __name__ == "__main__":
    trans_id = sys.argv[1] if len(sys.argv) > 1 else f"TEST{unix_ts()}"
    amount = sys.argv[2] if len(sys.argv) > 2 else "100.00"

    params = build_deposit_params(
        trans_id=trans_id,
        amount=amount,
        payer_account_no="1234567890",
        payer_account_name="SOMCHAI SUKPAN",
        payer_account_org="KBANK",
    )
    place_deposit_order(params)
