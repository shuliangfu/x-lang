# 阶段 F-log v1（std.log 去 C）

> **F-log v1**：删除 **`log.c`**；格式化在 **`log.x`**；sink/轮转/异步在 **`compiler/src/asm/runtime_log_os.c`**（F-ZC）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `log.c`（386 行） | `log.x` + `runtime_log_os.c` |
| `log.o` | `cc -c log.c` | 纯 `shux -backend asm log.x` |
| OS 胶层 | `std/log/log_os_glue.c` | `compiler/runtime_log_os.o`（与 log.o 同链） |
| 存量 | std 83 `.c` | std **54** `.c`（log_os_glue 已迁出 std） |

## 门禁

```bash
SHUX_F_LOG_V1_FAIL=1 ./tests/run-f-log-v1-gate.sh
./tests/run-std-log-multi-sink-gate.sh
./tests/run-std-log-rotate-async-gate.sh
```

## 下一项

- **F-atomic v1** / **Z8** 其它胶层
