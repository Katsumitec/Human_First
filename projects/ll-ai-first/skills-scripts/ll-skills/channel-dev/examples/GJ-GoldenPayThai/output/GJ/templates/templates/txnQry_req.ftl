<#-- txnQry_req.ftl: 代收查詢請求報文（GET 時系統會轉為 Query String） -->
<#setting number_format="0">
{
  "id": "${ctx.id!''}",
  "mch_id": "${ctx.mch_id!''}",
  "nonce": "${ctx.nonce!''}",
  "timestamp": "${ctx.timestamp!''}",
  "sign": "${ctx.sign!''}"
}
