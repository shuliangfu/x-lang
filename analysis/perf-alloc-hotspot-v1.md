# PERF-007 内存分配热点治理 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ZC-4`（string arena）、`DOD-CL-S2`（Arena64）、`OBS-003`（结构化日志）、`PERF-005`（flamegraph）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **热点零 heap** | Arena/bump 路径禁止 per-op `malloc/calloc/realloc` |
| **可测可 cap** | Linux `strace` 统计次数，baseline TSV 设上限 |
| **共享库** | `tests/lib/perf-alloc-hotspot.sh` 供 bench / gate 复用 |
| **可 grep** | `shux: [SHUX_ALLOC_HOTSPOT]` 报告行 |

验收（NEXT PERF-007）：**alloc 次数与总量下降** → v1 以「热路径零 heap 调用」为可执行代理指标；总量治理随后续编译器/运行时埋点扩展。

---

## 2. 测量方法（v1）

| 项 | 说明 |
|----|------|
| 工具 | Linux `strace -e trace=memory` |
| 计数 | `malloc(` / `calloc(` / `realloc(` 行数 |
| 排除 | `posix_memalign`（Arena64 chunk 一次性对齐分配，非 per-op heap） |
| Bench | `string_arena_concat`（ZC-4）、`cl_arena64_smoke`（DOD-CL-S2） |

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_ALLOC_HOTSPOT_FAIL` | `0` | `1` 时超 cap 硬失败 |
| `SHUX_ALLOC_HOTSPOT_REQUIRE_STRACE` | `0` | CI Linux 可设 `1` 禁止 SKIP |
| `SHUX_ALLOC_HOTSPOT_PREFIX` | `shux: [SHUX_ALLOC_HOTSPOT]` | 报告前缀 |
| `SHUX_ALLOC_HOTSPOT_BASELINE` | `tests/baseline/alloc-hotspot-perf.tsv` | cap 表 |

---

## 3. 基线（alloc-hotspot-perf.tsv）

| case_id | bench_src | max_malloc | max_calloc | max_realloc |
|---------|-----------|------------|------------|-------------|
| `string_arena_concat` | `tests/bench/string_arena_concat.sx` | 0 | 0 | 0 |
| `cl_arena64_smoke` | `tests/dod/cl_arena64_smoke.sx` | 0 | 0 | 0 |

---

## 4. 报告行

```text
shux: [SHUX_ALLOC_HOTSPOT] case=string_arena_concat malloc=0 calloc=0 realloc=0 cap_malloc=0 cap_calloc=0 cap_realloc=0 ok=1
```

实现：`perf_ah_report_emit()` in `tests/lib/perf-alloc-hotspot.sh`；`run-perf-string-arena.sh` 与 `run-perf-alloc-hotspot.sh` 在 strace 后 emit。

---

## 5. 治理流程

1. **识别**：`PERF-005` flamegraph 或 strace 见意外 `malloc`。
2. **归类**：per-op 堆分配 → 改 Arena64 / bump / 栈缓冲；一次性 init 保留 `posix_memalign`。
3. **验证**：`./tests/run-perf-alloc-hotspot.sh` 全 case 绿。
4. **门禁**：`./tests/run-perf-alloc-hotspot-gate.sh`（manifest + Linux strace 烟测）。

---

## 6. 文件索引

| 路径 | 角色 |
|------|------|
| `analysis/perf-alloc-hotspot-v1.md` | 本文 |
| `tests/baseline/perf-alloc-hotspot.tsv` | manifest |
| `tests/baseline/alloc-hotspot-perf.tsv` | case cap |
| `tests/lib/perf-alloc-hotspot.sh` | strace 库 |
| `tests/run-perf-alloc-hotspot.sh` | 统一 runner |
| `tests/run-perf-alloc-hotspot-gate.sh` | gate |
| `tests/run-perf-string-arena.sh` | ZC-4 hook（emit） |

---

## 7. 后续（v2 候选）

- 编译器 AST pool：`malloc` 总量与峰值（`SHUX_COMPILE_ALLOC`）
- `malloc_usable_size` / sanitizer 统计字节量
- 与 `PERF-008` syscall 批处理联合看板

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-alloc-hotspot.tsv` |
| 基线 | `tests/baseline/alloc-hotspot-perf.tsv` |
| 库 | `tests/lib/perf-alloc-hotspot.sh` |
| runner | `tests/run-perf-alloc-hotspot.sh` |
| 门禁 | `tests/run-perf-alloc-hotspot-gate.sh` |
| ZC-4 | `tests/run-zc4-gate.sh` |
| 结构化日志 | `analysis/obs-structured-log-v1.md` |

**PERF-007 状态：定版 ✅**
