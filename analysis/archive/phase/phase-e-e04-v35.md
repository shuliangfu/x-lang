# 阶段 E-04 v35（dep 传递闭包 collect/merge 迁入 pipeline_abi）

> **E-04 v35**：自 `runtime.c` 将 **shux_collect_deps_transitive / shux_merge_direct_then_transitive_deps / shux_load_direct_imports_for_asm_layout** 迁入 **`runtime_pipeline_abi.c/h`**。

## v35 完成（✅）

| 符号 | TU | 说明 |
|------|-----|------|
| `shux_collect_deps_transitive` | runtime_pipeline_abi.c | 递归 resolve+preprocess+parse import 闭包 |
| `shux_merge_direct_then_transitive_deps` | runtime_pipeline_abi.c | direct import 槽对齐 + 传递 dep 去重 merge |
| `shux_load_direct_imports_for_asm_layout` | runtime_pipeline_abi.c | ENTRY_MODULE_ONLY 仅读 direct import 填 layout |

## 仍留 runtime.c

- `run_compiler_c` / `run_compiler_x_path` 主体
- `driver_run_asm_backend` / `driver_run_compiler_parsed` 编排
- `driver_run_x_emit_c` 与 X emit 路径

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c
```

## 延后（E-04 已闭合 — 无 v36+ gate 项）

- `driver_run_compiler_parsed` / `run_compiler_c` 主体拆分：**可选维护**，非阶段 E
- 详见 `analysis/phase-e-soft-v2-closure.md`
