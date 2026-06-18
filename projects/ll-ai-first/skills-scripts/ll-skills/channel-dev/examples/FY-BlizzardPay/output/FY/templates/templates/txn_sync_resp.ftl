<#-- txn_sync_resp: 代付 - 同步响应报文 -->
<#setting number_format="0">

<#if (ctx.code?string) == "200">
  ${svc.assertNotEmpty('data参数不可为空', ctx.data)}
  ${svc.assertNotEmpty('payData参数不可为空', ctx.data.payData)}
  
  <#assign casherUrl>${svc.getCasherUrl(ctx, 
    'ch_accountName', (ctx.data.payData.accountName)!'', 
    'ch_account', (ctx.data.payData.account)!'', 
    'ch_bankName', (ctx.data.payData.bankName)!'', 
    'ch_qrcode', (ctx.data.payData.qrcode)!'', 
    'ch_expired', (ctx.data.payData.expired?c)!'', 
    'ch_remark', (ctx.data.payData.remark)!'', 
    'currentLang', 'vn')}</#assign>

  {
    "channel": "${svc.getChannel()}",
    "intTxnType" : "${svc.getIntTxnType()!''}",
    "chnlMerId" : "${svc.getChnlMerId()!''}",
    "chnlOrderId" : "${ctx.chnlOrderId!''}",
    "codeImgUrl" : "${casherUrl!''}",
    "codePageUrl" : "${casherUrl!''}",
    "txnStatus" : "01",
    "txnStatusDesc" : "In processing",
    "respCode" : "0000",
    "respMsg" : "OK"
  }
<#else>
  {
    "channel": "${svc.getChannel()}",
    "intTxnType" : "${svc.getIntTxnType()!''}",
    "chnlMerId" : "${svc.getChnlMerId()!''}",
    "chnlOrderId" : "${ctx.chnlOrderId!''}",
    "txnStatus" : "20",
    "txnStatusDesc" : "${ctx.msg!''}",
    "respCode" : "0000",
    "respMsg" : "OK"
  }
</#if>