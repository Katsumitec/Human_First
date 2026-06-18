REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('GG', '*', '0098_txn_notify.ftl', '<#-- 0098_txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0.##\')}
${svc.setLocalAmtFormat(\'0\')}
<#assign orderResult=svc.queryOrderByChnlOrderIdWithAmt(ctx.merchantOrderId, ctx.payAmount) />
<#assign respToChannel = \'fail\' />
<#if orderResult.result_code == \'0000\'>
  <#assign respToChannel = \'success\' />
</#if>
{
  "channel" : "${ctx.channel!ctx.channelId!svc.getChannel()}",
  "intTxnType" : "${ctx.intTxnType!svc.getIntTxnType()}",
  "chnlOrderId" : "${ctx.merOrderId!ctx.chnlOrderId!\'\'}",
  "respToChannel" : "${respToChannel}",
  "respContentType" : "text/plain"
}', 100, '交易反查模版', '', '2026-04-09 17:47:19', '2026-04-10 20:18:14'),
('GG', '*', '5210_txnQry_req.ftl', '<#-- 5210_txnQry_req.ftl: 代付查詢請求報文模板（GG NewSKYPay）-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!\'\'},
  "merchantOrderId": "${ctx.merchantOrderId!\'\'}",
  "payAmount": ${ctx.payAmount!\'\'},
  "sign": "${ctx.sign!\'\'}"
}', 100, '代付查询请求报文模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txnQry_req_sign.ftl', '<#-- 5210_txnQry_req_sign.ftl: 代付查詢請求簽名模板（GG NewSKYPay）-->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}"
}', 100, '代付查询请求签名模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp.ftl: 代付查詢響應解析模板（GG NewSKYPay）
     status=1: 訂單存在; orderStatus: 0→01, 3→10(推測), 8→20
-->
<#setting number_format="0">

<#if ctx.status?string == \'1\'>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.payOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.data.orderStatus?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.orderStatus?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_QRY\', ctx.data.orderStatus?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_QRY\', ctx.data.orderStatus?string!\'\')!\'处理中\'}",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.status?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "查询失败，保留处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>', 100, '代付查询响应解析模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txnQry_resp_sign.ftl', '
', 100, '代付查询响应验签模板（空）', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txn_notify.ftl', '<#-- 5210_txn_notify.ftl: 代付異步通知解析模板（GG NewSKYPay）
     回調字段: merchantId, merchantOrderId, payOrderId, payAmount, paidAmount, bankNum, bankAccount, orderStatus, remark, sign
     orderStatus: 3=成功(10), 8=失敗(20), 其他=處理中(01)
-->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

<#if ctx.orderStatus?? && ctx.orderStatus?string == "3">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.payOrderId!\'\'}",
  "chnlRespCd": "${ctx.orderStatus?string!\'\'}",
  "chnlRespMsg": "success",
  "chnlTxnStatus": "${ctx.orderStatus?string!\'\'}",
  "chnlTxnStatusDesc": "paid",
  "txnStatus": "10",
  "txnStatusDesc": "Success",
  "respCode": "0000",
  "respMsg": "Notified"
}
<#elseif ctx.orderStatus?? && ctx.orderStatus?string == "8">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.payOrderId!\'\'}",
  "chnlRespCd": "${ctx.orderStatus?string!\'\'}",
  "chnlRespMsg": "${ctx.remark!\'failed\'}",
  "chnlTxnStatus": "${ctx.orderStatus?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.remark!\'failed\'}",
  "txnStatus": "20",
  "txnStatusDesc": "${ctx.remark!\'Failed\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.payOrderId!\'\'}",
  "chnlRespCd": "${ctx.orderStatus?string!\'\'}",
  "chnlRespMsg": "${ctx.remark!\'processing\'}",
  "chnlTxnStatus": "${ctx.orderStatus?string!\'\'}",
  "chnlTxnStatusDesc": "processing",
  "txnStatus": "01",
  "txnStatusDesc": "Processing",
  "respCode": "0000",
  "respMsg": "Notified"
}
</#if>', 100, '代付异步通知解析模板（orderStatus: 3→10成功, 8→20失敗, 其他→01處理中）', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txn_notify_sign.ftl', '<#-- 5210_txn_notify_sign.ftl: 代付回調驗簽模板（GG NewSKYPay）
     簽名欄位固定順序: merchantId → merchantOrderId → payOrderId → payAmount → paidAmount（成功時）→ bankNum → bankAccount
     paidAmount 僅在 orderStatus == 3（支付成功）時參與簽名
     因 5210 ext_config sortMessageForSign=false，欄位順序由模板決定。
-->
<#setting number_format="0">
{
"merchantId": "${ctx.merchantId!\'\'}",
"merchantOrderId": "${ctx.merchantOrderId!\'\'}",
"payOrderId": "${ctx.payOrderId!\'\'}",
"payAmount": "${ctx.payAmount!\'\'}",
<#if ctx.orderStatus?? && ctx.orderStatus?string == "3">
"paidAmount": "${ctx.paidAmount!\'\'}",
</#if>
"bankNum": "${ctx.bankNum!\'\'}",
"bankAccount": "${ctx.bankAccount!\'\'}"
}', 100, '代付回调验签模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req.ftl: 代付下單請求報文模板（GG NewSKYPay）
     簽名欄位: merchantId, merchantOrderId, payAmount, bankNum, bankAccount
     非簽名欄位: bankType, payType, commonType, withdrawQueryUrl, notifyUrl
-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!\'\'},
  "merchantOrderId": "${ctx.merchantOrderId!\'\'}",
  "payAmount": ${ctx.payAmount!\'\'},
  "bankNum": "${ctx.bankNum!\'\'}",
  "bankAccount": "${ctx.bankAccount!\'\'}",
  "bankType": "${ctx.chnlBankNum!\'\'}",
  "payType": 1060,
  "commonType": "vnd",
  "withdrawQueryUrl": "${svc.getMerParam(\'withdrawQueryUrl\', \'\')}",
  "notifyUrl": "${ctx.chnlNotifyUrl!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}', 100, '代付下单请求报文模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign.ftl: 代付下單請求簽名模板（GG NewSKYPay）
     簽名欄位固定順序（非字母序）: merchantId → merchantOrderId → payAmount → bankNum → bankAccount
     ext_config: sortMessageForSign=false
-->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}",
"bankNum": "${ctx.accNum!\'\'}",
"bankAccount": "${ctx.accName!\'\'}"
}', 100, '代付下单请求签名模板（固定字段顺序，非字母序）', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp.ftl: 代付下單同步響應解析模板（GG NewSKYPay）
     status=1 且 data != null: 下單成功，txnStatus=01，等待異步通知確認
     其他情況（status!=1 或 data==null）: txnStatus=01(處理中)，respCode=9999，msg 帶渠道錯誤訊息
     相容格式: 正常回應用 status 欄位，錯誤回應可能只有 code 欄位
