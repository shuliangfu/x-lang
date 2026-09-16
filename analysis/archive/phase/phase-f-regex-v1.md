# 阶段 F-regex v1（std.regex 去 C）

> **F-regex v1**：删除 **`regex.c`**；模块锚点在 **`regex.x`**。  
> **F-regex v2** ✅：引擎自 **`regex_min.inc.c`** 全量迁入 **`regex.x`**；已删 glue/inc。

## 变更

| 项 | 前 | v1 | v2 |
|----|----|-----|-----|
| 实现 | `regex.c` | `regex.x` + glue/inc | **`regex.x` 纯 .x** |
| `regex.o` | `cc -c` | `ld -r` | **纯 xlang** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_REGEX_V1_FAIL` retired. Static + ensure hard; STD-051 regex smoke observational (listed skip encoding-extra／regex／net-tls product residual).

**2026-08-30 leftover XLANG fallthrough 已收**（f-regex-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-regex 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-regex-v1-gate.sh
```


## 下一项

- **F-regex v2** ✅
