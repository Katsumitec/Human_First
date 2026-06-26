<#-- notify_sign.ftl -->
<#setting number_format="0">
{
    "customer_id":"${ctx.customer_id!''}",
    "order_id":"${ctx.order_id!''}",
    "transaction_id":"${ctx.transaction_id!''}",
    "order_amount":"${ctx.order_amount!''}",
    "real_amount":"${ctx.real_amount!''}",
    "status":"${ctx.status!''}",
    "message":"${ctx.message!''}"
 
}
