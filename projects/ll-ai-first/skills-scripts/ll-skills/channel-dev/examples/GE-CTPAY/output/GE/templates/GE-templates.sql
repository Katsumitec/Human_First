REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('GE', '*', '014d_txnQry_req.ftl', '<#-- 014d_txnQry_req.ftl: 代收查詢請求模板（014d，共用 0010 查詢端點） -->
<#-- GET 請求無 body，訂單號由 URL 路徑參數傳遞 -->
', 100, '014d 銀行直連 代收查詢請求（空文件，GET）', '', '2026-03-23 13:47:44', '2026-03-23 13:47:44'),
('GE', '*', '014d_txnQry_req_header.ftl', '<#-- 014d_txnQry_req_header.ftl: 代收查詢 Header 模板（014d） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '014d 銀行直連 代收查詢 Header', '', '2026-03-23 13:47:44', '2026-03-23 19:58:34'),
('GE', '*', '014d_txnQry_req_sign.ftl', '
', 100, '014d 銀行直連 代收查詢簽名（空文件）', '', '2026-03-23 13:47:44', '2026-03-23 13:47:44'),
('GE', '*', '014d_txnQry_resp.ftl', '<#-- 014d_txnQry_resp.ftl: 代收查詢響應解析模板（014d） -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.data.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "chnlTxnAmt": "${svc.fromChnlAmt((ctx.data.amount!0)?string)?string}",
  "chnlTxnStatus": "${ctx.data.state?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.state?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_QRY\', ctx.data.state?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_QRY\', ctx.data.state?string!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Queried"
}', 100, '014d 銀行直連 代收查詢響應解析', '', '2026-03-23 13:49:24', '2026-03-23 20:15:26'),
('GE', '*', '014d_txnQry_resp_sign.ftl', '
', 100, '014d 銀行直連 代收查詢響應驗簽（空文件）', '', '2026-03-23 13:49:41', '2026-03-23 13:49:41'),
('GE', '*', '014d_txn_notify.ftl', '<#-- 014d_txn_notify.ftl: 代收異步通知解析模板（014d 銀行直連） -->
<#-- 與 txn_notify.ftl 邏輯相同，通知只含 completed 狀態 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
${svc.assertNotEmpty(\'out_trade_no 為空\', ctx.out_trade_no!\'\')}
${svc.assertEqual(\'實際支付金額與訂單金額不一致: \'+ctx.amount+\'!=\'+svc.toChnlAmt(ctx.txnAmt)?string, ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.trade_no!\'\'}",
  "chnlRespCd": "${ctx.state!\'\'}",
  "chnlRespMsg": "${ctx.state!\'\'}",
  "chnlTxnStatus": "${ctx.state!\'\'}",
  "chnlTxnStatusDesc": "${ctx.state!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_NOTIFY\', ctx.state!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_NOTIFY\', ctx.state!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '014d 銀行直連 代收異步通知解析', '', '2026-03-23 13:49:58', '2026-03-23 13:49:58'),
('GE', '*', '014d_txn_notify_sign.ftl', '<#-- 014d_txn_notify_sign.ftl: 代收異步通知驗簽模板（014d 銀行直連） -->
<#-- 驗簽欄位與 txn_notify_sign.ftl 相同：4 個固定欄位 -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!\'\'}",
  "out_trade_no": "${ctx.out_trade_no!\'\'}",
  "state": "${ctx.state!\'\'}",
  "trade_no": "${ctx.trade_no!\'\'}"
}
', 100, '014d 銀行直連 代收異步通知驗簽（4欄位）', '', '2026-03-23 13:50:14', '2026-03-23 17:55:05'),
('GE', '*', '014d_txn_req.ftl', '<#-- 014d_txn_req.ftl: 代收請求報文模板（014d 銀行直連） -->
<#-- bank 字段（非 bank_id），為銀行直連的必填字段 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 金額格式：不補零 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 本地金額格式 -->
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}', 100, '014d 銀行直連 代收請求報文（0121）', '', '2026-03-23 13:58:11', '2026-03-23 19:43:28'),
('GE', '*', '014d_txn_req_header.ftl', '<#-- 014d_txn_req_header.ftl: 代收請求 Header 模板（014d 銀行直連） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '014d 銀行直連 代收請求 Header（Bearer Token）', '', '2026-03-23 13:58:28', '2026-03-23 19:49:18'),
('GE', '*', '014d_txn_req_sign.ftl', '<#-- 014d_txn_req_sign.ftl: 代收請求簽名模板（014d 銀行直連） -->
<#-- bank 為必填，從商戶參數 bank_id 取值 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}
', 100, '014d 銀行直連 代收請求簽名（0121）', '', '2026-03-23 13:58:41', '2026-03-23 17:55:05'),
('GE', '*', '014d_txn_sync_resp.ftl', '<#-- 014d_txn_sync_resp.ftl: 代收同步響應解析模板（014d 銀行直連） -->
<#-- 透過 getCasherUrl 傳遞 data.qrcode 給自製收銀台 -->
<#setting number_format="0">
<#assign casherUrl>${svc.getCasherUrl(ctx, \'ch_qrCodeUrl\', ctx.data.qrcode!\'\')}</#assign>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "codeImgUrl": "${casherUrl!\'\'}",
  "codePageUrl": "${casherUrl!\'\'}",
  "chnlTxnStatus": "${ctx.success?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.success?string!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "處理中",
  "respCode": "0000",
  "respMsg": "Processed"
}', 100, '014d 銀行直連 代收同步響應（0121，qrcode→收銀台）', '', '2026-03-23 13:59:01', '2026-03-23 19:50:55'),
('GE', '*', '014d_txn_sync_resp_sign.ftl', '
', 100, '014d 銀行直連 代收同步響應驗簽（空文件）', '', '2026-03-23 13:59:01', '2026-03-23 13:59:01'),
('GE', '*', '014e_txnQry_req.ftl', '
', 100, '014e 網銀掃碼 代收查詢請求（空文件，GET）', '', '2026-03-23 13:59:01', '2026-03-23 13:59:01'),
('GE', '*', '014e_txnQry_req_header.ftl', '<#-- 014e_txnQry_req_header.ftl: 代收查詢 Header 模板（014e） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '014e 網銀掃碼 代收查詢 Header', '', '2026-03-23 13:59:17', '2026-03-23 19:58:34'),
('GE', '*', '014e_txnQry_req_sign.ftl', '
', 100, '014e 網銀掃碼 代收查詢簽名（空文件）', '', '2026-03-23 13:59:17', '2026-03-23 13:59:17'),
('GE', '*', '014e_txnQry_resp.ftl', '<#-- 014e_txnQry_resp.ftl: 代收查詢響應解析模板（014e） -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.data.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "chnlTxnAmt": "${svc.fromChnlAmt((ctx.data.amount!0)?string)?string}",
  "chnlTxnStatus": "${ctx.data.state?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.state?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_QRY\', ctx.data.state?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_QRY\', ctx.data.state?string!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Queried"
}', 100, '014e 網銀掃碼 代收查詢響應解析', '', '2026-03-23 13:59:17', '2026-03-23 20:15:26'),
('GE', '*', '014e_txnQry_resp_sign.ftl', '
', 100, '014e 網銀掃碼 代收查詢響應驗簽（空文件）', '', '2026-03-23 13:59:17', '2026-03-23 13:59:17'),
('GE', '*', '014e_txn_notify.ftl', '<#-- 014e_txn_notify.ftl: 代收異步通知解析模板（014e 網銀掃碼） -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
${svc.assertNotEmpty(\'out_trade_no 為空\', ctx.out_trade_no!\'\')}
${svc.assertEqual(\'實際支付金額與訂單金額不一致: \'+ctx.amount+\'!=\'+svc.toChnlAmt(ctx.txnAmt)?string, ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.trade_no!\'\'}",
  "chnlRespCd": "${ctx.state!\'\'}",
  "chnlRespMsg": "${ctx.state!\'\'}",
  "chnlTxnStatus": "${ctx.state!\'\'}",
  "chnlTxnStatusDesc": "${ctx.state!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_NOTIFY\', ctx.state!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_NOTIFY\', ctx.state!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '014e 網銀掃碼 代收異步通知解析', '', '2026-03-23 13:59:32', '2026-03-23 13:59:32'),
('GE', '*', '014e_txn_notify_sign.ftl', '<#-- 014e_txn_notify_sign.ftl: 代收異步通知驗簽模板（014e） -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!\'\'}",
  "out_trade_no": "${ctx.out_trade_no!\'\'}",
  "state": "${ctx.state!\'\'}",
  "trade_no": "${ctx.trade_no!\'\'}"
}
', 100, '014e 網銀掃碼 代收異步通知驗簽（4欄位）', '', '2026-03-23 13:59:46', '2026-03-23 13:59:46'),
('GE', '*', '014e_txn_req.ftl', '<#-- 014e_txn_req.ftl: 代收請求報文模板（014e 網銀掃碼） -->
<#-- bank 選填，若為空字串 removeEmptyForSign=true 在發送時排除此欄位 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 金額格式：不補零 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 本地金額格式 -->
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}', 100, '014e 網銀掃碼 代收請求報文（0121）', '', '2026-03-23 14:00:07', '2026-03-23 19:43:28'),
('GE', '*', '014e_txn_req_header.ftl', '<#-- 014e_txn_req_header.ftl: 代收請求 Header 模板（014e 網銀掃碼） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '014e 網銀掃碼 代收請求 Header（Bearer Token）', '', '2026-03-23 14:00:07', '2026-03-23 19:49:18'),
('GE', '*', '014e_txn_req_sign.ftl', '<#-- 014e_txn_req_sign.ftl: 代收請求簽名模板（014e 網銀掃碼） -->
<#-- bank 選填，若商戶參數 bank_id 為空則 removeEmptyForSign=true 會自動排除 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "bank": "${svc.getMerParam(\'bank_id\', \'\')}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}
', 100, '014e 網銀掃碼 代收請求簽名（0121）', '', '2026-03-23 14:00:26', '2026-03-23 14:00:26'),
('GE', '*', '014e_txn_sync_resp.ftl', '<#-- 014e_txn_sync_resp.ftl: 代收同步響應解析模板（014e 網銀掃碼） -->
<#setting number_format="0">
<#assign casherUrl>${svc.getCasherUrl(ctx, \'ch_qrCodeUrl\', ctx.data.qrcode!\'\')}</#assign>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "codeImgUrl": "${casherUrl!\'\'}",
  "codePageUrl": "${casherUrl!\'\'}",
  "chnlTxnStatus": "${ctx.success?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.success?string!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "處理中",
  "respCode": "0000",
  "respMsg": "Processed"
}', 100, '014e 網銀掃碼 代收同步響應（0121，qrcode→收銀台）', '', '2026-03-23 14:00:45', '2026-03-23 19:50:56'),
('GE', '*', '014e_txn_sync_resp_sign.ftl', '
', 100, '014e 網銀掃碼 代收同步響應驗簽（空文件）', '', '2026-03-23 14:00:45', '2026-03-23 14:00:45'),
('GE', '*', '5210_txnQry_req.ftl', '<#-- 5210_txnQry_req.ftl: 代付查詢請求模板（0050） -->
<#-- GET /api/payment/{chnlOrderId}，無 request body -->
', 100, '代付（5210）代收查詢請求（空文件，GET）', '', '2026-03-23 14:01:05', '2026-03-23 14:01:05'),
('GE', '*', '5210_txnQry_req_header.ftl', '<#-- 5210_txnQry_req_header.ftl: 代付查詢 Header 模板（0050） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '代付（5210）代收查詢 Header', '', '2026-03-23 14:01:23', '2026-03-23 20:02:39'),
('GE', '*', '5210_txnQry_req_sign.ftl', '
', 100, '代付（5210）代收查詢簽名（空文件）', '', '2026-03-23 14:01:23', '2026-03-23 14:01:23'),
('GE', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp.ftl: 代付查詢響應解析模板（0050） -->
<#-- 狀態碼：new/processing/verify=01, completed=10, failed/reject/refund=20 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.data.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "chnlTxnAmt": "${svc.fromChnlAmt((ctx.data.amount!0)?string)!\'\'}",
  "chnlTxnStatus": "${ctx.data.state?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.state?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_QRY\', ctx.data.state?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_QRY\', ctx.data.state?string!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Queried"
}
', 100, '代付（5210）代收查詢響應解析', '', '2026-03-23 14:01:37', '2026-03-24 10:14:12'),
('GE', '*', '5210_txnQry_resp_sign.ftl', '
', 100, '代付（5210）代收查詢響應驗簽（空文件）', '', '2026-03-23 14:01:37', '2026-03-23 14:01:37'),
('GE', '*', '5210_txn_notify.ftl', '<#-- 5210_txn_notify.ftl: 代付異步通知解析模板（5210） -->
<#-- 代付回調在 completed/failed/refund 時觸發 -->
<#-- 驗簽通過後解析狀態 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
${svc.assertNotEmpty(\'out_trade_no 為空\', ctx.out_trade_no!\'\')}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.trade_no!\'\'}",
  "chnlRespCd": "${ctx.state!\'\'}",
  "chnlRespMsg": "${ctx.state!\'\'}",
  "chnlTxnStatus": "${ctx.state!\'\'}",
  "chnlTxnStatusDesc": "${ctx.state!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_NOTIFY\', ctx.state!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_NOTIFY\', ctx.state!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '代付（5210）代收異步通知解析', '', '2026-03-23 14:02:09', '2026-03-23 14:02:09'),
('GE', '*', '5210_txn_notify_sign.ftl', '<#-- 5210_txn_notify_sign.ftl: 代付異步通知驗簽模板（5210） -->
<#-- 驗簽欄位：固定 4 個（trade_no, amount, out_trade_no, state） -->
<#-- 排除：sign, callback_url -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!\'\'}",
  "out_trade_no": "${ctx.out_trade_no!\'\'}",
  "state": "${ctx.state!\'\'}",
  "trade_no": "${ctx.trade_no!\'\'}"
}
', 100, '代付（5210）代收異步通知驗簽（4欄位）', '', '2026-03-23 14:02:27', '2026-03-23 14:02:27'),
('GE', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req.ftl: 代付請求報文模板（5210） -->
<#-- sign 由系統根據 5210_txn_req_sign.ftl 計算後填入 ctx.sign -->
<#setting number_format="0">
{
  "VerifyChannelNo": "${ctx.VerifyChannelNo!\'1\'}",
  "out_trade_no": "${ctx.out_trade_no!\'\'}",
  "bank_id": "${ctx.bank_id!\'\'}",
  "bank_owner": "${ctx.bank_owner!\'\'}",
  "account_number": "${ctx.account_number!\'\'}",
  "amount": "${ctx.amount!\'\'}",
  "callback_url": "${ctx.callback_url!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}
', 100, '代付（5210）代收請求報文（0121）', '', '2026-03-23 14:03:44', '2026-03-23 23:55:07'),
('GE', '*', '5210_txn_req_header.ftl', '<#-- 5210_txn_req_header.ftl: 代付請求 Header 模板（5210） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '代付（5210）代收請求 Header（Bearer Token）', '', '2026-03-23 14:03:59', '2026-03-23 20:02:39'),
('GE', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign.ftl: 代付請求簽名模板（5210） -->
<#-- 代付 sign 必填，對除 sign 外所有欄位按 ksort 計算 MD5 -->
<#-- VerifyChannelNo=1 為官方示例必帶字段 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "VerifyChannelNo": "1",
  "account_number": "${ctx.accNum!\'\'}",
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "bank_id": "${ctx.chnlBankNum!\'\'}",
  "bank_owner": "${ctx.accName!\'\'}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}
', 100, '代付（5210）代收請求簽名（0121）', '', '2026-03-23 14:12:21', '2026-03-23 14:12:21'),
('GE', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp.ftl: 代付同步響應解析模板（5210） -->
<#-- 同步響應以 success Boolean 判斷提交成功/失敗 -->
<#-- success=true → txnStatus=01（處理中，等待異步通知） -->
<#-- success=false → txnStatus=20（提交失敗） -->
<#setting number_format="0">
{
  "channel": "${(svc.getChannel())!\'\'}",
  "intTxnType": "${(svc.getIntTxnType())!\'\'}",
  "chnlMerId": "${(svc.getChnlMerId())!\'\'}",
  "chnlOrderId": "${(ctx.data.out_trade_no)!(ctx.chnlOrderId)!\'\'}",
  "chnlTxnId": "${(ctx.data.trade_no)!\'\'}",
  "chnlTxnStatus": "${(ctx.data.state)!\'\'}",
  "chnlTxnStatusDesc": "${(ctx.data.state)!\'\'}",
  <#assign successStr = (ctx.success?string)!\'\' />
  <#assign statusCodeStr = (ctx.status_code?string)!\'\' />
  <#assign statusCode = successStr + statusCodeStr />
  "txnStatus": "${(svc.getTranslatedCode(\'WITHDRAW\', statusCode))!\'01\'}",
  "txnStatusDesc": "${(svc.getTranslatedMsg(\'WITHDRAW\', statusCode))!\'处理中\'}",
  "respCode": "0000",
  "respMsg": "Processed"
}', 100, '代付（5210）代收同步響應（0121，qrcode→收銀台）', '', '2026-03-23 14:01:05', '2026-03-23 23:26:09'),
('GE', '*', '5210_txn_sync_resp_sign.ftl', '', 100, '代付（5210）代收同步響應驗簽（空文件）', '', '2026-03-23 14:03:59', '2026-03-23 14:03:59'),
('GE', '*', 'txnQry_req.ftl', '<#-- txnQry_req.ftl: 代收查詢請求模板（0010） -->
<#-- GET /api/transaction/{chnlOrderId}，無 request body -->
<#-- 訂單號透過 url.txn.query 的 ${chnlOrderId} 路徑參數傳遞 -->', 100, '代收查詢請求（空文件，GET）', '', '2026-03-23 14:13:28', '2026-03-23 14:13:28'),
('GE', '*', 'txnQry_req_header.ftl', '<#-- txnQry_req_header.ftl: 代收查詢請求 Header 模板（0010） -->
<#-- GET 查詢也需要 Bearer Token 認證 -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '代收查詢 Header', '', '2026-03-23 14:13:16', '2026-03-23 19:59:45'),
('GE', '*', 'txnQry_req_sign.ftl', '<#-- txnQry_req_sign.ftl: 代收查詢請求簽名模板（0010） -->
<#-- GET 請求無 body，不需要簽名，空文件 -->
', 100, '代收查詢簽名（空文件）', '', '2026-03-23 14:13:28', '2026-03-23 14:13:28'),
('GE', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl: 代收查詢響應解析模板（0010） -->
<#-- 狀態碼：new/processing/verify=01, completed=10, failed/reject/refund=20 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.data.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "chnlTxnAmt": "${svc.fromChnlAmt((ctx.data.amount!0)?string)?string}",
  "chnlTxnStatus": "${ctx.data.state?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.state?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_QRY\', ctx.data.state?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_QRY\', ctx.data.state?string!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Queried"
}', 100, '代收查詢響應解析', '', '2026-03-23 14:13:45', '2026-03-23 20:15:26'),
('GE', '*', 'txnQry_resp_sign.ftl', '
', 100, '代收查詢響應驗簽（空文件）', '', '2026-03-23 14:13:45', '2026-03-23 14:13:45'),
('GE', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl: 代收異步通知解析模板（0121/014d/014e） -->
<#-- 代收回調只通知 completed（成功）訂單 -->
<#-- 驗簽後，金額需校驗（不浮動） -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 金額格式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 本地金額格式 -->
${svc.assertNotEmpty(\'out_trade_no 為空\', ctx.out_trade_no!\'\')} <#-- 訂單號非空斷言 -->
${svc.assertEqual(\'實際支付金額與訂單金額不一致: \'+ctx.amount+\'!=\'+svc.toChnlAmt(ctx.txnAmt)?string, ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)} <#-- 不浮動金額校驗 -->
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.out_trade_no!\'\'}",
  "chnlTxnId": "${ctx.trade_no!\'\'}",
  "chnlRespCd": "${ctx.state!\'\'}",
  "chnlRespMsg": "${ctx.state!\'\'}",
  "chnlTxnStatus": "${ctx.state!\'\'}",
  "chnlTxnStatusDesc": "${ctx.state!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_NOTIFY\', ctx.state!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_NOTIFY\', ctx.state!\'\')!\'處理中\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '代收異步通知解析', '', '2026-03-23 14:24:44', '2026-03-23 14:24:44'),
('GE', '*', 'txn_notify_sign.ftl', '<#-- txn_notify_sign.ftl: 代收異步通知驗簽模板 -->
<#-- 驗簽欄位：固定 4 個（trade_no, amount, out_trade_no, state） -->
<#-- 排除：sign, request_amount, callback_url -->
<#-- 系統將此 JSON 轉為 Map，ksort 後串接 sign.key 做 MD5 -->
<#setting number_format="0">
{
  "amount": "${ctx.amount!\'\'}",
  "out_trade_no": "${ctx.out_trade_no!\'\'}",
  "state": "${ctx.state!\'\'}",
  "trade_no": "${ctx.trade_no!\'\'}"
}
', 100, '代收異步通知驗簽（4欄位）', '', '2026-03-23 14:24:59', '2026-03-23 14:24:59'),
('GE', '*', 'txn_req.ftl', '<#-- txn_req.ftl: 代收請求報文模板（0121 純卡網關） -->
<#-- 返回 data.qrcode 供自製收銀台展示 QR Code -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 金額格式：不補零 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 本地金額格式 -->
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}', 100, '代收請求報文（0121）', '', '2026-03-23 14:25:11', '2026-03-23 18:29:27'),
('GE', '*', 'txn_req_header.ftl', '<#-- txnQry_req_header.ftl: 代收查詢請求 Header 模板（0010） -->
<#-- GET 查詢也需要 Bearer Token 認證 -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),\'apitoken\',\'\')}"
}', 100, '代收請求 Header（Bearer Token）', '', '2026-03-23 14:25:23', '2026-03-23 19:58:34'),
('GE', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign.ftl: 代收請求簽名模板（0121 純卡網關） -->
<#-- sign 對 API 為選填，此模板提供簽名支持 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 設置交易幣別：越南盾 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 金額單位：元（VND） -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 金額格式：不補零 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 本地金額格式 -->
{
  "amount": "${svc.toChnlAmt(ctx.txnAmt)}",
  "callback_url": "${ctx.chnlNotifyUrl!\'\'}",
  "out_trade_no": "${ctx.chnlOrderId!\'\'}"
}
', 100, '代收請求簽名（0121）', '', '2026-03-23 14:25:23', '2026-03-23 14:25:23'),
('GE', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp.ftl: 代收同步響應解析模板（0121 純卡網關） -->
<#-- 同步響應表示提交成功，txnStatus 固定 01（處理中） -->
<#-- 透過 getCasherUrl 傳遞 data.qrcode 給自製收銀台 -->
<#setting number_format="0">
<#assign casherUrl>${svc.getCasherUrl(ctx, \'ch_qrCodeUrl\', ctx.data.qrcode!\'\')}</#assign>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.trade_no!\'\'}",
  "codeImgUrl": "${casherUrl!\'\'}",
  "codePageUrl": "${casherUrl!\'\'}",
  "chnlTxnStatus": "${ctx.success?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.success?string!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "處理中",
  "respCode": "0000",
  "respMsg": "Processed"
}', 100, '代收同步響應（0121，qrcode→收銀台）', '', '2026-03-23 14:25:55', '2026-03-23 18:39:29'),
('GE', '*', 'txn_sync_resp_sign.ftl', '
', 100, '代收同步響應驗簽（空文件）', '', '2026-03-23 14:25:55', '2026-03-23 14:25:55');
