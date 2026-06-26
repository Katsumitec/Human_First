<#-- txnQry_req_sign.ftl: 代收查詢請求簽名模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.chnlOrderId}",
"merchant_code": "${svc.getChnlMerId()}"
}