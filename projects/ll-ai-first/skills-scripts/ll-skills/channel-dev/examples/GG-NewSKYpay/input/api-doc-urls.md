# GG-NewSKYpay API 文檔子頁面 URL 列表

> 來源：http://18.163.184.55/doc
> 抓取日期：2026-04-27
> 抓取方式：agent-browser open + eval（提取側邊欄 `[onclick]` 元素）

## 分類與子頁面

| 分類 | 接口名稱（Title） | URL |
|------|-----------------|-----|
| 代付接口 | 出款下单（代付下單） | http://18.163.184.55/doc/withdraw/index.html |
| 代付接口 | 出款查询（代付查單） | http://18.163.184.55/doc/withdraw/query.html |
| 代付接口 | 订单通知（代付異步通知） | http://18.163.184.55/doc/withdraw/notify.html |
| 代付接口 | 银行类型（銀行類型表） | http://18.163.184.55/doc/withdraw/bankType.html |
| 代付接口 | **反查商户接口规范(必须接)**（反查回調） | http://18.163.184.55/doc/withdraw/query_merchant_order.html |
| 代收接口 | 充值下单（代收下單） | http://18.163.184.55/doc/deposit/index.html |
| 代收接口 | 充值订单查询（代收查單） | http://18.163.184.55/doc/deposit/query.html |
| 代收接口 | 订单通知（代收異步通知） | http://18.163.184.55/doc/deposit/notify.html |
| 余额接口 | 余额查询（商戶餘額查詢） | http://18.163.184.55/doc/balance/balance.html |

## 重要備註

- 「**反查商戶接口規範(必須接)**」實際歸屬於**代付接口**分類（非代收）— 此與部分對接需求描述「代收 → 反查」不同，請以此 API 文檔結構為準。
- 反查接口場景：上游收到我方代付下單後，會主動回調我方反查接口確認訂單存在與一致性，回應為純文字 `OK` / `ERROR`。
- 所有頁面均屬於同一站點 http://18.163.184.55/doc，內容由 JS 動態載入到右側 `iframe` / `content` 區域。
