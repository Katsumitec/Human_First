<#-- txn_notify_sign.ftl: 代收回調驗簽模板（GG NewSKYPay）
     簽名欄位（固定順序，按文件示例）: merchantId → merchantOrderId → payOrderId → payAmount → paidAmount（成功時）
     不參與簽名: remark, orderStatus, bankAccount, sign
     paidAmount 僅在 orderStatus == 3（支付成功）時參與簽名
-->
<#setting number_format="0">
{
"merchantId": "${ctx.merchantId!''}",
"merchantOrderId": "${ctx.merchantOrderId!''}",
"payOrderId": "${ctx.payOrderId!''}",
"payAmount": "${ctx.payAmount!''}"<#if ctx.orderStatus?? && ctx.orderStatus?string == "3">,
"paidAmount": "${ctx.paidAmount!''}"</#if>
}