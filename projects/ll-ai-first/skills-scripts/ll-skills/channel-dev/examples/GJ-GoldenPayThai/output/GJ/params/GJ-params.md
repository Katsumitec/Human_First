## GJ

### Channel Params

| chnl_id | mchnt_cd | param_cat | param_id | param_value | orderSeq | param_desc | last_oper_id | param_st |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GJ | #DEFAULT# | PARAM | notify.sync.resp | success | 100 | 異步通知回覆內容（純文字 success） |  | 1 |
| GJ | * | * | chnl.currency | THB | 100 | 上游接收的幣別字母碼（THB；上游不收 764） |  | 1 |
| GJ | * | * | sign.field.ignore.names | channelId,intTxnType,refId | 100 | 簽名忽略欄位（系統內部欄位） |  | 1 |
| GJ | * | * | sign.field.name | sign | 100 | 簽名欄位名稱 |  | 1 |
| GJ | * | * | url.txn.query | https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders | 100 | 代收訂單查詢 URL（GET + Query String） |  | 1 |
| GJ | * | * | url.txn.req | https://ds-api.goldenpaythai.com/api/v1/mch/pmt-orders | 100 | 代收下單 URL |  | 1 |
| GJ | * | 0050 | url.txn.query | https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders | 100 | 代付訂單查詢 URL（GET + Query String） |  | 1 |
| GJ | * | 0121 | type | bank | 100 | 0121 通道代碼（泰國：bank） |  | 1 |
| GJ | * | 013d | type | bank | 100 | 013d 通道代碼（泰國：bank；實際可能為其他，待聯調確認） |  | 1 |
| GJ | * | 5210 | type | bank | 100 | 5210 通道代碼（泰國：bank） |  | 1 |
| GJ | * | 5210 | url.txn.req | https://ds-api.goldenpaythai.com/api/v1/mch/wdl-orders | 100 | 代付下單 URL |  | 1 |
| GJ | * | PARAM | sign.action.notify.check | 1 | 100 | 是否驗簽：異步通知 |  | 1 |
| GJ | * | PARAM | sign.action.notify.check.by.template | 1 | 100 | 異步通知驗簽是否用模板 |  | 1 |
| GJ | * | PARAM | sign.action.qry.check | 0 | 100 | 是否驗簽：查詢響應 |  | 1 |
| GJ | * | PARAM | sign.action.qry.check.by.template | 0 | 100 | 查詢響應驗簽是否用模板 |  | 1 |
| GJ | * | PARAM | sign.action.qry.sign | 1 | 100 | 是否簽名：查詢 |  | 1 |
| GJ | * | PARAM | sign.action.req.sign | 1 | 100 | 是否簽名：請求 |  | 1 |
| GJ | * | PARAM | sign.action.resp.check | 0 | 100 | 是否驗簽：同步響應（暫關，聯調確認後再開） |  | 1 |
| GJ | * | PARAM | sign.action.resp.check.by.template | 0 | 100 | 同步響應驗簽是否用模板 |  | 1 |
| GJ | 4133 | SEC | sign.key | senc.v1::senc......GA== | 100 | API Token / 簽名密鑰（見 email） |  | 1 |
| GJ | 4133 | SEC | verify.key | senc.v1::senc......GA== | 100 | 驗簽密鑰（同 sign.key） |  | 1 |
