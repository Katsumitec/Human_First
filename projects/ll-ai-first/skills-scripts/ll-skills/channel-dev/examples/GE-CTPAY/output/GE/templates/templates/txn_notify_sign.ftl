<#-- txn_notify_sign.ftl: 代收異步通知驗簽模板 -->
<#-- 驗簽欄位：固定 4 個（trade_no, amount, out_trade_no, state） -->
<#-- 排除：sign, request_amount, callback_url -->
<#-- 系統將此 JSON 轉為 Map，ksort 後串接 sign.key 做 MD5 -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!''}",
  "out_trade_no": "${ctx.out_trade_no!''}",
  "state": "${ctx.state!''}",
  "trade_no": "${ctx.trade_no!''}"
}
