"""
CTPAY 代付回調驗簽範例
代付回調在 成功/沖回/失敗 時觸發
驗簽欄位：trade_no, amount, out_trade_no, state（4個）
排除：sign, callback_url
"""
from ctpay_utils import verify_notify_sign

# 代付回調參與簽名的字段（固定4個）
PAYMENT_SIGN_FIELDS = ["trade_no", "amount", "out_trade_no", "state"]

# 代付最終狀態映射
STATE_MAP = {
    "completed": "10",  # 成功
    "failed": "20",     # 失敗
    "refund": "20",     # 沖回（視為失敗）
}


def handle_payment_notify(notify_data: dict) -> str:
    """
    處理代付異步通知

    Args:
        notify_data: 渠道 POST 來的 JSON body

    Returns:
        "ok"（驗簽成功）或拋出異常
    """
    print(f"收到代付回調: {notify_data}")

    # 1. 驗簽
    if not verify_notify_sign(notify_data, PAYMENT_SIGN_FIELDS):
        raise ValueError(f"驗簽失敗！接收到的 sign: {notify_data.get('sign')}")

    # 2. 取訂單信息
    out_trade_no = notify_data.get("out_trade_no")
    trade_no = notify_data.get("trade_no")
    state = notify_data.get("state")
    amount = notify_data.get("amount")
    errors = notify_data.get("errors", "")

    print(f"✅ 驗簽通過")
    print(f"  商戶訂單號: {out_trade_no}")
    print(f"  平台訂單號: {trade_no}")
    print(f"  狀態: {state}")
    print(f"  金額: {amount}")

    mapped = STATE_MAP.get(state, "01")
    if mapped == "10":
        print(f"  → 代付成功，更新訂單狀態")
    elif mapped == "20":
        print(f"  → 代付失敗（{errors or state}），更新訂單狀態")
    else:
        print(f"  → 未知狀態 {state}，保持處理中")

    # TODO: 更新本地訂單狀態

    return "ok"


if __name__ == "__main__":
    # 模擬代付成功回調
    mock_notify_success = {
        "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe6",
        "amount": "300000",
        "out_trade_no": "PAY202603230001",
        "state": "completed",
        "callback_url": "https://www.example.com/notify",
        "sign": "需替換為真實簽名",
    }

    # 模擬代付失敗回調
    mock_notify_failed = {
        "trade_no": "fdd49c43-e1c1-49da-9d23-8027f5412fe7",
        "amount": "300000",
        "out_trade_no": "PAY202603230002",
        "state": "failed",
        "callback_url": "https://www.example.com/notify",
        "errors": "银行维护中",
        "sign": "需替換為真實簽名",
    }

    try:
        print("=== 測試代付成功回調 ===")
        response = handle_payment_notify(mock_notify_success)
        print(f"回覆渠道: {response}")
    except ValueError as e:
        print(f"❌ 錯誤: {e}")
