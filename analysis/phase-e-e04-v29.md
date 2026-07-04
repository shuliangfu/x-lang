# 阶段 E-04 v29（栈/预处理/typeck dep 侧车迁入 ABI）

> **E-04 v29**：**`driver_bump_stack_limit`** / **大栈 pthread** 迁入 **`runtime_driver_abi.c/h`**；**`shux_preprocess_raw_to_malloc`** 与 **typeck dep 侧车** 迁入 **`runtime_pipeline_abi.c/h`**。

## v29 完成（✅）

| 符号 | 目标 TU | 说明 |
|------|---------|------|
| `driver_bump_stack_limit` | driver_abi | RLIMIT_STACK 软上限 64MiB |
| `driver_run_thread_on_large_stack` | driver_abi | 256MiB 栈 pthread |
| `driver_run_on_large_stack_pthread` | driver_abi | LSP 主循环别名 |
| `shux_preprocess_raw_to_malloc` | pipeline_abi | preprocess.x 条件编译 |
| `typeck_dep_*` / `get_dep_*` | pipeline_abi | pipeline_gen 兼容 dep 槽 |
| `pipeline_set_dep` / `pipeline_set_ndep` | pipeline_abi | pipeline.x 写 dep |
| `driver_typeck_dep_sidecar_clear` | pipeline_abi | clear_all 同步清侧车 |

## 仍留 runtime.c

- `load_one_import` / `resolve_and_load_imports` / `run_compiler_c` 主体
- dep 预跑 `pipeline_dep_prerun_*`、`pipeline_run_x_pipeline_large_stack`
- pipeline I/O 原语（`pipeline_resolve_path` / `pipeline_read_file` 等）

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c compiler/src/runtime_driver_abi.c
```

## 延后（E-04 v31+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
