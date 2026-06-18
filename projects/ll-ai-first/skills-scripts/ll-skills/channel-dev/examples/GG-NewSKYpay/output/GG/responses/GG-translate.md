## GG

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| GG | * | PAY_NOTIFY | * | 01 | 处理中 | 代收回调默认，模板以 paidAmount 断言判断成功 |
| GG | * | PAY_NOTIFY | 0 | 01 | 处理中 | orderStatus=0 已建立 |
| GG | * | PAY_NOTIFY | 1 | 01 | 处理中 | orderStatus=1 處理中 |
| GG | * | PAY_NOTIFY | 3 | 10 | 交易成功 | orderStatus=3 代收成功 |
| GG | * | PAY_QRY | * | 01 | 处理中 | 默认保留处理中 |
| GG | * | PAY_QRY | 0 | 01 | 等待付款 | orderStatus=0：等待付款 |
| GG | * | PAY_QRY | 1 | 01 | 处理中 | orderStatus=1 處理中 |
| GG | * | PAY_QRY | 3 | 10 | 成功 | orderStatus=3：代收成功 |
| GG | * | PAY_QRY | 8 | 20 | 失败 | orderStatus=8：代收失败 |
| GG | * | WITHDRAW | * | 01 | 其他 | 代付同步响应默认失败，转其他 |
| GG | * | WITHDRAW | 0 | 01 | 处理中 | orderStatus=0 已建立 |
| GG | * | WITHDRAW | 1 | 01 | 提交成功，处理中 | status=1：下单成功，等待出款确认 |
| GG | * | WITHDRAW_NOTIFY | * | 01 | 处理中 | 代付回调默认，模板以 paidAmount 断言判断成功 |
| GG | * | WITHDRAW_NOTIFY | 0 | 01 | 处理中 | orderStatus=0 已建立 |
| GG | * | WITHDRAW_NOTIFY | 1 | 01 | 处理中 | orderStatus=1 處理中 |
| GG | * | WITHDRAW_NOTIFY | 3 | 10 | 交易成功 | orderStatus=3 代付成功 |
| GG | * | WITHDRAW_NOTIFY | 8 | 20 | 交易失败 | orderStatus=8 代付失敗 |
| GG | * | WITHDRAW_QRY | * | 01 | 处理中 | 默认保留处理中 |
| GG | * | WITHDRAW_QRY | 0 | 01 | 处理中 | orderStatus=0：出款处理中 |
| GG | * | WITHDRAW_QRY | 1 | 01 | 处理中 | orderStatus=1 處理中 |
| GG | * | WITHDRAW_QRY | 3 | 10 | 成功 | orderStatus=3：出款成功（推测值，建议向渠道确认） |
| GG | * | WITHDRAW_QRY | 8 | 20 | 失败 | orderStatus=8：出款失败 |
