<#-- txnQry_resp.ftl: 代收查詢響應解析模板（GG NewSKYPay）
     status=1: 訂單存在; orderStatus: 0→01, 3→10, 8→20
-->
<#setting number_format="0">

<#if ctx.status?string == '1'>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.data.payOrderId!''}",
  "chnlTxnStatus": "${ctx.data.orderStatus?string!''}",
  "chnlTxnStatusDesc": "${ctx.data.orderStatus?string!''}",
  "txnStatus": "${svc.getTranslatedCode('PAY_QRY', ctx.data.orderStatus?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('PAY_QRY', ctx.data.orderStatus?string!'')!'处理中'}",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnStatus": "${ctx.status?string!''}",
  "chnlTxnStatusDesc": "${ctx.msg!''}",
  "txnStatus": "01",
  "txnStatusDesc": "查询失败，保留处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>