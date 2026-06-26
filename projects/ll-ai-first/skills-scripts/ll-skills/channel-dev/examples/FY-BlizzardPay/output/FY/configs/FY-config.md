## FY

### 1. Channel Config

| chnl_id | txn_type | chnl_svc_type | svc_addr | svc_interactive | svc_invoke | bypass_chnl_http_status | allow_notify | svc_state | jar_file_name | protocol_ver | tags | memo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FY | 0010 | JAR | com.icpay.payment.service.channel.common.PayV2Mode1 | Sync | query | 1 | 1 | 1 |  | 1 |  |  |
| FY | 0050 | JAR | com.icpay.payment.service.channel.common.PayV2Mode2 | Sync | query | 1 | 1 | 1 |  | 1 |  | 注意模板名称需冠 5210_ |
| FY | 0121 | JAR | com.icpay.payment.service.channel.common.PayV2Mode1 | Redirect | convRequest | 1 | 1 | 1 |  | 1 |  |  |
| FY | 5210 | JAR | com.icpay.payment.service.channel.common.PayV2Mode2 | Async | convRequest | 1 | 1 | 1 |  | 1 |  | 注意模板名称需冠 5210_ |

### 2. Channel Extend Config

chnl_id: FY
txn_type: 0010
ext_config:
```json
{
    "requestMode": "FORM_JSON",
    "notifyMode": "FORM",
    "useTemplateForRequestHeader": "0",
    "chnlReqMethod": "GET",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: FY
txn_type: 0050
ext_config:
```json
{
    "requestMode": "FORM_JSON",
    "notifyMode": "FORM",
    "useTemplateForRequestHeader": "0",
    "chnlReqMethod": "GET",
    "templateNamePrefix": "5210_",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: FY
txn_type: 0121
ext_config:
```json
{
    "requestMode": "FORM_JSON",
    "notifyMode": "FORM",
    "useTemplateForRequestHeader": "0",
    "templateNamePrefix": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: FY
txn_type: 5210
ext_config:
```json
{
    "requestMode": "FORM_JSON",
    "notifyMode": "FORM",
    "useTemplateForRequestHeader": "0",
    "templateNamePrefix": "5210_",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "&key=",
    "signatureKeyField": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "keyEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

