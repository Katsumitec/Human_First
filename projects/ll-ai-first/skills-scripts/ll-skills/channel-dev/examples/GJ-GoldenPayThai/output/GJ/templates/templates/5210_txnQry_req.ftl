<#-- 5210_txnQry_req.ftl: 代付查詢請求報文（GET） -->
<#setting number_format="0">
{
  "id": "${ctx.id!''}",
  "mch_id": "${ctx.mch_id!''}",
  "nonce": "${ctx.nonce!''}",
  "timestamp": "${ctx.timestamp!''}",
  "sign": "${ctx.sign!''}"
}
