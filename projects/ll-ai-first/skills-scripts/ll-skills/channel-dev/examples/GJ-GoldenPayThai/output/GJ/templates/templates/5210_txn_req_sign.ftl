<#-- 5210_txn_req_sign.ftl: 代付請求簽名原文 -->
<#setting number_format="0">
${svc.setCurrencyByCode('764')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.00')}
${svc.setLocalAmtFormat('0')}
{
  "mch_id": "${svc.getChnlMerId()}",
  "trans_id": "${ctx.chnlOrderId}",
  "channel": "${svc.getMerParam('type','bank')}",
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "currency": "${svc.getMerParam('chnl.currency','THB')}",
  "account_no": "${ctx.accNum!''}",
  "account_name": "${ctx.accName!''}",
  "account_org": "${ctx.chnlBankName!ctx.bankName!""}",
  "account_org_code": "${ctx.chnlBankNum!ctx.bankNum!""}",
  "callback_url": "${ctx.chnlNotifyUrl!''}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}