-->
<#setting number_format="0">
<#if ctx.status?? && ctx.status?string == "1" && ctx.data??>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.payOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.status?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "",
  "chnlTxnStatus": "${ctx.status!ctx.code!\'\'}",
  "chnlTxnStatusDesc": "${ctx.msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "${ctx.msg!\'处理中\'}",
  "respCode": "9999",
  "respMsg": "${ctx.msg!\'Error\'}"
}
</#if>', 100, '代付下单同步响应解析模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', '5210_txn_sync_resp_sign.ftl', '
', 100, '代付同步响应验签模板（空）', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txnQry_req.ftl', '<#-- txnQry_req.ftl: 代收查詢請求報文模板（GG NewSKYPay）-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!\'\'},
  "merchantOrderId": "${ctx.merchantOrderId!\'\'}",
  "payAmount": ${ctx.payAmount!\'\'},
  "sign": "${ctx.sign!\'\'}"
}', 100, '代收查询请求报文模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txnQry_req_sign.ftl', '<#-- txnQry_req_sign.ftl: 代收查詢請求簽名模板（GG NewSKYPay）-->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}"
}', 100, '代收查询请求签名模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl: 代收查詢響應解析模板（GG NewSKYPay）
     status=1: 訂單存在; orderStatus: 0→01, 3→10, 8→20
-->
<#setting number_format="0">

<#if ctx.status?string == \'1\'>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.payOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.data.orderStatus?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.orderStatus?string!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'PAY_QRY\', ctx.data.orderStatus?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'PAY_QRY\', ctx.data.orderStatus?string!\'\')!\'处理中\'}",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.status?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "查询失败，保留处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
</#if>', 100, '代收查询响应解析模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txnQry_resp_sign.ftl', '
', 100, '代收查询响应验签模板（空）', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl: 代收異步通知解析模板（GG NewSKYPay）
     回調字段: payOrderId, payAmount, merchantId, sign, orderStatus, remark, merchantOrderId, paidAmount
     orderStatus: 3=成功；remark: 狀態說明文字
     不浮動金額: 要求 paidAmount 等於下單 payAmount
