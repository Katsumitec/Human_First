"""
GB-EzPay 代付-支付結果異步通知處理範例
接口：POST（渠道推送至商戶回調地址）
分類：N:異步通知接口

注意：成功響應值必須為字符串 OK（大寫，無雙引號）
"""

import json
from common import verify_sign


def handle_payout_callback(callback_data: dict) -> str:
    """
    處理代付異步通知

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
    transaction_code = str(callback_data.get("transaction_code", ""))
    order_id = callback_data.get("order_id", "")
    amount = callback_data.get("amount", "0")
    transaction_id = callback_data.get("transaction_id", "")
    transaction_msg = callback_data.get("transaction_msg", "")

    if transaction_code == "30000":
        print(f"[SUCCESS] 代付訂單 {order_id} 支付成功")
        print(f"  平台訂單號: {transaction_id}")
        print(f"  金額: {amount}")
        print(f"  描述: {transaction_msg}")
    elif transaction_code == "40000":
        print(f"[REJECTED] 代付訂單 {order_id} 被駁回")
        print(f"  描述: {transaction_msg}")
    else:
        print(f"[UNKNOWN] 代付訂單 {order_id} 未知狀態: {transaction_code}")

    return "OK"


if __name__ == "__main__":
    # 模擬收到的回調數據
    sample_callback = {
        "customer_id": 58787,
        "order_id": "order1582539115",
        "amount": "300.0000",
        "datetime": "2020-05-12 21:06:57",
        "sign": "E6144CDA4177A00ED3F6731870DD06DD",
        "transaction_id": "P2020051215480616131",
        "transaction_code": "30000",
        "transaction_msg": "支付成功",
    }
    print("回調數據:")
    print(json.dumps(sample_callback, indent=2, ensure_ascii=False))
    print()

    response = handle_payout_callback(sample_callback)
    print(f"\n回覆: {response}")
