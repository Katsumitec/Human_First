# SignatureV3ForMap -- Map 格式通用簽名服務（V3，代理模式）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV3ForMap`

## 說明

V3 版通用型簽名服務，以 Map 鍵值對串接字串作為簽名來源。繼承自 `SignatureV3ForJson`，覆寫簽名原文計算邏輯，將 Map 以指定連接符串接。支援 URL 編碼、空格替換等進階功能，並使用 V3 的代理模式進行簽名計算。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignatureV3ForJson`
- **已知子類別**: `SignatureV3ForMapNested`、`SignatureV3ForMapWithExKey`
- **主要相依性**: `SignatureV3ForJson`、`EncryptUtil`

## API說明

### Class: SignatureV3ForMap

#### Public 部分

##### extConfig 配置項（新增）

| 配置項 | 說明 | 預設值 |
|--------|------|--------|
| `signConnector` | 字段間連接符 | `"&"` |
| `keyValConnector` | 鍵值間連接符 | `"="` |
| `signWithFieldName` | 是否包含字段名 | `"true"` |
| `urlEncode` | 是否 URL 編碼 | `"false"` |
| `urlEncodeSpaceReplacement` | URL 編碼時空格替換符 | `null` |

##### 建構式

- **`SignatureV3ForMap()`**

##### 配置存取方法

- **`String getSignConnector()`** -- 字段連接符，預設 `"&"`
- **`String getKeyValSignConnector()`** -- 鍵值連接符，預設 `"="`
- **`boolean shouldSignWithFieldName()`** -- 是否包含字段名，預設 `true`
- **`boolean shouldURLEncode()`** -- 是否 URL 編碼，預設 `false`
- **`String getURLEncodeSpaceReplacement()`** -- URL 編碼空格替換符

#### Protected 部分

- **`String calcSignSource(Map msg, Map params, Map outputMap)`**
  覆寫父類方法，將 Map 以鍵值對形式串接。

- **`String concatMap(Map signSrcMap, boolean allowEmpty, boolean urlEncode, String charEncoding, String spaceReplacement)`**
  串接 Map，使用 `EncryptUtil.concatMap`。

- **`String sortMap(Map signSrcMap, boolean allowEmpty, boolean urlEncode, String charEncoding, String spaceReplacement)`**
  排序後串接 Map，使用 `EncryptUtil.sortMapV2`。
