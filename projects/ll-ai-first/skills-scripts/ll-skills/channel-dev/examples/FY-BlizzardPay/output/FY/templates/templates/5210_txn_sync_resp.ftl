<#-- 5210_txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
<#-- 
${svc.assertEqual('Error: ' + (ctx.msg!'Transaction error!'), '200', ctx.code?string)} 
${svc.assertNotEmpty('data参数不可为空',ctx.data)}
 -->
{
 
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!''}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",
  "chnlTxnStatusDesc" : "${ctx.msg!''}",
  "txnStatus" : "${svc.getTranslatedCode('WITHDRAW',ctx.code?string!'')!'01'}",
  "txnStatusDesc" : "${ctx.msg!''} - ${svc.getTranslatedMsg('WITHDRAW', (ctx.code?string)!'')!'异常'}",
  "respCode" : "0000",
  "respMsg" : "OK"
}