<#-- 5210notify_sign.ftl 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
{
    "appId":"${ctx.appId!''}",
    "orderNo":"${ctx.orderNo!''}",
    "outOrderNo":"${ctx.outOrderNo!''}",
    "currency":"${ctx.currency!''}",
    "amount":"${ctx.amount!''}",
    "orderStatus":"${ctx.orderStatus!''}",
    "message":"${ctx.message!''}"
}