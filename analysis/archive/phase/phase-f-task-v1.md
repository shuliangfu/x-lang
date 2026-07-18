# 阶段 F-task v1（std.task 去 C）

> **F-task v1**：删除 **`task.c`**；模块锚点在 **`task.x`**；TaskGroup/JoinSet 在 **`task_async_glue.c`**（async 函数指针 + calloc）。**v2 ✅** 见 `phase-f-task-v2.md`。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `task.c`（270 行） | `task.x` + `task_async_glue.c` |
| `task.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_TASK_V1_FAIL=1 ./tests/run-f-task-v1-gate.sh
./tests/run-std-task-gate.sh
```

## 下一项

- **F-task v2** ✅ / **F-channel v2**
