<#-- 5210_txn_sync_resp.ftl: 代付同步響應模板 -->
<#setting number_format="0">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnStatusDesc": "${ctx.message!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW', ctx.code?string!'')!'20'}",
  "txnStatusDesc": "${ctx.message!''} - ${svc.getTranslatedMsg('WITHDRAW', ctx.code?string!'')!'异常'}",
  "respCode": "0000",
  "respMsg": "OK"
}
