---
name: ll-order-by-chnl
description: 以渠道訂單號（平台訂單號 chnlOrderId）查單（POST /api/v1/transactions/lookup-by-chnl-order）。觸發時機：(a) 上游渠道群成員提供渠道訂單號查該單狀態（直接有界查詢、非 case-driven，對渠道受眾對稱隱瞞——只回 chnlOrderId+state，禁回商戶 orderId/mchntCd/transSeqId，見 ADR 0011）；(b) 拿到渠道端/平台訂單號想對到內部訂單時。caller 必須已綁定渠道（chat-channel-binding），跨月查當月 + 前 1 月；多筆命中全回 list，對渠道不轉述 data.warning 內部結構。
---

# ll-order-by-chnl — 以渠道訂單號查商戶訂單

> 版本：v1.1（PRD-F-013 / Issue #85 + Issue #86 testenv fix；對齊 API_Spec.yaml v4.2.2）

## 何時使用

- 「渠道側看到訂單 ABC 但商戶端找不到」
- 「這是支付寶那邊的單號，幫我查對應商戶訂單」
- 「拿到對帳檔上的平台訂單號 X，是哪筆商戶單？」

不是這個 skill 的場景：
- 知道商戶訂單號 → `ll-order`（含跨月回溯與 caller-aggregated 變體）
- 訂單卡住要催上游 → `ll-order-refresh`
- 看整月清單 → `ll-transactions`

## 端點

```
POST ${ICPAY_TG_BASE_URL}/api/v1/transactions/lookup-by-chnl-order
Content-Type: application/json
```

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |
| `ICPAY_TG_TOKEN_MER` | Bearer token（scope: `transaction.read`）|
| `ICPAY_TG_CALLER_CHAT_ID` | 呼叫端所在 chat ID |
| `ICPAY_TG_CALLER_USER_ID` | 呼叫端 user ID |

## 入參（JSON body）

| 欄位 | 必填 | 說明 |
|------|:---:|------|
| `callerChatId` | ✅ | 呼叫端 chat（用於反查渠道綁定）|
| `callerUserId` | ✅ | 呼叫端 user（audit）|
| `chnlOrderId` | ✅ | 渠道訂單號 / 平台訂單號（最長 100）|
| `channel` | ❌ | 外部 channel 識別（如 `TG`）；省略時 service 從 caller 綁定反查 |
| `chnlMchntCd` | ❌ | 渠道大商編；省略時列出該 chat 所有 active 渠道綁定（不限 mchntCd）|
| header `Authorization` | ✅ | `Bearer ${ICPAY_TG_TOKEN_MER}` |

## 範例 curl

**指定 `chnlMchntCd`（精準綁定）**：

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/transactions/lookup-by-chnl-order" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}" \
  -H "Content-Type: application/json" \
  -d '{
    "callerChatId": "-1001234567890",
    "callerUserId": "88912345",
    "chnlOrderId": "2026050822357981234",
    "chnlMchntCd": "ALI_M88"
  }'
```

**不指定 `chnlMchntCd`（列出 caller 所有綁定渠道一起查）**：

```bash
curl -sS -X POST "${ICPAY_TG_BASE_URL}/api/v1/transactions/lookup-by-chnl-order" \
  -H "Authorization: Bearer ${ICPAY_TG_TOKEN_MER}" \
  -H "Content-Type: application/json" \
  -d '{
    "callerChatId": "-1001234567890",
    "callerUserId": "88912345",
    "chnlOrderId": "2026050822357981234"
  }'
```

## 回傳

> Response envelope `{code, message, defaultLang, data}`。`data.list` 為命中的訂單清單（**多筆全回**），`data.count` 為筆數，`data.warning` 在 `count > 1` 時帶警告字串。

**單筆命中（正常）**：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "list": [
      {
        "transSeqId": "TS20260508143012001",
        "mchntCd": "M001",
        "orderId": "O20260508001",
        "transChnl": "F1",
        "chnlMchntCd": "ALI_M88",
        "chnlOrderId": "2026050822357981234",
        "intTransCd": "0121",
        "state": "SUCCESSFUL",
        "stateRaw": "10",
        "txnStateMsg": "支付成功",
        "errMsg": null,
        "chnlErrMsg": null,
        "transAmt": "1,200.00",
        "currCd": "CNY"
      }
    ],
    "count": 1,
    "warning": null
  }
}
```

