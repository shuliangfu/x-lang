# 阶段 F-elf v1（std.elf 去 C）

> **F-elf v1**：删除 **`elf.c`**；锚点 **`elf.sx`**；ELF64 解析在 **`elf_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `elf.c`（564 行） | `elf.sx` + `elf_glue.c` |
| `elf.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_ELF_V1_FAIL=1 ./tests/run-f-elf-v1-gate.sh
./tests/run-std-elf-parse-gate.sh
```

## 下一项

- **F-elf v2**（`elf_glue.c` → `elf.sx` + `elf_io_glue.c`）
