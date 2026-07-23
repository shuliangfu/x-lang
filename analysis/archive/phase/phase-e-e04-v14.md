# 阶段 E-04 v14（invoke_ld prepare + tail -l* + nm 自包含扫描）

> **E-04 v14**：自 `runtime.c` 迁入 **`xlang_asm_ld_prepare_for_exe_link`**、**`xlang_asm_user_o_has_undef_syms`**、**`xlang_asm_ld_append_mach_tail_libs`**、**`xlang_asm_ld_append_unix_gcc_tail_libs`** 与 **`XLANG_LD_ARGV_CAP`**；`invoke_ld` / `driver_asm_invoke_ld` 去重；`asm_invoke_ld_platform` fork/exec 主体仍留 runtime.c。

## v14 完成（✅）

| 符号 | 说明 |
|------|------|
| `XLANG_LD_ARGV_CAP` | ASM ld argv 槽位上限（96） |
| `xlang_asm_ld_prepare_for_exe_link` | ensure panic/io_stubs/crt0/freestanding_io + 目标格式校验 |
| `xlang_asm_user_o_has_undef_syms` | nm -u 自包含 .o 判定（Linux 最小 gcc 链） |
| `xlang_asm_ld_append_mach_tail_libs` | macOS clang/ld 尾 -l* |
| `xlang_asm_ld_append_unix_gcc_tail_libs` | Linux/Unix gcc 尾 -l*（-luring/-pthread/-lm/-lc 等） |

## 复现

```bash
XLANG_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v15+）

- `invoke_cc` 主体与 `get_std_*_o_path` 路径族（v15 已迁 `asm_invoke_ld_platform`）
- `main.c` → crt0 / main.x 全入口
