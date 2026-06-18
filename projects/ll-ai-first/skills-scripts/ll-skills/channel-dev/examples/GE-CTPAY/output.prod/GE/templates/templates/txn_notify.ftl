<#-- txn_notify.ftl: 代收異步通知解析模板（0121/014d/014e） -->
<#-- 代收回調只通知 completed（成功）訂單 -->
<#-- 驗簽後，金額需校驗（不浮動） -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr('1.0')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat('0.##')} <#-- 金額格式 -->
${svc.setLocalAmtFormat('0')} <#-- 本地金額格式 -->
${svc.assertNotEmpty('out_trade_no 為空', ctx.out_trade_no!'')} <#-- 訂單號非空斷言 -->
${svc.assertEqual('實際支付金額與訂單金額不一致: '+ctx.amount+'!='+svc.toChnlAmt(ctx.txnAmt)?string, ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)} <#-- 不浮動金額校驗 -->
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
  "txnStatus": "${svc.getTranslatedCode('PAY_NOTIFY', ctx.state!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('PAY_NOTIFY', ctx.state!'')!'處理中'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
