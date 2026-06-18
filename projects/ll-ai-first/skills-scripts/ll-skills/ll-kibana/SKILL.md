---
name: ll-kibana
description: 在公司內網 ll-kibana.sky-net.com.tw 的 dev_ll_log-* index 中搜尋日誌、定位錯誤、分析呼叫鏈。基於 agent-browser 操作 Kibana Discover，會自動處理首次登入、URL 組裝、KQL 查詢、結果擷取與分頁。觸發詞：「查 Kibana」「搜 ll-kibana」「sessionId 日誌」「dev_ll_log」「sky-net Kibana」「定位錯誤碼」「呼叫鏈追蹤」「日誌分析」。
allowed-tools: Bash(agent-browser:*), Bash(command:*), Bash(which:*), Bash(npm:*), Bash(brew:*), Bash(cat:*), Bash(head:*), Bash(wc:*), Bash(grep:*), Bash(ls:*), Read, Write, Edit, AskUserQuestion
---

# ll-kibana — 公司內網 Kibana 日誌搜尋技能

固定入口、固定 index、安全認證 — 專門用來在 **ll-kibana.sky-net.com.tw** 的 **dev_ll_log-\*** 上做 session/錯誤/呼叫鏈定位的工作流。

## 🔒 硬性限制 (不可違反)

1. **Kibana 入口固定**：只能訪問 `https://ll-kibana.sky-net.com.tw/kibana/app/discover`
2. **Index 鎖死 dev_ll_log-\***：URL 內 `index` 參數**永遠**等於 `0788a73a-4957-49de-af25-98a63bfc98ed`
   - 即使使用者要求切到 prod / bak / nginx 等其他 index，**先拒絕並說明此 skill 僅允許 dev_ll_log-\***
   - 若使用者堅持要查其他 index，請他不要透過本 skill 進行，改用一般 agent-browser 自行操作
3. **絕不替使用者輸入帳密**：登入動作交由使用者在 headed 瀏覽器視窗手動完成

## 📋 啟動前置檢查 (Pre-flight)

每次呼叫此 skill 第一步必做：

```bash
command -v agent-browser >/dev/null 2>&1 && agent-browser --version
```

判斷：

- **未安裝 agent-browser** → 停下來，告訴使用者擇一安裝：
  ```
  npm install -g agent-browser     # 最常用
  brew install agent-browser       # macOS Homebrew
  cargo install agent-browser      # Rust 玩家
  ```
  接著 `agent-browser install` 下載 Chrome runtime。安裝完成後請使用者重新觸發此 skill。
- **已安裝** → 進入下一步。

## 🔐 認證流程

固定使用 **headed + persistent profile** 模式，profile 路徑：

```
~/.agent-browser-kibana
```

### 啟動 / 開啟 Kibana

```bash
# 若 daemon 已在跑且 profile 不一致，必須先 close
agent-browser close 2>/dev/null

agent-browser --profile ~/.agent-browser-kibana --headed \
  open "https://ll-kibana.sky-net.com.tw/kibana/app/discover"

agent-browser wait --load networkidle
agent-browser get url
```

### 判斷是否需要登入

抓 URL，若包含 `/kibana/login` 即代表 cookie 失效需重新登入：

```bash
URL=$(agent-browser get url)
case "$URL" in
  *"/kibana/login"*) echo "需要登入" ;;
  *) echo "已登入" ;;
esac
```

需要登入時：

1. **明確告知使用者**：「Kibana 需要登入。瀏覽器視窗已開啟，請您在視窗中手動完成登入，登入完成請告知。」
2. **不要嘗試代填帳密**，等使用者回覆「已登入」或類似訊息後再繼續。
3. 登入完成後再次 `agent-browser get url` 確認跳出 login 頁。

> 💡 因為使用持久 profile，第一次登入後 cookie 會留在 `~/.agent-browser-kibana`，後續就會免登入直到 session 過期。

## 🔧 查詢 URL 組裝

Kibana Discover URL 結構：

```
https://ll-kibana.sky-net.com.tw/kibana/app/discover#/?
  _g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:'<ISO>',to:'<ISO>'))
  &_a=(columns:!(),filters:!(),
       index:'0788a73a-4957-49de-af25-98a63bfc98ed',   # ★ 永遠是這個
       interval:auto,
       query:(language:kuery,query:'<KQL>'),
       sort:!(!('@timestamp',desc)))
```

關鍵 URL-encode 規則：

| 字元 | 編碼 | 用途 |
|---|---|---|
| `"` (引號) | `%22` | KQL 字串值要包雙引號做 phrase match |
| 空格 | `%20` | KQL 運算子之間 |
| `:` | 保留不編 | KQL `field:value` |

範例 (依 sessionId 找日誌、最近 3 小時)：

```bash
KQL='%22177951338659061493%22'   # "177951338659061493"
TIME_FROM='now-3h' ; TIME_TO='now'
URL="https://ll-kibana.sky-net.com.tw/kibana/app/discover#/?_g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:${TIME_FROM},to:${TIME_TO}))&_a=(columns:!(),filters:!(),index:'0788a73a-4957-49de-af25-98a63bfc98ed',interval:auto,query:(language:kuery,query:'${KQL}'),sort:!(!('@timestamp',desc)))"

agent-browser open "$URL"
agent-browser wait --load networkidle
agent-browser wait 2000
```

精準時間範圍 (ISO 8601 UTC)：

```bash
TIME_FROM="'2026-05-23T05:11:00.000Z'"
TIME_TO="'2026-05-23T05:21:00.000Z'"
```

## 📤 結果擷取

