<#-- txnQry_req_sign: 交易查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0">
{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": ${svc.nowSecs()},
"pay_order_id": "${ctx.chnlOrderId}"
}