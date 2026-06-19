# PERF-006 CPU cache miss 重点治理 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`DOD-S1`（SoA/AoS）、`PERF-005`（flamegraph）、`OBS-003`（结构化日志）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **热点 L1 可见** | SoA 列扫描路径 L1 miss 率可测、可 cap |
| **SoA 优于 AoS** | 同 bench 下 SoA miss% < AoS（列主序收益） |
| **共享 perf 库** | `tests/lib/perf-cache-miss.sh` 供 dod-soa / gate 复用 |
| **可 grep** | `shux: [SHUX_CACHE_MISS]` 报告行 |

验收（NEXT PERF-006）：**热点路径 miss 降低** → baseline cap + dod-soa 挂钩 + gate。

---

## 2. 测量方法（v1）

| 项 | 说明 |
|----|------|
| 工具 | Linux `perf stat`（L1-dcache-loads/misses，回落 cache-references/misses） |
| Bench | `tests/bench/dod_soa_sum_x.sx` vs `dod_aos_sum_x.sx` |
| f32 | `dod_f32_soa_sum_x.sx` vs `dod_f32_aos_sum_x.sx` |
| 默认 N | `SHUX_DOD_BENCH_N=4096` |

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_DOD_SOA_MAX_L1_MISS_PCT` | `1.0` | SoA i32 cap（%） |
| `SHUX_DOD_SOA_FAIL` | `0` | `1` 时超 cap 硬失败 |
| `SHUX_DOD_SOA_REQUIRE_L1` | `0` | CI Linux 可设 `1` 禁止 SKIP |
| `SHUX_CACHE_MISS_PREFIX` | `shux: [SHUX_CACHE_MISS]` | 报告前缀 |

---

## 3. 基线（cache-miss-perf.tsv）

| case_id | layout | max_l1_miss_pct | soa_lt_aos |
|---------|--------|-----------------|------------|
| `dod_soa_sum_x` | soa | 1.0 | yes |
| `dod_f32_soa_sum_x` | soa | 1.5 | yes |

---

## 4. 报告行

```text
shux: [SHUX_CACHE_MISS] case=dod_soa_sum_x layout=soa l1_miss_pct=0.4200 cap_pct=1.0 ok=1
```

实现：`perf_cm_report_emit()` in `tests/lib/perf-cache-miss.sh`；`run-perf-dod-soa.sh` 在 L1 测量后 emit。

---

## 5. 治理流程

1. 本地 / CI：`./tests/run-perf-dod-soa.sh`（Linux + native shux）  
2. 超 cap：`SHUX_DOD_SOA_FAIL=1` 或调优 SoA layout / `align(64)`（DOD-CL-S1）  
3. 新热点：增 `cache-miss-perf.tsv` 行 + manifest case  
4. 门禁：`./tests/run-perf-cache-miss-gate.sh`

---

## 6. 门禁

`tests/run-perf-cache-miss-gate.sh`：

1. RFC + manifest + baseline + lib  
2. `run-perf-dod-soa.sh` 引用 `perf-cache-miss.sh`  
3. Linux + perf 可选烟测；其它平台 manifest OK + SKIP bench  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-cache-miss.tsv` |
| 基线 | `tests/baseline/cache-miss-perf.tsv` |
| 库 | `tests/lib/perf-cache-miss.sh` |
| bench | `tests/run-perf-dod-soa.sh` |
| 门禁 | `tests/run-perf-cache-miss-gate.sh` |
| DOD | `tests/run-dod-s1-gate.sh` |
| vec SoA | `std/vec/README.md` |
| 结构化日志 | `analysis/obs-structured-log-v1.md` |

**PERF-006 状态：定版 ✅**
