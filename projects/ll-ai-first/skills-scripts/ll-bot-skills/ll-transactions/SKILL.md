---
name: ll-transactions
description: 查詢 caller 所屬商戶在指定月份的交易清單，可篩 state / orderId / intTransCd / transChnl 並分頁（GET /api/v1/transactions）。當使用者問「最近交易」「本月成功的訂單」「失敗的有哪些」時觸發；單筆查詢改用 ll-order。**僅支援 caller-aggregated 變體**：商戶號由 callerChatId 反查綁定決定，嚴禁攜帶 mchntCd 以防跨商戶越權；caller 綁多個商戶 → 400 MULTIPLE_BINDINGS（須由 admin 收斂綁定，本 skill 不接受顯式 mchntCd）。month 必填（yyyyMM）、pageSize 上限 10；響應為 envelope。
---

# ll-transactions — 商戶交易清單查詢

> 版本：v3.2（強制 caller-aggregated；移除「指定 mchntCd」變體以杜絕跨商戶越權）

## 何時使用

- 「商戶 X 這個月的交易」
- 「最近成功 / 失敗 / 處理中的訂單有哪些」
- 「這個月交易筆數」
- 「篩選 intTransCd 0210 的交易」

不是這個 skill 的場景：
- 已知 orderId 查單筆 → `ll-order`
- 跨月精準回溯 → `ll-order`（自帶 lookbackMonths）
- 查餘額 → `ll-balance`

## 端點

```
GET ${ICPAY_TG_BASE_URL}/api/v1/transactions
```

> **僅支援 caller-aggregated 變體** — 由 `callerChatId` 反查綁定商戶，藉此保證 caller 只能列出「自己綁定」的商戶交易，從根本上杜絕跨商戶越權。
> **禁止使用** `GET /api/v1/merchants/{mchntCd}/transactions` 主端點（即便 token 的 `allowedMchntCds` 容許，亦不在本 skill 範圍）。

反查邏輯：caller 綁 1 個 → 自動使用；綁 ≥ 2 個 → 400 `MULTIPLE_BINDINGS`（須先由 admin 將 caller 收斂到單一商戶綁定，本 skill 不接受顯式指定 mchntCd 規避）；無綁定 → 403 `CHAT_NOT_BOUND_TO_MCHNT`（或 401 早期失敗）。

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_MER` | Bearer token（scope: `transaction.read`）|
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端 chat ID |
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID |

## 入參

| 位置 | 名稱 | 必填 | 說明 |
|------|------|:---:|------|
| query | `channel` | ✅ | `TG` / `SK` |
| query | `callerChatId` | ✅ | 從環境變數；**商戶號由此反查決定** |
| query | `callerUserId` | ✅ | 從環境變數 |
| query | `month` | ✅ | yyyyMM，例 `202604` |
| query | `orderId` | ❌ | 商戶端訂單號（精確匹配，最長 50）|
| query | `state` | ❌ | `SUCCESSFUL` / `FAILED` / `PROCESSING` |
| query | `intTransCd` | ❌ | 4 碼數字（內部交易代碼）|
| query | `transChnl` | ❌ | 2 碼數字（交易通道）|
| query | `pageNo` | ❌ | 預設 `1` |
| query | `pageSize` | ❌ | 預設 `10`，**上限 10** |
| header | `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_MER}` |

> ⛔ **禁止欄位**：`mchntCd`（無論放 path、query 或 body 都不接受）。商戶號一律由 `callerChatId` 反查綁定決定，呼叫端無從顯式指定，這是本 skill 防跨商戶越權的核心護欄。

## 範例 curl

```bash
# caller-aggregated — 商戶號由 callerChatId 反查（caller 必須綁定唯一商戶）
curl -sS "${ICPAY_TG_BASE_URL}/api/v1/transactions?channel=TG&callerChatId=-268678324&callerUserId=88912345&month=202604&state=SUCCESSFUL&pageNo=1&pageSize=10" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"
```

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；清單欄位放在 `envelope.data` 內。

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "mchntCd": "889000000000001",
    "month": "202604",
    "pageNo": 1,
    "pageSize": 10,
    "totalCount": 42,
    "list": [
      {
        "orderId": "ORDER-2026-001",
        "transSeqId": "TS20260420093011001",
        "intTransCd": "0210",
        "state": "SUCCESSFUL",
        "stateRaw": "00",
        "transAt": "1,234.00",
        "currCd": "156",
        "transChnl": "01",
        "chnlOrderId": "2026042009301100887",
        "extTransDt": "20260420",
        "extTransTm": "093011"
      }
    ]
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `MULTIPLE_BINDINGS` | caller 綁多個商戶，反查無法收斂為單一商戶；**須先由 admin 收斂綁定**，本 skill 不允許顯式帶 `mchntCd` 規避 |
| 400 | `MONTH_INVALID` | month 非 6 碼數字 |
| 400 | `ORDER_ID_INVALID` | orderId 超長 / 非法字元 |
| 400 | `PAGE_SIZE_INVALID` | pageSize > 10 |
| 400 | `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 三身份參數格式問題 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `transaction.read` |
| 403 | `MCHNT_NOT_AUTHORIZED` | 反查到的商戶不在 token 的 `allowedMchntCds` 內（token 與綁定配置不一致；屬運維問題） |
| 403 | `CHAT_NOT_BOUND_TO_MCHNT` | caller chat 未綁定任何商戶 |

