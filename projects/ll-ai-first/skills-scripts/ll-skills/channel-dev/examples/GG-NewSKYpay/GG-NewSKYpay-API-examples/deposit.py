"""GG-NewSKYpay 代收（充值）下單範例。

接口：POST /hpay/dt/vnd/ct
Content-Type: application/json
"""
from __future__ import annotations

from typing import Any, Mapping

from common import (
    DEPOSIT_CT_SIGN_FIELDS,
    load_config,
    post_json,
    pretty_print_request,
    pretty_print_response,
    sign_payload,
)


def build_deposit_request(cfg: Mapping[str, str], merchant_order_id: str,
                          pay_amount: int) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "merchantId": int(cfg["MERCHANT_ID"]),
        "merchantOrderId": merchant_order_id,
        "payAmount": pay_amount,
        # payType 固定 1060（不參與簽名）
        "payType": int(cfg["PAY_TYPE"]),
        # 必填非簽名欄位
        "userId": cfg["TEST_USER_ID"],
        "notifyUrl": cfg["NOTIFY_URL"],
    }
    # 可選欄位（有值才帶；不影響簽名）
    if cfg.get("TEST_USER_IP"):
        payload["userIp"] = cfg["TEST_USER_IP"]
    if cfg.get("TEST_BANK_TYPE"):
        payload["bankType"] = cfg["TEST_BANK_TYPE"]

    payload["sign"] = sign_payload(payload, DEPOSIT_CT_SIGN_FIELDS, cfg["MERCHANT_KEY"])
    return payload


def submit_deposit(cfg: Mapping[str, str], merchant_order_id: str,
                   pay_amount: int) -> dict[str, Any]:
    url = cfg["BASE_URL"].rstrip("/") + cfg["DEPOSIT_CT_PATH"]
    payload = build_deposit_request(cfg, merchant_order_id, pay_amount)
    pretty_print_request("代收下單請求 (deposit)", url, payload)
    result = post_json(url, payload)
    pretty_print_response("代收下單響應 (deposit)", result)
    return result


if __name__ == "__main__":
    cfg = load_config()
    if not cfg.get("MERCHANT_KEY") or cfg["MERCHANT_KEY"].startswith("__REPLACE"):
        print("[警告] 尚未設定 MERCHANT_KEY，請先複製 .env.example 為 .env 並填入真實值。")
    submit_deposit(
        cfg,
        merchant_order_id=cfg["TEST_MERCHANT_ORDER_ID"] + "_DEP",
        pay_amount=int(cfg["TEST_PAY_AMOUNT"]),
    )
