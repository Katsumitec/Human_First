<#-- 5210_txnQry_resp.ftl: 代付查詢響應解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0')}
${svc.setLocalAmtFormat('0')}

${svc.assertNotEmpty('data参数不可为空', ctx.data)}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.data.member_id!svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.data.payment_id!''}",
  "chnlTxnStatus": "${ctx.data.status!''}",
  "chnlTxnStatusDesc": "${ctx.data.status_name!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW_QRY', ctx.data.status?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW_QRY', ctx.data.status?string!'')!'异常'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
