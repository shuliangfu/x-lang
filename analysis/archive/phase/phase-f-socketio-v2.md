# 阶段 F-socketio v2（std.socketio 逻辑 .x 下沉）

> **F-socketio v2**：Engine.IO/SIO 编解码、polling/WS URL、namespace 路由、WS hub、room、cluster adapter 与全部烟测迁入 **`socketio.x`**；**纯 .x**（HTTP/WS 经 `extern http_*` / `net_ws_*`）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 协议逻辑 | `socketio_glue.c`（~2802 行） | **`socketio.x`** |
| IO | glue 内联 `http_get` / `net_ws_*` | **`extern` 声明于 socketio.x** |
| `socketio.o` | `ld -r` glue + x | **仅 x（`socketio_main.o`）** |

## 门禁

```bash
SHUX_F_SOCKETIO_V2_FAIL=1 ./tests/run-f-socketio-v2-gate.sh
./tests/run-std-socketio-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（其他模块 v2）
