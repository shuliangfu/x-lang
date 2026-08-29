# 阶段 F-csv v1（std.csv 去 C）

> **F-csv v1**：删除 **`csv.c`**；RFC 4180 解析/写回/流式 smoke 全量在 **`csv.x`**（零胶层）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `csv.c`（271 行） | `csv.x` |
| `csv.o` | `cc -c` | `xlang -backend asm` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CSV_V1_FAIL` retired. Delegates STD-036 csv-row hard. STD-128 csv-stream observational (asm UNDEF residual).

**2026-08-30 leftover XLANG fallthrough 已收**（f-csv-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-csv-row／std-csv-stream 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-csv-v1-gate.sh
./tests/run-std-csv-row-gate.sh
```

## 下一项

- **F-json v1** ✅ / **F-regex v1** ✅ / **F-unicode v1**
