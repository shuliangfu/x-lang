# 阶段 F-channel v1（std.channel 去 C）

> **F-channel v1**：删除 **`channel.c`**；**`channel.x`** + **`compiler/src/asm/runtime_channel_glue.c`**（F-ZC）；Unix 须 **-lpthread**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `channel.c`（613 行） | `channel.x` + `runtime_channel_glue.c` |
| `channel.o` | `ld -r` 合并 | 纯 `.x` |
| channel 胶层 | `std/channel/channel_glue.c` | `compiler/runtime_channel_glue.o` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CHANNEL_V1_FAIL` retired. Delegates STD-098 channel-select hard. channel-unbounded observational (product residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-channel-v1-gate.sh
./tests/run-std-channel-select-gate.sh
```

## 下一项

- **F-sync v1** ✅ / **F-crypto v1** / **F-thread v1** ✅
