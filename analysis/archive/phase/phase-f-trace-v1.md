# 阶段 F-trace v1（std.trace 去 C）

> **F-trace v1**：删除 **`trace.c`**；烟测在 **`trace.x`**；span 栈/export 在 **`trace_span_glue.c`**（**v2 已迁入 trace.x 并删 glue**）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `trace.c`（252 行） | `trace.x` + `trace_span_glue.c` → **v2 纯 trace.x** |
| `trace.o` | `cc -c` | `ld -r` 合并 → **v2 纯 xlang** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_TRACE_V1_FAIL` retired. STD-088／hooks observational (fossil `trace_new` vs live `new`).

**2026-08-30 leftover XLANG fallthrough 已收**（f-trace-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-trace／std-trace-hooks 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-trace-v1-gate.sh
./tests/run-std-trace-gate.sh
./tests/run-std-trace-hooks-gate.sh
```

## 下一项

- **F-trace v2** ✅（span/export 逻辑下沉，删 glue）
