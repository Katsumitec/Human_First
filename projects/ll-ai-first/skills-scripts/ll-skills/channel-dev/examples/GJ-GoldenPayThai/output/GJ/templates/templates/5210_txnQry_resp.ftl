<#-- 5210_txnQry_resp.ftl: 代付查询响应 -> 我方格式 -->
<#setting number_format="0"/>
${svc.setCurrencyByCode("764")}
${svc.setChnlAmtUnitStr("1.0")}
${svc.setChnlAmtFormat("0.00")}
${svc.setLocalAmtFormat("0")}
${svc.assertEqual("上游回傳 code != 200：" + ((ctx.errors.message)!""), "200", (ctx.code?string)!"" )}
${svc.assertNotEmpty("payload 為空", ctx.payload)}
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.payload.mch_id!svc.getChnlMerId()!""}",
  "chnlOrderId": "${ctx.payload.trans_id!ctx.chnlOrderId!""}",
  "chnlTxnId": "${ctx.payload.id!""}",
  "chnlTxnStatus": "${ctx.payload.status?string!""}",
  "chnlTxnStatusDesc": "status=${ctx.payload.status?string!""}",
  "txnStatus": "${svc.getTranslatedCode("WITHDRAW_QRY", ctx.payload.status?string!"")!"01"}",
  "txnStatusDesc": "${svc.getTranslatedMsg("WITHDRAW_QRY", ctx.payload.status?string!"")!"處理中"}",
  "respCode": "0000",
  "respMsg": "Queried"
}