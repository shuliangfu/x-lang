# COMP-002 typeck 热路径剖析与优化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-004`（compile dogfood）、`TYPE-001/002`、`run-typeck-wpo-optin-smoke.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **热点清单** | 固定 typeck 热函数矩阵，可追溯 tier / 优化状态 |
| **已落地优化** | 至少 6 项 `opt_status=done`（mega 分派、SoA、inline 快路径等） |
| **防回退** | `check_typeck` 纳入 compile-dogfood；region/linear/WPO hook 绿 |
| **后续 PR** | `planned` / `monitor` 行作为下一批优化 backlog |

验收（NEXT COMP-002）：**热点函数有优化 PR** → v1 以矩阵 + 门禁 + dogfood `check_typeck` 固化。

---

## 2. 剖析方法（v1）

| 手段 | 用途 |
|------|------|
| **模块 dogfood** | `shux check compiler/src/typeck/typeck.sx` 中位数（PERF-004 `check_typeck`） |
| **源码体量 + 调用树** | `typeck_sx_ast` → `check_block` / `check_expr` → `check_expr_impl_mega` |
| **WPO reach** | `typeck_wpo.o` 与 layout helper partial 链（`run-typeck-wpo-optin-smoke.sh`） |
| **功能 hook** | region / linear typeck 烟测覆盖 slice/linear 热路径 |

profiling（`perf` / 采样）留作 v2；v1 以**固定清单 + dogfood 不回退**为主。

---

## 3. 热点矩阵

文件：`tests/baseline/typeck-hotpath-matrix.tsv`

| tier | 含义 |
|------|------|
| T0 | 模块入口（`typeck_sx_ast`） |
| T1 | expr/block 递归（最高频） |
| T2 | layout / unify / dep |
| T3 | 命名比较、类型 ref 分配 |

| opt_status | 含义 |
|------------|------|
| `done` | 已有可述优化（须在 notes 列说明） |
| `monitor` | 已知热点，仅 dogfood 监控 |
| `planned` | backlog，下一 PR |

---

## 4. 已落地优化（v1 摘要）

| hot_id | 优化要点 |
|--------|----------|
| `check_expr_impl_mega` | ExprKind 分派至 `typeck_check_expr_*` 子 helper，避免巨型 switch 单函数 |
| `check_expr` / `check_block` | impl 分层 + mega 委托，EMIT_HEAVY 可 slice |
| `typeck_sx_ast` | per-function loop + library 快路径 |
| `typeck_wpo_unify_soa_layouts` | WPO 跨模块 SoA layout 统一，消除 AoS↔SoA 转换 |
| `typeck_inline_u8_64_array_field_type_ref` | 常见 `u8[64]` 字段类型 inline，跳过通用 layout 查表 |
| `typeck_soa_array_storage_size_glue` | SoA 数组存储尺寸 C glue，减少 SX 递归 depth |
| `hot_reorder_layout` | `SHUX_HOT_REORDER=1` 热字段置前 diagnostic（DOD-CL-S2） |

---

## 5. 门禁

`tests/run-typeck-hotpath-gate.sh`：

1. manifest：RFC + matrix + `min_opt_done`  
2. 符号存在：`symbol` 须在 `source` 文件中出现  
3. `done` 计数 ≥ `min_opt_done`  
4. hook：`run-typeck-region.sh`、`run-typeck-linear.sh`（有 shux 时）；WPO smoke（Linux + shux_asm）  
5. dogfood：`check_typeck` 行存在于 `compile-dogfood.tsv`（由 PERF-004 gate 硬跑）

---

## 6. 变更流程

1. 新优化合并 → 改 matrix `opt_status`/`notes`，必要时 bump `compile-dogfood` + registry version  
2. 新热点 → 增 matrix 行，`monitor` 起步  
3. 本地：`./tests/run-typeck-hotpath-gate.sh`

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/typeck-hotpath-matrix.tsv` |
| 门禁 | `tests/run-typeck-hotpath-gate.sh` |
| typeck 源码 | `compiler/src/typeck/typeck.sx` |
| dogfood | `tests/baseline/compile-dogfood.tsv`（含 `check_typeck`） |
| WPO smoke | `tests/run-typeck-wpo-optin-smoke.sh` |

**COMP-002 状态：定版 ✅**
