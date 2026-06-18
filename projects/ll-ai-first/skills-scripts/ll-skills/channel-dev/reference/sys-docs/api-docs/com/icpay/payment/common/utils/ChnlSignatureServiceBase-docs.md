# ChnlSignatureServiceBase -- 渠道簽名服務抽象基類

類別名稱：`com.icpay.payment.common.utils.ChnlSignatureServiceBase`

## 說明

渠道簽名服務的抽象基類，提供簽名欄位管理、忽略欄位管理、簽名/驗簽密鑰管理、擴展配置存取、交互階段設定等共用功能。所有具體渠道簽名服務類別皆繼承此類，並透過實作 `OnlTxnChnlSignatureService` 介面來完成簽名（`sign`）與驗簽（`checkSign`）邏輯。

使用到的加密參數（`para_cat` 為 `SEC`）：
- `sign.key.<交易類>` — 交易簽名密鑰（依交易類型區分）
- `sign.key` — 預設交易簽名密鑰
- `verify.key.<交易類>` — 交易驗簽密鑰（依交易類型區分）
- `verify.key` — 預設交易驗簽密鑰

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **繼承**: `ChnlBaseTools`（`com.icpay.payment.common.utils.ChnlBaseTools`）
- **實作介面**: `OnlTxnChnlSignatureService`（`com.icpay.payment.service.OnlTxnChnlSignatureService`）
- **已知子類別體系**: `com.icpay.payment.service.channel.common.sec` 套件下的各簽名實作類別（如 `SignatureForMap`、`SignatureForJson`、`SignatureV2ForMap` 等）
- **主要相依性**: `ChnlBaseTools`、`Utils`、`TxnInteractiveStage`

## API說明

### Class: ChnlSignatureServiceBase

#### Public 部分

##### 建構式

- **`ChnlSignatureServiceBase()`**
  無參建構式。

##### 交互階段設定方法（鏈式呼叫）

- **`ChnlSignatureServiceBase stage(TxnInteractiveStage stage)`**
  設定服務的交互階段（列舉型別）。回傳 `this` 以支援鏈式呼叫。

  `TxnInteractiveStage` 可用值：`NONE`、`TXN_REQUEST`、`TXN_RESPONSE`、`QRY_REQUEST`、`QRY_RESPONSE`、`NOTIFY`。

  ```java
  // 使用範例
  signService.stage(TxnInteractiveStage.TXN_REQUEST);
  ```

- **`ChnlSignatureServiceBase stage(String stage)`**
  設定服務的交互階段（字串型別）。回傳 `this` 以支援鏈式呼叫。

  ```java
  // 使用範例
  signService.stage("TxnRequest");
  ```

##### 忽略簽名欄位管理

- **`void setIgnoreSignFields(String[] ignoreSignFields)`**
  設定簽名時要忽略的欄位陣列。

- **`void setIgnoreSignFields(String ignoreSignFields)`**
  設定簽名時要忽略的欄位（字串型別）。支援以逗號（`,`）或分號（`;`）分隔多個欄位名稱。傳入 `null` 清除設定；傳入空字串設為空陣列。

  ```java
  // 使用範例
  signService.setIgnoreSignFields("channelId,intTxnType,refId");
  signService.setIgnoreSignFields("field1;field2;field3");
  ```

- **`String[] getIgnoreSignFields()`**
  取得簽名時要忽略的欄位陣列。

##### 簽名欄位名稱管理

- **`void setSignFieldName(String signFieldName)`**
  設定簽名欄位名稱（即訊息中存放簽名值的欄位鍵名）。

- **`String getSignFieldName()`**
  取得簽名欄位名稱。

##### 驗簽欄位名稱管理

- **`void setSignFieldNameForVerify(String signFieldName)`**
  設定驗簽專用的簽名欄位名稱。當驗簽時簽名值所在欄位與簽名時不同，可透過此方法另行指定。

- **`String getSignFieldNameForVerify()`**
  取得驗簽專用的簽名欄位名稱。

##### 簽名模板名稱管理

- **`void setSignTemplateName(String signTemplateName)`**
  設定簽名用的 FreeMarker 模板名稱。

- **`String getSignTemplateName()`**
  取得簽名用的 FreeMarker 模板名稱。

##### 擴展配置管理

- **`Map<String, Object> getExtConfig()`**
  取得擴展配置 Map。若尚未初始化則自動建立空 Map。

- **`void setExtConfig(Map config)`**
  以 Map 整體設定擴展配置。會將所有鍵轉為 `String` 型別。

