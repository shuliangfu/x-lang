# 阶段 F-trace v1（std.trace 去 C）

> **F-trace v1**：删除 **`trace.c`**；烟测在 **`trace.sx`**；span 栈/export 在 **`trace_span_glue.c`**（**v2 已迁入 trace.sx 并删 glue**）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `trace.c`（252 行） | `trace.sx` + `trace_span_glue.c` → **v2 纯 trace.sx** |
| `trace.o` | `cc -c` | `ld -r` 合并 → **v2 纯 shux** |

## 门禁

```bash
SHUX_F_TRACE_V1_FAIL=1 ./tests/run-f-trace-v1-gate.sh
./tests/run-std-trace-gate.sh
./tests/run-std-trace-hooks-gate.sh
```

## 下一项

- **F-trace v2** ✅（span/export 逻辑下沉，删 glue）
