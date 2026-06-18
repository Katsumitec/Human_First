"""GG-NewSKYpay 回調 / 反查接口處理（Flask 範例）。

提供三個端點：

1. POST /callback/gg/notify/deposit
   - 代收異步通知（JSON）
   - 上游推送 → 我方驗簽 + 業務處理 → 回 "success"

2. POST /callback/gg/notify/withdraw
   - 代付異步通知（JSON）
   - 邏輯同上

3. POST /callback/gg/query_merchant_order
   - **反查商戶接口**（form-urlencoded，**無簽名**）
   - 上游推送 merchantId + merchantOrderId + payAmount
   - 我方核對訂單存在後回應純文字字串：
       * 訂單存在且金額一致 → "success"
       * 否則 → "fail"

注意（與專案 0098 模板差異）：
   - 專案需求文檔（GG-requirement.md）將反查回應定為 OK / ERROR；
   - 但**官方 API 文檔規定為 success / fail**。
   - 本範例以官方文檔為準（success / fail）。
"""
from __future__ import annotations

import os
from typing import Any, Mapping

from flask import Flask, request, Response

from common import (
    load_config,
    verify_notify_sign,
)


app = Flask(__name__)


# ---------- 模擬訂單儲存（實務應接資料庫）----------
# 結構：{ merchantOrderId: { "payAmount": int, "status": str, ... } }
FAKE_ORDER_DB: dict[str, dict[str, Any]] = {}


def upsert_fake_order(merchant_order_id: str, pay_amount: int, status: str = "0") -> None:
    FAKE_ORDER_DB[merchant_order_id] = {
        "payAmount": pay_amount,
        "status": status,
    }


def find_fake_order(merchant_order_id: str) -> dict[str, Any] | None:
    return FAKE_ORDER_DB.get(merchant_order_id)


# ---------- 1. 代收通知 ----------

@app.route("/callback/gg/notify/deposit", methods=["POST"])
def deposit_notify():
    """代收異步通知處理。

    驗簽流程：
        1. 取得 JSON
        2. 依 orderStatus 判定使用「成功欄位序」或「失敗欄位序」
        3. 比對 sign
    """
    cfg = load_config()
    body = request.get_json(silent=True) or {}
    print(f"[deposit_notify] received: {body}")

    if not verify_notify_sign(body, cfg["MERCHANT_KEY"], kind="deposit"):
        print("[deposit_notify] sign mismatch")
        return Response("fail", mimetype="text/plain")

    # 業務處理（這裡僅示意）
    if str(body.get("orderStatus", "")).strip() == "3":
        # 確認金額一致再入帳
        moid = str(body.get("merchantOrderId", ""))
        pay_amt = int(body.get("payAmount", 0))
        paid_amt = int(body.get("paidAmount", 0))
        order = find_fake_order(moid)
        if order is None:
            print("[deposit_notify] order not found")
            return Response("fail", mimetype="text/plain")
        if order["payAmount"] != pay_amt or pay_amt != paid_amt:
            print(f"[deposit_notify] amount mismatch: db={order['payAmount']} pay={pay_amt} paid={paid_amt}")
            return Response("fail", mimetype="text/plain")
        order["status"] = "3"
        print(f"[deposit_notify] order {moid} marked SUCCESS")

    return Response("success", mimetype="text/plain")


# ---------- 2. 代付通知 ----------

@app.route("/callback/gg/notify/withdraw", methods=["POST"])
def withdraw_notify():
    cfg = load_config()
    body = request.get_json(silent=True) or {}
    print(f"[withdraw_notify] received: {body}")

    if not verify_notify_sign(body, cfg["MERCHANT_KEY"], kind="withdraw"):
        print("[withdraw_notify] sign mismatch")
        return Response("fail", mimetype="text/plain")

    moid = str(body.get("merchantOrderId", ""))
    status = str(body.get("orderStatus", "")).strip()
    order = find_fake_order(moid)
    if order is None:
        print(f"[withdraw_notify] order not found: {moid}")
        return Response("fail", mimetype="text/plain")
    if status in {"3", "8"}:
        order["status"] = status
        print(f"[withdraw_notify] order {moid} -> {status}")

    return Response("success", mimetype="text/plain")


