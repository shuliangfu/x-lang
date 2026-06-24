# 阶段 F-04 v3（std.net WebSocket 去 C）

> **F-04 v3**：**`ws.inc.c`** → **`ws_codec.sx`** + **`ws_io.sx`**；`std.websocket/mod.sx` import 转发。

## v3 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `ws_codec.sx` | SHA-1 Accept、帧编解码、握手 HTTP、URL 解析、Upgrade 校验 |
| `ws_io.sx` | connect/读写、服务端 101、poll+send/recv |
| `std/websocket/mod.sx` | import ws_codec + ws_io + tls_stub |
| `net.c` | 不再 `#include ws.inc.c` |
| 删除 | `std/net/ws.inc.c` |
| 存量 | F-01 total **101**（较 102 减 1） |

## v3 限制

| 项 | 说明 |
|----|------|
| socketpair 烟测 | 客户端/服务端 fork 集成烟测 v3 离线化（同 Windows 跳过策略） |
| WSS runtime | 仍依赖 tls_stub（OpenSSL 链入待 F-04 v4） |

## 复现

```bash
SHUX_F04_NET_WS_FAIL=1 ./tests/run-f04-std-net-ws-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=101
./tests/run-std-net-ws-gate.sh
```
