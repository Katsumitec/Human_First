<#-- txnQry_resp.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('data参数不可为空',ctx.data)}
<#if (ctx.data.status?string)! == "1" || (ctx.data.status?string)! == "2">
  <#-- ${svc.assertEqual('实际支付金额与原订单金额不一致: ' + (ctx.data.real_amount?string!'0') + ' != ' + svc.toChnlAmt(ctx.txnAmt), ctx.data.real_amount?string!'0', svc.toChnlAmt(ctx.txnAmt))} -->
<#assign realAmt = (ctx.data.real_amount?string!'0')?number>
  <#assign expectedAmt = (svc.toChnlAmt(ctx.txnAmt))?number>
  
  ${svc.assertEqual('实际支付金额与原订单金额不一致: ' + realAmt + ' != ' + expectedAmt, realAmt?string, expectedAmt?string)}
</#if>

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.data.transaction_id!''}",
  "chnlTxnStatus" : "${(ctx.data.status?string)!''}",
  "txnStatus" : "${svc.getTranslatedCode('PAY_QRY', (ctx.data.status?string)!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('PAY_QRY', (ctx.data.status?string)!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}