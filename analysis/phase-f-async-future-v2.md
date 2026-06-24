# 阶段 F-async-future v2（std.async Future 逻辑 .sx 下沉）

> **F-async-future v2**：Future/Poll 全量在 **`future.sx`**；**删除 `future_glue.c`**；`scheduler_glue.c` 暂留；`future.o` 纯 `.sx` 编译。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| Future 实现 | `future_glue.c`（157 行） | **`future.sx`** |
| `future.o` | `ld -r` glue + sx | **纯 shux → future.o** |
| wait 依赖 | glue 内 weak drain/poll | **`extern` 弱桩**（scheduler 链入时覆盖） |

## 门禁

```bash
SHUX_F_ASYNC_FUTURE_V2_FAIL=1 ./tests/run-f-async-future-v2-gate.sh
./tests/run-std-async-future-gate.sh
SHUX_F_ASYNC_V1_FAIL=1 ./tests/run-f-async-v1-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-async-scheduler v2** / **F-channel v2** 等 async 胶层继续下沉
