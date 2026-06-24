# 阶段 F-unicode v2（std.unicode 逻辑 .sx 下沉）

> **F-unicode v2**：分类/NFC/字素簇全量在 **`unicode.sx`**；**删除 `unicode_glue.c`**；`unicode.o` 纯 `.sx` 编译（同 hash/schema/cache）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 算法实现 | `unicode_glue.c`（288 行） | **`unicode.sx`** |
| `unicode.o` | `ld -r` glue + sx | **纯 shux → unicode.o** |
| 依赖 | libc ctype.h/string.h | 内联 ASCII 查表 + `extern memcpy` |

## 门禁

```bash
SHUX_F_UNICODE_V2_FAIL=1 ./tests/run-f-unicode-v2-gate.sh
./tests/run-std-unicode-nfc-gate.sh
./tests/run-std-unicode-grapheme-case-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-dynlib v2** / **F-http v2** 等 std 胶层继续下沉
