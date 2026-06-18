## GE

### Channel Translate

| chnl_id | class_name | catalog | src_code | dest_code | dest_msg | memo |
| --- | --- | --- | --- | --- | --- | --- |
| GE | * | PAY_NOTIFY | * | 01 | 處理中 | 預設處理中（防禦性配置） |
| GE | * | PAY_NOTIFY | completed | 10 | 支付成功 | 代收成功，API 僅回調此狀態 |
| GE | * | PAY_QRY | * | 01 | 處理中 | 預設處理中 |
| GE | * | PAY_QRY | completed | 10 | 支付成功 | 代收成功 |
| GE | * | PAY_QRY | new | 01 | 新訂單 | 待處理 |
| GE | * | PAY_QRY | processing | 01 | 處理中 | 處理中 |
| GE | * | PAY_QRY | verify | 01 | 待確認 | 待確認 |
| GE | * | WITHDRAW | * | 01 | 提交成功處理中 | success=true，等待異步通知確認最終結果 |
| GE | * | WITHDRAW | false422 | 20 | 代付失败 |  |
| GE | * | WITHDRAW_NOTIFY | * | 01 | 處理中 | 預設處理中 |
| GE | * | WITHDRAW_NOTIFY | completed | 10 | 代付成功 | 轉帳成功 |
| GE | * | WITHDRAW_NOTIFY | failed | 20 | 代付失敗 | 轉帳失敗 |
| GE | * | WITHDRAW_NOTIFY | refund | 20 | 代付沖回 | 已沖回 |
| GE | * | WITHDRAW_QRY | * | 01 | 處理中 | 預設處理中 |
| GE | * | WITHDRAW_QRY | completed | 10 | 代付成功 | 轉帳成功 |
| GE | * | WITHDRAW_QRY | failed | 20 | 代付失敗 | 轉帳失敗 |
| GE | * | WITHDRAW_QRY | new | 01 | 新訂單 | 待處理 |
| GE | * | WITHDRAW_QRY | processing | 01 | 處理中 | 處理中 |
| GE | * | WITHDRAW_QRY | refund | 20 | 代付沖回 | 已沖回 |
| GE | * | WITHDRAW_QRY | reject | 20 | 代付拒絕 | 被拒絕 |
| GE | * | WITHDRAW_QRY | verify | 01 | 待審核 | 待審核 |
