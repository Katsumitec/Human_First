<#-- 5210_txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat('0.00')} <#-- 设置渠道金额的格式化方式 -->
<#assign rawAmount = svc.toChnlAmt(ctx.txnAmt)>
<#assign formattedAmount = rawAmount?number?string("0.##")>

{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": "${ctx.pay_apply_date}",
"pay_order_id": "${ctx.chnlOrderId}",
"pay_notify_url": "${ctx.pay_notify_url}",
"pay_amount": ${formattedAmount},
"pay_account_name": "${ctx.pay_account_name}",
"pay_card_no": "${ctx.pay_card_no}",
"pay_bank_name": "${ctx.pay_bank_name}",
"pay_md5_sign": "${ctx.sign}"
}