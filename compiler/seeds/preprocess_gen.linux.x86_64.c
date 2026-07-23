/* generated from preprocess */
/* wave265: line_buf 512→4096 (silent truncate at 511 caused P001 on long source lines). */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
struct xlang_slice_uint8_t { uint8_t *data; size_t length; };
struct preprocess_ParseDirectiveResult { int32_t kind; int32_t sym_len; };
/* wave245 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED orch / host getenv residual via single face.
 * Compiler-only gen seed pin (CRASH_EVIDENCE inline) — not user program template
 * (runtime.from_x.c fprintf CRASH_EVIDENCE user C templates use link_abi_getenv since wave254). */
extern char *link_abi_getenv(const char *name);
extern int getpid(void);
static inline void xlang_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = link_abi_getenv("XLANG_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "note: crash evidence: panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = link_abi_getenv("XLANG_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/xlang-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "note: crash evidence: bundle=%s\n", _p); } } }
static inline void xlang_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void xlang_panic_(int has_msg, int msg_val) {
  xlang_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern void preprocess_if_stack_reset();
extern int32_t preprocess_if_stack_len();
extern int32_t preprocess_if_stack_push(int32_t v);
extern void preprocess_if_stack_pop();
extern int32_t preprocess_if_stack_at(int32_t i);
extern void preprocess_if_stack_set_at(int32_t i, int32_t v);
extern int32_t preprocess_eval_condition_c(uint8_t * cond, int32_t cond_len);
int32_t preprocess_apply_directive_kind(int32_t kind, int32_t cond_val);
int preprocess_line_keeping();
int32_t preprocess_parse_copy_cond_from_line(uint8_t cond[256], uint8_t line_buf[4096], int32_t pos, int32_t line_len);
void preprocess_parse_directive_into(struct preprocess_ParseDirectiveResult * out, uint8_t line_buf[4096], int32_t line_len, uint8_t cond[256]);
int32_t preprocess_x(struct xlang_slice_uint8_t * source, struct xlang_slice_uint8_t * out_buf);
int32_t preprocess_x_buf(uint8_t source_buf[4194304], ptrdiff_t source_len, uint8_t out_buf[4194304], int32_t out_cap);
/* 失败码：-2 else without #if；-3 endif without；-4 elseif without；-5 elseif after else；-6 duplicate else；-7 nesting */
int32_t preprocess_apply_directive_kind(int32_t kind, int32_t cond_val) {
  int32_t depth = preprocess_if_stack_len();
  if (kind == 1) {
    int32_t v = cond_val;
    if (depth > 0) {
      int32_t parent = preprocess_if_stack_at(depth - 1);
      if (parent == 0)
        v = 0;
    }
    if (v != 0)
      v = 1;
    if (preprocess_if_stack_push(v) < 0)
      return -7;
    return 0;
  }
  if (kind == 2) {
    int32_t di;
    int32_t top;
    if (depth == 0)
      return -2;
    di = depth - 1;
    top = preprocess_if_stack_at(di);
    if (top == 1)
      preprocess_if_stack_set_at(di, 0);
    else if (top == 0)
      preprocess_if_stack_set_at(di, 2);
    else if (top == 3)
      ;
    else
      return -6;
    return 0;
  }
  if (kind == 4) {
    int32_t di2;
    int32_t top2;
    if (depth == 0)
      return -4;
    di2 = depth - 1;
    top2 = preprocess_if_stack_at(di2);
    if (top2 == 2)
      return -5;
    if (top2 == 1)
      preprocess_if_stack_set_at(di2, 3);
    else if (top2 == 0) {
      if (cond_val != 0)
        preprocess_if_stack_set_at(di2, 1);
      else
        preprocess_if_stack_set_at(di2, 0);
    } else
      preprocess_if_stack_set_at(di2, 3);
    return 0;
  }
  if (depth == 0)
    return -3;
  preprocess_if_stack_pop();
  return 0;
}
int preprocess_line_keeping() {
  int32_t depth = preprocess_if_stack_len();
  (void)(({ int __tmp = 0; if (depth == 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  int32_t top = preprocess_if_stack_at(depth - 1);
  return top == 1 || top == 2;
}
int32_t preprocess_parse_copy_cond_from_line(uint8_t cond[256], uint8_t line_buf[4096], int32_t pos, int32_t line_len) {
  int32_t s = 0;
  while (pos < line_len && s < 255) {
    uint8_t ch = (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10 || ch == 13) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ((s < 0 || (s) >= 256 ? (xlang_panic_(1, 0), 0) : ((cond)[s] = ch, 0)));
    ++s;
    ++pos;
  }
  while (s > 0) {
    uint8_t tail = (s - 1 < 0 || (s - 1) >= 256 ? (xlang_panic_(1, 0), (cond)[0]) : (cond)[s - 1]);
    (void)(({ int32_t __tmp = 0; if (tail != 32 && tail != 9 && tail != 13) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (s = (s - 1));
  }
  return s;
}
void preprocess_parse_directive_into(struct preprocess_ParseDirectiveResult * out, uint8_t line_buf[4096], int32_t line_len, uint8_t cond[256]) {
  int32_t pos = 0;
  ((out)->kind = (0));
  ((out)->sym_len = (0));
  while (pos < line_len) {
    uint8_t ws0 = (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ws0 != 32 && ws0 != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++pos;
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 35) {   return;
 } else (__tmp = 0) ; __tmp; }));
  ++pos;
  while (pos < line_len) {
    uint8_t ws1 = (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ws1 != 32 && ws1 != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++pos;
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 2 <= line_len && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 105 && (pos + 1 < 0 || (pos + 1) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 102) {   pos += 2;
  (void)(({ int32_t __tmp = 0; if (pos < line_len && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 32 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 9 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 10 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 13 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  while (pos < line_len) {
    uint8_t ws_if = (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ws_if != 32 && ws_if != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++pos;
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cl = preprocess_parse_copy_cond_from_line(cond, line_buf, pos, line_len);
  (void)(({ int32_t __tmp = 0; if (cl <= 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  ((out)->kind = (1));
  ((out)->sym_len = (cl));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 6 <= line_len && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 108 && (pos + 2 < 0 || (pos + 2) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 115 && (pos + 3 < 0 || (pos + 3) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 101 && (pos + 4 < 0 || (pos + 4) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 4]) == 105 && (pos + 5 < 0 || (pos + 5) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 5]) == 102) {   pos += 6;
  (void)(({ int32_t __tmp = 0; if (pos < line_len && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 32 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 9 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 10 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 13 && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  while (pos < line_len) {
    uint8_t ws_elseif = (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ws_elseif != 32 && ws_elseif != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++pos;
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cl2 = preprocess_parse_copy_cond_from_line(cond, line_buf, pos, line_len);
  (void)(({ int32_t __tmp = 0; if (cl2 <= 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  ((out)->kind = (4));
  ((out)->sym_len = (cl2));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 4 <= line_len && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 108 && (pos + 2 < 0 || (pos + 2) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 115 && (pos + 3 < 0 || (pos + 3) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 101) {   pos += 4;
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 10 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 13 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 0) {   ((out)->kind = (2));
  ((out)->sym_len = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 5 <= line_len && (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 110 && (pos + 2 < 0 || (pos + 2) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 100 && (pos + 3 < 0 || (pos + 3) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 105 && (pos + 4 < 0 || (pos + 4) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 4]) == 102) {   pos += 5;
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 10 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 13 || (pos < 0 || (pos) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 0) {   ((out)->kind = (3));
  ((out)->sym_len = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
}
int32_t preprocess_x(struct xlang_slice_uint8_t * source, struct xlang_slice_uint8_t * out_buf) {
  (void)(({ int32_t __tmp = 0; if ((out_buf)->length <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(preprocess_if_stack_reset());
  int32_t out_len = 0;
  int32_t line_len = 0;
  uint8_t line_buf[4096] = { 0 };
  int32_t pos = 0;
  while (pos < (source)->length) {
    uint8_t ch = (pos < 0 || (size_t)(pos) >= (source)->length ? (xlang_panic_(1, 0), (source)->data[0]) : (source)->data[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10) {   (void)(({ int32_t __tmp = 0; if (line_len > 0 || 1) {   uint8_t cond[256] = { 0 };
  struct preprocess_ParseDirectiveResult res = (struct preprocess_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
  (void)(preprocess_parse_directive_into((&(res)), line_buf, line_len, cond));
  int32_t kind = (res).kind;
  __tmp = ({ int32_t __tmp = 0; if (kind != 0) {   int32_t cond_val = 0;
  (void)(({ int32_t __tmp = 0; if (kind == 1 || kind == 4) {   (cond_val = (preprocess_eval_condition_c((&((cond)[0])), (res).sym_len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((__tmp = preprocess_apply_directive_kind(kind, cond_val)) != 0) {   return __tmp;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (xlang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0)));
  ++out_len;
 } else {   int keeping = preprocess_line_keeping();
  (void)(({ int32_t __tmp = 0; if (keeping) {   int32_t i = 0;
  while (i < line_len) {
    (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (xlang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = (i < 0 || (i) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[i]), 0)));
    ++out_len;
    ++i;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (xlang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0)));
  ++out_len;
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (line_len = (0));
  ++pos;
 } else {   (void)(({ int32_t __tmp = 0; if (line_len < 4095) {   ((line_len < 0 || (line_len) >= 4096 ? (xlang_panic_(1, 0), 0) : ((line_buf)[line_len] = ch, 0)));
  ++line_len;
 } else (__tmp = 0) ; __tmp; }));
  ++pos;
 } ; __tmp; }));
  }
  /* PLATFORM: SHARED — flush last line when source omits trailing LF (mirror preprocess.x).
   * Without this, final `}` is dropped → parse num_funcs=0 / XP003. */
  if (line_len > 0) {
    uint8_t cond_eof[256] = { 0 };
    struct preprocess_ParseDirectiveResult res_eof = (struct preprocess_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
    (void)(preprocess_parse_directive_into((&(res_eof)), line_buf, line_len, cond_eof));
    int32_t kind_eof = (res_eof).kind;
    if (kind_eof != 0) {
      int32_t cond_val_eof = 0;
      if (kind_eof == 1 || kind_eof == 4) {
        cond_val_eof = (preprocess_eval_condition_c((&((cond_eof)[0])), (res_eof).sym_len));
      }
      {
        int32_t ar_eof = preprocess_apply_directive_kind(kind_eof, cond_val_eof);
        if (ar_eof != 0) {
          return ar_eof;
        }
      }
      if (out_len >= (out_buf)->length) {
        return (-1);
      }
      ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (xlang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0)));
      ++out_len;
    } else {
      int keeping_eof = preprocess_line_keeping();
      if (keeping_eof) {
        int32_t i_eof = 0;
        while (i_eof < line_len) {
          if (out_len >= (out_buf)->length) {
            return (-1);
          }
          ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (xlang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = (i_eof < 0 || (i_eof) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[i_eof]), 0)));
          ++out_len;
          ++i_eof;
        }
      }
      if (out_len >= (out_buf)->length) {
        return (-1);
      }
      ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (xlang_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0)));
      ++out_len;
    }
    line_len = 0;
  }
  (void)(({ int32_t __tmp = 0; if (preprocess_if_stack_len() != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return out_len;
}
int32_t preprocess_x_buf(uint8_t source_buf[4194304], ptrdiff_t source_len, uint8_t out_buf[4194304], int32_t out_cap) {
  (void)(({ int32_t __tmp = 0; if (out_cap <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(preprocess_if_stack_reset());
  int32_t out_len = 0;
  int32_t line_len = 0;
  uint8_t line_buf[4096] = { 0 };
  int32_t pos = 0;
  while (pos < source_len && pos < 4194304) {
    uint8_t ch = (pos < 0 || (pos) >= 4194304 ? (xlang_panic_(1, 0), (source_buf)[0]) : (source_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10) {   (void)(({ int32_t __tmp = 0; if (line_len > 0 || 1) {   uint8_t cond[256] = { 0 };
  struct preprocess_ParseDirectiveResult res = (struct preprocess_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
  (void)(preprocess_parse_directive_into((&(res)), line_buf, line_len, cond));
  int32_t kind = (res).kind;
  __tmp = ({ int32_t __tmp = 0; if (kind != 0) {   int32_t cond_val = 0;
  (void)(({ int32_t __tmp = 0; if (kind == 1 || kind == 4) {   (cond_val = (preprocess_eval_condition_c((&((cond)[0])), (res).sym_len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((__tmp = preprocess_apply_directive_kind(kind, cond_val)) != 0) {   return __tmp;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (out_len) >= 4194304 ? (xlang_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0)));
  ++out_len;
 } else {   int keeping = preprocess_line_keeping();
  (void)(({ int32_t __tmp = 0; if (keeping) {   int32_t i = 0;
  while (i < line_len) {
    (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((out_len < 0 || (out_len) >= 4194304 ? (xlang_panic_(1, 0), 0) : ((out_buf)[out_len] = (i < 0 || (i) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[i]), 0)));
    ++out_len;
    ++i;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (out_len) >= 4194304 ? (xlang_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0)));
  ++out_len;
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (line_len = (0));
  ++pos;
 } else {   (void)(({ int32_t __tmp = 0; if (line_len < 4095) {   ((line_len < 0 || (line_len) >= 4096 ? (xlang_panic_(1, 0), 0) : ((line_buf)[line_len] = ch, 0)));
  ++line_len;
 } else (__tmp = 0) ; __tmp; }));
  ++pos;
 } ; __tmp; }));
  }
  /* PLATFORM: SHARED — flush last line when buffer omits trailing LF (mirror preprocess.x). */
  if (line_len > 0) {
    uint8_t cond_eof_b[256] = { 0 };
    struct preprocess_ParseDirectiveResult res_eof_b = (struct preprocess_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
    (void)(preprocess_parse_directive_into((&(res_eof_b)), line_buf, line_len, cond_eof_b));
    int32_t kind_eof_b = (res_eof_b).kind;
    if (kind_eof_b != 0) {
      int32_t cond_val_eof_b = 0;
      if (kind_eof_b == 1 || kind_eof_b == 4) {
        cond_val_eof_b = (preprocess_eval_condition_c((&((cond_eof_b)[0])), (res_eof_b).sym_len));
      }
      {
        int32_t ar_eof_b = preprocess_apply_directive_kind(kind_eof_b, cond_val_eof_b);
        if (ar_eof_b != 0) {
          return ar_eof_b;
        }
      }
      if (out_len >= out_cap) {
        return (-1);
      }
      ((out_len < 0 || (out_len) >= 4194304 ? (xlang_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0)));
      ++out_len;
    } else {
      int keeping_eof_b = preprocess_line_keeping();
      if (keeping_eof_b) {
        int32_t i_eof_b = 0;
        while (i_eof_b < line_len) {
          if (out_len >= out_cap) {
            return (-1);
          }
          ((out_len < 0 || (out_len) >= 4194304 ? (xlang_panic_(1, 0), 0) : ((out_buf)[out_len] = (i_eof_b < 0 || (i_eof_b) >= 4096 ? (xlang_panic_(1, 0), (line_buf)[0]) : (line_buf)[i_eof_b]), 0)));
          ++out_len;
          ++i_eof_b;
        }
      }
      if (out_len >= out_cap) {
        return (-1);
      }
      ((out_len < 0 || (out_len) >= 4194304 ? (xlang_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0)));
      ++out_len;
    }
    line_len = 0;
  }
  (void)(({ int32_t __tmp = 0; if (preprocess_if_stack_len() != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return out_len;
}
