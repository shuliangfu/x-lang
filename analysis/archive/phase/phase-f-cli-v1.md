# 阶段 F-cli v1（std.cli 去 C）

> **F-cli v1**：删除 **`cli.c`**；选项解析/usage/烟测全在 **`cli.x`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `cli.c`（151 行） | `cli.x` |
| `cli.o` | `cc -c cli.c` | `xlang -backend asm cli.x` |
| 存量 | std 84 `.c` | std **83** `.c` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CLI_V1_FAIL` retired. Delegates STD-077 std-cli hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-cli-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-cli 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-cli-v1-gate.sh
./tests/run-std-cli-gate.sh
```

## 下一项

- **F-log v1**
