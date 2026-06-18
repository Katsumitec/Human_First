<#-- 5210_txn_notify.ftl: 代付異步通知解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('status参数不可为空', ctx.status)}
<#-- 代付实际金额可能与请求金额不一致，不校验金额 -->

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.trans_id!''}",
  "chnlTxnStatus": "${ctx.status!''}",
  "chnlTxnStatusDesc": "${ctx.error_code!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW_NOTIFY', ctx.status?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW_NOTIFY', ctx.status?string!'')!'异常'}",
  "respCode": "0000",
  "respMsg": "Notified"
}