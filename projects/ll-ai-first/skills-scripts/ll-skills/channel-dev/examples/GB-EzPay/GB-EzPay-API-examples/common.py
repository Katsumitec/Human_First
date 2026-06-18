"""
GB-EzPay API 通用工具模組
提供簽名計算、配置讀取等共用功能
"""

import hashlib
import os
import time
from dotenv import load_dotenv

# 載入 .env 配置
load_dotenv()

# 從環境變數讀取配置
BASE_URL = os.getenv("BASE_URL", "").rstrip("/")
CUSTOMER_ID = int(os.getenv("CUSTOMER_ID", "0"))
API_KEY = os.getenv("API_KEY", "")
PAY_CHANNEL_ID = int(os.getenv("PAY_CHANNEL_ID", "1"))
NOTIFY_URL = os.getenv("NOTIFY_URL", "")


def generate_sign(params: dict, api_key: str = None) -> str:
    """
    生成 MD5 簽名

    簽名步驟：
    1. 將參數按鍵名升序排序
    2. 將非空值以 key=value& 方式連接
    3. 末尾加上 key=api_key
    4. MD5 加密後轉大寫

    Args:
        params: 需要簽名的參數字典（不含 pay_md5_sign / sign）
        api_key: API 密鑰，預設使用環境變數中的值

    Returns:
        大寫的 MD5 簽名字串
    """
    if api_key is None:
        api_key = API_KEY

    # 按鍵名升序排序
    sorted_keys = sorted(params.keys())

    # 拼接非空值
    sign_str = ""
    for key in sorted_keys:
        val = params[key]
        if val is not None and val != "":
            sign_str += f"{key}={val}&"

    # 加上 key
    sign_str += f"key={api_key}"

    # MD5 加密並轉大寫
    return hashlib.md5(sign_str.encode("utf-8")).hexdigest().upper()


def verify_sign(params: dict, sign: str, api_key: str = None) -> bool:
    """
    驗證回調簽名

    Args:
        params: 回調參數字典（不含 sign 字段）
        sign: 收到的簽名值
        api_key: API 密鑰

    Returns:
        簽名是否匹配
    """
    expected = generate_sign(params, api_key)
    return expected.upper() == sign.upper()


def current_timestamp() -> int:
    """取得當前 Unix 時間戳（秒）"""
    return int(time.time())
