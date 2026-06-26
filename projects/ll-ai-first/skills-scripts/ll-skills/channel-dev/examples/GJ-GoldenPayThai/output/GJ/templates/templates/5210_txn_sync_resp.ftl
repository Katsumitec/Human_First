<#-- 5210_txn_sync_resp.ftl: 代付同步响应 -> 我方格式 -->
<#setting number_format="0">
<#if ctx.code?? && ctx.code?string == "200" && ctx.payload??>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.payload.id!''}",
  "chnlRespCd": "${ctx.code?string!''}",
  "chnlRespMsg": "${(ctx.payload.message)!'OK'}",
  "chnlTxnStatus": "${ctx.payload.status?string!''}",
  "chnlTxnStatusDesc": "status=${ctx.payload.status?string!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW', ctx.code?string!'')!'01'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW', ctx.code?string!'')!'提交成功处理中'}",
  "respCode": "0000",
  "respMsg": "Processed"
}
<#else>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "",
  "chnlRespCd": "${ctx.code?string!''}",
  "chnlRespMsg": "${(ctx.errors.message)!(ctx.payload.message)!''}",
  "chnlTxnStatus": "${ctx.code?string!''}",
  "chnlTxnStatusDesc": "${(ctx.errors.message)!(ctx.payload.message)!''}",
  "txnStatus": "${svc.getTranslatedCode('WITHDRAW', ctx.code?string!'')!'20'}",
  "txnStatusDesc": "${svc.getTranslatedMsg('WITHDRAW', ctx.code?string!'')!'失败'}",
  "respCode": "0000",
  "respMsg": "Processed"
}
</#if>