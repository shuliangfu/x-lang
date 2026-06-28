# STD-078 std.metrics v1

> 更新时间：2026-06-18  
> 状态：**可用** — Counter/Gauge/Histogram + Prometheus 导出 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-metrics-manifest.tsv` |
| 3 | `./tests/run-std-metrics-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `Counter` / `Gauge` / `Histogram` | 三类指标 |
| `Registry` | 本地注册表（各类型最多 4 项） |
| `counter_inc` / `gauge_set` / `histogram_observe` | 更新 |
| `counter_snapshot` / `gauge_snapshot` | 快照读 |
| `counter` / `gauge` / `histogram` | 注册并返回索引 |
| `export_prometheus` | Prometheus 文本导出 |
| `label_set` | 单 label 维度 |
| `err_*` | 错误码 |

与 `std.log` / `std.trace`：v1 通过共享 label 键（如 `service`）对齐观测上下文；trace 模块落地后复用同一 label 约定。

---

## 3. Gate

```
shux: [SHUX_STD_METRICS] status=ok sx=1 skip=0
std-metrics gate OK
```

Round-trip 向量：`tests/baseline/std-metrics-vectors.tsv`。
