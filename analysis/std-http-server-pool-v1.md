# STD-107：std.http server 循环 + client 连接池 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-http-server-pool.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-http-server-pool.tsv` |
| 3 | `./tests/run-std-http-server-pool-gate.sh` |

---

## 2. Server 循环

| API | 说明 |
|-----|------|
| `listen_on(addr_u32, port, backlog)` | IPv4 TCP listen；`port=0` 分配临时端口 |
| `serve_one(listener_fd, body, len, timeout_ms)` | accept 一次 + `respond_get_ok` + 关闭 client |

与 STD-009 `respond_get_ok` 组合构成最小 HTTP server 循环。

---

## 3. Client 连接池

| API | 说明 |
|-----|------|
| `client_pool_create(host, host_len, port, port_len, max_conns)` | 绑定 host:port，最多 8 idle |
| `client_pool_get(pool, url, url_len, out, out_cap)` | 池化 GET；响应含 keep-alive 时归还连接 |
| `client_pool_destroy(pool)` | 关闭全部 idle 并释放 |

**金样**：同一 URL 连续两次 `client_pool_get`，`connect_count==1`（仅一次 TCP 建连）。

---

## 4. 门禁

```bash
make -C compiler ../std/http/http.o
./tests/run-std-http-server-pool-gate.sh
```
