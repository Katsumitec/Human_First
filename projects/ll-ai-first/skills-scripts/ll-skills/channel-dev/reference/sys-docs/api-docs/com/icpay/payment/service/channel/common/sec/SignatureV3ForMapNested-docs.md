# SignatureV3ForMapNested -- Map 格式通用簽名服務（V3，巢狀 Map 支援）

類別名稱：`com.icpay.payment.service.channel.common.sec.SignatureV3ForMapNested`

## 說明

`SignatureV3ForMap` 的擴展，覆寫 Map 串接與排序邏輯，使用 `EncryptUtil.concatMapNested` 和 `EncryptUtil.sortMapNested` 處理巢狀（nested）Map 結構。適用於報文中包含多層巢狀物件的場景，使用 V3 代理模式進行簽名計算。

## 架構
- **Package**: `com.icpay.payment.service.channel.common.sec`
- **繼承**: `SignatureV3ForMap` -> `SignatureV3ForJson`
- **主要相依性**: `SignatureV3ForMap`、`EncryptUtil`

## API說明

### Class: SignatureV3ForMapNested

#### Protected 部分

- **`String concatMap(Map signSrcMap, boolean allowEmpty, boolean urlEncode, String charEncoding, String spaceReplacement)`**
  覆寫父類方法，使用 `EncryptUtil.concatMapNested` 處理巢狀 Map。

- **`String sortMap(Map signSrcMap, boolean allowEmpty, boolean urlEncode, String charEncoding, String spaceReplacement)`**
  覆寫父類方法，使用 `EncryptUtil.sortMapNested` 處理巢狀 Map 的排序。
