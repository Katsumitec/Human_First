<#-- 5210_txn_req.ftl: 代付請求報文模板（5210） -->
<#-- sign 由系統根據 5210_txn_req_sign.ftl 計算後填入 ctx.sign -->
<#setting number_format="0">
{
  "VerifyChannelNo": "${ctx.VerifyChannelNo!'1'}",
  "out_trade_no": "${ctx.out_trade_no!''}",
  "bank_id": "${ctx.bank_id!''}",
  "bank_owner": "${ctx.bank_owner!''}",
  "account_number": "${ctx.account_number!''}",
  "amount": "${ctx.amount!''}",
  "callback_url": "${ctx.callback_url!''}",
  "sign": "${ctx.sign!''}"
}
