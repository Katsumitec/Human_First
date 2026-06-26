<#-- 5210_txn_req.ftl: 代付下單請求報文模板（GG NewSKYPay）
     簽名欄位: merchantId, merchantOrderId, payAmount, bankNum, bankAccount
     非簽名欄位: bankType, payType, commonType, withdrawQueryUrl, notifyUrl
-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!''},
  "merchantOrderId": "${ctx.merchantOrderId!''}",
  "payAmount": ${ctx.payAmount!''},
  "bankNum": "${ctx.bankNum!''}",
  "bankAccount": "${ctx.bankAccount!''}",
  "bankType": "${ctx.chnlBankNum!''}",
  "payType": 1060,
  "commonType": "vnd",
  "withdrawQueryUrl": "${svc.getMerParam('withdrawQueryUrl', '')}",
  "notifyUrl": "${ctx.chnlNotifyUrl!''}",
  "sign": "${ctx.sign!''}"
}