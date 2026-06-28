# std.map — 映射/字典

与 **Zig** std.AutoHashMap、**Rust** HashMap、**Go** map 对标。

## 类型

- **Map_i32_i32**：键值均为 i32，堆分配 keys/vals/occupied，须在不用时 `deinit`。
- **Map_u64_i32** / **Map_str_i32**：u64 键与字符串键变体（`str_*` API）。

## API（Map_i32_i32 / Map_u64_i32 重载）

| 函数 | 说明 |
|------|------|
| `new(0)` / `new(0 as u64)` | 新建空 map（tag 参数用于 i32/u64 重载消歧） |
| `with_capacity(m, capacity)` | 预分配槽位；失败返回 -1 |
| `insert(m, key, value)` | 插入/覆盖；失败返回 -1 |
| `get(m, key, default_val)` | 取值，不存在返回 default_val |
| `contains_key(m, key)` | 是否包含 key |
| `remove(m, key)` | 移除 key；存在返回 1，否则 0 |
| `len(m)` / `is_empty(m)` | 条目数 / 是否为空 |
| `clear(m)` / `reserve(m, new_cap)` | 清空 / 扩容 |
| `deinit(m)` | 释放堆，调用后不可再用 |
| `iter_init(m)` / `iter_next(it)` | 迭代 occupied 槽 |
| `load_factor_pct(m)` | 负载因子百分比 |
| `empty_size()` | 烟测锚点，恒 0 |

字符串键见 `str_new` / `str_insert` / `str_get` / `str_remove` / `str_deinit` 等。

## 实现

- 线性探测哈希表；**负载因子 > 0.75** 时 2 倍扩容（减少 rehash 频率）。

## 性能（已压榨）

- **find 走 .sx 快路径**：`heap.map_find`（`std/heap/ops.sx`）内线性探测，get/contains/remove/insert 均复用。
- **reserve_one**：字面量 8 与 3/4 负载因子，避免阈值函数调用。
- **热路径**：`len_ptr` 避免按值传 Map 结构体。

## 依赖

- `import("std.heap")`；链接时需 `std/heap/heap.o`（malloc/copy；find/mem 在 ops.sx）。
