<#-- 014d_txn_req.ftl: 代收請求報文模板（014d 銀行直連） -->
<#-- bank 字段（非 bank_id），為銀行直連的必填字段 -->
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