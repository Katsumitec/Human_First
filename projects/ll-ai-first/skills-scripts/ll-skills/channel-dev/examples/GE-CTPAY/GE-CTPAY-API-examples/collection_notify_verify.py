"""
CTPAY 代收回調驗簽範例
代收回調只通知 completed（成功）訂單
驗簽欄位：trade_no, amount, out_trade_no, state（4個）
排除：sign, request_amount, callback_url
"""
from ctpay_utils import verify_notify_sign

# 代收回調參與簽名的字段（固定4個）
COLLECTION_SIGN_FIELDS = ["trade_no", "amount", "out_trade_no", "state"]


def handle_collection_notify(notify_data: dict) -> str:
    """
    處理代收異步通知

    Args:
        notify_data: 渠道 POST 來的 JSON body

    Returns:
        "ok"（驗簽成功）或拋出異常
    """
    print(f"收到代收回調: {notify_data}")

    # 1. 驗簽
    if not verify_notify_sign(notify_data, COLLECTION_SIGN_FIELDS):
        raise ValueError(f"驗簽失敗！接收到的 sign: {notify_data.get('sign')}")

    # 2. 取訂單信息
    out_trade_no = notify_data.get("out_trade_no")
    trade_no = notify_data.get("trade_no")
    state = notify_data.get("state")
    amount = notify_data.get("amount")

    print(f"✅ 驗簽通過")
    print(f"  商戶訂單號: {out_trade_no}")
    print(f"  平台訂單號: {trade_no}")
    print(f"  狀態: {state}")
    print(f"  實付金額: {amount}")

    # 3. 代收只通知 completed，state 固定為 completed
    if state == "completed":
        print(f"  → 交易成功，更新訂單狀態")
        # TODO: 更新本地訂單狀態為成功

    # 4. 回覆 ok 告知渠道不再重發
    return "ok"


if __name__ == "__main__":
    # 模擬收到的代收回調數據
    mock_notify = {
        "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
        "amount": "300000",
        "request_amount": "300000",
        "out_trade_no": "lt0085DB4AE5444B_60509043_112159",
        "state": "completed",
        "callback_url": "https://www.example.com/notify",
        "sign": "1ed30abda08395adb9cacabca1d669ad",  # 需與真實 token 一致
    }

    try:
        response = handle_collection_notify(mock_notify)
        print(f"\n回覆渠道: {response}")
    except ValueError as e:
        print(f"\n❌ 錯誤: {e}")
