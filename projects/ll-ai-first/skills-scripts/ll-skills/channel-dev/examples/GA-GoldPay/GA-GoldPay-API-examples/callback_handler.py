"""
GoldPay 回調處理範例（代收 + 代付）
使用 Flask 接收渠道推送的回調通知
"""
import json
from flask import Flask, request, jsonify
from common import verify_sign

app = Flask(__name__)


@app.route("/callback/deposit", methods=["POST"])
def deposit_callback():
    """處理代收回調通知"""
    params = request.form.to_dict()
    print("=== 收到代收回調 ===")
    print(json.dumps(params, indent=2, ensure_ascii=False))

    # 驗證簽名
    if not verify_sign(params):
        print("簽名驗證失敗！")
        return jsonify({"status": "error", "error_msg": "sign verification failed"})

    # 處理業務邏輯
    status = int(params.get("status", 0))
    order_no = params.get("merchant_order_no", "")
    amount = params.get("amount", "")
    trans_id = params.get("trans_id", "")

    if status == 1:
        print(f"代收成功: 訂單={order_no}, 金額={amount}, 交易號={trans_id}")
        # TODO: 更新訂單狀態為成功
    else:
        error_code = params.get("error_code", "")
        print(f"代收失敗: 訂單={order_no}, 錯誤碼={error_code}")
        # TODO: 更新訂單狀態為失敗

    return jsonify({"status": "success", "error_msg": ""})


@app.route("/callback/withdraw", methods=["POST"])
def withdraw_callback():
    """處理代付回調通知"""
    params = request.form.to_dict()
    print("=== 收到代付回調 ===")
    print(json.dumps(params, indent=2, ensure_ascii=False))

    # 驗證簽名
    if not verify_sign(params):
        print("簽名驗證失敗！")
        return jsonify({"status": "error", "error_msg": "sign verification failed"})

    # 處理業務邏輯
    status = int(params.get("status", 0))
    order_no = params.get("merchant_order_no", "")
    amount = params.get("amount", "")
    trans_id = params.get("trans_id", "")

    if status == 1:
        print(f"代付成功: 訂單={order_no}, 金額={amount}, 交易號={trans_id}")
        # 注意：實際提現金額有可能跟請求金額不一致，需自行判斷
        # TODO: 更新訂單狀態為成功
    else:
        error_code = params.get("error_code", "")
        print(f"代付失敗: 訂單={order_no}, 錯誤碼={error_code}")
        # TODO: 更新訂單狀態為失敗

    return jsonify({"status": "success", "error_msg": ""})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
