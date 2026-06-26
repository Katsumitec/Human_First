<#-- 5210_txnQry_req: 代付查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
{
"appId": "${svc.getChnlMerId()}",
"outOrderNo": "${ctx.chnlOrderId}",
"sign": "${ctx.sign}",
}