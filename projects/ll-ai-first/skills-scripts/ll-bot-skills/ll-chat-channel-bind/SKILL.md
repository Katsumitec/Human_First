---
name: ll-chat-channel-bind
description: 建立 chat 與支付渠道（chnlId 2 字英數，禁用 '00'）的綁定（POST /api/v1/chat-channel-binding）。當運營 / admin 要求「把這群組綁到 08 渠道」「為 F1 渠道設定通知群」時觸發；可選 chnlMchntCd（渠道大商編，未指定 = 該渠道所有大商編都綁同 chat 萬用 fallback）。N:N、冪等；授權 admin OR；響應為 envelope。
---

# ll-chat-channel-bind — chat ↔ 渠道綁定

> 版本：v3.1（對齊 API_Spec.yaml v4.1.0）

## 何時使用

- 「把這個群組綁到渠道 08」
- 「為渠道 F1 / WX 設定通知接收群」
- 「重新啟用之前 unbind 過的 chat-channel 綁定」（冪等重綁會把 state 0 復活成 1，回 outcome=reactivated）
- 同一個群組同時綁多個渠道（N:N，每個渠道是獨立一筆）

不是這個 skill 的場景：
- 綁定 chat ↔ 商戶 → `ll-bind`（PRD-F-001，那是用 mchntCd，本 skill 是 chnlId）
- 解綁 chat ↔ 渠道 → `ll-chat-channel-unbind`
- 查我所屬商戶涵蓋的渠道群組清單 → `ll-channel-chats`

## 端點

```
POST ${ICPAY_TG_BASE_URL}/api/v1/chat-channel-binding
Content-Type: application/json
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_ADMIN` | Bearer token（scope: `binding.write`）|
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端所在 chat；用於 admin OR 判定（**與被綁定的 `chatId` 是不同概念**）|
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID；用於 admin OR 判定 |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `callerChatId` | ✅ | 呼叫端所在 chat；用於 admin OR 判定（**與 `chatId` 不同概念**）|
| `callerUserId` | ✅ | 呼叫端 user ID；用於 admin OR 判定 |
| `chatId` | ✅ | 被綁定的目標 chat ID（寫入 DB `chat_id` 欄）；ASCII printable，最長 100；與 `callerChatId` 解耦，可由 admin 代為綁定其他 chat |
| `chnlId` | ✅ | 渠道編號（2 字英數，case-insensitive，例 `08` / `F1` / `wx`）；後端 normalize 為大寫後寫入。**禁用 `'00'`**（保留給商戶綁定）→ 400 `CHANNEL_ID_RESERVED` |
| `chnlMchntCd` | ❌ | 渠道商戶號（大商編；語意對齊 `tbl_txn_routing.chnl_mchnt_cd`）；格式 `[0-9A-Za-z_]{1,100}`。**未指定時預設 `'0000'`**，語意為「此渠道所有大商編都綁同 chatId」（萬用 fallback row）；ll-channel-chats 反查時若該 `(chnl_id, chnl_mchnt_cd)` 對找不到精準綁定才會 fallback 到此萬用 row |
| `chnlDesc` | ❌ | 渠道描述（最長 256），存入 DB `comments` 欄；查詢 GET 時以 `chnlDesc` 回傳 |
| `defaultLang` | ❌ | chat 群組默認語系；BCP 47 格式（如 `zh-TW` / `en-US`）；後端**不做格式校驗**，僅長度上限 16；未指定時讀取側 fallback 為 `en`。**`outcome=idempotent_hit` 時不覆寫**既存值；`created` / `reactivated` 時寫入 |
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_ADMIN}` |

> 跟 `ll-bind` 對齊：
> - 沒有 `channel` 入參（後端固定 `category='TG'`）
> - **`chatId` / `callerChatId` 為兩個獨立概念**（與 `ll-bind` 一致）：`chatId` 是要綁的目標 chat，`callerChatId` 是呼叫端所在 chat（用於 admin OR 判定）
> - `chnlMchntCd` 是選填（預設 `'0000'`），不像 ll-bind 的 `mchntCd` 必填具體商戶

## 範例 curl

**不指定 `chnlMchntCd`（預設走萬用 `'0000'`；表示「此渠道所有大商編都綁同此 chat」）**：

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/chat-channel-binding" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "callerChatId": "-1001234567890",
    "callerUserId": "88912345",
    "chatId": "-1001234567890",
    "chnlId": "08",
    "chnlDesc": "支付寶 H5",
    "defaultLang": "zh-TW"
  }'
```

**指定具體 `chnlMchntCd`（精準綁定特定渠道大商編；admin 代為綁定他人 chat，`chatId` ≠ `callerChatId`）**：

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/chat-channel-binding" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_ADMIN}" \
  -H "Content-Type: application/json" \
  -d '{
    "callerChatId": "-1009999999999",
    "callerUserId": "88912345",
    "chatId": "-1001234567890",
    "chnlId": "F1",
    "chnlMchntCd": "ALI_M88",
    "chnlDesc": "FastPay 渠道",
    "defaultLang": "en-US"
  }'
```

> `chnlMchntCd` 省略時填 `'0000'` 寫入 DB；ll-channel-chats 反查時 `(chnl_id, chnl_mchnt_cd)` 對先查精準綁定，找不到才 fallback 到此萬用 row。
> `defaultLang` 可省略；省略時讀取側 fallback 為 `en`。**注意 `chnlId` 不可填 `'00'`**（保留給商戶綁定，會回 400 `CHANNEL_ID_RESERVED`）。

## 回傳

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`、`message=null`；綁定欄位放在 `envelope.data` 內。`envelope.defaultLang` 為 server 預設語系 hint，`data.defaultLang` 為該綁定設定值（兩者語意不同）。

