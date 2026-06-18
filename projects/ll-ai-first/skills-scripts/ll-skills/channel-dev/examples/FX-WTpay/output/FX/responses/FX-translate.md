## FX

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| FX | * | PAY_NOTIFY | * | 01 | 其他狀態(处理中) | 未定義交易狀態 |
| FX | * | PAY_NOTIFY | completed | 10 | 交易成功 |  |
| FX | * | PAY_QRY | * | 01 | 其他，保留处理中 |  |
| FX | * | PAY_QRY | completed | 10 | 交易成功 | 成功 |
| FX | * | PAY_QRY | failed | 20 | 交易失败 | 失败 |
| FX | * | PAY_QRY | refund | 20 | 交易失败 | 冲回 |
| FX | * | PAY_QRY | reject | 20 | 交易失败 | 拒绝 |
| FX | * | WITHDRAW | * | 01 | 处理中 | 其它异常，保留处理中 |
| FX | * | WITHDRAWCODE | 422 | 20 | 交易失败 | 传送资料有误 |
| FX | * | WITHDRAW_NOTIFY | * | 01 | 其他狀態(处理中) | 未定義交易狀態 |
| FX | * | WITHDRAW_NOTIFY | completed | 10 | 交易成功 |  |
| FX | * | WITHDRAW_NOTIFY | failed | 20 | 交易失败 |  |
| FX | * | WITHDRAW_NOTIFY | refund | 20 | 交易失败 |  |
| FX | * | WITHDRAW_QRY | * | 01 | 其他，保留处理中 |  |
| FX | * | WITHDRAW_QRY | completed | 10 | 交易成功 | 成功 |
| FX | * | WITHDRAW_QRY | failed | 20 | 交易失败 | 失败 |
| FX | * | WITHDRAW_QRY | refund | 20 | 交易失败 | 冲回 |
| FX | * | WITHDRAW_QRY | reject | 20 | 交易失败 | 拒绝 |
