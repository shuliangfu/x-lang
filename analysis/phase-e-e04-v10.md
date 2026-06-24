# 阶段 E-04 v10（freestanding/crt0 路径 + ensure runtime_panic 迁入 runtime_link_abi）

> **E-04 v10**：自 `runtime.c` 迁入 **`shux_crt0_user_o_path`**、**`shux_freestanding_io_o_path`**、**`shux_runtime_asm_io_stubs_o_path`** 与 **`shux_ensure_runtime_panic_o`**；invoke_ld / asm_invoke_ld 与 freestanding 链共用 link ABI TU。

## v10 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_crt0_user_o_path` | compiler/crt0_user.o 路径 |
| `shux_freestanding_io_o_path` | compiler/freestanding_io.o 路径 |
| `shux_runtime_asm_io_stubs_o_path` | compiler/runtime_asm_io_stubs.o 路径 |
| `shux_ensure_runtime_panic_o` | 按需 cc -c 生成 runtime_panic.o |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v12+）

- `asm_invoke_ld_platform` / `invoke_ld` / `invoke_cc` 主体
- `get_repo_root` 等 std .o 路径族
- `main.c` → crt0 / main.sx 全入口
