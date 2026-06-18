<#-- txn_notify_sign.ftl: 代收通知驗簽原文（不含 sign 本身） -->
<#setting number_format="0">
{
  "id": "${ctx.id!''}",
  "mch_id": "${ctx.mch_id!''}",
  "trans_id": "${ctx.trans_id!''}",
  "channel": "${ctx.channel!''}",
  "order_amount": "${ctx.order_amount!''}",
  "payed_amount": "${ctx.payed_amount!''}",
  "created_at": "${ctx.created_at!''}",
  "payed_at": "${ctx.payed_at!''}",
  "status": "${ctx.status?string!''}"
}
