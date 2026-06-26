<#-- 014d_txnQry_req_header.ftl: 代收查詢 Header 模板（014d） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),'apitoken','')}"
}