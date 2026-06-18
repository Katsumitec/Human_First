REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('GJ', '*', '5210_txnQry_req.ftl', '<#-- 5210_txnQry_req.ftl: 代付查詢請求報文（GET） -->
<#setting number_format="0">
{
  "id": "${ctx.id!\'\'}",
  "mch_id": "${ctx.mch_id!\'\'}",
  "nonce": "${ctx.nonce!\'\'}",
  "timestamp": "${ctx.timestamp!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}
', 100, '代付查詢請求報文（GET + Query）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', '5210_txnQry_req_sign.ftl', '<#-- 5210_txnQry_req_sign.ftl: 代付查詢請求簽名原文 -->
<#setting number_format="0">
{
  "id": "${ctx.chnlOrderId}",
  "mch_id": "${svc.getChnlMerId()}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}
', 100, '代付查詢簽名原文', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp.ftl: 代付查询响应 -> 我方格式 -->
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
}', 100, '代付查詢響應解析', '', '2026-04-24 17:42:01', '2026-04-25 12:17:12'),
('GJ', '*', '5210_txnQry_resp_sign.ftl', '', 100, '代付查詢響應驗簽模板（空）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', '5210_txn_notify.ftl', '<#-- 5210_txn_notify.ftl: 代付異步通知解析 → 我方格式 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'764\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.00\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.mch_id!svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.trans_id!ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.id!\'\'}",
  "chnlRespCd": "${ctx.status?string!\'\'}",
  "chnlRespMsg": "status=${ctx.status?string!\'\'}",
  "chnlTxnStatus": "${ctx.status?string!\'\'}",
  "chnlTxnStatusDesc": "status=${ctx.status?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_NOTIFY\',ctx.status?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_NOTIFY\',ctx.status?string!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '代付異步通知解析', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', '5210_txn_notify_sign.ftl', '<#-- 5210_txn_notify_sign.ftl: 代付通知驗簽原文（不含 sign 本身） -->
<#setting number_format="0">
{
  "id": "${ctx.id!\'\'}",
  "mch_id": "${ctx.mch_id!\'\'}",
  "trans_id": "${ctx.trans_id!\'\'}",
  "order_amount": "${ctx.order_amount!\'\'}",
  "created_at": "${ctx.created_at!\'\'}",
  "canceled_at": "${ctx.canceled_at!\'\'}",
  "payed_at": "${ctx.payed_at!\'\'}",
  "status": "${ctx.status?string!\'\'}"
}
', 100, '代付異步通知驗簽原文', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req.ftl: 代付請求報文 -->
<#setting number_format="0">
{
  "mch_id": "${ctx.mch_id!\'\'}",
  "trans_id": "${ctx.trans_id!\'\'}",
  "channel": "${ctx.channel!\'\'}",
  "amount": "${ctx.amount!\'\'}",
  "currency": "${ctx.currency!\'\'}",
  "account_no": "${ctx.account_no!\'\'}",
  "account_name": "${ctx.account_name!\'\'}",
  "account_org": "${ctx.account_org!\'\'}",
  "account_org_code": "${ctx.account_org_code!\'\'}",
  "callback_url": "${ctx.callback_url!\'\'}",
  "nonce": "${ctx.nonce!\'\'}",
  "timestamp": "${ctx.timestamp!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}
', 100, '代付請求報文', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign.ftl: 代付請求簽名原文 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'764\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.00\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "mch_id": "${svc.getChnlMerId()}",
  "trans_id": "${ctx.chnlOrderId}",
  "channel": "${svc.getMerParam(\'type\',\'bank\')}",
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "currency": "${svc.getMerParam(\'chnl.currency\',\'THB\')}",
  "account_no": "${ctx.accNum!\'\'}",
  "account_name": "${ctx.accName!\'\'}",
  "account_org": "${ctx.chnlBankName!ctx.bankName!""}",
  "account_org_code": "${ctx.chnlBankNum!ctx.bankNum!""}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}', 100, '代付請求簽名原文', '', '2026-04-24 17:42:01', '2026-04-25 12:08:14'),
('GJ', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp.ftl: 代付同步响应 -> 我方格式 -->
<#setting number_format="0">
<#if ctx.code?? && ctx.code?string == "200" && ctx.payload??>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.payload.id!\'\'}",
  "chnlRespCd": "${ctx.code?string!\'\'}",
  "chnlRespMsg": "${(ctx.payload.message)!\'OK\'}",
  "chnlTxnStatus": "${ctx.payload.status?string!\'\'}",
  "chnlTxnStatusDesc": "status=${ctx.payload.status?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW\', ctx.code?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW\', ctx.code?string!\'\')!\'提交成功处理中\'}",
  "respCode": "0000",
  "respMsg": "Processed"
}
<#else>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "",
  "chnlRespCd": "${ctx.code?string!\'\'}",
  "chnlRespMsg": "${(ctx.errors.message)!(ctx.payload.message)!\'\'}",
  "chnlTxnStatus": "${ctx.code?string!\'\'}",
  "chnlTxnStatusDesc": "${(ctx.errors.message)!(ctx.payload.message)!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW\', ctx.code?string!\'\')!\'20\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW\', ctx.code?string!\'\')!\'失败\'}",
  "respCode": "0000",
  "respMsg": "Processed"
}
</#if>', 100, '代付同步響應解析', '', '2026-04-24 17:42:01', '2026-04-25 15:20:14'),
('GJ', '*', '5210_txn_sync_resp_sign.ftl', '', 100, '代付同步響應驗簽模板（空）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', 'txnQry_req.ftl', '<#-- txnQry_req.ftl: 代收查詢請求報文（GET 時系統會轉為 Query String） -->
<#setting number_format="0">
{
  "id": "${ctx.id!\'\'}",
  "mch_id": "${ctx.mch_id!\'\'}",
  "nonce": "${ctx.nonce!\'\'}",
  "timestamp": "${ctx.timestamp!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}
', 100, '代收查詢請求報文（GET + Query）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', 'txnQry_req_sign.ftl', '<#-- txnQry_req_sign.ftl: 代收查詢請求簽名原文 -->
<#setting number_format="0">
{
  "id": "${ctx.chnlOrderId}",
  "mch_id": "${svc.getChnlMerId()}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}
', 100, '代收查詢簽名原文', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl: 代收查詢響應解析 → 我方格式 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'764\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.00\')}
${svc.setLocalAmtFormat(\'0\')}
${svc.assertEqual("上游回傳 code != 200：" + ((ctx.errors.message)!""), "200", (ctx.code?string)!"" )}
${svc.assertNotEmpty(\'payload 為空\', ctx.payload)}
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.payload.mch_id!svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.payload.trans_id!ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.payload.id!\'\'}",
  "chnlTxnStatus": "${ctx.payload.status?string!\'\'}",
  "chnlTxnStatusDesc": "status=${ctx.payload.status?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_QRY\',ctx.payload.status?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_QRY\',ctx.payload.status?string!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Queried"
}
', 100, '代收查詢響應解析', '', '2026-04-24 17:42:01', '2026-04-25 11:36:10'),
('GJ', '*', 'txnQry_resp_sign.ftl', '', 100, '代收查詢響應驗簽模板（空）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl: 代收异步通知解析 -> 我方格式 -->
<#setting number_format="0"/>
${svc.setCurrencyByCode("764")}
${svc.setChnlAmtUnitStr("1.0")}
${svc.setChnlAmtFormat("0.00")}
${svc.setLocalAmtFormat("0")}

${svc.assertEqual(
  "實際支付金額與訂單金額不一致：payed=" + ((ctx.payed_amount)!"") + " vs orig=" + (svc.toChnlAmt(ctx.txnAmt)),
  (ctx.payed_amount?number?string["0.00"]),
  (svc.toChnlAmt(ctx.txnAmt)?number?string["0.00"])
)}
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.mch_id!svc.getChnlMerId()!""}",
  "chnlOrderId": "${ctx.trans_id!ctx.chnlOrderId!""}",
  "chnlTxnId": "${ctx.id!""}",
  "chnlRespCd": "${ctx.status?string!""}",
  "chnlRespMsg": "status=${ctx.status?string!""}",
  "chnlTxnStatus": "${ctx.status?string!""}",
  "chnlTxnStatusDesc": "status=${ctx.status?string!""}",
  "txnStatus": "${svc.getTranslatedCode("PAY_NOTIFY", ctx.status?string!"")!"20"}",
  "txnStatusDesc": "${svc.getTranslatedMsg("PAY_NOTIFY", ctx.status?string!"")!"失敗"}",
  "respCode": "0000",
  "respMsg": "Notified"
}', 100, '代收異步通知解析', '', '2026-04-24 17:42:01', '2026-04-25 11:51:43'),
('GJ', '*', 'txn_notify_sign.ftl', '<#-- txn_notify_sign.ftl: 代收通知驗簽原文（不含 sign 本身） -->
<#setting number_format="0">
{
  "id": "${ctx.id!\'\'}",
  "mch_id": "${ctx.mch_id!\'\'}",
  "trans_id": "${ctx.trans_id!\'\'}",
  "channel": "${ctx.channel!\'\'}",
  "order_amount": "${ctx.order_amount!\'\'}",
  "payed_amount": "${ctx.payed_amount!\'\'}",
  "created_at": "${ctx.created_at!\'\'}",
  "payed_at": "${ctx.payed_at!\'\'}",
  "status": "${ctx.status?string!\'\'}"
}
', 100, '代收異步通知驗簽原文', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', 'txn_req.ftl', '<#-- txn_req.ftl: 代收請求報文（從已簽名的 ctx 組裝最終 JSON） -->
<#setting number_format="0">
{
  "mch_id": "${ctx.mch_id!\'\'}",
  "trans_id": "${ctx.trans_id!\'\'}",
  "currency": "${ctx.currency!\'\'}",
  "amount": "${ctx.amount!\'\'}",
  "channel": "${ctx.channel!\'\'}",
  "payer_account_no": "${ctx.payer_account_no!\'\'}",
  "payer_account_name": "${ctx.payer_account_name!\'\'}",
  "payer_account_org": "${ctx.payer_account_org!\'\'}",
  "callback_url": "${ctx.callback_url!\'\'}",
  "nonce": "${ctx.nonce!\'\'}",
  "timestamp": "${ctx.timestamp!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}
', 100, '代收請求報文（0121/013d 共用）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01'),
('GJ', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign.ftl: 代收請求簽名原文（0121/013d 共用） -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'764\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.00\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "mch_id": "${svc.getChnlMerId()}",
  "trans_id": "${ctx.chnlOrderId}",
  "currency": "${svc.getMerParam(\'chnl.currency\',\'THB\')}",
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "channel": "${svc.getMerParam(\'type\',\'bank\')}",
  "payer_account_no": "${ctx.accNum!(rand.getInt(1000000000,9999999999)?string)}",
  "payer_account_name": "${ctx.accName!(rand.getEnglishName())}",
  "payer_account_org": "${ctx.chnlBankNum!\'KBANK\'}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}', 100, '代收請求簽名原文', '', '2026-04-24 17:42:01', '2026-04-25 18:41:51'),
('GJ', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp.ftl: 代收同步响应 -> 我方格式（上游返回 url 供用户跳转） -->
<#setting number_format="0"/>

${svc.assertNotEmpty("payload 为空", ctx.payload)}
${svc.assertEqual("上游返回 code != 200：" + ((ctx.errors.message)!"") + ((ctx.payload.message)!""),
  "200",
  (ctx.code?string)!""
)}

{
  "channel": "${svc.getChannel()!""}",
  "intTxnType": "${svc.getIntTxnType()!""}",
  "chnlMerId": "${svc.getChnlMerId()!""}",
  "chnlOrderId": "${ctx.chnlOrderId!""}",
  "chnlTxnId": "${(ctx.payload.id)!""}",
  "codeImgUrl": "${(ctx.payload.url)!""}",
  "codePageUrl": "${(ctx.payload.url)!""}",
  "chnlTxnStatus": "${(ctx.payload.status?string)!""}",
  "chnlTxnStatusDesc": "status=${(ctx.payload.status?string)!""}",
  "txnStatus": "01",
  "txnStatusDesc": "处理中",
  "respCode": "0000",
  "respMsg": "Processed"
}', 100, '代收同步響應解析', '', '2026-04-24 17:42:01', '2026-04-25 00:17:07'),
('GJ', '*', 'txn_sync_resp_sign.ftl', '', 100, '代收同步響應驗簽模板（空：不以模板驗簽）', '', '2026-04-24 17:42:01', '2026-04-24 17:42:01');
