<#-- txnQry_req.ftl: 代收查詢請求報文模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.merchant_order_no!''}",
"merchant_code": "${ctx.merchant_code!''}",
"sign": "${ctx.sign!''}"
}