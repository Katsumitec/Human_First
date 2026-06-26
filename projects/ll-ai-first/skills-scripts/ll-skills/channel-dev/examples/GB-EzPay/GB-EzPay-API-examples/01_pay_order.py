"""
GB-EzPay 代收-支付下單 API 範例
接口：POST /api/pay_order
分類：C:複合類代收接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, PAY_CHANNEL_ID, NOTIFY_URL, generate_sign, current_timestamp


def create_pay_order(
    order_id: str,
    amount: float,
    user_name: str = "",
    product_name: str = "",
    bank_id: str = "",
    pay_currency: str = "",
) -> dict:
    """
    發起代收下單請求

    Args:
        order_id: 商戶訂單號（最大 32 字符）
        amount: 提單金額（元），支持兩位小數
        user_name: 玩家姓名（實名制通道必填，最大 20 字符）
        product_name: 商品名稱（最大 20 字符）
        bank_id: 收款指定銀行編碼（僅部分通道支持）
        pay_currency: 貨幣轉換（如 CNYUSDT）

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/pay_order"

    # 構建簽名參數（不含 pay_md5_sign）
    sign_params = {
        "pay_customer_id": CUSTOMER_ID,
        "pay_apply_date": current_timestamp(),
        "pay_order_id": order_id,
        "pay_notify_url": NOTIFY_URL,
        "pay_amount": amount,
        "pay_channel_id": PAY_CHANNEL_ID,
    }

    # 選填參數（非空時加入簽名）
    if product_name:
        sign_params["pay_product_name"] = product_name
    if user_name:
        sign_params["user_name"] = user_name
    if bank_id:
        sign_params["bank_id"] = bank_id
    if pay_currency:
        sign_params["pay_currency"] = pay_currency

    # 生成簽名
    sign = generate_sign(sign_params)

    # 完整請求參數
    payload = {**sign_params, "pay_md5_sign": sign}

    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()


if __name__ == "__main__":
    result = create_pay_order(
        order_id="TEST_ORDER_001",
        amount=100.00,
        user_name="TestUser",
        product_name="TestProduct",
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))
