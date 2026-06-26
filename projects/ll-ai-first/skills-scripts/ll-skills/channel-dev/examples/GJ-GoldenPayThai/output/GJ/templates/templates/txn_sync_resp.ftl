<#-- txn_sync_resp.ftl: 代收同步响应 -> 我方格式（上游返回 url 供用户跳转） -->
<#setting number_format="0"/>

${svc.assertNotEmpty("payload 为空", ctx.payload)}
${svc.assertEqual("上游返回 code != 200：" + ((ctx.errors.message)!"") + ((ctx.payload.message)!""),
  "200",
  (ctx.code?string)!""
)}

{
  "channel": "${svc.getChannel()!""}",
  "intTxnType": "${svc.getIntTxnType()!""}",
  "chnlMerId": "${svc.getChnlMerId()!""}",
  "chnlOrderId": "${ctx.chnlOrderId!""}",
  "chnlTxnId": "${(ctx.payload.id)!""}",
  "codeImgUrl": "${(ctx.payload.url)!""}",
  "codePageUrl": "${(ctx.payload.url)!""}",
  "chnlTxnStatus": "${(ctx.payload.status?string)!""}",
  "chnlTxnStatusDesc": "status=${(ctx.payload.status?string)!""}",
  "txnStatus": "01",
  "txnStatusDesc": "处理中",
  "respCode": "0000",
  "respMsg": "Processed"
}