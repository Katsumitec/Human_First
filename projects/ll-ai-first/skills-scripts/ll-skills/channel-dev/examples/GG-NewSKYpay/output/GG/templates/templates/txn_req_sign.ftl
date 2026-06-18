<#-- txn_req_sign.ftl: 代收下單請求簽名模板（GG NewSKYPay）
     簽名欄位順序（字母序）: merchantId → merchantOrderId → payAmount
     簽名格式: merchantId=XXX&merchantOrderId=XXX&payAmount=XXX&key={商戶金鑰}
-->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}"
}