"""
CTPAY 代付查詢範例
對應交易類型：0050
接口 URL：GET https://tianciv420428.com/api/payment/{out_trade_no}

狀態碼映射：
  new / processing / verify → 01 處理中
  completed               → 10 成功
  failed / reject / refund → 20 失敗
"""
import json
import requests
from ctpay_utils import BASE_URL, build_headers

STATE_MAP = {
    "new": "01",
    "processing": "01",
    "verify": "01",
    "completed": "10",
    "failed": "20",
    "reject": "20",
    "refund": "20",
}


def payment_query(out_trade_no: str) -> dict:
    """
    查詢代付訂單狀態

    Args:
        out_trade_no: 商戶訂單號

    Returns:
        渠道響應 dict
    """
    url = f"{BASE_URL}/api/payment/{out_trade_no}"
    resp = requests.get(url, headers=build_headers(), timeout=30)
    resp.raise_for_status()
    return resp.json()


if __name__ == "__main__":
    result = payment_query("PAY202603230001")
    print(json.dumps(result, indent=2, ensure_ascii=False))

    if result.get("success") and result.get("data"):
        data = result["data"]
        state = data.get("state", "")
        mapped = STATE_MAP.get(state, "01")
        print(f"\n📋 代付訂單查詢結果")
        print(f"  商戶訂單號: {data.get('out_trade_no')}")
        print(f"  平台訂單號: {data.get('trade_no')}")
        print(f"  金額: {data.get('amount')}")
        print(f"  渠道狀態: {state}")
        print(f"  系統狀態: {mapped} ({'處理中' if mapped=='01' else '成功' if mapped=='10' else '失敗'})")
        if data.get("bank_account"):
            print(f"  出款卡號末五碼: {data.get('bank_account')}")
