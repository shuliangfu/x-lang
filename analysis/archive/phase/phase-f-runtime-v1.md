# 阶段 F-runtime v1（std.runtime 去 C）

> **F-runtime v1**：删除 **`runtime.c`**；panic/abort 全在 **`runtime.x`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `runtime.c`（27 行） | `runtime.x` |
| `runtime.o` | `cc -c runtime.c` | `xlang -backend asm runtime.x` |
| 存量 | std 86 `.c` | std **85** `.c` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_RUNTIME_V1_FAIL` retired. Delegates STD-028 runtime-panic-hook hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-runtime-v1-gate.sh
./tests/run-std-runtime-panic-hook-gate.sh
```


## 下一项

- **F-log v1** / **F-ffi v1** 等
