#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
struct xlang_slice_uint8_t { uint8_t *data; size_t length; };
struct ParseDirectiveResult {
  int32_t kind;
  int32_t sym_len;
};

extern void pp_if_stack_reset(void);
extern int32_t pp_if_stack_len(void);
extern int32_t pp_if_stack_push(int32_t v);
extern int32_t pp_if_stack_at(int32_t i);
extern void pp_if_stack_set_at(int32_t i, int32_t v);
extern void pp_if_stack_pop(void);
extern int32_t pp_eval_condition(uint8_t * cond, int32_t cond_len);
extern int32_t pp_reset_i32(void);
extern int pp_kind_needs_cond(int32_t kind);
extern int pp_is_ws(uint8_t ch);
extern int pp_is_eol(uint8_t ch);
extern int pp_is_token_end(uint8_t ch);
extern int pp_at_end_or_not_byte(uint8_t * buf, int32_t pos, int32_t line_len, uint8_t target);
extern int pp_is_word_boundary(uint8_t * buf, int32_t pos, int32_t line_len);
extern int pp_at_end_or_token_end(uint8_t * buf, int32_t pos, int32_t line_len);
extern int pp_match_if(uint8_t * buf, int32_t pos, int32_t line_len);
extern int pp_match_elseif(uint8_t * buf, int32_t pos, int32_t line_len);
extern int pp_match_else(uint8_t * buf, int32_t pos, int32_t line_len);
extern int pp_match_endif(uint8_t * buf, int32_t pos, int32_t line_len);
extern int32_t preprocess_apply_directive_kind(int32_t kind, int32_t cond_val);
extern int preprocess_line_keeping(void);
extern int32_t parse_copy_cond_from_line(uint8_t * cond, uint8_t * line_buf, int32_t pos, int32_t line_len);
extern void parse_directive_into(uint8_t * line_buf, int32_t line_len, uint8_t * cond);
extern int32_t preprocess_x(struct xlang_slice_uint8_t source, struct xlang_slice_uint8_t out_buf);
extern int32_t preprocess_x_buf(uint8_t * source_buf, ssize_t source_len, uint8_t * out_buf, int32_t out_cap);
static int32_t g_pp_kind;
static int32_t g_pp_sym_len;
static uint8_t g_pp_line_buf[512];
static uint8_t g_pp_cond[256];
static void init_globals(void) {
  g_pp_kind = 0;
  g_pp_sym_len = 0;
}
extern void preprocess_if_stack_reset(void);
extern int32_t preprocess_if_stack_len(void);
extern int32_t preprocess_if_stack_push(int32_t v);
extern void preprocess_if_stack_pop(void);
extern int32_t preprocess_if_stack_at(int32_t i);
extern void preprocess_if_stack_set_at(int32_t i, int32_t v);
extern int32_t preprocess_eval_condition_c(uint8_t * cond, int32_t cond_len);
void pp_if_stack_reset(void) {
  (void)(preprocess_if_stack_reset());
  (void)(0);
  return;
}
int32_t pp_if_stack_len(void) {
  return preprocess_if_stack_len();
  return 0;
}
int32_t pp_if_stack_push(int32_t v) {
  return preprocess_if_stack_push(v);
  return 0;
}
int32_t pp_if_stack_at(int32_t i) {
  return preprocess_if_stack_at(i);
  return 0;
}
void pp_if_stack_set_at(int32_t i, int32_t v) {
  (void)(preprocess_if_stack_set_at(i, v));
  (void)(0);
  return;
}
void pp_if_stack_pop(void) {
  (void)(preprocess_if_stack_pop());
  (void)(0);
  return;
}
int32_t pp_eval_condition(uint8_t * cond, int32_t cond_len) {
  return preprocess_eval_condition_c(cond, cond_len);
  return 0;
}
int32_t pp_reset_i32(void) {
  (void)(preprocess_if_stack_reset());
  return 0;
}
int pp_kind_needs_cond(int32_t kind) {
  if ((kind ==1)) {
    return 1;
  }
  if ((kind ==4)) {
    return 1;
  }
  return 0;
}
int pp_is_ws(uint8_t ch) {
  if ((ch ==32)) {
    return 1;
  }
  if ((ch ==9)) {
    return 1;
  }
  return 0;
}
int pp_is_eol(uint8_t ch) {
  if ((ch ==10)) {
    return 1;
  }
  if ((ch ==13)) {
    return 1;
  }
  return 0;
}
int pp_is_token_end(uint8_t ch) {
  if ((ch ==32)) {
    return 1;
  }
  if ((ch ==9)) {
    return 1;
  }
  if ((ch ==10)) {
    return 1;
  }
  if ((ch ==13)) {
    return 1;
  }
  if ((ch ==0)) {
    return 1;
  }
  return 0;
}
int pp_at_end_or_not_byte(uint8_t * buf, int32_t pos, int32_t line_len, uint8_t target) {
  if ((pos >=line_len)) {
    return 1;
  }
  if (((buf)[pos] !=target)) {
    return 1;
  }
  return 0;
}
int pp_is_word_boundary(uint8_t * buf, int32_t pos, int32_t line_len) {
  if ((pos >=line_len)) {
    return 0;
  }
  uint8_t ch = (buf)[pos];
  if (pp_is_token_end(ch)) {
    return 0;
  }
  return 1;
}
int pp_at_end_or_token_end(uint8_t * buf, int32_t pos, int32_t line_len) {
  if ((pos >=line_len)) {
    return 1;
  }
  uint8_t ch = (buf)[pos];
  if (pp_is_token_end(ch)) {
    return 1;
  }
  return 0;
}
int pp_match_if(uint8_t * buf, int32_t pos, int32_t line_len) {
  if (((pos + 2) > line_len)) {
    return 0;
  }
  if (((buf)[pos] !=105)) {
    return 0;
  }
  if (((buf)[(pos + 1)] !=102)) {
    return 0;
  }
  return 1;
}
int pp_match_elseif(uint8_t * buf, int32_t pos, int32_t line_len) {
  if (((pos + 6) > line_len)) {
    return 0;
  }
  if (((buf)[pos] !=101)) {
    return 0;
  }
  if (((buf)[(pos + 1)] !=108)) {
    return 0;
  }
  if (((buf)[(pos + 2)] !=115)) {
    return 0;
  }
  if (((buf)[(pos + 3)] !=101)) {
    return 0;
  }
  if (((buf)[(pos + 4)] !=105)) {
    return 0;
  }
  if (((buf)[(pos + 5)] !=102)) {
    return 0;
  }
  return 1;
}
int pp_match_else(uint8_t * buf, int32_t pos, int32_t line_len) {
  if (((pos + 4) > line_len)) {
    return 0;
  }
  if (((buf)[pos] !=101)) {
    return 0;
  }
  if (((buf)[(pos + 1)] !=108)) {
    return 0;
  }
  if (((buf)[(pos + 2)] !=115)) {
    return 0;
  }
  if (((buf)[(pos + 3)] !=101)) {
    return 0;
  }
  return 1;
}
int pp_match_endif(uint8_t * buf, int32_t pos, int32_t line_len) {
  if (((pos + 5) > line_len)) {
    return 0;
  }
  if (((buf)[pos] !=101)) {
    return 0;
  }
  if (((buf)[(pos + 1)] !=110)) {
    return 0;
  }
  if (((buf)[(pos + 2)] !=100)) {
    return 0;
  }
  if (((buf)[(pos + 3)] !=105)) {
    return 0;
  }
  if (((buf)[(pos + 4)] !=102)) {
    return 0;
  }
  return 1;
}
int32_t preprocess_apply_directive_kind(int32_t kind, int32_t cond_val) {
  int32_t depth = pp_if_stack_len();
  if ((kind ==1)) {
    int32_t v = cond_val;
    if ((depth > 0)) {
      int32_t parent = pp_if_stack_at((depth - 1));
      if ((parent ==0)) {
        (void)((v = 0));
      }
    }
    if ((v !=0)) {
      (void)((v = 1));
    }
    int32_t pr = pp_if_stack_push(v);
    if ((pr < 0)) {
      return -(7);
    }
    return 0;
  }
  if ((kind ==2)) {
    int32_t di = (depth - 1);
    int32_t top = pp_if_stack_at(di);
    if ((depth ==0)) {
      return -(2);
    }
    if ((top ==1)) {
      (void)(pp_if_stack_set_at(di, 0));
    } else {
      if ((top ==0)) {
        (void)(pp_if_stack_set_at(di, 2));
      } else {
        if ((top ==3)) {
        } else {
          return -(6);
        }
      }
    }
    return 0;
  }
  if ((kind ==4)) {
    int32_t di2 = (depth - 1);
    int32_t top2 = pp_if_stack_at(di2);
    if ((depth ==0)) {
      return -(4);
    }
    if ((top2 ==2)) {
      return -(5);
    }
    if ((top2 ==1)) {
      (void)(pp_if_stack_set_at(di2, 3));
    } else {
      if ((top2 ==0)) {
        int32_t cv = cond_val;
        if ((cv !=0)) {
          (void)(pp_if_stack_set_at(di2, 1));
        } else {
          (void)(pp_if_stack_set_at(di2, 0));
        }
      } else {
        (void)(pp_if_stack_set_at(di2, 3));
      }
    }
    return 0;
  }
  if ((depth ==0)) {
    return -(3);
  }
  (void)(pp_if_stack_pop());
  return 0;
}
int preprocess_line_keeping(void) {
  int32_t depth = pp_if_stack_len();
  if ((depth ==0)) {
    return 1;
  }
  int32_t top = pp_if_stack_at((depth - 1));
  if ((top ==1)) {
    return 1;
  }
  if ((top ==2)) {
    return 1;
  }
  return 0;
}
int32_t parse_copy_cond_from_line(uint8_t * cond, uint8_t * line_buf, int32_t pos, int32_t line_len) {
  int32_t s = 0;
  while ((pos < line_len)) {
    uint8_t ch = (line_buf)[pos];
    if ((s >=255)) {
      break;
    }
    if (pp_is_eol(ch)) {
      break;
    }
    (void)(((cond)[s] = ch));
    (void)((s = (s + 1)));
    (void)((pos = (pos + 1)));
  }
  while ((s > 0)) {
    uint8_t tail = (cond)[(s - 1)];
    if (pp_is_ws(tail)) {
      (void)((s = (s - 1)));
    } else {
      if ((tail ==13)) {
        (void)((s = (s - 1)));
      } else {
        break;
      }
    }
  }
  return s;
}
void parse_directive_into(uint8_t * line_buf, int32_t line_len, uint8_t * cond) {
  int32_t pos = 0;
  (void)((g_pp_kind = 0));
  (void)((g_pp_sym_len = 0));
  while ((pos < line_len)) {
    uint8_t ws0 = (line_buf)[pos];
    if (pp_is_ws(ws0)) {
      (void)((pos = (pos + 1)));
    } else {
      break;
    }
  }
  if (pp_at_end_or_not_byte(line_buf, pos, line_len, ((uint8_t)(35)))) {
    return;
  }
  (void)((pos = (pos + 1)));
  while ((pos < line_len)) {
    uint8_t ws1 = (line_buf)[pos];
    if (pp_is_ws(ws1)) {
      (void)((pos = (pos + 1)));
    } else {
      break;
    }
  }
  if ((pos >=line_len)) {
    return;
  }
  if (pp_match_if(line_buf, pos, line_len)) {
    int32_t cl = parse_copy_cond_from_line(cond, line_buf, pos, line_len);
    (void)((pos = (pos + 2)));
    if (pp_is_word_boundary(line_buf, pos, line_len)) {
      return;
    }
    while ((pos < line_len)) {
      uint8_t ws_if = (line_buf)[pos];
      if (pp_is_ws(ws_if)) {
        (void)((pos = (pos + 1)));
      } else {
        break;
      }
    }
    if ((pos >=line_len)) {
      return;
    }
    if ((cl <=0)) {
      return;
    }
    (void)((g_pp_kind = 1));
    (void)((g_pp_sym_len = cl));
    return;
  }
  if (pp_match_elseif(line_buf, pos, line_len)) {
    int32_t cl2 = parse_copy_cond_from_line(cond, line_buf, pos, line_len);
    (void)((pos = (pos + 6)));
    if (pp_is_word_boundary(line_buf, pos, line_len)) {
      return;
    }
    while ((pos < line_len)) {
      uint8_t ws_elseif = (line_buf)[pos];
      if (pp_is_ws(ws_elseif)) {
        (void)((pos = (pos + 1)));
      } else {
        break;
      }
    }
    if ((pos >=line_len)) {
      return;
    }
    if ((cl2 <=0)) {
      return;
    }
    (void)((g_pp_kind = 4));
    (void)((g_pp_sym_len = cl2));
    return;
  }
  if (pp_match_else(line_buf, pos, line_len)) {
    (void)((pos = (pos + 4)));
    if (pp_at_end_or_token_end(line_buf, pos, line_len)) {
      (void)((g_pp_kind = 2));
      (void)((g_pp_sym_len = 0));
      return;
    }
    return;
  }
  if (pp_match_endif(line_buf, pos, line_len)) {
    (void)((pos = (pos + 5)));
    if (pp_at_end_or_token_end(line_buf, pos, line_len)) {
      (void)((g_pp_kind = 3));
      (void)((g_pp_sym_len = 0));
      return;
    }
    return;
  }
}
int32_t preprocess_x(struct xlang_slice_uint8_t source, struct xlang_slice_uint8_t out_buf) {
  if (((out_buf.length) <=0)) {
    return -(1);
  }
  int32_t _r = pp_reset_i32();
  int32_t out_len = 0;
  int32_t line_len = 0;
  int32_t pos = 0;
  while ((pos < (source.length))) {
    uint8_t ch = (source).data[pos];
    if ((ch ==10)) {
      int32_t kind = g_pp_kind;
      (void)(parse_directive_into(g_pp_line_buf, line_len, g_pp_cond));
      if ((kind !=0)) {
        int32_t cond_val = 0;
        if (pp_kind_needs_cond(kind)) {
          (void)((cond_val = pp_eval_condition(&((g_pp_cond)[0]), g_pp_sym_len)));
        }
        int32_t ar = preprocess_apply_directive_kind(kind, cond_val);
        if ((ar !=0)) {
          return ar;
        }
        if ((out_len >=(out_buf.length))) {
          return -(1);
        }
        (void)(((out_buf).data[out_len] = 10));
        (void)((out_len = (out_len + 1)));
      } else {
        int keeping = preprocess_line_keeping();
        if (keeping) {
          int32_t i = 0;
          while ((i < line_len)) {
            if ((out_len >=(out_buf.length))) {
              return -(1);
            }
            (void)(((out_buf).data[out_len] = (g_pp_line_buf)[i]));
            (void)((out_len = (out_len + 1)));
            (void)((i = (i + 1)));
          }
        }
        if ((out_len >=(out_buf.length))) {
          return -(1);
        }
        (void)(((out_buf).data[out_len] = 10));
        (void)((out_len = (out_len + 1)));
      }
      (void)((line_len = 0));
      (void)((pos = (pos + 1)));
    } else {
      if ((line_len < 511)) {
        (void)(((g_pp_line_buf)[line_len] = ch));
        (void)((line_len = (line_len + 1)));
      }
      (void)((pos = (pos + 1)));
    }
  }
  if ((pp_if_stack_len() !=0)) {
    return -(1);
  }
  return out_len;
}
int32_t preprocess_x_buf(uint8_t * source_buf, ssize_t source_len, uint8_t * out_buf, int32_t out_cap) {
  if ((out_cap <=0)) {
    return -(1);
  }
  int32_t _r = pp_reset_i32();
  int32_t out_len = 0;
  int32_t line_len = 0;
  int32_t pos = 0;
  while ((pos < source_len)) {
    uint8_t ch = (source_buf)[pos];
    if ((pos >=4194304)) {
      break;
    }
    if ((ch ==10)) {
      int32_t kind = g_pp_kind;
      (void)(parse_directive_into(g_pp_line_buf, line_len, g_pp_cond));
      if ((kind !=0)) {
        int32_t cond_val = 0;
        if (pp_kind_needs_cond(kind)) {
          (void)((cond_val = pp_eval_condition(&((g_pp_cond)[0]), g_pp_sym_len)));
        }
        int32_t ar = preprocess_apply_directive_kind(kind, cond_val);
        if ((ar !=0)) {
          return ar;
        }
        if ((out_len >=out_cap)) {
          return -(1);
        }
        (void)(((out_buf)[out_len] = 10));
        (void)((out_len = (out_len + 1)));
      } else {
        int keeping = preprocess_line_keeping();
        if (keeping) {
          int32_t i = 0;
          while ((i < line_len)) {
            if ((out_len >=out_cap)) {
              return -(1);
            }
            (void)(((out_buf)[out_len] = (g_pp_line_buf)[i]));
            (void)((out_len = (out_len + 1)));
            (void)((i = (i + 1)));
          }
        }
        if ((out_len >=out_cap)) {
          return -(1);
        }
        (void)(((out_buf)[out_len] = 10));
        (void)((out_len = (out_len + 1)));
      }
      (void)((line_len = 0));
      (void)((pos = (pos + 1)));
    } else {
      if ((line_len < 511)) {
        (void)(((g_pp_line_buf)[line_len] = ch));
        (void)((line_len = (line_len + 1)));
      }
      (void)((pos = (pos + 1)));
    }
  }
  if ((pp_if_stack_len() !=0)) {
    return -(1);
  }
  return out_len;
}
