<#-- txnQry_resp.ftl: 代收查詢響應解析模板 -->
<#setting number_format="0">

<#if (ctx.status?string) == "1">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.trans_id!''}",
  "chnlTxnStatus": "${ctx.trans_status!''}",
  "chnlTxnStatusDesc": "${ctx.trans_status!''}",
  "txnStatus": "${svc.getTranslatedCode('PAY_QRY', ctx.trans_status!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('PAY_QRY', ctx.trans_status!'')!'处理中'}",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnStatus": "${ctx.error_code!''}",
  "chnlTxnStatusDesc": "${ctx.error_msg!''}",
  "txnStatus": "01",
  "txnStatusDesc": "查询失败，保留处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>