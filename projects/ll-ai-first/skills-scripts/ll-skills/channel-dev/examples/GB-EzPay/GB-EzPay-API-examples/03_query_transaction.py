"""
GB-EzPay 代收-查詢訂單 API 範例
接口：POST /api/query_transaction
分類：Q:查詢類接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, generate_sign, current_timestamp

# 代收訂單狀態映射
STATUS_MAP = {
    0: "未處理（平台收到訂單，玩家尚未支付）",
    1: "成功，未返回（訂單成功，尚未成功通知商戶端）",
    2: "成功，已返回（訂單成功，成功通知商戶端）",
    3: "失敗，逾期失效（訂單過期，未收到款項）",
    4: "失敗，訂單金額不相符",
    5: "失敗，訂單異常（提單失敗）",
}


def query_pay_transaction(order_id: str) -> dict:
    """
    查詢代收訂單狀態

    Args:
        order_id: 商戶訂單號

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/query_transaction"

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
    result = query_pay_transaction("TEST_ORDER_001")
    print(json.dumps(result, indent=2, ensure_ascii=False))

    # 解析狀態
    if result.get("code") == 0:
        data = result.get("data", {})
        status = data.get("status", -1)
        print(f"\n訂單狀態: {STATUS_MAP.get(status, f'未知狀態({status})')}")