優先用 `eval --stdin` 從 DOM 直接抓取結構化資料，**避免**截圖看不清字。

### 取查詢命中數

```bash
agent-browser eval 'document.querySelector("[data-test-subj=\"discoverQueryHits\"]")?.innerText'
```

### 取目前頁的日誌列

```bash
agent-browser eval --stdin > /tmp/kibana_rows.txt <<'EVALEOF'
(() => {
  const counter = document.querySelector('[data-test-subj="discoverQueryHits"]');
  const rows = Array.from(document.querySelectorAll('[role="row"]'));
  const docs = rows.slice(1).map(r => r.innerText.replace(/\s+/g, ' ').slice(0, 1200));
  return { hits: counter?.innerText, count: docs.length, docs };
})()
EVALEOF
```

### 大型輸出要存檔

Kibana 一筆 log doc 動輒幾 KB，搜尋結果可能上百筆。**所有 eval 結果一律寫入 `/tmp/kibana_<topic>.txt`** 再用 `Read`/`grep` 分析，不要直接把整包塞回對話。

## 🎯 工作流模板

### 模板 A：依 sessionId 定位錯誤 (本 skill 最常見場景)

1. 開 Discover (上面已說明)
2. URL 帶 `query=%22<sessionId>%22`、time 設為「最近 3h」
3. 抓 hits：
   - **0 筆** → 提示「該 sessionId 在 dev_ll_log-* 最近 3 小時無紀錄」，再問是否擴大到 24h
   - **有結果** → 點 "View all matches" 或手動擴大時間範圍鎖到該 session 的精確時段
4. 加二級過濾 `<sessionId> and (ERROR or Exception or "<errorCode>")`
5. 若只命中 DEBUG 級別 → **特別檢查是否誤觸 `error=` 這種欄位名**，並查看完整 doc 內容

### 模板 B：依錯誤碼/錯誤訊息回追

1. 直接搜 `"<errorCode>" and (errCode or respCode or code)` (注意 KQL 雙引號做精準匹配)
2. 找到後抓該 doc 的 sessionId / orderId
3. 改回模板 A 用該 sessionId 做完整呼叫鏈追蹤

### 模板 C：呼叫鏈時序重建

1. 抓到該 session 的時間區間後，把 sort 改成 `@timestamp asc` (URL 內 `sort:!(!('@timestamp',asc))`)
2. 過濾掉 noise：例如 `and not "OrderPolling" and not "Monitor the state" and not MerConfigCache`
3. 滾動載入或翻頁，把 thread / handler / 時間戳排成 sequence diagram (可呼叫 `design-doc-mermaid` skill)

## 🧠 KQL 撇步 (常踩雷)

| 場景 | KQL 寫法 |
|---|---|
| 全文 phrase 精準比對 | `"177951338659061493"` (一定要包雙引號) |
| 多關鍵字 OR | `"9001" or "Exception" or ERROR` |
| 排除字串 | `and not "OrderPolling"` |
| 欄位精準比對 | `tag : "gateway-onl-all"` |
| 萬用排除 noise | `not MerConfigCache and not "Monitor the state"` |
| 大小寫 | KQL 預設 case-**in**sensitive，所以 `ERROR` 也會中 `error` 欄位名 — 這常是誤命中來源 |

## 🧹 收尾

- 中途檔保留在 `/tmp/kibana_*.txt`，可在任務結束建議清掉
- **不要把搜到的訂單號、用戶名等敏感資料寫入** `~/.claude/projects/-Users-robin/memory/`
- **瀏覽器是否關閉**：依對話脈絡判斷
  - 使用者只是順手問一筆 → 任務結束跑 `agent-browser close`
  - 還會接續查多筆 / 對話還沒結束 → 保留 daemon (cookie 仍在 profile 中，下次免登入)
  - 不確定就用 `AskUserQuestion` 問一下「要關閉 Kibana 瀏覽器嗎？」

## ⚠️ 拒絕清單 (Refuse list)

收到以下要求請婉拒，並引導使用者改用其他工具：

| 使用者請求 | 回應 |
|---|---|
| 「切到 prod_ll_log / bak_prod_ll_log」 | 「本 skill 出於安全考量僅允許 `dev_ll_log-*`。如需查 prod 請改用一般 agent-browser 自行操作。」 |
| 「幫我輸入 Kibana 帳密」 | 「我不會代您輸入密碼，請在 headed 視窗中親自完成登入。」 |
| 「修改 Kibana 設定 / 新增 data view」 | 「本 skill 僅供查詢，請改用 Kibana UI 自行設定。」 |
| 「把這些訂單號記到 memory」 | 「日誌中含交易資訊，依規不寫入長期 memory；改放 `/tmp/`。」 |

## 📎 常用 hostname / tag 對照 (供分析 reference)

從這批 dev_ll_log-* 觀察到的常見來源：

| hostname | 角色 | 常見 tag |
|---|---|---|
| ll-dev-gw1 | gateway-onl 對外閘道 | `gateway-onl-all` |
| ll-dev-tc1 | 交易中控 / 通道呼叫 | `outgoing-all` |
| ll-dev-sr1 | 內部 service / RPC | `service-secure-all` |

常出現的 thread / handler 命名：

- `qtp<port>-<n>` — Jetty HTTP 接收 thread (gw1)
- `NioServer-Service--thread-<n>` — RPC 接收 thread (tc1)
- `pool-*-thread-*` — 排程 / Polling 背景執行緒 (多半是雜訊)
- `Log-doSubmit-<n>` — 下單流程 logger 標記
- `Handler-invoke-<n>` / `Service$1-service-<n>` — RPC handler 框架日誌
