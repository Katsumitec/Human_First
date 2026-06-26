<#-- 014d_txn_notify_sign.ftl: 代收異步通知驗簽模板（014d 銀行直連） -->
<#-- 驗簽欄位與 txn_notify_sign.ftl 相同：4 個固定欄位 -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!''}",
  "out_trade_no": "${ctx.out_trade_no!''}",
  "state": "${ctx.state!''}",
  "trade_no": "${ctx.trade_no!''}"
}
