# std.bytes — 动态字节缓冲

**模块路径**：`std/bytes/mod.x`（纯 .x，依赖 std.heap/string/mem）  
**对标**：Zig ArrayList(u8)、Go bytes.Buffer、Rust Vec<u8>。

## API 概览

### Bytes 容器

- `bytes_new` / `bytes_with_capacity` / `bytes_from_slice` / `bytes_from_view`
- `bytes_append_byte` / `bytes_append_slice` / `bytes_clear` / `bytes_deinit`
- `bytes_from_external` — Arena/外部切片绑定（STD-155，不拥有内存）

### 游标

- `reader_new` / `reader_read` / `reader_seek` / `reader_remaining`
- `writer_new` / `writer_write` / `writer_remaining_cap`

### 互操作

- `bytes_as_view` — 零拷贝 StrView
- `bytes_as_buffer` — 转 std.mem.Buffer（IO 桥接）
- `bytes_eq` — 等长字节比较（1/0）

## 测试

- `bash tests/run-std-bytes-gate.sh`
