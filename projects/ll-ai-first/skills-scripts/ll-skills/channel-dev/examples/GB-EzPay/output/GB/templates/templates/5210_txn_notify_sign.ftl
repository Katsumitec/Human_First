<#-- 5210_txn_notify_sign.ftl: 代付異步通知驗簽模板 -->
<#setting number_format="0">
{
    "customer_id": "${ctx.customer_id}",
    "order_id": "${ctx.order_id!''}",
    "amount": "${ctx.amount!''}",
    "datetime": "${ctx.datetime!''}",
    "transaction_id": "${ctx.transaction_id!''}",
    "transaction_code": "${ctx.transaction_code!''}",
    "transaction_msg": "${ctx.transaction_msg!''}"
}
