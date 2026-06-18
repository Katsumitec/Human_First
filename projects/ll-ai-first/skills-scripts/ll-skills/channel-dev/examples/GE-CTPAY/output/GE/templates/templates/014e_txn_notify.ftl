<#-- 014e_txn_notify.ftl: 代收異步通知解析模板（014e 網銀掃碼） -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
${svc.assertNotEmpty('out_trade_no 為空', ctx.out_trade_no!'')}
${svc.assertEqual('實際支付金額與訂單金額不一致: '+ctx.amount+'!='+svc.toChnlAmt(ctx.txnAmt)?string, ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.out_trade_no!''}",
  "chnlTxnId": "${ctx.trade_no!''}",
  "chnlRespCd": "${ctx.state!''}",
  "chnlRespMsg": "${ctx.state!''}",
  "chnlTxnStatus": "${ctx.state!''}",
  "chnlTxnStatusDesc": "${ctx.state!''}",
  "txnStatus": "${svc.getTranslatedCode('PAY_NOTIFY', ctx.state!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('PAY_NOTIFY', ctx.state!'')!'處理中'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
