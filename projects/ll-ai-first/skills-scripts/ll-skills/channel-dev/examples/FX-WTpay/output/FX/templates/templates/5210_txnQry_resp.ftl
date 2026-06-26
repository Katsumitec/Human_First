<#-- 5210_txnQry_resp: 交易查詢 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat('0')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat('0')} <#-- 设置本地金额的格式化 -->
${svc.assertNotEmpty('data参数不可为空',ctx.data)}
${svc.assertEqual('实际支付金额与原订单金额不一致'+(ctx.data.amount?string)+'::'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.data.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}
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
  "txnStatus" : "${svc.getTranslatedCode('WITHDRAW_QRY',ctx.data.state!!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('WITHDRAW_QRY',ctx.data.state!!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}



