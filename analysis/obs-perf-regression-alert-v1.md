# OBS-004 性能回归自动告警 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ENG-001`（baseline registry）、`OBS-003`（结构化日志）、`PERF-001~004`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **越界即告警** | 性能回归失败时 stderr 输出统一 `SHUX_PERF_ALERT` 行 |
| **registry 联动** | 7 条 perf baseline 各有 `fail_env` + gate |
| **机器可聚合** | 与 OBS-003 bracket 格式一致，CI/Loki 可 grep |
| **零假阳性默认** | 仅 `SHUX_PERF_FAIL_ON_*=1` 硬失败路径发 `severity=critical` |

验收（NEXT OBS-004）：**指标越界自动通知** → manifest + emit lib + dogfood 挂钩 + gate。

---

## 2. 告警行格式（v1）

```text
shux: [SHUX_PERF_ALERT] severity=critical baseline_id=compile-dogfood metric=loop_i32 measured=0.1000 cap=0.0900 gate=run-perf-compile-dogfood-gate.sh
```

| 字段 | 说明 |
|------|------|
| `severity` | `critical`（硬回归）/ `warn`（advisory） |
| `baseline_id` | `perf-baseline-registry.tsv` 逻辑名 |
| `metric` | case_id 或指标名 |
| `measured` | 实测值（秒、吞吐等，十进制） |
| `cap` | baseline 上限 |
| `gate` | 对应 gate 脚本名 |

实现：`tests/lib/obs-perf-regression-alert.sh` → `obs_perf_alert_emit()`。

---

## 3. 注册表（与 ENG-001 对齐）

文件：`tests/baseline/obs-perf-regression-alert.tsv`

| baseline_id | fail_env | gate |
|-------------|----------|------|
| `zig-perf` | `SHUX_PERF_FAIL_ON_ZIG` | `run-zig-baseline-gate.sh` |
| `io-perf` | `SHUX_PERF_FAIL_ON_IO_REGRESSION` | `run-perf-io-zig-gate.sh` |
| `net-perf` | `SHUX_PERF_FAIL_ON_NET_REGRESSION` | `run-perf-net-zig-gate.sh` |
| `compile-dogfood` | `SHUX_PERF_FAIL_ON_COMPILE_REGRESSION` | `run-perf-compile-dogfood-gate.sh` |
| `async-perf` | `SHUX_PERF_FAIL_ON_ASYNC_REGRESSION` | `run-perf-async.sh` |
| `coldstart-perf` | `SHUX_PERF_FAIL_ON_COLDSTART_REGRESSION` | `run-perf-coldstart.sh` |

`net-perf-latency` 与 `net-perf` 共用 gate/env（manifest 一行备注）。

---

## 4. 挂钩点（v1）

| 路径 | 行为 |
|------|------|
| `run-perf-compile-dogfood.sh` | Python 路径 `SLOW` + `fail_regress` 时 `emit` |
| 其它 gate | 文档约定；runner `--smoke` 验证 emit 格式 |

后续 PR 可在 `run-perf-io.sh` / `run-perf-net.sh` 等失败分支调用 `obs_perf_alert_emit`。

---

## 5. 用法

```bash
# 烟测：对 manifest 每行 emit 样例告警（不跑 bench）
./tests/run-obs-perf-regression-alert.sh --smoke

# 门禁
./tests/run-obs-perf-regression-alert-gate.sh

# CI 聚合
grep -F 'shux: [SHUX_PERF_ALERT]' ci.log
```

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_PERF_ALERT_EMIT` | `1` | `0` 关闭 emit（测试用） |

---

## 6. 门禁

`tests/run-obs-perf-regression-alert-gate.sh`：

1. RFC + manifest + lib + registry 交叉校验  
2. `run-obs-perf-regression-alert.sh --smoke` 输出 ≥ `min_alerts` 行  
3. `compile-dogfood` 脚本含 `SHUX_PERF_ALERT` emit 锚点  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/obs-perf-regression-alert.tsv` |
| 库 | `tests/lib/obs-perf-regression-alert.sh` |
| runner | `tests/run-obs-perf-regression-alert.sh` |
| 门禁 | `tests/run-obs-perf-regression-alert-gate.sh` |
| baseline 注册表 | `tests/baseline/perf-baseline-registry.tsv` |
| baseline 治理 | `analysis/eng-baseline-governance-v1.md` |
| 结构化日志 | `analysis/obs-structured-log-v1.md` |

**OBS-004 状态：定版 ✅**
