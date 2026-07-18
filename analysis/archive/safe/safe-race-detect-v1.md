# SAFE-006 数据竞争检测实验线 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1 实验线）**  
> 关联：`SAFE-001`（sanitize）、`SAFE-005`（夜跑模式）、`std.sync` / `std.atomic`

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 实验轨 T1–T4 |
| 2 | 打开 `tests/baseline/safe-race-detect.tsv` |
| 3 | `./tests/run-safe-race-detect-gate.sh` |
| 4 | Linux：`SHUX_RACE_PROBE=1 ./tests/run-safe-race-detect.sh` |

---

## 2. 实验轨 T1–T4

权威：`tests/baseline/safe-race-detect.tsv`（**4** 条 `track_*`）。

| 轨道 | 手段 | v1 状态 |
|------|------|---------|
| **T1-tsan-probe** | `cc -fsanitize=thread` + `race_probe.c` | ✅ 探测器 |
| **T2-mutex-safe** | `std.sync` 互斥保护共享状态 | ✅ 烟测 |
| **T3-atomic-safe** | `std.atomic` `fetch_add` 无数据竞争 | ✅ 烟测 |
| **T4-report** | `SHUX_RACE_DETECT` 结构化报告 | ✅ runner |

**TSAN 策略**（实验，未接入 `shux` 主链）：

| 项 | v1 约定 |
|----|---------|
| 工具链 | `cc -fsanitize=thread -pthread` |
| 探测器 | `SHUX_RACE_PROBE=1` 时运行 `race_probe.c`（故意 pthread 竞争） |
| 平台 | **Linux** 主路径；macOS/Windows gate manifest only |
| 正例 | `.x` 用例普通编译运行（mutex/atomic 单线程烟测） |

验收：**可执行方案**（runnable manifest + TSAN probe + 正例烟测）→ v1 实验线交付。

---

## 3. 用例矩阵

| case | 路径 | 期望 |
|------|------|------|
| `case_mutex` | `tests/safe/race_mutex_ok.x` | exit **0** |
| `case_atomic` | `tests/safe/race_atomic_ok.x` | exit **0** |
| `probe` | `tests/safe/race_probe.c` | TSAN 检出竞争（非 0） |

---

## 4. 报告格式（race report）

```
shux: [SHUX_RACE_DETECT] status=ok cases_ok=2 cases_fail=0 probe=ok
```

| 字段 | 含义 |
|------|------|
| `status` | `ok` / `fail` / `skip` |
| `cases_ok` | 正例通过数 |
| `probe` | `ok` / `skip` / `fail` |

---

## 5. 调度与门禁

| 入口 | 角色 |
|------|------|
| `.github/workflows/ci-nightly.yml` | Linux 实验 job（`SHUX_RACE_PROBE=1`） |
| 库 | `tests/lib/safe-race.sh` |
| runner | `tests/run-safe-race-detect.sh` |
| 门禁 | `tests/run-safe-race-detect-gate.sh` |

联动：`tests/run-sanitize-gate.sh`（SAFE-001）、`tests/run-sync.sh`、`tests/run-thread.sh`。

**SAFE-006 状态：定版 ✅（实验线）**
