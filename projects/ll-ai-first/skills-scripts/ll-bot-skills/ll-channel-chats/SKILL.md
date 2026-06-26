---
name: ll-channel-chats
description: 查詢 caller 所屬商戶涵蓋的所有渠道對應群組清單（GET /api/v1/chat-bindings/channel-chats）。當使用者問「我商戶有哪些渠道，分別由哪些群組接收通知」「列出我綁定渠道的群組」時觸發。反查邏輯精準優先 fallback 萬用 row；chatId 去重、上限 100 筆截斷；scope `binding.read`；響應為 envelope。
---

# ll-channel-chats — 商戶渠道群組清單查詢

> 版本：v3.1（對齊 API_Spec.yaml v4.1.0）

## 何時使用

- 「我所屬商戶有哪些渠道」
- 「列出每個渠道對應的通知群組」
- 「我商戶涵蓋的渠道有哪些群組接收通知」

不是這個 skill 的場景：
- 建立 chat ↔ 渠道綁定 → `ll-chat-channel-bind`
- 解綁 → `ll-chat-channel-unbind`
- 查 chat ↔ 商戶 綁定（PRD-F-001/002 那層）→ `ll-bind` / `ll-unbind`

## 端點

```
GET ${ICPAY_TG_BASE_URL}/api/v1/chat-bindings/channel-chats
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_MER` 或 `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: **`binding.read`**）|
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端 chat（必須已綁某商戶）|
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user（**僅作為審計 actor**，無 admin 檢查）|

> 新 scope `binding.read` 為 PRD-F-011 落地時新增；既有 token 需 UPDATE param_value 加上此 scope，並透過 `POST /api/v1/internal/reload-tokens` 觸發熱重載。

## 入參（query string）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `callerChatId` | ✅ | 反查商戶集合的 key（查 `tbl_bot_chat_binding` 中 `category='TG' AND chnl_id='00' AND state='1'` 的列）|
| `callerUserId` | ✅ | 僅審計用，不檢 admin 也不檢綁定 |
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_MER}`（或 ADMIN）|

## 範例 curl

```bash
curl -sS -G "${ICPAY_TG_BASE_URL}/api/v1/chat-bindings/channel-chats" \
  --data-urlencode "callerChatId=-268678324" \
  --data-urlencode "callerUserId=88912345" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}"
```

## 回傳（200 always）

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；`items` / `count` / `truncated` 放在 `envelope.data` 內。

**有資料**（`chnlMchntCd` 必填、`currCd` nullable）：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "items": [
      {"chatId": "-268678324", "chnlId": "08", "chnlDesc": "支付寶", "mchntCd": "0000",            "chnlMchntCd": "ALI_M88", "currCd": "156",  "defaultLang": "zh-TW"},
      {"chatId": "-100123",    "chnlId": "92", "chnlDesc": null,     "mchntCd": "921002056400044", "chnlMchntCd": "921002056400044", "currCd": null, "defaultLang": null}
    ],
    "count": 2,
    "truncated": false
  }
}
```

> 欄位說明：
> - **`chnlMchntCd`**（必填）：對應 `tbl_txn_routing.chnl_mchnt_cd`（業務語意「真正的大商編」）；routing 命中**精準綁定**時 `chnlMchntCd == mchntCd`；命中**萬用 fallback**時 `mchntCd='0000'` 但 `chnlMchntCd` 仍是 routing 的具體大商編
> - **`currCd`**（nullable）：對應 `tbl_txn_routing.curr_cd`；空字串視為 null
> - **`defaultLang`**（nullable）：該綁定設定值；缺失或 JSON 解析失敗 → `null`（與 `envelope.defaultLang` 不同概念，後者為 server hint）
> - 第一筆 item 示例：routing `(chnl_id='08', chnl_mchnt_cd='ALI_M88')` 找不到精準綁定 → fallback 至 `(chnl_id='08', chnl_mchnt_cd='0000')` 萬用 row → `mchntCd='0000'`、`chnlMchntCd='ALI_M88'`
> - 第二筆 item 示例：routing `(chnl_id='92', chnl_mchnt_cd='921002056400044')` 命中精準綁定 → `mchntCd == chnlMchntCd`；該 routing `curr_cd` 為空字串 → response 投影為 `null`

**無資料（caller 商戶無路由 / 路由 chnl_id 都未綁 chat-channel）**：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "items": [],
    "count": 0,
    "truncated": false
  }
}
```

**結果集 ≥ 101 筆已截斷**：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "items": [ /* 100 筆 */ ],
    "count": 100,
    "truncated": true
  }
}
```

## 流程語意

```
callerChatId
   │
   │ tbl_bot_chat_binding (category='TG', chnl_id='00', state='1')  ← 多商戶聯集
   ▼
mchntCd 集合 M
   │
   │ tbl_txn_routing (status='1')  ← 取每筆 (chnl_id, chnl_mchnt_cd, curr_cd)
   ▼
