# 阶段 F-unicode v1（std.unicode 去 C）

> **F-unicode v1**：删除 **`unicode.c`**；模块锚点在 **`unicode.x`**；分类/NFC/字素簇在 **`unicode_glue.c`**（**v2 已删 glue**）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `unicode.c`（289 行） | `unicode.x` + `unicode_glue.c` → **v2 纯 `.x`** |
| `unicode.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_UNICODE_V1_FAIL` retired. STD-037 nfc／grapheme-case observational (product residual／复探红).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-unicode-v1-gate.sh
./tests/run-std-unicode-nfc-gate.sh
./tests/run-std-unicode-grapheme-case-gate.sh
```

## 下一项

- **F-unicode v2** ✅ / **F-hash v1** ✅ / **F-dynlib v1**
