# OBS-001 编译阶段耗时埋点 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-004`、`SHUX_DEBUG_PIPE`、`pipeline.x`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **三阶段可见** | 单次编译输出 parse / typeck / codegen 毫秒耗时 |
| **零默认开销** | 未设环境变量时不计时、不打印 |
| **主链覆盖** | `run_x_pipeline_impl`（.x 流水线）全路径 |
| **可 grep** | 固定 stderr 前缀，便于 gate / CI / 脚本聚合 |

验收（NEXT OBS-001）：**parse/typeck/codegen 耗时输出** + manifest + gate。

---

## 2. 环境变量

| 变量 | 值 | 行为 |
|------|-----|------|
| `SHUX_COMPILE_PHASE_TIMING` | 任意非空 | 启用阶段计时并在流水线结束（或失败退出前）打印汇总 |

与 `SHUX_DEBUG_PIPE` 独立；可同时开启。

---

## 3. 阶段定义（v1）

| phase | 名称 | 范围 |
|-------|------|------|
| 0 | `parse` | `run_x_pipeline_parse_entry_if_needed` + `pipeline_load_and_sync_direct_import_deps` |
| 1 | `typeck` | `run_x_pipeline_typecheck_entry` |
| 2 | `codegen` | `run_x_pipeline_codegen_deps` + `run_x_pipeline_codegen_entry` |

`shux check`（check-only）在 typeck 通过后打印；`codegen_ms=0.000`。

---

## 4. 输出格式

单行 stderr（毫秒，三位小数）：

```text
shux: [SHUX_COMPILE_PHASE_TIMING] parse_ms=12.345 typeck_ms=3.210 codegen_ms=0.000 total_ms=15.555
```

实现：`compiler/src/runtime_driver_abi.c`（`driver_compile_phase_timing_*`）  
编排：`compiler/src/pipeline/pipeline.x`（`run_x_pipeline_impl`）

---

## 5. 矩阵

文件：`tests/baseline/obs-compile-phase-timing.tsv`

列：`item_id` · `kind` · `anchor` · `notes`

---

## 6. 门禁

`tests/run-obs-compile-phase-timing-gate.sh`：

1. RFC + manifest 存在  
2. `runtime_driver_abi.c` / `pipeline.x` 含必需符号与 env 名  
3. 有 native `shux` 时：`SHUX_COMPILE_PHASE_TIMING=1 check` 烟测 grep 汇总行  

---

## 7. 用法示例

```bash
SHUX_COMPILE_PHASE_TIMING=1 ./compiler/shux-c check tests/bench/loop_i32.x
SHUX_COMPILE_PHASE_TIMING=1 ./compiler/shux-c tests/bench/loop_i32.x -o /tmp/loop_i32
```

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/obs-compile-phase-timing.tsv` |
| 门禁 | `tests/run-obs-compile-phase-timing-gate.sh` |
| 实现 | `compiler/src/runtime_driver_abi.c` |
| 编排 | `compiler/src/pipeline/pipeline.x` |