- **`void setExtConfig(String key, Object value)`**
  設定單一擴展配置項。

  ```java
  // 使用範例
  signService.setExtConfig("charset", "UTF-8");
  signService.setExtConfig("binaryEncoding", "BASE64");
  ```

##### 簽名值取得方法

- **`String getSignature(Map<String, ?> msg, String signField)`**
  從訊息 Map 中取得指定欄位的簽名值。支援巢狀欄位路徑（以 `.` 分隔），若巢狀路徑找不到則嘗試取最右側的欄位名稱。回傳簽名值字串，若欄位為空則回傳 `null`。

- **`String getSignature(Map<String, ?> msg)`**
  從訊息 Map 中取得簽名值。優先使用 `signFieldNameForVerify`，若取不到則改用 `signFieldName`。

  ```java
  // 使用範例
  Map<String, Object> responseMsg = ...; // 渠道回應
  String signature = signService.getSignature(responseMsg);
  ```

##### 簽名欄位移除方法

- **`boolean removeSignField(Map<String, ?> msg, String signField)`**
  從訊息 Map 中移除指定的簽名欄位。支援巢狀路徑，若移除失敗則嘗試以最右側欄位名稱再移除一次。回傳是否成功移除。

- **`boolean removeSignField(Map<String, ?> msg)`**
  從訊息 Map 中移除 `signFieldName` 指定的簽名欄位。

  ```java
  // 使用範例：驗簽前先取出簽名值再移除簽名欄位
  String sign = signService.getSignature(msg);
  signService.removeSignField(msg);
  boolean valid = signService.checkSign(msg, params);
  ```

##### 驗簽方法

- **`boolean checkSign(String msgBody, Map params)`**
  以字串型態的訊息體進行驗簽。內部會將 `msgBody` 轉為 Map 後委派至 `checkSign(Map, Map)` 方法處理。

#### Protected 部分

##### 常數

| 常數 | 類型 | 值 | 說明 |
|------|------|----|------|
| `DEFAULT_IGNORE_SIGN_FIELDS` | `String[]` | `{"channelId", "intTxnType", "refId"}` | 預設忽略簽名的欄位清單，這些欄位為系統內部欄位，不參與簽名計算 |

##### 擴展配置存取

- **`String extConfig(String key)`**
  取得擴展配置參數值。若配置值以 `@` 開頭，則視為間接參照，會從 `tbl_mer_params` 表中以該值（去掉 `@` 前綴）作為參數名稱查詢。查詢時優先以當前渠道商戶 + 交易類型查找，找不到則回退至萬用交易類型 `"*"`。

  ```java
  // 使用範例
  // 直接取值
  String charset = extConfig("charset");  // 回傳配置中的值，例如 "UTF-8"

  // 間接參照：若 extConfig 中設定 "apiUrl" = "@api.url"
  // 則會從 tbl_mer_params 中查找 para_id 為 "api.url" 的參數值
  String apiUrl = extConfig("apiUrl");
  ```

- **`String extConfig(String key, String defaultValue)`**
  取得擴展配置參數值，若取不到則回傳預設值。

  ```java
  // 使用範例
  String charset = extConfig("charset", "UTF-8");
  ```

##### 密鑰管理

- **`String getSignKey()`**
  從商戶安全參數（`para_cat = SEC`）中取得簽名密鑰。查找順序：
  1. `sign.key.<交易類>` — 依當前交易類型查找
  2. `sign.key` — 預設簽名密鑰

  取得後會快取，後續呼叫直接回傳快取值。

  ```freemarker
  <#-- 以下是在 FreeMarker 模板中使用, svc 是繼承自 ChnlBaseTools 的實例 -->
  <#-- 在簽名模板中取得簽名密鑰 -->
  <#assign signKey = svc.getSignKey()>
  ```

- **`String getVerifyKey()`**
  從商戶安全參數（`para_cat = SEC`）中取得驗簽密鑰。查找順序：
  1. `verify.key.<交易類>` — 依當前交易類型查找
  2. `verify.key` — 預設驗簽密鑰
  3. 若以上皆未定義，則回退使用 `getSignKey()` 的值

  取得後會快取，後續呼叫直接回傳快取值。

- **`String getKey(String keyId)`**
  從商戶安全參數中取得指定 `keyId` 的密鑰。查找順序：
  1. `{keyId}.{交易類型}` — 依當前交易類型查找
  2. `{keyId}` — 無交易類型限定

  ```java
  // 使用範例：在子類別中取得自訂密鑰
  String hmacKey = getKey("hmac.key");
  // 會先查找 "hmac.key.0200" (假設交易類型為 0200)
  // 找不到再查找 "hmac.key"
  ```
