"""
GB-EzPay 代付-查詢訂單 API 範例
接口：POST /api/payments/query_transaction
分類：Q:查詢類接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, generate_sign, current_timestamp

# 代付訂單狀態映射
PAYOUT_STATUS_MAP = {
    0: "未處理",
    1: "處理中",
    2: "已打款",
    3: "已駁回沖正",
    4: "核實不成功",
    5: "餘額不足",
}


def query_payout_transaction(order_id: str) -> dict:
    """
    查詢代付訂單狀態

    Args:
        order_id: 商戶訂單號

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/payments/query_transaction"

    sign_params = {
        "pay_customer_id": CUSTOMER_ID,
        "pay_apply_date": current_timestamp(),
        "pay_order_id": order_id,
    }

    sign = generate_sign(sign_params)
    payload = {**sign_params, "pay_md5_sign": sign}

    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()


if __name__ == "__main__":
    result = query_payout_transaction("PAYOUT_ORDER_001")
    print(json.dumps(result, indent=2, ensure_ascii=False))

    # 解析狀態
    if result.get("code") == 0:
        data = result.get("data", {})
        status = data.get("status", -1)
        status_name = data.get("status_name", "")
        print(f"\n訂單狀態: {PAYOUT_STATUS_MAP.get(status, status_name)}")
