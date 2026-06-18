<#-- txnQry_resp.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat('0')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat('0')} <#-- 设置本地金额的格式化 -->
${svc.assertNotEmpty('data参数不可为空',ctx.data)}
 

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.outTradeNo!ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.data.trade_no!''}",<#--
  "chnlRespCd" : "${ctx.state!''}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.state!''}", -->
  "chnlTxnStatus" : "${ctx.data.state!''}",
  "txnStatus" : "${svc.getTranslatedCode('PAY_NOTIFY',ctx.data.state!!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('PAY_NOTIFY',ctx.data.state!!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
  
}