---
name: ll-order
description: 依商戶訂單號查單筆交易**目前狀態**（讀本地已同步狀態，快 <500ms；GET /api/v1/transactions/{orderId}），自動跨月回溯。**這是查單的預設入口（第一步）**：使用者問「訂單 X 怎麼了 / 成功了沒 / 現在什麼狀態 / 上個月那筆」一律先用本 skill。**固定程序**：拿到狀態後 —— 終態（成功 / 失敗）直接回報；**若為 PROCESSING（處理中），必須立即自動接 `ll-order-refresh` 重新同步、以刷新後的狀態回報（自動步驟,不詢問、不提議「要不要刷新」,直接做）**。整月清單改用 ll-transactions。**僅支援 caller-aggregated 變體**：商戶號由 callerChatId 反查綁定決定，嚴禁攜帶 mchntCd 以防跨商戶越權；caller 綁多個商戶 → 400 MULTIPLE_BINDINGS（須由 admin 收斂綁定，本 skill 不接受顯式 mchntCd）。找不到回 200 + data.found=false（非 404）；響應為 envelope。
---

# ll-order — 單筆訂單查詢（含跨月回溯）

> 版本：v3.2（強制 caller-aggregated；移除「指定 mchntCd」變體以杜絕跨商戶越權）

## 何時使用

- 「訂單 ORDER-123 成功了沒」
- 「這筆交易現在是什麼狀態」
- 「我那張單子處理完了嗎」
- 「上個月某筆訂單」（用 `lookbackMonths`）

不是這個 skill 的場景：
- 看一整月清單 → `ll-transactions`
- 不知道 orderId 只想看最近 → `ll-transactions`
- 狀態看起來不一致 → `ll-order-refresh`（重新同步校正）

> ⚠️ 查到 **PROCESSING（處理中）時不要停在本 skill 回報** —— 程序要求**自動**接 `ll-order-refresh`（見下「查詢程序（處理中必接刷新）」）。

## 查詢程序（處理中必接刷新）

1. 用本 skill `GET` 拿訂單目前狀態。
2. 看 `state`：
   - `SUCCESSFUL` / `FAILED`（終態）→ 直接回報，結束（**不**用 refresh）。
   - **`PROCESSING`（處理中）→ 立即自動呼叫 `ll-order-refresh` 重新同步，以刷新後回傳的狀態回報。**
     - 🔒 **這是自動步驟、不是選項**：**禁止**回「要不要幫您刷新 / 需要的話可以幫您確認最新」這類提議，也**不要**停在「目前處理中」就結束。判定處理中 = 直接做刷新，再把刷新後結果交給使用者。
     - refresh 後**仍** PROCESSING，才回報「處理中」（此時已是上游最新）。

## 端點

```
GET ${ICPAY_TG_BASE_URL}/api/v1/transactions/{orderId}
```

> **僅支援 caller-aggregated 變體** — 由 `callerChatId` 反查綁定商戶，藉此保證 caller 只能查到「自己綁定」的商戶訂單，從根本上杜絕跨商戶越權。
> **禁止使用** `GET /api/v1/merchants/{mchntCd}/transactions/{orderId}` 主端點（即便 token 的 `allowedMchntCds` 容許，亦不在本 skill 範圍）。

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
| path | `orderId` | ✅ | 商戶端訂單號（最長 50）|
| query | `channel` | ✅ | `TG` / `SK` |
| query | `callerChatId` | ✅ | 從環境變數；**商戶號由此反查決定** |
| query | `callerUserId` | ✅ | 從環境變數 |
| query | `lookbackMonths` | ❌ | 跨月回溯月數，`0..6`，預設 `1`（找當月 + 前 1 月）|
| header | `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_MER}` |

> ⛔ **禁止欄位**：`mchntCd`（無論放 path、query 或 body 都不接受）。商戶號一律由 `callerChatId` 反查綁定決定，呼叫端無從顯式指定，這是本 skill 防跨商戶越權的核心護欄。

