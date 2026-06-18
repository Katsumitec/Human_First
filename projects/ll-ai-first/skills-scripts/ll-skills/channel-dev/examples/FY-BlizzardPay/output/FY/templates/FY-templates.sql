REPLACE INTO `icpay`.`tbl_chnl_template` (
    `catalog`, `class_name`, `template_id`, `template`, `orderSeq`, `memo`, `last_oper_id`, `rec_crt_ts`, `rec_upd_ts`
) VALUES
('FY', '*', '5210_txnQry_req.ftl', '<#-- 5210_txnQry_req: 代付查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
{
"appId": "${svc.getChnlMerId()}",
"outOrderNo": "${ctx.chnlOrderId}",
"sign": "${ctx.sign}",
}', 100, ' 交易查詢請求模板', '', '2026-02-25 16:03:24', '2026-02-25 18:23:27'),
('FY', '*', '5210_txnQry_req_sign.ftl', '<#-- 5210_txnQry_req_sign: 交易查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
{
"appId": "${svc.getChnlMerId()}",
"outOrderNo": "${ctx.chnlOrderId}"
}', 100, '代付交易查詢請求簽名模板', '', '2026-02-25 16:03:24', '2026-02-25 18:23:27'),
('FY', '*', '5210_txnQry_resp.ftl', '<#-- 5210_txnQry_resp: 交易查詢 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->
${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
<#if (ctx.data.orderStatus?c)! == "1">
${svc.assertEqual(\'實際支付金額與原訂單金額不一致 \' + (ctx.data.apply?string!\'0\') + \'::\' + svc.toChnlAmt(ctx.txnAmt), (ctx.data.apply?string)!\'0\', svc.toChnlAmt(ctx.txnAmt))}
</#if>
{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.outTradeNo!ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.data.orderNo!\'\'}",<#--
  "chnlRespCd" : "${ctx.orderStatus!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.orderStatus!\'\'}", -->
  "chnlTxnStatus" : "${ctx.data.orderStatus!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAW_QRY\',ctx.data.orderStatus!!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'WITHDRAW_QRY\',ctx.data.orderStatus!!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}



', 100, '代付交易查詢響應模板', '', '2026-02-25 16:03:24', '2026-02-26 16:01:07'),
('FY', '*', '5210_txnQry_resp_sign.ftl', '', 100, '代付交易查詢響應驗簽模板', '', '2026-02-25 16:03:24', '2026-02-25 16:03:24'),
('FY', '*', '5210_txn_notify.ftl', '<#-- 5210txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0.00\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->

${svc.assertNotEmpty(\'status参数不可为空\',ctx.orderStatus)}
${svc.assertEqual(\'实际支付金额与原订单金额不一致\'+(ctx.amount?string)+\'::\'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.amount?string, svc.toChnlAmt(ctx.txnAmt)?string)}


{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.orderNo!\'\'}",<#--
  "chnlRespCd" : "${ctx.orderStatus!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.orderStatus!\'\'}", -->
  "chnlTxnStatus" : "${ctx.orderStatus!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAW_NOTIFY\',ctx.orderStatus!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'WITHDRAW_NOTIFY\',ctx.orderStatus!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}', 100, '代付交易回調模板', '', '2026-02-25 16:03:24', '2026-02-26 15:48:20'),
('FY', '*', '5210_txn_notify_sign.ftl', '<#-- 5210notify_sign.ftl 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
{
    "appId":"${ctx.appId!\'\'}",
    "orderNo":"${ctx.orderNo!\'\'}",
    "outOrderNo":"${ctx.outOrderNo!\'\'}",
    "currency":"${ctx.currency!\'\'}",
    "amount":"${ctx.amount!\'\'}",
    "orderStatus":"${ctx.orderStatus!\'\'}",
    "message":"${ctx.message!\'\'}"
}', 100, '代付交易回調驗簽模板', '', '2026-02-25 16:03:24', '2026-02-25 18:22:44'),
('FY', '*', '5210_txn_req.ftl', '<#-- 5210_txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"appId": "${ctx.appId}",
"outOrderNo": "${ctx.outOrderNo}",
"amount": "${ctx.amount}",
"bankName": "${ctx.bankName}",
"bankUserName": "${ctx.bankUserName}",
"bankCard": "${ctx.bankCard}",
"currency": "${ctx.currency}",
"callbackUrl": "${ctx.chnlNotifyUrl!\'\'}",
"sign": "${ctx.sign}"
}', 100, '代付交易請求模板', '', '2026-02-25 16:03:24', '2026-02-26 14:19:48'),
('FY', '*', '5210_txn_req_sign.ftl', '<#-- 5210_txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.00\')} <#-- 设置渠道金额的格式化方式 -->
{
"appId": "${svc.getChnlMerId()}",
"outOrderNo": "${ctx.chnlOrderId}",
"amount": "${svc.toChnlAmt(ctx.txnAmt)}",
"bankName": "${ctx.chnlBankNum!\'\'}",
"bankUserName": "${ctx.accName!\'\'}",
"bankCard": "${ctx.accNum!\'\'}",
"currency": "VND",
"callbackUrl": "${ctx.chnlNotifyUrl!\'\'}"
}', 100, '代付交易請求簽名模板', '', '2026-02-25 16:03:24', '2026-02-26 14:19:33'),
('FY', '*', '5210_txn_sync_resp.ftl', '<#-- 5210_txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
<#-- 
${svc.assertEqual(\'Error: \' + (ctx.msg!\'Transaction error!\'), \'200\', ctx.code?string)} 
${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}
 -->
{
 
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!\'\'}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnStatusDesc" : "${ctx.msg!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'WITHDRAW\',ctx.code?string!\'\')!\'01\'}",
  "txnStatusDesc" : "${ctx.msg!\'\'} - ${svc.getTranslatedMsg(\'WITHDRAW\', (ctx.code?string)!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "OK"
}', 100, '代付交易請求響應模板', '', '2026-02-25 16:03:24', '2026-02-26 14:51:34'),
('FY', '*', '5210_txn_sync_resp_sign.ftl', '', 100, '代付交易請求響應驗簽模板', '', '2026-02-25 16:03:24', '2026-02-25 16:03:24'),
('FY', '*', 'txnQry_req.ftl', '<#-- txnQry_req: 代付查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
{
"appId": "${svc.getChnlMerId()}",
"outTradeNo": "${ctx.chnlOrderId}",
"sign": "${ctx.sign}",
}
', 100, '交易查詢請求模板', '', '2026-02-25 16:03:24', '2026-02-25 16:17:36'),
('FY', '*', 'txnQry_req_sign.ftl', '<#-- txnQry_req_sign: 交易查詢 - 请求报文  (我方请求报文 转成 渠道请求报文)-->
{
"appId": "${svc.getChnlMerId()}",
"outTradeNo": "${ctx.chnlOrderId}"
}', 100, '交易查詢請求簽名模板', '', '2026-02-25 16:03:24', '2026-02-25 16:17:37'),
('FY', '*', 'txnQry_resp.ftl', '<#-- txnQry_resp.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')}
${svc.setChnlAmtUnitStr(\'1.0\')}
${svc.setChnlAmtFormat(\'0\')}
${svc.setLocalAmtFormat(\'0\')}

${svc.assertNotEmpty(\'data参数不可为空\',ctx.data)}

<#if (ctx.data.paySuccess?c)! == "true">
  <#-- Fixed the Chinese parenthesis here -->
  ${svc.assertEqual(\'實際支付金額與原訂單金額不一致 \' + (ctx.data.amountTrue!0) + \'::\' + svc.toChnlAmt(ctx.txnAmt), (ctx.data.amountTrue?string)!\'0\', svc.toChnlAmt(ctx.txnAmt))}
</#if>

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.data.orderNo!\'\'}",
  "chnlTxnStatus" : "${(ctx.data.paySuccess?string)!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'PAY_QRY\', (ctx.data.paySuccess?string)!\'\')!\'01\'}",
"txnStatusDesc" : "${svc.getTranslatedMsg(\'PAY_QRY\', (ctx.data.paySuccess?string)!\'\')!\'异常\'}",
  "respMsg" : "Notified"
}', 100, '交易查詢響應模板', '', '2026-02-25 16:03:24', '2026-02-26 20:11:45'),
('FY', '*', 'txnQry_resp_sign.ftl', '', 100, '交易查詢響應驗簽模板', '', '2026-02-25 16:03:24', '2026-02-25 16:03:24'),
('FY', '*', 'txn_notify.ftl', '<#-- txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setChnlAmtFormat(\'0.00\')} <#-- 设置渠道金额的格式化方式 -->
${svc.setLocalAmtFormat(\'0\')} <#-- 设置本地金额的格式化 -->

${svc.assertNotEmpty(\'status参数不可为空\',ctx.payStatus)}
${svc.assertEqual(\'实际支付金额与原订单金额不一致\'+(ctx.amountTrue?string)+\'::\'+(svc.toChnlAmt(ctx.txnAmt)?string), ctx.amountTrue?string, svc.toChnlAmt(ctx.txnAmt)?string)}

{
  "channel" : "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()}",
  "chnlMerId" : "${ctx.merchantNo!svc.getChnlMerId()!\'\'}",
  "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
  "chnlTxnId" : "${ctx.orderNo!\'\'}",<#--
  "chnlRespCd" : "${ctx.payStatus!\'\'}",
  "chnlRespMsg" : "", 
  "chnlTxnStatusDesc" : "${ctx.payStatus!\'\'}", -->
  "chnlTxnStatus" : "${ctx.payStatus!\'\'}",
  "txnStatus" : "${svc.getTranslatedCode(\'PAY_NOTIFY\',ctx.payStatus!\'\')!\'01\'}",
  "txnStatusDesc" : "${svc.getTranslatedMsg(\'PAY_NOTIFY\',ctx.payStatus!\'\')!\'异常\'}",
  "respCode" : "0000",
  "respMsg" : "Notified"
}
', 100, '交易回調模板', '', '2026-02-25 16:03:24', '2026-02-26 10:55:44'),
('FY', '*', 'txn_notify_sign.ftl', '<#-- notify_sign.ftl -->
<#-- channelId 寫死的如果有換要改 -->
{
    "appId":"${ctx.appId!\'\'}",
    "outTradeNo":"${ctx.outTradeNo!\'\'}",
    "orderNo":"${ctx.orderNo!\'\'}",
    "channelId":"110",
    "amount":"${ctx.amount!\'\'}",
    "amountTrue":"${ctx.amountTrue!\'\'}",
    "payStatus":"${ctx.payStatus!\'\'}"
}', 100, '交易回調驗簽模板', '', '2026-02-25 16:03:24', '2026-02-26 15:04:06'),
('FY', '*', 'txn_req.ftl', '<#-- txn_req: 请求报文  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
{
"appId": "${ctx.appId}",
"outTradeNo": "${ctx.outTradeNo}",
"channelId": "110",
"amount": "${ctx.amount}",
"callbackUrl": "${ctx.callbackUrl}",
"successUrl": "${ctx.successUrl}",
"clientUserIp": "${ctx.clientUserIp}",
"clientUserId": "${ctx.clientUserId}",
"sign": "${ctx.sign!\'\'}"
}', 100, '交易請求模板', '', '2026-02-25 16:03:24', '2026-02-25 17:02:02'),
('FY', '*', 'txn_req_sign.ftl', '<#-- txn_req_sign: 请求报文签名  (我方请求报文 转成 渠道请求报文)-->
<#setting number_format="0"> <#-- 告诉 FreeMarker 将所有数字按原样输出 -->
${svc.setChnlAmtUnitStr(\'1.0\')} <#-- 设置渠道金额的单位:1.0=元 -->
${svc.setCurrencyByCode(\'704\')} <#-- 设置交易币别 -->
${svc.setChnlAmtFormat(\'0.##\')} <#-- 设置渠道金额的格式化方式 -->
{
"appId": "${svc.getChnlMerId()}",
"outTradeNo": "${ctx.chnlOrderId}",
"channelId": "110",
"amount": "${svc.toChnlAmt(ctx.txnAmt)}",
"callbackUrl": "${ctx.chnlNotifyUrl!\'\'}",
"successUrl": "${ctx.chnlPageRetUrl!\'\'}",
"clientUserIp": "${ctx.clientIp!rand.getRandomIp()}",
"clientUserId": "${rand.getInt(1000000,9999999)}"

}', 100, '交易請求簽名模板', '', '2026-02-25 16:03:24', '2026-02-26 11:51:57'),
('FY', '*', 'txn_sync_resp.ftl', '<#-- txn_sync_resp: 代付 - 同步响应报文 -->
<#setting number_format="0">

<#if (ctx.code?string) == "200">
  ${svc.assertNotEmpty(\'data参数不可为空\', ctx.data)}
  ${svc.assertNotEmpty(\'payData参数不可为空\', ctx.data.payData)}
  
  <#assign casherUrl>${svc.getCasherUrl(ctx, 
    \'ch_accountName\', (ctx.data.payData.accountName)!\'\', 
    \'ch_account\', (ctx.data.payData.account)!\'\', 
    \'ch_bankName\', (ctx.data.payData.bankName)!\'\', 
    \'ch_qrcode\', (ctx.data.payData.qrcode)!\'\', 
    \'ch_expired\', (ctx.data.payData.expired?c)!\'\', 
    \'ch_remark\', (ctx.data.payData.remark)!\'\', 
    \'currentLang\', \'vn\')}</#assign>

  {
    "channel": "${svc.getChannel()}",
    "intTxnType" : "${svc.getIntTxnType()!\'\'}",
    "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
    "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
    "codeImgUrl" : "${casherUrl!\'\'}",
    "codePageUrl" : "${casherUrl!\'\'}",
    "txnStatus" : "01",
    "txnStatusDesc" : "In processing",
    "respCode" : "0000",
    "respMsg" : "OK"
  }
<#else>
  {
    "channel": "${svc.getChannel()}",
    "intTxnType" : "${svc.getIntTxnType()!\'\'}",
    "chnlMerId" : "${svc.getChnlMerId()!\'\'}",
    "chnlOrderId" : "${ctx.chnlOrderId!\'\'}",
    "txnStatus" : "20",
    "txnStatusDesc" : "${ctx.msg!\'\'}",
    "respCode" : "0000",
    "respMsg" : "OK"
  }
</#if>', 100, '交易請求響應模板', '', '2026-02-25 16:03:24', '2026-02-26 21:25:27'),
('FY', '*', 'txn_sync_resp_sign.ftl', '', 100, '交易請求響應驗簽模板', '', '2026-02-25 16:03:24', '2026-02-25 16:03:24');
