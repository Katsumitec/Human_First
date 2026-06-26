<#-- 014e_txn_req_sign.ftl: 代收請求簽名模板（014e 網銀掃碼） -->
<#-- bank 選填，若商戶參數 bank_id 為空則 removeEmptyForSign=true 會自動排除 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "bank": "${svc.getMerParam('bank_id', '')}",
  "callback_url": "${ctx.chnlNotifyUrl!''}",
  "out_trade_no": "${ctx.chnlOrderId!''}"
}
