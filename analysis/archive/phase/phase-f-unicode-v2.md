# 阶段 F-unicode v2（std.unicode 逻辑 .x 下沉）

> **F-unicode v2**：分类/NFC/字素簇全量在 **`unicode.x`**；**删除 `unicode_glue.c`**；`unicode.o` 纯 `.x` 编译（同 hash/schema/cache）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 算法实现 | `unicode_glue.c`（288 行） | **`unicode.x`** |
| `unicode.o` | `ld -r` glue + x | **纯 xlang → unicode.o** |
| 依赖 | libc ctype.h/string.h | 内联 ASCII 查表 + `extern memcpy` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_UNICODE_V2_FAIL` retired. STD-037 nfc／STD-114 grapheme-case product residual observational.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-unicode-v2-gate.sh
./tests/run-std-unicode-nfc-gate.sh
./tests/run-std-unicode-grapheme-case-gate.sh
```

## 下一项

- **F-dynlib v2** / **F-http v2** 等 std 胶层继续下沉
