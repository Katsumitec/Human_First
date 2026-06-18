"""
GB-EzPay 代收-匯率查詢 API 範例（選用）
接口：POST /api/rate
分類：Q:查詢類接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, generate_sign, current_timestamp


def query_rate() -> dict:
    """
    查詢平台支持的貨幣匯率

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/rate"

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
    result = query_rate()
    print(json.dumps(result, indent=2, ensure_ascii=False))

    # 解析匯率列表
    if result.get("code") == 0:
        print("\n匯率列表:")
        for item in result.get("data", []):
            print(f"  {item['currency']}: {item['rate']}")
