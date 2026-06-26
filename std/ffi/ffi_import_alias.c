/**
 * ffi_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const ffi = import("std.ffi")` 生成 std_ffi_* 符号；
 * ffi.o 仅导出 ffi_*_c（ffi.sx）。本 TU 提供 std_ffi_* 转发（语义对齐 mod.sx）。
 */
#include <stdint.h>

/** 与 mod.sx FfiPoint 布局一致。 */
typedef struct ShuxFfiPoint {
  int32_t x;
  int32_t y;
} ShuxFfiPoint;

extern int32_t ffi_cstr_len_c(uint8_t *ptr);
extern uint8_t *ffi_cstring_new_c(uint8_t *ptr, int32_t len);
extern void ffi_cstring_free_c(uint8_t *ptr);
extern int32_t ffi_cstring_try_new_c(uint8_t *ptr, int32_t len, uintptr_t *out);
extern int32_t ffi_point_pack_c(uint8_t *buf, int32_t cap, int32_t x, int32_t y);
extern int32_t ffi_point_unpack_c(uint8_t *buf, int32_t cap, ShuxFfiPoint *out);
extern uintptr_t ffi_cb_double_i32_fn_c(void);
extern int32_t ffi_invoke_i32_cb_c(uintptr_t cb, int32_t arg);

/** cstr_len；转发 ffi_cstr_len_c。 */
int32_t std_ffi_cstr_len(uint8_t *ptr) { return ffi_cstr_len_c(ptr); }

/** cstring_new；转发 ffi_cstring_new_c。 */
uint8_t *std_ffi_cstring_new(uint8_t *ptr, int32_t len) { return ffi_cstring_new_c(ptr, len); }

/** cstring_free；转发 ffi_cstring_free_c。 */
void std_ffi_cstring_free(uint8_t *ptr) { ffi_cstring_free_c(ptr); }

/** cstring_destroy 别名；转发 ffi_cstring_free_c。 */
void std_ffi_cstring_destroy(uint8_t *ptr) { ffi_cstring_free_c(ptr); }

/** cstring_try_new；转发 ffi_cstring_try_new_c。 */
int32_t std_ffi_cstring_try_new(uint8_t *ptr, int32_t len, uintptr_t *out) {
  return ffi_cstring_try_new_c(ptr, len, out);
}

/** point_pack；转发 ffi_point_pack_c。 */
int32_t std_ffi_point_pack(uint8_t *buf, int32_t cap, int32_t x, int32_t y) {
  return ffi_point_pack_c(buf, cap, x, y);
}

/** point_unpack；转发 ffi_point_unpack_c。 */
int32_t std_ffi_point_unpack(uint8_t *buf, int32_t cap, ShuxFfiPoint *out) {
  return ffi_point_unpack_c(buf, cap, out);
}

/** cb_double_i32_fn；转发 ffi_cb_double_i32_fn_c。 */
uintptr_t std_ffi_cb_double_i32_fn(void) { return ffi_cb_double_i32_fn_c(); }

/** invoke_i32_cb；转发 ffi_invoke_i32_cb_c。 */
int32_t std_ffi_invoke_i32_cb(uintptr_t cb, int32_t arg) { return ffi_invoke_i32_cb_c(cb, arg); }
