<#-- 5210_txnQry_req.ftl: 代付查詢請求報文模板 -->
<#setting number_format="0">
{
"pay_customer_id": ${ctx.pay_customer_id},
"pay_apply_date": ${ctx.pay_apply_date},
"pay_order_id": "${ctx.pay_order_id!''}",
"pay_md5_sign": "${ctx.sign!''}"
}