**多筆命中（需警告使用者）**：

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "zh-TW",
  "data": {
    "list": [ ... 多筆 ... ],
    "count": 2,
    "warning": "同 chnlOrderId 命中 2 筆，預期單筆，請檢查路由設定"
  }
}
```

## 錯誤碼

| HTTP | code | 條件 |
|:---:|------|------|
| 400 | `BAD_REQUEST` / `VALIDATION_FAILED` | 入參缺失或格式錯誤 |
| 401 | `AUTH_MISSING` / `AUTH_INVALID` | token 問題 |
| 403 | `SCOPE_INSUFFICIENT` | token 缺 `transaction.read` |
| 403 | `CALLER_NOT_BOUND_TO_CHANNEL` | callerChatId 尚未綁定任何渠道（或 service 未能反查到 category）→ 提示使用者先 `ll-chat-channel-bind` |
| 502 | `UPSTREAM_ERROR` | DB 故障 |

## 使用守則

### 🔴 對渠道受眾的信任邊界 — 對稱隱瞞(ADR 0011-C1/C3)

當本 skill 服務**上游渠道群**(caller 是渠道、回覆要送進渠道群)時:

- **只可回**渠道自己給的 `chnlOrderId` + 客觀 `state` + 下面彙整的 `stateDesc`。
- ❌ **禁回**:商戶 `orderId`(下游身份)/ `mchntCd` / `transSeqId`(我方純內部,兩方都不給)/ 他渠道 `chnlMchntCd` / 渠道名 / 路由拓撲。
- 把這些原樣轉述進渠道群 = 把**下游商戶身份洩給上游同業**(0006-C1/C2 的反向)。
- ⚠️ **`stateDesc` 對渠道走固定模板**(「成功」/「失敗」/「處理中」),**禁從 `errMsg`/`chnlErrMsg`/`txnStateMsg`/`warning` 等 free-text 生成**(ADR 0011-C1):這些欄位可內嵌商戶識別 / 他渠道資訊 / 路由事實,一轉述就洩。下面「LLM 自行彙整 stateDesc」的 errMsg/chnlErrMsg 規則**只適用內部/ops 受眾,不適用渠道群**。
- 渠道查狀態是**直接有界查詢、非 case-driven**:不立 case、不 fanout(ADR 0011-C2);與商戶側「意圖即立案」相反。
- ⚠️ **此 SKILL 紅線是 prompt-only 過渡層**:真正的硬擋是後端對渠道受眾只回 sanitized 欄位(ADR 0011-C5),在那之前 LLM 仍拿得到 `mchntCd`/`orderId`/`transSeqId`/`warning`,僅靠本紅線約束 → 殘留軟層風險。
- 完整 SOP 見 ll-mer-agent 注入檔 `CHANNEL-QUERY.md`。

### LLM 自行彙整 `stateDesc`

後端**只回原始欄位**（`state` / `stateRaw` / `txnStateMsg` / `errMsg` / `chnlErrMsg`），不合成 stateDesc。請依下列規則彙整給使用者看的「狀態說明」：

- `state="SUCCESSFUL"` → 用 `txnStateMsg`（如「支付成功」）；若空則用「成功」
- `state="FAILED"` → 優先用 `errMsg`，退到 `chnlErrMsg`，再退到 `txnStateMsg`；若都空則用「失敗」
- `state="PROCESSING"` → 簡述「處理中」即可，不需 errMsg / chnlErrMsg（處理中沒有錯誤訊息）

### 多筆命中(count > 1)— 對渠道 fail-closed

`data.count > 1` 時 `data.warning` 一定有值,且是**資料完整性異常,非正常查單結果**。⚠️ **對渠道受眾 fail-closed**(ADR 0011-C3):
- **不回任何 state**,回有界「資料需人工核對,請勿據此處理,已轉相關同事」並轉 ops。
- **禁原樣轉述 `data.warning`**(含「同號多筆 / 路由設定錯誤 / 多 `chnl_mchnt_cd`」內部結構 → 洩多商戶/路由拓撲),**也禁挑一筆回狀態**(渠道據錯單行動比洩 warning 更糟)。
- **內部/ops 受眾**(非渠道群):才可看完整 warning。常見原因:同一商戶在多個 `chnl_mchnt_cd` 下複用同一 `chnlOrderId`、路由設定錯誤導致同筆訂單寫了兩次。

### `CALLER_NOT_BOUND_TO_CHANNEL` 引導

若回 403 此錯誤，提示使用者：
- 「目前這個群組尚未綁定任何渠道，請先聯絡 admin 用 ll-chat-channel-bind 綁定」
- 不要建議使用者改用 ll-order（那是商戶側查單，本 skill 是渠道側查單，意圖不同）

### `chnlMchntCd` 概念

- `chnlMchntCd` 是**渠道側的大商編**（如支付寶的商戶號 `ALIPAY_MERCHANT_88912`），不是平台 mchntCd
- 反查邏輯（v4.2.2 起）：
  - 未指定 → service 列出該 chat 所有 active 渠道綁定 chnl_id（不限 mchntCd），多渠道聯查
  - 有指定 → 精準查 `mchnt_cd=chnlMchntCd`；0 筆且非 `'0000'` 才 fallback 萬用 `mchnt_cd='0000'`
- 一般情境**不需要傳** `chnlMchntCd`；只有「同一渠道下要把查單範圍鎖定到特定大商編」時才傳具體值

### 跨月行為

API 自動跨當月 + 前 1 月查 `tbl_trans_logNN`。**沒有 lookbackMonths 入參可調**（與 ll-order 不同）— 若使用者要查更早的訂單，建議用 `ll-order` 或 `ll-transactions`。

### 邊界 / 注意

- 操作會寫入 audit log
- 多筆命中時 `data.list` 順序不保證
- **金額欄位（`transAmt`）原樣顯示、保留千分位逗號**：後端回傳的 `transAmt` 為字串、已是最終顯示格式（固定兩位小數、千位以上含千分位逗號，例：`1,005.00`、`1,234,567.89`）。對商戶 / 內部受眾顯示金額時直接原樣輸出該字串、**完整保留其中的逗號**（後端給 `1,005.00` 就顯示 `1,005.00`，不可寫成 `1005.00`），不可改寫、四捨五入、補 / 去零或移除任何數字格式（對渠道受眾依上方紅線本就不外露金額）
