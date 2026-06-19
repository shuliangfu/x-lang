# STD-017 std.heap SHUX_HEAP_TRACE 调试钩子 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-017、`std/heap/heap.c`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-017 | `SHUX_HEAP_TRACE=1` 时统计 alloc/free/realloc 次数与累计请求字节 |

默认关闭；零开销路径为惰性 `getenv` + 分支，未设置时计数器不递增。

---

## 2. API

| 函数 | 说明 |
|------|------|
| `heap_trace_enabled()` | 是否启用 trace；1/0 |
| `heap_trace_stats(out)` | 读取 `HeapTraceStats` 快照 |
| `heap_trace_reset()` | 清零计数 |

`HeapTraceStats` 字段：`alloc_count` / `free_count` / `realloc_count` / `bytes_allocated`。

---

## 3. 环境变量

| 变量 | 语义 |
|------|------|
| `SHUX_HEAP_TRACE` | 非空且非 `0` 启用统计 |

---

## 4. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| 未设置 env | `heap_trace_enabled()==0`；alloc 后 stats 仍为 0 |
| `SHUX_HEAP_TRACE=1` | alloc(32)+free → alloc_count≥1, free_count≥1, bytes≥32 |
| `heap_trace_reset()` | 计数归零 |

---

## 5. 验收

- manifest：`tests/baseline/std-heap-trace.tsv`
- 烟测：`tests/heap/trace_stats.sx`
- 报告：`shux: [SHUX_STD_HEAP_TRACE] status=ok`

---

## 6. 演进

- 按指针簿记 live bytes；与 ASAN/leak 夜跑联动（TST-004）。
