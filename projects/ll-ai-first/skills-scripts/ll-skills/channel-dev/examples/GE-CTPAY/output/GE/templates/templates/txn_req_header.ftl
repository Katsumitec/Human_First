<#-- txnQry_req_header.ftl: 代收查詢請求 Header 模板（0010） -->
<#-- GET 查詢也需要 Bearer Token 認證 -->
{
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer ${svc.getMerSecParam(svc.getChnlMerId(),'apitoken','')}"
}