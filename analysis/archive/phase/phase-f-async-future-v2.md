# 阶段 F-async-future v2（std.async Future 逻辑 .x 下沉）

> **F-async-future v2**：Future/Poll 全量在 **`future.x`**；**删除 `future_glue.c`**；`scheduler_glue.c` 暂留；`future.o` 纯 `.x` 编译。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| Future 实现 | `future_glue.c`（157 行） | **`future.x`** |
| `future.o` | `ld -r` glue + x | **纯 xlang → future.o** |
| wait 依赖 | glue 内 weak drain/poll | **`extern` 弱桩**（scheduler 链入时覆盖） |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_ASYNC_FUTURE_V2_FAIL` retired. STD-041 async-future product residual observational (c smoke).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-async-future-v2-gate.sh
./tests/run-std-async-future-gate.sh
```

## 下一项

- **F-async-scheduler v2** / **F-channel v2** 等 async 胶层继续下沉
