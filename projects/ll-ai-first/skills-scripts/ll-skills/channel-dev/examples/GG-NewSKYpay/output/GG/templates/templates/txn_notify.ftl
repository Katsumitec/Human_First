<#-- txn_notify.ftl: 代收異步通知解析模板（GG NewSKYPay）
     回調字段: payOrderId, payAmount, merchantId, sign, orderStatus, remark, merchantOrderId, paidAmount
     orderStatus: 3=成功；remark: 狀態說明文字
     不浮動金額: 要求 paidAmount 等於下單 payAmount
-->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('paidAmount 不可為空', ctx.paidAmount)}
${svc.assertEqual('實際收款金額與訂單金額不一致: ' + (ctx.paidAmount?string!'0') + ' != ' + (svc.toChnlAmt(ctx.txnAmt)), ctx.paidAmount?string!'0', svc.toChnlAmt(ctx.txnAmt))}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.merchantOrderId!''}",
  "chnlRespCd": "${ctx.orderStatus?string!''}",
  "chnlRespMsg": "${ctx.remark!''}",
  "chnlTxnStatus": "${ctx.orderStatus?string!''}",
  "chnlTxnStatusDesc": "${ctx.remark!''}",
  "txnStatus": "10",
  "txnStatusDesc": "Success",
  "respCode": "0000",
  "respMsg": "Notified"
}