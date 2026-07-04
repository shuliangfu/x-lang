# std.mem — 内存操作与 Buffer ABI

与 **Zig** std.mem、**Rust** std::mem / std::ptr、**Go** bytes 对标。

## 一、内存操作（copy / set / compare）

| 函数 | 说明 |
|------|------|
| `copy(dst, src, n)` | 字节拷贝 dst[0..n-1] = src[0..n-1]；n≤0 不写。对标 Zig std.mem.copy、Rust ptr::copy。 |
| `set(ptr, byte, n)` | 字节填充 ptr[0..n-1] = byte；n≤0 不写。对标 Zig std.mem.set、Rust ptr::write_bytes。 |
| `compare(a, b, n)` | 字节比较 a[0..n-1] 与 b[0..n-1]；返回 <0 / 0 / >0。对标 Zig std.mem.compare、Go bytes.Compare。 |

实现：`ops.x`（set/compare/map）+ `libc.x`（libc malloc）；无 `heap.c`。

### 有界封装（STD-144）

| 函数 | 说明 |
|------|------|
| `copy_bounded(dst, dst_cap, src, n)` | n>cap 返回 -1；否则 copy 并返回 n |
| `set_bounded(ptr, cap, byte, n)` | n>cap 返回 -1；否则 set 并返回 n |
| `compare_bounded(a, a_len, b, b_len)` | 先比公共前缀，再按长度决胜 |
| `buffer_from(ptr, len)` | 构造 `Buffer { ptr, len, handle=0 }` |

RFC：`analysis/std-mem-safe-v1.md`；门禁 `./tests/run-std-mem-safe-gate.sh`。

## 与 core.mem 职责边界（STD-018）

| 模块 | 职责 |
|------|------|
| **core.mem** | 无 OS/无堆：`mem_copy` / `mem_move` / `mem_zero` / 对齐辅助；编译器可内建化 |
| **std.mem** | Buffer ABI + 经 **std.heap** 的 `copy` / `set` / `compare`；**禁止** `import("core.mem")` 双路径 |

详细矩阵与选用指南：`analysis/std-mem-boundary-v1.md`；门禁 `./tests/run-std-mem-boundary-gate.sh`。

## 二、Buffer ABI 与舒 IO 预注册

| 类型/函数 | 说明 |
|-----------|------|
| `Buffer` | 结构体 { ptr, len, handle }，24 字节，与 std.io.driver Buffer 同布局。 |
| `register_buffer(buf)` | 调用 std.io.core.shux_io_register，与 std.io.driver 共用同一实现。 |

## 依赖

- **std.io.core**：register_buffer 用 shux_io_register。
- **std.heap**：copy/set/compare 用 heap 的 copy_u8_at、heap_mem_set_c、heap_mem_compare_c（链接 heap.o）。

## 对标说明

- **Zig**：std.mem.copy、set、compare、@sizeOf；分配在 Allocator（std.heap）。
- **Rust**：std::mem::size_of、align_of；std::ptr::copy、write_bytes；分配在 std::alloc。
- **Go**：无独立 mem 包；bytes.Equal、bytes.Compare；分配由运行时内部处理。
