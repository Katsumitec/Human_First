<#-- txnQry_req_sign.ftl: 代收查詢請求簽名原文 -->
<#setting number_format="0">
{
  "id": "${ctx.chnlOrderId}",
  "mch_id": "${svc.getChnlMerId()}",
  "nonce": "${rand.getStr(16)}",
  "timestamp": "${svc.nowSecs()?string}"
}
