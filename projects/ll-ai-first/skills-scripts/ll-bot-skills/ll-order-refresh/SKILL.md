---
name: ll-order-refresh
description: 訂單狀態的**升級刷新**：向來源重新同步後回傳最新狀態（POST /api/v1/transactions/refresh）。**⚠️ 不是一般查單第一步** —— 查單一律先用 `ll-order`（快 <500ms）。**在這三種情形用本 skill**：① **`ll-order` 查回 PROCESSING（處理中）→ 由 ll-order 程序自動接本 skill**（處理中必刷新,不需使用者開口）;② 使用者**明確要求**「刷新 / 催一下 / 確認上游 / force」;③ 狀態不一致需校正。**較慢：同步阻塞 ~30s**（終態單 `triggered=false` 略過、處理中單 `triggered=true` 才實際重新同步）；scope `transaction.refresh`；響應為 envelope。
---

# ll-order-refresh — 訂單刷新（重新同步取最新）

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）

## 何時使用

> **先決條件**:查單第一步一律走 `ll-order`。本 skill 是**第二步/升級**,不要拿來當第一手查單入口。

- **`ll-order` 查回 PROCESSING（處理中）→ 自動接本 skill 重新同步**（ll-order 程序要求,非選項,不需使用者要求）
- 「ORDER-123 卡在處理中很久了，幫我**催**一下」
- 「幫我**刷新 / force 上游**確認這筆最新狀態」
- 「下游回說狀態還沒更新，我這邊看也是處理中」
- 「客服說 Order 跟 trans_log 對不上，幫我修一下」

> **本 skill 的定位與成本**：對 ll-order 的快取讀做一次「**重新同步取最新**」;同步阻塞 ~30s（見下「使用守則」）。終態單 `triggered=false`(已最終態、略過重拉)、處理中單 `triggered=true`(實際重新同步)。

## 端點

```
POST ${ICPAY_TG_BASE_URL}/api/v1/transactions/refresh
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_MER` | Bearer token（scope: `transaction.refresh`，**獨立於 `transaction.read`**） |
| `ICPAY_TG_CHANNEL` | 預設 `TG` |
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端 chat ID |
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID |

## 入參（POST JSON body）

| 名稱 | 必填 | 說明 |
|------|:---:|------|
| `channel` | ✅ | `TG` / `SK` |
| `callerChatId` | ✅ | 從環境變數 |
| `callerUserId` | ✅ | 從環境變數 |
| `orderId` | ✅ | 商戶訂單號（最長 50） |
| `mchntCd` | ❌ | 商戶號（可選）；不傳則用 callerChatId 反查綁定商戶輪試 |

## 範例 curl

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/transactions/refresh" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}" \
  -H "Content-Type: application/json" \
  --max-time 35 \
  -d '{
    "channel": "TG",
    "callerChatId": "-268678324",
    "callerUserId": "88912345",
    "orderId": "ORDER-2026-001",
    "mchntCd": "M001"
  }'
```

**重要**：`--max-time 35`（或 client read timeout ≥ 30s），因為內部會做：
1. tbl_order + tbl_trans_log 雙表 lookup（含跨月回溯 1 個月）
2. 對外狀態一致性檢查
3. 若處理中 / 不一致 → 上游 Hessian RPC `queryChnlTxnResult`（含商戶後端通知）
4. `Thread.sleep(5_000)` 等候 IO 收斂
5. 重讀兩張表 + post-trigger 一致性檢查

最壞情境總耗時 ~30s。**不要在 5s 內重複呼叫同一 `(mchntCd, orderId)`**（server 不做 dedupe，重打會觸發第二次商戶通知）。

## 回傳（200）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；訂單欄位放在 `envelope.data` 內。失敗時 `code` 用業務錯誤碼常數（如 `ORDER_NOT_FOUND` / `STATE_INCONSISTENT` / `UPSTREAM_RPC_FAILED`）。

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "mchntCd": "M001",
    "orderId": "ORDER-2026-001",
    "txnState": "10",
    "txnStateDesc": "成功",
    "txnStateMsg": "支付成功",
    "errMsg": null,
    "chnlErrMsg": null,
    "amount": "1,200.00",
    "currency": "CNY",
    "extTransDt": "20260508",
    "extTransTm": "143012",
    "chnlId": "01",
    "chnlMchntCd": "ALIPAY_MERCHANT_88912",
    "chnlOrderId": "2026050822357981234",
    "triggered": true,
    "settledAt": "2026-05-08T14:30:12+08:00"
  }
}
```

