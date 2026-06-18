<#-- 5210_txnQry_req_sign.ftl: 代付查詢請求簽名模板（GG NewSKYPay）-->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}"
}