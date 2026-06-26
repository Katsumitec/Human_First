<#-- 5210txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat('0')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat('0')} <#-- 设置本地金额的格式化 -->

${svc.assertEqual('实际支付金额与原订单金额不一致'+(ctx.amount?string)+'::'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.trade_no!''}",<#--
  "chnlRespCd" : "${ctx.state!''}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.state!''}", -->
  "chnlTxnStatus" : "${ctx.state!''}",
  "txnStatus" : "${svc.getTranslatedCode('WITHDRAW_NOTIFY',ctx.state!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('WITHDRAW_NOTIFY',ctx.state!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}