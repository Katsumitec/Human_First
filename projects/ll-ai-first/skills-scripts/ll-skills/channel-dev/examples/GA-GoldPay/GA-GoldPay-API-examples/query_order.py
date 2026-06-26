"""
GoldPay 查詢訂單接口範例
POST /sha256/query-order
"""
import requests
from common import BASE_URL, MERCHANT_CODE, generate_sign, print_response

# 交易狀態碼對照表
DEPOSIT_STATUS = {
    "S": "已處理（成功）",
    "F": "失敗或駁回",
    "P": "待處理",
    "C": "已退款",
}

WITHDRAW_STATUS = {
    "Y": "已出款（成功）",
    "F": "失敗或駁回",
    "P": "待處理",
    "I": "處理中",
    "C": "已退款",
}


def query_order(order_no: str):
    """
    查詢訂單狀態

    Args:
        order_no: 先前提交的商戶訂單號

    Response 重要字段:
        - status: 1=成功, 0=失敗, 3=部分出款（API 調用結果）
        - trans_status: 交易狀態碼
            代收: S=已處理, F=失敗或駁回, P=待處理, C=已退款
            代付: Y=已出款, F=失敗或駁回, P=待處理, I=處理中, C=已退款
    """
    params = {
        "merchant_order_no": order_no,
        "merchant_code": MERCHANT_CODE,
    }
    params["sign"] = generate_sign(params)

    url = f"{BASE_URL}/sha256/query-order"
    print(f"POST {url}")
    resp = requests.post(url, data=params)
    print_response(resp)

    # 解析交易狀態
    try:
        data = resp.json()
        if data.get("status") == 1:
            trans_status = data.get("trans_status", "")
            deposit_desc = DEPOSIT_STATUS.get(trans_status)
            withdraw_desc = WITHDRAW_STATUS.get(trans_status)
            if deposit_desc:
                print(f"\n交易狀態: {trans_status} -> 代收: {deposit_desc}")
            if withdraw_desc:
                print(f"\n交易狀態: {trans_status} -> 代付: {withdraw_desc}")
    except Exception:
        pass

    return resp


if __name__ == "__main__":
    query_order("TEST_DEP_001")
