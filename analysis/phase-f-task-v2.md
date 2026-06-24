# 阶段 F-task v2（std.task 逻辑 .sx 下沉）

> **F-task v2**：TaskGroup/JoinSet 全量在 **`task.sx`**；**删除 `task_async_glue.c`**；`task.o` 纯 `.sx` 编译。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| TaskGroup/JoinSet | `task_async_glue.c`（269 行） | **`task.sx`** |
| `task.o` | `ld -r` glue + sx | **纯 shux → task.o** |
| `task_echo_fn_ptr_c` | glue 内 C 取址 | **`shux_async_task_echo_fn_ptr_c`**（scheduler 链 task.o 时解析；待 .sx 支持同模块 fn 址后内联） |

## 门禁

```bash
SHUX_F_TASK_V2_FAIL=1 ./tests/run-f-task-v2-gate.sh
./tests/run-std-task-gate.sh
SHUX_F_TASK_V1_FAIL=1 ./tests/run-f-task-v1-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-channel v2** / **F-async-scheduler v2** 等 async 胶层继续下沉
