/**
 * std/ffi/ffi.c — C 字符串互操作（对标 Zig std.cstr、Rust std::ffi）
 *
 * 【文件职责】
 * cstr_len / cstring_new / cstring_free：CString 生命周期；
 * point_pack / point_unpack：8 字节 POD 有界读写；
 * invoke_i32_cb：usize 回调调用。
 *
 * 【所属模块/组件】
 * 标准库 std.ffi；与 std/ffi/mod.sx 同属一模块。无外部依赖（仅 malloc/free）。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/** 返回 NUL 结尾字符串的字节长度（不含 NUL）；ptr 为 0 返回 -1。 */
int32_t ffi_cstr_len_c(const uint8_t *ptr) {
  if (!ptr) return -1;
  const char *s = (const char *)ptr;
  size_t n = strlen(s);
  return (int32_t)(n <= 0x7fffffff ? n : 0x7fffffff);
}

/** 分配 len+1 字节，复制 ptr[0..len] 并写入 NUL；失败返回 0。调用方用 cstring_free 释放。 */
uint8_t *ffi_cstring_new_c(const uint8_t *ptr, int32_t len) {
  if (len < 0) return NULL;
  size_t n = (size_t)len + 1;
  uint8_t *p = (uint8_t *)malloc(n);
  if (!p) return NULL;
  if (ptr && len > 0)
    memcpy(p, ptr, (size_t)len);
  p[len] = 0;
  return p;
}

/** 释放由 cstring_new 返回的指针；ptr 可为 0。 */
void ffi_cstring_free_c(uint8_t *ptr) {
  if (ptr) free(ptr);
}

/** FfiPoint POD（与 mod.sx 布局一致：x + y，各 i32）。 */
typedef struct {
  int32_t x;
  int32_t y;
} ffi_point_t;

/** 将 x/y 以小端写入 buf[0..7]；cap<8 返回 FFI_ERR_TOO_SMALL。 */
int32_t ffi_point_pack_c(uint8_t *buf, int32_t cap, int32_t x, int32_t y) {
  if (!buf) return -1;
  if (cap < 8) return -4;
  buf[0] = (uint8_t)(x & 0xff);
  buf[1] = (uint8_t)((x >> 8) & 0xff);
  buf[2] = (uint8_t)((x >> 16) & 0xff);
  buf[3] = (uint8_t)((x >> 24) & 0xff);
  buf[4] = (uint8_t)(y & 0xff);
  buf[5] = (uint8_t)((y >> 8) & 0xff);
  buf[6] = (uint8_t)((y >> 16) & 0xff);
  buf[7] = (uint8_t)((y >> 24) & 0xff);
  return 0;
}

/** 从 buf[0..7] 读出 FfiPoint；cap<8 返回 FFI_ERR_TOO_SMALL。 */
int32_t ffi_point_unpack_c(const uint8_t *buf, int32_t cap, ffi_point_t *out) {
  if (!buf || !out) return -1;
  if (cap < 8) return -4;
  out->x = (int32_t)((uint32_t)buf[0] | ((uint32_t)buf[1] << 8) |
                     ((uint32_t)buf[2] << 16) | ((uint32_t)buf[3] << 24));
  out->y = (int32_t)((uint32_t)buf[4] | ((uint32_t)buf[5] << 8) |
                     ((uint32_t)buf[6] << 16) | ((uint32_t)buf[7] << 24));
  return 0;
}

/** 内置烟测回调：返回 arg*2。 */
static int32_t ffi_cb_double_i32(int32_t arg) {
  return arg * 2;
}

/** 返回内置 double 回调函数地址（usize）。 */
uintptr_t ffi_cb_double_i32_fn_c(void) {
  return (uintptr_t)(void *)ffi_cb_double_i32;
}

/** 调用 usize 承载的 i32→i32 回调；cb=0 返回 FFI_ERR_NULL。 */
int32_t ffi_invoke_i32_cb_c(void *cb, int32_t arg) {
  if (!cb) return -1;
  return ((int32_t (*)(int32_t))cb)(arg);
}

/** STD-151 C 烟测：pack/unpack + 回调边界。 */
int32_t ffi_struct_callback_smoke_c(void) {
  uint8_t buf[8];
  ffi_point_t pt;
  if (ffi_point_pack_c(buf, 8, 3, 4) != 0) return 1;
  if (ffi_point_unpack_c(buf, 8, &pt) != 0) return 2;
  if (pt.x != 3 || pt.y != 4) return 3;
  if (ffi_point_pack_c(buf, 4, 0, 0) != -4) return 4;
  if (ffi_invoke_i32_cb_c(NULL, 1) != -1) return 5;
  if (ffi_invoke_i32_cb_c((void *)ffi_cb_double_i32, 5) != 10) return 6;
  return 0;
}
