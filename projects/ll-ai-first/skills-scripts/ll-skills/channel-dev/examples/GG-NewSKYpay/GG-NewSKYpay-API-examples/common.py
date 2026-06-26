"""GG-NewSKYpay 通用模組：簽名、HTTP、配置載入。

簽名規則（適用所有接口）：
    1. 將「參與簽名欄位」依文檔指定的「順序」拼接為 `key1=value1&key2=value2&...`
    2. 結尾追加 `&key=<商戶密鑰>`
    3. 整串做 MD5 → 轉小寫
    4. 空字段不參與簽名
    5. paidAmount 在通知接口僅當「支付成功」(orderStatus=3) 時才參與簽名
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
from typing import Any, Iterable, Mapping

import requests


# ---------- 配置載入 ----------

def _load_env_file(env_path: Path) -> None:
    """非常輕量的 .env 載入（不支援多行 / quoted），覆蓋至 os.environ。"""
    if not env_path.exists():
        return
    for raw in env_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip()
        v = v.strip().strip('"').strip("'")
        os.environ.setdefault(k, v)


def load_config() -> dict[str, str]:
    """從 .env (或 .env.example) 載入配置。"""
    here = Path(__file__).resolve().parent
    for name in (".env", ".env.example"):
        _load_env_file(here / name)

    cfg = {
        "BASE_URL": os.environ.get("BASE_URL", "http://api.newsky.vip"),
        "MERCHANT_ID": os.environ.get("MERCHANT_ID", ""),
        "MERCHANT_KEY": os.environ.get("MERCHANT_KEY", ""),
        "DEPOSIT_CT_PATH": os.environ.get("DEPOSIT_CT_PATH", "/hpay/dt/vnd/ct"),
        "DEPOSIT_QUERY_PATH": os.environ.get("DEPOSIT_QUERY_PATH", "/hpay/dt/vnd/query"),
        "WITHDRAW_CT_PATH": os.environ.get("WITHDRAW_CT_PATH", "/hpay/wd/vnd/ct"),
        "WITHDRAW_QUERY_PATH": os.environ.get("WITHDRAW_QUERY_PATH", "/hpay/wd/vnd/query"),
        "BALANCE_PATH": os.environ.get("BALANCE_PATH", "/hpay/merchant/balance"),
        "NOTIFY_URL": os.environ.get("NOTIFY_URL", ""),
        "QUERY_MERCHANT_ORDER_URL": os.environ.get("QUERY_MERCHANT_ORDER_URL", ""),
        "PAY_TYPE": os.environ.get("PAY_TYPE", "1060"),
        "CALLBACK_SERVER_HOST": os.environ.get("CALLBACK_SERVER_HOST", "0.0.0.0"),
        "CALLBACK_SERVER_PORT": os.environ.get("CALLBACK_SERVER_PORT", "5000"),
        "TEST_MERCHANT_ORDER_ID": os.environ.get("TEST_MERCHANT_ORDER_ID", "GG_TEST_0001"),
        "TEST_PAY_AMOUNT": os.environ.get("TEST_PAY_AMOUNT", "10000"),
        "TEST_USER_ID": os.environ.get("TEST_USER_ID", "78"),
        "TEST_USER_IP": os.environ.get("TEST_USER_IP", "127.0.0.1"),
        "TEST_BANK_TYPE": os.environ.get("TEST_BANK_TYPE", "ACB"),
        "TEST_BANK_NUM": os.environ.get("TEST_BANK_NUM", "36954697135656"),
        "TEST_BANK_ACCOUNT": os.environ.get("TEST_BANK_ACCOUNT", "NGUYEN VAN A"),
    }
    return cfg


# ---------- 簽名 ----------

def _stringify(value: Any) -> str:
    """將參與簽名的值轉成字串（保留整數樣態，避免 int 變成 '10000.0'）。"""
    if value is None:
        return ""
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, float):
        # 若實際為整數則去掉小數點（10000.0 → "10000"）
        if value.is_integer():
            return str(int(value))
        return str(value)
    return str(value)


def build_sign_string(
    payload: Mapping[str, Any],
    fields_in_order: Iterable[str],
    merchant_key: str,
) -> str:
    """組裝簽名前字符串（**不含 md5**）。

    - 嚴格按 fields_in_order 拼接
    - 若值為空（None / "" ）則「不參與簽名」（跳過該欄位）
    """
    parts: list[str] = []
    for name in fields_in_order:
        if name not in payload:
            continue
        s = _stringify(payload.get(name))
        if s == "":
            continue  # 空字段不參與簽名
        parts.append(f"{name}={s}")
    base = "&".join(parts)
    return f"{base}&key={merchant_key}"


def md5_lower(text: str) -> str:
    return hashlib.md5(text.encode("utf-8")).hexdigest().lower()


def sign_payload(
    payload: Mapping[str, Any],
    fields_in_order: Iterable[str],
    merchant_key: str,
) -> str:
    """產生 sign：toLower(md5(欄位拼接 + &key=密鑰))"""
    sign_str = build_sign_string(payload, fields_in_order, merchant_key)
    return md5_lower(sign_str)


def verify_sign(
    payload: Mapping[str, Any],
    fields_in_order: Iterable[str],
    merchant_key: str,
    sign_field: str = "sign",
) -> bool:
    """驗證 payload 中的 sign 是否與重新計算的 sign 相符。"""
    received = str(payload.get(sign_field, "")).lower()
    if not received:
        return False
    expected = sign_payload(payload, fields_in_order, merchant_key)
    return received == expected


# ---------- HTTP ----------

def post_json(url: str, payload: Mapping[str, Any], timeout: int = 15) -> dict[str, Any]:
    """以 application/json 發送 POST。"""
    headers = {"Content-Type": "application/json;charset=UTF-8"}
    resp = requests.post(url, data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
                         headers=headers, timeout=timeout)
    return _wrap_resp(resp)


def post_form(url: str, payload: Mapping[str, Any], timeout: int = 15) -> dict[str, Any]:
    """以 application/x-www-form-urlencoded 發送 POST（反查接口使用）。"""
    headers = {"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"}
    resp = requests.post(url, data=payload, headers=headers, timeout=timeout)
    return _wrap_resp(resp)


def _wrap_resp(resp: requests.Response) -> dict[str, Any]:
    out: dict[str, Any] = {
        "http_status": resp.status_code,
        "raw_text": resp.text,
        "headers": dict(resp.headers),
    }
    try:
        out["json"] = resp.json()
    except Exception:
        out["json"] = None
    return out


# ---------- 格式化輸出 ----------

def pretty_print_response(label: str, result: Mapping[str, Any]) -> None:
    print(f"\n========== {label} ==========")
    print(f"HTTP Status: {result.get('http_status')}")
    if result.get("json") is not None:
        print("JSON:")
        print(json.dumps(result["json"], ensure_ascii=False, indent=2))
    else:
        print("Raw Text:")
        print(result.get("raw_text"))
    print("=" * (len(label) + 22))


def pretty_print_request(label: str, url: str, payload: Mapping[str, Any]) -> None:
    print(f"\n---------- {label} ----------")
    print(f"POST {url}")
    print("Body:")
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    print("-" * (len(label) + 22))


# ---------- 簽名欄位順序常數（依官方文檔指定順序） ----------

DEPOSIT_CT_SIGN_FIELDS = ("merchantId", "merchantOrderId", "payAmount")
DEPOSIT_QUERY_SIGN_FIELDS = ("merchantId", "merchantOrderId", "payAmount")

WITHDRAW_CT_SIGN_FIELDS = (
    "merchantId", "merchantOrderId", "payAmount", "bankNum", "bankAccount",
)
WITHDRAW_QUERY_SIGN_FIELDS = ("merchantId", "merchantOrderId", "payAmount")

BALANCE_SIGN_FIELDS = ("merchantId", "time")

# 通知接口（用於驗簽）
DEPOSIT_NOTIFY_SIGN_FIELDS_SUCCESS = (
    "merchantId", "merchantOrderId", "payOrderId", "payAmount", "paidAmount",
)
DEPOSIT_NOTIFY_SIGN_FIELDS_FAIL = (
    "merchantId", "merchantOrderId", "payOrderId", "payAmount",
)

WITHDRAW_NOTIFY_SIGN_FIELDS_SUCCESS = (
    "merchantId", "merchantOrderId", "payOrderId", "payAmount", "paidAmount",
    "bankNum", "bankAccount",
)
WITHDRAW_NOTIFY_SIGN_FIELDS_FAIL = (
    "merchantId", "merchantOrderId", "payOrderId", "payAmount",
    "bankNum", "bankAccount",
)


def verify_notify_sign(payload: Mapping[str, Any], merchant_key: str, kind: str) -> bool:
    """通知驗簽：依 orderStatus 自動切換是否含 paidAmount。

    kind: 'deposit' or 'withdraw'
    """
    is_success = str(payload.get("orderStatus", "")).strip() == "3"
    if kind == "deposit":
        fields = DEPOSIT_NOTIFY_SIGN_FIELDS_SUCCESS if is_success else DEPOSIT_NOTIFY_SIGN_FIELDS_FAIL
    elif kind == "withdraw":
        fields = WITHDRAW_NOTIFY_SIGN_FIELDS_SUCCESS if is_success else WITHDRAW_NOTIFY_SIGN_FIELDS_FAIL
    else:
        raise ValueError(f"Unknown kind: {kind}")
    return verify_sign(payload, fields, merchant_key)


if __name__ == "__main__":
    # 簡單自我測試：用文檔範例驗證簽名計算
    print("== 自我測試（簽名計算）==")
    # 代收下單範例：merchantId=500000&merchantOrderId=88&payAmount=10000&key=xxxx
    sample = {"merchantId": 500000, "merchantOrderId": "88", "payAmount": 10000}
    s = build_sign_string(sample, DEPOSIT_CT_SIGN_FIELDS, "xxxx")
    print(f"sign string : {s}")
    print(f"md5 (lower) : {md5_lower(s)}")

    # 代付下單文檔範例：merchantId=5100&merchantOrderId=88&payAmount=10000&bankNum=12345&bankAccount=lisa&key=7ce0127
    sample2 = {
        "merchantId": 5100,
        "merchantOrderId": "88",
        "payAmount": 10000,
        "bankNum": "12345",
        "bankAccount": "lisa",
    }
    s2 = build_sign_string(sample2, WITHDRAW_CT_SIGN_FIELDS, "7ce0127")
    print(f"\nsign string : {s2}")
    print(f"md5 (lower) : {md5_lower(s2)}")
