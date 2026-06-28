# STD-118 std.trace 关键路径挂钩 v1

> 更新时间：2026-06-18  
> 状态：**可用** — io/net/async 自动 span + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-trace-hooks-manifest.tsv` |
| 3 | `./tests/run-std-trace-hooks-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `hook_span_begin` / `hook_span_end` | 通用子 span 挂钩 |
| `hook_io_read_ctx` / `hook_io_write_ctx` | 包装 `std.io` read_ctx/write_ctx |
| `hook_net_connect_ctx` | 包装 `std.net.connect_ctx_fd` |
| `hook_net_stream_read_ctx` | 包装 `std.net.read_ctx` |
| `hook_async_drain_ctx` | 包装 `std.async.drain` |

Context 未附着 trace 时各 hook **透传**底层调用；有 trace 时自动 `span_start_child` + `span_end`。

Span 命名：`io.read`、`io.write`、`net.connect`、`net.stream_read`、`async.drain`。

---

## 3. Gate

```
shux: [SHUX_STD118_TRACE_HOOKS] status=ok c=1 sx=1 skip=0
std-trace-hooks gate OK
```

向量：`tests/baseline/std-trace-hooks-vectors.tsv`。
