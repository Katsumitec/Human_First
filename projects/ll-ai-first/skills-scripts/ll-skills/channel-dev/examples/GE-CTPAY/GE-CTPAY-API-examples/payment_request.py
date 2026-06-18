"""
CTPAY 代付請求範例
對應交易類型：5210
接口 URL：POST https://tianciv420428.com/api/payment
sign 為必填！
"""
import json
import os
import requests
from ctpay_utils import BASE_URL, build_headers, calc_sign
from dotenv import load_dotenv

load_dotenv()

CALLBACK_URL = os.getenv("CALLBACK_URL", "https://your-server.example.com/notify")


def payment_request(
    out_trade_no: str,
    bank_id: str,
    bank_owner: str,
    account_number: str,
    amount: float,
    callback_url: str = None,
) -> dict:
    """
    發起代付請求（5210）

    Args:
        out_trade_no: 商戶訂單號（唯一）
        bank_id: 收款銀行代碼（如 "ACB"）
        bank_owner: 收款人姓名
        account_number: 收款銀行卡號
        amount: 代付金額（VND）
        callback_url: 異步回調 URL

    Returns:
        渠道響應 dict
    """
    if callback_url is None:
        callback_url = CALLBACK_URL

    # 代付請求 body（VerifyChannelNo=1 為官方示例必帶字段）
    body = {
        "VerifyChannelNo": "1",
        "account_number": account_number,
        "amount": str(amount),
        "bank_id": bank_id,
        "bank_owner": bank_owner,
        "callback_url": callback_url,
        "out_trade_no": out_trade_no,
    }

    # 代付 sign 必填：對除 sign 外的所有字段計算簽名
    body["sign"] = calc_sign({k: v for k, v in body.items()})

    url = f"{BASE_URL}/api/payment"
    resp = requests.post(url, headers=build_headers(), json=body, timeout=30)
    resp.raise_for_status()
    return resp.json()


if __name__ == "__main__":
    result = payment_request(
        out_trade_no="PAY202603230001",
        bank_id="ACB",
        bank_owner="DAO VAN THANG",
        account_number="6212262000000000001",
        amount=500000,
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))

    if result.get("success"):
        data = result["data"]
        print(f"\n✅ 代付提交成功（狀態為處理中，等待回調確認）")
        print(f"  平台訂單號: {data.get('trade_no')}")
        print(f"  初始狀態: {data.get('state')}")
    else:
        print(f"\n❌ 代付提交失敗: {result}")
