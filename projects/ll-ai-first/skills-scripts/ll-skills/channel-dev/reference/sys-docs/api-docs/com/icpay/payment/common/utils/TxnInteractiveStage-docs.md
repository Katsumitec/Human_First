# TxnInteractiveStage

類別名稱：`com.icpay.payment.common.utils.TxnInteractiveStage`

## 說明

`TxnInteractiveStage` 是一個 Java 列舉（Enum），定義了交易過程中的各個交互階段。每個列舉值對應一個階段名稱字串，用於標記當前處理所處的交易階段。

此列舉在 `ChnlBaseTools` 及其子類（如 `ChnlServiceBase`、`MyChnlBase` 等）中使用，用於標記當前正在處理的交易階段，例如：發送交易請求、接收交易回應、發送查詢請求、接收查詢回應、接收異步通知等。透過階段標記，系統可在不同階段執行對應的處理邏輯（如簽名、驗簽、加密、解密等）。

## 架構

- **Package**：`com.icpay.payment.common.utils`
- **類型**：`enum`
- **所屬模組**：`icpay-service-common`（Maven artifact: `com.ppay:icpay-service-common`）
- **繼承**：`java.lang.Enum<TxnInteractiveStage>`
- **相依性**：無外部相依性

## API 說明

### Enum: TxnInteractiveStage

#### Public 部分

##### 列舉值

| 列舉值 | 階段名稱（stageName） | 說明 |
|--------|----------------------|------|
| `NONE` | `"None"` | 無階段／預設值，表示不在任何特定交易交互階段 |
| `TXN_REQUEST` | `"TxnRequest"` | 交易請求階段，表示正在組裝並發送交易請求至渠道 |
| `TXN_RESPONSE` | `"TxnResponse"` | 交易回應階段，表示正在處理渠道回傳的交易回應 |
| `QRY_REQUEST` | `"QryRequest"` | 查詢請求階段，表示正在組裝並發送查詢請求至渠道 |
| `QRY_RESPONSE` | `"QryResponse"` | 查詢回應階段，表示正在處理渠道回傳的查詢回應 |
| `NOTIFY` | `"Notify"` | 通知階段，表示正在處理渠道發送的異步通知 |

##### 方法

###### `getStageName()`

```java
public String getStageName()
```

- **說明**：取得該列舉值對應的階段名稱字串。
- **參數**：無
- **回傳值**：`String` — 階段名稱（例如 `"TxnRequest"`、`"Notify"`）

**使用案例**：

```java
TxnInteractiveStage stage = TxnInteractiveStage.TXN_REQUEST;
String name = stage.getStageName(); // "TxnRequest"
```

---

###### `toString()`

```java
@Override
public String toString()
```

- **說明**：覆寫 `Object.toString()`，回傳與 `getStageName()` 相同的階段名稱字串。
- **參數**：無
- **回傳值**：`String` — 階段名稱

**使用案例**：

```java
TxnInteractiveStage stage = TxnInteractiveStage.NOTIFY;
System.out.println(stage); // 輸出: Notify
```

---

###### `fromString(String stageName)`

```java
public static TxnInteractiveStage fromString(String stageName)
```

- **說明**：靜態方法，透過階段名稱字串取得對應的列舉值。比對時忽略大小寫（`equalsIgnoreCase`）。若找不到匹配的列舉值，將拋出 `IllegalArgumentException`。
- **參數**：
  - `stageName`（`String`）— 要查詢的階段名稱字串
- **回傳值**：`TxnInteractiveStage` — 對應的列舉值
- **例外**：`IllegalArgumentException` — 當傳入的 `stageName` 無法匹配任何列舉值時拋出

**使用案例**：

```java
// 正常使用
TxnInteractiveStage stage = TxnInteractiveStage.fromString("TxnRequest");
// stage == TxnInteractiveStage.TXN_REQUEST

// 忽略大小寫
TxnInteractiveStage stage2 = TxnInteractiveStage.fromString("notify");
// stage2 == TxnInteractiveStage.NOTIFY

// 無效名稱將拋出例外
TxnInteractiveStage stage3 = TxnInteractiveStage.fromString("Unknown");
// 拋出 IllegalArgumentException: Unknown stage name: Unknown
```
