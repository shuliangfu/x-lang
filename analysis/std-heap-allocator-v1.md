# STD-112：std.heap 自定义 Allocator trait v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-heap-allocator.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-heap-allocator.tsv` |
| 3 | `./tests/run-std-heap-allocator-gate.sh` |

---

## 2. Allocator 语义

| API | 说明 |
|-----|------|
| `allocator_kind_heap` / `allocator_kind_arena` | 后端种类 |
| `allocator_heap()` | libc 堆分配器 |
| `allocator_from_arena(a)` | Arena64 bump 包装 |
| `allocator_alloc` / `allocator_free` / `allocator_realloc` | 统一分配接口 |
| `vec_u8_with_allocator` | Vec_u8 容器接入（预分配） |
| `vec_u8_push_with_allocator` | Vec_u8 扩容/追加 |
| `vec_u8_deinit_with_allocator` | 按后端释放（arena 为 no-op） |

**Arena 语义**：`free` 为 no-op；`realloc` 仅在扩容时 bump 新块并拷贝；生命周期由 `arena64_deinit` 统一管理。

---

## 3. 烟测

1. heap 分配器 + Vec_u8 push `"AB"` 往返  
2. arena 分配器 + Vec_u8 push `"D"` + arena 销毁  

---

## 4. 验证与门禁

```bash
./tests/run-std-heap-allocator-gate.sh
```
