"""
GB-EzPay 代收-異步通知處理範例
接口：POST（渠道推送至商戶回調地址）
分類：N:異步通知接口

注意：商戶收到回調後必須返回純文字 OK（大寫，無雙引號）
"""

import json
from common import verify_sign


def handle_pay_callback(callback_data: dict) -> str:
    """
    處理代收異步通知

    Args:
        callback_data: 渠道推送的回調 JSON 數據

    Returns:
        回覆字串（成功返回 "OK"）
    """
    # 提取簽名字段
    sign = callback_data.get("sign", "")

    # 構建驗簽參數（排除 sign 字段）
    verify_params = {k: v for k, v in callback_data.items() if k != "sign"}

    # 驗證簽名
    if not verify_sign(verify_params, sign):
        print("[ERROR] 簽名驗證失敗")
        return "FAIL"

    # 處理業務邏輯
    status = str(callback_data.get("status", ""))
    order_id = callback_data.get("order_id", "")
    order_amount = callback_data.get("order_amount", 0)
    real_amount = callback_data.get("real_amount", 0)
    transaction_id = callback_data.get("transaction_id", "")

    if status == "30000":
        # 支付成功
        print(f"[SUCCESS] 訂單 {order_id} 支付成功")
        print(f"  平台訂單號: {transaction_id}")
        print(f"  提單金額: {order_amount}, 實際支付: {real_amount}")
    elif status == "50000":
        # 原路退款
        refund_info = callback_data.get("extra", {}).get("refund", {})
        refund_status = refund_info.get("refund_status", 0)
        status_map = {1: "退款中", 2: "退款成功", 3: "退款失敗"}
        print(f"[REFUND] 訂單 {order_id} 原路退款 - {status_map.get(refund_status, '未知')}")
    else:
        print(f"[UNKNOWN] 訂單 {order_id} 未知狀態: {status}")

    return "OK"


if __name__ == "__main__":
    # 模擬收到的回調數據
    sample_callback = {
        "customer_id": 50003,
        "order_id": "99523425405591",
        "transaction_id": "T202012081925511001637559l",
        "order_amount": 500,
        "real_amount": 500,
        "sign": "1fc494c688dbe76693e9193d900000fd",
        "status": "30000",
        "message": "支付成功",
        "extra": {
            "user_name": "玩家姓名",
            "pay_product_name": None,
        },
    }
    print("回調數據:")
    print(json.dumps(sample_callback, indent=2, ensure_ascii=False))
    print()

    response = handle_pay_callback(sample_callback)
    print(f"\n回覆: {response}")
