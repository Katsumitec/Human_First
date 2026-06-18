<#-- 5210_txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"out_trade_no": "${ctx.out_trade_no}",
"bank_id": "${ctx.bank_id}",
"bank_owner" : "${ctx.bank_owner}",
"account_number": "${ctx.account_number}",
"amount":  "${ctx.amount}",
"callback_url": "${ctx.callback_url}",
"sign": "${ctx.sign!''}"
}