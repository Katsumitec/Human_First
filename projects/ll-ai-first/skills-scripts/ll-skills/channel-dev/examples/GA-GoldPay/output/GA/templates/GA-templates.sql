REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('GA', '*', '5210_txnQry_req.ftl', '<#-- 5210_txnQry_req.ftl: 代付查詢請求報文模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.merchant_order_no!\'\'}",
"merchant_code": "${ctx.merchant_code!\'\'}",
"sign": "${ctx.sign!\'\'}"
}', 100, '代付查询请求报文模板', '', '2026-03-10 14:21:51', '2026-03-10 14:21:51'),
('GA', '*', '5210_txnQry_req_sign.ftl', '<#-- 5210_txnQry_req_sign.ftl: 代付查詢請求簽名模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.chnlOrderId}",
"merchant_code": "${svc.getChnlMerId()}"
}', 100, '代付查询请求签名模板', '', '2026-03-10 14:09:42', '2026-03-10 14:09:42'),
('GA', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp.ftl: 代付查詢響應解析模板 -->
<#setting number_format="0">

<#if (ctx.status?string) == "1">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.trans_id!\'\'}",
  "chnlTxnStatus": "${ctx.trans_status!\'\'}",
  "chnlTxnStatusDesc": "${ctx.trans_status!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_QRY\', ctx.trans_status!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_QRY\', ctx.trans_status!\'\')!\'处理中\'}",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.error_code!\'\'}",
  "chnlTxnStatusDesc": "${ctx.error_msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "查询失败，保留处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>', 100, '代付查询响应解析模板', '', '2026-03-10 14:22:01', '2026-03-10 14:22:01'),
('GA', '*', '5210_txnQry_resp_sign.ftl', '
', 100, '代付查询响应验签模板（空）', '', '2026-03-10 14:22:08', '2026-03-10 14:22:08'),
('GA', '*', '5210_txn_notify.ftl', '<#-- 5210_txn_notify.ftl: 代付異步通知解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'status参数不可为空\', ctx.status)}
<#-- 代付实际金额可能与请求金额不一致，不校验金额 -->

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.trans_id!\'\'}",
  "chnlTxnStatus": "${ctx.status!\'\'}",
  "chnlTxnStatusDesc": "${ctx.error_code!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_NOTIFY\', ctx.status?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_NOTIFY\', ctx.status?string!\'\')!\'异常\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}', 100, '代付异步通知解析模板', '', '2026-03-10 14:19:56', '2026-03-10 14:19:56'),
('GA', '*', '5210_txn_notify_sign.ftl', '<#-- 5210_txn_notify_sign.ftl: 代付異步通知驗簽模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.merchant_order_no!\'\'}",
"amount": "${ctx.amount!\'\'}",
"trans_id": "${ctx.trans_id!\'\'}",
"status": "${ctx.status!\'\'}",
"process_time": "${ctx.process_time!\'\'}",
"error_code": "${ctx.error_code!\'\'}"
}', 100, '代付异步通知验签模板', '', '2026-03-10 14:20:16', '2026-03-10 14:20:16'),
('GA', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req.ftl: 代付請求報文模板 -->
<#setting number_format="0">
{
"merchant_code": "${ctx.merchant_code!\'\'}",
"merchant_order_no": "${ctx.merchant_order_no!\'\'}",
"amount": "${ctx.amount!\'\'}",
"service_type": "${ctx.service_type!\'\'}",
"bank_code": "${ctx.bank_code!\'\'}",
"callback_url": "${ctx.callback_url!\'\'}",
"card_name": "${ctx.card_name!\'\'}",
"card_num": "${ctx.card_num!\'\'}",
"merchant_user": "${ctx.merchant_user!\'\'}",
"mobile_no": "${ctx.mobile_no!\'\'}",
"platform": "${ctx.platform!\'\'}",
"risk_level": "${ctx.risk_level!\'\'}",
"sign": "${ctx.sign!\'\'}"
}', 100, '代付请求报文模板', '', '2026-03-10 14:19:07', '2026-03-10 14:19:07'),
('GA', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign.ftl: 代付請求報文簽名模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}
{
"merchant_code": "${svc.getChnlMerId()}",
"merchant_order_no": "${ctx.chnlOrderId}",
"amount": "${svc.toChnlAmt(ctx.txnAmt)}",
"service_type": "${svc.getMerParam(\'type\', \'700\')}",
"bank_code": "${ctx.chnlBankNum!\'\'}",
"callback_url": "${ctx.chnlNotifyUrl!\'\'}",
"card_name": "${ctx.accName!\'\'}",
"card_num": "${ctx.accNum!\'\'}",
"merchant_user": "${ctx.accName!\'\'}",
"mobile_no": "${ctx.accNum!\'\'}",
"platform": "PC",
"risk_level": "1"
}', 100, '代付请求签名模板', '', '2026-03-10 14:09:42', '2026-03-10 19:19:46'),
('GA', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp.ftl: 代付同步響應模板 -->
<#setting number_format="0">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.trans_id!\'\'}",
  "chnlTxnStatus": "${ctx.status!\'\'}",
  "chnlTxnStatusDesc": "${ctx.error_msg!\'\'}",
  <#assign statusCode = "${ctx.status!\'\'}${ctx.error_code!\'\'}" />
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW\', statusCode)!\'20\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW\', statusCode)!\'失败\'}",
  "respCode": "0000",
  "respMsg": "OK"
}', 100, '代付同步响应模板', '', '2026-03-10 14:19:22', '2026-03-10 21:50:12'),
('GA', '*', '5210_txn_sync_resp_sign.ftl', '
', 100, '代付同步响应验签模板（空）', '', '2026-03-10 14:19:56', '2026-03-10 14:19:56'),
('GA', '*', 'txnQry_req.ftl', '<#-- txnQry_req.ftl: 代收查詢請求報文模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.merchant_order_no!\'\'}",
"merchant_code": "${ctx.merchant_code!\'\'}",
"sign": "${ctx.sign!\'\'}"
}', 100, '代收查询请求报文模板', '', '2026-03-10 14:11:49', '2026-03-10 14:11:49'),
('GA', '*', 'txnQry_req_sign.ftl', '<#-- txnQry_req_sign.ftl: 代收查詢請求簽名模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.chnlOrderId}",
"merchant_code": "${svc.getChnlMerId()}"
}', 100, '代收查询请求签名模板', '', '2026-03-10 14:09:42', '2026-03-10 14:09:42'),
('GA', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl: 代收查詢響應解析模板 -->
<#setting number_format="0">

<#if (ctx.status?string) == "1">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.trans_id!\'\'}",
  "chnlTxnStatus": "${ctx.trans_status!\'\'}",
  "chnlTxnStatusDesc": "${ctx.trans_status!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_QRY\', ctx.trans_status!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_QRY\', ctx.trans_status!\'\')!\'处理中\'}",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.error_code!\'\'}",
  "chnlTxnStatusDesc": "${ctx.error_msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "查询失败，保留处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>', 100, '代收查询响应解析模板', '', '2026-03-10 14:12:14', '2026-03-10 14:12:14'),
('GA', '*', 'txnQry_resp_sign.ftl', '
', 100, '代收查询响应验签模板（空）', '', '2026-03-10 14:12:14', '2026-03-10 14:12:14'),
('GA', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl: 代收異步通知解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'status参数不可为空\', ctx.status)}
${svc.assertEqual(\'实际支付金额与原订单金额不一致: \'+(ctx.amount?string!\'0\')+\' != \'+(svc.toChnlAmt(ctx.txnAmt)), ctx.amount?string!\'0\', svc.toChnlAmt(ctx.txnAmt))}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.trans_id!\'\'}",
  "chnlTxnStatus": "${ctx.status!\'\'}",
  "chnlTxnStatusDesc": "${ctx.error_code!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_NOTIFY\', ctx.status?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_NOTIFY\', ctx.status?string!\'\')!\'异常\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}', 100, '代收异步通知解析模板', '', '2026-03-10 14:09:42', '2026-03-10 14:09:42'),
('GA', '*', 'txn_notify_sign.ftl', '<#-- txn_notify_sign.ftl: 代收異步通知驗簽模板 -->
<#setting number_format="0">
{
"merchant_order_no": "${ctx.merchant_order_no!\'\'}",
"amount": "${ctx.amount!\'\'}",
"trans_id": "${ctx.trans_id!\'\'}",
"status": "${ctx.status!\'\'}",
"deposit_time": "${ctx.deposit_time!\'\'}",
"process_time": "${ctx.process_time!\'\'}",
"error_code": "${ctx.error_code!\'\'}"
}', 100, '代收异步通知验签模板', '', '2026-03-10 14:10:25', '2026-03-10 14:10:25'),
('GA', '*', 'txn_req.ftl', '<#-- txn_req.ftl: 代收請求報文模板 -->
<#setting number_format="0">
{
"merchant_code": "${ctx.merchant_code!\'\'}",
"merchant_order_no": "${ctx.merchant_order_no!\'\'}",
"amount": "${ctx.amount!\'\'}",
"service_type": "${ctx.service_type!\'\'}",
"callback_url": "${ctx.callback_url!\'\'}",
"hashed_mem_id": "${ctx.hashed_mem_id!\'\'}",
"platform": "${ctx.platform!\'\'}",
"risk_level": "${ctx.risk_level!\'\'}",
"sign": "${ctx.sign!\'\'}"
}', 100, '代收请求报文模板', '', '2026-03-10 14:08:11', '2026-03-10 14:08:11'),
('GA', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign.ftl: 代收請求報文簽名模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}
{
"merchant_code": "${svc.getChnlMerId()}",
"merchant_order_no": "${ctx.chnlOrderId}",
"amount": "${svc.toChnlAmt(ctx.txnAmt)}",
"service_type": "${svc.getMerParam(\'type\', \'\')}",
"callback_url": "${ctx.chnlNotifyUrl!\'\'}",
"hashed_mem_id": "${ctx.chnlOrderId}",
"platform": "PC",
"risk_level": 1
}', 100, '代收查询请求签名模板', '', '2026-03-10 14:08:11', '2026-03-10 16:16:44'),
('GA', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp.ftl: 代收同步響應模板（跳轉上游收銀台） -->
<#setting number_format="0">

<#if (ctx.status?string) == "1">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.trans_id!\'\'}",
  "codeImgUrl": "${ctx.transaction_url!\'\'}",
  "codePageUrl": "${ctx.transaction_url!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "In processing",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "txnStatus": "20",
  "txnStatusDesc": "${ctx.error_msg!\'\'}",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>', 100, '代收同步响应模板', '', '2026-03-10 14:08:56', '2026-03-10 14:08:56'),
('GA', '*', 'txn_sync_resp_sign.ftl', '
', 100, '代收同步响应验签模板（空）', '', '2026-03-10 14:09:42', '2026-03-10 14:09:42');
