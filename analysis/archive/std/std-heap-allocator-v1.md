# STD-112 std.heap Allocator trait v1

> 更新时间：2026-06-19  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2、`std.vec` 容器接入

---

## 1. 阅读路径

15 分钟速览：`std/heap/mod.x` 中 `Allocator` / `heap_alloc` / `from_arena`，以及 `std/vec/mod.x` 中 `vec_u8_with_allocator`。

---

## 2. Allocator 语义

| API | 说明 |
|-----|------|
| `kind_heap()` | 堆 kind 常量（0） |
| `heap_alloc()` | 默认 libc 堆分配器 |
| `from_arena(a)` | 将 `Arena64` 包装为 bump 分配器 |
| `alloc(al, size)` | 分配；失败 null |
| `free(al, ptr)` | 释放；arena 为 no-op |
| `realloc(al, ptr, new_size)` | 仅堆支持；arena 返回 null |

---

## 3. Vec_u8 接入

- `vec_u8_with_allocator(v, al, cap)` — 预分配
- `vec_u8_push_with_allocator(v, al, x)` — 追加
- `vec_u8_deinit_with_allocator(v, al)` — 释放（测试用）

---

## 4. 验证与门禁

- manifest：`tests/baseline/std-heap-allocator.tsv`
- 烟测：`tests/heap/allocator_vec.x`
- gate：`tests/run-std-heap-allocator-gate.sh`
- 报告：`shux: [SHUX_STD112_HEAP_ALLOC] status=ok`
