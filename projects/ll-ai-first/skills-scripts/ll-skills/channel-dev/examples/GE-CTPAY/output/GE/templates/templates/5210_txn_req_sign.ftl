<#-- 5210_txn_req_sign.ftl: 代付請求簽名模板（5210） -->
<#-- 代付 sign 必填，對除 sign 外所有欄位按 ksort 計算 MD5 -->
<#-- VerifyChannelNo=1 為官方示例必帶字段 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
{
  "VerifyChannelNo": "1",
  "account_number": "${ctx.accNum!''}",
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "bank_id": "${ctx.chnlBankNum!''}",
  "bank_owner": "${ctx.accName!''}",
  "callback_url": "${ctx.chnlNotifyUrl!''}",
  "out_trade_no": "${ctx.chnlOrderId!''}"
}
