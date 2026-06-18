<#-- 5210_txnQry_resp: 交易查詢 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat('0')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat('0')} <#-- 设置本地金额的格式化 -->
${svc.assertNotEmpty('data参数不可为空',ctx.data)}
<#if (ctx.data.orderStatus?c)! == "1">
${svc.assertEqual('實際支付金額與原訂單金額不一致 ' + (ctx.data.apply?string!'0') + '::' + svc.toChnlAmt(ctx.txnAmt), (ctx.data.apply?string)!'0', svc.toChnlAmt(ctx.txnAmt))}
</#if>
{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.outTradeNo!ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.data.orderNo!''}",<#--
  "chnlRespCd" : "${ctx.orderStatus!''}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.orderStatus!''}", -->
  "chnlTxnStatus" : "${ctx.data.orderStatus!''}",
  "txnStatus" : "${svc.getTranslatedCode('WITHDRAW_QRY',ctx.data.orderStatus!!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('WITHDRAW_QRY',ctx.data.orderStatus!!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}



