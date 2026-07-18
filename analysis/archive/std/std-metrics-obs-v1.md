# STD-117 std.metrics 观测上下文关联 v1

> 更新时间：2026-06-18  
> 状态：**可用** — ObservabilityCtx + log KV + context 传播 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-metrics-obs-manifest.tsv` |
| 3 | `./tests/run-std-metrics-obs-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `ObservabilityCtx` | trace_id/span_id hex + trace 句柄 |
| `obs_ctx_from_trace` | 从 `std.trace` Span 构建 |
| `obs_ctx_attach_context` / `obs_ctx_from_context` | 经 `std.context` 传播 |
| `obs_ctx_format_log_kv` | 生成 `trace_id=… span_id=…` 供 `std.log.structured_kv` |
| `obs_ctx_apply_trace_label` | 将 trace_id 写入 metrics Label |

与 `std.log` / `std.trace`：共享 `trace_id` / `span_id` 字段名；context 键 `trace`/`span` 与 trace 模块一致。

---

## 3. Gate

```
shux: [SHUX_STD117_METRICS_OBS] status=ok x=1 skip=0
std-metrics-obs gate OK
```

向量：`tests/baseline/std-metrics-obs-vectors.tsv`。
