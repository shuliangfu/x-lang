# STD-037：std.unicode 非 BMP 与 NFC 规范化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`std.encoding` UTF-8、既有 `category` / `to_lower`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-unicode-nfc.tsv` |
| 3 | `./tests/run-std-unicode-nfc-gate.sh` |
| 4 | 金样：`tests/unicode/nfc_gold.x` |

---

## 2. NFC 规范化

| API | 说明 |
|-----|------|
| `nfc_buf(in, in_len, out, out_cap)` | 缓冲 NFC（v1 **拉丁预组合子集**） |

**金样向量**（`nfc_gold.x`）：

| 输入 | 期望 NFC 输出 |
|------|----------------|
| `e` + U+0301 | `é`（UTF-8 `C3 A9`） |
| 已预组合 `é` | 不变 |
| ASCII `abc` | 不变 |
| U+1F600 emoji | UTF-8 直通（4 字节） |

v1 **不**实现全量 Unicode 15 NFC 表；仅覆盖 gate 金样与常见拉丁组合对。

---

## 3. 非 BMP 码点

| API | 说明 |
|-----|------|
| `is_supplementary(rune)` | `rune > U+FFFF` |
| `rune_utf8_len(rune)` | 单码点 UTF-8 长度 1..4 |

与 `std.encoding.utf8_*` 互补：encoding 管通用 UTF-8 流；unicode 管码点语义与 NFC。

---

## 4. 验证与门禁

```bash
./tests/run-std-unicode-nfc-gate.sh
```

```
shux: [SHUX_STD_UNICODE_NFC] status=ok nfc=1 main=1 skip=0
```

---

## 5. 非目标（v1）

- Hangul 音节组合
- 全量 Unicode 15 分解/组合表
- NFKD 额外兼容映射（全角/连字等）

NFD/NFKC/NFKD 基础集见 **STD-082**：`analysis/std-unicode-normalization-v1.md`。