## 使用守則

- ⛔ **絕不接受呼叫端傳入 `mchntCd`**：商戶號一律由 `callerChatId` 反查決定。這是本 skill 的安全護欄 — 防止 caller 列出任何「非己綁定」的商戶交易清單，即使 token 的 `allowedMchntCds` 涵蓋多個商戶也不放行
- 不要把 `mchntCd` 放進 URL、query、body 或任何參數位置；也不要主動猜
- 若使用者請求中夾帶「商戶 X 這個月交易」字樣，僅以 caller 反查到的商戶為準；若使用者顯式指定的 mchntCd 與反查結果不一致，回覆「本 skill 不支援指定商戶，以您 chat 綁定的商戶為準」
- caller 綁多個商戶 → 400 `MULTIPLE_BINDINGS`：應反問「請聯絡 admin 將此 chat 收斂為單一商戶綁定」，**不要**改呼叫指定 mchntCd 的舊端點
- `month` 是必填 — 若使用者只說「最近交易」，預設帶當月（取本機時間 yyyyMM）
- `pageSize` 最大 10；要看更多筆要分頁（提示使用者 `pageNo=2` 等）
- `state="SUCCESSFUL"` 才是真正完成；`PROCESSING` 是處理中（可能仍會變動）
- 三組主要的交易識別 ID（用途與受眾不同）：
  - `orderId` — **商戶側**訂單號（商戶自定義;查詢入參用它）
  - `transSeqId` — **我方內部**流水（平台分配,純內部 ID）
  - `chnlOrderId` / `chnlId` / `transChnl` — **上游渠道側**標識
- **對外回覆的信任邊界**（清單**每筆**都受約束）：
  - 對**商戶** → 每筆只列 `orderId` / 狀態 / 金額 / 交易時間;`transSeqId` / `chnlOrderId` / `intTransCd` / `stateRaw` / `transChnl` 及渠道號**一律不外露**（含「渠道訂單號 / 上游訂單號 / 平台訂單號」等**同義改寫**也不可）。⚠️ 內部排查可看全欄位,**對商戶輸出剔除跨方/內部欄位**
- **金額欄位（`transAt`）原樣顯示、保留千分位逗號**：後端回傳的 `transAt` 字串已是最終顯示格式（固定兩位小數、千位以上含千分位逗號，例：`1,005.00`、`1,234,567.89`）。逐筆直接原樣輸出該字串、**完整保留其中的逗號**（後端給 `1,005.00` 就顯示 `1,005.00`，不可寫成 `1005.00`），不可改寫、四捨五入、補 / 去零或移除任何數字格式
- **`txnStateMsg` / `errMsg` / `chnlErrMsg` 是原始錯誤訊息 free-text 3 欄**（同 `ll-order`，對應 `tbl_trans_logNN.txn_state_msg` / `err_msg` / `chnl_err_msg`），後端原始透出。商戶若要看某筆**失敗原因**時（清單裡的失敗筆）：**忠實保留錯誤的原始語意、直接陳述,不改寫 / 不抽象 / 不挑選 / 不判斷真因**;只做兩件減法——(1) 剝除敏感識別碼（`mchntCd` / `chnlOrderId` / `transSeqId` / 渠道號 / 渠道名,尤其 `chnlErrMsg` 內嵌）;(2) 去除純技術鷹架（stack trace / `檔名 at line N` / `${...}`）。其餘原意一字不刪不轉換（規則同 `ll-order`）。
- 大筆數時不要把整份 list 全 dump 給使用者，先摘要（總筆數、成功 / 失敗計數）再列前幾筆;**清單摘要通常不逐筆列失敗原因**,商戶指定某筆要原因時才依上條呈現該筆
