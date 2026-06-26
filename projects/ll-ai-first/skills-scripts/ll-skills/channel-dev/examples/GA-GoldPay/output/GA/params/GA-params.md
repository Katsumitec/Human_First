## GA

### Channel Params

| chnl_id | mchnt_cd | param_cat | param_id | param_value | orderSeq | param_desc | last_oper_id | param_st |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GA | #DEFAULT# | PARAM | notify.sync.resp | {"status":"1","error_msg":"回调成功"} | 100 | 异步通知时的响应讯息（JSON格式） |  | 1 |
| GA | * | * | sign.field.ignore.names | channel,channelId,intTxnType,refId | 100 | 忽略签名字段 |  | 1 |
| GA | * | * | sign.field.name | sign | 100 | 签名字段名称 |  | 1 |
| GA | * | * | url.txn.query | https://api.pgvn.vn-pay.co/sha256/query-order | 100 | 代收查询地址 |  | 1 |
| GA | * | * | url.txn.req | https://api.pgvn.vn-pay.co/sha256/deposit | 100 | 代收请求地址 |  | 1 |
| GA | * | 0050 | url.txn.query | https://api.pgvn.vn-pay.co/sha256/query-order | 100 | 代付查询地址（与代收共用） |  | 1 |
| GA | * | 0121 | type | 702 | 100 | 代收通道编码-银行转账 |  | 1 |
| GA | * | 014d | type | 702 | 100 | 代收通道编码-MoMo |  | 1 |
| GA | * | 014e | type | 702 | 100 | 代收通道编码-ZaloPay |  | 1 |
| GA | * | 5210 | type | 700 | 100 | 代付通道编码-银行转账 |  | 1 |
| GA | * | 5210 | url.txn.req | https://api.pgvn.vn-pay.co/sha256/withdraw | 100 | 代付请求地址 |  | 1 |
| GA | * | PARAM | sign.action.notify.check | 1 | 100 | 异步通知是否验签 |  | 1 |
| GA | * | PARAM | sign.action.notify.check.by.template | 1 | 100 | 异步通知验签是否使用模板 |  | 1 |
| GA | * | PARAM | sign.action.qry.check | 0 | 100 | 查询响应是否验签 |  | 1 |
| GA | * | PARAM | sign.action.qry.check.by.template | 0 | 100 | 查询响应验签是否使用模板 |  | 1 |
| GA | * | PARAM | sign.action.qry.sign | 1 | 100 | 查询请求是否签名 |  | 1 |
| GA | * | PARAM | sign.action.req.sign | 1 | 100 | 请求报文是否签名 |  | 1 |
| GA | * | PARAM | sign.action.resp.check | 0 | 100 | 同步响应是否验签 |  | 1 |
| GA | * | PARAM | sign.action.resp.check.by.template | 0 | 100 | 同步响应验签是否使用模板 |  | 1 |
| GA | llpp8888 | SEC | sign.key | senc.v1::senc......bw== | 100 | 签名密钥 |  | 1 |
| GA | llpp8888 | SEC | verify.key | senc.v1::senc......bw== | 100 | 验签密钥 |  | 1 |
