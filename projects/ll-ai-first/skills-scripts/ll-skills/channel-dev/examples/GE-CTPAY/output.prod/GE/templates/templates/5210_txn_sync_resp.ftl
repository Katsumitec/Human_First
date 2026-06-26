<#-- 5210_txn_sync_resp.ftl: 代付同步響應解析模板（5210） -->
<#-- 同步響應以 success Boolean 判斷提交成功/失敗 -->
<#-- success=true → txnStatus=01（處理中，等待異步通知） -->
<#-- success=false → txnStatus=20（提交失敗） -->
<#setting number_format="0">
{
  "channel": "${(svc.getChannel())!''}",
  "intTxnType": "${(svc.getIntTxnType())!''}",
  "chnlMerId": "${(svc.getChnlMerId())!''}",
  "chnlOrderId": "${(ctx.data.out_trade_no)!(ctx.chnlOrderId)!''}",
  "chnlTxnId": "${(ctx.data.trade_no)!''}",
  "chnlTxnStatus": "${(ctx.data.state)!''}",
  "chnlTxnStatusDesc": "${(ctx.data.state)!''}",
  <#assign successStr = (ctx.success?string)!'' />
  <#assign statusCodeStr = (ctx.status_code?string)!'' />
  <#assign statusCode = successStr + statusCodeStr />
  "txnStatus": "${(svc.getTranslatedCode('WITHDRAW', statusCode))!'01'}",
  "txnStatusDesc": "${(svc.getTranslatedMsg('WITHDRAW', statusCode))!'处理中'}",
  "respCode": "0000",
  "respMsg": "Processed"
}