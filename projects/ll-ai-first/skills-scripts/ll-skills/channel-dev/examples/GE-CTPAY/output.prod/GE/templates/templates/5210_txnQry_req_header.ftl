<#-- 5210_txnQry_req_header.ftl: 代付查詢 Header 模板（0050） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),'apitoken','')}"
}