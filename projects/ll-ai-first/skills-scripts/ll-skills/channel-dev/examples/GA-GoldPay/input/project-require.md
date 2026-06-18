提出日期：2026/3/7

厂商名称：`GoldPay`

TG对接群：`GoldPay 越南llpp8888(1.1+0)`
\#麦当当号

### 对接内容

- 渠道編號：`GA`
- 对接交易類
  - 代收：请先对接跳转上游收银台。待上游调整完成可使用回传参数qr\_image\_url取得原始二维码后，再改为自制收银台。
    - `0121`
      - service_type：702
      - platform：请带入常数值 PC
      - risk_level：请带入常数值 1, 未验证
    - `014d`
      - service_type：420
      - platform：请带入常数值 PC
      - risk_level：请带入常数值 1, 未验证
    - `014e`
      - service_type：440
      - platform：请带入常数值 PC
      - risk_level：请带入常数值 1, 未验证
  - 代付
    - `5210`
      - service_type：700
      - platform：请带入常数值 PC
      - risk_level：请带入常数值 1, 未验证
      - card_name：银行卡姓名
      - card_num：银行卡号
      - merchant_user：银行卡姓名
      - mobile\_no：mobile\_no = card_num
      - platform：请带入常数值 PC
      - risk_level：请带入常数值 1, 未验证
- 对接货币：`704-越南盾`
- 代收是否浮动金额：不浮动
- 對接文檔：[https://api.goldpay8.site/#/guide](https://api.goldpay8.site/#/guide "smartCard-inline")

---

商户资料，如下

- 商户API资讯
  - 商户编码(商户号) ：llpp8888
    密钥:\*\*见email\*\*
- 商户后台
  - 後台：[https://bo.merc-mgmt.pgvn.vn-pay.co/#/login](https://bo.merc-mgmt.pgvn.vn-pay.co/#/login "‌")
  - 登录账号：`llpp8888`
- 接口URL
  - 代收提单：[https://api.pgvn.vn-pay.co/sha256/deposit](https://api.pgvn.vn-pay.co/sha256/deposit "‌")
  - 代收查询：[https://api.pgvn.vn-pay.co/sha256/withdraw](https://api.pgvn.vn-pay.co/sha256/withdraw "‌")
  - 代付提单：[https://api.pgvn.vn-pay.co/sha256/query-order](https://api.pgvn.vn-pay.co/sha256/query-order "‌")
  - 代付查询：[https://api.pgvn.vn-pay.co/sha256/query-order](https://api.pgvn.vn-pay.co/sha256/query-order "‌")
  - 余额查询：[https://api.pgvn.vn-pay.co/sha256/balance](https://api.pgvn.vn-pay.co/sha256/balance "‌")
- 回调IP：52.34.55.206
- 是否支持反查：不支持。

---