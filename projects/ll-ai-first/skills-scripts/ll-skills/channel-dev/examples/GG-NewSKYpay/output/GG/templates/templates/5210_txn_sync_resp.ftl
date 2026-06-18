<#-- 5210_txn_sync_resp.ftl: 代付下單同步響應解析模板（GG NewSKYPay）
     status=1 且 data != null: 下單成功，txnStatus=01，等待異步通知確認
     其他情況（status!=1 或 data==null）: txnStatus=01(處理中)，respCode=9999，msg 帶渠道錯誤訊息
     相容格式: 正常回應用 status 欄位，錯誤回應可能只有 code 欄位
-->
<#setting number_format="0">
<#if ctx.status?? && ctx.status?string == "1" && ctx.data??>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "${ctx.data.payOrderId!''}",
  "chnlTxnStatus": "${ctx.status?string!''}",
  "chnlTxnStatusDesc": "${ctx.msg!''}",
  "txnStatus": "01",
  "txnStatusDesc": "处理中",
  "respCode": "0000",
  "respMsg": "OK"
}
<#else>
{
  "channel": "${svc.getChannel()!''}",
  "intTxnType": "${svc.getIntTxnType()!''}",
  "chnlMerId": "${svc.getChnlMerId()!''}",
  "chnlOrderId": "${ctx.chnlOrderId!''}",
  "chnlTxnId": "",
  "chnlTxnStatus": "${ctx.status!ctx.code!''}",
  "chnlTxnStatusDesc": "${ctx.msg!''}",
  "txnStatus": "01",
  "txnStatusDesc": "${ctx.msg!'处理中'}",
  "respCode": "9999",
  "respMsg": "${ctx.msg!'Error'}"
}
</#if>