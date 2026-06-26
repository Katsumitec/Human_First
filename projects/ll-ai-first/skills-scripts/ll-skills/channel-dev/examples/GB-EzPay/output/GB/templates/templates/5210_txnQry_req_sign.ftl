<#-- 5210_txnQry_req_sign.ftl: 代付查詢請求簽名模板 -->
<#setting number_format="0">
{
"pay_customer_id": "${svc.getChnlMerId()}",
"pay_apply_date": "${svc.nowSecs()}",
"pay_order_id": "${ctx.chnlOrderId}"
}
