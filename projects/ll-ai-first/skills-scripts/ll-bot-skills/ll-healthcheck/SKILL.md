---
name: ll-healthcheck
description: 探測 icpay-tg-bot-services 服務是否存活與是否就緒（liveness `/healthz` 永遠 200；readiness `/readyz` 200 = ready / 503 = degraded 含 deps map）。當使用者問「服務還活著嗎」「DB / Redis 通嗎」「為什麼讀不到資料」時觸發；不涉及任何業務 API。匿名（不需 token）；判斷可用性以 HTTP code 為主，envelope `code` 為次要訊號。
---

# ll-healthcheck — 服務探活與就緒

> 版本：v3.0（對齊 API_Spec.yaml v4.0.0）
> Response 統一 envelope `{code, message, defaultLang, data}`：
> - `/healthz` 永遠 200 + `code="OK"` + `data.status="ok"`
> - `/readyz` 200 + `code="OK"` + `data` 含 `status` / `deps`（ready）
> - `/readyz` 503 + `code="UPSTREAM_ERROR"` + `data` 含 `status="degraded"` / `deps`（degraded；AccessProfile=NONE 故 `defaultLang` fallback 至 `app.lang.mer-default`）

## 何時使用

- 「服務還活著嗎？」
- 「為什麼查不到餘額？是不是後端掛了？」
- 「DB / Redis 通嗎？」
- 「現在是不是部署中？」
- 監控腳本 / SRE 巡檢的慣例 ping

不是這個 skill 的場景：
- 業務查詢失敗想看「為什麼不通」→ 看回應的 HTTP code 與 `code` 欄位
- 看 metrics 數值（QPS / 延遲）→ 不在本 skill 範圍（建議走 Grafana）

## 端點

```
GET ${ICPAY_TG_BASE_URL}/healthz   # liveness（永遠 200，只要進程活著）
GET ${ICPAY_TG_BASE_URL}/readyz    # readiness（DB / Redis 任一不通 → 503）
```

兩端點皆**匿名**（不需 token）。

## 必要環境變數

| 變數 | 用途 |
|------|------|
| `ICPAY_TG_BASE_URL` | 服務 base URL |

## 範例 curl

**liveness**

```bash
curl -sS "${ICPAY_TG_BASE_URL}/healthz"
```

**readiness**（含依賴狀態）

```bash
curl -sS -w "\nHTTP %{http_code}\n" "${ICPAY_TG_BASE_URL}/readyz"
```

## 回傳

> Response envelope `{code, message, defaultLang, data}`。成功時 `code="OK"`；503 degraded 時 `code="UPSTREAM_ERROR"`。`status` / `deps` 欄位放在 `envelope.data` 內。AccessProfile=NONE → `defaultLang` 由 `app.lang.mer-default` 決定（預設 `en`）。

**healthz 200（永遠這樣）**

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "en",
  "data": { "status": "ok" }
}
```

**readyz 200 — ready**

```json
{
  "code": "OK",
  "message": null,
  "defaultLang": "en",
  "data": {
    "status": "ok",
    "deps": {
      "mysql": "ok",
      "redis": "ok"
    }
  }
}
```

**readyz 503 — degraded**（任一依賴不通）

```json
{
  "code": "UPSTREAM_ERROR",
  "message": "one or more dependencies are down",
  "defaultLang": "en",
  "data": {
    "status": "degraded",
    "deps": {
      "mysql": "ok",
      "redis": "down: connection refused"
    }
  }
}
```

## 判斷信號優先順序

healthcheck 端點也走 envelope，但「是否能服務」仍以 **HTTP status** 為主：
- 200 = healthy / ready（envelope `code="OK"`）
- 503 = readyz 偵測到依賴異常（envelope `code="UPSTREAM_ERROR"`，`data.deps` 列詳情）
- timeout / connection refused = 服務根本沒起來

K8s liveness / readiness probe 通常配置只看 HTTP code，不解析 body；envelope 的 `code` 是給人類 / 自動化腳本看細節用。

## 使用守則

- **healthz 永遠 200** 的設計是 K8s liveness probe 的慣例 — 它只代表「進程沒死」，不代表「能服務」；判斷「能不能用」要看 readyz
- 發生業務查詢失敗時建議流程：
  1. 先打 `/readyz`：若 503 → 報告使用者「服務在重啟 / 依賴掛掉」
  2. 若 200 → 業務問題（看具體 API 的回應 `code`），不是基礎設施問題
- 不要把 healthcheck 當做業務監控工具 — 它只回答「活 / 死」，不回答「快 / 慢」「對 / 錯」
- 如使用者要看 metrics，告知這個 skill 不負責，可去 Grafana（T-403 條線設計給 Prometheus + Grafana 使用）
- 預設探測頻率：人類詢問時就打一次；自動化巡檢腳本建議 ≥ 30 秒一次（避免成為自我 DoS）
