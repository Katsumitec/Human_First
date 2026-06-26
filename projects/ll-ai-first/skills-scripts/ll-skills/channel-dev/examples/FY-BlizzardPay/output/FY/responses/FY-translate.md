## FY

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| FY | * | PAY_NOTIFY | * | 01 | 其他狀態(处理中) | 未定義交易狀態 |
| FY | * | PAY_NOTIFY | SUCCESS | 10 | 交易成功 |  |
| FY | * | PAY_QRY | * | 01 | 其他，保留处理中 |  |
| FY | * | PAY_QRY | false | 20 | 交易失败 |  |
| FY | * | PAY_QRY | true | 10 | 交易成功 |  |
| FY | * | WITHDRAW | * | 01 | 处理中 | 其它异常，保留处理中 |
| FY | * | WITHDRAW | 400 | 20 | 交易失败 | 建單失敗 |
| FY | * | WITHDRAW_NOTIFY | * | 01 | 其他狀態(处理中) | 未定義交易狀態 |
| FY | * | WITHDRAW_NOTIFY | 1 | 10 | 交易成功 | 已打款 |
| FY | * | WITHDRAW_NOTIFY | 2 | 20 | 交易失败 | 驳回 |
| FY | * | WITHDRAW_QRY | * | 01 | 其他，保留处理中 |  |
| FY | * | WITHDRAW_QRY | 1 | 10 | 交易成功 |  |
| FY | * | WITHDRAW_QRY | 2 | 20 | 交易失败 |  |
