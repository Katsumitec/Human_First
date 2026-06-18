<#-- txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat('0.00')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat('0')} <#-- 设置本地金额的格式化 -->

${svc.assertNotEmpty('status参数不可为空',ctx.payStatus)}
${svc.assertEqual('实际支付金额与原订单金额不一致'+(ctx.amountTrue?string)+'::'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.amountTrue?string, svc.toChnlAmt(ctx.txnAmt)?string)}

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.orderNo!''}",<#--
  "chnlRespCd" : "${ctx.payStatus!''}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.payStatus!''}", -->
  "chnlTxnStatus" : "${ctx.payStatus!''}",
  "txnStatus" : "${svc.getTranslatedCode('PAY_NOTIFY',ctx.payStatus!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('PAY_NOTIFY',ctx.payStatus!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}
