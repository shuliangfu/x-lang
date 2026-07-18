# 阶段 F-elf v2（std.elf 逻辑 .x 下沉 + F-ZC）

> **F-elf v2**：ELF64 解析/写入/烟测迁入 **`elf.x`**；**F-ZC** 删除 **`elf_io_glue.c`**，fixture 读经 **`fs_open_read_c` + `fs_posix_read_c`**。

## 变更

| 项 | v1 | v2 | F-ZC |
|----|----|-----|------|
| ELF 逻辑 | `elf_glue.c`（561 行） | **`elf.x`** | 同 v2 |
| fixture IO | glue 内联 fopen | `elf_io_glue.c` | **`.x` + fs extern** |
| `elf.o` | `ld -r` glue + x | `ld -r` io glue + x | **纯 `.x`** |

## 门禁

```bash
SHUX_F_ELF_V2_FAIL=1 ./tests/run-f-elf-v2-gate.sh
./tests/run-std-elf-parse-gate.sh
./tests/run-std-elf-deep-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
```

## 下一项

- **F-ZC Z8** 继续清场其余 OS 小胶层（security/env/log…）
