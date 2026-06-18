<#-- txn_sync_resp.ftl: 代收同步響應解析模板（0121 純卡網關） -->
<#-- 同步響應表示提交成功，txnStatus 固定 01（處理中） -->
<#-- 透過 getCasherUrl 傳遞 data.qrcode 給自製收銀台 -->
<#setting number_format="0">
<#assign casherUrl>${svc.getCasherUrl(ctx, 'ch_qrCodeUrl', ctx.data.qrcode!'')}</#assign>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.data.trade_no!''}",
  "codeImgUrl": "${casherUrl!''}",
  "codePageUrl": "${casherUrl!''}",
  "chnlTxnStatus": "${ctx.success?string!''}",
  "chnlTxnStatusDesc": "${ctx.success?string!''}",
  "txnStatus": "01",
  "txnStatusDesc": "處理中",
  "respCode": "0000",
  "respMsg": "Processed"
}