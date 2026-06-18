# SignatureForMap -- Map 格式通用簽名服務（V1）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureForMap`

## 說明

通用型簽名服務，以 Map 鍵值對串接的字串作為簽名來源。支援自訂字段連接符、鍵值連接符，可控制是否包含字段名、是否排序、是否移除空值等。使用 MD5 計算簽名。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlSignatureServiceBase`（`com.icpay.payment.common.utils.ChnlSignatureServiceBase`）
- **主要相依性**: `ChnlSignatureServiceBase`、`EncryptUtil`

## API說明

### Class: SignatureForMap

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `signConnector` | 字段間連接符 | `"&"` |
| `keyValConnector` | 鍵值間連接符 | `"="` |
| `keyConnector` | 密鑰連接符 | `"&key="` |
| `signWithFieldName` | 是否包含字段名 | `"true"` |
| `sortMessageForSign` | 是否依字段名排序 | `"true"` |
| `signatureKeyField` | 密鑰字段名 | `null` |
| `removeEmptyForSign` | 是否移除空字段 | `"false"` |
| `signatureUpper` | 簽名是否轉大寫 | `"false"` |

##### 常數

| 常數 | 類型 | 值 |
|------|------|----|
| `CONNECTOR_SIGN` | `String` | `"signConnector"` |
| `CONNECTOR_KEY_VAL_SIGN` | `String` | `"keyValConnector"` |
| `CONNECTOR_KEY` | `String` | `"keyConnector"` |
| `SIGN_WITH_FIELDNAME` | `String` | `"signWithFieldName"` |
| `SORT_MESSAGE` | `String` | `"sortMessageForSign"` |
| `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` |
| `REMOVE_EMPTY` | `String` | `"removeEmptyForSign"` |
| `SIGNATURE_TOUPPER` | `String` | `"signatureUpper"` |

##### 建構式

- **`SignatureForMap()`**

##### 簽名與驗簽方法

- **`String sign(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行簽名。流程：
  1. 模板轉換或直接使用 msg
  2. 移除忽略字段、簽名字段、空字段
  3. 可選注入密鑰字段
  4. 排序或串接 Map（使用 `EncryptUtil.sortMap` 或 `EncryptUtil.concatMap`）
  5. 附加密鑰，計算 MD5

  ```java
  SignatureForMap signer = new SignatureForMap();
  String signature = signer.sign(msgMap, paramsMap, outputMap);
  // 簽名原文格式如：amount=100&merchant=M001&key=myKey
  ```

- **`boolean checkSign(Map msg, Map params)`**
  驗證報文簽名。

##### 配置存取方法

- **`boolean shouldSortMessage()`** -- 是否排序，預設 `true`
- **`boolean shouldRemoveEmpty()`** -- 是否移除空字段，預設 `false`
- **`boolean shouldSignatureToUppercase()`** -- 簽名是否轉大寫，預設 `false`
- **`boolean shouldSignWithFieldName()`** -- 是否包含字段名，預設 `true`

#### Protected 部分

- **`String getKeyConnector()`** -- 密鑰連接符，預設 `"&key="`
- **`String getSignConnector()`** -- 字段間連接符，預設 `"&"`
- **`String getKeyValSignConnector()`** -- 鍵值連接符，預設 `"="`
- **`String getSignatureKeyField()`** -- 密鑰字段名
- **`static String getMaskedKey(String key)`** -- 遮蔽密鑰
