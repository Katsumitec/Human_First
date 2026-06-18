"""GG-NewSKYpay 代付（出款）下單範例。

接口：POST /hpay/wd/vnd/ct
Content-Type: application/json
"""
from __future__ import annotations

from typing import Any, Mapping

from common import (
    WITHDRAW_CT_SIGN_FIELDS,
    load_config,
    post_json,
    pretty_print_request,
    pretty_print_response,
    sign_payload,
)


def build_withdraw_request(cfg: Mapping[str, str], merchant_order_id: str,
                           pay_amount: int) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "merchantId": int(cfg["MERCHANT_ID"]),
        "merchantOrderId": merchant_order_id,
        "payAmount": pay_amount,
        "bankNum": cfg["TEST_BANK_NUM"],
        "bankAccount": cfg["TEST_BANK_ACCOUNT"],
        # 不參與簽名
        "bankType": cfg["TEST_BANK_TYPE"],
        "payType": int(cfg["PAY_TYPE"]),  # 固定 1060
        "notifyUrl": cfg["NOTIFY_URL"],
        # 反查地址：當上游發起反查時，會回調此處（由我方系統處理）
        "withdrawQueryUrl": cfg["QUERY_MERCHANT_ORDER_URL"],
    }
    if cfg.get("TEST_USER_ID"):
        payload["userId"] = cfg["TEST_USER_ID"]
    if cfg.get("TEST_USER_IP"):
        payload["userIp"] = cfg["TEST_USER_IP"]

    payload["sign"] = sign_payload(payload, WITHDRAW_CT_SIGN_FIELDS, cfg["MERCHANT_KEY"])
    return payload


def submit_withdraw(cfg: Mapping[str, str], merchant_order_id: str,
                    pay_amount: int) -> dict[str, Any]:
    url = cfg["BASE_URL"].rstrip("/") + cfg["WITHDRAW_CT_PATH"]
    payload = build_withdraw_request(cfg, merchant_order_id, pay_amount)
    pretty_print_request("代付下單請求 (withdraw)", url, payload)
    result = post_json(url, payload)
    pretty_print_response("代付下單響應 (withdraw)", result)
    return result


if __name__ == "__main__":
    cfg = load_config()
    if not cfg.get("MERCHANT_KEY") or cfg["MERCHANT_KEY"].startswith("__REPLACE"):
        print("[警告] 尚未設定 MERCHANT_KEY，請先複製 .env.example 為 .env 並填入真實值。")
    submit_withdraw(
        cfg,
        merchant_order_id=cfg["TEST_MERCHANT_ORDER_ID"] + "_WD",
        pay_amount=int(cfg["TEST_PAY_AMOUNT"]),
    )
