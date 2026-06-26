"""
GoldPay API 通用模組 - 簽名計算與配置載入
"""
import hashlib
import os
from urllib.parse import urlencode

from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("GOLDPAY_BASE_URL", "https://api.pgvn.vn-pay.co")
MERCHANT_CODE = os.getenv("GOLDPAY_MERCHANT_CODE")
SECRET_KEY = os.getenv("GOLDPAY_SECRET_KEY")
CALLBACK_URL = os.getenv("GOLDPAY_CALLBACK_URL", "")


def generate_sign(params: dict) -> str:
    """
    依 GoldPay 簽名規則生成 SHA256 簽名。

    1. 過濾空值參數
    2. 按參數名 ASCII 碼升序排序
    3. 拼接成 key1=value1&key2=value2 格式
    4. 末尾拼接 &key=<SECRET_KEY>
    5. 對整個字符串做 SHA256
    """
    # 過濾空值，排除 sign 字段本身
    filtered = {k: v for k, v in params.items() if v not in (None, "", "sign") and k != "sign"}
    # 按 key 字典序排序
    sorted_keys = sorted(filtered.keys())
    # 拼接
    sign_str = "&".join(f"{k}={filtered[k]}" for k in sorted_keys)
    # 拼接密鑰
    sign_str += f"&key={SECRET_KEY}"
    # SHA256
    return hashlib.sha256(sign_str.encode("utf-8")).hexdigest()


def verify_sign(params: dict) -> bool:
    """驗證回調簽名是否正確"""
    received_sign = params.get("sign", "")
    expected_sign = generate_sign(params)
    return received_sign == expected_sign


def print_response(resp):
    """格式化列印 API 回應"""
    print(f"HTTP Status: {resp.status_code}")
    try:
        data = resp.json()
        import json
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except Exception:
        print(resp.text)
