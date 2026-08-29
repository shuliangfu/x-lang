# 阶段 F-dynlib v1（std.dynlib 去 C）

> **F-dynlib v1**：删除 **`dynlib.c`**；模块锚点在 **`dynlib.x`**；dlopen/LoadLibrary 在 **`dynlib_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `dynlib.c`（173 行） | `dynlib.x` + `dynlib_glue.c` |
| `dynlib.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_DYNLIB_V1_FAIL` retired. Delegates STD-027 dynlib-windows + STD-096 last-error hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-dynlib-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-dynlib-windows／std-dynlib-last-error 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-dynlib-v1-gate.sh
./tests/run-std-dynlib-windows-gate.sh
./tests/run-std-dynlib-last-error-gate.sh
```

## 下一项

- **F-backtrace v1** ✅ / **F-http v1**
