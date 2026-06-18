<#-- 5210_txn_notify.ftl: 代付異步通知解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('transaction_code参数不可为空', ctx.transaction_code)}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.customer_id!svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.transaction_id!''}",
  "chnlTxnStatus": "${ctx.transaction_code!''}",
  "chnlTxnStatusDesc": "${ctx.transaction_msg!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW_NOTIFY', ctx.transaction_code!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW_NOTIFY', ctx.transaction_code!'')!'异常'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
