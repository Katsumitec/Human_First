<#-- txn_req_sign.ftl: 代收請求簽名原文（0121/013d 共用） -->
<#setting number_format="0">
${svc.setCurrencyByCode('764')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.00')}
${svc.setLocalAmtFormat('0')}
{
  "mch_id": "${svc.getChnlMerId()}",
  "trans_id": "${ctx.chnlOrderId}",
  "currency": "${svc.getMerParam('chnl.currency','THB')}",
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "channel": "${svc.getMerParam('type','bank')}",
  "payer_account_no": "${ctx.accNum!(rand.getInt(1000000000,9999999999)?string)}",
  "payer_account_name": "${ctx.accName!(rand.getEnglishName())}",
  "payer_account_org": "${ctx.chnlBankNum!'KBANK'}",
  "callback_url": "${ctx.chnlNotifyUrl!''}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}