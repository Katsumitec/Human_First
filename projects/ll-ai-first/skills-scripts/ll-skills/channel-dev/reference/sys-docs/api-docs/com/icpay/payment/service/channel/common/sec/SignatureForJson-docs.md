# SignatureForJson -- JSON 格式通用簽名服務（V1）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureForJson`

## 說明

通用型簽名服務，以 JSON 字串作為簽名來源。將 Map 報文轉換為 JSON 後，使用 MD5 計算簽名。支援字段排序、空字段移除、密鑰字段注入、簽名大寫轉換等配置。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `ChnlSignatureServiceBase`（`com.icpay.payment.common.utils.ChnlSignatureServiceBase`）
- **主要相依性**: `ChnlSignatureServiceBase`、`EncryptUtil`、`JsonUtils`、`fastjson`

## API說明

### Class: SignatureForJson

#### Public 部分

##### extConfig 配置項

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `keyConnector` | 密鑰連接符 | `"&key="` |
| `sortMessageForSign` | 簽名時是否依字段名排序 | `"true"` |
| `sortWthKeyForSign` | 排序是否包含密鑰一起排序 | `"false"` |
| `signatureKeyField` | 密鑰字段名（注入到 Map 中） | `null` |
| `removeEmptyForSign` | 是否移除空字段 | `"false"` |
| `signatureUpper` | 簽名是否轉大寫 | `"false"` |

##### 常數

| 常數 | 類型 | 值 |
|------|------|----|
| `CONNECTOR_KEY` | `String` | `"keyConnector"` |
| `SORT_MESSAGE` | `String` | `"sortMessageForSign"` |
| `SORT_WITH_KEY` | `String` | `"sortWthKeyForSign"` |
| `SIGNATURE_KEY_FIELD` | `String` | `"signatureKeyField"` |
| `REMOVE_EMPTY` | `String` | `"removeEmptyForSign"` |
| `SIGNATURE_TOUPPER` | `String` | `"signatureUpper"` |

##### 建構式

- **`SignatureForJson()`**

##### 簽名與驗簽方法

- **`String sign(Map msg, Map params, Map outputMap)`**
  對 Map 報文進行簽名。流程：
  1. 若有簽名模板則使用模板轉換，否則直接使用 msg
  2. 移除忽略字段與簽名字段
  3. 可選移除空字段
  4. 可選注入密鑰字段
  5. 可選排序後轉為 JSON
  6. 附加密鑰計算 MD5
  7. 可選轉大寫

  ```java
  SignatureForJson signer = new SignatureForJson();
  // 配置透過 extConfig 設定
  Map<String, Object> outputMap = new HashMap<>();
  String signature = signer.sign(msgMap, paramsMap, outputMap);
  ```

- **`boolean checkSign(Map msg, Map params)`**
  驗證報文簽名。從報文中取出簽名值，重新計算後比對。

##### 配置存取方法

- **`boolean shouldSortMessage()`** -- 是否排序，預設 `true`
- **`boolean shouldSortWithKey()`** -- 排序是否含密鑰，預設 `false`
- **`boolean shouldRemoveEmpty()`** -- 是否移除空字段，預設 `false`
- **`boolean shouldSignatureToUppercase()`** -- 簽名是否轉大寫，預設 `false`

#### Protected 部分

- **`String getKeyConnector()`** -- 取得密鑰連接符，預設 `"&key="`
- **`String getSignatureKeyField()`** -- 取得密鑰字段名
- **`String mapToJson(Map map)`** -- 將 Map 轉為 JSON 字串（使用 fastjson，保留 null 值）
- **`static String getMaskedKey(String key)`** -- 遮蔽密鑰
