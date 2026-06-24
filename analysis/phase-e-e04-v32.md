# 阶段 E-04 v32（preprocess 迁入 pipeline_abi）

> **E-04 v32**：自 `runtime.c` 将 **driver/bootstrap 预处理** 迁入 **`runtime_pipeline_abi.c/h`**；shux-c 仍经 `SHUX_RUNTIME_PREPROCESS` 宏链 `preprocess.o`。

## v32 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_preprocess` | SX preprocess.sx 路径（默认）或 `preprocess_c_fallback`（LEGACY） |
| `SHUX_RUNTIME_PREPROCESS` | runtime.c 宏：driver 用 `shux_preprocess`，shux-c 用 `preprocess()` |
| `RUNTIME_PIPELINE_ABI_CFLAGS` | Makefile 为 pipeline_abi.o 注入 `-DSHUX_USE_SX_PIPELINE` |

## 仍留 runtime.c

- `run_compiler_c` / `run_compiler_sx_path` 主体
- driver 诊断 `driver_diagnostic_*` 大块

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
SHUX_E03_PREPROCESS_FAIL=1 ./tests/run-e03-preprocess-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_pipeline_abi.c
```

## 延后（E-04 v33+）

- `run_compiler_c` / `driver_diagnostic_*` 继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
