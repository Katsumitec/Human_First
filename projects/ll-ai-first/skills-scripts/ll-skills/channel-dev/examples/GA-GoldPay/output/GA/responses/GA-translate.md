## GA

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| GA | * | PAY_NOTIFY | * | 01 | 其他狀態(处理中) | 通配规则 |
| GA | * | PAY_NOTIFY | 1 | 10 | 交易成功 | status=1，代收完成 |
| GA | * | PAY_QRY | * | 01 | 其他，保留处理中 | 通配规则 |
| GA | * | PAY_QRY | S | 10 | 交易成功 | 已处理 |
| GA | * | WITHDRAW | * | 01 | 处理中 | status+error_code |
| GA | * | WITHDRAW | 0E00004 | 20 | 请求金额无效 | status+error_code: 0+E00006 |
| GA | * | WITHDRAW | 0E00006 | 20 | 商户馀额不足 | status+error_code: 0+E00006 |
| GA | * | WITHDRAW | 0E00008 | 20 | 系统维护中 | status+error_code: 0+E00006 |
| GA | * | WITHDRAW | 0E00014 | 20 | 此商户没有可用的渠道，商户帐号设置错误 | status+error_code: 0+E00006 |
| GA | * | WITHDRAW | 1 | 01 | 处理中 | status+error_code: status=1提交成功，等待处理 |
| GA | * | WITHDRAW_NOTIFY | * | 01 | 其他狀態(处理中) | 通配规则 |
| GA | * | WITHDRAW_NOTIFY | 0 | 20 | 交易失败 | status=0，代付失败 |
| GA | * | WITHDRAW_NOTIFY | 1 | 10 | 交易成功 | status=1，代付完成 |
| GA | * | WITHDRAW_QRY | * | 01 | 其他，保留处理中 | 通配规则 |
| GA | * | WITHDRAW_QRY | C | 20 | 交易失败 | 已退款 |
| GA | * | WITHDRAW_QRY | F | 20 | 交易失败 | 失败或驳回 |
| GA | * | WITHDRAW_QRY | Y | 10 | 交易成功 | 已出款 |
