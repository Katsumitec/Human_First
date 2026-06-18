<#-- 5210_txn_req.ftl: 代付請求報文 -->
<#setting number_format="0">
{
  "mch_id": "${ctx.mch_id!''}",
  "trans_id": "${ctx.trans_id!''}",
  "channel": "${ctx.channel!''}",
  "amount": "${ctx.amount!''}",
  "currency": "${ctx.currency!''}",
  "account_no": "${ctx.account_no!''}",
  "account_name": "${ctx.account_name!''}",
  "account_org": "${ctx.account_org!''}",
  "account_org_code": "${ctx.account_org_code!''}",
  "callback_url": "${ctx.callback_url!''}",
  "nonce": "${ctx.nonce!''}",
  "timestamp": "${ctx.timestamp!''}",
  "sign": "${ctx.sign!''}"
}
