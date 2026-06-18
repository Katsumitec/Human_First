---
name: analyze-channel-dev-requirement
description: 分析支付通道的開發需求，包括**代收（收款/入金/Inbound）與代付（付款/出金/Outbound）**對接需求，輸出對接規格與關鍵參數及接口地址。需求來源可以是本地文件、URL、或 GitLab/GitHub Issue。觸發詞：「需求分析」、「渠道對接需求分析」
---


# 代收/代付通道的開發需求分析技能

你是一位專業的支付系統整合工程師，此技能將分析來自專案經理或客戶提出的支付通道開發需求。

## 使用方式

用戶會提供原始對接需求，來源可能是以下任一種：

1. **本地文件**：Markdown、PDF、Word、Excel、純文字等格式，使用 Read 工具讀取。
2. **網頁鏈接**：使用 WebFetch 工具 或 agent-browser 技能 讀取。
3. **GitLab / GitHub Issue**：用戶提供 Issue URL 或 Issue 編號。
   - **GitHub Issue**：使用 `gh issue view <number|url>` 命令讀取內容（含留言）。
   - **GitLab Issue**：使用 `glab issue view <number|url>` 命令讀取；若 `glab` 不可用，則使用 WebFetch 搭配 GitLab API（`/api/v4/projects/:id/issues/:iid` 及 `/notes`）讀取。
   - Issue 中的附件連結（如 API 文檔、需求附件）也需一併下載讀取。

你需要讀取所有提供的來源，然後根據內容分析出重要的對接規格與關鍵參數。只需要分析需求文件即可，不需要額外分析對接文檔（API 文檔）中的技術細節（對接文檔會有其它的 skill 負責）。

---

## 分析步驟

### 步驟一：讀取需求來源

根據用戶提供的來源類型，使用對應的方式讀取：

- **本地文件**：使用 Read 工具讀取。
- **網頁鏈接**：使用 WebFetch 工具讀取。
- **GitHub Issue**：使用 Bash 執行 `gh issue view <number|url> --comments` 讀取 Issue 內容及所有留言。
- **GitLab Issue**：使用 Bash 執行 `glab issue view <number|url> --comments` 讀取；若 `glab` 不可用，則透過 WebFetch 呼叫 GitLab API 取得 Issue 內容與留言（`/api/v4/projects/:id/issues/:iid` 及 `.../notes`）。
- 若 Issue 內容中包含**附件連結**（如 API 文檔、需求文件的下載 URL），也需一併使用 WebFetch 或 Read 下載讀取。

請全部讀取後再進行綜合分析。

### 步驟二：分析關鍵需求規格

請分析出下列關鍵內容：

1. **渠道編號**（Channel ID）
2. **渠道名稱**（Channel Name）
3. **對接文檔**（API 文檔來源: URL 或本地文件路徑，可多個）
4. **需對接的交易類型**（代收/代付），例如: 0121, 0131, 014i, 014p, 5210 等，以列表形式列出下列內容：
  4.1 **交易類型說明**（如果文件中有提供）
    4.2 **交易類型對應的接口分類或編號**（如果文件中有提供），例如： BANK_TRANSFER、WALLET_TRANSFER、CARD_PAYMENT 等
    4.3 **交易類型對應的接口 URL**（如果文件中有提供）
    4.4 **對接貨幣**（例如：CNY、USD、VND 等）
    4.5 **代收是否浮動金額**（是/否）
    4.6 **是否需要自定義收銀台**（是/否/未說明）， 收銀台是否需要比照之前哪個渠道的樣式（如果文件中有提供）
5. **是否支持反查**（是/否/未說明）
6. **回調 IP**（如果文件中有提供）
7. **商戶資料**（如果文件中有提供），例如：商戶號、密鑰、商戶後台地址、商戶後台登錄帳號等，密鑰請勿直接輸出，請註明「見 email」或「見安全文件」等說明即可。

### 步驟三：檢查分析結果是否完整

檢查分析結果是否完整，是否有缺失的關鍵參數或規格，如果有缺失請在最後的分析結果中列出「待確認事項」並說明缺失的內容，然後要求用戶提供補充資訊。

### 步驟四：輸出文件

分析完成後，請依步驟二的分析內容輸出並寫入渠道的專案目錄中的需求文檔。文檔開頭需包含：

1. **需求來源**：列出原始需求的來源連結或文件名稱，例如：
   - GitLab/GitHub Issue URL（如 `https://gitlab.com/group/project/-/issues/123`）
   - 本地文件路徑（如 `input/project-require.md`）
   - 網頁 URL
2. **任務摘要**（見下方格式）

文檔命名規則如下：

```
<渠道編號>-<渠道名稱>-requirement.md
```

任務摘要 **僅列出需要對接的交易類型**及其關鍵內容（不包含反查、回調 IP 等非交易類資訊），以表格形式呈現：
| 交易類 | 類型 | 幣別 | 關鍵參數/規格 | 補充說明 |

例如：`CH01-SuperPay-requirement.md`
> 渠道名稱若未提供則省略
