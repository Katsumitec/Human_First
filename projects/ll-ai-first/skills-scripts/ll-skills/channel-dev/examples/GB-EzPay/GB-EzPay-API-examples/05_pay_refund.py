"""
GB-EzPay 代收-原路退款銀行資訊 API 範例（選用）
接口：POST /api/pay_refund
分類：W:代付類接口
"""

import json
import requests
from common import BASE_URL, CUSTOMER_ID, generate_sign, current_timestamp


def submit_refund_bank_info(
    order_id: str,
    bank_account_name: str,
    bank_name: str = "",
    bank_no: str = "",
    bank_province: str = "",
    bank_city: str = "",
    bank_sub_branch: str = "",
    phone: str = "",
) -> dict:
    """
    提交原路退款銀行資訊

    Args:
        order_id: 商戶訂單號
        bank_account_name: 戶名（必填）
        bank_name: 銀行名稱
        bank_no: 銀行帳號
        bank_province: 銀行省份
        bank_city: 銀行城市
        bank_sub_branch: 銀行支行
        phone: 手機號

    Returns:
        API 響應 JSON
    """
    url = f"{BASE_URL}/api/pay_refund"

    sign_params = {
        "pay_customer_id": CUSTOMER_ID,
        "pay_apply_date": current_timestamp(),
        "pay_order_id": order_id,
        "bank_account_name": bank_account_name,
    }

    # 選填參數（非空時加入簽名）
    if bank_name:
        sign_params["bank_name"] = bank_name
    if bank_no:
        sign_params["bank_no"] = bank_no
    if bank_province:
        sign_params["bank_province"] = bank_province
    if bank_city:
        sign_params["bank_city"] = bank_city
    if bank_sub_branch:
        sign_params["bank_sub_branch"] = bank_sub_branch
    if phone:
        sign_params["phone"] = phone

    sign = generate_sign(sign_params)
    payload = {**sign_params, "pay_md5_sign": sign}

    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()


if __name__ == "__main__":
    result = submit_refund_bank_info(
        order_id="TEST_ORDER_001",
        bank_account_name="张三",
        bank_name="VIETCOMBANK",
        bank_no="1234567890",
        phone="0901234567",
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))
