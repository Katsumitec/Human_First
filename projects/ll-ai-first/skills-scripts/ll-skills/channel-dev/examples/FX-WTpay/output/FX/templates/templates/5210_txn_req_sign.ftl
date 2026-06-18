<#-- 5210_txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat('0.##')} <#-- 设置渠道金额的格式化方式 -->
{
"out_trade_no": "${ctx.chnlOrderId}",
"bank_id": "${ctx.chnlBankNum}",
"bank_owner" : "${ctx.accName}",
"account_number": "${ctx.accNum}",
"amount":  "${svc.toChnlAmt(ctx.txnAmt)}",
"callback_url": "${ctx.chnlNotifyUrl!''}"
}
