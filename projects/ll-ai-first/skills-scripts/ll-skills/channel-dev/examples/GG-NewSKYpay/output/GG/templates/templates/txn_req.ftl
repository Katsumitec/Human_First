<#-- txn_req.ftl: 代收下單請求報文模板（GG NewSKYPay）-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!''},
  "merchantOrderId": "${ctx.merchantOrderId!''}",
  "payAmount": ${ctx.payAmount!''},
  "payType": 1060,
  "userId": "${rand.getInt(1000, 9999)}",
  "notifyUrl": "${ctx.chnlNotifyUrl!''}",
  "sign": "${ctx.sign!''}"
}