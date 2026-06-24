# 阶段 E-04 v13（asm_ld_append_std/on_demand + rel 路径 + nm 符号扫描）

> **E-04 v13**：自 `runtime.c` 迁入 **`shux_asm_ld_append_std_objs`**、**`shux_asm_ld_append_on_demand_user_objs`**、**`shux_rel_o_path_from_argv0`**、**`shux_link_obj_needs_undef_sym`** 与 freestanding 按需链判定；`asm_invoke_ld_platform` 主体仍留 runtime.c。

## v13 完成（✅）

| 符号 | 说明 |
|------|------|
| `ShuAsmLdStdLinkFlags` | 已链入 std 模块标记（-pthread/-lm 等） |
| `shux_rel_o_path_from_argv0` | 通用 std/core .o 相对路径解析 |
| `shux_link_obj_needs_undef_sym` | nm 未定义符号扫描 |
| `shux_freestanding_user_o_needs_io/panic` | freestanding 按需链判定 |
| `shux_asm_ld_append_std_objs` | ASM ld 全量 std/*.o argv 构建 |
| `shux_asm_ld_append_on_demand_user_objs` | 用户 .o 伴生模块按需追加 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v14+）

- `asm_invoke_ld_platform` fork/exec 主体（v14 已拆 prepare/tail -l*）
- `invoke_cc` 主体与 `get_std_*_o_path` 路径族
- `main.c` → crt0 / main.sx 全入口
