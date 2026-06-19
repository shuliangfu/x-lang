# ENG-001 性能 baseline 版本化治理 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-001~004`、`tests/baseline/perf-baseline-registry.tsv`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **单一注册表** | 所有性能 baseline TSV 有 id、version、gate、更新命令 |
| **改动可追溯** | 改数值须同 PR bump registry `version` |
| **强制评审** | baseline PR 须 perf-review checklist + 对应 gate 绿 |

验收（NEXT ENG-001）：**baseline 改动强制评审** + 自动检查。

---

## 2. 注册表

文件：`tests/baseline/perf-baseline-registry.tsv`

| 列 | 说明 |
|----|------|
| `baseline_id` | 逻辑名（如 `io-perf`） |
| `path` | baseline TSV 路径 |
| `version` | `v1.YYYY-MM-DD`；**任何 cap/median 变更须 bump** |
| `gate_script` | 验证门禁（相对 `tests/`） |
| `update_env` | 录制/更新用的环境变量 |
| `notes` | 关联 PERF 任务 |

当前 **7** 条（zig / io / net / latency / dogfood / async / coldstart）。

---

## 3. 变更流程（PR）

1. 用 `update_env` 脚本重录（勿手改无说明）  
2. 更新 baseline TSV 数值  
3. **同 PR** bump `perf-baseline-registry.tsv` 中对应 `version`（新日期）  
4. PR 描述附 checklist（见 `tests/templates/eng-baseline-change-checklist.txt`）  
5. 跑对应 gate + `run-eng-baseline-governance-gate.sh`

**禁止**：仅放宽 cap 而不 bump version / 无 PR 说明。

---

## 4. 门禁

`tests/run-eng-baseline-governance-gate.sh`：

| 检查 | 说明 |
|------|------|
| manifest | RFC + registry + 7 个 baseline 文件存在 |
| gate 存在 | registry 中每个 `gate_script` 可执行 |
| version 格式 | `v1.YYYY-MM-DD` |
| **diff 联动**（`SHUX_ENG_BASELINE_DIFF_CHECK=1`） | baseline TSV 有 diff → registry 对应 `version` 须变化 |

CI PR 可设：`SHUX_ENG_BASELINE_DIFF_CHECK=1 SHUX_ENG_BASELINE_BASE_REF=origin/main`

---

## 5. 与 PERF 任务关系

| baseline_id | PERF / 领域 |
|-------------|-------------|
| `zig-perf` | PERF-001 |
| `io-perf` | PERF-002 |
| `net-perf` / `net-perf-latency` | PERF-003 |
| `compile-dogfood` | PERF-004 |
| `async-perf` | STD-004 压测 |
| `coldstart-perf` | 冷启动 stretch |

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 注册表 | `tests/baseline/perf-baseline-registry.tsv` |
| 工具库 | `tests/lib/perf-baseline-governance.sh` |
| 门禁 | `tests/run-eng-baseline-governance-gate.sh` |
| PR checklist | `tests/templates/eng-baseline-change-checklist.txt` |

**ENG-001 状态：定版 ✅**
