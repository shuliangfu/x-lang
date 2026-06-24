# 阶段 E-04 v27（import/load 辅助与 argv 宏收集迁入 ABI）

> **E-04 v27**：自 `runtime.c` 将 load/import 周边 helper 迁入 **`runtime_pipeline_abi.c/h`**；**`driver_argv_collect_defines`** 迁入 **`runtime_driver_abi.c/h`**。

## v27 完成（✅）

| 符号 | 目标 TU | 说明 |
|------|---------|------|
| `shux_find_loaded_import_index` | pipeline_abi | 已加载 import 去重查下标 |
| `shux_dep_prerun_entry_dir` | pipeline_abi | dep 预跑 entry_dir（-L 优先） |
| `shux_entry_lib_name_from_path` | pipeline_abi | -E 库模块 C 前缀 |
| `shux_emit_pipeline_glue_include` | pipeline_abi | -E pipeline.sx 胶水 include |
| `driver_asm_fclose_asm_out` | pipeline_abi | asm 写出（stdout 仅 fflush） |
| `shux_asm_out_buf_is_object` | pipeline_abi | Mach-O/ELF 对象魔数检测 |
| `driver_argv_collect_defines` | driver_abi | -D / -target / uname 宏收集 |

## 仍留 runtime.c

- `load_one_import` / `resolve_and_load_imports` 主体（耦合 lexer/parser/typeck）
- `runtime_one_ctx_for_dep_prerun`（访问 `ast_PipelineDepCtx` 字段）
- `driver_typeck_dep_sidecar_clear` 钩子

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c
```

## 延后（E-04 v29+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
