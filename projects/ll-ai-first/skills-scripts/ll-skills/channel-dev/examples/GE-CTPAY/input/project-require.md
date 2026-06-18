提出日期：2026/3/22

厂商名称：`CTPAY`

TG对接群：`『CTPAY對接群』`
\#麦当当号

### 对接内容

- 渠道編號：`GE`
- 对接交易類
  - 代收
    - 自制收银台，依照请求返回参数的data.qrcode在收银台呈现
    - `0121`
    - `014d`
    - `014e`
  - 代付
    - `5210`
- 对接货币：`越南盾(704)`
- 代收是否浮动金额：不浮动
- 對接文檔：[https://tianciv420428.com/docs](https://tianciv420428.com/docs "smartCard-inline")

---

商户资料，如下

- 商户API资讯
  - 商户编码(商户号) ：`vvdd222`
    密钥:\*\*见email\*\*
- 商户后台
  - 後台：[https://yd.user.3a.cash/](https://yd.user.3a.cash/ "smartCard-inline")
  - 登录账号：`zzzfb16888`
- 接口URL
  - 代收 `https://tianciv420428.com/api/transaction`
  - 代付 `https://tianciv420428.com/api/payment`
  - 代收查单 `https://tianciv420428.com/api/transaction/{out_trade_no}`
  - 代付查单 `https://tianciv420428.com/api/payment/{out_trade_no}`
  - 商户余额 `https://tianciv420428.com/api/balance/inquiry`
- 回调IP：3.113.1.152
- 是否支持反查：不支持。

---