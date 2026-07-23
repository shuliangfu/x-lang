# OBS-003 统一日志结构化规范 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`OBS-001`（编译阶段）、`OBS-002`（async trace）、`std/log`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **统一行格式** | stderr 一行一事件，key=value 可 grep / jq / Loki |
| **双轨兼容** | 遗留 `xlang: [COMPONENT] …` 与新版 `xlang: level=… component=…` |
| **注册表** | manifest 列出 Tier-1 组件与必需字段 |
| **零默认开销** | 人类 `[INFO]` 日志不变；结构化 API 显式调用 |

验收（NEXT OBS-003）：**日志可被机器聚合分析** → RFC + registry + `log_write_structured_kv_c` + gate。

---

## 2. 行格式（v1）

### 2.1 结构化（推荐，std.log / 新埋点）

```text
xlang: level=info component=obs_smoke event=gate_ok case=1
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `level` | 是 | `debug` / `info` / `warn` / `error` |
| `component` | 是 | 组件名（snake 或 `XLANG_*` 大写常量） |
| 其它 | 否 | 小写 snake `key=value`，值勿含空格 |

实现：`std/log/log.x` → `log_write_structured_kv_c()`；`.x` → `structured_kv()`。

### 2.2 遗留 bracket（OBS-001/002、ENG 预检等）

```text
xlang: [XLANG_COMPILE_PHASE_TIMING] parse_ms=12.345 typeck_ms=3.210 ...
xlang: [XLANG_ASYNC_RUNTIME_TRACE] rank=1 kind=task_run worker=0 us=1234 ...
```

规则：前缀 `xlang: [COMPONENT]` + 空格分隔 kv；**COMPONENT 须在 registry 登记**。

---

## 3. 环境变量

| 变量 | 默认 | 行为 |
|------|------|------|
| `XLANG_LOG_MIN_LEVEL` | 未设 | 若设 0–3，映射 `log_set_min_level_c`（与 std.log 一致） |
| 各组件 env | 见子 RFC | 如 `XLANG_COMPILE_PHASE_TIMING`、`XLANG_ASYNC_RUNTIME_TRACE` |

---

## 4. Tier-1 组件注册表

文件：`tests/baseline/obs-structured-log.tsv`

| component | 来源 |
|-----------|------|
| `XLANG_COMPILE_PHASE_TIMING` | OBS-001 `runtime.c` |
| `XLANG_ASYNC_RUNTIME_TRACE` | OBS-002 `scheduler.c` |
| `XLANG_RELEASE_PRECHECK` | ENG-004 预检脚本 |
| `XLANG_PERF_FLAMEGRAPH` | PERF-005 flamegraph |
| `XLANG_ROLLBACK_DRILL` | ENG-006 演练 |
| `XLANG_PERF_ALERT` | OBS-004 性能回归 |
| `XLANG_CACHE_MISS` | PERF-006 L1 miss |
| `XLANG_ALLOC_HOTSPOT` | PERF-007 heap 热点 |
| `XLANG_SYSCALL_BATCH` | PERF-008 syscall 批处理 |
| `XLANG_NET_ZC` | PERF-009 网络零拷贝 CPU/byte |
| `XLANG_ZIG_STRATEGY` | PERF-011 Zig 战略看板 |
| `obs_smoke` | gate 烟测 |

---

## 5. 聚合示例

```bash
# 提取结构化行
grep -E '^xlang: level=' build.log

# 遗留 bracket 组件
grep -F 'xlang: [XLANG_COMPILE_PHASE_TIMING]' build.log | sed 's/.*\] //'

# 烟测
./tests/run-obs-structured-log-gate.sh
```

---

## 6. 门禁

`tests/run-obs-structured-log-gate.sh`：

1. RFC + manifest + `log.c` 符号  
2. registry 中 bracket 组件在仓库可 grep  
3. `obs_structured_log_smoke.c` 输出合法结构化行  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/obs-structured-log.tsv` |
| 校验库 | `tests/lib/obs-structured-log.sh` |
| 烟测 | `tests/bench/obs_structured_log_smoke.c` |
| 门禁 | `tests/run-obs-structured-log-gate.sh` |
| std.log | `std/log/log.c`、`std/log/mod.x` |
| 编译阶段 | `analysis/obs-compile-phase-timing-v1.md` |
| async trace | `analysis/obs-async-runtime-trace-v1.md` |

**OBS-003 状态：定版 ✅**
