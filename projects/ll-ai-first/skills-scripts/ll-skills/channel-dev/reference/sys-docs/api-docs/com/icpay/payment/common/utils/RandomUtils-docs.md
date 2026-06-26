# RandomUtils

類別名稱：`com.icpay.payment.common.utils.RandomUtils`

## 說明

隨機數據生成工具集，用於產生各種測試用的隨機資料，包括：隨機數值、隨機字串、隨機中英文姓名、隨機電子郵件、隨機手機號碼、隨機地址、隨機 IP 位址、隨機店鋪名稱等。主要用於系統測試、模擬交易資料產生等場景。在 FreeMarker 模板中以 `rand` 物件存取。

## 架構

- **Package**: `com.icpay.payment.common.utils`
- **Maven Artifact**: `com.ppay:icpay-common-utils`
- **繼承**: 無（獨立工具類別）
- **相依性**:
  - `java.util.concurrent.ThreadLocalRandom`
  - `com.icpay.payment.common.utils.Utils`

## API 說明

### Class: RandomUtils

#### Public 部分

##### 屬性

| 屬性 | 型別 | 說明 |
|------|------|------|
| `alpha` | `String` | 小寫英文字母字元集 `"abcdefghijklmnopqrstuvwxyz"` |
| `base` | `String` | 小寫英文字母 + 數字字元集 `"abcdefghijklmnopqrstuvwxyz0123456789"` |

---

##### 方法 — 基礎隨機數

###### `getInt`

```java
public static int getInt(int start, int end)
```

獲取隨機整數 x，範圍 `start <= x <= end`。

```java
int dice = RandomUtils.getInt(1, 6); // 1~6 的隨機整數
```

###### `getLong`

```java
public static long getLong(long start, long end)
```

獲取隨機長整數 x，範圍 `start <= x <= end`。

```java
// 產生隨機交易金額（單位：分），範圍 100~999999（即 1.00~9999.99 元）
long amount = RandomUtils.getLong(100L, 999999L);

// 產生隨機訂單號範圍
long orderSuffix = RandomUtils.getLong(10000000L, 99999999L);
```

###### `getStr`（字元集版）

```java
public static String getStr(String chars, int len)
```

從指定字元集中隨機取字元組成指定長度的字串。

```java
String s = RandomUtils.getStr(RandomUtils.alpha, 8);
// 範例輸出: "kcmqwtze"

// 使用自訂字元集產生純數字字串
String digits = RandomUtils.getStr("0123456789", 6);
// 範例輸出: "384712"

// 使用 base 字元集（字母+數字）
String token = RandomUtils.getStr(RandomUtils.base, 16);
// 範例輸出: "k3mq5tw2ze9ab1xp"
```

###### `getStr`（預設版）

```java
public static String getStr(int len)
```

獲取隨機字串（小寫字母 + 數字），委託 `Utils.getRandomString`。

```java
// 產生 12 位隨機字串作為測試 nonce
String nonce = RandomUtils.getStr(12);
// 範例輸出: "a3k9m2x7p5q1"
```

###### `getStrCase`

```java
public static String getStrCase(int len)
```

獲取隨機字串（區分大小寫），委託 `Utils.getRandomString2`。

```java
// 產生含大小寫的隨機字串，適合模擬 token 或密鑰
String token = RandomUtils.getStrCase(32);
// 範例輸出: "aK3mQ5tW2zE9Ab1XpLcR7nG4sU6vY8hJ"
```

###### `getBytes`

```java
public static byte[] getBytes(int len)
```

獲取隨機 byte 陣列，委託 `Utils.getRandomBytes`。

```java
// 產生 16 位元組隨機資料，可用於 AES 金鑰或 IV
byte[] key = RandomUtils.getBytes(16);

// 產生 32 位元組隨機資料
byte[] salt = RandomUtils.getBytes(32);
```

###### `getRandomIndex`

```java
public static Integer getRandomIndex(Integer size)
```

回傳隨機索引，範圍 `0 <= index < size`。

```java
// 從清單中隨機取一個元素
List<String> urls = Arrays.asList("https://api1.example.com", "https://api2.example.com");
int idx = RandomUtils.getRandomIndex(urls.size());
String selectedUrl = urls.get(idx);
```

###### `getRandomInSet`