routing pairs P：[(chnl_id, chnl_mchnt_cd, curr_cd), ...]
   │
   │ 對每筆 (chnl_id, chnl_mchnt_cd) 對：
   │   ① 精準查 tbl_bot_chat_binding (category='TG', chnl_id, mchnt_cd=chnl_mchnt_cd, state='1')
   │   ② ①  0 筆 → fallback 查 (category='TG', chnl_id, mchnt_cd='0000', state='1')
   │   ③ 兩者皆 0 → 略過該 pair
   ▼
回傳 items（chatId 去重、上限 100；每筆含 chnlMchntCd from routing、currCd from routing、defaultLang from params JSON）
```

- **反查邏輯「精準優先 fallback 萬用」**：對每筆 routing `(chnl_id, chnl_mchnt_cd)` 對先查精準綁定，0 筆才 fallback 至 `(chnl_id, '0000')` 萬用 row；精準存在時萬用 row **不出現**在結果集中
- **`chnlMchntCd` 來源**：response 的 `chnlMchntCd` 永遠是 routing 的具體大商編（不是綁定表的 row 值）；`mchntCd` 才是綁定表 row 直譯（精準命中時相同、萬用命中時為 `'0000'`）
- **`currCd` 不參與 join**：`tbl_txn_routing.curr_cd` 僅用作 response 投影回填，反查條件中只用 `(chnl_id, chnl_mchnt_cd)`；空字串視為 null
- chatId 去重：同 chatId 出現多次（不同 chnlId / chnlMchntCd / currCd）只留一筆，挑 chnlId 字典序最小者代表
- 上限截斷：結果集 > 100 → 取前 100 筆 + `truncated=true`
- 未綁的 routing pair（精準 + 萬用都查不到）：略過（不回 null 占位）

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `BAD_REQUEST` | callerChatId / callerUserId 缺失或格式不合 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `binding.read` |
| 403 | `CALLER_NOT_BOUND` | callerChatId 沒綁任何商戶（無法反查商戶集合）|

> 不會回 404；caller 商戶無路由 / chnl_id 無綁定都回 200 + count=0。

## 使用守則

- ⚠️ **受眾分流(讀其餘守則前先看這條)**：本 API 回的 `items`(`mchntCd` / `chnlMchntCd` / `chnlId` / 其他群 `chatId` / `chnlDesc`)是**我方內部綁定／路由資訊**,屬「對商戶、對渠道兩邊都不出」的內部層。
  - 下面「可讀性回應」**逐筆展示** items 的格式,**僅適用於**呼叫端在 **ops / admin / debug** 場景**明確要列自己的渠道清單**。
  - 在**客服 / 商戶面 / 渠道面群組**裡,**一律不得複述 items 任何欄位**;綁定查詢這類問題只回「當前 chat_id + 有無綁定(yes/no)」,其餘導向運營從系統側查。
  - **粒度看「所在群／受眾」,不看「誰問」**(即使 admin 在商戶群問也照此收斂)。
- **可讀性回應(僅 ops/admin/debug 列清單場景適用,見上)**：把每筆 item 轉成「渠道 {chnlId}（{chnlDesc}） / 大商編 {chnlMchntCd} → chat {chatId}」一行；沒有 chnlDesc 時用「渠道 {chnlId} / 大商編 {chnlMchntCd} → chat {chatId}」即可；若 `defaultLang` 不為 null 可附註「(語系：{defaultLang})」；若 `currCd` 不為 null 可附註「(幣別：{currCd})」
- **`chnlMchntCd` vs `mchntCd` 解讀**：對使用者展示**業務語意大商編請用 `chnlMchntCd`**（永遠是 routing 的具體值）；`mchntCd` 為綁定 row 直譯（萬用 fallback 時為 `'0000'`），對非工程使用者不易理解，建議不展示或僅在 debug 模式展示
- **精準 vs 萬用**：當 `mchntCd == chnlMchntCd` 表示該渠道大商編有**精準綁定**；當 `mchntCd == '0000'` 但 `chnlMchntCd` 非 `'0000'` 表示走**萬用 fallback**（該渠道未針對該大商編設專屬群組，沿用渠道層萬用 row）
- **`currCd` 為 null**：表示該 routing 的 `curr_cd` 為空字串或 NULL；對使用者一般不需提示，可省略不顯示
- **`defaultLang` 為 null**：表示該綁定建立時沒指定預設語系，或 `params` JSON 解析失敗；caller 自行決定 fallback（規格建議讀取側 fallback 為 `en`）
- **多商戶聯集**：一個群組綁多個商戶時，回的是所有商戶 chnl_id 的並集；agent 不需主動拆分
- **截斷處理**：`truncated=true` 時提示使用者「結果超過 100 筆，已截斷；如需完整清單請縮小範圍」
- **`callerUserId` 為審計用**：不像 `ll-chat-channel-bind/unbind` 必須是 admin；任何已綁商戶的 chat 都可查
- **`binding.read` scope**：部分既有 token 可能尚未授權；遇到 403 SCOPE_INSUFFICIENT 提示需要更新 token 配置
