REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('GB', '*', '5210_txnQry_req.ftl', '<#-- 5210_txnQry_req.ftl: 代付查詢請求報文模板 -->
<#setting number_format="0">
{
"pay_customer_id": ${ctx.pay_customer_id},
"pay_apply_date": ${ctx.pay_apply_date},
"pay_order_id": "${ctx.pay_order_id!\'\'}",
"pay_md5_sign": "${ctx.sign!\'\'}"
}
', 100, ' 交易查詢請求模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:41'),
('GB', '*', '5210_txnQry_req_sign.ftl', '<#-- 5210_txnQry_req_sign.ftl: 代付查詢請求簽名模板 -->
<#setting number_format="0">
{
"pay_customer_id": "${svc.getChnlMerId()}",
"pay_apply_date": "${svc.nowSecs()}",
"pay_order_id": "${ctx.chnlOrderId}"
}
', 100, '代付交易查詢請求簽名模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:41'),
('GB', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp.ftl: 代付查詢響應解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'data参数不可为空\', ctx.data)}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.data.member_id!svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.data.payment_id!\'\'}",
  "chnlTxnStatus": "${ctx.data.status!\'\'}",
  "chnlTxnStatusDesc": "${ctx.data.status_name!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_QRY\', ctx.data.status?string!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_QRY\', ctx.data.status?string!\'\')!\'异常\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '代付交易查詢響應模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:41'),
('GB', '*', '5210_txnQry_resp_sign.ftl', '', 100, '代付交易查詢響應驗簽模板', '', '2026-03-09 11:22:31', '2026-03-09 11:22:31'),
('GB', '*', '5210_txn_notify.ftl', '<#-- 5210_txn_notify.ftl: 代付異步通知解析模板 -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'transaction_code参数不可为空\', ctx.transaction_code)}

{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()}",
  "chnlMerId": "${ctx.customer_id!svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId": "${ctx.transaction_id!\'\'}",
  "chnlTxnStatus": "${ctx.transaction_code!\'\'}",
  "chnlTxnStatusDesc": "${ctx.transaction_msg!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW_NOTIFY\', ctx.transaction_code!\'\')!\'01\'}",
  "txnStatusDesc": "${svc.getTranslatedMsg(\'WITHDRAW_NOTIFY\', ctx.transaction_code!\'\')!\'异常\'}",
  "respCode": "0000",
  "respMsg": "Notified"
}
', 100, '代付交易回調模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:41'),
('GB', '*', '5210_txn_notify_sign.ftl', '<#-- 5210_txn_notify_sign.ftl: 代付異步通知驗簽模板 -->
<#setting number_format="0">
{
    "customer_id": "${ctx.customer_id}",
    "order_id": "${ctx.order_id!\'\'}",
    "amount": "${ctx.amount!\'\'}",
    "datetime": "${ctx.datetime!\'\'}",
    "transaction_id": "${ctx.transaction_id!\'\'}",
    "transaction_code": "${ctx.transaction_code!\'\'}",
    "transaction_msg": "${ctx.transaction_msg!\'\'}"
}
', 100, '代付交易回調驗簽模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:42'),
('GB', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.00\')} <#-- 设置渠道金额的格式化方式 -->
<#assign rawAmount = svc.toChnlAmt(ctx.txnAmt)>
<#assign formattedAmount = rawAmount?number?string("0.##")>

{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": "${ctx.pay_apply_date}",
"pay_order_id": "${ctx.chnlOrderId}",
"pay_notify_url": "${ctx.pay_notify_url}",
"pay_amount": ${formattedAmount},
"pay_account_name": "${ctx.pay_account_name}",
"pay_card_no": "${ctx.pay_card_no}",
"pay_bank_name": "${ctx.pay_bank_name}",
"pay_md5_sign": "${ctx.sign}"
}', 100, '代付交易請求模板', '', '2026-03-09 11:22:31', '2026-03-09 16:00:18'),
('GB', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.00\')} <#-- 设置渠道金额的格式化方式 -->
<#assign rawAmount = svc.toChnlAmt(ctx.txnAmt)>
<#assign formattedAmount = rawAmount?number?string("0.##")>
{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": ${svc.nowSecs()},
"pay_order_id": "${ctx.chnlOrderId}",
"pay_notify_url": "${ctx.chnlNotifyUrl!\'\'}",
"pay_amount": ${formattedAmount},
"pay_account_name": "${ctx.accName!\'\'}",
"pay_card_no": "${ctx.accNum!\'\'}",
"pay_bank_name": "${ctx.chnlBankName!\'\'}"
}', 100, '代付交易請求簽名模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:42'),
('GB', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp.ftl: 代付同步響應模板 -->
<#setting number_format="0">
{
  "channel": "${svc.getChannel()}",
  "intTxnType": "${svc.getIntTxnType()!\'\'}",
  "chnlMerId": "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId": "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatusDesc": "${ctx.message!\'\'}",
  "txnStatus": "${svc.getTranslatedCode(\'WITHDRAW\', ctx.code?string!\'\')!\'20\'}",
  "txnStatusDesc": "${ctx.message!\'\'} - ${svc.getTranslatedMsg(\'WITHDRAW\', ctx.code?string!\'\')!\'异常\'}",
  "respCode": "0000",
  "respMsg": "OK"
}
', 100, '代付交易請求響應模板', '', '2026-03-09 11:22:31', '2026-03-09 15:43:43'),
('GB', '*', '5210_txn_sync_resp_sign.ftl', '', 100, '代付交易請求響應驗簽模板', '', '2026-03-09 11:22:31', '2026-03-09 11:22:31'),
('GB', '*', 'txnQry_req.ftl', '<#-- txnQry_req: 代付查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0">
{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": ${ctx.pay_apply_date},
"pay_order_id": "${ctx.pay_order_id}",
"pay_md5_sign": "${ctx.sign!\'\'}"
}

', 100, '交易查詢請求模板', '', '2026-03-09 11:22:31', '2026-03-09 15:00:24'),
('GB', '*', 'txnQry_req_sign.ftl', '<#-- txnQry_req_sign: 交易查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0">
{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": ${svc.nowSecs()},
"pay_order_id": "${ctx.chnlOrderId}"
}', 100, '交易查詢請求簽名模板', '', '2026-03-09 11:22:31', '2026-03-09 15:00:15'),
('GB', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
<#if (ctx.data.status?string)! == "1" || (ctx.data.status?string)! == "2">
  <#-- ${svc.assertEqual(\'实际支付金额与原订单金额不一致: \' + (ctx.data.real_amount?string!\'0\') + \' != \' + svc.toChnlAmt(ctx.txnAmt), ctx.data.real_amount?string!\'0\', svc.toChnlAmt(ctx.txnAmt))} -->
<#assign realAmt = (ctx.data.real_amount?string!\'0\')?number>
  <#assign expectedAmt = (svc.toChnlAmt(ctx.txnAmt))?number>
  
  ${svc.assertEqual(\'实际支付金额与原订单金额不一致: \' + realAmt + \' != \' + expectedAmt, realAmt?string, expectedAmt?string)}
</#if>

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.data.transaction_id!\'\'}",
  "chnlTxnStatus" : "${(ctx.data.status?string)!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'PAY_QRY\', (ctx.data.status?string)!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'PAY_QRY\', (ctx.data.status?string)!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}', 100, '交易查詢響應模板', '', '2026-03-09 11:22:31', '2026-03-09 20:00:53'),
('GB', '*', 'txnQry_resp_sign.ftl', '', 100, '交易查詢響應驗簽模板', '', '2026-03-09 11:22:31', '2026-03-09 11:22:31'),
('GB', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->

<#-- ${svc.assertEqual(\'实际支付金额与原订单金额不一致\'+(ctx.real_amount?string)+\'::\'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.real_amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}  -->
${svc.assertNotEmpty(\'status参数不可为空\', ctx.status)}
${svc.assertEqual(\'实际支付金额与原订单金额不一致: \'+(ctx.real_amount?string!\'0\')+\' != \'+(svc.toChnlAmt(ctx.txnAmt)), ctx.real_amount?string!\'0\', svc.toChnlAmt(ctx.txnAmt))}

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.transaction_id!\'\'}",<#--
  "chnlRespCd" : "${ctx.status!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.status!\'\'}", -->
  "chnlTxnStatus" : "${ctx.status!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'PAY_NOTIFY\',ctx.status!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'PAY_NOTIFY\',ctx.status!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}', 100, '交易回調模板', '', '2026-03-09 11:22:31', '2026-03-09 15:37:00'),
('GB', '*', 'txn_notify_sign.ftl', '<#-- notify_sign.ftl -->
<#setting number_format="0">
{
    "customer_id":"${ctx.customer_id!\'\'}",
    "order_id":"${ctx.order_id!\'\'}",
    "transaction_id":"${ctx.transaction_id!\'\'}",
    "order_amount":"${ctx.order_amount!\'\'}",
    "real_amount":"${ctx.real_amount!\'\'}",
    "status":"${ctx.status!\'\'}",
    "message":"${ctx.message!\'\'}"
 
}
', 100, '交易回調驗簽模板', '', '2026-03-09 11:22:31', '2026-03-09 15:21:56'),
('GB', '*', 'txn_req.ftl', '<#-- txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 设置渠道金额的格式化方式 -->
<#assign rawAmount = svc.toChnlAmt(ctx.txnAmt)>
<#assign formattedAmount = rawAmount?number?string("0.##")>

{
"pay_customer_id": ${ctx.pay_customer_id},
"pay_apply_date": ${ctx.pay_apply_date},
"pay_order_id": "${ctx.pay_order_id}",
"pay_notify_url": "${ctx.pay_notify_url}",
"pay_amount": ${formattedAmount},
"pay_channel_id": ${ctx.pay_channel_id},
"pay_md5_sign": "${ctx.sign!\'\'}"
}', 100, '交易請求模板', '', '2026-03-09 11:22:31', '2026-03-09 16:03:54'),
('GB', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 设置渠道金额的格式化方式 -->
<#assign rawAmount = svc.toChnlAmt(ctx.txnAmt)>
<#assign formattedAmount = rawAmount?number?string("0.##")>
{
"pay_customer_id": ${svc.getChnlMerId()},
"pay_apply_date": ${svc.nowSecs()},
"pay_order_id": "${ctx.chnlOrderId}",
"pay_notify_url": "${ctx.chnlNotifyUrl!\'\'}",
"pay_amount": ${formattedAmount},
"pay_channel_id": 9649
}', 100, '交易請求簽名模板', '', '2026-03-09 11:22:31', '2026-03-09 12:24:36'),
('GB', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.assertEqual(\'Error: \' + (ctx.msg!\'Transaction error!\'), \'0\', ctx.code?string)} 
${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
<#assign casherUrl>${svc.getCasherUrl(ctx, 
  \'ch_bank_code\', ctx.data.bank_code!\'\',
  \'ch_bank_name\', ctx.data.bank_name!\'\',
  \'ch_bank_no\', ctx.data.bank_no!\'\',
  \'ch_bank_owner\', ctx.data.bank_owner!\'\',
  \'ch_bank_from\', ctx.data.bank_from!\'\',
  \'ch_qr_code\', ctx.data.qr_code!\'\',
  \'ch_remark\', ctx.data.remark!\'\',
   \'lang\', \'vn\')}</#assign>
{
  
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!\'\'}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",<#--
  "chnlTxnId" : "${ctx.orderNo!\'\'}",
  
  "codeImgUrl" : "${ctx.data.view_url!\'\'}",
  "codePageUrl" : "${ctx.data.view_url!\'\'}",
  -->
  "codeImgUrl" : "${casherUrl!\'\'}",
  "codePageUrl" : "${casherUrl!\'\'}",
  
  "txnStatus" : "01",
  "txnStatusDesc" : "In processing",
  "respCode" : "0000",
  "respMsg" : "OK"
}', 100, '交易請求響應模板', '', '2026-03-09 11:22:31', '2026-03-09 18:00:28'),
('GB', '*', 'txn_sync_resp_sign.ftl', '', 100, '交易請求響應驗簽模板', '', '2026-03-09 11:22:31', '2026-03-09 11:22:31');