| 簽名 | 說明 |
|------|------|
| `getRandomInSet(String... set)` | 隨機回傳 String 集合中的元素 |
| `getRandomInSet(Integer... set)` | 隨機回傳 Integer 集合中的元素 |
| `getRandomInSet(Long... set)` | 隨機回傳 Long 集合中的元素 |
| `getRandomInSet(Object... set)` | 隨機回傳 Object 集合中的元素 |

```java
// 隨機選取幣別
String currency = RandomUtils.getRandomInSet("CNY", "USD", "EUR", "JPY");

// 隨機選取交易狀態碼
Integer statusCode = RandomUtils.getRandomInSet(0, 1, 2, 3);

// 隨機選取測試金額（Long 型別）
Long amount = RandomUtils.getRandomInSet(1000L, 2000L, 5000L, 10000L);

// 在 FreeMarker 模板中使用
// ${rand.getRandomInSet("SALE", "AUTH", "REFUND")}
```

---

##### 方法 — 電子郵件

###### `getEmail`

| 簽名 | 說明 |
|------|------|
| `getEmail()` | 回傳隨機 Email（userId 長度 8~16） |
| `getEmail(int lMin, int lMax)` | 指定 userId 最小/最大長度 |

```java
String email = RandomUtils.getEmail();
// 範例輸出: "kxmq5tw2ze@gmail.com"

// 指定 userId 長度範圍為 5~10
String shortEmail = RandomUtils.getEmail(5, 10);
// 範例輸出: "ab3k9@163.com"
```

###### `getPopularEmail`

| 簽名 | 說明 |
|------|------|
| `getPopularEmail()` | 回傳隨機 Email（使用常見國際域名） |
| `getPopularEmail(int lMin, int lMax)` | 指定 userId 長度範圍 |

```java
// 產生使用國際常見域名的 Email（gmail, outlook, protonmail 等）
String email = RandomUtils.getPopularEmail();
// 範例輸出: "m3xq9kzp@outlook.com"

String email2 = RandomUtils.getPopularEmail(6, 12);
// 範例輸出: "t7abc2@protonmail.com"
```

---

##### 方法 — 電話號碼

###### `getPhoneNum`

```java
public static String getPhoneNum()
```

獲取隨機中國手機號碼（包含真實的運營商號段前綴）。

```java
String phone = RandomUtils.getPhoneNum();
// 範例輸出: "13856781234"

// 在 FreeMarker 模板中使用
// ${rand.getPhoneNum()}
```

###### `getRandomMobileForChina`

```java
public static String getRandomMobileForChina()
```

回傳隨機中國手機號碼（另一種實現，使用不同號段前綴集）。

```java
String mobile = RandomUtils.getRandomMobileForChina();
// 範例輸出: "15887654321"
// 格式為 3 位運營商前綴 + 8 位隨機數字
```

---

##### 方法 — 姓名

###### `getChineseName`

| 簽名 | 說明 |
|------|------|
| `getChineseName()` | 回傳隨機中文姓名（性別隨機，男 55% / 女 45%） |
| `getChineseName(int sex)` | 指定性別，`0` = 女, `1` = 男 |

```java
String name = RandomUtils.getChineseName();     // 隨機性別
String femaleName = RandomUtils.getChineseName(0); // 女性名
String maleName = RandomUtils.getChineseName(1);   // 男性名
// 範例輸出: "李秀娟"（女）、"王伟刚"（男）
// 姓名可能為 2 字或 3 字（隨機決定）
```

###### `getChineseFirstName`

```java
public static String getChineseFirstName()
```

回傳隨機中文姓氏，百家姓常見姓氏佔比 70%。

```java
String surname = RandomUtils.getChineseFirstName();
// 範例輸出: "李"、"王"、"張"（常見姓氏機率較高）
```

###### `getSexByChineseName`

```java
public static int getSexByChineseName(String name)
```

根據中文姓名判斷性別。回傳值：`0` = 女, `1` = 男, `-1` = 無法判別。

```java
int sex1 = RandomUtils.getSexByChineseName("李秀娟"); // 回傳 0（女）
int sex2 = RandomUtils.getSexByChineseName("王伟刚"); // 回傳 1（男）
int sex3 = RandomUtils.getSexByChineseName(null);      // 回傳 -1（無法判別）
int sex4 = RandomUtils.getSexByChineseName("李");      // 回傳 -1（名字太短）

// 搭配 getChineseName 使用
String name = RandomUtils.getChineseName();
int sex = RandomUtils.getSexByChineseName(name);
String sexStr = (sex == 0) ? "女" : (sex == 1) ? "男" : "未知";
```

