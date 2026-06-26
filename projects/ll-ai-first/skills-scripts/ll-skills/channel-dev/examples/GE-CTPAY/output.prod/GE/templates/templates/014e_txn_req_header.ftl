<#-- 014e_txn_req_header.ftl: 代收請求 Header 模板（014e 網銀掃碼） -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),'apitoken','')}"
}