<#-- 5210_txn_req_header.ftl: 代付請求 Header 模板（5210） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),'apitoken','')}"
}