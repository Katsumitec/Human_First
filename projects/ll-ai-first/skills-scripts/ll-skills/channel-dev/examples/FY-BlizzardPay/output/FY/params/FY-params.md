## FY

### Channel Params

| chnl_id | mchnt_cd | param_cat | param_id | param_value | orderSeq | param_desc | last_oper_id | param_st |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FY | #DEFAULT# | PARAM | notify.sync.resp | SUCCESS | 100 | 异步通知时的响应讯息 |  | 1 |
| FY | * | * | sign.field.ignore.names | channel,intTxnType,refId | 100 | 忽略签名字段 |  | 1 |
| FY | * | * | sign.field.name | sign | 100 | 签名字段 |  | 1 |
| FY | * | * | url.txn.query | https://api.blizzardpay.pw/order/query | 100 | 代付请求地址 |  | 1 |
| FY | * | * | url.txn.req | https://api.blizzardpay.pw/order/v2/create | 100 | 代付请求地址 |  | 1 |
| FY | * | 0010 | chnl.qryType | 003 | 100 | 签名字段 |  | 1 |
| FY | * | 0050 | chnl.qryType | 001 | 100 | 签名字段 |  | 1 |
| FY | * | 0050 | url.txn.query | https://api.blizzardpay.pw/withdraw/query | 100 | 代付请求地址 |  | 1 |
| FY | * | 0121 | casher.url | http://paygate.dev-ai.org:9090/gateway-onl/casher/casher.fy.0121.do | 100 | GW收银台地址 |  | 1 |
| FY | * | 5210 | url.txn.req | https://api.blizzardpay.pw/withdraw/apply | 100 | 代付请求地址 |  | 1 |
| FY | * | PARAM | sign.action.notify.check | 1 | 100 | 異步通知 |  | 1 |
| FY | * | PARAM | sign.action.notify.check.by.template | 1 | 100 | 异步通知的签名是否使用模板 |  | 1 |
| FY | * | PARAM | sign.action.qry.check | 0 | 100 | 是否驗簽：查询同步響應 |  | 1 |
| FY | * | PARAM | sign.action.qry.check.by.template | 0 | 100 | 是否使用模板驗簽：查询同步響應 |  | 1 |
| FY | * | PARAM | sign.action.qry.sign | 1 | 100 | 是否簽名：查询 |  | 1 |
| FY | * | PARAM | sign.action.req.sign | 1 | 100 | 是否簽名：請求 |  | 1 |
| FY | * | PARAM | sign.action.resp.check | 0 | 100 | 是否驗簽：請求同步響應 |  | 1 |
| FY | * | PARAM | sign.action.resp.check.by.template | 0 | 100 | 请求同步响应的验签的待签字串是否使用模板 |  | 1 |
| FY | 10977 | SEC | sign.key | senc.v1::4aSJWFNFo66D7gXD/XEbI67QjxBAuZRYerEnhsUo/Iuvdkpt5qK2Ew== | 100 |  |  | 1 |
| FY | 10977 | SEC | verify.key | senc.v1::4aSJWFNFo66D7gXD/XEbI67QjxBAuZRYerEnhsUo/Iuvdkpt5qK2Ew== | 100 |  |  | 1 |
