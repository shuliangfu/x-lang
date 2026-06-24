/* generated seed from lsp_gen_full.c (G-06 cold start) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern ptrdiff_t io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ptrdiff_t io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern uint8_t * std_heap_alloc(size_t size);
extern void std_heap_free(uint8_t * ptr);
#define std_io_read io_read
#define std_io_write io_write
/* C-04 -E-extern TU aliases */
static int32_t typeck_LSP_BODY_SAFETY_CAP = 67108864;
static int32_t typeck_LSP_STATE_LEFTOVER_OFF = 0;
static int32_t typeck_LSP_STATE_LEFTOVER_MAX = 8192 * 2;
static int32_t typeck_LSP_STATE_LEN_OFF = 8192 * 2;
extern void lsp_diag_invalidate_cache();
extern void lsp_debug_u32(uint32_t n);
extern void lsp_debug_ptr(uint8_t * p);
ptrdiff_t typeck_read_message(int32_t fd, uint8_t * body_out, int32_t body_cap, uint8_t * state_buf);
int32_t typeck_parse_content_length_in_buf(uint8_t * state_buf, int32_t off, int32_t header_end);
ptrdiff_t typeck_write_fd(int32_t fd, uint8_t * ptr, size_t count);
int32_t typeck_extract_document_text(uint8_t * body, int32_t body_len, uint8_t * out_buf, int32_t out_cap);
uint8_t * typeck_lsp_alloc(size_t size);
void typeck_lsp_free(uint8_t * ptr);
int32_t typeck_lsp_is_null(uint8_t * ptr);
ptrdiff_t typeck_read_message(int32_t fd, uint8_t * body_out, int32_t body_cap, uint8_t * state_buf) {
  size_t h = 0;
  (void)(({ int32_t __tmp = 0; if (fd != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t b0 = (state_buf)[typeck_LSP_STATE_LEN_OFF];
  uint8_t b1 = (state_buf)[typeck_LSP_STATE_LEN_OFF + 1];
  uint8_t b2 = (state_buf)[typeck_LSP_STATE_LEN_OFF + 2];
  uint8_t b3 = (state_buf)[typeck_LSP_STATE_LEN_OFF + 3];
  int32_t n0 = ((int32_t)(b0));
  int32_t n1 = ((int32_t)(b1)) << 8;
  int32_t n2 = ((int32_t)(b2)) << 16;
  int32_t n3 = ((int32_t)(b3)) << 24;
  int32_t n = n0 + n1 + n2 + n3;
  (void)(({ int32_t __tmp = 0; if (n < 0 || n > typeck_LSP_STATE_LEFTOVER_MAX) {   (void)((n = 0));
 } else (__tmp = 0) ; __tmp; }));
  (void)(lsp_debug_ptr(state_buf));
  (void)(({ int32_t __tmp = 0; if (n > 0) {   (void)(lsp_debug_u32(((uint32_t)(n))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (n < typeck_LSP_STATE_LEFTOVER_MAX) {   while (n < typeck_LSP_STATE_LEFTOVER_MAX) {
    int32_t got = std_io_read(h, (&((state_buf)[n])), ((size_t)(typeck_LSP_STATE_LEFTOVER_MAX - n)), ((uint32_t)(0)));
    (void)(({ int32_t __tmp = 0; if (got > 0) {   (void)((n = n + got));
 } else {   break;
 } ; __tmp; }));
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (n <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i + 4 <= n) {
    (void)(({ int32_t __tmp = 0; if ((state_buf)[i] == 13 && (state_buf)[i + 1] == 10 && (state_buf)[i + 2] == 13 && (state_buf)[i + 3] == 10) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)(({ int32_t __tmp = 0; if (i + 4 > n) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t header_end = i + 4;
  int32_t content_len = typeck_parse_content_length_in_buf(state_buf, 0, header_end);
  (void)(({ int32_t __tmp = 0; if (content_len <= 0 || content_len > body_cap || content_len > typeck_LSP_BODY_SAFETY_CAP) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t body_in_buf = n - header_end;
  int32_t to_copy = ({ int32_t __tmp = 0; if (body_in_buf > content_len) {   __tmp = content_len;
 } else {   __tmp = body_in_buf;
 } ; __tmp; });
  int32_t j = 0;
  while (j < to_copy) {
    (void)(((body_out)[j] = (state_buf)[header_end + j]));
    (void)((j = j + 1));
  }
  (void)(({ int32_t __tmp = 0; if (content_len > to_copy) {   int32_t remain = content_len - to_copy;
  int32_t r = std_io_read(h, (&((state_buf)[0])), ((size_t)(remain)), ((uint32_t)(0)));
  (void)(({ int32_t __tmp = 0; if (r != remain) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t j2 = 0;
  while (j2 < remain) {
    (void)(((body_out)[to_copy + j2] = (state_buf)[j2]));
    (void)((j2 = j2 + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
  int32_t consumed = header_end + content_len;
  int32_t new_n = n - consumed;
  (void)(({ int32_t __tmp = 0; if (new_n > 0) {   int32_t k = 0;
  while (k < new_n) {
    (void)(((state_buf)[k] = (state_buf)[consumed + k]));
    (void)((k = k + 1));
  }
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF] = ((uint8_t)(new_n & 255))));
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF + 1] = ((uint8_t)(new_n >> 8 & 255))));
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF + 2] = ((uint8_t)(new_n >> 16 & 255))));
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF + 3] = ((uint8_t)(new_n >> 24 & 255))));
  (void)(lsp_debug_u32(((uint32_t)(new_n))));
 } else {   (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF] = 0));
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF + 1] = 0));
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF + 2] = 0));
  (void)(((state_buf)[typeck_LSP_STATE_LEN_OFF + 3] = 0));
 } ; __tmp; }));
  return ((ptrdiff_t)(content_len));
}
int32_t typeck_parse_content_length_in_buf(uint8_t * state_buf, int32_t off, int32_t header_end) {
  (void)(({ int32_t __tmp = 0; if (header_end < 16) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t key[16] = { 67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58, 32 };
  int32_t ki = 0;
  while (ki < 16) {
    (void)(({ int32_t __tmp = 0; if ((state_buf)[off + ki] != (ki < 0 || (ki) >= 16 ? (shux_panic_(1, 0), (key)[0]) : (key)[ki])) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((ki = ki + 1));
  }
  int32_t val = 0;
  int32_t i = 16;
  while (i < header_end) {
    uint8_t c0 = (state_buf)[off + i];
    (void)(({ int32_t __tmp = 0; if (c0 != 32 && c0 != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  while (i < header_end) {
    uint8_t c = (state_buf)[off + i];
    (void)(({ int32_t __tmp = 0; if (c >= 48 && c <= 57) {   (void)((val = val * 10 + ((int32_t)(c)) - 48));
  (void)((i = i + 1));
 } else {   break;
 } ; __tmp; }));
  }
  return val;
}
ptrdiff_t typeck_write_fd(int32_t fd, uint8_t * ptr, size_t count) {
  size_t h = 1;
  (void)(({ int32_t __tmp = 0; if (fd != 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t r = std_io_write(h, ptr, count, ((uint32_t)(0)));
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((ptrdiff_t)(r));
}
int32_t typeck_extract_document_text(uint8_t * body, int32_t body_len, uint8_t * out_buf, int32_t out_cap) {
  int32_t key_len = 8;
  uint8_t key[8] = { 34, 116, 101, 120, 116, 34, 58, 34 };
  int32_t i = 0;
  while (i + key_len <= body_len) {
    int32_t is_match = 1;
    int32_t k = 0;
    while (k < key_len) {
      (void)(({ int32_t __tmp = 0; if ((body)[i + k] != (k < 0 || (k) >= 8 ? (shux_panic_(1, 0), (key)[0]) : (key)[k])) {   (void)((is_match = 0));
  break;
 } else (__tmp = 0) ; __tmp; }));
      (void)((k = k + 1));
    }
    (void)(({ int32_t __tmp = 0; if (is_match != 0) {   int32_t start = i + key_len;
  int32_t out_len = 0;
  while (start < body_len && out_len < out_cap - 1) {
    uint8_t c = (body)[start];
    (void)(({ int32_t __tmp = 0; if (c == 34) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (c == 92 && start + 1 < body_len) {   (void)((start = start + 1));
  uint8_t next = (body)[start];
  (void)(({ int32_t __tmp = 0; if (next == 110) {   (void)(((out_buf)[out_len] = 10));
  (void)((out_len = out_len + 1));
  (void)((start = start + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (next == 114) {   (void)(((out_buf)[out_len] = 13));
  (void)((out_len = out_len + 1));
  (void)((start = start + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (next == 116) {   (void)(((out_buf)[out_len] = 9));
  (void)((out_len = out_len + 1));
  (void)((start = start + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (next == 34 || next == 92) {   (void)(((out_buf)[out_len] = next));
  (void)((out_len = out_len + 1));
  (void)((start = start + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_buf)[out_len] = next));
  (void)((out_len = out_len + 1));
  (void)((start = start + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out_buf)[out_len] = c));
    (void)((out_len = out_len + 1));
    (void)((start = start + 1));
  }
  (void)(((out_buf)[out_len] = 0));
  return out_len;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return (-1);
}
uint8_t * typeck_lsp_alloc(size_t size) {
  (void)(({ uint8_t * __tmp = 0; if (size == 0 || size > ((size_t)(typeck_LSP_BODY_SAFETY_CAP))) {   return ((uint8_t *)(0));
 } else (__tmp = 0) ; __tmp; }));
  return std_heap_alloc(size);
}
void typeck_lsp_free(uint8_t * ptr) {
  (void)(std_heap_free(ptr));
}
int32_t typeck_lsp_is_null(uint8_t * ptr) {
  (void)(({ int32_t __tmp = 0; if (ptr == ((uint8_t *)(0))) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
