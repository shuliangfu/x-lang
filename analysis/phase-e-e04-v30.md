# 阶段 E-04 v30（pipeline I/O 原语与 dep 预跑迁入 pipeline_abi）

> **E-04 v30**：自 `runtime.c` 将 **pipeline I/O 原语**（resolve/read/parse/slot）与 **dep 预跑 / 大栈 pipeline** 迁入 **`runtime_pipeline_abi.c/h`**。

## v30 完成（✅）

| 符号 | 说明 |
|------|------|
| `pipeline_set_entry_dir` / `pipeline_set_dep_slots` | pipeline.x 编排 entry/lib |
| `pipeline_resolve_path` / `pipeline_read_file` | import 路径解析与读入 preprocess |
| `pipeline_get_dep_*_slot` / `pipeline_parse_into_loaded_import` | dep 槽与 parse |
| `shux_pipeline_run_x_pipeline_large_stack` | 大栈 pthread 跑 pipeline |
| `shux_pipeline_dep_prerun_*` | dep 预跑 parse/typeck 变体 |

## 仍留 runtime.c

- `load_one_import` / `resolve_and_load_imports` / `run_compiler_c` 主体
- `asm_asm_codegen_elf_o_large_stack` 等 asm ELF 路径
- driver 诊断 `driver_diagnostic_*` 大块

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c
```

## 延后（E-04 v31+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
