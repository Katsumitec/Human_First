<#-- 5210_txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"appId": "${ctx.appId}",
"outOrderNo": "${ctx.outOrderNo}",
"amount": "${ctx.amount}",
"bankName": "${ctx.bankName}",
"bankUserName": "${ctx.bankUserName}",
"bankCard": "${ctx.bankCard}",
"currency": "${ctx.currency}",
"callbackUrl": "${ctx.chnlNotifyUrl!''}",
"sign": "${ctx.sign}"
}