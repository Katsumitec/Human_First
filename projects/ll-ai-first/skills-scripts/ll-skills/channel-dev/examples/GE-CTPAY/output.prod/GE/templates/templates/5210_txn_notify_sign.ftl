<#-- 5210_txn_notify_sign.ftl: 代付異步通知驗簽模板（5210） -->
<#-- 驗簽欄位：固定 4 個（trade_no, amount, out_trade_no, state） -->
<#-- 排除：sign, callback_url -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!''}",
  "out_trade_no": "${ctx.out_trade_no!''}",
  "state": "${ctx.state!''}",
  "trade_no": "${ctx.trade_no!''}"
}
