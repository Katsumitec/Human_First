<#-- txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.assertEqual('Error: ' + (ctx.message!'Transaction error!'), 'true', ctx.success?string)} 
${svc.assertNotEmpty('data参数不可为空',ctx.data)}
<#assign casherUrl>${svc.getCasherUrl(ctx,'ch_qrcode', ctx.data.qrcode!'','currentLang','vn')}</#assign>
{
  
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!''}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",<#--
  "chnlTxnId" : "${ctx.rockTradeNo!''}",-->
  <#--
  "codeImgUrl" : "${ctx.data.uri!''}",
  "codePageUrl" : "${ctx.data.uri!''}",
  -->
  "codeImgUrl" : "${casherUrl!''}",
  "codePageUrl" : "${casherUrl!''}",
  "qrcode": "${ctx.data.qrcode!''}",
  "txnStatus" : "01",
  "txnStatusDesc" : "In processing",
  "respCode" : "0000",
  "respMsg" : "OK"
}