# 阶段 E-04 v31（asm ELF 大栈 + LSP import 释放迁入 pipeline_abi）

> **E-04 v31**：自 `runtime.c` 将 **asm ELF 大栈 emit**、**entry elf emit 准备**、**typeck 入口包装**、**LSP import 释放** 与 **import dep_dir 提取** 迁入 **`runtime_pipeline_abi.c/h`**。

## v31 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_import_dep_dir_from_path` | 从源文件 path 提取 dep_dir（load_one_import 递归 import） |
| `shux_driver_asm_prepare_entry_elf_emit` | asm_codegen_elf_o 前 skip_heavy + ARRAY_LIT/SoA 补类型 |
| `shux_asm_codegen_elf_o_large_stack` | 256MiB 栈 pthread 上调用 asm_asm_codegen_elf_o |
| `pipeline_typeck_module_for_ctx` | 使用 typeck_ndep 侧车对入口模块 C typecheck |
| `shu_lsp_free_loaded_imports` | 释放 LSP resolve_and_load 写入的 dep 列表 |

## 仍留 runtime.c

- `load_one_import` / `resolve_and_load_imports`（C 前端耦合）
- `run_compiler_c` / `run_compiler_sx_path` 主体
- driver 诊断 `driver_diagnostic_*` 大块

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c
```

## 延后（E-04 v32+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
