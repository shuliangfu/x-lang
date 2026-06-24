# 阶段 F-runtime v1（std.runtime 去 C）

> **F-runtime v1**：删除 **`runtime.c`**；panic/abort 全在 **`runtime.sx`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `runtime.c`（27 行） | `runtime.sx` |
| `runtime.o` | `cc -c runtime.c` | `shux -backend asm runtime.sx` |
| 存量 | std 86 `.c` | std **85** `.c` |

## 门禁

```bash
SHUX_F_RUNTIME_V1_FAIL=1 ./tests/run-f-runtime-v1-gate.sh
./tests/run-std-runtime-panic-hook-gate.sh
```

## 下一项

- **F-log v1** / **F-ffi v1** 等