## 範例 curl

```bash
# caller-aggregated — 商戶號由 callerChatId 反查（caller 必須綁定唯一商戶）
curl -sS "${ICPAY_TG_BASE_URL}/api/v1/transactions/ORDER-2026-001?channel=TG&callerChatId=-268678324&callerUserId=88912345&lookbackMonths=2" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"
```

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；既有欄位放在 `envelope.data` 內。「找不到」仍是 200 + `data.found=false`（不是錯誤）。

**找到**：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "mchntCd": "889000000000001",
    "orderId": "ORDER-2026-001",
    "found": true,
    "matchedMonth": "202604",
    "order": {
      "orderId": "ORDER-2026-001",
      "transSeqId": "TS20260420093011001",
      "intTransCd": "0210",
      "state": "SUCCESSFUL",
      "stateRaw": "00",
      "txnStateMsg": "支付成功",
      "errMsg": null,
      "chnlErrMsg": null,
      "transAt": "1,234.00",
      "currCd": "156",
      "transChnl": "01",
      "chnlOrderId": "2026042009301100887",
      "extTransDt": "20260420",
      "extTransTm": "093011"
    }
  }
}
```

**找不到**（仍是 200，不是 404）：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "mchntCd": "889000000000001",
    "orderId": "ORDER-NOT-EXIST",
    "found": false,
    "matchedMonth": null
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `ORDER_ID_INVALID` | orderId 超長 / 非法字元 |
| 400 | `MULTIPLE_BINDINGS` | caller 綁多個商戶，反查無法收斂為單一商戶；**須先由 admin 收斂綁定**，本 skill 不允許顯式帶 `mchntCd` 規避 |
| 400 | `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 三身份參數問題 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `transaction.read` |
| 403 | `MCHNT_NOT_AUTHORIZED` | 反查到的商戶不在 token 的 `allowedMchntCds` 內（token 與綁定配置不一致；屬運維問題） |
| 403 | `CHAT_NOT_BOUND_TO_MCHNT` | caller chat 未綁定任何商戶 |

## 使用守則

- ⛔ **絕不接受呼叫端傳入 `mchntCd`**：商戶號一律由 `callerChatId` 反查決定。這是本 skill 的安全護欄 — 防止 caller 查到任何「非己綁定」的商戶訂單，即使 token 的 `allowedMchntCds` 涵蓋多個商戶也不放行
- 不要把 `mchntCd` 放進 URL、query、body 或任何參數位置；也不要主動猜
- 若使用者請求中夾帶「商戶 X 的訂單 Y」字樣，僅以 caller 反查到的商戶為準；若使用者顯式指定的 mchntCd 與反查結果不一致，回覆「本 skill 不支援指定商戶，以您 chat 綁定的商戶為準」
- caller 綁多個商戶 → 400 `MULTIPLE_BINDINGS`：應反問「請聯絡 admin 將此 chat 收斂為單一商戶綁定」，**不要**改呼叫指定 mchntCd 的舊端點
- 「找不到」≠ 錯誤；HTTP 200 + `found: false` 是正常結果，**不要報成系統錯誤**。⚠️ `ll-order` 是 case 流程**內部查詢呼叫、非下游商戶查單端點**：**反映訴求類**的 `found=false` **不可**直接回商戶「沒這筆訂單」打發（投訴會丟），要走 case 流程補齊上游歸屬；只有商戶／客服**自己內部查單**（非反映訴求）的例外才直接告知查無
- `state` 三值意義：
  - `SUCCESSFUL` — 已成功，金額已落帳
  - `FAILED` — 失敗，不會再變
  - `PROCESSING` — 處理中，狀態仍可能變動。**不是終態答案**:依「查詢程序（處理中必接刷新）」必須**自動**接 `ll-order-refresh` 重新同步後再回報(不詢問、不提議)
