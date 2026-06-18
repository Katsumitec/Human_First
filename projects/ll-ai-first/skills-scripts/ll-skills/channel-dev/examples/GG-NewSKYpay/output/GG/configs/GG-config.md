## GG

### 1. Channel Config

| chnl_id | txn_type | chnl_svc_type | svc_addr | svc_interactive | svc_invoke | bypass_chnl_http_status | allow_notify | svc_state | jar_file_name | protocol_ver | tags | memo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GG | 0010 | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Sync | query | 1 | 1 | 1 |  | 1 |  |  |
| GG | 0050 | JAR | com.icpay.payment.service.channel.common.PayV3Mode2 | Sync | query | 1 | 1 | 1 |  | 1 |  | 注意模板名称需冠 5210_ |
| GG | 0098 | JAR | com.icpay.payment.service.channel.common.PayV3Mode1 | Async | convResult | 1 | 1 | 1 |  | 1 |  |  |
| GG | 0121 | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | convRequest | 1 | 1 | 1 |  | 1 |  |  |
| GG | 013g | JAR | com.icpay.payment.service.channel.common.PayV2Mode1 | Async | commonTrans | 1 | 1 | 1 |  | 1 |  | 越南Bank QRcode 代收 |
| GG | 014d | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | convRequest | 1 | 1 | 1 |  | 1 |  |  |
| GG | 014e | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | convRequest | 1 | 1 | 1 |  | 1 |  |  |
| GG | 014h | JAR | com.icpay.payment.service.channel.common.PayV2Mode1 | Async | commonTrans | 1 | 1 | 1 |  | 1 |  | 越南VTPAY 代收 |
| GG | 5210 | JAR | com.icpay.payment.service.channel.common.PayV3Mode2 | Async | convRequest | 1 | 1 | 1 |  | 1 |  | 注意模板名称需冠 5210_；代付签名字段固定顺序（非字母序）merchantId→merchantOrderId→payAmount→bankNum→bankAccount |

### 2. Channel Extend Config

chnl_id: GG
txn_type: 0010
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 0050
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "5210_",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 0098
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "chnlReqMethod": "POST",
    "trimTemplate": "true",
    "useTemplateForRequestHeader": "0",
    "templateNamePrefix": "0098_",
    "signConnector": "|",
    "keyValConnector": "",
    "keyConnector": "",
    "signatureKeyField": "",
    "removeEmptyForSign": "false",
    "signWithFieldName": "false",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "RAW",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV3ForMap"
}
```

chnl_id: GG
txn_type: 0121
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 013g
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForRequestHeader": "0",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 014d
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 014e
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 014h
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForRequestHeader": "0",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GG
txn_type: 5210
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "templateNamePrefix": "5210_",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "false",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

