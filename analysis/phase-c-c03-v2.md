# 阶段 C-03 v2（Windows B-strict 禁 pipeline_gen cc -c）

> **C-03 v2 / E-06 v5**：Linux/macOS B-strict 已在 v1 完成；Windows MSYS2 通过 **`SHUX_WIN_BSTRICT=1`** + **`bootstrap-driver-bstrict`** 对齐同一标准。

## v2 完成（✅ gate 路径）

| 项 | 说明 |
|----|------|
| `bootstrap-driver-bstrict-windows` | Makefile 目标 |
| `build_shux_asm_is_msys` | SKIP_GEN experimental SX-only |
| `run-bootstrap-bstrict-windows-gate.sh` | `SHUX_WIN_BSTRICT=1` 审计 pipeline_gen=0 |

## 默认仍 B-hybrid

| 项 | 说明 |
|----|------|
| `SHUX_WIN_BSTRICT=0` | CI 默认 hybrid（A-08 烟测） |
| `SHUX_WIN_C03_PIPELINE_GEN_FAIL=1` | 可选收紧 hybrid 日志 |

## 复现

```bash
SHUX_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
SHUX_C03_FAIL=1 ./tests/run-c03-no-pipeline-gen-gate.sh
```
