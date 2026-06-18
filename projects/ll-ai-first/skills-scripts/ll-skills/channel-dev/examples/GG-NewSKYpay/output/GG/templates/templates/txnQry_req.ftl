<#-- txnQry_req.ftl: 代收查詢請求報文模板（GG NewSKYPay）-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!''},
  "merchantOrderId": "${ctx.merchantOrderId!''}",
  "payAmount": ${ctx.payAmount!''},
  "sign": "${ctx.sign!''}"
}