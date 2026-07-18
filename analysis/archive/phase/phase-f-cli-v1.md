# 阶段 F-cli v1（std.cli 去 C）

> **F-cli v1**：删除 **`cli.c`**；选项解析/usage/烟测全在 **`cli.x`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `cli.c`（151 行） | `cli.x` |
| `cli.o` | `cc -c cli.c` | `shux -backend asm cli.x` |
| 存量 | std 84 `.c` | std **83** `.c` |

## 门禁

```bash
SHUX_F_CLI_V1_FAIL=1 ./tests/run-f-cli-v1-gate.sh
./tests/run-std-cli-gate.sh
```

## 下一项

- **F-log v1**
