<#-- 5210_txn_req_sign.ftl: 代付請求報文簽名模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}
{
"merchant_code": "${svc.getChnlMerId()}",
"merchant_order_no": "${ctx.chnlOrderId}",
"amount": "${svc.toChnlAmt(ctx.txnAmt)}",
"service_type": "${svc.getMerParam('type', '700')}",
"bank_code": "${ctx.chnlBankNum!''}",
"callback_url": "${ctx.chnlNotifyUrl!''}",
"card_name": "${ctx.accName!''}",
"card_num": "${ctx.accNum!''}",
"merchant_user": "${ctx.accName!''}",
"mobile_no": "${ctx.accNum!''}",
"platform": "PC",
"risk_level": "1"
}