# SignatureV3ForMapWithExKey -- Map 格式通用簽名服務（V3，額外密鑰支援）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV3ForMapWithExKey`

## 說明

`SignatureV3ForMap` 的擴展，新增額外密鑰（ExKey）機制。在簽名原文計算完成後，可額外串接一組獨立的密鑰（來自不同的 MerParams 配置），用於需要雙重密鑰控制的場景。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignatureV3ForMap` -> `SignatureV3ForJson`
- **主要相依性**: `SignatureV3ForMap`

## API說明

### Class: SignatureV3ForMapWithExKey

#### Public 部分

##### extConfig 配置項（新增）

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `exSignKeyName` | 簽名時額外密鑰的 MerParams key 名稱 | `"sign.key.ex"` |
| `exVerifyKeyName` | 驗簽時額外密鑰的 MerParams key 名稱 | `"verify.key.ex"` |
| `exKeyConnector` | 額外密鑰的連接符 | `"&key="` |
| `concatExKeyToSignSrc` | 是否在簽名原文後附加額外密鑰 | `"true"` |

##### 常數

| 常數 | 類型 | 值 |
|------|------|----|
| `EX_SIGN_KEY_NAME` | `String` | `"exSignKeyName"` |
| `EX_VERIFY_KEY_NAME` | `String` | `"exVerifyKeyName"` |
| `CONCAT_EX_KEY` | `String` | `"concatExKeyToSignSrc"` |
| `CONNECTOR_EX_KEY` | `String` | `"exKeyConnector"` |

##### 建構式

- **`SignatureV3ForMapWithExKey()`**

##### 配置存取方法

- **`String getExKeyConnector()`** -- 額外密鑰連接符，預設 `"&key="`
- **`String getExSignKeyName()`** -- 簽名用額外密鑰名稱，預設 `"sign.key.ex"`
- **`String getExVerifyKeyName()`** -- 驗簽用額外密鑰名稱，預設 `"verify.key.ex"`
- **`boolean shouldConcatExKeyToSignSrc()`** -- 是否附加額外密鑰，預設 `true`

#### Protected 部分

- **`String calcSignSource(Map msg, Map params, Map outputMap)`**
  覆寫父類方法。在標準 Map 串接邏輯完成後，若 `concatExKeyToSignSrc` 為 true，則在簽名原文末尾附加 `{exKeyConnector}{exKey}`。

  ```java
  // 假設 exKeyConnector = "&key=", exKey = "extraSecret123"
  // 最終簽名原文如：amount=100&merchant=M001&key=extraSecret123
  ```

- **`String getExSignKey()`** -- 從 MerParams 中取得簽名用額外密鑰
- **`String getExVerifyKey()`** -- 從 MerParams 中取得驗簽用額外密鑰，若為空則回退到 signKey
