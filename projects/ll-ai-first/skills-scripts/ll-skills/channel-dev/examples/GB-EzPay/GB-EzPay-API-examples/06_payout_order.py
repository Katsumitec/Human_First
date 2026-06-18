"""
GB-EzPay 代付-申請下單 API 範例
接口：POST /api/payments/pay_order
分類：W:代付類接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, NOTIFY_URL, generate_sign, current_timestamp


def create_payout_order(
    order_id: str,
    amount: float,
    account_name: str,
    card_no: str,
    bank_name: str,
    sub_branch: str = "",
    city: str = "",
    validate_id: str = "",
    pay_currency: str = "",
) -> dict:
    """
    發起代付（出金）下單請求

    Args:
        order_id: 商戶訂單號（最大 32 字符）
        amount: 下單金額（支持小數至 2 位）
        account_name: 銀行卡持有人姓名（USDT 模式：玩家名稱）
        card_no: 銀行卡號（USDT 模式：錢包地址）
        bank_name: 銀行名稱（USDT 模式：USDT）
        sub_branch: 銀行支行（印度幣別 IFSC Code 必填）
        city: 銀行卡所屬城市
        validate_id: 查核編碼（僅部分通道支持）
        pay_currency: 貨幣轉換（如 CNYUSDT）

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/payments/pay_order"

    sign_params = {
        "pay_customer_id": CUSTOMER_ID,
        "pay_apply_date": current_timestamp(),
        "pay_order_id": order_id,
        "pay_notify_url": NOTIFY_URL,
        "pay_amount": amount,
        "pay_account_name": account_name,
        "pay_card_no": card_no,
        "pay_bank_name": bank_name,
    }

    # 選填參數
    if sub_branch:
        sign_params["pay_sub_branch"] = sub_branch
    if city:
        sign_params["pay_city"] = city
    if validate_id:
        sign_params["pay_validate_id"] = validate_id
    if pay_currency:
        sign_params["pay_currency"] = pay_currency

    sign = generate_sign(sign_params)
    payload = {**sign_params, "pay_md5_sign": sign}

    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()


if __name__ == "__main__":
    result = create_payout_order(
        order_id="PAYOUT_ORDER_001",
        amount=500.00,
        account_name="Nguyen Van A",
        card_no="1234567890123",
        bank_name="VIETCOMBANK",
        sub_branch="Ho Chi Minh Branch",
        city="Ho Chi Minh",
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))
