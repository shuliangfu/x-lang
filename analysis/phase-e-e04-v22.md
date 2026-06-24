# 阶段 E-04 v22（driver CLI 标志迁入 runtime_driver_abi）

> **E-04 v22**：自 `runtime.c` 拆出 **`runtime_driver_abi.c/h`**，承载 driver check/freestanding/sanitize/fmt/skip-typeck/codegen 标志、`driver_print_check_ok`、大栈线程标记；pipeline/run_compiler_c 主体仍留 runtime.c。

## v22 完成（✅）

| 符号 | 说明 |
|------|------|
| `driver_check_only_*` / `driver_freestanding_*` | CLI 模式标志 |
| `driver_sanitize_address_*` | ASan 边界检查开关 |
| `driver_fmt_check_only_*` / `driver_print_check_ok` | fmt/check 输出 |
| `driver_sx_pipeline_skip_*` | SX pipeline 跳过 typeck/codegen |
| `driver_typeck_force_c_enabled` | SHUX_TYPECK_FORCE_C |
| `driver_is_large_stack_thread` / `driver_large_stack_thread_mark` | 大栈 pthread 上下文 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_driver_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v24+）

- `run_compiler_c` / pipeline dep 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
