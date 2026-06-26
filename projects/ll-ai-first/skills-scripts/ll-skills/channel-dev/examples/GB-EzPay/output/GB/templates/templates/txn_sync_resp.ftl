<#-- txn_sync_resp: 代付 - 同步响应报文 (渠道同步响应报文 转成 我方同步响应报文) -->
<#setting number_format="0">
${svc.assertEqual('Error: ' + (ctx.msg!'Transaction error!'), '0', ctx.code?string)} 
${svc.assertNotEmpty('data参数不可为空',ctx.data)}
<#assign casherUrl>${svc.getCasherUrl(ctx, 
  'ch_bank_code', ctx.data.bank_code!'',
  'ch_bank_name', ctx.data.bank_name!'',
  'ch_bank_no', ctx.data.bank_no!'',
  'ch_bank_owner', ctx.data.bank_owner!'',
  'ch_bank_from', ctx.data.bank_from!'',
  'ch_qr_code', ctx.data.qr_code!'',
  'ch_remark', ctx.data.remark!'',
   'lang', 'vn')}</#assign>
{
  
  "channel": "${svc.getChannel()}",
  "intTxnType" : "${svc.getIntTxnType()!''}",
  "chnlMerId" : "${svc.getChnlMerId()!''}",
  "chnlOrderId" : "${ctx.chnlOrderId!''}",<#--
  "chnlTxnId" : "${ctx.orderNo!''}",
  
  "codeImgUrl" : "${ctx.data.view_url!''}",
  "codePageUrl" : "${ctx.data.view_url!''}",
  -->
  "codeImgUrl" : "${casherUrl!''}",
  "codePageUrl" : "${casherUrl!''}",
  
  "txnStatus" : "01",
  "txnStatusDesc" : "In processing",
  "respCode" : "0000",
  "respMsg" : "OK"
}