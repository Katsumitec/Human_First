<#-- 5210_txn_sync_resp.ftl: 代付同步響應模板 -->
<#setting number_format="0">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.trans_id!''}",
  "chnlTxnStatus": "${ctx.status!''}",
  "chnlTxnStatusDesc": "${ctx.error_msg!''}",
  <#assign statusCode = "${ctx.status!''}${ctx.error_code!''}" />
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW', statusCode)!'20'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW', statusCode)!'失败'}",
  "respCode": "0000",
  "respMsg": "OK"
}