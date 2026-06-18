<#-- txn_sync_resp.ftl: 代收下單同步響應解析模板（GG NewSKYPay）
     成功(status=1, data 存在): 使用 data.qrCode 透過自製收銀台展示，txnStatus=01
     異常(status≠1 或 data 缺失): 保持 txnStatus=01（處理中），記錄渠道錯誤訊息，不直接判失敗
     相容格式: 正常回應用 status 欄位，錯誤回應可能只有 code 欄位
-->
<#setting number_format="0">

<#if ctx.status?? && ctx.status?string == '1' && ctx.data??>
<#assign casherUrl>${svc.getCasherUrl(ctx,
'ch_qr_code_url', ctx.data.qrAddress!'',
'ch_bank_name', ctx.data.receiveType!'',
'ch_bank_no', ctx.data.receiveNum!'',
'ch_bank_owner', ctx.data.receiveAccount!'',
'ch_remark', ctx.data.remark!'',
'currentLang','vn'
)}</#assign>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.data.payOrderId!''}",
  "codeImgUrl": "${casherUrl!''}",
  "codePageUrl": "${casherUrl!''}",
  "chnlTxnStatus": "${ctx.status?string!''}",
  "chnlTxnStatusDesc": "${ctx.msg!''}",
  "txnStatus": "01",
  "txnStatusDesc": "In processing",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnStatus": "${ctx.status!ctx.code!''}",
  "chnlTxnStatusDesc": "${ctx.msg!''}",
  "txnStatus": "01",
  "txnStatusDesc": "${ctx.msg!'Error'}",
  "respCode": "9999",
  "respMsg": "${ctx.msg!'Error'}"
}
</#if>