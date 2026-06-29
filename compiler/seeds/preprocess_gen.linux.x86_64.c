/* generated from preprocess */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
struct shux_slice_uint8_t { uint8_t *data; size_t length; };
struct preprocess_ParseDirectiveResult { int32_t kind; int32_t sym_len; };
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
extern void preprocess_if_stack_reset();
extern int32_t preprocess_if_stack_len();
extern int32_t preprocess_if_stack_push(int32_t v);
extern void preprocess_if_stack_pop();
extern int32_t preprocess_if_stack_at(int32_t i);
extern void preprocess_if_stack_set_at(int32_t i, int32_t v);
extern int32_t preprocess_eval_condition_c(uint8_t * cond, int32_t cond_len);
int32_t preprocess_apply_directive_kind(int32_t kind, int32_t cond_val);
int preprocess_line_keeping();
int32_t preprocess_parse_copy_cond_from_line(uint8_t cond[256], uint8_t line_buf[512], int32_t pos, int32_t line_len);
void preprocess_parse_directive_into(struct preprocess_ParseDirectiveResult * out, uint8_t line_buf[512], int32_t line_len, uint8_t cond[256]);
int32_t preprocess_sx(struct shux_slice_uint8_t * source, struct shux_slice_uint8_t * out_buf);
int32_t preprocess_sx_buf(uint8_t source_buf[4194304], ptrdiff_t source_len, uint8_t out_buf[4194304], int32_t out_cap);
int32_t preprocess_apply_directive_kind(int32_t kind, int32_t cond_val) {
  int32_t depth = preprocess_if_stack_len();
  (void)(({ int32_t __tmp = 0; if (kind == 1) {   int32_t v = cond_val;
  (void)(({ int32_t __tmp = 0; if (depth > 0) {   int32_t parent = preprocess_if_stack_at(depth - 1);
  __tmp = ({ int32_t __tmp = 0; if (parent == 0) {   (v = (0));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (v != 0) {   (v = (1));
 } else (__tmp = 0) ; __tmp; }));
  return preprocess_if_stack_push(v);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == 2) {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t di = depth - 1;
  int32_t top = preprocess_if_stack_at(di);
  (void)(({ int32_t __tmp = 0; if (top == 1) {   (void)(preprocess_if_stack_set_at(di, 0));
 } else (__tmp = ({ int32_t __tmp = 0; if (top == 0) {   (void)(preprocess_if_stack_set_at(di, 2));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == 4) {   (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t di2 = depth - 1;
  int32_t top2 = preprocess_if_stack_at(di2);
  (void)(({ int32_t __tmp = 0; if (top2 == 2) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (top2 == 1) {   (void)(preprocess_if_stack_set_at(di2, 3));
 } else (__tmp = ({ int32_t __tmp = 0; if (top2 == 0) {   int32_t cv = cond_val;
  __tmp = ({ int32_t __tmp = 0; if (cv != 0) {   (void)(preprocess_if_stack_set_at(di2, 1));
 } else {   (void)(preprocess_if_stack_set_at(di2, 0));
 } ; __tmp; });
 } else {   (void)(preprocess_if_stack_set_at(di2, 3));
 } ; __tmp; })) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (depth == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(preprocess_if_stack_pop());
  return 0;
}
int preprocess_line_keeping() {
  int32_t depth = preprocess_if_stack_len();
  (void)(({ int __tmp = 0; if (depth == 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  int32_t top = preprocess_if_stack_at(depth - 1);
  return top == 1 || top == 2;
}
int32_t preprocess_parse_copy_cond_from_line(uint8_t cond[256], uint8_t line_buf[512], int32_t pos, int32_t line_len) {
  int32_t s = 0;
  while (pos < line_len && s < 255) {
    uint8_t ch = (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10 || ch == 13) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ((s < 0 || (s) >= 256 ? (shux_panic_(1, 0), 0) : ((cond)[s] = ch, 0)));
    ++s;
    ++pos;
  }
  while (s > 0) {
    uint8_t tail = (s - 1 < 0 || (s - 1) >= 256 ? (shux_panic_(1, 0), (cond)[0]) : (cond)[s - 1]);
    (void)(({ int32_t __tmp = 0; if (tail != 32 && tail != 9 && tail != 13) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (s = (s - 1));
  }
  return s;
}
void preprocess_parse_directive_into(struct preprocess_ParseDirectiveResult * out, uint8_t line_buf[512], int32_t line_len, uint8_t cond[256]) {
  int32_t pos = 0;
  ((out)->kind = (0));
  ((out)->sym_len = (0));
  while (pos < line_len) {
    uint8_t ws0 = (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ws0 != 32 && ws0 != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++pos;
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 35) {   return;
 } else (__tmp = 0) ; __tmp; }));
  ++pos;
  while (pos < line_len) {
    uint8_t ws1 = (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ws1 != 32 && ws1 != 9) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++pos;
  }
  (void)(({ int32_t __tmp = 0; if (pos >= line_len) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 2 <= line_len && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 105 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 102) {   pos += 2;
  (void)(({ int32_t __tmp = 0; if (pos < line_len && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 32 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 9 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 10 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 13 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  while (pos < line_len) {
    uint8_t ws_if = (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
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
  (void)(({ int32_t __tmp = 0; if (pos + 6 <= line_len && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 108 && (pos + 2 < 0 || (pos + 2) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 115 && (pos + 3 < 0 || (pos + 3) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 101 && (pos + 4 < 0 || (pos + 4) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 4]) == 105 && (pos + 5 < 0 || (pos + 5) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 5]) == 102) {   pos += 6;
  (void)(({ int32_t __tmp = 0; if (pos < line_len && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 32 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 9 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 10 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 13 && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  while (pos < line_len) {
    uint8_t ws_elseif = (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]);
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
  (void)(({ int32_t __tmp = 0; if (pos + 4 <= line_len && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 108 && (pos + 2 < 0 || (pos + 2) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 115 && (pos + 3 < 0 || (pos + 3) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 101) {   pos += 4;
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 10 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 13 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 0) {   ((out)->kind = (2));
  ((out)->sym_len = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pos + 5 <= line_len && (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 101 && (pos + 1 < 0 || (pos + 1) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 1]) == 110 && (pos + 2 < 0 || (pos + 2) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 2]) == 100 && (pos + 3 < 0 || (pos + 3) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 3]) == 105 && (pos + 4 < 0 || (pos + 4) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos + 4]) == 102) {   pos += 5;
  (void)(({ int32_t __tmp = 0; if (pos >= line_len || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 32 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 9 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 10 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 13 || (pos < 0 || (pos) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[pos]) == 0) {   ((out)->kind = (3));
  ((out)->sym_len = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
  return;
}
int32_t preprocess_sx(struct shux_slice_uint8_t * source, struct shux_slice_uint8_t * out_buf) {
  (void)(({ int32_t __tmp = 0; if ((out_buf)->length <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(preprocess_if_stack_reset());
  int32_t out_len = 0;
  int32_t line_len = 0;
  uint8_t line_buf[512] = { 0 };
  int32_t pos = 0;
  while (pos < (source)->length) {
    uint8_t ch = (pos < 0 || (size_t)(pos) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10) {   (void)(({ int32_t __tmp = 0; if (line_len > 0 || 1) {   uint8_t cond[256] = { 0 };
  struct preprocess_ParseDirectiveResult res = (struct preprocess_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
  (void)(preprocess_parse_directive_into((&(res)), line_buf, line_len, cond));
  int32_t kind = (res).kind;
  __tmp = ({ int32_t __tmp = 0; if (kind != 0) {   int32_t cond_val = 0;
  (void)(({ int32_t __tmp = 0; if (kind == 1 || kind == 4) {   (cond_val = (preprocess_eval_condition_c((&((cond)[0])), (res).sym_len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (preprocess_apply_directive_kind(kind, cond_val) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (shux_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0)));
  ++out_len;
 } else {   int keeping = preprocess_line_keeping();
  (void)(({ int32_t __tmp = 0; if (keeping) {   int32_t i = 0;
  while (i < line_len) {
    (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (shux_panic_(1, 0), 0) : ((out_buf)->data[out_len] = (i < 0 || (i) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[i]), 0)));
    ++out_len;
    ++i;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= (out_buf)->length) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (size_t)(out_len) >= (out_buf)->length ? (shux_panic_(1, 0), 0) : ((out_buf)->data[out_len] = 10, 0)));
  ++out_len;
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (line_len = (0));
  ++pos;
 } else {   (void)(({ int32_t __tmp = 0; if (line_len < 511) {   ((line_len < 0 || (line_len) >= 512 ? (shux_panic_(1, 0), 0) : ((line_buf)[line_len] = ch, 0)));
  ++line_len;
 } else (__tmp = 0) ; __tmp; }));
  ++pos;
 } ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (preprocess_if_stack_len() != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return out_len;
}
int32_t preprocess_sx_buf(uint8_t source_buf[4194304], ptrdiff_t source_len, uint8_t out_buf[4194304], int32_t out_cap) {
  (void)(({ int32_t __tmp = 0; if (out_cap <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(preprocess_if_stack_reset());
  int32_t out_len = 0;
  int32_t line_len = 0;
  uint8_t line_buf[512] = { 0 };
  int32_t pos = 0;
  while (pos < source_len && pos < 4194304) {
    uint8_t ch = (pos < 0 || (pos) >= 4194304 ? (shux_panic_(1, 0), (source_buf)[0]) : (source_buf)[pos]);
    (void)(({ int32_t __tmp = 0; if (ch == 10) {   (void)(({ int32_t __tmp = 0; if (line_len > 0 || 1) {   uint8_t cond[256] = { 0 };
  struct preprocess_ParseDirectiveResult res = (struct preprocess_ParseDirectiveResult){ .kind = 0, .sym_len = 0 };
  (void)(preprocess_parse_directive_into((&(res)), line_buf, line_len, cond));
  int32_t kind = (res).kind;
  __tmp = ({ int32_t __tmp = 0; if (kind != 0) {   int32_t cond_val = 0;
  (void)(({ int32_t __tmp = 0; if (kind == 1 || kind == 4) {   (cond_val = (preprocess_eval_condition_c((&((cond)[0])), (res).sym_len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (preprocess_apply_directive_kind(kind, cond_val) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (out_len) >= 4194304 ? (shux_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0)));
  ++out_len;
 } else {   int keeping = preprocess_line_keeping();
  (void)(({ int32_t __tmp = 0; if (keeping) {   int32_t i = 0;
  while (i < line_len) {
    (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((out_len < 0 || (out_len) >= 4194304 ? (shux_panic_(1, 0), 0) : ((out_buf)[out_len] = (i < 0 || (i) >= 512 ? (shux_panic_(1, 0), (line_buf)[0]) : (line_buf)[i]), 0)));
    ++out_len;
    ++i;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_len >= out_cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((out_len < 0 || (out_len) >= 4194304 ? (shux_panic_(1, 0), 0) : ((out_buf)[out_len] = 10, 0)));
  ++out_len;
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (line_len = (0));
  ++pos;
 } else {   (void)(({ int32_t __tmp = 0; if (line_len < 511) {   ((line_len < 0 || (line_len) >= 512 ? (shux_panic_(1, 0), 0) : ((line_buf)[line_len] = ch, 0)));
  ++line_len;
 } else (__tmp = 0) ; __tmp; }));
  ++pos;
 } ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (preprocess_if_stack_len() != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return out_len;
}