###### `getEnglishName`

| 簽名 | 說明 |
|------|------|
| `getEnglishName()` | 回傳隨機英文全名（含姓），全大寫 |
| `getEnglishName(int sex)` | 指定性別，`0` = 女, `1` = 男 |
| `getEnglishName(int sex, int mode, boolean includeLastName)` | 完整控制輸出格式 |
| `getEnglishName(int mode, boolean includeLastName)` | 性別隨機，控制格式 |

`mode` 參數：
- `0` = 全大寫（如 `JIMMY SMITH`）
- `1` = 首字母大寫（如 `Jimmy Smith`）
- `2` = 全小寫（如 `jimmy smith`）

```java
// 預設全大寫含姓
String name1 = RandomUtils.getEnglishName();
// 範例輸出: "ABEL GATES"

// 指定性別
String femaleName = RandomUtils.getEnglishName(0);
// 範例輸出: "SOPHIE WHITE"

// 首字母大寫，含姓
String name2 = RandomUtils.getEnglishName(1, 1, true);
// 範例輸出: "Jimmy Smith"

// 僅取名（不含姓），首字母大寫
String firstName = RandomUtils.getEnglishName(0, 1, false);
// 範例輸出: "Sophie"

// 全小寫，含姓
String name3 = RandomUtils.getEnglishName(2, true);
// 範例輸出: "jimmy smith"

// 在 FreeMarker 模板中使用
// ${rand.getEnglishName(1, 1, true)}
```

###### `outputEnglishName`

```java
public static String outputEnglishName(String name, int mode, boolean includeLastName)
```

以指定格式輸出已有的英文名。

```java
// 將全大寫名字轉為首字母大寫格式
String formatted = RandomUtils.outputEnglishName("JIMMY SMITH", 1, true);
// 輸出: "Jimmy Smith"

// 僅取名，全小寫
String first = RandomUtils.outputEnglishName("SOPHIE WHITE", 2, false);
// 輸出: "sophie"

// 僅取名，全大寫
String firstUpper = RandomUtils.outputEnglishName("SOPHIE WHITE", 0, false);
// 輸出: "SOPHIE"
```

---

##### 方法 — 地址

###### `getRoad`

```java
public static String getRoad()
```

回傳隨機地址（格式：路名 + 號 + 樓層）。

```java
String addr = RandomUtils.getRoad();
// 範例輸出: "重庆大厦56号-12-3"
```

###### `getRoadForChina`

```java
public static String getRoadForChina()
```

回傳隨機中國地址（包含中文樓層格式，如 `"5楼之3"`, `"8楼2室"` 等）。

```java
String addr = RandomUtils.getRoadForChina();
// 可能的輸出格式:
// "黑龙江路88号12楼3室"   （40% 機率）
// "十梅庵街45号5楼之3"    （20% 機率）
// "遵义路120号8F-2"       （20% 機率）
// "湘潭街33号"            （20% 機率，無樓層資訊）
```

###### `getStoreNameForChina`

```java
public static String getStoreNameForChina()
```

生成隨機中文店鋪名稱。

```java
String store = RandomUtils.getStoreNameForChina();
// 範例輸出: "重庆秀娟小店"、"黑龙伟刚店"、"十梅华慧旗舰店"
// 格式為：地名前兩字 + 兩個隨機名字用字 + 店鋪後綴（店/小店/旗舰店）
```

---

##### 方法 — IP 位址

###### `getRandomIp`

```java
public static String getRandomIp()
```

獲取隨機全球 IP 位址。

```java
String ip = RandomUtils.getRandomIp();
// 範例輸出: "42.187.56.123"
```

###### `getRandomIpForChina`

```java
public static String getRandomIpForChina()
```

獲取隨機中國 IP 位址（限定在中國 IP 段範圍內）。

```java
String ip = RandomUtils.getRandomIpForChina();
// 範例輸出: "106.85.123.45"
// 涵蓋的 IP 段包括: 36.56.x.x, 61.232.x.x, 106.80.x.x,
// 121.76.x.x, 123.232.x.x, 139.196.x.x, 171.8.x.x,
// 182.80.x.x, 210.25.x.x, 222.16.x.x 等

// 在 FreeMarker 模板中模擬客戶端 IP
// ${rand.getRandomIpForChina()}
```

#### Protected 部分

無 protected 成員。
