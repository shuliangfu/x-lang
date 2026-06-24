# 阶段 E-04 v28（PipelineDepCtx 填充与 pipeline 诊断迁入 ABI）

> **E-04 v28**：`PipelineDepCtx` 布局与填充/seed helper、asm dep 路径判定迁入 **`runtime_pipeline_abi.c/h`**；**`driver_pipeline_fail_code`** / **`driver_print_sx_smoke_summary`** / **`driver_peek_source_file`** 迁入 **`runtime_driver_abi.c/h`**。

## v28 完成（✅）

| 符号 | 目标 TU | 说明 |
|------|---------|------|
| `struct ast_PipelineDepCtx` | pipeline_abi.h | 与 ast.sx 布局一致 |
| `shux_pipeline_fill_ctx_path_buffers` | pipeline_abi | entry_dir / lib_root sidecar |
| `shux_pipeline_pctx_seed_dep_slots` | pipeline_abi | dep 槽写入 ctx |
| `shux_pipeline_one_ctx_for_dep_prerun` | pipeline_abi | 单 dep 预跑 ctx 重置 |
| `shux_asm_user_*` | pipeline_abi | asm 用户 std dep 路径判定 |
| `driver_pipeline_fail_code` | driver_abi | pipeline rc 诊断 |
| `driver_print_sx_smoke_summary` | driver_abi | parse/typeck 烟测 stderr |
| `driver_peek_source_file` | driver_abi | 源文件前缀探测 |

## 仍留 runtime.c

- `load_one_import` / `resolve_and_load_imports` / `run_compiler_c` 主体
- dep 预跑 `pipeline_dep_prerun_*`、大栈 pthread 包装
- `driver_typeck_dep_sidecar_clear` 钩子

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c compiler/src/runtime_driver_abi.c
```

## 延后（E-04 v30+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
