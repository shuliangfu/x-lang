# 阶段 F-socketio v1（std.socketio 去 C）

> **F-socketio v1**：删除 **`socketio.c`**；锚点 **`socketio.x`**；Engine.IO/SIO 胶层 v2 已删（见 `run-f-socketio-v2-gate.sh`）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `socketio.c` | `socketio.x`（v2 无 glue） |
| `socketio.o` | `cc -c` | 纯 `.x` / ld -r |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SOCKETIO_V1_FAIL` retired. Static + ensure hard. STD-socketio observational (prefer-c + eio_packet P014 product residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-socketio-v1-gate.sh
```

## 下一项

- **F-net-tls v1**（`tls_mbedtls_bio.c` 胶层化）/ 全量 `.x` 逻辑下沉 v2
