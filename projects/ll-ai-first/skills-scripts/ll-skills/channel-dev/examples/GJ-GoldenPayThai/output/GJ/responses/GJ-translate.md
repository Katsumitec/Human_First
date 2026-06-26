## GJ

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| GJ | * | PAY_NOTIFY | * | 01 | 失敗 | 代收通知：文檔「60=成功其他失敗」，預設失敗 |
| GJ | * | PAY_NOTIFY | 60 | 10 | 成功 | 代收通知：支付成功 |
| GJ | * | PAY_QRY | * | 01 | 處理中 | 代收查詢：文檔「60=成功其他未支付」，預設處理中 |
| GJ | * | PAY_QRY | 20 | 01 | 新創建 | 代收查詢：訂單剛創建 |
| GJ | * | PAY_QRY | 60 | 10 | 成功 | 代收查詢：支付成功 |
| GJ | * | WITHDRAW | * | 01 | 处理中 | 代付同步響應：預設失敗 |
| GJ | * | WITHDRAW | 200 | 01 | 提交成功處理中 | 代付同步響應：code=200 代表提交成功 |
| GJ | * | WITHDRAW | 400 | 20 | 失敗 | 代付同步響應：code=400代表通道维护或超出限额 |
| GJ | * | WITHDRAW | 406 | 20 | 失敗 | 代付同步響應：code=406 代表馀额不足 |
| GJ | * | WITHDRAW_NOTIFY | * | 01 | 處理中 | 代付通知：文檔「50=取消其他成功」；保守設處理中，聯調確認成功碼 |
| GJ | * | WITHDRAW_NOTIFY | 50 | 20 | 取消/失敗 | 代付通知：取消或失敗 |
| GJ | * | WITHDRAW_NOTIFY | 60 | 10 | 成功 | 代付通知：推測成功碼（與代收一致，聯調確認） |
| GJ | * | WITHDRAW_QRY | * | 01 | 處理中 | 代付查詢：文檔「20=已受理 50=取消/失敗 其他=成功」；保守設處理中 |
| GJ | * | WITHDRAW_QRY | 20 | 01 | 已受理 | 代付查詢：訂單已受理 |
| GJ | * | WITHDRAW_QRY | 50 | 20 | 取消/失敗 | 代付查詢：取消或失敗 |
| GJ | * | WITHDRAW_QRY | 60 | 10 | 成功 | 代付查詢：推測成功碼（與代收一致，聯調確認） |
