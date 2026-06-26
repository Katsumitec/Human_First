"""
GoldPay 代付下單接口範例
POST /sha256/withdraw
"""
import requests
from common import BASE_URL, MERCHANT_CODE, CALLBACK_URL, generate_sign, print_response


def withdraw(order_no: str, amount: int, service_type: int,
             bank_code: str, card_name: str, card_num: str,
             merchant_user: str, mobile_no: str):
    """
    發起代付請求

    Args:
        order_no: 商戶訂單號（唯一）
        amount: 提現金額
        service_type: 服務類型（700=VN Withdraw）
        bank_code: 銀行代碼
        card_name: 銀行卡姓名
        card_num: 銀行卡號
        merchant_user: 商戶會員真實姓名
        mobile_no: 手機號（service_type=700 時 mobile_no = card_num）
    """
    params = {
        "merchant_code": MERCHANT_CODE,
        "merchant_order_no": order_no,
        "amount": amount,
        "service_type": service_type,
        "bank_code": bank_code,
        "card_name": card_name,
        "card_num": card_num,
        "merchant_user": merchant_user,
        "mobile_no": mobile_no,
        "platform": "PC",
        "risk_level": 1,
    }

    if callback_url := CALLBACK_URL:
        params["callback_url"] = callback_url

    params["sign"] = generate_sign(params)

    url = f"{BASE_URL}/sha256/withdraw"
    print(f"POST {url}")
    resp = requests.post(url, data=params)
    print_response(resp)
    return resp


if __name__ == "__main__":
    # 範例：使用 service_type=700 (VN Withdraw)
    withdraw(
        order_no="TEST_WD_001",
        amount=500000,
        service_type=700,
        bank_code="9003",        # MBBank
        card_name="NGUYEN VAN A",
        card_num="1234567890",
        merchant_user="NGUYEN VAN A",
        mobile_no="1234567890",  # service_type=700 時等於 card_num
    )
