/**
 * core/slice/slice.c — 切片视图构造（CORE-004/157）
 *
 * 【文件职责】
 * 从 (data, length) 或 subslice 参数构造 shulang_slice_* 返回值，供 core/slice/mod.su 零拷贝 API 使用。
 * 语言层暂无 slice 复合字面量，subslice 热路径经 C 薄封装。
 */

#include <stddef.h>
#include <stdint.h>

/** []i32 切片 ABI：{ data, length }。 */
typedef struct {
  int32_t *data;
  size_t length;
} shulang_slice_int32_t;

/** []u8 切片 ABI。 */
typedef struct {
  uint8_t *data;
  size_t length;
} shulang_slice_uint8_t;

/** []u64 切片 ABI。 */
typedef struct {
  uint64_t *data;
  size_t length;
} shulang_slice_uint64_t;

/** 通用 subslice 钳制：start 越界返回空视图；len 超出剩余则截断。 */
static size_t subslice_clamp(size_t total_len, size_t start, size_t len, size_t *out_start) {
  if (out_start)
    *out_start = start;
  if (start >= total_len)
    return 0;
  {
    size_t avail = total_len - start;
    return len > avail ? avail : len;
  }
}

/** 从 ptr+length 构造 []i32 视图。 */
shulang_slice_int32_t core_slice_i32_from_ptr_c(int32_t *data, size_t length) {
  shulang_slice_int32_t s;
  s.data = data;
  s.length = length;
  return s;
}

/** 零拷贝 subslice（[]i32）。 */
shulang_slice_int32_t core_subslice_i32_c(int32_t *data, size_t total_len, size_t start, size_t len) {
  shulang_slice_int32_t s;
  size_t n = subslice_clamp(total_len, start, len, NULL);
  if (start >= total_len) {
    s.data = data;
    s.length = 0;
    return s;
  }
  s.data = data + start;
  s.length = n;
  return s;
}

/** 从 ptr+length 构造 []u8 视图。 */
shulang_slice_uint8_t core_slice_u8_from_ptr_c(uint8_t *data, size_t length) {
  shulang_slice_uint8_t s;
  s.data = data;
  s.length = length;
  return s;
}

/** 零拷贝 subslice（[]u8）。 */
shulang_slice_uint8_t core_subslice_u8_c(uint8_t *data, size_t total_len, size_t start, size_t len) {
  shulang_slice_uint8_t s;
  size_t n = subslice_clamp(total_len, start, len, NULL);
  if (start >= total_len) {
    s.data = data;
    s.length = 0;
    return s;
  }
  s.data = data + start;
  s.length = n;
  return s;
}

/** 从 ptr+length 构造 []u64 视图。 */
shulang_slice_uint64_t core_slice_u64_from_ptr_c(uint64_t *data, size_t length) {
  shulang_slice_uint64_t s;
  s.data = data;
  s.length = length;
  return s;
}

/** 零拷贝 subslice（[]u64）。 */
shulang_slice_uint64_t core_subslice_u64_c(uint64_t *data, size_t total_len, size_t start, size_t len) {
  shulang_slice_uint64_t s;
  size_t n = subslice_clamp(total_len, start, len, NULL);
  if (start >= total_len) {
    s.data = data;
    s.length = 0;
    return s;
  }
  s.data = data + start;
  s.length = n;
  return s;
}
