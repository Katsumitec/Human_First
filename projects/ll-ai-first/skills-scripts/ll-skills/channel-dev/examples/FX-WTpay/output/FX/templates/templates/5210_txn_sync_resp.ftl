<#-- 5210_txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
<#if ctx.success?string == "true">
	${svc.assertNotEmpty('data参数不可为空',ctx.data)}

	{
 
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!''}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.data.trade_no!''}",
  "chnlTxnStatusDesc" : "${ctx.message!''}",
  "txnStatus" : "${svc.getTranslatedCode('WITHDRAW',ctx.data.state?string!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('WITHDRAW',ctx.data.state?string!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "OK"
	}
<#else>
	{
 
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!''}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnId" : "${ctx.trade_no!''}",
  "chnlTxnStatusDesc" : "${ctx.message!''}",
  "txnStatus" : "${svc.getTranslatedCode('WITHDRAWCODE',ctx.status_code?string!'')!'01'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg('WITHDRAWCODE',ctx.status_code?string!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "OK"
	}
</#if>