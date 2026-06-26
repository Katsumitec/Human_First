<#-- 5210_txn_notify.ftl: 代付異步通知解析模板（GG NewSKYPay）
     回調字段: merchantId, merchantOrderId, payOrderId, payAmount, paidAmount, bankNum, bankAccount, orderStatus, remark, sign
     orderStatus: 3=成功(10), 8=失敗(20), 其他=處理中(01)
-->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

<#if ctx.orderStatus?? && ctx.orderStatus?string == "3">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.payOrderId!''}",
  "chnlRespCd": "${ctx.orderStatus?string!''}",
  "chnlRespMsg": "success",
  "chnlTxnStatus": "${ctx.orderStatus?string!''}",
  "chnlTxnStatusDesc": "paid",
  "txnStatus": "10",
  "txnStatusDesc": "Success",
  "respCode": "0000",
  "respMsg": "Notified"
}
<#elseif ctx.orderStatus?? && ctx.orderStatus?string == "8">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.payOrderId!''}",
  "chnlRespCd": "${ctx.orderStatus?string!''}",
  "chnlRespMsg": "${ctx.remark!'failed'}",
  "chnlTxnStatus": "${ctx.orderStatus?string!''}",
  "chnlTxnStatusDesc": "${ctx.remark!'failed'}",
  "txnStatus": "20",
  "txnStatusDesc": "${ctx.remark!'Failed'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.payOrderId!''}",
  "chnlRespCd": "${ctx.orderStatus?string!''}",
  "chnlRespMsg": "${ctx.remark!'processing'}",
  "chnlTxnStatus": "${ctx.orderStatus?string!''}",
  "chnlTxnStatusDesc": "processing",
  "txnStatus": "01",
  "txnStatusDesc": "Processing",
  "respCode": "0000",
  "respMsg": "Notified"
}
</#if>