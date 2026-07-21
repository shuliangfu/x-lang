/* seeds/async_liveness_surface.from_x.c
 * R2 pure surface + Cap residual pure (type/layout) — isomorphic with src/async/async_liveness.x
 * Product cold path still cc seeds/async_liveness.from_x.c (no FROM_X) for full C + Cap residual.
 * Hybrid/PREFER: g05_try_x_to_o(async_liveness.x) + rest (-DSHUX_ASYNC_LIVENESS_FROM_X).
 * R2: full.x eats pure helpers (await walk / live frame / mangle/tag) + Cap residual pure
 *   (lookup/type/size/layout/has_await/needs_cps/analyze/module_struct); FROM_X omits those C bodies.
 * Cap residual (stay seed C always): emit_* (FILE* fprintf).
 * Prove: full.x vs this seed → nm IDENTICAL (pure surface)
 * Regen: ./shux -E ... src/async/async_liveness.x | filter DBG + polish prologue
 * NOTE: use ./shux (not shux-x). Stack: analyze_block_linear uses malloc(4096) not u8[4096];
 *   layout temps use malloc(4196) for AsyncFrameLayout.
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
extern void async_liveness_async_live_store_i32(uint8_t * p, int32_t off, int32_t v);
extern void async_liveness_async_live_store_ptr(uint8_t * p, int32_t off, uint8_t * v);
extern void async_liveness_async_live_cstr_copy_cap(uint8_t * dst, uint8_t * src, int32_t cap);
extern int32_t async_liveness_async_live_cstr_has_prefix(uint8_t * a, uint8_t * pref, int32_t plen);
extern void async_live_sort_frame_names(uint8_t * out);
extern uint8_t * async_liveness_lookup_var_type(uint8_t * f, uint8_t * name);
extern void async_liveness_type_to_c_buf(uint8_t * ty, uint8_t * buf, int32_t cap);
extern int32_t async_liveness_type_size_bytes_module(uint8_t * ty, uint8_t * m);
extern int32_t async_liveness_func_has_await(uint8_t * f);
extern int32_t async_liveness_expr_has_await(uint8_t * e);
extern int32_t async_liveness_layout_func_module(uint8_t * f, uint8_t * m, uint8_t * out);
extern int32_t async_liveness_layout_func(uint8_t * f, uint8_t * out);
extern int32_t async_liveness_func_needs_cps_frame(uint8_t * f);
extern int32_t async_liveness_module_struct_in_frame(uint8_t * m, uint8_t * struct_name);
extern int32_t async_liveness_analyze_func(uint8_t * f, uint8_t * out);
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
void async_liveness_async_live_store_i32(uint8_t * p, int32_t off, int32_t v) {
  if ((p ==0)) {
    return;
  }
  if ((off < 0)) {
    return;
  }
  uint32_t u = ((uint32_t)(v));
  (void)(((p)[off] = ((uint8_t)((u & 255)))));
  (void)(((p)[(off + 1)] = ((uint8_t)(((u / 256) & 255)))));
  (void)(((p)[(off + 2)] = ((uint8_t)(((u / 65536) & 255)))));
  (void)(((p)[(off + 3)] = ((uint8_t)(((u / 16777216) & 255)))));
}
void async_liveness_async_live_store_ptr(uint8_t * p, int32_t off, uint8_t * v) {
  if ((p ==0)) {
    return;
  }
  if ((off < 0)) {
    return;
  }
  size_t a = ((size_t)(v));
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  (void)(((p)[off] = ((uint8_t)((a % m)))));
  (void)(((p)[(off + 1)] = ((uint8_t)(((a / m) % m)))));
  (void)(((p)[(off + 2)] = ((uint8_t)(((a / m2) % m)))));
  (void)(((p)[(off + 3)] = ((uint8_t)(((a / (m2 * m)) % m)))));
  (void)(((p)[(off + 4)] = ((uint8_t)(((a / m4) % m)))));
  (void)(((p)[(off + 5)] = ((uint8_t)(((a / (m4 * m)) % m)))));
  (void)(((p)[(off + 6)] = ((uint8_t)(((a / (m4 * m2)) % m)))));
  (void)(((p)[(off + 7)] = ((uint8_t)(((a / ((m4 * m2) * m)) % m)))));
}
void async_liveness_async_live_cstr_copy_cap(uint8_t * dst, uint8_t * src, int32_t cap) {
  if ((dst ==0)) {
    return;
  }
  if ((cap <=0)) {
    return;
  }
  if ((src ==0)) {
    (void)(((dst)[0] = 0));
    return;
  }
  int32_t i = 0;
  while (((i + 1) < cap)) {
    uint8_t c = (src)[i];
    if ((c ==0)) {
      break;
    }
    (void)(((dst)[i] = c));
    (void)((i = (i + 1)));
  }
  (void)(((dst)[i] = 0));
}
int32_t async_liveness_async_live_cstr_has_prefix(uint8_t * a, uint8_t * pref, int32_t plen) {
  if ((a ==0)) {
    return 0;
  }
  if ((pref ==0)) {
    return 0;
  }
  if ((plen <=0)) {
    return 1;
  }
  int32_t i = 0;
  while ((i < plen)) {
    if (((a)[i] !=(pref)[i])) {
      return 0;
    }
    if (((a)[i] ==0)) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
void async_live_sort_frame_names(uint8_t * out) {
  if ((out ==0)) {
    return;
  }
  int32_t n = async_liveness_frame_live_load_n(out);
  if ((n <=1)) {
    return;
  }
  int32_t i = 1;
  while ((i < n)) {
    uint8_t key[64] = {};
    uint8_t * src = async_liveness_frame_live_row_ptr(out, i);
    int32_t k = 0;
    while ((k < 64)) {
      (void)(((key)[k] = (src)[k]));
      (void)((k = (k + 1)));
    }
    int32_t j = (i - 1);
    while ((j >=0)) {
      uint8_t * row = async_liveness_frame_live_row_ptr(out, j);
      if ((live_name_cmp(row, &((key)[0])) <=0)) {
        break;
      }
      uint8_t * dst = async_liveness_frame_live_row_ptr(out, (j + 1));
      int32_t t = 0;
      while ((t < 64)) {
        (void)(((dst)[t] = (row)[t]));
        (void)((t = (t + 1)));
      }
      (void)((j = (j - 1)));
    }
    uint8_t * dest = async_liveness_frame_live_row_ptr(out, (j + 1));
    (void)((k = 0));
    while ((k < 64)) {
      (void)(((dest)[k] = (key)[k]));
      (void)((k = (k + 1)));
    }
    (void)((i = (i + 1)));
  }
}
uint8_t * async_liveness_lookup_var_type(uint8_t * f, uint8_t * name) {
  if ((f ==0)) {
    return ((uint8_t *)(0));
  }
  if ((name ==0)) {
    return ((uint8_t *)(0));
  }
  if (((name)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  int32_t nparams = async_liveness_async_live_load_i32(f, 40);
  uint8_t * params = async_liveness_async_live_load_ptr(f, 32);
  if ((params !=0)) {
    int32_t i = 0;
    while ((i < nparams)) {
      uint8_t * pr = (params + (i * 24));
      uint8_t * pn = async_liveness_async_live_load_ptr(pr, 0);
      if ((pn !=0)) {
        if ((async_liveness_async_live_cstr_eq(pn, name) !=0)) {
          return async_liveness_async_live_load_ptr(pr, 8);
        }
      }
      (void)((i = (i + 1)));
    }
  }
  uint8_t * body = async_liveness_async_live_load_ptr(f, 56);
  if ((body !=0)) {
    uint8_t * lets = async_liveness_async_live_load_ptr(body, 16);
    int32_t nlets = async_liveness_async_live_load_i32(body, 24);
    if ((lets !=0)) {
      int32_t i = 0;
      while ((i < nlets)) {
        uint8_t * ld = (lets + (i * 48));
        uint8_t * ln = async_liveness_async_live_load_ptr(ld, 0);
        if ((ln !=0)) {
          if ((async_liveness_async_live_cstr_eq(ln, name) !=0)) {
            return async_liveness_async_live_load_ptr(ld, 8);
          }
        }
        (void)((i = (i + 1)));
      }
    }
  }
  return ((uint8_t *)(0));
}
void async_liveness_type_to_c_buf(uint8_t * ty, uint8_t * buf, int32_t cap) {
  if ((buf ==0)) {
    return;
  }
  if ((cap <=0)) {
    return;
  }
  if ((ty ==0)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74"), cap));
    return;
  }
  int32_t kind = async_liveness_async_live_load_i32(ty, 0);
  if ((kind ==0)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74"), cap));
    return;
  }
  if ((kind ==1)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74"), cap));
    return;
  }
  if ((kind ==2)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x75\x69\x6e\x74\x38\x5f\x74"), cap));
    return;
  }
  if ((kind ==3)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x75\x69\x6e\x74\x33\x32\x5f\x74"), cap));
    return;
  }
  if ((kind ==4)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x75\x69\x6e\x74\x36\x34\x5f\x74"), cap));
    return;
  }
  if ((kind ==5)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x36\x34\x5f\x74"), cap));
    return;
  }
  if ((kind ==6)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x75\x69\x6e\x74\x70\x74\x72\x5f\x74"), cap));
    return;
  }
  if ((kind ==7)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x70\x74\x72\x5f\x74"), cap));
    return;
  }
  if ((kind ==15)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x66\x6c\x6f\x61\x74"), cap));
    return;
  }
  if ((kind ==16)) {
    (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x64\x6f\x75\x62\x6c\x65"), cap));
    return;
  }
  if ((kind ==9)) {
    uint8_t * elem = async_liveness_async_live_load_ptr(ty, 16);
    if ((elem !=0)) {
      uint8_t inner[64] = {};
      (void)(async_liveness_type_to_c_buf(elem, &((inner)[0]), 64));
      int32_t j = 0;
      while (((j + 1) < cap)) {
        if (((inner)[j] ==0)) {
          break;
        }
        (void)(((buf)[j] = (inner)[j]));
        (void)((j = (j + 1)));
      }
      if (((j + 1) < cap)) {
        (void)(((buf)[j] = 32));
        (void)((j = (j + 1)));
      }
      if (((j + 1) < cap)) {
        (void)(((buf)[j] = 42));
        (void)((j = (j + 1)));
      }
      (void)(((buf)[j] = 0));
    } else {
      (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x76\x6f\x69\x64\x20\x2a"), cap));
    }
    return;
  }
  if ((kind ==8)) {
    uint8_t * nm = async_liveness_async_live_load_ptr(ty, 8);
    if ((nm !=0)) {
      if ((async_liveness_async_live_cstr_has_prefix(nm, ((uint8_t *)"\x73\x74\x72\x75\x63\x74\x20"), 7) !=0)) {
        (void)(async_liveness_async_live_cstr_copy_cap(buf, nm, cap));
      } else {
        uint8_t * pref = ((uint8_t *)"\x73\x74\x72\x75\x63\x74\x20");
        int32_t j = 0;
        int32_t i = 0;
        while (((j + 1) < cap)) {
          if (((pref)[i] ==0)) {
            break;
          }
          (void)(((buf)[j] = (pref)[i]));
          (void)((j = (j + 1)));
          (void)((i = (i + 1)));
        }
        (void)((i = 0));
        while (((j + 1) < cap)) {
          if (((nm)[i] ==0)) {
            break;
          }
          (void)(((buf)[j] = (nm)[i]));
          (void)((j = (j + 1)));
          (void)((i = (i + 1)));
        }
        (void)(((buf)[j] = 0));
      }
    } else {
      (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74"), cap));
    }
    return;
  }
  (void)(async_liveness_async_live_cstr_copy_cap(buf, ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74"), cap));
}
int32_t async_liveness_type_size_bytes_module(uint8_t * ty, uint8_t * m) {
  if ((ty ==0)) {
    return 4;
  }
  int32_t kind = async_liveness_async_live_load_i32(ty, 0);
  if ((kind ==8)) {
    uint8_t * nm = async_liveness_async_live_load_ptr(ty, 8);
    if ((nm !=0)) {
      if ((m !=0)) {
        uint8_t * sdefs = async_liveness_async_live_load_ptr(m, 88);
        int32_t ns = async_liveness_async_live_load_i32(m, 96);
        if ((sdefs !=0)) {
          int32_t i = 0;
          while ((i < ns)) {
            uint8_t * sd = async_liveness_async_live_load_ptr(sdefs, (i * 8));
            if ((sd !=0)) {
              uint8_t * sn = async_liveness_async_live_load_ptr(sd, 0);
              if ((sn !=0)) {
                if ((async_liveness_async_live_cstr_eq(sn, nm) !=0)) {
                  int32_t sz = async_liveness_async_live_load_i32(sd, 568);
                  if ((sz > 0)) {
                    return sz;
                  }
                }
              }
            }
            (void)((i = (i + 1)));
          }
        }
      }
    }
    return 8;
  }
  if ((kind ==5)) {
    return 8;
  }
  if ((kind ==4)) {
    return 8;
  }
  if ((kind ==16)) {
    return 8;
  }
  if ((kind ==6)) {
    return 8;
  }
  if ((kind ==7)) {
    return 8;
  }
  if ((kind ==9)) {
    return 8;
  }
  return 4;
}
int32_t async_liveness_func_has_await(uint8_t * f) {
  if ((f ==0)) {
    return 0;
  }
  if ((async_liveness_async_live_load_i32(f, 68) ==0)) {
    return 0;
  }
  uint8_t * body = async_liveness_async_live_load_ptr(f, 56);
  if ((body ==0)) {
    return 0;
  }
  return block_has_await(body);
}
int32_t async_liveness_expr_has_await(uint8_t * e) {
  return expr_has_await(e);
}
int32_t async_liveness_layout_func_module(uint8_t * f, uint8_t * m, uint8_t * out) {
  if ((out ==0)) {
    return -1;
  }
  (void)(memset(out, 0, 4196));
  if ((f ==0)) {
    return 0;
  }
  if ((async_liveness_async_live_load_i32(f, 68) ==0)) {
    return 0;
  }
  uint8_t * body = async_liveness_async_live_load_ptr(f, 56);
  if ((body ==0)) {
    return 0;
  }
  if ((block_has_await(body) ==0)) {
    return 0;
  }
  uint8_t * prefix = 0;
  (void)((prefix = malloc(512)));
  if ((prefix ==0)) {
    return -1;
  }
  (void)(memset(prefix, 0, 512));
  int32_t n_pre = 0;
  int32_t nparams = async_liveness_async_live_load_i32(f, 40);
  uint8_t * params = async_liveness_async_live_load_ptr(f, 32);
  if ((params !=0)) {
    int32_t i = 0;
    while ((i < nparams)) {
      if ((n_pre >=64)) {
        break;
      }
      uint8_t * pr = (params + (i * 24));
      uint8_t * pn = async_liveness_async_live_load_ptr(pr, 0);
      if ((pn !=0)) {
        (void)(async_liveness_async_live_store_ptr(prefix, (n_pre * 8), pn));
        (void)((n_pre = (n_pre + 1)));
      }
      (void)((i = (i + 1)));
    }
  }
  (void)(analyze_block_linear(body, prefix, n_pre, out));
  (void)(free(prefix));
  int32_t ln = async_liveness_frame_live_load_n(out);
  if ((ln > 1)) {
    (void)(async_live_sort_frame_names(out));
  }
  int32_t na = block_count_await(body);
  (void)(async_liveness_async_live_store_i32(out, 4100, na));
  int32_t ird = block_has_io_read_await(body);
  int32_t iwr = block_has_io_write_await(body);
  (void)(async_liveness_async_live_store_i32(out, 4188, ird));
  (void)(async_liveness_async_live_store_i32(out, 4192, iwr));
  (void)(frame_build_tag(f, (out + 4108), 80));
  int32_t fb = 4;
  if ((ird !=0)) {
    (void)((fb = (fb + 4)));
  }
  if ((iwr !=0)) {
    (void)((fb = (fb + 4)));
  }
  int32_t li = 0;
  while ((li < ln)) {
    uint8_t * row = async_liveness_frame_live_row_ptr(out, li);
    uint8_t * ty = async_liveness_lookup_var_type(f, row);
    (void)((fb = (fb + async_liveness_type_size_bytes_module(ty, m))));
    (void)((li = (li + 1)));
  }
  (void)(async_liveness_async_live_store_i32(out, 4104, fb));
  return 0;
}
int32_t async_liveness_layout_func(uint8_t * f, uint8_t * out) {
  return async_liveness_layout_func_module(f, 0, out);
}
int32_t async_liveness_func_needs_cps_frame(uint8_t * f) {
  if ((f ==0)) {
    return 0;
  }
  if ((async_liveness_async_live_load_i32(f, 68) ==0)) {
    return 0;
  }
  uint8_t * body = async_liveness_async_live_load_ptr(f, 56);
  if ((body ==0)) {
    return 0;
  }
  if ((block_has_await(body) ==0)) {
    return 0;
  }
  if ((block_has_io_read_await(body) !=0)) {
    return 1;
  }
  if ((block_has_io_write_await(body) !=0)) {
    return 1;
  }
  if ((block_count_await(body) > 1)) {
    return 1;
  }
  if ((async_liveness_async_live_load_i32(body, 24) > 0)) {
    return 1;
  }
  if ((async_liveness_async_live_load_i32(body, 40) > 0)) {
    return 1;
  }
  if ((async_liveness_async_live_load_i32(body, 56) > 0)) {
    return 1;
  }
  uint8_t * layout = 0;
  (void)((layout = malloc(4196)));
  if ((layout ==0)) {
    return 0;
  }
  if ((async_liveness_layout_func_module(f, 0, layout) !=0)) {
    (void)(free(layout));
    return 0;
  }
  int32_t ln = async_liveness_frame_live_load_n(layout);
  if ((ln <=0)) {
    (void)(free(layout));
    return 0;
  }
  int32_t nparams = async_liveness_async_live_load_i32(f, 40);
  uint8_t * params = async_liveness_async_live_load_ptr(f, 32);
  int32_t i = 0;
  while ((i < ln)) {
    uint8_t * row = async_liveness_frame_live_row_ptr(layout, i);
    int32_t is_param = 0;
    if ((params !=0)) {
      int32_t pi = 0;
      while ((pi < nparams)) {
        uint8_t * pr = (params + (pi * 24));
        uint8_t * pn = async_liveness_async_live_load_ptr(pr, 0);
        if ((pn !=0)) {
          if ((async_liveness_async_live_cstr_eq(pn, row) !=0)) {
            (void)((is_param = 1));
            break;
          }
        }
        (void)((pi = (pi + 1)));
      }
    }
    if ((is_param ==0)) {
      (void)(free(layout));
      return 1;
    }
    (void)((i = (i + 1)));
  }
  (void)(free(layout));
  return 0;
}
int32_t async_liveness_module_struct_in_frame(uint8_t * m, uint8_t * struct_name) {
  if ((m ==0)) {
    return 0;
  }
  if ((struct_name ==0)) {
    return 0;
  }
  if (((struct_name)[0] ==0)) {
    return 0;
  }
  uint8_t * layout = 0;
  (void)((layout = malloc(4196)));
  if ((layout ==0)) {
    return 0;
  }
  uint8_t * funcs = async_liveness_async_live_load_ptr(m, 152);
  int32_t nfuncs = async_liveness_async_live_load_i32(m, 160);
  if ((funcs !=0)) {
    int32_t fi = 0;
    while ((fi < nfuncs)) {
      uint8_t * f = async_liveness_async_live_load_ptr(funcs, (fi * 8));
      if ((f !=0)) {
        if ((async_liveness_async_live_load_i32(f, 68) !=0)) {
          if ((async_liveness_func_has_await(f) !=0)) {
            if ((async_liveness_layout_func_module(f, m, layout) ==0)) {
              int32_t ln = async_liveness_frame_live_load_n(layout);
              int32_t li = 0;
              while ((li < ln)) {
                uint8_t * row = async_liveness_frame_live_row_ptr(layout, li);
                uint8_t * ty = async_liveness_lookup_var_type(f, row);
                if ((ty !=0)) {
                  if ((async_liveness_async_live_load_i32(ty, 0) ==8)) {
                    uint8_t * tn = async_liveness_async_live_load_ptr(ty, 8);
                    if ((tn !=0)) {
                      if ((async_liveness_async_live_cstr_eq(tn, struct_name) !=0)) {
                        (void)(free(layout));
                        return 1;
                      }
                    }
                  }
                }
                (void)((li = (li + 1)));
              }
            }
          }
        }
      }
      (void)((fi = (fi + 1)));
    }
  }
  uint8_t * impls = async_liveness_async_live_load_ptr(m, 136);
  int32_t nimpl = async_liveness_async_live_load_i32(m, 144);
  if ((impls !=0)) {
    int32_t k = 0;
    while ((k < nimpl)) {
      uint8_t * ib = async_liveness_async_live_load_ptr(impls, (k * 8));
      if ((ib !=0)) {
        uint8_t * ifuncs = async_liveness_async_live_load_ptr(ib, 24);
        int32_t nif = async_liveness_async_live_load_i32(ib, 32);
        if ((ifuncs !=0)) {
          int32_t j = 0;
          while ((j < nif)) {
            uint8_t * f = async_liveness_async_live_load_ptr(ifuncs, (j * 8));
            if ((f !=0)) {
              if ((async_liveness_async_live_load_i32(f, 68) !=0)) {
                if ((async_liveness_func_has_await(f) !=0)) {
                  if ((async_liveness_layout_func_module(f, m, layout) ==0)) {
                    int32_t ln = async_liveness_frame_live_load_n(layout);
                    int32_t li = 0;
                    while ((li < ln)) {
                      uint8_t * row = async_liveness_frame_live_row_ptr(layout, li);
                      uint8_t * ty = async_liveness_lookup_var_type(f, row);
                      if ((ty !=0)) {
                        if ((async_liveness_async_live_load_i32(ty, 0) ==8)) {
                          uint8_t * tn = async_liveness_async_live_load_ptr(ty, 8);
                          if ((tn !=0)) {
                            if ((async_liveness_async_live_cstr_eq(tn, struct_name) !=0)) {
                              (void)(free(layout));
                              return 1;
                            }
                          }
                        }
                      }
                      (void)((li = (li + 1)));
                    }
                  }
                }
              }
            }
            (void)((j = (j + 1)));
          }
        }
      }
      (void)((k = (k + 1)));
    }
  }
  (void)(free(layout));
  return 0;
}
int32_t async_liveness_analyze_func(uint8_t * f, uint8_t * out) {
  if ((out ==0)) {
    return -1;
  }
  uint8_t * layout = 0;
  (void)((layout = malloc(4196)));
  if ((layout ==0)) {
    return -1;
  }
  if ((async_liveness_layout_func(f, layout) !=0)) {
    (void)(free(layout));
    return -1;
  }
  int32_t i = 0;
  while ((i < 4100)) {
    (void)(((out)[i] = (layout)[i]));
    (void)((i = (i + 1)));
  }
  (void)(free(layout));
  return 0;
}
