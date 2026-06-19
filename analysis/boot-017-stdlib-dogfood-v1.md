# BOOT-017 标准库 .sx 前端编译 dogfood 指标 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`PERF-004`、`BOOT-013`、`tests/baseline/stdlib-check-matrix.tsv`

---

## 1. 目标

在 BOOT-013「全模块 `shux check` 正确性」之上，为 **55 个 core/std 模块**记录前端编译（check）**分模块耗时**，作为 PERF-004 的 std 侧 dogfood 扩展。

| 目标 | 说明 |
|------|------|
| **分模块矩阵** | 与 `stdlib-check-matrix.tsv` 一一对应 |
| **计时** | 每模块 `import` 探针 + `shux check -L .`；默认 `RUNS=1`（门禁），基线刷新 `RUNS=3` 取中位数 |
| **基线** | `tests/baseline/stdlib-dogfood.tsv`（module_id → 秒上限） |
| **不回退（可选）** | `SHUX_BOOT017_FAIL_ON_REGRESSION=1` 时 median ≤ 基线 |

---

## 2. 分模块矩阵（PERF-004 扩展）

| tier | 模块示例 | 默认 cap（s） |
|------|----------|---------------|
| `core` | `core.fmt`、`core.mem` | 0.050 |
| `std` | `std.vec`、`std.path` | 0.065 |
| `heavy` | `std.http`、`std.json`、`std.async` | 0.100 |

全表见 `stdlib-dogfood.tsv`（55 行）。与 BOOT-013 探针相同：单文件 `import ${mod}; function main(): i32 { return 0; }`。

---

## 3. 报告格式

```
shux: [SHUX_BOOT017_STDLIB_DOGFOOD] status=ok modules=55 slow=0 p50=0.042 p95=0.068 skip=0
```

| 字段 | 含义 |
|------|------|
| `modules` | 计时模块数 |
| `slow` | 超基线模块数（`FAIL_REGRESSION=0` 时仅计数） |
| `p50` / `p95` | 分模块耗时中位数 / 95 分位 |
| `skip` | 无 native shux 时 1 |

---

## 4. 与 PERF-004 分工

| 维度 | PERF-004 `compile-dogfood` | BOOT-017 `stdlib-dogfood` |
|------|---------------------------|---------------------------|
| 对象 | microbench + 编译器重模块 | core/std 全模块 check |
| 用例数 | 8 | 55 |
| CI 硬门禁 | Linux GHA（编译器） | v1 软指标；硬门禁 opt-in |
| 注册表 | `perf-baseline-registry.tsv` | 同行追加 `stdlib-dogfood` |

---

## 5. Gate

```bash
./tests/run-boot-017-stdlib-dogfood-gate.sh
# 刷新基线：
SHUX_BOOT017_UPDATE_BASELINE=1 SHUX_BOOT017_RUNS=3 ./tests/run-boot-017-stdlib-dogfood.sh
```

---

## 6. 演进

- CI 硬门禁：待 std 模块数稳定后，对 `heavy` tier 子集启用 `FAIL_REGRESSION=1`。
- 与 `comp-incr-compile` 增量编译指标联动（非 BOOT-017）。
