"""
GoldenPay 泰國 共用模組：配置載入、簽名計算、驗簽、回應列印。

簽名規則（來自官方文檔 https://integration.gpbli.top/reference/）：
    1. 取出除 sign 外的所有非空參數
    2. 按 key 的 ASCII 字典序排序
    3. 以 key=value 形式用 & 連接，組成 body 字串
    4. 在 body 最前面附加 API_TOKEN 並用 & 連接：
         source = API_TOKEN + "&" + body
    5. 對 source 做 MD5，取十六進制字串（不區分大小寫；此處用小寫）
"""
from __future__ import annotations

import hashlib
import json
import os
import random
import string
import time
from typing import Any, Dict, Optional, Tuple

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


# ---------- 配置 ----------

def cfg(key: str, default: Optional[str] = None, required: bool = False) -> str:
    val = os.getenv(key, default)
    if required and not val:
        raise RuntimeError(f"環境變數 {key} 未設定，請檢查 .env")
    return val or ""


def get_config() -> Dict[str, str]:
    return {
        "BASE_URL":            cfg("BASE_URL",            required=True),
        "URL_DEPOSIT":         cfg("URL_DEPOSIT",         "/api/v1/mch/pmt-orders"),
        "URL_DEPOSIT_QUERY":   cfg("URL_DEPOSIT_QUERY",   "/api/v1/mch/pmt-orders"),
        "URL_WITHDRAW":        cfg("URL_WITHDRAW",        "/api/v1/mch/wdl-orders"),
        "URL_WITHDRAW_QUERY":  cfg("URL_WITHDRAW_QUERY",  "/api/v1/mch/wdl-orders"),
        "URL_BALANCE":         cfg("URL_BALANCE",         "/api/v1/mch/balance"),
        "MCH_ID":              cfg("MCH_ID",              required=True),
        "API_TOKEN":           cfg("API_TOKEN",           required=True),
        "CURRENCY":            cfg("CURRENCY",            "THB"),
        "CHANNEL":             cfg("CHANNEL",             "bank"),
        "CALLBACK_URL":        cfg("CALLBACK_URL",        "https://example.com/callback"),
        "RETURN_URL":          cfg("RETURN_URL",          "https://example.com/return"),
    }


# ---------- 簽名 ----------

NON_SIGN_FIELDS = {"sign"}


def build_sign_source(params: Dict[str, Any], api_token: str) -> str:
    """組出用於 MD5 的原始字串：API_TOKEN + "&" + sorted k=v 串接。"""
    filtered = {
        k: v for k, v in params.items()
        if k not in NON_SIGN_FIELDS and v is not None and v != ""
    }
    ordered = sorted(filtered.items(), key=lambda kv: kv[0])
    body = "&".join(f"{k}={v}" for k, v in ordered)
    return f"{api_token}&{body}" if body else api_token


def md5_lower(text: str) -> str:
    return hashlib.md5(text.encode("utf-8")).hexdigest().lower()


def sign(params: Dict[str, Any], api_token: str) -> str:
    return md5_lower(build_sign_source(params, api_token))


def sign_with_source(params: Dict[str, Any], api_token: str) -> Tuple[str, str]:
    source = build_sign_source(params, api_token)
    return md5_lower(source), source


def verify_signature(params: Dict[str, Any], api_token: str,
                     received_signature: str) -> bool:
    """驗證回調／響應簽名（不區分大小寫）。"""
    expected = sign(params, api_token)
    return expected.lower() == (received_signature or "").lower()


# ---------- 共用隨機 ----------

def gen_nonce(length: int = 16) -> str:
    chars = string.ascii_lowercase + string.digits
    return "".join(random.choice(chars) for _ in range(length))


def unix_ts() -> str:
    return str(int(time.time()))


# ---------- 輔助 ----------

def pretty(title: str, data: Any) -> None:
    print("\n" + "=" * 10, title, "=" * 10)
    if isinstance(data, (dict, list)):
        print(json.dumps(data, indent=2, ensure_ascii=False))
    else:
        print(data)


def print_request(url: str, params: Dict[str, Any], source: str, signature: str) -> None:
    pretty("Request URL", url)
    pretty("Request Params", params)
    pretty("Sign Source", source)
    pretty("Signature", signature)


def print_response(resp) -> None:
    pretty("HTTP Status", resp.status_code)
    try:
        pretty("Response JSON", resp.json())
    except Exception:
        pretty("Response Text", resp.text)


if __name__ == "__main__":
    # 重現官方文檔的簽名範例（文檔範例的拼接字串缺 timestamp，
    # 且所給的 Signature `3147c167...` 無法由任一種組合重現，
    # 判定為文檔錯誤。此處仍按「文字描述的算法」實作並列印供人工對照。）
    example = {
        "mch_id": "M3pZtGCTQg7rJeoLy",
        "trans_id": 20181230213948,
        "amount": "200.00",
        "channel": "alipay",
        "remarks": "memo",
        "nonce": "7886356ioiasdf",
        "timestamp": 1678132123,
        "callback_url": "http://hd3tcp.javawebdata9.com/api/recharge/onlinePayAsyncCallback/20200627132036809474",
        "ip": "47.244.122.36",
    }
    token = "xoJb3BS8j40OCuPc6kzE"
    sig, src = sign_with_source(example, token)
    pretty("Sign Source", src)
    pretty("Signature", sig)
    pretty("官方範例 Signature（疑有誤）", "3147c167da0392a2317542c18d0017e1")
