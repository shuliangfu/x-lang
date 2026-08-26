# 阶段 F-elf v1（std.elf 去 C）

> **F-elf v1**：删除 **`elf.c`**；锚点 **`elf.x`**；ELF64 解析在 **`elf_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `elf.c`（564 行） | `elf.x` + `elf_glue.c` |
| `elf.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_ELF_V1_FAIL` retired. STD-058 elf-parse observational (host-c smoke / elf-write product residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-elf-v1-gate.sh
./tests/run-std-elf-parse-gate.sh
```

## 下一项

- **F-elf v2**（`elf_glue.c` → `elf.x` + `elf_io_glue.c`）
