<#-- txn_sync_resp.ftl: 代收同步響應模板（跳轉上游收銀台） -->
<#setting number_format="0">

<#if (ctx.status?string) == "1">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.trans_id!''}",
  "codeImgUrl": "${ctx.transaction_url!''}",
  "codePageUrl": "${ctx.transaction_url!''}",
  "txnStatus": "01",
  "txnStatusDesc": "In processing",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "txnStatus": "20",
  "txnStatusDesc": "${ctx.error_msg!''}",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>