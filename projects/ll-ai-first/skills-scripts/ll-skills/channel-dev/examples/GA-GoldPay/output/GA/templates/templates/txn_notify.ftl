<#-- txn_notify.ftl: 代收異步通知解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('status参数不可为空', ctx.status)}
${svc.assertEqual('实际支付金额与原订单金额不一致: '+(ctx.amount?string!'0')+' != '+(svc.toChnlAmt(ctx.txnAmt)), ctx.amount?string!'0', svc.toChnlAmt(ctx.txnAmt))}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.trans_id!''}",
  "chnlTxnStatus": "${ctx.status!''}",
  "chnlTxnStatusDesc": "${ctx.error_code!''}",
  "txnStatus": "${svc.getTranslatedCode('PAY_NOTIFY', ctx.status?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('PAY_NOTIFY', ctx.status?string!'')!'异常'}",
  "respCode": "0000",
  "respMsg": "Notified"
}