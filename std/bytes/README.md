# std.bytes

动态字节缓冲 `Bytes`、读游标 `BytesReader`、写游标 `BytesWriter`。

## 依赖

- `std.heap` — 默认堆分配（`alloc_u8` / `realloc_u8` / `free_u8`）；Arena 见 STD-155
- `std.string` — `StrView` 零拷贝互转
- `std.mem` — `Buffer` IO 桥接

## 分配策略

| 路径 | API | 释放 |
|------|-----|------|
| **堆（默认）** | `bytes_new` / `bytes_append_*` | `bytes_deinit` |
| **Arena 外部** | `bytes_from_external` + 预 bump slab | `bytes_deinit`（no-op free）+ `arena64_deinit` |

常量：`BYTES_OWN_HEAP` / `BYTES_OWN_EXTERNAL`；`bytes_is_owned`；`recommend_bytes_alloc` / `recommend_bytes_alloc_arena`。

RFC：`analysis/std-bytes-v1.md`（STD-072）· `analysis/std-bytes-arena-v1.md`（STD-155）

## Gate

```bash
./tests/run-std-bytes-gate.sh          # STD-072
./tests/run-std-bytes-arena-gate.sh    # STD-155 Arena
```