### 對外抽象狀態 `txnState`（4 值）

| 值 | 描述 | 含義 |
|---|---|---|
| `01` | 處理中 | 仍未進入結束狀態；若 `triggered=true`，代表已觸發上游但 5s 後仍處理中（可能還在通道側轉帳）|
| `10` | 成功 | 已成功，金額已落帳 |
| `20` | 失敗 | 失敗，不會再變 |
| `30` | 其他結束 | 結束但非成功 / 失敗（如：超時、撤銷、退款等 `tbl_order.state=33 Other`）|

### 原始錯誤訊息 3 欄 `txnStateMsg` / `errMsg` / `chnlErrMsg`

對應 `tbl_trans_logNN.txn_state_msg` / `err_msg` / `chnl_err_msg`，由 trans_log 補（極少情境 trans_log 缺失時三欄為 `null`）。

- `txnStateDesc` 是**後端組裝**的固定狀態描述（「成功 / 失敗 / 處理中 / 其他結束」）；`txnStateMsg` / `errMsg` / `chnlErrMsg` 是 **DB 原始 free-text**，後端不合成，原始透出。
- **呈現錯誤訊息的原則：忠實保留錯誤的原始語意，直接陳述、不改寫、不抽象、不換成籠統說法**。只做兩件「減法」，其餘原意照實傳達：
  1. **剝除敏感識別碼**（信任邊界，見下）：`mchntCd` / `chnlOrderId` / `transSeqId` / `chnlId` / `chnlMchntCd` / 渠道名——尤其 `chnlErrMsg` 可能內嵌，剝掉識別碼後**保留其餘錯誤語意**；
  2. **去除純技術鷹架雜訊**：stack trace 行、`檔名 at line N`（如 `txn_sync_resp.ftl at line 3`）、模板運算式（`${...}`）——只去鷹架，**保留錯誤語意句本身**。
- ⚠️ **不改寫、也不挑選/丟棄語意**：
  - 不可把系統 / 模板異常改寫成業務原因；
  - **也不可自行判斷「哪部分才是真因」而只取讀得懂的片段、丟掉其餘錯誤語意**。例如 `报文转换异常: 订单未受理:暂无可用通道` 要**整串**呈現（「報文轉換異常：訂單未受理，暫無可用通道」），**不可**只留「暫無可用通道」而把「報文轉換異常」丟掉。
  - 原文有什麼錯誤描述就**完整帶上**，只做兩件減法（剝識別碼 + 去鷹架），其餘語意**一字不刪、不轉換**。
- **各狀態**（與 `txnState` 4 值對應）：
  - `txnState="10"`（成功）→ 用 `txnStateMsg`（如「支付成功」）；若空則沿用後端 `txnStateDesc`「成功」
  - `txnState="20"` / `"30"`（失敗或其他結束、帶錯誤）→ **完整、原樣陳述 `errMsg`（前端向、優先）等錯誤訊息的全部語意**（只剝識別碼 + 去鷹架，不挑選、不判斷真因、不精簡）；多欄有互補資訊一併帶上。`errMsg`/`txnStateMsg`/`chnlErrMsg` 皆空才退用後端 `txnStateDesc`
  - `txnState="01"`（處理中）→ 簡述「處理中」即可，不需 errMsg / chnlErrMsg（處理中沒有錯誤訊息）

### `triggered` 欄位

- `true` — 本次實際呼叫了上游 RPC（因處理中或狀態不一致）
- `false` — 本地已是 final state 且一致，跳過上游（未實際打 RPC,回的就是當前終態狀態）

### `settledAt` 欄位

