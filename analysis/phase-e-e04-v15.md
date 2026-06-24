# 阶段 E-04 v15（asm_invoke_ld_platform fork/exec 迁入 link_abi）

> **E-04 v15**：自 `runtime.c` 迁入 **`shux_asm_invoke_ld_platform`**（含 freestanding `-nostdlib`、最小 gcc 链、Mach-O/COFF/Unix 全路径）；删除 `shu_ld_freestanding_enabled` 薄包装；`invoke_ld` / `driver_asm_invoke_ld` 改调 link ABI。

## v15 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_asm_invoke_ld_platform` | fork/exec ld/gcc/lld-link；含 freestanding 与 nm 自包含快路径 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v17+）

- `invoke_cc` fork/exec 主体迁入 `runtime_link_abi`
- `main.c` → crt0 / main.sx 全入口
