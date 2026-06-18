"""
CTPAY 工具模塊：簽名計算、HTTP 請求封裝
"""
import hashlib
import os
import requests
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("BASE_URL", "https://tianciv420428.com")
API_TOKEN = os.getenv("API_TOKEN", "")
NOTIFY_TOKEN = os.getenv("NOTIFY_TOKEN", "")


def build_headers() -> dict:
    """構建通用請求 Header（Bearer Token 認證）"""
    return {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_TOKEN}",
    }


def calc_sign(fields: dict) -> str:
    """
    計算 CTPAY 簽名：
    1. 對 fields 按 key 的 ASCII 碼遞增排序（ksort）
    2. 串接為 key=value&key=value... 格式
    3. 直接拼接 api_token + notify_token（無分隔符）
    4. MD5 hash（小寫 hex）

    Args:
        fields: 參與簽名的字段字典（已排除 sign 等不參與簽名的字段）

    Returns:
        MD5 簽名（小寫 hex）
    """
    sorted_keys = sorted(fields.keys())
    parts = [f"{k}={fields[k]}" for k in sorted_keys]
    raw = "&".join(parts) + API_TOKEN + NOTIFY_TOKEN
    return hashlib.md5(raw.encode("utf-8")).hexdigest()


def verify_notify_sign(notify_data: dict, sign_fields: list) -> bool:
    """
    驗證回調通知的簽名

    Args:
        notify_data: 渠道推送的完整回調數據
        sign_fields: 參與簽名的字段名列表（如 ['trade_no', 'amount', 'out_trade_no', 'state']）

    Returns:
        True=驗簽通過，False=驗簽失敗
    """
    received_sign = notify_data.get("sign", "")
    fields = {k: notify_data[k] for k in sign_fields if k in notify_data}
    expected_sign = calc_sign(fields)
    return received_sign == expected_sign
