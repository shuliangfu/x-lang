# 阶段 F-04 v14（std.net accept workers 去 C — net.c 删除）

> **F-04 v14 v1**：从 **`net.c`** 迁出 **`net_run_accept_workers_c*`** → **`net_workers.sx`** + **`runtime_net_workers.c`**（F-ZC）；**删除 `std/net/net.c`**。

## v14 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `net_workers.sx` | `net_run_accept_workers_c` / `net_run_accept_workers_c_real`（thread_create/join） |
| `runtime_net_workers.c` | worker 线程入口 + 弱 `thread_set_affinity_self_c` stub |
| `net.c` | **已删除**；std.net 宿主路径无 legacy C |
| `Makefile` | `net.o` = **10** 个 `.sx`；胶层在 `runtime_net_* .o` |

## v14 限制

| 项 | 说明 |
|----|------|
| 线程入口 | 仍为 C 函数指针（同 tls_mbedtls_bio / thread 模块约定） |
| 链接 | `run_accept_workers` 需链 `thread.o`（`-lpthread`）才有真绑核 |
| 无 shux | `net.o` 无法构建（须 shux 合并 `.sx`）；runtime 胶层单独 `cc -c` |

## 复现

```bash
SHUX_F04_NET_SLICE_V14_FAIL=1 ./tests/run-f04-std-net-slice-v14-gate.sh
SHUX_F04_NET_SLICE_V13B_FAIL=1 ./tests/run-f04-std-net-slice-v13b-gate.sh
./tests/run-net.sh
```
