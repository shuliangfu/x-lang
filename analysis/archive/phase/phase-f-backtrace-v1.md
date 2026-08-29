# 阶段 F-backtrace v1（std.backtrace 去 C）

> **F-backtrace v1**：删除 **`backtrace.c`**；模块锚点在 **`backtrace.x`**；capture/symbolicate 在 **`backtrace_glue.c`**（**v2 已拆**）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `backtrace.c`（329 行） | `backtrace.x` + `backtrace_glue.c` → **v2** |
| `backtrace.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_BACKTRACE_V1_FAIL` retired. Delegates STD-052 symbolicate hard. STD-147 xplat observational (fossil DOC sections).

**2026-08-30 leftover XLANG fallthrough 已收**（f-backtrace-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-backtrace-symbolicate／std-backtrace-xplat 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-backtrace-v1-gate.sh
./tests/run-std-backtrace-symbolicate-gate.sh
./tests/run-std-backtrace-xplat-gate.sh
```

## 下一项

- **F-http v1** ✅ / **F-tar v1**
