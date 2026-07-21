/* seeds/async_liveness_surface.from_x.c
 * R2 pure surface — isomorphic with src/async/async_liveness.x pure helpers
 * Product cold path still cc seeds/async_liveness.from_x.c (no FROM_X) for full C + Cap residual.
 * Hybrid/PREFER: g05_try_x_to_o(async_liveness.x) + rest (-DSHUX_ASYNC_LIVENESS_FROM_X).
 * R2: full.x eats pure helpers (await walk / live frame / mangle/tag); FROM_X omits those C bodies.
 * Cap residual (stay seed C always): lookup_var_type / type_to_c_buf / type_size /
 *   layout_func* / analyze_func / module_struct_in_frame / emit_* (FILE* fprintf).
 * Prove: full.x vs this seed → nm IDENTICAL (pure surface)
 * Regen: ./shux -E ... src/async/async_liveness.x | filter DBG + polish prologue
 * NOTE: use ./shux (not shux-x). Stack: analyze_block_linear uses malloc(4096) not u8[4096].
 * PLATFORM: SHARED — async liveness pure helpers; mac + Ubuntu prove.
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern int32_t async_liveness_x_doc_anchor(void);
extern uint8_t * async_liveness_async_live_load_func_name(uint8_t * callee);
extern int32_t async_liveness_callee_is_io_read(uint8_t * f);
extern int32_t async_liveness_callee_is_io_write(uint8_t * f);
extern int32_t async_liveness_async_live_load_i32(uint8_t * p, int32_t off);
extern uint8_t * async_liveness_async_live_load_ptr(uint8_t * p, int32_t off);
extern uint8_t * async_liveness_async_live_ptr_at(uint8_t * base, int32_t i);
extern int32_t async_liveness_async_live_expr_kind(uint8_t * e);
extern int32_t async_liveness_async_live_is_binop_kind(int32_t k);
extern int32_t async_liveness_async_live_is_unary_kind(int32_t k);
extern int32_t expr_has_await(uint8_t * e);
extern int32_t expr_count_await(uint8_t * e);
extern int32_t block_count_await(uint8_t * b);
extern int32_t block_has_await(uint8_t * b);
extern int32_t expr_has_io_read_await(uint8_t * e);
extern int32_t expr_has_io_write_await(uint8_t * e);
extern int32_t block_has_io_read_await(uint8_t * b);
extern int32_t block_has_io_write_await(uint8_t * b);
extern int32_t async_liveness_async_live_cstr_eq(uint8_t * a, uint8_t * b);
extern void async_liveness_async_live_cstr_copy64(uint8_t * dst, uint8_t * src);
extern uint8_t * async_liveness_async_live_def_row(uint8_t * defs, int32_t i);
extern uint8_t * async_liveness_async_live_load_def_name(uint8_t * defs, int32_t i);
extern int32_t expr_refs_var(uint8_t * e, uint8_t * name);
extern int32_t block_refs_var(uint8_t * b, uint8_t * name);
extern int32_t block_rest_refs_var(uint8_t * b, int32_t from_exclusive, uint8_t * name);
extern int32_t async_liveness_frame_live_load_n(uint8_t * out);
extern void async_liveness_frame_live_store_n(uint8_t * out, int32_t n);
extern uint8_t * async_liveness_frame_live_row_ptr(uint8_t * out, int32_t idx);
extern int32_t async_liveness_frame_live_name_eq(uint8_t * row, uint8_t * name);
extern void frame_live_add(uint8_t * out, uint8_t * name);
extern void frame_live_at_await(uint8_t * b, int32_t idx, uint8_t * defs, int32_t nd, uint8_t * out);
extern void async_liveness_async_live_analyze_at_await(uint8_t * b, int32_t si, uint8_t * defs, int32_t n_def, uint8_t * frame);
extern void analyze_block_linear(uint8_t * b, uint8_t * prefix, int32_t n_prefix, uint8_t * frame);
extern void frame_mangle_ident(uint8_t * in_name, uint8_t * out, int32_t cap);
extern void frame_build_tag(uint8_t * f, uint8_t * out, int32_t cap);
extern int32_t live_name_cmp(uint8_t * a, uint8_t * b);
int32_t async_liveness_x_doc_anchor(void) {
  return 0;
}
uint8_t * async_liveness_async_live_load_func_name(uint8_t * callee) {
  if ((callee ==0)) {
    return ((uint8_t *)(0));
  }
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  size_t a = ((size_t)((callee)[8]));
  (void)((a = (a + (((size_t)((callee)[9])) * m))));
  (void)((a = (a + (((size_t)((callee)[10])) * m2))));
  (void)((a = (a + (((size_t)((callee)[11])) * (m2 * m)))));
  (void)((a = (a + (((size_t)((callee)[12])) * m4))));
  (void)((a = (a + (((size_t)((callee)[13])) * (m4 * m)))));
  (void)((a = (a + (((size_t)((callee)[14])) * (m4 * m2)))));
  (void)((a = (a + (((size_t)((callee)[15])) * ((m4 * m2) * m)))));
  return ((uint8_t *)(a));
}
int32_t async_liveness_callee_is_io_read(uint8_t * f) {
  uint8_t * name = async_liveness_async_live_load_func_name(f);
  if ((name ==0)) {
    return 0;
  }
  if (((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==0))) {
    return 1;
  }
  if ((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==100)) && ((name)[7] ==0))) {
    return 1;
  }
  return 0;
}
int32_t async_liveness_callee_is_io_write(uint8_t * f) {
  uint8_t * name = async_liveness_async_live_load_func_name(f);
  if ((name ==0)) {
    return 0;
  }
  if ((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==0))) {
    return 1;
  }
  if (((((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==95)) && ((name)[6] ==102)) && ((name)[7] ==100)) && ((name)[8] ==0))) {
    return 1;
  }
  return 0;
}
int32_t async_liveness_async_live_load_i32(uint8_t * p, int32_t off) {
  if ((p ==0)) {
    return 0;
  }
  int32_t m = 256;
  int32_t a = ((int32_t)((p)[off]));
  (void)((a = (a + (((int32_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + ((((int32_t)((p)[(off + 2)])) * m) * m))));
  (void)((a = (a + (((((int32_t)((p)[(off + 3)])) * m) * m) * m))));
  return a;
}
uint8_t * async_liveness_async_live_load_ptr(uint8_t * p, int32_t off) {
  if ((p ==0)) {
    return ((uint8_t *)(0));
  }
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  size_t a = ((size_t)((p)[off]));
  (void)((a = (a + (((size_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + (((size_t)((p)[(off + 2)])) * m2))));
  (void)((a = (a + (((size_t)((p)[(off + 3)])) * (m2 * m)))));
  (void)((a = (a + (((size_t)((p)[(off + 4)])) * m4))));
  (void)((a = (a + (((size_t)((p)[(off + 5)])) * (m4 * m)))));
  (void)((a = (a + (((size_t)((p)[(off + 6)])) * (m4 * m2)))));
  (void)((a = (a + (((size_t)((p)[(off + 7)])) * ((m4 * m2) * m)))));
  return ((uint8_t *)(a));
}
uint8_t * async_liveness_async_live_ptr_at(uint8_t * base, int32_t i) {
  if ((base ==0)) {
    return ((uint8_t *)(0));
  }
  return async_liveness_async_live_load_ptr(base, (i * 8));
}
int32_t async_liveness_async_live_expr_kind(uint8_t * e) {
  return async_liveness_async_live_load_i32(e, 0);
}
int32_t async_liveness_async_live_is_binop_kind(int32_t k) {
  if ((k >=4)) {
    if ((k <=21)) {
      return 1;
    }
  }
  if ((k >=28)) {
    if ((k <=38)) {
      return 1;
    }
  }
  return 0;
}
int32_t async_liveness_async_live_is_unary_kind(int32_t k) {
  if ((k ==22)) {
    return 1;
  }
  if ((k ==23)) {
    return 1;
  }
  if ((k ==24)) {
    return 1;
  }
  if ((k ==41)) {
    return 1;
  }
  if ((k ==42)) {
    return 1;
  }
  if ((k ==51)) {
    return 1;
  }
  if ((k ==52)) {
    return 1;
  }
  return 0;
}
int32_t expr_has_await(uint8_t * e) {
  if ((e ==0)) {
    return 0;
  }
  int32_t k = async_liveness_async_live_expr_kind(e);
  if ((k ==54)) {
    return 1;
  }
  if ((async_liveness_async_live_is_binop_kind(k) !=0)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    return 0;
  }
  if ((async_liveness_async_live_is_unary_kind(k) !=0)) {
    return expr_has_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==53)) {
    return expr_has_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==25)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    uint8_t * el = async_liveness_async_live_load_ptr(e, 40);
    if ((el !=0)) {
      if ((expr_has_await(el) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==27)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    uint8_t * el2 = async_liveness_async_live_load_ptr(e, 40);
    if ((el2 !=0)) {
      if ((expr_has_await(el2) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==26)) {
    return block_has_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==44)) {
    return expr_has_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==47)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    return expr_has_await(async_liveness_async_live_load_ptr(e, 32));
  }
  if ((k ==48)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * args = async_liveness_async_live_load_ptr(e, 32);
    int32_t n = async_liveness_async_live_load_i32(e, 40);
    int32_t i = 0;
    while ((i < n)) {
      if ((expr_has_await(async_liveness_async_live_ptr_at(args, i)) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  if ((k ==49)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * args2 = async_liveness_async_live_load_ptr(e, 40);
    int32_t n2 = async_liveness_async_live_load_i32(e, 48);
    int32_t j = 0;
    while ((j < n2)) {
      if ((expr_has_await(async_liveness_async_live_ptr_at(args2, j)) !=0)) {
        return 1;
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
  if ((k ==45)) {
    uint8_t * inits = async_liveness_async_live_load_ptr(e, 40);
    int32_t nf = async_liveness_async_live_load_i32(e, 48);
    int32_t fi = 0;
    while ((fi < nf)) {
      if ((expr_has_await(async_liveness_async_live_ptr_at(inits, fi)) !=0)) {
        return 1;
      }
      (void)((fi = (fi + 1)));
    }
    return 0;
  }
  if ((k ==46)) {
    uint8_t * elems = async_liveness_async_live_load_ptr(e, 24);
    int32_t ne = async_liveness_async_live_load_i32(e, 32);
    int32_t ei = 0;
    while ((ei < ne)) {
      if ((expr_has_await(async_liveness_async_live_ptr_at(elems, ei)) !=0)) {
        return 1;
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  if ((k ==43)) {
    if ((expr_has_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * arms = async_liveness_async_live_load_ptr(e, 32);
    int32_t na = async_liveness_async_live_load_i32(e, 40);
    int32_t ai = 0;
    while ((ai < na)) {
      if ((arms ==0)) {
        return 0;
      }
      uint8_t * arm = (arms + (ai * 88));
      if ((expr_has_await(async_liveness_async_live_load_ptr(arm, 80)) !=0)) {
        return 1;
      }
      (void)((ai = (ai + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t expr_count_await(uint8_t * e) {
  if ((e ==0)) {
    return 0;
  }
  int32_t k = async_liveness_async_live_expr_kind(e);
  if ((k ==54)) {
    return (1 + expr_count_await(async_liveness_async_live_load_ptr(e, 24)));
  }
  if ((async_liveness_async_live_is_binop_kind(k) !=0)) {
    return (expr_count_await(async_liveness_async_live_load_ptr(e, 24)) + expr_count_await(async_liveness_async_live_load_ptr(e, 32)));
  }
  if ((async_liveness_async_live_is_unary_kind(k) !=0)) {
    return expr_count_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==53)) {
    return expr_count_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==25)) {
    int32_t n = (expr_count_await(async_liveness_async_live_load_ptr(e, 24)) + expr_count_await(async_liveness_async_live_load_ptr(e, 32)));
    uint8_t * el = async_liveness_async_live_load_ptr(e, 40);
    if ((el !=0)) {
      (void)((n = (n + expr_count_await(el))));
    }
    return n;
  }
  if ((k ==27)) {
    int32_t n2 = (expr_count_await(async_liveness_async_live_load_ptr(e, 24)) + expr_count_await(async_liveness_async_live_load_ptr(e, 32)));
    uint8_t * el2 = async_liveness_async_live_load_ptr(e, 40);
    if ((el2 !=0)) {
      (void)((n2 = (n2 + expr_count_await(el2))));
    }
    return n2;
  }
  if ((k ==26)) {
    return block_count_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==44)) {
    return expr_count_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==47)) {
    return (expr_count_await(async_liveness_async_live_load_ptr(e, 24)) + expr_count_await(async_liveness_async_live_load_ptr(e, 32)));
  }
  if ((k ==48)) {
    int32_t n3 = expr_count_await(async_liveness_async_live_load_ptr(e, 24));
    uint8_t * args = async_liveness_async_live_load_ptr(e, 32);
    int32_t nn = async_liveness_async_live_load_i32(e, 40);
    int32_t i = 0;
    while ((i < nn)) {
      (void)((n3 = (n3 + expr_count_await(async_liveness_async_live_ptr_at(args, i)))));
      (void)((i = (i + 1)));
    }
    return n3;
  }
  if ((k ==49)) {
    int32_t n4 = expr_count_await(async_liveness_async_live_load_ptr(e, 24));
    uint8_t * args2 = async_liveness_async_live_load_ptr(e, 40);
    int32_t nn2 = async_liveness_async_live_load_i32(e, 48);
    int32_t j = 0;
    while ((j < nn2)) {
      (void)((n4 = (n4 + expr_count_await(async_liveness_async_live_ptr_at(args2, j)))));
      (void)((j = (j + 1)));
    }
    return n4;
  }
  if ((k ==45)) {
    int32_t n5 = 0;
    uint8_t * inits = async_liveness_async_live_load_ptr(e, 40);
    int32_t nf = async_liveness_async_live_load_i32(e, 48);
    int32_t fi = 0;
    while ((fi < nf)) {
      (void)((n5 = (n5 + expr_count_await(async_liveness_async_live_ptr_at(inits, fi)))));
      (void)((fi = (fi + 1)));
    }
    return n5;
  }
  if ((k ==46)) {
    int32_t n6 = 0;
    uint8_t * elems = async_liveness_async_live_load_ptr(e, 24);
    int32_t ne = async_liveness_async_live_load_i32(e, 32);
    int32_t ei = 0;
    while ((ei < ne)) {
      (void)((n6 = (n6 + expr_count_await(async_liveness_async_live_ptr_at(elems, ei)))));
      (void)((ei = (ei + 1)));
    }
    return n6;
  }
  if ((k ==43)) {
    int32_t n7 = expr_count_await(async_liveness_async_live_load_ptr(e, 24));
    uint8_t * arms = async_liveness_async_live_load_ptr(e, 32);
    int32_t na = async_liveness_async_live_load_i32(e, 40);
    int32_t ai = 0;
    while ((ai < na)) {
      if ((arms ==0)) {
        return n7;
      }
      uint8_t * arm = (arms + (ai * 88));
      (void)((n7 = (n7 + expr_count_await(async_liveness_async_live_load_ptr(arm, 80)))));
      (void)((ai = (ai + 1)));
    }
    return n7;
  }
  return 0;
}
int32_t block_count_await(uint8_t * b) {
  if ((b ==0)) {
    return 0;
  }
  int32_t n = 0;
  int32_t nlets = async_liveness_async_live_load_i32(b, 24);
  uint8_t * lets = async_liveness_async_live_load_ptr(b, 16);
  int32_t i = 0;
  while ((i < nlets)) {
    if ((lets !=0)) {
      uint8_t * ld = (lets + (i * 48));
      uint8_t * init = async_liveness_async_live_load_ptr(ld, 16);
      if ((init !=0)) {
        (void)((n = (n + expr_count_await(init))));
      }
    }
    (void)((i = (i + 1)));
  }
  int32_t nst = async_liveness_async_live_load_i32(b, 104);
  uint8_t * stmts = async_liveness_async_live_load_ptr(b, 96);
  int32_t j = 0;
  while ((j < nst)) {
    (void)((n = (n + expr_count_await(async_liveness_async_live_ptr_at(stmts, j)))));
    (void)((j = (j + 1)));
  }
  uint8_t * fin = async_liveness_async_live_load_ptr(b, 112);
  if ((fin !=0)) {
    (void)((n = (n + expr_count_await(fin))));
  }
  return n;
}
int32_t block_has_await(uint8_t * b) {
  if ((block_count_await(b) > 0)) {
    return 1;
  }
  return 0;
}
int32_t expr_has_io_read_await(uint8_t * e) {
  if ((e ==0)) {
    return 0;
  }
  int32_t k = async_liveness_async_live_expr_kind(e);
  if ((k ==54)) {
    uint8_t * op = async_liveness_async_live_load_ptr(e, 24);
    if ((op !=0)) {
      if ((async_liveness_async_live_expr_kind(op) ==48)) {
        uint8_t * cal = async_liveness_async_live_load_ptr(op, 72);
        if ((cal !=0)) {
          if ((async_liveness_callee_is_io_read(cal) !=0)) {
            return 1;
          }
        }
      }
    }
  }
  if ((expr_has_await(e) ==0)) {
    return 0;
  }
  if ((k ==54)) {
    return expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((async_liveness_async_live_is_binop_kind(k) !=0)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    return expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 32));
  }
  if ((async_liveness_async_live_is_unary_kind(k) !=0)) {
    return expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==53)) {
    return expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==25)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    uint8_t * el = async_liveness_async_live_load_ptr(e, 40);
    if ((el !=0)) {
      if ((expr_has_io_read_await(el) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==27)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    uint8_t * el2 = async_liveness_async_live_load_ptr(e, 40);
    if ((el2 !=0)) {
      if ((expr_has_io_read_await(el2) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==26)) {
    return block_has_io_read_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==44)) {
    return expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==47)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    return expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 32));
  }
  if ((k ==48)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * args = async_liveness_async_live_load_ptr(e, 32);
    int32_t n = async_liveness_async_live_load_i32(e, 40);
    int32_t i = 0;
    while ((i < n)) {
      if ((expr_has_io_read_await(async_liveness_async_live_ptr_at(args, i)) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  if ((k ==49)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * args2 = async_liveness_async_live_load_ptr(e, 40);
    int32_t n2 = async_liveness_async_live_load_i32(e, 48);
    int32_t j = 0;
    while ((j < n2)) {
      if ((expr_has_io_read_await(async_liveness_async_live_ptr_at(args2, j)) !=0)) {
        return 1;
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
  if ((k ==45)) {
    uint8_t * inits = async_liveness_async_live_load_ptr(e, 40);
    int32_t nf = async_liveness_async_live_load_i32(e, 48);
    int32_t fi = 0;
    while ((fi < nf)) {
      if ((expr_has_io_read_await(async_liveness_async_live_ptr_at(inits, fi)) !=0)) {
        return 1;
      }
      (void)((fi = (fi + 1)));
    }
    return 0;
  }
  if ((k ==46)) {
    uint8_t * elems = async_liveness_async_live_load_ptr(e, 24);
    int32_t ne = async_liveness_async_live_load_i32(e, 32);
    int32_t ei = 0;
    while ((ei < ne)) {
      if ((expr_has_io_read_await(async_liveness_async_live_ptr_at(elems, ei)) !=0)) {
        return 1;
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  if ((k ==43)) {
    if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * arms = async_liveness_async_live_load_ptr(e, 32);
    int32_t na = async_liveness_async_live_load_i32(e, 40);
    int32_t ai = 0;
    while ((ai < na)) {
      if ((arms ==0)) {
        return 0;
      }
      uint8_t * arm = (arms + (ai * 88));
      if ((expr_has_io_read_await(async_liveness_async_live_load_ptr(arm, 80)) !=0)) {
        return 1;
      }
      (void)((ai = (ai + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t expr_has_io_write_await(uint8_t * e) {
  if ((e ==0)) {
    return 0;
  }
  int32_t k = async_liveness_async_live_expr_kind(e);
  if ((k ==54)) {
    uint8_t * op = async_liveness_async_live_load_ptr(e, 24);
    if ((op !=0)) {
      if ((async_liveness_async_live_expr_kind(op) ==48)) {
        uint8_t * cal = async_liveness_async_live_load_ptr(op, 72);
        if ((cal !=0)) {
          if ((async_liveness_callee_is_io_write(cal) !=0)) {
            return 1;
          }
        }
      }
    }
  }
  if ((expr_has_await(e) ==0)) {
    return 0;
  }
  if ((k ==54)) {
    return expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((async_liveness_async_live_is_binop_kind(k) !=0)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    return expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 32));
  }
  if ((async_liveness_async_live_is_unary_kind(k) !=0)) {
    return expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==53)) {
    return expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==25)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    uint8_t * el = async_liveness_async_live_load_ptr(e, 40);
    if ((el !=0)) {
      if ((expr_has_io_write_await(el) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==27)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 32)) !=0)) {
      return 1;
    }
    uint8_t * el2 = async_liveness_async_live_load_ptr(e, 40);
    if ((el2 !=0)) {
      if ((expr_has_io_write_await(el2) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==26)) {
    return block_has_io_write_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==44)) {
    return expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24));
  }
  if ((k ==47)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    return expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 32));
  }
  if ((k ==48)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * args = async_liveness_async_live_load_ptr(e, 32);
    int32_t n = async_liveness_async_live_load_i32(e, 40);
    int32_t i = 0;
    while ((i < n)) {
      if ((expr_has_io_write_await(async_liveness_async_live_ptr_at(args, i)) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  if ((k ==49)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * args2 = async_liveness_async_live_load_ptr(e, 40);
    int32_t n2 = async_liveness_async_live_load_i32(e, 48);
    int32_t j = 0;
    while ((j < n2)) {
      if ((expr_has_io_write_await(async_liveness_async_live_ptr_at(args2, j)) !=0)) {
        return 1;
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
  if ((k ==45)) {
    uint8_t * inits = async_liveness_async_live_load_ptr(e, 40);
    int32_t nf = async_liveness_async_live_load_i32(e, 48);
    int32_t fi = 0;
    while ((fi < nf)) {
      if ((expr_has_io_write_await(async_liveness_async_live_ptr_at(inits, fi)) !=0)) {
        return 1;
      }
      (void)((fi = (fi + 1)));
    }
    return 0;
  }
  if ((k ==46)) {
    uint8_t * elems = async_liveness_async_live_load_ptr(e, 24);
    int32_t ne = async_liveness_async_live_load_i32(e, 32);
    int32_t ei = 0;
    while ((ei < ne)) {
      if ((expr_has_io_write_await(async_liveness_async_live_ptr_at(elems, ei)) !=0)) {
        return 1;
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  if ((k ==43)) {
    if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(e, 24)) !=0)) {
      return 1;
    }
    uint8_t * arms = async_liveness_async_live_load_ptr(e, 32);
    int32_t na = async_liveness_async_live_load_i32(e, 40);
    int32_t ai = 0;
    while ((ai < na)) {
      if ((arms ==0)) {
        return 0;
      }
      uint8_t * arm = (arms + (ai * 88));
      if ((expr_has_io_write_await(async_liveness_async_live_load_ptr(arm, 80)) !=0)) {
        return 1;
      }
      (void)((ai = (ai + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t block_has_io_read_await(uint8_t * b) {
  if ((b ==0)) {
    return 0;
  }
  int32_t nlets = async_liveness_async_live_load_i32(b, 24);
  uint8_t * lets = async_liveness_async_live_load_ptr(b, 16);
  int32_t i = 0;
  while ((i < nlets)) {
    if ((lets !=0)) {
      uint8_t * ld = (lets + (i * 48));
      uint8_t * init = async_liveness_async_live_load_ptr(ld, 16);
      if ((init !=0)) {
        if ((expr_has_io_read_await(init) !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  int32_t nst = async_liveness_async_live_load_i32(b, 104);
  uint8_t * stmts = async_liveness_async_live_load_ptr(b, 96);
  int32_t j = 0;
  while ((j < nst)) {
    if ((expr_has_io_read_await(async_liveness_async_live_ptr_at(stmts, j)) !=0)) {
      return 1;
    }
    (void)((j = (j + 1)));
  }
  uint8_t * fin = async_liveness_async_live_load_ptr(b, 112);
  if ((fin !=0)) {
    if ((expr_has_io_read_await(fin) !=0)) {
      return 1;
    }
  }
  return 0;
}
int32_t block_has_io_write_await(uint8_t * b) {
  if ((b ==0)) {
    return 0;
  }
  int32_t nlets = async_liveness_async_live_load_i32(b, 24);
  uint8_t * lets = async_liveness_async_live_load_ptr(b, 16);
  int32_t i = 0;
  while ((i < nlets)) {
    if ((lets !=0)) {
      uint8_t * ld = (lets + (i * 48));
      uint8_t * init = async_liveness_async_live_load_ptr(ld, 16);
      if ((init !=0)) {
        if ((expr_has_io_write_await(init) !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  int32_t nst = async_liveness_async_live_load_i32(b, 104);
  uint8_t * stmts = async_liveness_async_live_load_ptr(b, 96);
  int32_t j = 0;
  while ((j < nst)) {
    if ((expr_has_io_write_await(async_liveness_async_live_ptr_at(stmts, j)) !=0)) {
      return 1;
    }
    (void)((j = (j + 1)));
  }
  uint8_t * fin = async_liveness_async_live_load_ptr(b, 112);
  if ((fin !=0)) {
    if ((expr_has_io_write_await(fin) !=0)) {
      return 1;
    }
  }
  return 0;
}
int32_t async_liveness_async_live_cstr_eq(uint8_t * a, uint8_t * b) {
  if ((a ==0)) {
    return 0;
  }
  if ((b ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 4096)) {
    uint8_t ca = (a)[i];
    uint8_t cb = (b)[i];
    if ((ca !=cb)) {
      return 0;
    }
    if ((ca ==0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
void async_liveness_async_live_cstr_copy64(uint8_t * dst, uint8_t * src) {
  if ((dst ==0)) {
    return;
  }
  if ((src ==0)) {
    (void)(((dst)[0] = 0));
    return;
  }
  int32_t j = 0;
  while ((j < 63)) {
    uint8_t c = (src)[j];
    if ((c ==0)) {
      break;
    }
    (void)(((dst)[j] = c));
    (void)((j = (j + 1)));
  }
  (void)(((dst)[j] = 0));
}
uint8_t * async_liveness_async_live_def_row(uint8_t * defs, int32_t i) {
  if ((defs ==0)) {
    return ((uint8_t *)(0));
  }
  uint8_t * q = defs;
  int32_t off = (i * 64);
  int32_t k = 0;
  while ((k < off)) {
    (void)((q = (q + 1)));
    (void)((k = (k + 1)));
  }
  return q;
}
uint8_t * async_liveness_async_live_load_def_name(uint8_t * defs, int32_t i) {
  if ((defs ==0)) {
    return ((uint8_t *)(0));
  }
  int32_t off = (i * 8);
  return async_liveness_async_live_load_ptr(defs, off);
}
int32_t expr_refs_var(uint8_t * e, uint8_t * name) {
  if ((e ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if (((name)[0] ==0)) {
    return 0;
  }
  int32_t k = async_liveness_async_live_expr_kind(e);
  if ((k ==3)) {
    uint8_t * vn = async_liveness_async_live_load_ptr(e, 24);
    if ((vn !=0)) {
      if ((async_liveness_async_live_cstr_eq(vn, name) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((async_liveness_async_live_is_binop_kind(k) !=0)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    return expr_refs_var(async_liveness_async_live_load_ptr(e, 32), name);
  }
  if ((async_liveness_async_live_is_unary_kind(k) !=0)) {
    return expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name);
  }
  if ((k ==54)) {
    return expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name);
  }
  if ((k ==53)) {
    return expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name);
  }
  if ((k ==25)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 32), name) !=0)) {
      return 1;
    }
    uint8_t * el = async_liveness_async_live_load_ptr(e, 40);
    if ((el !=0)) {
      if ((expr_refs_var(el, name) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==27)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 32), name) !=0)) {
      return 1;
    }
    uint8_t * el2 = async_liveness_async_live_load_ptr(e, 40);
    if ((el2 !=0)) {
      if ((expr_refs_var(el2, name) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==26)) {
    return block_refs_var(async_liveness_async_live_load_ptr(e, 24), name);
  }
  if ((k ==44)) {
    return expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name);
  }
  if ((k ==47)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    return expr_refs_var(async_liveness_async_live_load_ptr(e, 32), name);
  }
  if ((k ==48)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    uint8_t * args = async_liveness_async_live_load_ptr(e, 32);
    int32_t n = async_liveness_async_live_load_i32(e, 40);
    int32_t i = 0;
    while ((i < n)) {
      if ((expr_refs_var(async_liveness_async_live_ptr_at(args, i), name) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  if ((k ==49)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    uint8_t * args2 = async_liveness_async_live_load_ptr(e, 40);
    int32_t n2 = async_liveness_async_live_load_i32(e, 48);
    int32_t j = 0;
    while ((j < n2)) {
      if ((expr_refs_var(async_liveness_async_live_ptr_at(args2, j), name) !=0)) {
        return 1;
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
  if ((k ==45)) {
    uint8_t * inits = async_liveness_async_live_load_ptr(e, 40);
    int32_t nf = async_liveness_async_live_load_i32(e, 48);
    int32_t fi = 0;
    while ((fi < nf)) {
      if ((expr_refs_var(async_liveness_async_live_ptr_at(inits, fi), name) !=0)) {
        return 1;
      }
      (void)((fi = (fi + 1)));
    }
    return 0;
  }
  if ((k ==46)) {
    uint8_t * elems = async_liveness_async_live_load_ptr(e, 24);
    int32_t ne = async_liveness_async_live_load_i32(e, 32);
    int32_t ei = 0;
    while ((ei < ne)) {
      if ((expr_refs_var(async_liveness_async_live_ptr_at(elems, ei), name) !=0)) {
        return 1;
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  if ((k ==43)) {
    if ((expr_refs_var(async_liveness_async_live_load_ptr(e, 24), name) !=0)) {
      return 1;
    }
    uint8_t * arms = async_liveness_async_live_load_ptr(e, 32);
    int32_t na = async_liveness_async_live_load_i32(e, 40);
    int32_t ai = 0;
    while ((ai < na)) {
      if ((arms ==0)) {
        return 0;
      }
      uint8_t * arm = (arms + (ai * 88));
      if ((expr_refs_var(async_liveness_async_live_load_ptr(arm, 80), name) !=0)) {
        return 1;
      }
      (void)((ai = (ai + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t block_refs_var(uint8_t * b, uint8_t * name) {
  if ((b ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  int32_t nlets = async_liveness_async_live_load_i32(b, 24);
  uint8_t * lets = async_liveness_async_live_load_ptr(b, 16);
  int32_t i = 0;
  while ((i < nlets)) {
    if ((lets !=0)) {
      uint8_t * ld = (lets + (i * 48));
      uint8_t * init = async_liveness_async_live_load_ptr(ld, 16);
      if ((init !=0)) {
        if ((expr_refs_var(init, name) !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  int32_t nst = async_liveness_async_live_load_i32(b, 104);
  uint8_t * stmts = async_liveness_async_live_load_ptr(b, 96);
  int32_t j = 0;
  while ((j < nst)) {
    if ((expr_refs_var(async_liveness_async_live_ptr_at(stmts, j), name) !=0)) {
      return 1;
    }
    (void)((j = (j + 1)));
  }
  uint8_t * fin = async_liveness_async_live_load_ptr(b, 112);
  if ((fin !=0)) {
    if ((expr_refs_var(fin, name) !=0)) {
      return 1;
    }
  }
  return 0;
}
int32_t block_rest_refs_var(uint8_t * b, int32_t from_exclusive, uint8_t * name) {
  if ((b ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if (((name)[0] ==0)) {
    return 0;
  }
  int32_t norder = async_liveness_async_live_load_i32(b, 120);
  if ((norder > 0)) {
    int32_t nlets = async_liveness_async_live_load_i32(b, 24);
    uint8_t * lets = async_liveness_async_live_load_ptr(b, 16);
    int32_t nst = async_liveness_async_live_load_i32(b, 104);
    uint8_t * stmts = async_liveness_async_live_load_ptr(b, 96);
    int32_t si = (from_exclusive + 1);
    while ((si < norder)) {
      int32_t base = (172 + (si * 8));
      int32_t sk = ((int32_t)((b)[base]));
      int32_t idx = async_liveness_async_live_load_i32(b, (base + 4));
      if ((sk ==1)) {
        if ((lets !=0)) {
          if ((idx >=0)) {
            if ((idx < nlets)) {
              uint8_t * ld = (lets + (idx * 48));
              uint8_t * init = async_liveness_async_live_load_ptr(ld, 16);
              if ((init !=0)) {
                if ((expr_refs_var(init, name) !=0)) {
                  return 1;
                }
              }
            }
          }
        }
      } else {
        if ((sk ==2)) {
          if ((stmts !=0)) {
            if ((idx >=0)) {
              if ((idx < nst)) {
                if ((expr_refs_var(async_liveness_async_live_ptr_at(stmts, idx), name) !=0)) {
                  return 1;
                }
              }
            }
          }
        }
      }
      (void)((si = (si + 1)));
    }
    uint8_t * fin = async_liveness_async_live_load_ptr(b, 112);
    if ((fin !=0)) {
      if ((expr_refs_var(fin, name) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  uint8_t * fin2 = async_liveness_async_live_load_ptr(b, 112);
  if ((fin2 !=0)) {
    if ((expr_refs_var(fin2, name) !=0)) {
      return 1;
    }
  }
  return 0;
}
int32_t async_liveness_frame_live_load_n(uint8_t * out) {
  if ((out ==0)) {
    return 0;
  }
  uint8_t * q = out;
  int32_t i = 0;
  while ((i < 4096)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  int32_t m = 256;
  int32_t a = ((int32_t)((q)[0]));
  (void)((a = (a + (((int32_t)((q)[1])) * m))));
  (void)((a = (a + ((((int32_t)((q)[2])) * m) * m))));
  (void)((a = (a + (((((int32_t)((q)[3])) * m) * m) * m))));
  return a;
}
void async_liveness_frame_live_store_n(uint8_t * out, int32_t n) {
  if ((out ==0)) {
    return;
  }
  uint8_t * q = out;
  int32_t i = 0;
  while ((i < 4096)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  int32_t a = n;
  int32_t m = 256;
  if ((a < 0)) {
    (void)((a = 0));
  }
  (void)(((q)[0] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((q)[1] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((q)[2] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((q)[3] = ((uint8_t)((a % m)))));
}
uint8_t * async_liveness_frame_live_row_ptr(uint8_t * out, int32_t idx) {
  if ((out ==0)) {
    return ((uint8_t *)(0));
  }
  uint8_t * q = out;
  int32_t off = (idx * 64);
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  return q;
}
int32_t async_liveness_frame_live_name_eq(uint8_t * row, uint8_t * name) {
  if ((row ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 64)) {
    uint8_t a = (row)[i];
    uint8_t b = (name)[i];
    if ((a !=b)) {
      return 0;
    }
    if ((a ==0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
void frame_live_add(uint8_t * out, uint8_t * name) {
  if ((out ==0)) {
    return;
  }
  if ((name ==0)) {
    return;
  }
  if (((name)[0] ==0)) {
    return;
  }
  int32_t n = async_liveness_frame_live_load_n(out);
  if ((n < 0)) {
    (void)((n = 0));
  }
  if ((n > 64)) {
    (void)((n = 64));
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * row = async_liveness_frame_live_row_ptr(out, i);
    if ((async_liveness_frame_live_name_eq(row, name) !=0)) {
      return;
    }
    (void)((i = (i + 1)));
  }
  if ((n >=64)) {
    return;
  }
  uint8_t * dst = async_liveness_frame_live_row_ptr(out, n);
  if ((dst ==0)) {
    return;
  }
  int32_t j = 0;
  while ((j < 63)) {
    uint8_t c = (name)[j];
    if ((c ==0)) {
      break;
    }
    (void)(((dst)[j] = c));
    (void)((j = (j + 1)));
  }
  (void)(((dst)[j] = 0));
  (void)(async_liveness_frame_live_store_n(out, (n + 1)));
}
void frame_live_at_await(uint8_t * b, int32_t idx, uint8_t * defs, int32_t nd, uint8_t * out) {
  if ((nd <=0)) {
    return;
  }
  if ((defs ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  int32_t i = 0;
  while ((i < nd)) {
    uint8_t * name = async_liveness_async_live_load_def_name(defs, i);
    if ((name !=0)) {
      if ((block_rest_refs_var(b, idx, name) !=0)) {
        (void)(frame_live_add(out, name));
      }
    }
    (void)((i = (i + 1)));
  }
}
void async_liveness_async_live_analyze_at_await(uint8_t * b, int32_t si, uint8_t * defs, int32_t n_def, uint8_t * frame) {
  if ((n_def <=0)) {
    return;
  }
  if ((defs ==0)) {
    return;
  }
  if ((frame ==0)) {
    return;
  }
  int32_t i = 0;
  while ((i < n_def)) {
    uint8_t * name = async_liveness_async_live_def_row(defs, i);
    if ((name !=0)) {
      if (((name)[0] !=0)) {
        if ((block_rest_refs_var(b, si, name) !=0)) {
          (void)(frame_live_add(frame, name));
        }
      }
    }
    (void)((i = (i + 1)));
  }
}
void analyze_block_linear(uint8_t * b, uint8_t * prefix, int32_t n_prefix, uint8_t * frame) {
  if ((b ==0)) {
    return;
  }
  if ((frame ==0)) {
    return;
  }
  uint8_t * def_names = 0;
  (void)((def_names = malloc(4096)));
  if ((def_names ==0)) {
    return;
  }
  int32_t n_def = 0;
  int32_t pi = 0;
  while ((pi < n_prefix)) {
    if ((n_def >=64)) {
      break;
    }
    uint8_t * pn = async_liveness_async_live_load_def_name(prefix, pi);
    if ((pn !=0)) {
      if (((pn)[0] !=0)) {
        (void)(async_liveness_async_live_cstr_copy64(async_liveness_async_live_def_row(def_names, n_def), pn));
        (void)((n_def = (n_def + 1)));
      }
    }
    (void)((pi = (pi + 1)));
  }
  int32_t norder = async_liveness_async_live_load_i32(b, 120);
  if ((norder > 0)) {
    int32_t nlets = async_liveness_async_live_load_i32(b, 24);
    uint8_t * lets = async_liveness_async_live_load_ptr(b, 16);
    int32_t nst = async_liveness_async_live_load_i32(b, 104);
    uint8_t * stmts = async_liveness_async_live_load_ptr(b, 96);
    int32_t si = 0;
    while ((si < norder)) {
      int32_t base = (172 + (si * 8));
      int32_t sk = ((int32_t)((b)[base]));
      int32_t idx = async_liveness_async_live_load_i32(b, (base + 4));
      if ((sk ==1)) {
        if ((lets !=0)) {
          if ((idx >=0)) {
            if ((idx < nlets)) {
              uint8_t * ld = (lets + (idx * 48));
              uint8_t * init = async_liveness_async_live_load_ptr(ld, 16);
              if ((init !=0)) {
                if ((expr_has_await(init) !=0)) {
                  (void)(async_liveness_async_live_analyze_at_await(b, si, def_names, n_def, frame));
                }
              }
              if ((n_def < 64)) {
                uint8_t * lname = async_liveness_async_live_load_ptr(ld, 0);
                if ((lname !=0)) {
                  if (((lname)[0] !=0)) {
                    (void)(async_liveness_async_live_cstr_copy64(async_liveness_async_live_def_row(def_names, n_def), lname));
                    (void)((n_def = (n_def + 1)));
                  }
                }
              }
            }
          }
        }
      } else {
        if ((sk ==2)) {
          if ((stmts !=0)) {
            if ((idx >=0)) {
              if ((idx < nst)) {
                uint8_t * ex = async_liveness_async_live_ptr_at(stmts, idx);
                if ((ex !=0)) {
                  if ((expr_has_await(ex) !=0)) {
                    (void)(async_liveness_async_live_analyze_at_await(b, si, def_names, n_def, frame));
                  }
                }
              }
            }
          }
        }
      }
      (void)((si = (si + 1)));
    }
    uint8_t * fin = async_liveness_async_live_load_ptr(b, 112);
    if ((fin !=0)) {
      if ((expr_has_await(fin) !=0)) {
        (void)(async_liveness_async_live_analyze_at_await(b, (norder - 1), def_names, n_def, frame));
      }
    }
    (void)(free(def_names));
    return;
  }
  uint8_t * fin2 = async_liveness_async_live_load_ptr(b, 112);
  if ((fin2 !=0)) {
    if ((expr_has_await(fin2) !=0)) {
      (void)(async_liveness_async_live_analyze_at_await(b, -1, def_names, n_def, frame));
    }
  }
  (void)(free(def_names));
}
void frame_mangle_ident(uint8_t * in_name, uint8_t * out, int32_t cap) {
  if ((out ==0)) {
    return;
  }
  if ((cap <=0)) {
    return;
  }
  if ((in_name ==0)) {
    if ((cap > 2)) {
      (void)(((out)[0] = 102));
      (void)(((out)[1] = 110));
      (void)(((out)[2] = 0));
    } else {
      (void)(((out)[0] = 0));
    }
    return;
  }
  if (((in_name)[0] ==0)) {
    if ((cap > 2)) {
      (void)(((out)[0] = 102));
      (void)(((out)[1] = 110));
      (void)(((out)[2] = 0));
    } else {
      (void)(((out)[0] = 0));
    }
    return;
  }
  int32_t j = 0;
  int32_t i = 0;
  while ((i < 4096)) {
    if (((in_name)[i] ==0)) {
      break;
    }
    if (((j + 1) >=cap)) {
      break;
    }
    uint8_t c = (in_name)[i];
    int32_t ok = 0;
    if ((c >=97)) {
      if ((c <=122)) {
        (void)((ok = 1));
      }
    }
    if ((c >=65)) {
      if ((c <=90)) {
        (void)((ok = 1));
      }
    }
    if ((c >=48)) {
      if ((c <=57)) {
        (void)((ok = 1));
      }
    }
    if ((c ==95)) {
      (void)((ok = 1));
    }
    if ((ok !=0)) {
      (void)(((out)[j] = c));
    } else {
      (void)(((out)[j] = 95));
    }
    (void)((j = (j + 1)));
    (void)((i = (i + 1)));
  }
  (void)(((out)[j] = 0));
}
void frame_build_tag(uint8_t * f, uint8_t * out, int32_t cap) {
  if ((out ==0)) {
    return;
  }
  if ((cap <=1)) {
    return;
  }
  uint8_t * name = 0;
  if ((f !=0)) {
    (void)((name = async_liveness_async_live_load_func_name(f)));
  }
  if ((name ==0)) {
    (void)((name = ((uint8_t *)"\x66\x6e")));
  } else {
    if (((name)[0] ==0)) {
      (void)((name = ((uint8_t *)"\x66\x6e")));
    }
  }
  uint8_t m[64] = {};
  (void)(frame_mangle_ident(name, &((m)[0]), 64));
  uint8_t * pref = ((uint8_t *)"\x5f\x5f\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x66\x72\x61\x6d\x65\x5f");
  int32_t j = 0;
  int32_t i = 0;
  while (((j + 1) < cap)) {
    if (((pref)[i] ==0)) {
      break;
    }
    (void)(((out)[j] = (pref)[i]));
    (void)((j = (j + 1)));
    (void)((i = (i + 1)));
  }
  (void)((i = 0));
  while (((j + 1) < cap)) {
    if (((m)[i] ==0)) {
      break;
    }
    (void)(((out)[j] = (m)[i]));
    (void)((j = (j + 1)));
    (void)((i = (i + 1)));
  }
  (void)(((out)[j] = 0));
}
int32_t live_name_cmp(uint8_t * a, uint8_t * b) {
  if ((a ==0)) {
    if ((b ==0)) {
      return 0;
    }
    return -1;
  }
  if ((b ==0)) {
    return 1;
  }
  int32_t i = 0;
  while ((i < 4096)) {
    uint8_t ca = (a)[i];
    uint8_t cb = (b)[i];
    if ((ca !=cb)) {
      return (((int32_t)(ca)) - ((int32_t)(cb)));
    }
    if ((ca ==0)) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
