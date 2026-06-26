# 【LL】對接上游_NewSKYpay_GG

> 來源：https://gitlab.sky-net.tw/ll/dashboard-ll/-/issues/2
> 提出日期：2026/4/7
> 廠商名稱：NewSKYpay
> TG 對接群：NewSKY-lv7688-0.55%+0 / #麥當當號

## 對接內容

- **渠道編號**：GG
- **對接交易類**
  - 代收
    - 交易類：`0121`、`014d`、`014e`
    - 參數說明：
      - 提單：
        - `payType`：固定傳 `1060`
        - 會員 ID：傳隨機值
      - 回應（收銀台）：
        - `data.payAmount` 金額
        - `data.qrCode` 二維碼字符串
  - 代付
    - 交易類：`5210`
    - 參數說明：
    - **額外規則**：
      - **需建制商戶反查接口**，在對上游提單之後讓上游透過接口反查
      - 對接文檔：代收接口 → 反查商戶接口
- **對接貨幣**：VND（越南盾，幣別代碼 704）
- **代收是否浮動金額**：不浮動
- **對接文檔**：http://18.163.184.55/doc

---

## 商戶資料

### 商戶 API 資訊
- **商戶編碼（商戶號）**：`30038`
- **密鑰**：見 email

### 商戶後台
- **商戶後台 URL**：http://sys.newsky.vip
- **帳號**：`lv7688`
- **密碼**：見 email

### 接口 URL
- **對接方式**：API 接口（POST，`application/json;charset=UTF-8`）
- **代收下單地址**：http://api.newsky.vip/hpay/dt/vnd/ct
- **代收查單地址**：http://api.newsky.vip/hpay/dt/vnd/query
- **代付下單地址**：http://api.newsky.vip/hpay/wd/vnd/ct
- **代付查單地址**：http://api.newsky.vip/hpay/wd/vnd/query
- **商戶餘額查詢**：http://api.newsky.vip/hpay/merchant/balance

### 回調 IP
- 18.163.181.38
- 43.199.133.253
- 43.199.58.235
- 95.40.139.72
- 18.162.79.67
- 18.166.1.107
- 18.166.44.1

### 是否支持反查
- **不支持**（此處應指：我方不支持上游發起反查的標準機制；本案需「客製建立」反查接口供上游回調，見下方 0098 規格）

---

## 0098 反查接口（使用者明確指示）

此渠道有要求「渠道反查」 — 渠道在實際建單時會回調我們「反查」接口，確認的確有該筆訂單。
反查機制需建立 0098 交易，作為反查回調接口的交易類。

### 1. 新增 tbl_chnl_service_conf

- `txn_type`: `0098`
- `svc_addr`: `com.icpay.payment.service.channel.common.PayV3Mode1`
- `svc_invoke`: `convResult`
- `ext_config`:
```json
{
    "requestMode": "JSON_JSON",
    "notifyMode": "JSON",
    "chnlReqMethod": "POST",
    "templateNamePrefix": "0098_"
}
```

### 2. 新增模板 `0098_txn_notify.ftl`

```freemarker
<#-- 0098_txn_notify.ftl -->
<#setting number_format="0">
${svc.setCurrencyByCode('704')}
${svc.setChnlAmtUnitStr('1.0')}
${svc.setChnlAmtFormat('0.##')}
${svc.setLocalAmtFormat('0')}
<#assign orderResult=svc.queryOrderByChnlOrderIdWithAmt(ctx.merOrderId, ctx.amount) />

<#assign respToChannel = 'ERROR' />
<#if orderResult.result_code == '0000'>
  <#assign respToChannel = 'OK' />
</#if>

{
  "channel" : "${ctx.channel!ctx.channelId!svc.getChannel()}",
  "intTxnType" : "${ctx.intTxnType!svc.getIntTxnType()}",
  "chnlOrderId" : "${ctx.merOrderId!ctx.chnlOrderId!''}",
  "respToChannel" : "${respToChannel}",
  "respContentType" : "text/plain"
}
```

### 3. 關閉 0098 簽名

於 `tbl_mer_params` 配置，交易類 `0098` 下列參數需設為 `0`：

| chnl_id | mchnt_cd | param_cat | param_id | param_value |
|:---|:---|:---|:---|:---|
| GG | * | 0098 | sign.action.notify.check | 0 |
| GG | * | 0098 | sign.action.notify.check.by.template | 0 |

> 反查接口不需驗簽（按使用者指示），只負責「比對訂單號 + 金額」後回 OK / ERROR。

---

## 實作策略
- 上游目前先依文檔開發，使用者後續會提供「實際上線的內容」作為調校來源。
