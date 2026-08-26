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

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-regex-v1-gate.sh
```


## 下一项

- **F-regex v2** ✅
