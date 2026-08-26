# 阶段 F-config v2（std.config 逻辑 .x 下沉 + F-ZC）

> **F-config v2**：TOML/YAML/ENV 解析与 store 迁入 **`config.x`**；**F-ZC** 删除 **`config_io_glue.c`**，文件读经 **`fs_open_read_c`**，smoke setenv 经 **`env_setenv_c`**。

## 变更

| 项 | v1 | v2 | F-ZC |
|----|----|-----|------|
| 配置逻辑 | `config_glue.c`（1067 行） | **`config.x`** | 同 v2 |
| 文件 IO / smoke setenv | glue 内联 | `config_io_glue.c` | **`.x` + fs/env extern** |
| `config.o` | `ld -r` glue + x | `ld -r` io glue + x | **纯 `.x`** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CONFIG_V2_FAIL` retired. Delegates STD-086 config + STD-119 config-yaml hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-config-v2-gate.sh
./tests/run-std-config-gate.sh
./tests/run-std-config-yaml-gate.sh
```

## 下一项

- **F-ZC Z8** 继续清场 url_glue / security_os_glue 等
