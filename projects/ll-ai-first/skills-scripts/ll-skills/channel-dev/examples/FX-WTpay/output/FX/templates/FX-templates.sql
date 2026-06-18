REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('FX', '*', '5210_txnQry_req.ftl', '', 100, ' 交易查詢請求模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', '5210_txnQry_req_header.ftl', '<#-- 5210_txnQry_req_header.ftl -->
{
	"Accept": "application/json",
	"Authorization": "Bearer ${svc.getMerParam(\'apitoken\',\'R2mbEHVZybFf0POR3CBQPrY3Rc78X6LxyymtX5dwZaKeOEWAt86rMlLxF6v4\')}"
}', 100, '交易請求響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 13:56:17'),
('FX', '*', '5210_txnQry_req_sign.ftl', '', 100, '代付交易查詢請求簽名模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp: 交易查詢 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->
${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
${svc.assertEqual(\'实际支付金额与原订单金额不一致\'+(ctx.data.amount?string)+\'::\'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.data.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}
{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.outTradeNo!ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.data.trade_no!\'\'}",<#--
  "chnlRespCd" : "${ctx.state!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.state!\'\'}", -->
  "chnlTxnStatus" : "${ctx.data.state!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAW_QRY\',ctx.data.state!!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'WITHDRAW_QRY\',ctx.data.state!!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}



', 100, '代付交易查詢響應模板', '', '2026-02-24 10:39:49', '2026-02-24 17:54:42'),
('FX', '*', '5210_txnQry_resp_sign.ftl', '', 100, '代付交易查詢響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', '5210_txn_notify.ftl', '<#-- 5210txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->

${svc.assertEqual(\'实际支付金额与原订单金额不一致\'+(ctx.amount?string)+\'::\'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.trade_no!\'\'}",<#--
  "chnlRespCd" : "${ctx.state!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.state!\'\'}", -->
  "chnlTxnStatus" : "${ctx.state!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAW_NOTIFY\',ctx.state!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'WITHDRAW_NOTIFY\',ctx.state!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}', 100, '代付交易回調模板', '', '2026-02-24 10:39:49', '2026-02-24 17:57:31'),
('FX', '*', '5210_txn_notify_sign.ftl', '<#-- 5210notify_sign.ftl 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0">
{
    "trade_no":"${ctx.trade_no!\'\'}",
    "amount":"${ctx.amount!\'\'}",
    "out_trade_no":"${ctx.out_trade_no!\'\'}",
    "state":"${ctx.state!\'\'}"
}', 100, '代付交易回調驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 16:11:01'),
('FX', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"out_trade_no": "${ctx.out_trade_no}",
"bank_id": "${ctx.bank_id}",
"bank_owner" : "${ctx.bank_owner}",
"account_number": "${ctx.account_number}",
"amount":  "${ctx.amount}",
"callback_url": "${ctx.callback_url}",
"sign": "${ctx.sign!\'\'}"
}', 100, '代付交易請求模板', '', '2026-02-24 10:39:49', '2026-02-24 16:51:44'),
('FX', '*', '5210_txn_req_header.ftl', '<#-- txn_req_header: 请求报文头-->
{
	"Accept": "application/json",
"Authorization": "Bearer ${svc.getMerParam(\'apitoken\',\'R2mbEHVZybFf0POR3CBQPrY3Rc78X6LxyymtX5dwZaKeOEWAt86rMlLxF6v4\')}"
}', 100, '交易請求響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 13:55:40'),
('FX', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 设置渠道金额的格式化方式 -->
{
"out_trade_no": "${ctx.chnlOrderId}",
"bank_id": "${ctx.chnlBankNum}",
"bank_owner" : "${ctx.accName}",
"account_number": "${ctx.accNum}",
"amount":  "${svc.toChnlAmt(ctx.txnAmt)}",
"callback_url": "${ctx.chnlNotifyUrl!\'\'}"
}
', 100, '代付交易請求簽名模板', '', '2026-02-24 10:39:49', '2026-02-24 16:51:18'),
('FX', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
<#if ctx.success?string == "true">
	${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}

	{
 
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!\'\'}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.data.trade_no!\'\'}",
  "chnlTxnStatusDesc" : "${ctx.message!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAW\',ctx.data.state?string!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'WITHDRAW\',ctx.data.state?string!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "OK"
	}
<#else>
	{
 
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!\'\'}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.trade_no!\'\'}",
  "chnlTxnStatusDesc" : "${ctx.message!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAWCODE\',ctx.status_code?string!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'WITHDRAWCODE\',ctx.status_code?string!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "OK"
	}
</#if>', 100, '代付交易請求響應模板', '', '2026-02-24 10:39:49', '2026-02-24 18:11:44'),
('FX', '*', '5210_txn_sync_resp_sign.ftl', '', 100, '代付交易請求響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', 'txnQry_req.ftl', '', 100, '交易查詢請求模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', 'txnQry_req_header.ftl', '<#-- txnQry_req_header.ftl -->
{
	"Accept": "application/json",
	"Authorization": "Bearer ${svc.getMerParam(\'apitoken\',\'R2mbEHVZybFf0POR3CBQPrY3Rc78X6LxyymtX5dwZaKeOEWAt86rMlLxF6v4\')}"
}', 100, '交易請求響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 13:19:45'),
('FX', '*', 'txnQry_req_sign.ftl', '', 100, '交易查詢請求簽名模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->
${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
 

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.outTradeNo!ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.data.trade_no!\'\'}",<#--
  "chnlRespCd" : "${ctx.state!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.state!\'\'}", -->
  "chnlTxnStatus" : "${ctx.data.state!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'PAY_NOTIFY\',ctx.data.state!!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'PAY_NOTIFY\',ctx.data.state!!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
  
}', 100, '交易查詢響應模板', '', '2026-02-24 10:39:49', '2026-02-24 11:29:48'),
('FX', '*', 'txnQry_resp_sign.ftl', '', 100, '交易查詢響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49'),
('FX', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->
<#--
${svc.assertNotEmpty(\'status参数不可为空\',ctx.status)}
${svc.assertEqual(\'实际支付金额与原订单金额不一致\'+(ctx.data.order_reality_amount)+\'::\'+(svc.toChnlAmt(ctx.txnAmt)), ctx.data.order_reality_amount, svc.toChnlAmt(ctx.txnAmt))}
  -->
{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.trade_no!\'\'}",<#--
  "chnlRespCd" : "${ctx.state!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.state!\'\'}", -->
  "chnlTxnStatus" : "${ctx.state!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'PAY_NOTIFY\',ctx.state!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'PAY_NOTIFY\',ctx.state!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}', 100, '交易回調模板', '', '2026-02-24 10:39:49', '2026-02-24 11:30:10'),
('FX', '*', 'txn_notify_sign.ftl', '<#-- notify_sign.ftl -->
<#setting number_format="0">
{
    "amount":"${ctx.amount!\'\'}",
    "out_trade_no":"${ctx.out_trade_no!\'\'}",
    "state":"${ctx.state!\'\'}",
    "trade_no":"${ctx.trade_no!\'\'}"
}
', 100, '交易回調驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 16:10:52'),
('FX', '*', 'txn_req.ftl', '<#-- txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"amount":  "${ctx.amount}",
"callback_url": "${ctx.callback_url}",
"out_trade_no": "${ctx.chnlOrderId}"
}', 100, '交易請求模板', '', '2026-02-24 10:39:49', '2026-02-24 15:14:33'),
('FX', '*', 'txn_req_header.ftl', '<#-- txn_req_header: 请求报文头-->
{
	"Accept": "application/json",
	"Authorization": "Bearer ${svc.getMerParam(\'apitoken\',\'R2mbEHVZybFf0POR3CBQPrY3Rc78X6LxyymtX5dwZaKeOEWAt86rMlLxF6v4\')}"
}', 100, '交易請求響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 15:14:15'),
('FX', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 设置渠道金额的格式化方式 -->
{
"amount":  "${svc.toChnlAmt(ctx.txnAmt)}",
"callback_url": "${ctx.chnlNotifyUrl!\'\'}",
"out_trade_no": "${ctx.chnlOrderId}"
}', 100, '交易請求簽名模板', '', '2026-02-24 10:39:49', '2026-02-24 15:14:25'),
('FX', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.assertEqual(\'Error: \' + (ctx.message!\'Transaction error!\'), \'true\', ctx.success?string)} 
${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
<#assign casherUrl>${svc.getCasherUrl(ctx,\'ch_qrcode\', ctx.data.qrcode!\'\',\'currentLang\',\'vn\')}</#assign>
{
  
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!\'\'}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",<#--
  "chnlTxnId" : "${ctx.rockTradeNo!\'\'}",-->
  <#--
  "codeImgUrl" : "${ctx.data.uri!\'\'}",
  "codePageUrl" : "${ctx.data.uri!\'\'}",
  -->
  "codeImgUrl" : "${casherUrl!\'\'}",
  "codePageUrl" : "${casherUrl!\'\'}",
  "qrcode": "${ctx.data.qrcode!\'\'}",
  "txnStatus" : "01",
  "txnStatusDesc" : "In processing",
  "respCode" : "0000",
  "respMsg" : "OK"
}', 100, '交易請求響應模板', '', '2026-02-24 10:39:49', '2026-02-24 15:35:34'),
('FX', '*', 'txn_sync_resp_sign.ftl', '', 100, '交易請求響應驗簽模板', '', '2026-02-24 10:39:49', '2026-02-24 10:39:49');
