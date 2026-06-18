"""
GB-EzPay 代付-餘額查詢 API 範例（選用）
接口：POST /api/payments/balance
分類：Q:查詢類接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, generate_sign, current_timestamp


def query_balance() -> dict:
    """
    查詢商戶代付餘額

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/payments/balance"

    sign_params = {
        "pay_customer_id": CUSTOMER_ID,
        "pay_apply_date": current_timestamp(),
    }

    sign = generate_sign(sign_params)
    payload = {**sign_params, "pay_md5_sign": sign}

    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()


if __name__ == "__main__":
    result = query_balance()
    print(json.dumps(result, indent=2, ensure_ascii=False))

    if result.get("code") == 0:
        balance = result.get("data", {}).get("balance", 0)
        print(f"\n商戶餘額: {balance}")
