<#-- 014d_txnQry_resp.ftl: 代收查詢響應解析模板（014d） -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.data.out_trade_no!''}",
  "chnlTxnId": "${ctx.data.trade_no!''}",
  "chnlTxnAmt": "${svc.fromChnlAmt((ctx.data.amount!0)?string)?string}",
  "chnlTxnStatus": "${ctx.data.state?string!''}",
  "chnlTxnStatusDesc": "${ctx.data.state?string!''}",
  "txnStatus": "${svc.getTranslatedCode('PAY_QRY', ctx.data.state?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('PAY_QRY', ctx.data.state?string!'')!'處理中'}",
  "respCode": "0000",
  "respMsg": "Queried"
}