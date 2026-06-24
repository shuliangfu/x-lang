# 阶段 F-thread v1（std.thread 去 C）

> **F-thread v1**：删除 **`thread.c`**；模块锚点在 **`thread.sx`**；pthread/CreateThread 封装在 **`thread_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `thread.c`（465 行） | `thread.sx` + `thread_glue.c` |
| `thread.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_THREAD_V1_FAIL=1 ./tests/run-f-thread-v1-gate.sh
./tests/run-std-thread-pool-gate.sh
```

## 下一项

- **F-async v1** ✅ / **F-cache v1**（`cache.c`）
