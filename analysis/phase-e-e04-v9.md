# 阶段 E-04 v9（runtime_panic / async scheduler .o 路径迁入 runtime_link_abi）

> **E-04 v9**：自 `runtime.c` 迁入 **`shux_runtime_panic_o_path`** 与 **`shux_std_async_scheduler_o_path`**；invoke_cc / asm_invoke_ld 与 ensure_runtime_panic_o 共用 link ABI TU。

## v9 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_runtime_panic_o_path` | compiler/runtime_panic.o 路径解析 |
| `shux_std_async_scheduler_o_path` | std/async/scheduler.o 路径解析 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v11+）

- `ensure_runtime_asm_io_stubs_o` / `ensure_crt0_user_o` / `ensure_freestanding_io_o`
- `asm_invoke_ld_platform` / `invoke_ld` / `invoke_cc` 主体
- `get_repo_root` 等 std .o 路径族
- `main.c` → crt0 / main.sx 全入口
