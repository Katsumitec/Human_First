"""
CTPAY 代收請求範例（純卡網關）
對應交易類型：0121
接口 URL：POST https://tianciv420428.com/api/transaction
返回 data.qrcode 供自製收銀台展示
"""
import json
import os
import requests
from ctpay_utils import BASE_URL, build_headers, calc_sign
from dotenv import load_dotenv

load_dotenv()

CALLBACK_URL = os.getenv("CALLBACK_URL", "https://your-server.example.com/notify")


def collection_request(
    out_trade_no: str,
    amount: float,
    callback_url: str = None,
    bank_id: str = None,
    sign_request: bool = True,
) -> dict:
    """
    發起代收請求（純卡網關，0121）

    Args:
        out_trade_no: 商戶訂單號（唯一）
        amount: 支付請求金額（VND，如 500000）
        callback_url: 異步回調 URL（默認從 .env 讀取）
        bank_id: 銀行代碼（選填，如 "ACB"）
        sign_request: 是否帶 sign（API 選填，默認帶）

    Returns:
        渠道響應 dict
    """
    if callback_url is None:
        callback_url = CALLBACK_URL

    body = {
        "amount": str(amount),
        "out_trade_no": out_trade_no,
        "callback_url": callback_url,
    }

    if bank_id:
        body["bank_id"] = bank_id

    # sign 為選填，帶上可增加安全性
    if sign_request:
        sign_fields = {k: v for k, v in body.items()}
        body["sign"] = calc_sign(sign_fields)

    url = f"{BASE_URL}/api/transaction"
    resp = requests.post(url, headers=build_headers(), json=body, timeout=30)
    resp.raise_for_status()
    return resp.json()


if __name__ == "__main__":
    result = collection_request(
        out_trade_no="TEST202603230001",
        amount=500000,
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))

    if result.get("success"):
        data = result["data"]
        print(f"\n✅ 提交成功")
        print(f"  平台訂單號: {data.get('trade_no')}")
        print(f"  QR 碼內容 (data.qrcode): {data.get('qrcode')}")
        print(f"  收銀台 URL (data.uri): {data.get('uri')}")
    else:
        print(f"\n❌ 提交失敗: {result}")
