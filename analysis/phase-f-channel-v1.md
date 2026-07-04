# 阶段 F-channel v1（std.channel 去 C）

> **F-channel v1**：删除 **`channel.c`**；**`channel.x`** + **`compiler/src/asm/runtime_channel_glue.c`**（F-ZC）；Unix 须 **-lpthread**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `channel.c`（613 行） | `channel.x` + `runtime_channel_glue.c` |
| `channel.o` | `ld -r` 合并 | 纯 `.x` |
| channel 胶层 | `std/channel/channel_glue.c` | `compiler/runtime_channel_glue.o` |

## 门禁

```bash
SHUX_F_CHANNEL_V1_FAIL=1 ./tests/run-f-channel-v1-gate.sh
./tests/run-std-channel-select-gate.sh
./tests/run-std-channel-unbounded-gate.sh
```

## 下一项

- **F-sync v1** / **F-crypto v1** / **F-thread v1**
