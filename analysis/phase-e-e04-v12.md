# 阶段 E-04 v12（asm ld path bank + io/repo 根路径迁入 runtime_link_abi）

> **E-04 v12**：自 `runtime.c` 迁入 **`ShuAsmLdPathBank`**、**`shux_asm_ld_bank_push`**、**`shux_asm_ld_try_under_lib_roots`**、**`shux_std_io_o_path`** 与 **`shux_repo_root_from_argv0`**；为 v13 `asm_ld_append_std_objs` / `asm_invoke_ld_platform` 拆分铺路。

## v12 完成（✅）

| 符号 | 说明 |
|------|------|
| `ShuAsmLdPathBank` | ASM ld 子进程 argv 路径持久槽 |
| `shux_asm_ld_bank_push` | 路径写入 bank |
| `shux_asm_ld_try_under_lib_roots` | 按 -L 根解析 std/*.o |
| `shux_std_io_o_path` | std/io/io.o 路径 |
| `shux_repo_root_from_argv0` | 仓库根（invoke_cc -I） |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v14+）

- `asm_invoke_ld_platform` / `invoke_ld` / `invoke_cc` 主体
- `get_std_*_o_path` 路径族（invoke_cc 仍用）
- `main.c` → crt0 / main.x 全入口
