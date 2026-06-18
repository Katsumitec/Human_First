# SignatureV2ForMap -- Map 格式通用簽名服務（V2，多演算法支援）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV2ForMap`

## 說明

V2 版通用型簽名服務，以 Map 鍵值對串接字串作為簽名來源。繼承自 `SignatureV2ForJson`，覆寫簽名原文計算邏輯，將 Map 以指定的連接符串接（而非 JSON 格式）。支援 URL 編碼、空格替換等進階功能。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignatureV2ForJson`
- **已知子類別**: `SignatureV2ForMapNested`
- **主要相依性**: `SignatureV2ForJson`、`EncryptUtil`

## API說明

### Class: SignatureV2ForMap

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

- **`SignatureV2ForMap()`**

##### 配置存取方法

- **`String getSignConnector()`** -- 字段連接符，預設 `"&"`
- **`String getKeyValSignConnector()`** -- 鍵值連接符，預設 `"="`
- **`boolean shouldSignWithFieldName()`** -- 是否包含字段名，預設 `true`
- **`boolean shouldURLEncode()`** -- 是否 URL 編碼，預設 `false`
- **`String getURLEncodeSpaceReplacement()`** -- URL 編碼空格替換符

#### Protected 部分

- **`String calcSignSource(Map msg, Map params, Map outputMap)`**
  覆寫父類方法。將 Map 以鍵值對形式串接（而非 JSON），支援排序、URL 編碼、大小寫轉換等。

- **`String concatMap(Map signSrcMap, boolean allowEmpty, boolean urlEncode, String charEncoding, String spaceReplacement)`**
  串接 Map，使用 `EncryptUtil.concatMap`。

- **`String sortMap(Map signSrcMap, boolean allowEmpty, boolean urlEncode, String charEncoding, String spaceReplacement)`**
  排序後串接 Map，使用 `EncryptUtil.sortMapV2`。
