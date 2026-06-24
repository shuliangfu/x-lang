# 阶段 F-backtrace v1（std.backtrace 去 C）

> **F-backtrace v1**：删除 **`backtrace.c`**；模块锚点在 **`backtrace.sx`**；capture/symbolicate 在 **`backtrace_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `backtrace.c`（329 行） | `backtrace.sx` + `backtrace_glue.c` |
| `backtrace.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_BACKTRACE_V1_FAIL=1 ./tests/run-f-backtrace-v1-gate.sh
./tests/run-std-backtrace-symbolicate-gate.sh
./tests/run-std-backtrace-xplat-gate.sh
```

## 下一项

- **F-http v1** ✅ / **F-tar v1**
