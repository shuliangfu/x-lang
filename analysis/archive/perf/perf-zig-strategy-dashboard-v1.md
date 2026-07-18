# PERF-011 超越 Zig 战略看板 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-001`（Zig 基线）、`PERF-002/003`（IO/NET）、`OBS-003`（结构化日志）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **战略可见** | P0 microbench + 关键 IO/NET case 的 Shu vs Zig 一目了然 |
| **月度趋势** | `zig-strategy-history.tsv` 按月（monthly）记录 `ahead_pct` |
| **趋势图** | runner 输出 ASCII sparkline（▁▂▃▄▅▆▇█） |
| **可 grep** | `shux: [SHUX_ZIG_STRATEGY]` 报告行 |

验收（NEXT PERF-011）：**月度更新并有趋势图** → v1 以 history TSV + sparkline + `--record` 工作流为可执行交付。

---

## 2. 指标

| 项 | 公式 |
|----|------|
| `ahead_pct` | `(1 - shu_sec / zig_sec) × 100` |
| `status` | `ahead_pct ≥ target_ahead_pct` → 绿；否则 `behind` |
| 趋势 | 按 `month` 升序取同 case 的 `ahead_pct` 序列画 sparkline |

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_ZIG_STRATEGY_RECORD` | `0` | `1` 时 `--record` 写入 history |
| `SHUX_ZIG_STRATEGY_FAIL` | `0` | `1` 时任一 P0 case behind 硬失败 |
| `SHUX_ZIG_STRATEGY_PREFIX` | `shux: [SHUX_ZIG_STRATEGY]` | 报告前缀 |
| `SHUX_ZIG_STRATEGY_CASES` | `tests/baseline/zig-strategy-cases.tsv` | case 表 |
| `SHUX_ZIG_STRATEGY_HISTORY` | `tests/baseline/zig-strategy-history.tsv` | 历史表 |

---

## 3. Case 清单（zig-strategy-cases.tsv）

| case_id | 类别 | 说明 |
|---------|------|------|
| `loop_i32` | microbench | P0 |
| `mem_copy` | microbench | P0 |
| `struct_param` | microbench | P0 |
| `call_boundary` | microbench | P0 |
| `io_mmap_throughput` | io | 16MiB 顺序读 |
| `net_echo_throughput` | net | echo client（无 server 时 SKIP） |

---

## 4. 报告行

```text
shux: [SHUX_ZIG_STRATEGY] case=loop_i32 shu_sec=0.0079 zig_sec=0.0101 ahead_pct=21.8 target_pct=0 status=ahead trend=▃▅█
```

实现：`zsd_report_emit()` in `tests/lib/zig-strategy-dashboard.sh`。

---

## 5. 月度更新流程

1. 每月固定 host（`zig-perf.tsv` `reference_host`）跑：  
   `./tests/run-perf-zig-strategy-dashboard.sh --record`
2. 检查 sparkline 与 `ahead_pct` 是否达标。
3. 提交更新后的 `zig-strategy-history.tsv`。
4. 门禁：`./tests/run-perf-zig-strategy-dashboard-gate.sh`（CI 每日/每月 schedule 可挂）。

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-zig-strategy-dashboard.tsv` |
| cases | `tests/baseline/zig-strategy-cases.tsv` |
| history | `tests/baseline/zig-strategy-history.tsv` |
| 库 | `tests/lib/zig-strategy-dashboard.sh` |
| runner | `tests/run-perf-zig-strategy-dashboard.sh` |
| 门禁 | `tests/run-perf-zig-strategy-dashboard-gate.sh` |
| Zig 基线 | `tests/baseline/zig-perf.tsv` |
| PERF-001 | `tests/run-zig-baseline-gate.sh` |
| 结构化日志 | `analysis/obs-structured-log-v1.md` |

**PERF-011 状态：定版 ✅**
