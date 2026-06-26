<#-- txn_req.ftl: 代收請求報文模板（0121 純卡網關） -->
<#-- 返回 data.qrcode 供自製收銀台展示 QR Code -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat('0.##')} <#-- 金額格式：不補零 -->
${svc.setLocalAmtFormat('0')} <#-- 本地金額格式 -->
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "callback_url": "${ctx.chnlNotifyUrl!''}",
  "out_trade_no": "${ctx.chnlOrderId!''}"
}