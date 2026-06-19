# STD-155：std.bytes 与 std.heap Arena 协作 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-072 `std.bytes`、STD-112 `Allocator` / `Arena64`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-bytes-arena-manifest.tsv` |
| 3 | `./tests/run-std-bytes-arena-gate.sh` |
| 4 | 烟测：`tests/std-bytes/arena_external.sx` |

---

## 2. 策略表

| 场景 | 路径 | API |
|------|------|-----|
| 默认 / 长生命周期 | 堆 | `bytes_new` → `bytes_deinit` |
| 短生命周期批处理 | Arena64 bump | `arena64_init` → `arena64_alloc` → `bytes_from_external` → `arena64_deinit` |
| 策略查询 | 文档常量 | `recommend_bytes_alloc` / `recommend_bytes_alloc_arena` |

常量：`BYTES_OWN_HEAP`（1）、`BYTES_OWN_EXTERNAL`（0）；`bytes_is_owned` 探测。

---

## 3. Arena 工作流

```text
arena64_init(&arena, cap)
slab = arena64_alloc(&arena, slab_cap, align)
b = bytes_from_external(slab, 0, slab_cap)
bytes_append_slice(&b, ...)   // len+extra <= cap，否则 -1
bytes_deinit(&b)              // 外部：no-op free，仅清零字段
arena64_deinit(&arena)        // 一次释放整块 chunk
```

外部绑定 **不可** `bytes_reserve` / `bytes_grow` 扩容；须预分配足够 slab 或换更大 bump。

---

## 4. Gate

```bash
./tests/run-std-bytes-arena-gate.sh
```

报告：`shux: [SHUX_STD155_BYTES_ARENA]`

回归：保留 `run-std-bytes-gate.sh`（STD-072 堆路径不破）。

---

## 5. 非目标（v1）

- `Bytes` 内部自动切换 Allocator trait
- Arena 上自动 reloc / 链式 chunk 扩容
