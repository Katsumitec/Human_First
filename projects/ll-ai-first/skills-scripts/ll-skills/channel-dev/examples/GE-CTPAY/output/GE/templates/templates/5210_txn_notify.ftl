<#-- 5210_txn_notify.ftl: 代付異步通知解析模板（5210） -->
<#-- 代付回調在 completed/failed/refund 時觸發 -->
<#-- 驗簽通過後解析狀態 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
${svc.assertNotEmpty('out_trade_no 為空', ctx.out_trade_no!'')}
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.out_trade_no!''}",
  "chnlTxnId": "${ctx.trade_no!''}",
  "chnlRespCd": "${ctx.state!''}",
  "chnlRespMsg": "${ctx.state!''}",
  "chnlTxnStatus": "${ctx.state!''}",
  "chnlTxnStatusDesc": "${ctx.state!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW_NOTIFY', ctx.state!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW_NOTIFY', ctx.state!'')!'處理中'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
