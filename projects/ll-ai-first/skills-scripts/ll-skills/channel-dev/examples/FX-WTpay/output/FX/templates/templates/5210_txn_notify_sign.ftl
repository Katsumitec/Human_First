<#-- 5210notify_sign.ftl 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0">
{
    "trade_no":"${ctx.trade_no!''}",
    "amount":"${ctx.amount!''}",
    "out_trade_no":"${ctx.out_trade_no!''}",
    "state":"${ctx.state!''}"
}