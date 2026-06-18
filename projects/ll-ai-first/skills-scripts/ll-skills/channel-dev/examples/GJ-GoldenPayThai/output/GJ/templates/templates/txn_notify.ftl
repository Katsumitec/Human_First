<#-- txn_notify.ftl: 代收异步通知解析 -> 我方格式 -->
<#setting number_format="0"/>
${svc.setCurrencyByCode("764")}
${svc.setChnlAmtUnitStr("1.0")}
${svc.setChnlAmtFormat("0.00")}
${svc.setLocalAmtFormat("0")}

${svc.assertEqual(
  "實際支付金額與訂單金額不一致：payed=" + ((ctx.payed_amount)!"") + " vs orig=" + (svc.toChnlAmt(ctx.txnAmt)),
  (ctx.payed_amount?number?string["0.00"]),
  (svc.toChnlAmt(ctx.txnAmt)?number?string["0.00"])
)}
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.mch_id!svc.getChnlMerId()!""}",
  "chnlOrderId": "${ctx.trans_id!ctx.chnlOrderId!""}",
  "chnlTxnId": "${ctx.id!""}",
  "chnlRespCd": "${ctx.status?string!""}",
  "chnlRespMsg": "status=${ctx.status?string!""}",
  "chnlTxnStatus": "${ctx.status?string!""}",
  "chnlTxnStatusDesc": "status=${ctx.status?string!""}",
  "txnStatus": "${svc.getTranslatedCode("PAY_NOTIFY", ctx.status?string!"")!"20"}",
  "txnStatusDesc": "${svc.getTranslatedMsg("PAY_NOTIFY", ctx.status?string!"")!"失敗"}",
  "respCode": "0000",
  "respMsg": "Notified"
}