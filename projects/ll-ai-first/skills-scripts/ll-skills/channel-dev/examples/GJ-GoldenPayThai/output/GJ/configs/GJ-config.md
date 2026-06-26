## GJ

### 1. Channel Config

| chnl_id | txn_type | chnl_svc_type | svc_addr | svc_interactive | svc_invoke | bypass_chnl_http_status | allow_notify | svc_state | jar_file_name | protocol_ver | tags | memo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GJ | 0010 | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Sync | query | 1 | 1 | 1 |  | 1 |  | 代收訂單查詢（GET /api/v1/mch/pmt-orders） |
| GJ | 0050 | JAR | com.icpay.payment.service.channel.common.PayV3Mode2 | Sync | query | 1 | 1 | 1 |  | 1 |  | 代付訂單查詢（GET /api/v1/mch/wdl-orders）；注意模板名稱需冠 5210_ |
| GJ | 0121 | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | convRequest | 1 | 1 | 1 |  | 1 |  | 代收-網銀類（POST /api/v1/mch/pmt-orders；上游返回 url 跳轉） |
| GJ | 013d | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | convRequest | 1 | 1 | 1 |  | 1 |  | 代收-H5/PromptPay類（POST /api/v1/mch/pmt-orders；共用 0121 模板） |
| GJ | 5210 | JAR | com.icpay.payment.service.channel.common.PayV3Mode2 | Async | convRequest | 1 | 1 | 1 |  | 1 |  | 代付（POST /api/v1/mch/wdl-orders）；注意模板名稱需冠 5210_ |

### 2. Channel Extend Config

chnl_id: GJ
txn_type: 0010
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "chnlReqMethod": "GET",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5_KeyFront_connector",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV3ForMap"
}
```

chnl_id: GJ
txn_type: 0050
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "chnlReqMethod": "GET",
    "templateNamePrefix": "5210_",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5_KeyFront_connector",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV3ForMap"
}
```

chnl_id: GJ
txn_type: 0121
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5_KeyFront_connector",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV3ForMap"
}
```

chnl_id: GJ
txn_type: 013d
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5_KeyFront_connector",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV3ForMap"
}
```

chnl_id: GJ
txn_type: 5210
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "5210_",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5_KeyFront_connector",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV3ForMap"
}
```

