# 阶段 E-04 v34（driver 诊断块迁入 runtime_driver_diagnostic TU）

> **E-04 v34**：自 `runtime.c` 将 **driver_diagnostic_* / parser_diag_* / typeck 诊断 scratch** 整块拆至 **`runtime_driver_diagnostic.c/h`**（OBJS_CORE + DRIVER_SEED_OBJS）。

## v34 完成（✅）

| 符号组 | TU | 说明 |
|--------|-----|------|
| `driver_diagnostic_parse_*` / `driver_diagnostic_typeck_*` | runtime_driver_diagnostic.c | pipeline/typeck/asm 诊断 |
| `driver_diagnostic_asm_*` | runtime_driver_diagnostic.c | asm codegen 失败定位 |
| `parser_diag_*` / `parser_is_ident_allow` | runtime_driver_diagnostic.c | parse 调试 |
| `driver_typeck_diag_scratch_*` | runtime_driver_diagnostic.c | typeck.x scratch 缓冲 |
| `driver_diagnostic_warn_pad_fields_*` 等 | runtime_driver_diagnostic.c | C typeck 亦调用（无 pipeline 条件编译） |

## 仍留 runtime.c

- `run_compiler_c` / `run_compiler_x_path` 主体
- `load_direct_imports_for_asm_layout` / `collect_deps_transitive` 等 dep 辅助
- `driver_run_x_emit_c` 与 X emit 路径（`SHUX_USE_X_DRIVER`）

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_driver_diagnostic.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_driver_diagnostic.c
```

## 延后（E-04 v35+）

- `run_compiler_c` 继续拆分（v35 已完成 dep collect/merge）
