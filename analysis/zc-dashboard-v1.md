# ZC-008 零拷贝指标仪表板 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ZC-001~007`、`PERF-008/009`、`analysis/zc-semantics-v1.md`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **指标可见** | ZC gate、syscall 上限、网络 cycles/MiB 一表汇总 |
| **每日趋势** | `zc-dashboard-history.tsv` 按日记录 metric 值与 status |
| **趋势图** | runner 输出 ASCII sparkline（▁▂▃▄▅▆▇█） |
| **可 grep** | `shux: [SHUX_ZC_DASHBOARD]` 报告行 |

验收：**每日（daily）更新并有趋势图** → v1 以 history TSV + sparkline + `--record` 工作流交付。

---

## 2. 指标层 D1–D4

权威：`tests/baseline/zc-dashboard-metrics.tsv`（**8** 条 `metric_*`）。

| 层级 | 指标 | 数据源 |
|------|------|--------|
| **D1-gate** | ZC-1..5 manifest 绿 | `run-zc*-gate.sh` |
| **D2-syscall** | splice/read 上限 | `syscall-batch-perf.tsv` |
| **D3-net** | provided vs batch cycles/MiB | `net-zc-perf.tsv` |
| **D4-io** | sendfile 耗时上限 | `io-perf.tsv` |

**status**：`value ≤ cap` → `green`；gate 输出含 `gate OK` → `pass`；否则 `warn`。

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_ZC_DASHBOARD_RECORD` | `0` | `1` 时 `--record` 写入 history |
| `SHUX_ZC_DASHBOARD_METRICS` | `tests/baseline/zc-dashboard-metrics.tsv` | 指标表 |
| `SHUX_ZC_DASHBOARD_HISTORY` | `tests/baseline/zc-dashboard-history.tsv` | 日历史 |
| `SHUX_ZC_DASHBOARD_PREFIX` | `shux: [SHUX_ZC_DASHBOARD]` | 报告前缀 |

---

## 3. 每日更新流程

1. CI schedule 或本地：`./tests/run-zc-dashboard.sh --record`
2. 检查 sparkline 与 `status` 列。
3. 提交更新后的 `zc-dashboard-history.tsv`。
4. 门禁：`./tests/run-zc-dashboard-gate.sh`（**runnable** manifest + history 天数）。

---

## 4. 报告行

```text
shux: [SHUX_ZC_DASHBOARD] metric=zc5_splice_max value=20 cap=20 status=green trend=▅▅
```

实现：`zcd_report_emit()` in `tests/lib/zc-dashboard.sh`。

---

## 5. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/zc-dashboard-manifest.tsv` |
| metrics | `tests/baseline/zc-dashboard-metrics.tsv` |
| history | `tests/baseline/zc-dashboard-history.tsv` |
| 库 | `tests/lib/zc-dashboard.sh` |
| runner | `tests/run-zc-dashboard.sh` |
| 门禁 | `tests/run-zc-dashboard-gate.sh` |

**ZC-008 状态：定版 ✅**
