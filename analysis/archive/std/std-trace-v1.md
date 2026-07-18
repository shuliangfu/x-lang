# STD-088 std.trace v1

> 更新时间：2026-06-18  
> 状态：**可用** — Span 嵌套 + trace_id + text 导出 + context 集成 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-trace-manifest.tsv` |
| 3 | `./tests/run-std-trace-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `trace_new` / `trace_free` | 追踪会话 |
| `span_start` / `span_start_child` / `span_end` | 嵌套 Span |
| `trace_id` / `current_span` | ID 与栈顶 |
| `export_text` | OTLP 风格简化 text |
| `attach_to_context` / `from_context` | 与 std.context 集成 |

实现：`std/trace/mod.x` + `std/trace/trace.x`（F-trace v2 纯 .x，无 glue）。

---

## 3. Gate

```
shux: [SHUX_STD_TRACE] status=ok c_smoke=1 x=1 skip=0
std-trace gate OK
```

---

## 4. 后续（非 v1 阻塞）

- async/io/net 自动 span 挂钩  
- OTLP JSON/protobuf 导出  
- 并发安全  
