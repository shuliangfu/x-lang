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

Gate honesty（2026-08-26 soft→硬绿；对齐 STD-137）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin-arm64 asm→c remap）
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05；失败不硬红）
- `tests/time/bench_timer.x` **exit 0 硬失败**（有 native xlang 时禁止 soft SKIP）
- 无 native xlang → **FAIL**（禁止无 native 则 SKIP 假绿）
- TSV／DOC 锚对齐产品短名：`Timer`／`start`／`reset`／`elapsed_ns`／`elapsed_ms`／`lap_ns`
- 报告：`check=`／`run=`／`skip=`
- 拒顶层 DOC 复活（live = `analysis/archive/std/`）

PLATFORM: SHARED archaeology.