- `txnState=01` 時為 `null`
- 其他狀態為 `tbl_order.rec_upd_ts`（ISO 8601）

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `BAD_REQUEST` / `CHANNEL_INVALID` / `CALLER_ID_INVALID` | 入參格式不合 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 缺 `transaction.refresh`（**注意**：`transaction.read` 不夠！） |
| 403 | `CHAT_NOT_BOUND_TO_MCHNT` | 呼叫 chat 與商戶綁定關係不成立 |
| 404 | `ORDER_NOT_FOUND` | 在所有候選商戶下都查無此 `orderId`（含跨月回溯後仍未命中） |
| **409** | **`STATE_INCONSISTENT`** | **上游 RPC + 5s 後仍 `tbl_order.state` 對外映射 ≠ `tbl_trans_log.txn_state`；訊息「交易狀態不一致，請聯繫客服處理」（上游也修不了＝真正資料污染） |
| 502 | `UPSTREAM_RPC_FAILED` | 上游 Hessian RPC 拋例外（連線錯誤 / 序列化失敗 / 上游 panic） |

## 使用守則

- **5s 內不要對同一訂單重打**：會觸發第二次上游 RPC + 商戶後端通知（push noise）
- **read timeout 必須 ≥ 30s**：sync 阻塞上游 IO + 5s 等候 + 兩段同步 HTTP，最壞 30s
- **`triggered=false`** = 本地已終態一致、本次未實打上游(回的是當前狀態)
- **`409 STATE_INCONSISTENT`** 是嚴重資料污染信號：訂單狀態與交易日誌對不上連上游都修不了；訊息「交易狀態不一致，請聯繫客服處理」要原樣轉達使用者
- **`502 UPSTREAM_RPC_FAILED`** 通常是「上游不可用」而非「訂單失敗」；建議引導使用者稍後再試
- 三組主要的交易識別 ID（用途與受眾不同）：
  - `orderId` — **商戶側**訂單號（商戶自己的單號）
  - `transSeqId` — **我方內部**流水（純內部 ID）
  - `chnlId` / `chnlMchntCd` / `chnlOrderId` — **上游渠道側**標識（如支付寶內部商戶號 / 訂單號）
- **對外回覆的信任邊界**（內部排查 / 對帳可三者並用;**對外嚴格受限**）：
  - 對**商戶** → ID 只給 `orderId`;`chnlId` / `chnlMchntCd` / `chnlOrderId` / 渠道號**一律不外露**（含「渠道訂單號 / 上游訂單號 / 平台訂單號」等**同義改寫**也不可）。⚠️ 這只是**剔除跨方欄位**——金額 / 狀態 / 交易時間**照給商戶**（別只回一句狀態）
  - 對**渠道** → 只給 `chnlOrderId`;商戶 `orderId` 不外露
- **金額欄位（`amount`）原樣顯示、保留千分位逗號**：後端回傳的 `amount` 為字串、已是最終顯示格式（固定兩位小數、千位以上含千分位逗號，例：`1,005.00`、`1,234,567.89`）。對商戶顯示時直接原樣輸出該字串、**完整保留其中的逗號**（後端給 `1,005.00` 就顯示 `1,005.00`，不可寫成 `1005.00`），不可改寫、四捨五入、補 / 去零或移除任何數字格式

## 與 ll-order 的差異

| 維度 | `ll-order` | `ll-order-refresh` |
|---|---|---|
| HTTP 方法 | `GET` | `POST` |
| Scope | `transaction.read` | `transaction.refresh` |
| 觸發上游 RPC | 否 | 是（若處理中或不一致） |
| 商戶後端通知副作用 | 無 | 有（觸發時） |
| 同步阻塞時長 | < 500ms | 5s + 上游 IO（~10-30s） |
| 狀態回傳 | 3 值 `SUCCESSFUL / FAILED / PROCESSING` | 4 值 `01 / 10 / 20 / 30` |
| 適用情境 | **日常查單預設**(處理中也直接回報) | **明確要求**刷新/催上游 / 校正不一致 |
