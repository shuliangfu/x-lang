# 阶段 E-04 v11（ensure io_stubs/crt0/freestanding 迁入 runtime_link_abi）

> **E-04 v11**：自 `runtime.c` 迁入 **`xlang_ensure_runtime_asm_io_stubs_o`**、**`xlang_ensure_crt0_user_o`**、**`xlang_ensure_freestanding_io_o`** 与 **`xlang_link_freestanding_enabled`**；invoke_ld / driver_asm_invoke_ld 链前 ensure 与 v10 路径解析共用 link ABI TU。

## v11 完成（✅）

| 符号 | 说明 |
|------|------|
| `xlang_link_freestanding_enabled` | Linux freestanding 链是否启用（env + driver flag） |
| `xlang_ensure_runtime_asm_io_stubs_o` | 按需 cc -c 生成 runtime_asm_io_stubs.o |
| `xlang_ensure_crt0_user_o` | freestanding 时按需生成 crt0_user.o |
| `xlang_ensure_freestanding_io_o` | freestanding 时按需生成 freestanding_io.o |

## 复现

```bash
XLANG_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v13+）

- `asm_invoke_ld_platform` / `invoke_ld` / `invoke_cc` 主体
- `get_repo_root` 等 std .o 路径族
- `main.c` → crt0 / main.x 全入口
