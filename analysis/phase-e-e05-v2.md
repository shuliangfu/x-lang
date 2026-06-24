# 阶段 E-05 v2（runtime.c 条件 include C 前端头）

> **E-05 v2**：默认 `runtime_driver_no_c.o`（`-DSHUX_NO_C_FRONTEND`）编译 `runtime.c` 时**不再** `#include` lexer/parser/typeck/codegen/ast C 前端头；仍保留 `preprocess.h`、`target_cpu.h`、`lsp/lsp_diag.h`。

## 完成（✅）

| 项 | 说明 |
|----|------|
| 条件 include | `#if !defined(SHUX_NO_C_FRONTEND)` 包裹 C 前端头 |
| preamble ABI | NO_C 路径仅前向声明 `codegen_get_preamble_skip_mask` + `CODEGEN_PREAMBLE_SKIP_*`（链 `codegen_pipeline_stubs.o`） |
| typeck 符号 | `pipeline_typeck_module_for_ctx` 保留；NO_C 前向声明 `typeck_module`（weak stub / partial） |
| Gate | `run-e05-include-soft-gate.sh` v2 grep 断言 |

## 复现

```bash
SHUX_E05_FAIL=1 ./tests/run-e05-include-soft-gate.sh
make -C compiler src/runtime_driver_no_c.o
```

## 延后（E-05 v3+）

- 合并/内嵌仅 bootstrap 必需的 ABI 头（减少 `lsp_diag.h` 表面积）
- 理想终局：include/ 仅 FFI/ABI（程度 4）
