# 阶段 E-04 v25（pipeline/asm 状态迁入 runtime_driver_abi）

> **E-04 v25**：自 `runtime.c` 将 pipeline 入口长度、asm 环境标志、dep codegen 路径与 OBS-001 阶段计时迁入 **`runtime_driver_abi.c/h`**（v22 扩展）。

## v25 完成（✅）

| 符号 | 说明 |
|------|------|
| `driver_set_pipeline_entry_source_len` / `driver_pipeline_entry_source_len` | 入口源码长度 |
| `driver_typeck_skip_large_entry` | 大模块跳过 merge typeck |
| `driver_asm_build_skip_typeck` | `SHUX_ASM_BUILD_SKIP_TYPECK` |
| `driver_asm_entry_emit_heavy` | `SHUX_ASM_ENTRY_EMIT_HEAVY` |
| `driver_asm_entry_module_only_from_env` | `SHUX_ASM_ENTRY_MODULE_ONLY` |
| `driver_skip_codegen_dep_0_*` | exe 路径跳过 dep0 codegen |
| `driver_set/get_current_dep_path_for_codegen` | codegen C 符号前缀 |
| `driver_compile_phase_timing_*` | `SHUX_COMPILE_PHASE_TIMING` |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_driver_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v27+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
