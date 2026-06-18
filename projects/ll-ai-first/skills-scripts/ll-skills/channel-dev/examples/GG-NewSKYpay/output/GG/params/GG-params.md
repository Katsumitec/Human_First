## GG

### Channel Params

| chnl_id | mchnt_cd | param_cat | param_id | param_value | orderSeq | param_desc | last_oper_id | param_st |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GG | #DEFAULT# | PARAM | notify.sync.resp | success | 100 | 异步通知回复内容（渠道要求纯文字 success） |  | 1 |
| GG | * | * | bankType | VIETBANK | 100 | 代收银行代码（需根据渠道可用银行清单配置，如 VIETBANK/VCB/MB 等） |  | 1 |
| GG | * | * | casher.url | http://paygate.dev-ai.org:9090/gateway-onl/casher/casher.xx.vn.0121.do | 100 | 0137扫码收银台地址 |  | 1 |
| GG | * | * | sign.field.ignore.names | channel,channelId,intTxnType,refId | 100 | 不参与签名的系统字段 |  | 1 |
| GG | * | * | sign.field.name | sign | 100 | 签名字段名称 |  | 1 |
| GG | * | * | url.txn.query | http://api.newsky.vip/hpay/dt/vnd/query | 100 | 代收查询地址 |  | 1 |
| GG | * | * | url.txn.req | http://api.newsky.vip/hpay/dt/vnd/ct | 100 | 代收下单地址 |  | 1 |
| GG | * | * | withdrawQueryUrl | http://paygate.dev-ai.org:9090/gateway-onl/txnNotify/GG/0098/do | 100 | 代收请求地址 |  | 1 |
| GG | * | 0050 | url.txn.query | http://api.newsky.vip/hpay/wd/vnd/query | 100 | 代付查询地址 |  | 1 |
| GG | * | 0098 | sign.action.notify.check | 0 | 100 | 異步通知 |  | 1 |
| GG | * | 0098 | sign.action.notify.check.by.template | 0 | 100 | 异步通知的签名是否使用模板 |  | 1 |
| GG | * | 5210 | url.txn.query | http://api.newsky.vip/hpay/wd/vnd/query | 100 | 代付查单地址 |  | 1 |
| GG | * | 5210 | url.txn.req | http://api.newsky.vip/hpay/wd/vnd/ct | 100 | 代付下单地址 |  | 1 |
| GG | * | PARAM | sign.action.notify.check | 1 | 100 | 异步通知是否验签 |  | 1 |
| GG | * | PARAM | sign.action.notify.check.by.template | 1 | 100 | 异步通知验签是否用模板 |  | 1 |
| GG | * | PARAM | sign.action.qry.check | 0 | 100 | 查询响应是否验签 |  | 1 |
| GG | * | PARAM | sign.action.qry.check.by.template | 0 | 100 | 查询响应验签是否使用模板 |  | 1 |
| GG | * | PARAM | sign.action.qry.sign | 1 | 100 | 查询是否签名 |  | 1 |
| GG | * | PARAM | sign.action.req.sign | 1 | 100 | 请求报文是否签名 |  | 1 |
| GG | * | PARAM | sign.action.req.sign.by.template | 1 | 100 | 请求的签名使用模板 |  | 1 |
| GG | * | PARAM | sign.action.resp.check | 0 | 100 | 同步响应是否验签 |  | 1 |
| GG | * | PARAM | sign.action.resp.check.by.template | 0 | 100 | 同步响应验签是否使用模板 |  | 1 |
| GG | 30038 | SEC | sign.key | senc.v1::senc......O/L1 | 100 | 签名密钥（商户后台金钥+客服验证金钥） |  | 1 |
| GG | 30038 | SEC | verify.key | senc.v1::senc......O/L1 | 100 | 验签密钥（同sign.key） |  | 1 |
