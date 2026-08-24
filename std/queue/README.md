# std.queue — 双端队列（VecDeque）

**路径**：`std/queue/`（mod.x + queue.x/queue_glue.c 胶层）  
**依赖**：std.heap。对标 Rust VecDeque、Zig std.fifo。

Authority = `std/queue/mod.x` live exports（模块短名；无 `queue_i32_` 前缀）。

| API | 说明 |
|-----|------|
| `new()` | 新建空队列 |
| `with_capacity(q, cap)` | 预分配；失败 -1 |
| `push_back(q, x)` / `push_front(q, x)` | 队尾/队首插入 |
| `pop_back(q)` / `pop_front(q)` | 队尾/队首弹出（空返回 0） |
| `get(q, i)` / `at(q, i)` | 取第 i 个元素 |
| `length(q)` / `is_empty(q)` | 个数 / 是否为空 |
| `clear(q)` / `reserve(q, new_cap)` / `deinit(q)` | 清空 / 扩容 / 释放 |
