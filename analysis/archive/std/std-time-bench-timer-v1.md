# STD-133：std.time benchmark 计时器 v1

> 状态：**定版（v1，纯 .x 封装单调时钟）**

## 1. API

| 名称 | 说明 |
|------|------|
| `Timer` | 单调计时状态（`start_ns`） |
| `start` / `reset` | 起点捕获与重置（产品短名；非化石 `timer_*`） |
| `elapsed_ns` / `elapsed_us` / `elapsed_ms` / `elapsed_sec` | 已用时长（多单位） |
| `lap_ns` | 分段计时并推进起点 |

底层仍使用 `now_monotonic_ns` + `duration_ns`；无堆分配、无额外 C 代码。

## 2. 关联

- 烟测：`tests/time/bench_timer.x`
- Manifest：`tests/baseline/std-time-bench-timer-manifest.tsv`
- Gate：`./tests/run-std-time-bench-timer-gate.sh`

## 3. Gate

Honesty (2026-08-28 soft fallthrough residual): prefer `xlang_asm` + pin
`XLANG_LINK_XLANG`; explicit-bad `XLANG` / missing native → hard die (refuse
soft fallthrough / prefer-c / soft auto-make / soft SKIP→OK). check
observational (paused 2026-08-05). `bench_timer.x` exit 0 hard-fail (`run+=`).
Report `run=` / `obs=` / `skip=`. Refuse top-level DOC resurrect
(live = `analysis/archive/std/`).

PLATFORM: SHARED archaeology.