-->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'paidAmount 不可為空\', ctx.paidAmount)}
${svc.assertEqual(\'實際收款金額與訂單金額不一致: \' + (ctx.paidAmount?string!\'0\') + \' != \' + (svc.toChnlAmt(ctx.txnAmt)), ctx.paidAmount?string!\'0\', svc.toChnlAmt(ctx.txnAmt))}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.merchantOrderId!\'\'}",
  "chnlRespCd": "${ctx.orderStatus?string!\'\'}",
  "chnlRespMsg": "${ctx.remark!\'\'}",
  "chnlTxnStatus": "${ctx.orderStatus?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.remark!\'\'}",
  "txnStatus": "10",
  "txnStatusDesc": "Success",
  "respCode": "0000",
  "respMsg": "Notified"
}', 100, '代收异步通知解析模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txn_notify_sign.ftl', '<#-- txn_notify_sign.ftl: 代收回調驗簽模板（GG NewSKYPay）
     簽名欄位（固定順序，按文件示例）: merchantId → merchantOrderId → payOrderId → payAmount → paidAmount（成功時）
     不參與簽名: remark, orderStatus, bankAccount, sign
     paidAmount 僅在 orderStatus == 3（支付成功）時參與簽名
-->
<#setting number_format="0">
{
"merchantId": "${ctx.merchantId!\'\'}",
"merchantOrderId": "${ctx.merchantOrderId!\'\'}",
"payOrderId": "${ctx.payOrderId!\'\'}",
"payAmount": "${ctx.payAmount!\'\'}"<#if ctx.orderStatus?? && ctx.orderStatus?string == "3">,
"paidAmount": "${ctx.paidAmount!\'\'}"</#if>
}', 100, '代收回调验签模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txn_req.ftl', '<#-- txn_req.ftl: 代收下單請求報文模板（GG NewSKYPay）-->
<#setting number_format="0">
{
  "merchantId": ${ctx.merchantId!\'\'},
  "merchantOrderId": "${ctx.merchantOrderId!\'\'}",
  "payAmount": ${ctx.payAmount!\'\'},
  "payType": 1060,
  "userId": "${rand.getInt(1000, 9999)}",
  "notifyUrl": "${ctx.chnlNotifyUrl!\'\'}",
  "sign": "${ctx.sign!\'\'}"
}', 100, '代收下单请求报文模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign.ftl: 代收下單請求簽名模板（GG NewSKYPay）
     簽名欄位順序（字母序）: merchantId → merchantOrderId → payAmount
     簽名格式: merchantId=XXX&merchantOrderId=XXX&payAmount=XXX&key={商戶金鑰}
-->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}
{
"merchantId": "${svc.getChnlMerId()}",
"merchantOrderId": "${ctx.chnlOrderId}",
"payAmount": "${svc.toChnlAmt(ctx.txnAmt)}"
}', 100, '代收下单请求签名模板', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13'),
('GG', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp.ftl: 代收下單同步響應解析模板（GG NewSKYPay）
     成功(status=1, data 存在): 使用 data.qrCode 透過自製收銀台展示，txnStatus=01
     異常(status≠1 或 data 缺失): 保持 txnStatus=01（處理中），記錄渠道錯誤訊息，不直接判失敗
     相容格式: 正常回應用 status 欄位，錯誤回應可能只有 code 欄位
-->
<#setting number_format="0">

<#if ctx.status?? && ctx.status?string == \'1\' && ctx.data??>
<#assign casherUrl>${svc.getCasherUrl(ctx,
\'ch_qr_code_url\', ctx.data.qrAddress!\'\',
\'ch_bank_name\', ctx.data.receiveType!\'\',
\'ch_bank_no\', ctx.data.receiveNum!\'\',
\'ch_bank_owner\', ctx.data.receiveAccount!\'\',
\'ch_remark\', ctx.data.remark!\'\',
\'currentLang\',\'vn\'
)}</#assign>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.payOrderId!\'\'}",
  "codeImgUrl": "${casherUrl!\'\'}",
  "codePageUrl": "${casherUrl!\'\'}",
  "chnlTxnStatus": "${ctx.status?string!\'\'}",
  "chnlTxnStatusDesc": "${ctx.msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "In processing",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()!\'\'}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatus": "${ctx.status!ctx.code!\'\'}",
  "chnlTxnStatusDesc": "${ctx.msg!\'\'}",
  "txnStatus": "01",
  "txnStatusDesc": "${ctx.msg!\'Error\'}",
  "respCode": "9999",
  "respMsg": "${ctx.msg!\'Error\'}"
}
</#if>', 100, '代收下单同步响应解析模板', '', '2026-04-10 18:16:13', '2026-04-11 20:51:01'),
('GG', '*', 'txn_sync_resp_sign.ftl', '
', 100, '代收同步响应验签模板（空）', '', '2026-04-10 18:16:13', '2026-04-10 18:16:13');
