<#-- 5210_txn_notify_sign.ftl: 代付異步通知驗簽模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.merchant_order_no!''}",
"amount": "${ctx.amount!''}",
"trans_id": "${ctx.trans_id!''}",
"status": "${ctx.status!''}",
"process_time": "${ctx.process_time!''}",
"error_code": "${ctx.error_code!''}"
}