`data.outcome` 三值區分本次處理結果：

**201 — `data.outcome=created`** 新建（4-tuple 不存在）

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "category": "TG",
    "chnlId": "08",
    "mchntCd": "0000",
    "chatId": "-1001234567890",
    "state": "1",
    "chnlDesc": "支付寶 H5",
    "defaultLang": "zh-TW",
    "outcome": "created",
    "recCrtTs": "2026-05-08T03:12:16Z"
  }
}
```

**200 — `data.outcome=idempotent_hit`** 同 4-tuple 已存在且 `state='1'`，未寫 DB

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "category": "TG",
    "chnlId": "08",
    "mchntCd": "0000",
    "chatId": "-1001234567890",
    "state": "1",
    "chnlDesc": "支付寶 H5",
    "defaultLang": "zh-TW",
    "outcome": "idempotent_hit",
    "recCrtTs": "2026-05-08T03:12:16Z"
  }
}
```

**200 — `data.outcome=reactivated`** 既有 row `state='0'`，已 UPDATE 為 `state='1'` 並覆寫 comments

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "category": "TG",
    "chnlId": "08",
    "mchntCd": "0000",
    "chatId": "-1001234567890",
    "state": "1",
    "chnlDesc": "重新啟用",
    "defaultLang": "zh-TW",
    "outcome": "reactivated",
    "recCrtTs": "2026-05-07T10:00:00Z"
  }
}
```

> `data.defaultLang` 缺失或解析失敗 → `null`。`outcome=idempotent_hit` 時即使本次入參帶了新值也**不會覆寫**既存值。

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `BAD_REQUEST` | 入參缺失（含 `chatId`）或 chnlId 不符 `^[A-Za-z0-9]{2}$` |
| 400 | `CHANNEL_ID_RESERVED` | `chnlId='00'`（保留給商戶綁定）|
| 400 | `VALIDATION_FAILED` | 欄位驗證失敗，例 `chatId` 長度 > 100 / 非 ASCII printable、`defaultLang` 長度 > 16 |
| 400 | `MCHNT_CD_INVALID` | `chnlMchntCd` 格式不合（[0-9A-Za-z_]{1,100}）|
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 缺 / 不對 |
| 403 | `SCOPE_INSUFFICIENT` | token 沒 `binding.write` |
| 403 | `NOT_ADMIN` | callerUserId 不在 admin user 清單 **且** callerChatId 不在 admin chat 清單（admin OR 兩條件都不滿足）|
| 403 | `MCHNT_NOT_AUTHORIZED` | `chnlMchntCd` 不在 token allowedMchntCds（`chnlMchntCd` ≠ `'0000'` 時生效）|
| 502 | `UPSTREAM_ERROR` | DB 故障 |

## 使用守則

- **admin OR 授權**：callerUserId ∈ `{channel}.users.admin` **或** callerChatId ∈ `{channel}.chats.admin`，兩條件擇一即可；兩者皆不滿足回 403 `NOT_ADMIN`
- **`chatId` vs `callerChatId`**：`chatId` 是要綁定到渠道的目標 chat（寫入 DB），`callerChatId` 是發起呼叫的 chat（僅用於 admin OR 判定）；兩者可相同（一般情境）或不同（admin 從其他 chat 代為綁定）
- **`chnlId` 禁用 `'00'`**：`'00'` 是商戶綁定保留值，渠道綁定打到 `'00'` 會回 400 `CHANNEL_ID_RESERVED`；若使用者意圖綁商戶請改用 `ll-bind`
- **chnlId 大小寫**：使用者打 `f1` 或 `F1` 都接受；後端統一 normalize 為大寫，DB 永遠存大寫
- **`defaultLang` 純語系標籤**：後端不校驗 BCP 47 格式，但長度上限 16；若要改既存綁定的 `defaultLang`，請 `ll-chat-channel-unbind` 後重綁（idempotent_hit 不會覆寫）
- **N:N 行為**：同一 `chatId` 可綁多個 `chnlId`（例 08、F1、WX 三筆獨立 row）；同一 `chnlId` 也可被多個 chat 綁
- **`chnlMchntCd` 概念**：對齊 `tbl_txn_routing.chnl_mchnt_cd`（渠道大商編 / channel-side merchant code）；和 F-001 的 `mchntCd`（平台 mchntCd）不同層次 — 前者是某渠道下的子大商編，後者是平台商戶號
  - 絕大多數情境用 `'0000'`（不指定具體大商編；語意：「這群組接收此渠道**所有大商編**的通知」，作為**萬用 fallback row**）
  - 只有要區分特定渠道大商編接收不同群組時才填具體值（例 `ALI_M88` / `WX_PRO`）
  - 反查時對每筆 `tbl_txn_routing(chnl_id, chnl_mchnt_cd)` 對先查精準綁定，0 筆才 fallback 至此 `'0000'` 萬用 row
- **`outcome` 區分**：
  - `created` ↔ 真新建（HTTP 201）
  - `reactivated` ↔ 之前被 unbind 過、現在復活（HTTP 200）
  - `idempotent_hit` ↔ 完全沒變化（HTTP 200）；告知使用者「已是綁定狀態」即可
- 操作會寫入 audit log（`CHAT_CHANNEL_BINDING_CREATE` / `_REACTIVATE` / `_IDEMPOTENT_HIT`）
