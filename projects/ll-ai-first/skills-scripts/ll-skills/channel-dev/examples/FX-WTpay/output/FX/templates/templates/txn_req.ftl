<#-- txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"amount":  "${ctx.amount}",
"callback_url": "${ctx.callback_url}",
"out_trade_no": "${ctx.chnlOrderId}"
}