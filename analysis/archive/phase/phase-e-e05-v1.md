# 阶段 E-05 v1（编译器 C/H 清单 + gate）

> **E-05 v1**：**不删除**任何 `.h`；登记 `compiler/include/` 与 `compiler/src/**/*.h` 的 **active / soft_retired** 状态；默认 bootstrap 依赖的头文件可审计、可对照 E-03/E-04。

## v1 完成（✅ inventory + gate）

| 类别 | 说明 | 示例 |
|------|------|------|
| **active_bootstrap** | 默认 seed / B-strict 仍链 TU 需要 | `target_cpu.h`, `simd_enc.h` |
| **active_runtime** | `runtime_driver_no_c.o` 编译仍 `#include` | `preprocess.h`, `lsp/lsp_diag.h` |
| **soft_retired_frontend** | 仅 C 前端 / LEGACY / shux-c | `ast.h`, `token.h`, `parser/parser.h` |
| **not_exists** | E-01 已内嵌删除 | `lsp_io_extern.h` |

## 复现

```bash
SHUX_E05_FAIL=1 ./tests/run-e05-include-soft-gate.sh
```

## 延后（E-05 v1）

- 见 `analysis/phase-e-e05-v2.md`（v2 已完成 runtime NO_C include 守卫）
