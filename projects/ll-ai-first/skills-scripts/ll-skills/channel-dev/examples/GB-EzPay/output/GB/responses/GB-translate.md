## GB

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| GB | * | PAY_NOTIFY | * | 01 | 其他狀態(处理中) | 未定義交易狀態 |
| GB | * | PAY_NOTIFY | 30000 | 10 | 交易成功 |  |
| GB | * | PAY_QRY | * | 01 | 其他，保留处理中 |  |
| GB | * | PAY_QRY | 1 | 10 | 交易成功 |  |
| GB | * | PAY_QRY | 2 | 10 | 交易成功 |  |
| GB | * | PAY_QRY | 3 | 20 | 交易失败 |  |
| GB | * | PAY_QRY | 5 | 20 | 交易失败 |  |
| GB | * | WITHDRAW | * | 01 | 处理中 | 其它异常，保留处理中 |
| GB | * | WITHDRAW | 20004 | 20 | 交易失败 |  |
| GB | * | WITHDRAW | 20010 | 20 | 交易失败 |  |
| GB | * | WITHDRAW | 20015 | 20 | 交易失败 |  |
| GB | * | WITHDRAW_NOTIFY | * | 01 | 其他狀態(处理中) | 未定義交易狀態 |
| GB | * | WITHDRAW_NOTIFY | 30000 | 10 | 交易成功 |  |
| GB | * | WITHDRAW_NOTIFY | 40000 | 20 | 交易失败 |  |
| GB | * | WITHDRAW_QRY | * | 01 | 其他，保留处理中 |  |
| GB | * | WITHDRAW_QRY | 2 | 10 | 交易成功 |  |
| GB | * | WITHDRAW_QRY | 3 | 20 | 交易失败 |  |
| GB | * | WITHDRAW_QRY | 5 | 20 | 交易失败 |  |
