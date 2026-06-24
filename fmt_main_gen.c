/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <string.h>
extern int getpid(void);
static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = getenv("SHUX_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/shux-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] bundle=%s\n", _p); } } }
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
struct std_io_driver_Buffer;
__attribute__((weak)) ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {
  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;
}
__attribute__((weak)) ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {
  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;
}
static int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_read_batch_buf((int)handle, bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}
static int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_write_batch_buf((int)handle, bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}
#define std_io_submit_read_batch_buf std_io_driver_submit_read_batch_buf
#define std_io_submit_write_batch_buf std_io_driver_submit_write_batch_buf
#define std_io_driver_driver_read_ptr_len shux_io_read_ptr_len
#define std_io_driver_driver_read_ptr shux_io_read_ptr
extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
__attribute__((weak)) int32_t std_io_print_str(uint8_t *ptr, size_t len) {
  if (!ptr || len == 0) return 0;
  return (fwrite(ptr, 1, len, stdout) == len) ? (int32_t)len : -1;
}
static const int32_t core_fmt_FMT_F64_DEFAULT_PREC = 6;
int32_t core_fmt_fmt_i32(int32_t x);
int32_t core_fmt_fmt_i32_to_buf(uint8_t * buf, int32_t cap, int32_t x);
int32_t core_fmt_fmt_u32_to_buf(uint8_t * buf, int32_t cap, uint32_t u);
int32_t core_fmt_fmt_u64_to_buf(uint8_t * buf, int32_t cap, uint64_t u);
int32_t core_fmt_fmt_i64_to_buf(uint8_t * buf, int32_t cap, int64_t x);
int32_t core_fmt_fmt_bool_to_buf(uint8_t * buf, int32_t cap, int b);
int32_t core_fmt_fmt_u32_hex_to_buf(uint8_t * buf, int32_t cap, uint32_t u);
int32_t core_fmt_fmt_u64_hex_to_buf(uint8_t * buf, int32_t cap, uint64_t u);
int32_t core_fmt_fmt_append_i32_to_buf(uint8_t * buf, int32_t cap, int32_t off, int32_t x);
int32_t core_fmt_fmt_append_i64_to_buf(uint8_t * buf, int32_t cap, int32_t off, int64_t x);
int core_fmt_fmt_f64_is_nan(double x);
int core_fmt_fmt_f64_is_inf(double x);
int32_t core_fmt_fmt_f64_write_special(uint8_t * buf, int32_t cap, double x);
int32_t core_fmt_fmt_f64_to_buf_prec(uint8_t * buf, int32_t cap, double x, int32_t prec);
int32_t core_fmt_fmt_f64_to_buf(uint8_t * buf, int32_t cap, double x);
int32_t core_fmt_fmt_usize_to_buf(uint8_t * buf, int32_t cap, size_t x);
int32_t core_fmt_fmt_isize_to_buf(uint8_t * buf, int32_t cap, ptrdiff_t x);
int32_t core_fmt_fmt_ptr_to_buf(uint8_t * buf, int32_t cap, uint8_t * p);
int32_t core_fmt_fmt_i32(int32_t x) {
  return x;
}
int32_t core_fmt_fmt_i32_to_buf(uint8_t * buf, int32_t cap, int32_t x) {
  uint8_t digits[10] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
  if (cap < 1) {
    return (-1);
  }
  int32_t u = 0 - x;
  if (x < 0 && u < 0) {
    if (cap < 11) {
    return (-1);
    }
    uint8_t s[11] = { 45, 50, 49, 52, 55, 52, 56, 51, 54, 52, 56 };
    int32_t k = 0;
    while (k < 11) {
      ((buf)[k] = ((s)[k]));
      ++k;
    }
    return 11;
  }
  int32_t off = 0;
  int32_t max = cap;
  int32_t val = x;
  if (val < 0) {
    ((buf)[0] = (45));
    (off = (1));
    (max = (cap - 1));
    (val = (u));
  }
  if (max < 1) {
    return (-1);
  }
  uint8_t tmp[10] = { 0 };
  int32_t num_digits = 0;
  int32_t v = val;
  while (v > 0 && num_digits < 10) {
    ((num_digits < 0 || (num_digits) >= 10 ? (shux_panic_(1, 0), 0) : ((tmp)[num_digits] = ((10 == 0 ? (shux_panic_(1, 0), v) : (v % 10)) < 0 || ((10 == 0 ? (shux_panic_(1, 0), v) : (v % 10))) >= 10 ? (shux_panic_(1, 0), (digits)[0]) : (digits)[(10 == 0 ? (shux_panic_(1, 0), v) : (v % 10))]), 0)));
    ++num_digits;
    (v = ((10 == 0 ? (shux_panic_(1, 0), v) : (v / 10))));
  }
  if (num_digits == 0) {
    ((buf)[off] = ((digits)[0]));
    return off + 1;
  }
  if (num_digits > max) {
    return (-1);
  }
  int32_t idx = 0;
  while (idx < num_digits) {
    ((buf)[off + idx] = (((num_digits - 1) - idx < 0 || ((num_digits - 1) - idx) >= 10 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[(num_digits - 1) - idx])));
    ++idx;
  }
  return off + num_digits;
}
int32_t core_fmt_fmt_u32_to_buf(uint8_t * buf, int32_t cap, uint32_t u) {
  uint8_t digits[10] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
  if (cap < 1) {
    return (-1);
  }
  uint8_t tmp[10] = { 0 };
  int32_t num_digits = 0;
  uint32_t v = u;
  while (v > 0 && num_digits < 10) {
    ((num_digits < 0 || (num_digits) >= 10 ? (shux_panic_(1, 0), 0) : ((tmp)[num_digits] = (v % 10 < 0 || (v % 10) >= 10 ? (shux_panic_(1, 0), (digits)[0]) : (digits)[v % 10]), 0)));
    ++num_digits;
    (v = ((10 == 0 ? (shux_panic_(1, 0), v) : (v / 10))));
  }
  if (num_digits == 0) {
    ((buf)[0] = ((digits)[0]));
    return 1;
  }
  if (num_digits > cap) {
    return (-1);
  }
  int32_t idx = 0;
  while (idx < num_digits) {
    ((buf)[idx] = (((num_digits - 1) - idx < 0 || ((num_digits - 1) - idx) >= 10 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[(num_digits - 1) - idx])));
    ++idx;
  }
  return num_digits;
}
int32_t core_fmt_fmt_u64_to_buf(uint8_t * buf, int32_t cap, uint64_t u) {
  uint8_t digits[10] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
  if (cap < 1) {
    return (-1);
  }
  uint8_t tmp[20] = { 0 };
  int32_t num_digits = 0;
  uint64_t v = u;
  while (v > 0 && num_digits < 20) {
    ((num_digits < 0 || (num_digits) >= 20 ? (shux_panic_(1, 0), 0) : ((tmp)[num_digits] = (v % 10 < 0 || (v % 10) >= 10 ? (shux_panic_(1, 0), (digits)[0]) : (digits)[v % 10]), 0)));
    ++num_digits;
    (v = ((10 == 0 ? (shux_panic_(1, 0), v) : (v / 10))));
  }
  if (num_digits == 0) {
    ((buf)[0] = ((digits)[0]));
    return 1;
  }
  if (num_digits > cap) {
    return (-1);
  }
  int32_t idx = 0;
  while (idx < num_digits) {
    ((buf)[idx] = (((num_digits - 1) - idx < 0 || ((num_digits - 1) - idx) >= 20 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[(num_digits - 1) - idx])));
    ++idx;
  }
  return num_digits;
}
int32_t core_fmt_fmt_i64_to_buf(uint8_t * buf, int32_t cap, int64_t x) {
  uint8_t digits[10] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
  if (cap < 1) {
    return (-1);
  }
  int64_t i64_min = 0;
  if (x == i64_min) {
    if (cap < 20) {
    return (-1);
    }
    uint8_t s[20] = { 45, 57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56 };
    int32_t k = 0;
    while (k < 20) {
      ((buf)[k] = ((s)[k]));
      ++k;
    }
    return 20;
  }
  int64_t u = 0 - x;
  if (x < 0 && u < 0) {
    if (cap < 20) {
    return (-1);
    }
    uint8_t s[20] = { 45, 57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56 };
    int32_t k = 0;
    while (k < 20) {
      ((buf)[k] = ((s)[k]));
      ++k;
    }
    return 20;
  }
  int32_t off = 0;
  int32_t max = cap;
  int64_t val = x;
  if (val < 0) {
    ((buf)[0] = (45));
    (off = (1));
    (max = (cap - 1));
    (val = (u));
  }
  if (max < 1) {
    return (-1);
  }
  uint8_t tmp[20] = { 0 };
  int32_t num_digits = 0;
  int64_t v = val;
  while (v > 0 && num_digits < 20) {
    ((num_digits < 0 || (num_digits) >= 20 ? (shux_panic_(1, 0), 0) : ((tmp)[num_digits] = ((10 == 0 ? (shux_panic_(1, 0), v) : (v % 10)) < 0 || ((10 == 0 ? (shux_panic_(1, 0), v) : (v % 10))) >= 10 ? (shux_panic_(1, 0), (digits)[0]) : (digits)[(10 == 0 ? (shux_panic_(1, 0), v) : (v % 10))]), 0)));
    ++num_digits;
    (v = ((10 == 0 ? (shux_panic_(1, 0), v) : (v / 10))));
  }
  if (num_digits == 0) {
    ((buf)[off] = ((digits)[0]));
    return off + 1;
  }
  if (num_digits > max) {
    return (-1);
  }
  int32_t idx = 0;
  while (idx < num_digits) {
    ((buf)[off + idx] = (((num_digits - 1) - idx < 0 || ((num_digits - 1) - idx) >= 20 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[(num_digits - 1) - idx])));
    ++idx;
  }
  return off + num_digits;
}
int32_t core_fmt_fmt_bool_to_buf(uint8_t * buf, int32_t cap, int b) {
  return ({ int32_t __tmp = 0; if (b) {   if (cap < 4) {
    return (-1);
  }
  ((buf)[0] = (116));
  ((buf)[1] = (114));
  ((buf)[2] = (117));
  ((buf)[3] = (101));
  return 4;
 } else {   if (cap < 5) {
    return (-1);
  }
  ((buf)[0] = (102));
  ((buf)[1] = (97));
  ((buf)[2] = (108));
  ((buf)[3] = (115));
  ((buf)[4] = (101));
  return 5;
 } ; __tmp; });
}
int32_t core_fmt_fmt_u32_hex_to_buf(uint8_t * buf, int32_t cap, uint32_t u) {
  uint8_t hex[16] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102 };
  if (cap < 1) {
    return (-1);
  }
  if (u == 0) {
    ((buf)[0] = (48));
    return 1;
  }
  uint8_t tmp[8] = { 0 };
  int32_t num_digits = 0;
  uint32_t v = u;
  while (v > 0 && num_digits < 8) {
    ((num_digits < 0 || (num_digits) >= 8 ? (shux_panic_(1, 0), 0) : ((tmp)[num_digits] = (v % 16 < 0 || (v % 16) >= 16 ? (shux_panic_(1, 0), (hex)[0]) : (hex)[v % 16]), 0)));
    ++num_digits;
    (v = ((16 == 0 ? (shux_panic_(1, 0), v) : (v / 16))));
  }
  if (num_digits > cap) {
    return (-1);
  }
  int32_t idx = 0;
  while (idx < num_digits) {
    ((buf)[idx] = (((num_digits - 1) - idx < 0 || ((num_digits - 1) - idx) >= 8 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[(num_digits - 1) - idx])));
    ++idx;
  }
  return num_digits;
}
int32_t core_fmt_fmt_u64_hex_to_buf(uint8_t * buf, int32_t cap, uint64_t u) {
  uint8_t hex[16] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102 };
  if (cap < 1) {
    return (-1);
  }
  if (u == 0) {
    ((buf)[0] = (48));
    return 1;
  }
  uint8_t tmp[16] = { 0 };
  int32_t num_digits = 0;
  uint64_t v = u;
  while (v > 0 && num_digits < 16) {
    ((num_digits < 0 || (num_digits) >= 16 ? (shux_panic_(1, 0), 0) : ((tmp)[num_digits] = (v % 16 < 0 || (v % 16) >= 16 ? (shux_panic_(1, 0), (hex)[0]) : (hex)[v % 16]), 0)));
    ++num_digits;
    (v = ((16 == 0 ? (shux_panic_(1, 0), v) : (v / 16))));
  }
  if (num_digits > cap) {
    return (-1);
  }
  int32_t idx = 0;
  while (idx < num_digits) {
    ((buf)[idx] = (((num_digits - 1) - idx < 0 || ((num_digits - 1) - idx) >= 16 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[(num_digits - 1) - idx])));
    ++idx;
  }
  return num_digits;
}
int32_t core_fmt_fmt_append_i32_to_buf(uint8_t * buf, int32_t cap, int32_t off, int32_t x) {
  if (off < 0 || off >= cap) {
    return (-1);
  }
  uint8_t tmp[24] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  int32_t n = core_fmt_fmt_i32_to_buf(tmp, 24, x);
  if (n < 0 || off + n > cap) {
    return (-1);
  }
  int32_t i = 0;
  while (i < n) {
    ((buf)[off + i] = ((i < 0 || (i) >= 24 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[i])));
    ++i;
  }
  return off + n;
}
int32_t core_fmt_fmt_append_i64_to_buf(uint8_t * buf, int32_t cap, int32_t off, int64_t x) {
  if (off < 0 || off >= cap) {
    return (-1);
  }
  uint8_t tmp[24] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  int32_t n = core_fmt_fmt_i64_to_buf(tmp, 24, x);
  if (n < 0 || off + n > cap) {
    return (-1);
  }
  int32_t i = 0;
  while (i < n) {
    ((buf)[off + i] = ((i < 0 || (i) >= 24 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[i])));
    ++i;
  }
  return off + n;
}
int core_fmt_fmt_f64_is_nan(double x) {
  return x != x;
}
int core_fmt_fmt_f64_is_inf(double x) {
  if (core_fmt_fmt_f64_is_nan(x)) {
    return 0;
  }
  if (x == 0.0) {
    return 0;
  }
  return x + x == x;
}
int32_t core_fmt_fmt_f64_write_special(uint8_t * buf, int32_t cap, double x) {
  if (core_fmt_fmt_f64_is_nan(x)) {
    if (cap < 3) {
    return (-1);
    }
    ((buf)[0] = (78));
    ((buf)[1] = (97));
    ((buf)[2] = (110));
    return 3;
  }
  if (core_fmt_fmt_f64_is_inf(x)) {
    if (x < 0.0) {
    if (cap < 4) {
    return (-1);
    }
    ((buf)[0] = (45));
    ((buf)[1] = (73));
    ((buf)[2] = (110));
    ((buf)[3] = (102));
    return 4;
    }
    if (cap < 3) {
    return (-1);
    }
    ((buf)[0] = (73));
    ((buf)[1] = (110));
    ((buf)[2] = (102));
    return 3;
  }
  return (-1);
}
int32_t core_fmt_fmt_f64_to_buf_prec(uint8_t * buf, int32_t cap, double x, int32_t prec) {
  uint8_t digits[10] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
  if (cap < 1) {
    return (-1);
  }
  if (prec < 0 || prec > 9) {
    return (-1);
  }
  int32_t special = core_fmt_fmt_f64_write_special(buf, cap, x);
  if (special >= 0) {
    return special;
  }
  double abs_x = x;
  if (x < 0.0) {
    (abs_x = (0.0 - x));
  }
  int64_t whole = ((int64_t)(abs_x));
  double frac = abs_x - ((double)(whole));
  int32_t off = 0;
  if (x < 0.0) {
    if (cap < 1) {
    return (-1);
    }
    ((buf)[0] = (45));
    (off = (1));
  }
  uint8_t tmp[24] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  int32_t n_whole = core_fmt_fmt_i64_to_buf(tmp, 24, whole);
  if (n_whole < 0 || off + n_whole > cap) {
    return (-1);
  }
  int32_t i = 0;
  while (i < n_whole) {
    ((buf)[off + i] = ((i < 0 || (i) >= 24 ? (shux_panic_(1, 0), (tmp)[0]) : (tmp)[i])));
    ++i;
  }
  (off = (off + n_whole));
  if (prec == 0) {
    return off;
  }
  if ((off + 1) + prec > cap) {
    return (-1);
  }
  ((buf)[off] = (46));
  ++off;
  int32_t k = 0;
  while (k < prec) {
    (frac = (frac * 10));
    int64_t d = ((int64_t)(frac));
    ((buf)[off + k] = ((((int32_t)(d)) < 0 || (((int32_t)(d))) >= 10 ? (shux_panic_(1, 0), (digits)[0]) : (digits)[((int32_t)(d))])));
    (frac = (frac - ((double)(d))));
    ++k;
  }
  return off + prec;
}
int32_t core_fmt_fmt_f64_to_buf(uint8_t * buf, int32_t cap, double x) {
  return core_fmt_fmt_f64_to_buf_prec(buf, cap, x, core_fmt_FMT_F64_DEFAULT_PREC);
}
int32_t core_fmt_fmt_usize_to_buf(uint8_t * buf, int32_t cap, size_t x) {
  return core_fmt_fmt_u32_to_buf(buf, cap, ((uint32_t)(x)));
}
int32_t core_fmt_fmt_isize_to_buf(uint8_t * buf, int32_t cap, ptrdiff_t x) {
  return core_fmt_fmt_i64_to_buf(buf, cap, ((int64_t)(x)));
}
int32_t core_fmt_fmt_ptr_to_buf(uint8_t * buf, int32_t cap, uint8_t * p) {
  if (cap < 2) {
    return (-1);
  }
  ((buf)[0] = (48));
  ((buf)[1] = (120));
  int32_t n = core_fmt_fmt_u64_hex_to_buf((&((buf)[2])), cap - 2, ((uint64_t)(p)));
  if (n < 0) {
    return (-1);
  }
  return 2 + n;
}
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#if defined(__SSE2__) && (defined(__x86_64__) || defined(__i386__))
#include <emmintrin.h>
static inline float shux_autovec_sum_f32(const float *a, int32_t n) {
  __m128 acc = _mm_setzero_ps();
  int32_t i = 0;
  while (i + 4 <= n) {
    acc = _mm_add_ps(acc, _mm_loadu_ps(a + i));
    i += 4;
  }
  { float tmp[4]; _mm_storeu_ps(tmp, acc); float s = tmp[0]+tmp[1]+tmp[2]+tmp[3];
    while (i < n) { s += a[i]; i++; } return s; }
}
static inline float shux_autovec_sum_f32_strided(const float *col0, int32_t step, int32_t n) {
  __m128 acc = _mm_setzero_ps();
  int32_t i = 0;
  while (i + 4 <= n) {
    acc = _mm_add_ps(acc, _mm_setr_ps(col0[i*step], col0[(i+1)*step], col0[(i+2)*step], col0[(i+3)*step]));
    i += 4;
  }
  { float tmp[4]; _mm_storeu_ps(tmp, acc); float s = tmp[0]+tmp[1]+tmp[2]+tmp[3];
    while (i < n) { s += col0[i*step]; i++; } return s; }
}
static inline float shux_autovec_dot_f32(const float *a, const float *b, int32_t n) {
  __m128 acc = _mm_setzero_ps();
  int32_t i = 0;
  while (i + 4 <= n) {
    __m128 va = _mm_loadu_ps(a + i);
    __m128 vb = _mm_loadu_ps(b + i);
    acc = _mm_add_ps(acc, _mm_mul_ps(va, vb));
    i += 4;
  }
  { float tmp[4]; _mm_storeu_ps(tmp, acc); float s = tmp[0]+tmp[1]+tmp[2]+tmp[3];
    while (i < n) { s += a[i]*b[i]; i++; } return s; }
}
#elif defined(__ARM_NEON) && defined(__aarch64__)
#include <arm_neon.h>
static inline float shux_autovec_sum_f32(const float *a, int32_t n) {
  float32x4_t acc = vdupq_n_f32(0.0f);
  int32_t i = 0;
  while (i + 4 <= n) {
    acc = vaddq_f32(acc, vld1q_f32(a + i));
    i += 4;
  }
  { float tmp[4]; vst1q_f32(tmp, acc); float s = tmp[0]+tmp[1]+tmp[2]+tmp[3];
    while (i < n) { s += a[i]; i++; } return s; }
}
static inline float shux_autovec_sum_f32_strided(const float *col0, int32_t step, int32_t n) {
  float32x4_t acc = vdupq_n_f32(0.0f);
  int32_t i = 0;
  while (i + 4 <= n) {
    float32x4_t v = vsetq_lane_f32(col0[i*step], vdupq_n_f32(0.0f), 0);
    v = vsetq_lane_f32(col0[(i+1)*step], v, 1);
    v = vsetq_lane_f32(col0[(i+2)*step], v, 2);
    v = vsetq_lane_f32(col0[(i+3)*step], v, 3);
    acc = vaddq_f32(acc, v);
    i += 4;
  }
  { float tmp[4]; vst1q_f32(tmp, acc); float s = tmp[0]+tmp[1]+tmp[2]+tmp[3];
    while (i < n) { s += col0[i*step]; i++; } return s; }
}
static inline float shux_autovec_dot_f32(const float *a, const float *b, int32_t n) {
  float32x4_t acc = vdupq_n_f32(0.0f);
  int32_t i = 0;
  while (i + 4 <= n) {
    float32x4_t va = vld1q_f32(a + i);
    float32x4_t vb = vld1q_f32(b + i);
    acc = vmlaq_f32(acc, va, vb);
    i += 4;
  }
  { float tmp[4]; vst1q_f32(tmp, acc); float s = tmp[0]+tmp[1]+tmp[2]+tmp[3];
    while (i < n) { s += a[i]*b[i]; i++; } return s; }
}
#else
static inline float shux_autovec_sum_f32(const float *a, int32_t n) {
  float s = 0.0f; int32_t i = 0;
  for (; i < n; i++) s += a[i]; return s;
}
static inline float shux_autovec_sum_f32_strided(const float *col0, int32_t step, int32_t n) {
  float s = 0.0f; int32_t i = 0;
  for (; i < n; i++) s += col0[i*step]; return s;
}
static inline float shux_autovec_dot_f32(const float *a, const float *b, int32_t n) {
  float s = 0.0f; int32_t i = 0;
  for (; i < n; i++) s += a[i]*b[i]; return s;
}
#endif
__attribute__((weak)) int shux_process_argc = 0;
__attribute__((weak)) char **shux_process_argv = NULL;
int main(int argc, char **argv) {
  shux_process_argc = argc;
  shux_process_argv = argv;
  int32_t n = core_fmt_fmt_i32(42);
  uint8_t buf[24] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  int32_t len = core_fmt_fmt_i32_to_buf(buf, 24, 42);
  if (len != 2) {
    return 1;
  }
  int32_t neg = -7;
  int32_t len2 = core_fmt_fmt_i32_to_buf(buf, 24, neg);
  if (len2 != 2) {
    return 3;
  }
  int32_t too_small = core_fmt_fmt_i32_to_buf(buf, 1, 123);
  if (too_small != (-1)) {
    return 5;
  }
  uint32_t u = 99;
  int32_t len3 = core_fmt_fmt_u32_to_buf(buf, 24, u);
  if (len3 != 2) {
    return 6;
  }
  uint64_t u64_val = 12345;
  int32_t len4 = core_fmt_fmt_u64_to_buf(buf, 24, u64_val);
  if (len4 != 5) {
    return 7;
  }
  int64_t i64_val = 6789;
  int32_t len5 = core_fmt_fmt_i64_to_buf(buf, 24, i64_val);
  if (len5 != 4) {
    return 8;
  }
  int32_t len6 = core_fmt_fmt_bool_to_buf(buf, 24, 1);
  if (len6 != 4) {
    return 9;
  }
  int32_t len7 = core_fmt_fmt_bool_to_buf(buf, 24, 0);
  if (len7 != 5) {
    return 10;
  }
  int32_t len8 = core_fmt_fmt_u32_hex_to_buf(buf, 24, 255);
  if (len8 != 2) {
    return 11;
  }
  uint64_t hex_val = 256;
  int32_t len9 = core_fmt_fmt_u64_hex_to_buf(buf, 24, hex_val);
  if (len9 != 3) {
    return 12;
  }
  int32_t off = core_fmt_fmt_append_i32_to_buf(buf, 24, 0, 100);
  if (off != 3) {
    return 13;
  }
  int32_t off2 = core_fmt_fmt_append_i32_to_buf(buf, 24, off, 200);
  if (off2 != 6) {
    return 14;
  }
  double x = 1.5;
  int32_t len_f64 = core_fmt_fmt_f64_to_buf(buf, 24, x);
  if (len_f64 != 8) {
    return 15;
  }
  double zero = 0.0;
  int32_t len_zero = core_fmt_fmt_f64_to_buf(buf, 24, zero);
  if (len_zero != 8) {
    return 16;
  }
  int32_t off_i64 = core_fmt_fmt_append_i64_to_buf(buf, 24, 0, 12345);
  if (off_i64 != 5) {
    return 17;
  }
  int32_t len_usize = core_fmt_fmt_usize_to_buf(buf, 24, ((size_t)(100)));
  if (len_usize != 3) {
    return 18;
  }
  int32_t len_isize = core_fmt_fmt_isize_to_buf(buf, 24, ((ptrdiff_t)(0 - 3)));
  if (len_isize != 2) {
    return 19;
  }
  uint8_t * null_p = ((uint8_t *)(0));
  int32_t len_ptr = core_fmt_fmt_ptr_to_buf(buf, 24, null_p);
  if (len_ptr != 3) {
    return 20;
  }
  return n;
}
