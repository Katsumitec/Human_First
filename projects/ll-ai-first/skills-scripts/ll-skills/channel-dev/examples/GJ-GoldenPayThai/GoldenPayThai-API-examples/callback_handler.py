"""
GoldenPay 泰國 回調處理範例（Flask）

- 代收回調：POST /callback/deposit  JSON；status=60 成功，其他失敗
- 代付回調：POST /callback/withdraw JSON；status=50 取消/失敗，其他成功
- 收到後需回純文字 "success"；建議回 HTTP 200
"""
from __future__ import annotations

from flask import Flask, request

from common import get_config, verify_signature, pretty


app = Flask(__name__)


def _handle(kind: str):
    data = request.get_json(silent=True) or {}
    pretty(f"[{kind}] Received callback", data)

    received_sign = data.get("sign", "")
    payload = {k: v for k, v in data.items() if k != "sign"}

    c = get_config()
    ok = verify_signature(payload, c["API_TOKEN"], received_sign)
    pretty(f"[{kind}] Signature valid", ok)
    if not ok:
        return "invalid sign", 400

    status = data.get("status")
    if kind == "deposit":
        # 60 成功，其他失敗
        biz_ok = str(status) == "60"
    else:
        # 50 取消/失敗，其他成功
        biz_ok = str(status) != "50"

    pretty(f"[{kind}] Business status", ("success" if biz_ok else "failed"))

    # TODO：冪等處理：查詢本地訂單狀態，避免重複上分
    # 超時：代收 5 秒、代付 10 秒內必須回應
    return "success", 200


@app.route("/callback/deposit", methods=["POST"])
def deposit_callback():
    return _handle("deposit")


@app.route("/callback/withdraw", methods=["POST"])
def withdraw_callback():
    return _handle("withdraw")


if __name__ == "__main__":
    # 開發用：local server，正式環境請置於 reverse proxy（HTTPS）後
    app.run(host="0.0.0.0", port=5000, debug=False)
