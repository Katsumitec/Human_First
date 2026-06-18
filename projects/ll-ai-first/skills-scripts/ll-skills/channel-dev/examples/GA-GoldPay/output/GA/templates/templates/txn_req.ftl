<#-- txn_req.ftl: 代收請求報文模板 -->
<#setting number_format="0">
{
"merchant_code": "${ctx.merchant_code!''}",
"merchant_order_no": "${ctx.merchant_order_no!''}",
"amount": "${ctx.amount!''}",
"service_type": "${ctx.service_type!''}",
"callback_url": "${ctx.callback_url!''}",
"hashed_mem_id": "${ctx.hashed_mem_id!''}",
"platform": "${ctx.platform!''}",
"risk_level": "${ctx.risk_level!''}",
"sign": "${ctx.sign!''}"
}