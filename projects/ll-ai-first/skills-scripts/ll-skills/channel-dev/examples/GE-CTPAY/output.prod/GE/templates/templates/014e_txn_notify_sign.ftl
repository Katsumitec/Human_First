<#-- 014e_txn_notify_sign.ftl: 代收異步通知驗簽模板（014e） -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!''}",
  "out_trade_no": "${ctx.out_trade_no!''}",
  "state": "${ctx.state!''}",
  "trade_no": "${ctx.trade_no!''}"
}
