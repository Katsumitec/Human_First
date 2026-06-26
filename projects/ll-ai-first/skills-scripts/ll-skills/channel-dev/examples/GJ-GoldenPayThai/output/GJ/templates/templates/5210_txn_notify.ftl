<#-- 5210_txn_notify.ftl: 代付異步通知解析 → 我方格式 -->
<#setting number_format="0">
${svc.setCurrencyByCode('764')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.00')}
${svc.setLocalAmtFormat('0')}
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.mch_id!svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.trans_id!ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.id!''}",
  "chnlRespCd": "${ctx.status?string!''}",
  "chnlRespMsg": "status=${ctx.status?string!''}",
  "chnlTxnStatus": "${ctx.status?string!''}",
  "chnlTxnStatusDesc": "status=${ctx.status?string!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW_NOTIFY',ctx.status?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW_NOTIFY',ctx.status?string!'')!'處理中'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
