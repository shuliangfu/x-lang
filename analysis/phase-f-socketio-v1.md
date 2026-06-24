# 阶段 F-socketio v1（std.socketio 去 C）

> **F-socketio v1**：删除 **`socketio.c`**；锚点 **`socketio.sx`**；Engine.IO/SIO 在 **`socketio_glue.c`**（2823 行）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `socketio.c` | `socketio.sx` + `socketio_glue.c` |
| `socketio.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_SOCKETIO_V1_FAIL=1 ./tests/run-f-socketio-v1-gate.sh
./tests/run-std-socketio-gate.sh
```

## 下一项

- **F-net-tls v1**（`tls_mbedtls_bio.c` 胶层化）/ 全量 `.sx` 逻辑下沉 v2
