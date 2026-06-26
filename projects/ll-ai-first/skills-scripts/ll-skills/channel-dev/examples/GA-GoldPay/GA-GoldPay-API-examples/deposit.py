"""
GoldPay 代收下單接口範例
POST /sha256/deposit
"""
import requests
from common import BASE_URL, MERCHANT_CODE, CALLBACK_URL, generate_sign, print_response


def deposit(order_no: str, amount: int, service_type: int,
            hashed_mem_id: str, bank_code: str = "",
            acct_name: str = "", acct_num: str = ""):
    """
    發起代收請求

    Args:
        order_no: 商戶訂單號（唯一）
        amount: 支付金額
        service_type: 服務類型（702=離線直連, 420=MoMo, 440=ZaloPay 等）
        hashed_mem_id: 會員唯一識別碼 Hash 值
        bank_code: 銀行代碼（service_type=22 時必填）
        acct_name: 用戶姓名（service_type=22 時必填）
        acct_num: 用戶帳號（service_type=22 時必填）
    """
    params = {
        "merchant_code": MERCHANT_CODE,
        "merchant_order_no": order_no,
        "amount": amount,
        "service_type": service_type,
        "hashed_mem_id": hashed_mem_id,
        "platform": "PC",
        "risk_level": 1,
    }

    if callback_url := CALLBACK_URL:
        params["callback_url"] = callback_url
    if bank_code:
        params["bank_code"] = bank_code
    if acct_name:
        params["acct_name"] = acct_name
    if acct_num:
        params["acct_num"] = acct_num

    params["sign"] = generate_sign(params)

    url = f"{BASE_URL}/sha256/deposit"
    print(f"POST {url}")
    resp = requests.post(url, data=params)
    print_response(resp)
    return resp


if __name__ == "__main__":
    # 範例：使用 service_type=702 (VN Deposit OFFLINE DIRECT)
    deposit(
        order_no="TEST_DEP_001",
        amount=100000,
        service_type=702,
        hashed_mem_id="member_hash_abc123",
    )
