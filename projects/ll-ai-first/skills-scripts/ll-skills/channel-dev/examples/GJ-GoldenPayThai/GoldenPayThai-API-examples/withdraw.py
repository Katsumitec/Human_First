"""
GoldenPay 泰國 代付下單範例（5210）

接口：POST {BASE_URL}/api/v1/mch/wdl-orders
"""
from __future__ import annotations

import sys
import requests

from common import (
    get_config, gen_nonce, unix_ts,
    sign_with_source, print_request, print_response,
)


def build_withdraw_params(
    trans_id: str,
    amount: str,
    *,
    account_no: str,
    account_name: str,
    account_org: str,
    account_org_code: str,
) -> dict:
    c = get_config()
    return {
        "mch_id": c["MCH_ID"],
        "trans_id": trans_id,
        "channel": c["CHANNEL"],            # bank / truemoney / mock
        "amount": amount,                    # 字串法幣單位
        "currency": c["CURRENCY"],           # THB
        "account_no": account_no,
        "account_name": account_name,
        "account_org": account_org,
        "account_org_code": account_org_code,
        "callback_url": c["CALLBACK_URL"],
        "nonce": gen_nonce(),
        "timestamp": unix_ts(),
    }


def place_withdraw_order(params: dict) -> requests.Response:
    c = get_config()
    signature, source = sign_with_source(params, c["API_TOKEN"])
    body = {**params, "sign": signature}

    url = c["BASE_URL"].rstrip("/") + c["URL_WITHDRAW"]
    print_request(url, body, source, signature)

    resp = requests.post(url, json=body, timeout=30)
    print_response(resp)
    return resp


if __name__ == "__main__":
    trans_id = sys.argv[1] if len(sys.argv) > 1 else f"WD{unix_ts()}"
    amount = sys.argv[2] if len(sys.argv) > 2 else "500.00"

    params = build_withdraw_params(
        trans_id=trans_id,
        amount=amount,
        account_no="1234567890",
        account_name="SOMCHAI SUKPAN",
        account_org="KBANK",
        account_org_code="KBANK",
    )
    place_withdraw_order(params)
