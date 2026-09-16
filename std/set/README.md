# std.set — 集合（HashSet）

**路径**：`std/set/`（仅 mod.x，无 .c）  
**依赖**：std.heap（复用 map_i32_i32_find_c）。对标 Rust HashSet、Zig AutoSet。

Authority = `std/set/mod.x` live exports（`Set_i32`/`Set_u64` 走 overload；`Set_str` 用 `str_*` 前缀）。

| API | 说明 |
|-----|------|
| `new(_tag)` / `with_capacity(s, cap)` | 新建 / 预分配槽位；失败 -1 |
| `insert(s, key)` | 插入；失败 -1 |
| `remove(s, key)` | 移除；存在返回 1 |
| `contains_key(s, key)` | 是否包含；1/0 |
| `length(s)` / `is_empty(s)` | 个数 / 是否为空 |
| `clear(s)` / `reserve(s, new_cap)` | 清空 / 扩容 |
| `deinit(s)` | 释放，调用后不可再用 |
| `str_new` / `str_insert` / `str_contains` / `str_remove` / `str_len` / `str_deinit` | `Set_str` 面 |
