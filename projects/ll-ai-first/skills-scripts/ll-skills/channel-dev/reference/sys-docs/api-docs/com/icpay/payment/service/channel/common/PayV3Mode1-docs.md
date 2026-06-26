# PayV3Mode1 — V3 單段式支付模式（含 Header/JWT/URL 變數）

類別名稱：`com.icpay.payment.service.channel.common.PayV3Mode1`

## 說明

基於 `MyChnlBaseV2` 的第三代單段式支付模式。在 V2 Mode1 基礎上新增以下功能：

1. **Header 中的簽名內容支援**：簽名結果可放入 HTTP Header
2. **JWT 支援**：可從 Header 中提取/注入 JWT
3. **URL 變數**：請求地址支援 `${var}` 變數，自動從模型中替換
4. **改進的模板 context**：
   - `mem` — 過程中記憶的值（可藉由 `svc.assign()` 存放）
   - `mem.sgSrc` — 計算後的待簽內容（Map）
   - `mem.reqHdr` — 請求 Header（Map）
   - `mem.rspHdr` — 回應 Header（Map）
   - `mem.jwtBody` — JWT Payload（Map）

### 交易流程

同 PayV2Mode1，但在以下環節加強：
- 發送前：將 headers 存入 `mem.reqHdr`，URL 支援變數替換
- 收到回應後：將回應 headers 存入 `mem.rspHdr`

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV2` → `ChnlServiceBase`
- **已知子類別**: `PayV3Mode2`, `PayV3Mode3`, `PayV3Mode1USDTCOBO`

## API說明

### Class: PayV3Mode1

#### Protected 部分

##### 交易流程方法

| 方法 | 回傳型別 | 說明 |
|---|---|---|
| `doConvRequest(Map, Map)` | `ChnlRequestContext` | 支付請求：`doCommonTrans` → 取得 URL → 跳轉 |
| `doCommonTrans(Map, Map)` | `TxnResultContext` | 完整交互：簽名 → 轉換 → assign headers → `calcUrl` → 發送 → assign 回應 headers → 驗章 → 轉換 |
| `doConvResult(String, Map, Map, Map)` | `TxnAsyncResultContext` | 異步通知：assign headers → 驗章 → 轉換 |
| `doConvSyncResultForAsync(String, Map)` | `TxnAsyncResultContext` | 回傳 null（跳轉類） |
| `doQuery(Map, Map)` | `TxnResultContext` | 查詢：簽名 → assign headers → `calcUrl` → 發送 → assign 回應 headers → 驗章 → 轉換 |
