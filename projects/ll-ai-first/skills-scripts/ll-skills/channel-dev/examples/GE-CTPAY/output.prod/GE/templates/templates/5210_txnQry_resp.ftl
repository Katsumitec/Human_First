<#-- 5210_txnQry_resp.ftl: 代付查詢響應解析模板（0050） -->
<#-- 狀態碼：new/processing/verify=01, completed=10, failed/reject/refund=20 -->
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
  "chnlTxnAmt": "${svc.fromChnlAmt((ctx.data.amount!0)?string)!''}",
  "chnlTxnStatus": "${ctx.data.state?string!''}",
  "chnlTxnStatusDesc": "${ctx.data.state?string!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW_QRY', ctx.data.state?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW_QRY', ctx.data.state?string!'')!'處理中'}",
  "respCode": "0000",
  "respMsg": "Queried"
}
