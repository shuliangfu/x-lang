/* seeds/runtime_slice_glue.from_x.c — G-02f-22 product TU
 * Logic still C until full .x port.
 */
/* compiler/src/asm/runtime_slice_glue.c — slice 构造薄封装（语言限制 C 桩）
 *
 * 【Why 根源】SHUX parser/codegen 暂不支持 slice 复合字面量（[]i32 { data, length }），
 * 也不支持范围切片（arr[0..n]）。core/slice/mod.x 的 subslice_i32 / chunk_i32 / split_at_i32
 * 等零拷贝视图须经本 TU 构造切片。返回值 ABI 与 codegen 生成的
 * struct shux_slice_<T>_t { T *data; size_t length; } 一致（16 字节，按值返回）。
 *
 * 【Invariant】data 指向至少 total_len 个 T 元素的可读缓冲；start/len 不越界（subslice 内部钳制）。
 * 【Asm/Perf】6 个函数均为纯寄存器运算（指针加法 + min），无内存访问，编译为 ≤5 条指令。
 *
 * 从 core/slice/slice.c 迁入（G-01：core/ 零 C）。待 codegen 补齐 slice 字面量后迁移回 .x。
 */
#include <stdint.h>
#include <stddef.h>

struct shux_slice_int32_t { int32_t *data; size_t length; };
struct shux_slice_uint8_t  { uint8_t  *data; size_t length; };
struct shux_slice_uint64_t { uint64_t *data; size_t length; };

/* from_ptr：直接包装 (ptr,len) 为切片，不做边界检查。 */
struct shux_slice_int32_t core_slice_i32_from_ptr_c(int32_t *data, size_t length) {
    struct shux_slice_int32_t s; s.data = data; s.length = length; return s;
}
struct shux_slice_uint8_t core_slice_u8_from_ptr_c(uint8_t *data, size_t length) {
    struct shux_slice_uint8_t s; s.data = data; s.length = length; return s;
}
struct shux_slice_uint64_t core_slice_u64_from_ptr_c(uint64_t *data, size_t length) {
    struct shux_slice_uint64_t s; s.data = data; s.length = length; return s;
}

/* subslice：从 start 起取 len 个元素；越界钳制（start>=total → 空，尾部不足截断）。 */
struct shux_slice_int32_t core_subslice_i32_c(int32_t *data, size_t total_len, size_t start, size_t len) {
    struct shux_slice_int32_t s;
    if (start >= total_len) { s.data = data; s.length = 0; return s; }
    size_t avail = total_len - start;
    if (len > avail) len = avail;
    s.data = data + start; s.length = len; return s;
}
struct shux_slice_uint8_t core_subslice_u8_c(uint8_t *data, size_t total_len, size_t start, size_t len) {
    struct shux_slice_uint8_t s;
    if (start >= total_len) { s.data = data; s.length = 0; return s; }
    size_t avail = total_len - start;
    if (len > avail) len = avail;
    s.data = data + start; s.length = len; return s;
}
struct shux_slice_uint64_t core_subslice_u64_c(uint64_t *data, size_t total_len, size_t start, size_t len) {
    struct shux_slice_uint64_t s;
    if (start >= total_len) { s.data = data; s.length = 0; return s; }
    size_t avail = total_len - start;
    if (len > avail) len = avail;
    s.data = data + start; s.length = len; return s;
}