- **`txnStateMsg` / `errMsg` / `chnlErrMsg` 是原始錯誤訊息 free-text 3 欄**（對應 `tbl_trans_logNN.txn_state_msg` / `err_msg` / `chnl_err_msg`），後端不合成，原始透出。
- **呈現錯誤訊息的原則：忠實保留錯誤的原始語意，直接陳述、不改寫、不抽象、不換成籠統說法**。對這 3 欄只做兩件「減法」，其餘原意照實傳達：
  1. **剝除敏感識別碼**（信任邊界，見下）：`mchntCd` / `chnlOrderId` / `transSeqId` / 渠道號 / 渠道名——尤其 `chnlErrMsg` 可能內嵌，剝掉這些識別碼後**保留其餘錯誤語意**；
  2. **去除純技術鷹架雜訊**：stack trace 行、`檔名 at line N`（如 `txn_sync_resp.ftl at line 3`）、模板運算式（`${...}`）等——只去鷹架，**保留錯誤語意句本身**。
- ⚠️ **不改寫、也不挑選/丟棄語意**：
  - 不可把系統 / 模板異常改寫成業務原因；
  - **也不可自行判斷「哪部分才是真因」而只取讀得懂的片段、丟掉其餘錯誤語意**。例如 `报文转换异常: 订单未受理:暂无可用通道` 要**整串**呈現（「報文轉換異常：訂單未受理，暫無可用通道」），**不可**只留「暫無可用通道」而把「報文轉換異常」丟掉。
  - 原文有什麼錯誤描述就**完整帶上**，只做兩件減法（剝識別碼 + 去鷹架），其餘語意**一字不刪、不轉換**。
- **各狀態**：
  - `state="SUCCESSFUL"` → 用 `txnStateMsg`（如「支付成功」）；若空則用「成功」
  - `state="FAILED"`（失敗或帶錯誤）→ **完整、原樣陳述 `errMsg`（前端向、優先）等錯誤訊息的全部語意**（只剝識別碼 + 去鷹架，不挑選、不判斷真因、不精簡）；多欄有互補資訊一併帶上。三欄皆空才退用「失敗」
  - `state="PROCESSING"` → 簡述「處理中」即可，不需 errMsg / chnlErrMsg（處理中沒有錯誤訊息）
- 跨月回溯：查老單時把 `lookbackMonths` 拉大（最多 6）；不要無腦帶 6（會多查 6 個月分表）
- 預設 `lookbackMonths=1` 已涵蓋當月 + 前一月，多數情境足夠
- 三組主要的交易識別 ID（用途與受眾不同）：
  - `orderId` — **商戶側**訂單號（商戶自己的單號）
  - `transSeqId` — **我方內部**流水（純內部 ID）
  - `chnlOrderId` — **上游渠道側**訂單號（`tbl_trans_logNN.chnl_order_id`；上游未回填為 `null`）
- **對外回覆的信任邊界**（內部排查 / 對帳可三者並用;對外嚴格受限）：
  - 對**商戶** → ID 只給 `orderId`;`transSeqId` / `chnlOrderId` 及其他**內部 / 渠道欄位**（`intTransCd` / `stateRaw` / `transChnl`）**一律不外露**（含「渠道訂單號 / 上游訂單號 / 平台訂單號」等同義改寫）。⚠️ 這只是**剔除跨方欄位**——金額 / 狀態 / 交易時間**照給商戶**（輸出格式由 ll-mer 查單 SOP 決定,別只回一句狀態）
  - 對**渠道** → 只給 `chnlOrderId`;商戶 `orderId` / `transSeqId` 不外露
- **金額欄位（`transAt`）原樣顯示、保留千分位逗號**：後端回傳的 `transAt` 字串已是最終顯示格式（固定兩位小數、千位以上含千分位逗號，例：`1,005.00`、`1,234,567.89`）。直接原樣輸出該字串、**完整保留其中的逗號**（後端給 `1,005.00` 就顯示 `1,005.00`，不可寫成 `1005.00`），不可改寫、四捨五入、補 / 去零或移除任何數字格式
