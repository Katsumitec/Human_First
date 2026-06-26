<#-- txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"appId": "${ctx.appId}",
"outTradeNo": "${ctx.outTradeNo}",
"channelId": "110",
"amount": "${ctx.amount}",
"callbackUrl": "${ctx.callbackUrl}",
"successUrl": "${ctx.successUrl}",
"clientUserIp": "${ctx.clientUserIp}",
"clientUserId": "${ctx.clientUserId}",
"sign": "${ctx.sign!''}"
}