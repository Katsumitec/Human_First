<#-- 5210_txn_notify_sign.ftl: 代付回調驗簽模板（GG NewSKYPay）
     簽名欄位固定順序: merchantId → merchantOrderId → payOrderId → payAmount → paidAmount（成功時）→ bankNum → bankAccount
     paidAmount 僅在 orderStatus == 3（支付成功）時參與簽名
     因 5210 ext_config sortMessageForSign=false，欄位順序由模板決定。
-->
<#setting number_format="0">
{
"merchantId": "${ctx.merchantId!''}",
"merchantOrderId": "${ctx.merchantOrderId!''}",
"payOrderId": "${ctx.payOrderId!''}",
"payAmount": "${ctx.payAmount!''}",
<#if ctx.orderStatus?? && ctx.orderStatus?string == "3">
"paidAmount": "${ctx.paidAmount!''}",
</#if>
"bankNum": "${ctx.bankNum!''}",
"bankAccount": "${ctx.bankAccount!''}"
}