<#-- 0098_txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
<#assign orderResult=svc.queryOrderByChnlOrderIdWithAmt(ctx.merchantOrderId, ctx.payAmount) />
<#assign respToChannel = 'fail' />
<#if orderResult.result_code == '0000'>
  <#assign respToChannel = 'success' />
</#if>
{
  "channel" : "${ctx.channel!ctx.channelId!svc.getChannel()}",
  "intTxnType" : "${ctx.intTxnType!svc.getIntTxnType()}",
  "chnlOrderId" : "${ctx.merOrderId!ctx.chnlOrderId!''}",
  "respToChannel" : "${respToChannel}",
  "respContentType" : "text/plain"
}