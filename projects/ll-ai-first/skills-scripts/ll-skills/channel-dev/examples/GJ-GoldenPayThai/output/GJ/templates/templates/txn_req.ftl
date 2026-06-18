<#-- txn_req.ftl: 代收請求報文（從已簽名的 ctx 組裝最終 JSON） -->
<#setting number_format="0">
{
  "mch_id": "${ctx.mch_id!''}",
  "trans_id": "${ctx.trans_id!''}",
  "currency": "${ctx.currency!''}",
  "amount": "${ctx.amount!''}",
  "channel": "${ctx.channel!''}",
  "payer_account_no": "${ctx.payer_account_no!''}",
  "payer_account_name": "${ctx.payer_account_name!''}",
  "payer_account_org": "${ctx.payer_account_org!''}",
  "callback_url": "${ctx.callback_url!''}",
  "nonce": "${ctx.nonce!''}",
  "timestamp": "${ctx.timestamp!''}",
  "sign": "${ctx.sign!''}"
}
