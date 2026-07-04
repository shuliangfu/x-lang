# STD-005 std.time 高精度与时区策略 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-001`（io 超时）、`PERF-001`（基准计时）、`std/time/README.md`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读 `std/time/README.md` API 表 |
| 2 | 读本文 §2–§4（时钟语义、精度、时区） |
| 3 | 跑 `./tests/run-time.sh` 或 `./tests/run-std-time-gate.sh` |
| 4 | 在业务代码中用 `now_monotonic_ns` 测耗时，用 `now_wall_sec` 打 UTC 时间戳 |

---

## 2. 时钟语义

| 种类 | API 前缀 | 用途 | 对标 |
|------|----------|------|------|
| **单调（monotonic）** | `now_monotonic_*` | 耗时、超时、基准；**不受** NTP 调整影响 | Rust `Instant`、Zig `Timer` |
| **墙钟（wall）** | `now_wall_*` | 日志时间戳、文件 mtime 对齐；**UTC 纪元秒** | Rust `SystemTime`、Zig `timestamp` |
| **睡眠** | `sleep_*` | 线程让出 CPU；可能提前唤醒 | POSIX `nanosleep` |
| **差值** | `duration_ns` | 纯算术 `to - from`；零 syscall | — |

**规则（v1）**

- 测性能、算超时 → **只用单调时钟**。
- 需要「世界时间」→ **墙钟 UTC**；v1 **不提供**本地时区转换。
- `duration_ns` 参数必须来自**同一**单调时钟源（`now_monotonic_ns`）。

---

## 3. 平台精度矩阵

权威清单：`tests/baseline/std-time-manifest.tsv`（13 个公开 API）。

| 平台 | 单调精度 | 墙钟精度 | 睡眠精度 | 实现 |
|------|----------|----------|----------|------|
| **Linux** | 纳秒 | 纳秒 | `nanosleep` 纳秒级（可能提前唤醒） | `clock_gettime`（常 vDSO） |
| **macOS** | 纳秒 | 纳秒 | 同 Linux | `clock_gettime` |
| **Windows** | 纳秒（QPC 换算） | **100ns**（FILETIME） | `Sleep` **≥1ms** | QPC + `GetSystemTimePreciseAsFileTime` |

**精度承诺（v1）**

| API | 承诺 |
|-----|------|
| `now_monotonic_ns` | 单次 syscall；相邻调用非递减（烟测校验） |
| `now_wall_*` | UTC Unix 纪元；`sec/ms/us/ns` 由 `_ns` 整数除派生，**同一次读** |
| `sleep_ms(50)` | 烟测 elapsed **≥10ms**（宽松，兼容 Windows 粒度） |
| `sleep_ns` on Windows | 内部抬升到 ≥1ms |
| `duration_ns` | 精确整数差；无平台差异 |

实现文件：`std/time/time.c`（`_WIN32` 与 `CLOCK_MONOTONIC` 双分支）。

---

## 4. 时区策略 timezone（v1）

| 策略 | v1 行为 | 未来（非 v1） |
|------|---------|----------------|
| **墙钟基准** | 一律 **UTC**（Unix epoch） | — |
| **本地时区** | **不支持** `now_local_*` / `strftime` 封装 | 可选 `std.time.zone` 或 locale 模块 |
| **夏令时** | 不涉及（无本地时区） | 文档化后再加 |
| **闰秒** | 跟随 OS `CLOCK_REALTIME`；不单独抽象 | 若需 TAI/UTC 分离再 RFC |

用户若需本地时间：**应用层**用 UTC 秒 + 自有偏移表，或等待 v2 时区 API。

---

## 5. API 面（13 函数）

完整符号（manifest 逐条校验）：

- `now_monotonic_ns`、`now_monotonic_us`、`now_monotonic_ms`、`now_monotonic_sec`
- `now_wall_sec`、`now_wall_ms`、`now_wall_us`、`now_wall_ns`
- `sleep_ns`、`sleep_us`、`sleep_ms`、`sleep_sec`
- `duration_ns`

| 函数 | 说明 |
|------|------|
| `now_monotonic_ns/us/ms/sec` | 单调时钟 |
| `now_wall_sec/ms/us/ns` | 墙钟 UTC |
| `sleep_ns/us/ms/sec` | 睡眠 |
| `duration_ns` | 纳秒差 |

源码：`std/time/mod.x`（薄封装）+ `std/time/time.c`（平台）。

---

## 6. 验证与门禁

```bash
# manifest + API + 烟测（native shux）
./tests/run-std-time-gate.sh

# 模块回归（compile + run main）
./tests/run-time.sh

# 单文件 typeck / runnable 烟测
./compiler/shux check -L . tests/time/precision_smoke.x
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/std-time-precision-v1.md` |
| manifest | `tests/baseline/std-time-manifest.tsv` |
| 库 | `tests/lib/std-time.sh` |
| 门禁 | `tests/run-std-time-gate.sh` |
| 烟测 | `tests/time/main.x`、`tests/time/precision_smoke.x` |
| README | `std/time/README.md` |
| 示例 catalog | `tests/baseline/std-examples-catalog.tsv`（`ex_time`） |

**STD-005 状态：定版 ✅**
