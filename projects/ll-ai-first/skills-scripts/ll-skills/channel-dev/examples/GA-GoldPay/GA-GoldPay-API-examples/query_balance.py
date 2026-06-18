"""
GoldPay 餘額查詢接口範例
POST /sha256/balance
"""
import requests
from common import BASE_URL, MERCHANT_CODE, generate_sign, print_response


def query_balance(order_no: str = "-"):
    """
    查詢商戶帳戶餘額

    Args:
        order_no: 商戶訂單號（此接口需提供，可帶入 "-" 作為佔位符）

    注意：請勿在 5 秒內重複請求。
    """
    params = {
        "merchant_order_no": order_no,
        "merchant_code": MERCHANT_CODE,
    }
    params["sign"] = generate_sign(params)

    url = f"{BASE_URL}/sha256/balance"
    print(f"POST {url}")
    resp = requests.post(url, data=params)
    print_response(resp)
    return resp


if __name__ == "__main__":
    query_balance()
