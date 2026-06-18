# PayV3Mode1USDTCOBO — USDT CoBo 支付模式（已棄用）

類別名稱：`com.icpay.payment.service.channel.common.PayV3Mode1USDTCOBO`

## 說明

> **@Deprecated** — 此類別已棄用，功能已移至 `icpay-service-chnl-onl-CoBoPay` 專案的 `com.icpay.payment.service.channel.et.PaymentImpl` 類別。

原為 USDT CoBo Pay 渠道的 V3 Mode1 支付實現。與 `PayV3Mode1` 功能相同，包含 Header 支援、URL 變數替換等 V3 特性。額外在異步通知處理中將原始渠道回應字串存入 memory（`chnlRespString`）。

## 架構

- **Package**: `com.icpay.payment.service.channel.common`
- **繼承**: `MyChnlBaseV2` → `ChnlServiceBase`
- **標註**: `@Deprecated`
