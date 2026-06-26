## GE

### Channel Params

| chnl_id | mchnt_cd | param_cat | param_id | param_value | orderSeq | param_desc | last_oper_id | param_st |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GE | #DEFAULT# | PARAM | notify.sync.resp | ok | 100 | 異步通知回覆純文字 ok |  | 1 |
| GE | * | * | casher.timeout | 300 | 100 | 收銀台有效期（秒） |  | 1 |
| GE | * | * | sign.field.ignore.names | channel,channelId,intTxnType,refId,sign | 100 | 不參與簽名的系統欄位 |  | 1 |
| GE | * | * | sign.field.name | sign | 100 | 簽名欄位名稱 |  | 1 |
| GE | * | * | sign.field.name.verify | sign | 100 | 簽名欄位名稱 |  | 1 |
| GE | * | * | url.txn.query | https://tianciv420428.com/api/transaction/${chnlOrderId} | 100 | 代收查詢 URL（GET 路徑參數） |  | 1 |
| GE | * | * | url.txn.req | https://tianciv420428.com/api/transaction | 100 | 代收請求 URL |  | 1 |
| GE | * | 0050 | url.txn.query | https://tianciv420428.com/api/payment/${chnlOrderId} | 100 | 代付查詢 URL（GET 路徑參數） |  | 1 |
| GE | * | 0121 | casher.url | http://paygate.dev-ai.org:9090/gateway-onl/casher/casher.ga.0121.do | 100 | 自製收銀台地址（QR碼模式） |  | 1 |
| GE | * | 014d | casher.url | http://paygate.dev-ai.org:9090/gateway-onl/casher/casher.ga.0121.do | 100 | 014d 自製收銀台地址 |  | 1 |
| GE | * | 014e | casher.url | http://paygate.dev-ai.org:9090/gateway-onl/casher/casher.ga.0121.do | 100 | 014e 自製收銀台地址 |  | 1 |
| GE | * | 5210 | sign.action.req.sign | 1 | 100 | 請求報文簽名（代收代付均帶 sign） |  | 1 |
| GE | * | 5210 | url.txn.req | https://tianciv420428.com/api/payment | 100 | 代付請求 URL |  | 1 |
| GE | * | PARAM | sign.action.notify.check | 1 | 100 | 異步通知驗簽 |  | 1 |
| GE | * | PARAM | sign.action.notify.check.by.template | 1 | 100 | 異步通知驗簽使用模板 |  | 1 |
| GE | * | PARAM | sign.action.qry.check | 0 | 100 | 查詢響應不驗簽 |  | 1 |
| GE | * | PARAM | sign.action.qry.check.by.template | 0 | 100 | 查詢響應不用模板驗簽 |  | 1 |
| GE | * | PARAM | sign.action.qry.sign | 0 | 100 | 查詢 GET 不簽名 |  | 1 |
| GE | * | PARAM | sign.action.req.sign | 0 | 100 | 請求報文簽名（代收代付均帶 sign） |  | 1 |
| GE | * | PARAM | sign.action.resp.check | 0 | 100 | 同步響應不驗簽 |  | 1 |
| GE | * | PARAM | sign.action.resp.check.by.template | 0 | 100 | 同步響應驗簽不用模板 |  | 1 |
| GE | vvdd222 | SEC | apitoken | senc.v1::senc......3Q== | 100 | api_token，用於 Bearer Token Header |  | 1 |
| GE | vvdd222 | SEC | sign.key | senc.v1::senc......C/4= | 100 | 簽名密鑰 = api_token + notify_token 直接拼接 |  | 1 |
| GE | vvdd222 | SEC | verify.key | senc.v1::senc......C/4= | 100 | 驗簽密鑰（與 sign.key 相同） |  | 1 |
