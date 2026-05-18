/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static inline void shulang_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shulang_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern int32_t shu_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shu_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shu_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shu_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shu_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
struct shulang_slice_uint8_t { uint8_t *data; size_t length; };
struct typeck_ParseDirectiveResult { int32_t kind; int32_t sym_len; };
void typeck_parse_directive_into(struct typeck_ParseDirectiveResult * out, uint8_t line_buf[512], int32_t line_len, uint8_t sym[64]);
int32_t typeck_preprocess_su(struct shulang_slice_uint8_t * source, struct shulang_slice_uint8_t * out_buf);
int32_t typeck_preprocess_su_buf(uint8_t source_buf[262144], ptrdiff_t source_len, uint8_t out_buf[262144], int32_t out_cap);
void typeck_parse_directive_into(struct typeck_ParseDirectiveResult * out, uint8_t line_buf[512], int32_t line_len, uint8_t sym[64]) {
  int32_t pos = 0;
  (void)(((out)->kind = 0));
  (void)(((out)->sym_len = 0));
  while (pos < line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9) {
    (void)((pos = pos + 1));
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 35) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((pos = pos + 1));
  while (pos < line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9) {
    (void)((pos = pos + 1));
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 2 <= line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 105 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 102) {   (void)((pos = pos + 2));
  (void)(({ int32_t __tmp = 0; if (pos < line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 32 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 9 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 10 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 13 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  while (pos < line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9) {
    (void)((pos = pos + 1));
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t s = 0;
  while (pos < line_len && s < 63) {
    uint8_t ch = (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch >= 48 && ch <= 57 || ch >= 65 && ch <= 90 || ch >= 97 && ch <= 122 || ch == 95) {   (void)(((s < 0 || (s) >= 64 ? (shulang_panic_(1, 0), 0) : ((sym)[s] = ch, 0))));
  (void)((s = s + 1));
  (void)((pos = pos + 1));
 } else {   break;
 } ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (s == 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->kind = 1));
  (void)(((out)->sym_len = s));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 6 <= line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 108 && (pos + 2 < 0 || (pos + 2) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 115 && (pos + 3 < 0 || (pos + 3) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 101 && (pos + 4 < 0 || (pos + 4) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 4]) == 105 && (pos + 5 < 0 || (pos + 5) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 5]) == 102) {   (void)((pos = pos + 6));
  (void)(({ int32_t __tmp = 0; if (pos < line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 32 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 9 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 10 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 13 && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  while (pos < line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9) {
    (void)((pos = pos + 1));
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t s = 0;
  while (pos < line_len && s < 63) {
    uint8_t ch = (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch >= 48 && ch <= 57 || ch >= 65 && ch <= 90 || ch >= 97 && ch <= 122 || ch == 95) {   (void)(((s < 0 || (s) >= 64 ? (shulang_panic_(1, 0), 0) : ((sym)[s] = ch, 0))));
  (void)((s = s + 1));
  (void)((pos = pos + 1));
 } else {   break;
 } ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (s == 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->kind = 4));
  (void)(((out)->sym_len = s));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 4 <= line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 108 && (pos + 2 < 0 || (pos + 2) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 115 && (pos + 3 < 0 || (pos + 3) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 101) {   (void)((pos = pos + 4));
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 10 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 13 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 0) {   (void)(((out)->kind = 2));
  (void)(((out)->sym_len = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 5 <= line_len && (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 110 && (pos + 2 < 0 || (pos + 2) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 100 && (pos + 3 < 0 || (pos + 3) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 105 && (pos + 4 < 0 || (pos + 4) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 4]) == 102) {   (void)((pos = pos + 5));
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 10 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 13 || (pos < 0 || (pos) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 0) {   (void)(((out)->kind = 3));
  (void)(((out)->sym_len = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
}
int32_t typeck_preprocess_su(struct shulang_slice_uint8_t * source, struct shulang_slice_uint8_t * out_buf) {
  (void)(({ int32_t __tmp = 0; if ((out_buf)->length <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t stack[32] = { 0 };
  int32_t depth = 0;
  int32_t out_len = 0;
  int32_t line_len = 0;
  uint8_t line_buf[512] = { 0 };
  int32_t pos = 0;
  while (pos < (source)->length) {
    uint8_t ch = (pos < 0 || (size_t)(pos) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10) {   (void)(({ int32_t __tmp = 0; if (line_len > 0 || 1) {   uint8_t sym[64] = { 0 };
  struct typeck_ParseDirectiveResult res = (struct typeck_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
  (void)(typeck_parse_directive_into((&(res)), line_buf, line_len, sym));
  int32_t kind = (res).kind;
  __tmp = ({ int32_t __tmp = 0; if (kind != 0) {   (void)(({ int32_t __tmp = 0; if (kind == 1) {   (void)(({ int32_t __tmp = 0; if (depth >= 32) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (depth > 0 && (depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 0) {   (void)(((depth < 0 || (depth) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth] = 0, 0))));
  (void)((depth = depth + 1));
 } else {   (void)(((depth < 0 || (depth) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth] = 0, 0))));
  (void)((depth = depth + 1));
 } ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (kind == 2) {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 1) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 0, 0))));
 } else (__tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 0) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 2, 0))));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (kind == 4) {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 2) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 1) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 3, 0))));
 } else (__tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 0) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 0, 0))));
 } else {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 3, 0))));
 } ; __tmp; })) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)((depth = depth - 1));
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (shulang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0))));
  (void)((out_len = out_len + 1));
 } else {   int keeping = depth == 0 || depth > 0 && (depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 1 || (depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 2;
  (void)(({ int32_t __tmp = 0; if (keeping) {   int32_t i = 0;
  while (i < line_len) {
    (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (shulang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = (i < 0 || (i) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[i]), 0))));
    (void)((out_len = out_len + 1));
    (void)((i = i + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (shulang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0))));
  (void)((out_len = out_len + 1));
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)((line_len = 0));
  (void)((pos = pos + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (line_len < 511) {   (void)(((line_len < 0 || (line_len) >= 512 ? (shulang_panic_(1, 0), 0) : ((line_buf)[line_len] = ch, 0))));
  (void)((line_len = line_len + 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((pos = pos + 1));
  }
  (void)(({ int32_t __tmp = 0; if (depth != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return out_len;
}
int32_t typeck_preprocess_su_buf(uint8_t source_buf[262144], ptrdiff_t source_len, uint8_t out_buf[262144], int32_t out_cap) {
  (void)(({ int32_t __tmp = 0; if (out_cap <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t stack[32] = { 0 };
  int32_t depth = 0;
  int32_t out_len = 0;
  int32_t line_len = 0;
  uint8_t line_buf[512] = { 0 };
  int32_t pos = 0;
  while (pos < source_len && pos < 262144) {
    uint8_t ch = (pos < 0 || (pos) >= 262144 ? (shulang_panic_(1, 0), (source_buf)[0]) : (source_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10) {   (void)(({ int32_t __tmp = 0; if (line_len > 0 || 1) {   uint8_t sym[64] = { 0 };
  struct typeck_ParseDirectiveResult res = (struct typeck_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
  (void)(typeck_parse_directive_into((&(res)), line_buf, line_len, sym));
  int32_t kind = (res).kind;
  __tmp = ({ int32_t __tmp = 0; if (kind != 0) {   (void)(({ int32_t __tmp = 0; if (kind == 1) {   (void)(({ int32_t __tmp = 0; if (depth >= 32) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (depth > 0 && (depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 0) {   (void)(((depth < 0 || (depth) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth] = 0, 0))));
  (void)((depth = depth + 1));
 } else {   (void)(((depth < 0 || (depth) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth] = 0, 0))));
  (void)((depth = depth + 1));
 } ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (kind == 2) {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 1) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 0, 0))));
 } else (__tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 0) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 2, 0))));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (kind == 4) {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 2) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 1) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 3, 0))));
 } else (__tmp = ({ int32_t __tmp = 0; if ((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 0) {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 0, 0))));
 } else {   (void)(((depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), 0) : ((stack)[depth - 1] = 3, 0))));
 } ; __tmp; })) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)((depth = depth - 1));
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_len < 0 || (out_len) >= 262144 ? (shulang_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0))));
  (void)((out_len = out_len + 1));
 } else {   int keeping = depth == 0 || depth > 0 && (depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 1 || (depth - 1 < 0 || (depth - 1) >= 32 ? (shulang_panic_(1, 0), (stack)[0]) : (stack)[depth - 1]) == 2;
  (void)(({ int32_t __tmp = 0; if (keeping) {   int32_t i = 0;
  while (i < line_len) {
    (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out_len < 0 || (out_len) >= 262144 ? (shulang_panic_(1, 0), 0) : ((out_buf)[out_len] = (i < 0 || (i) >= 512 ? (shulang_panic_(1, 0), (line_buf)[0]) : (line_buf)[i]), 0))));
    (void)((out_len = out_len + 1));
    (void)((i = i + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_len < 0 || (out_len) >= 262144 ? (shulang_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0))));
  (void)((out_len = out_len + 1));
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)((line_len = 0));
  (void)((pos = pos + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (line_len < 511) {   (void)(((line_len < 0 || (line_len) >= 512 ? (shulang_panic_(1, 0), 0) : ((line_buf)[line_len] = ch, 0))));
  (void)((line_len = line_len + 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((pos = pos + 1));
  }
  (void)(({ int32_t __tmp = 0; if (depth != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return out_len;
}
