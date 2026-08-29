# 阶段 F-config v1（std.config 去 C）

> **F-config v1**：删除 **`config.c`**；锚点 **`config.x`**；TOML/YAML/ENV 在 **`config_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `config.c`（1070 行） | `config.x` + `config_glue.c` |
| `config.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CONFIG_V1_FAIL` retired. Delegates STD-config + yaml hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-config-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-config／std-config-yaml 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-config-v1-gate.sh
./tests/run-std-config-gate.sh
./tests/run-std-config-yaml-gate.sh
```

## 下一项

- **F-datetime v1** ✅ / **F-elf v1** ✅
