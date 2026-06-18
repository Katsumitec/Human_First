<#-- txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat('0')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat('0')} <#-- 设置本地金额的格式化 -->

<#-- ${svc.assertEqual('实际支付金额与原订单金额不一致'+(ctx.real_amount?string)+'::'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.real_amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}  -->
${svc.assertNotEmpty('status参数不可为空', ctx.status)}
${svc.assertEqual('实际支付金额与原订单金额不一致: '+(ctx.real_amount?string!'0')+' != '+(svc.toChnlAmt(ctx.txnAmt)), ctx.real_amount?string!'0', svc.toChnlAmt(ctx.txnAmt))}

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.transaction_id!''}",<#--
  "chnlRespCd" : "${ctx.status!''}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.status!''}", -->
  "chnlTxnStatus" : "${ctx.status!''}",
  "txnStatus" : "${svc.getTranslatedCode('PAY_NOTIFY',ctx.status!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('PAY_NOTIFY',ctx.status!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}