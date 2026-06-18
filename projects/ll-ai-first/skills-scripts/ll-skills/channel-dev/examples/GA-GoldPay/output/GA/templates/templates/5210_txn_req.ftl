<#-- 5210_txn_req.ftl: 代付請求報文模板 -->
<#setting number_format="0">
{
"merchant_code": "${ctx.merchant_code!''}",
"merchant_order_no": "${ctx.merchant_order_no!''}",
"amount": "${ctx.amount!''}",
"service_type": "${ctx.service_type!''}",
"bank_code": "${ctx.bank_code!''}",
"callback_url": "${ctx.callback_url!''}",
"card_name": "${ctx.card_name!''}",
"card_num": "${ctx.card_num!''}",
"merchant_user": "${ctx.merchant_user!''}",
"mobile_no": "${ctx.mobile_no!''}",
"platform": "${ctx.platform!''}",
"risk_level": "${ctx.risk_level!''}",
"sign": "${ctx.sign!''}"
}