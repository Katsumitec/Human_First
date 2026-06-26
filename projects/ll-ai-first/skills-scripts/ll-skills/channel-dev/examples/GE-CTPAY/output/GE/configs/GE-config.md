## GE

### 1. Channel Config

| chnl_id | txn_type | chnl_svc_type | svc_addr | svc_interactive | svc_invoke | bypass_chnl_http_status | allow_notify | svc_state | jar_file_name | protocol_ver | tags | memo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GE | 0010 | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Sync | query | 1 | 1 | 1 |  | 1 |  | 代收查詢，GET /api/transaction/{chnlOrderId}，需 Bearer Token Header |
| GE | 0050 | JAR | com.icpay.payment.service.channel.common.PayV3Mode2 | Sync | query | 1 | 1 | 1 |  | 1 |  | 代付查詢，GET /api/payment/{chnlOrderId}，需 Bearer Token Header，模板冠 5210_ |
| GE | 0121 | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | commonTrans | 1 | 1 | 1 |  | 1 |  | 純卡網關，自製收銀台展示 data.qrcode |
| GE | 014d | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | commonTrans | 1 | 1 | 1 |  | 1 |  | 銀行直連，bank 必填，自製收銀台展示 data.qrcode，模板名稱冠 014d_ |
| GE | 014e | JAR | com.icpay.payment.service.channel.common.PayV5Mode1 | Redirect | commonTrans | 1 | 1 | 1 |  | 1 |  | 網銀掃碼，bank 選填，自製收銀台展示 data.qrcode，模板名稱冠 014e_ |
| GE | 5210 | JAR | com.icpay.payment.service.channel.common.PayV3Mode2 | Async | convRequest | 1 | 1 | 1 |  | 1 |  | 代付，sign 必填，模板名稱冠 5210_ |

### 2. Channel Extend Config

chnl_id: GE
txn_type: 0010
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForQueryHeader": "1",
    "templateNamePrefix": "",
    "signatureKeyField": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GE
txn_type: 0050
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForQueryHeader": "1",
    "templateNamePrefix": "5210_",
    "signatureKeyField": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GE
txn_type: 0121
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForRequestHeader": "1",
    "templateNamePrefix": "",
    "signatureKeyField": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GE
txn_type: 014d
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForRequestHeader": "1",
    "templateNamePrefix": "014d_",
    "signatureKeyField": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GE
txn_type: 014e
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForRequestHeader": "1",
    "templateNamePrefix": "014e_",
    "signatureKeyField": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

chnl_id: GE
txn_type: 5210
ext_config:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "useTemplateForRequestHeader": "1",
    "templateNamePrefix": "5210_",
    "signatureKeyField": "",
    "signConnector": "&",
    "keyValConnector": "=",
    "keyConnector": "",
    "removeEmptyForSign": "true",
    "signWithFieldName": "true",
    "sortMessageForSign": "true",
    "signatureUpper": "false",
    "urlEncode": "0",
    "binaryEncoding": "HEX",
    "signAlgorithm": "MD5",
    "signatureService": "com.icpay.payment.service.channel.common.sec.SignatureV2ForMap"
}
```

