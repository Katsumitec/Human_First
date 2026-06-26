<#-- 5210_txn_req_sign.ftl: 代付下單請求簽名模板（GG NewSKYPay）
     簽名欄位固定順序（非字母序）: merchantId → merchantOrderId → payAmount → bankNum → bankAccount
     ext_config: sortMessageForSign=false
-->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}",
"bankNum": "${ctx.accNum!''}",
"bankAccount": "${ctx.accName!''}"
}