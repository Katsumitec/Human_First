<#-- txnQry_resp.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('data参数不可为空',ctx.data)}

<#if (ctx.data.paySuccess?c)! == "true">
  <#-- Fixed the Chinese parenthesis here -->
  ${svc.assertEqual('實際支付金額與原訂單金額不一致 ' + (ctx.data.amountTrue!0) + '::' + svc.toChnlAmt(ctx.txnAmt), (ctx.data.amountTrue?string)!'0', svc.toChnlAmt(ctx.txnAmt))}
</#if>

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.data.orderNo!''}",
  "chnlTxnStatus" : "${(ctx.data.paySuccess?string)!''}",
  "txnStatus" : "${svc.getTranslatedCode('PAY_QRY', (ctx.data.paySuccess?string)!'')!'01'}",
"txnStatusDesc" : "${svc.getTranslatedMsg('PAY_QRY', (ctx.data.paySuccess?string)!'')!'异常'}",
  "respMsg" : "Notified"
}