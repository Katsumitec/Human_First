<#-- txnQry_req: 代付查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0">
{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": ${ctx.pay_apply_date},
"pay_order_id": "${ctx.pay_order_id}",
"pay_md5_sign": "${ctx.sign!''}"
}

