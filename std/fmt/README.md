# std.fmt — 格式化与标准输出

**模块路径**：`std/fmt/mod.sx`  
**依赖**：core.fmt、std.io。  
**对标**：Zig std.fmt、Rust std::fmt。

## API 概览

### 重导出 core.fmt

- `fmt_i32(x): i32` — 占位，返回 x（自举前无 buffer 时透传）。
- `fmt_i32_to_buf(buf, cap, x): i32` — 将 i32 十进制写入 buf，返回写入字节数，不足返回 -1。
- `fmt_u32_to_buf(buf, cap, u): i32` — 将 u32 十进制写入 buf。
- `fmt_i64_to_buf(buf, cap, x): i32` — 将 i64 十进制写入 buf。
- `fmt_u64_to_buf(buf, cap, u): i32` — 将 u64 十进制写入 buf。
- `fmt_bool_to_buf(buf, cap, b): i32` — 将 bool 写为 "true"/"false"。
- `fmt_f64_to_buf(buf, cap, x): i32` — 将 f64 写为小数形式（固定 6 位小数）。
- `fmt_u32_hex_to_buf(buf, cap, u): i32` — 将 u32 写为十六进制小写。
- `fmt_u64_hex_to_buf(buf, cap, u): i32` — 将 u64 写为十六进制小写。
- `fmt_append_i32_to_buf(buf, cap, off, x): i32` — 从 buf[off] 起追加 i32 十进制，返回新偏移或 -1。
- `fmt_append_i64_to_buf(buf, cap, off, x): i32` — 从 buf[off] 起追加 i64 十进制。
- `fmt_usize_to_buf` / `fmt_isize_to_buf` — usize/isize 十进制写入。
- `format_template_1_i32(buf, cap, pat, pat_len, val): i32` — 单 `{}` 占位模板（STD-166）。
- `placeholder(): i32` — 占位，表示模块可 import。

### 标准输出（委托 std.io，零拷贝）

- `print(ptr, len): i32` — 将 ptr[0..len] 写入 stdout；返回写入字节数，-1 错误。
- `println(ptr, len): i32` — 将 ptr[0..len] 写入 stdout 再写换行；返回首段写入字节数，-1 错误。

### 多参数拼接（函数重载，直接写 buf，无 tmp、无二次拷贝）

- `format_2(buf, cap, a, b): i32` — 按实参类型 overload 分派（i32/u32/i64/u64/usize/isize、*u8、bool、f64 等组合），返回总字节数或 -1。
- `format_3(buf, cap, a, b, c): i32` — 三字段 overload 拼接。

## 实现说明

- core 无 OS 依赖；std.fmt 仅重导出 core.fmt 并扩展 print/println、format_2/format_3 重载。
- print/println 直接写 stdout，不先 format 到 String，无多余分配。

## 性能（已压榨）

- **format_2 / format_3**：函数重载 + 直接写 buf（`fmt_scalar_to_buf` / 专用 fmt_*），**无中间 tmp、无二次拷贝**。
- **print/println**：薄封装，仅转发 io.print_str，零拷贝；瓶颈在 std.io 与内核写。
- **重导出**：单层转发，无额外分配；LTO 可内联。

## 测试

- `bash tests/run-fmt-std.sh`
