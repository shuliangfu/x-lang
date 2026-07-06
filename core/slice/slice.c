/* core/slice/slice.c — slice 构造薄封装（语言暂无 slice 复合字面量）
 *
 * mod.x 的 subslice_i32 / chunk_i32 / split_at_i32 等零拷贝视图经 core_subslice_*_c
 * 构造切片；本 TU 提供这 6 个 C 符号，返回值 ABI 与 codegen 生成的
 * struct shux_slice_<T>_t { T *data; size_t length; } 一致（16 字节，按值返回）。
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