# ---------- 3. 反查商戶接口（**重點**） ----------

@app.route("/callback/gg/query_merchant_order", methods=["POST"])
def query_merchant_order():
    """反查商戶訂單（form 表單，無簽名）。

    上游推送：merchantId, merchantOrderId, payAmount
    我方需做：
        1. 不驗簽（依 IP 白名單把關）
        2. 用 merchantOrderId 查我方訂單
        3. 訂單存在且金額一致 → 回 "success"
        4. 否則 → 回 "fail"
    """
    # 兩種來源都接（form 為主，少數情境可能誤打 JSON）
    if request.form:
        data = request.form.to_dict()
    else:
        data = request.get_json(silent=True) or {}

    print(f"[query_merchant_order] received: {data}, remote_ip={request.remote_addr}")

    # （建議）IP 白名單檢查
    allowed_ips = {
        "18.163.181.38", "43.199.133.253", "43.199.58.235",
        "95.40.139.72", "18.162.79.67", "18.166.1.107", "18.166.44.1",
    }
    # 開發 / 測試模式可以略過 IP 檢查
    enforce_ip = os.environ.get("ENFORCE_IP_WHITELIST", "0") == "1"
    if enforce_ip and request.remote_addr not in allowed_ips:
        print(f"[query_merchant_order] IP {request.remote_addr} NOT in whitelist")
        return Response("fail", mimetype="text/plain")

    moid = str(data.get("merchantOrderId", "")).strip()
    if not moid:
        return Response("fail", mimetype="text/plain")

    try:
        pay_amt = int(float(data.get("payAmount", 0)))
    except (TypeError, ValueError):
        return Response("fail", mimetype="text/plain")

    order = find_fake_order(moid)
    if order is None:
        print(f"[query_merchant_order] order NOT FOUND: {moid}")
        return Response("fail", mimetype="text/plain")
    if order["payAmount"] != pay_amt:
        print(f"[query_merchant_order] amount mismatch: db={order['payAmount']} req={pay_amt}")
        return Response("fail", mimetype="text/plain")

    print(f"[query_merchant_order] OK: {moid}")
    return Response("success", mimetype="text/plain")


# ---------- 健康檢查 ----------

@app.route("/health", methods=["GET"])
def health():
    return Response("ok", mimetype="text/plain")


# ---------- 模擬：手動建單，方便測試反查 ----------

@app.route("/_dev/seed_order", methods=["POST"])
def seed_order():
    """測試用：在「假訂單庫」放一筆訂單。"""
    data = request.get_json(silent=True) or request.form.to_dict()
    moid = str(data.get("merchantOrderId", ""))
    amt = int(data.get("payAmount", 0))
    if not moid or not amt:
        return Response("missing", mimetype="text/plain")
    upsert_fake_order(moid, amt, status="0")
    return Response("seeded", mimetype="text/plain")


if __name__ == "__main__":
    cfg = load_config()
    host = cfg["CALLBACK_SERVER_HOST"]
    port = int(cfg["CALLBACK_SERVER_PORT"])
    print(f"\nStarting GG-NewSKYpay callback server on {host}:{port}")
    print("Endpoints:")
    print(f"  POST http://{host}:{port}/callback/gg/notify/deposit         (代收通知)")
    print(f"  POST http://{host}:{port}/callback/gg/notify/withdraw        (代付通知)")
    print(f"  POST http://{host}:{port}/callback/gg/query_merchant_order   (**反查接口**, form, no sign)")
    print(f"  POST http://{host}:{port}/_dev/seed_order                    (測試輔助：建立假訂單)")
    print(f"  GET  http://{host}:{port}/health\n")
    app.run(host=host, port=port, debug=False)
