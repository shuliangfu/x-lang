# 阶段 F-unicode v1（std.unicode 去 C）

> **F-unicode v1**：删除 **`unicode.c`**；模块锚点在 **`unicode.sx`**；分类/NFC/字素簇在 **`unicode_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `unicode.c`（289 行） | `unicode.sx` + `unicode_glue.c` |
| `unicode.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_UNICODE_V1_FAIL=1 ./tests/run-f-unicode-v1-gate.sh
./tests/run-std-unicode-nfc-gate.sh
./tests/run-std-unicode-grapheme-case-gate.sh
```

## 下一项

- **F-unicode v2** ✅ / **F-hash v1** ✅ / **F-dynlib v1**
