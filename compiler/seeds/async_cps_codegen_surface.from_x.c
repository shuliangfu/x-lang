/* seeds/async_cps_codegen_surface.from_x.c
 * R2 pure surface + Cap residual pure wave1–5 — isomorphic with src/async/async_cps_codegen.x
 * Product cold path still cc seeds/async_cps_codegen.from_x.c (no FROM_X) for full C + Cap residual.
 * Hybrid/PREFER: g05_try_x_to_o(async_cps_codegen.x) + rest (-DSHUX_ASYNC_CPS_CODEGEN_FROM_X).
 * R2: .x eats pure name gates + thin walk/hoist + await expr classifiers (expr_is_*) +
 *   module/sched resolve + func_uses_void_entry + walk _impl (run-async LE walk) +
 *   FILE* emit end/phase_reset/after_await(_io)/sched_wrapper + begin/param_statics/hoist_impl
 *   via opaque driver_preamble_fputs + async_liveness_type_to_c_buf;
 *   FROM_X omits pure C bodies (incl. walk _impl + wave4–5 emit).
 * Cap residual (G.7 single authority): driver_preamble_fputs (opaque FILE*; runtime_driver_abi).
 * Prove: full.x vs this seed → nm IDENTICAL (pure surface)
 * Regen: ./shux -E ... src/async/async_cps_codegen.x | filter DBG + polish prologue
 * NOTE: use ./shux (not shux-x). Thin wrappers pass (e,target)/(b,target) ABI matching C.
 * PLATFORM: SHARED — async CPS pure helpers; mac + Ubuntu prove.
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern int32_t async_cps_codegen_x_doc_anchor(void);
extern uint8_t * async_cps_load_func_name(uint8_t * callee);
extern void emit_hoisted_lets(uint8_t * f, uint8_t * out);
extern int32_t async_cps_callee_is_io(uint8_t * callee);
extern int32_t expr_references_run_async(uint8_t * e, uint8_t * target);
extern int32_t block_has_run_async_ref(uint8_t * b, uint8_t * target);
extern int32_t async_cps_callee_is_future_wait_by_name(uint8_t * n);
extern int32_t async_cps_callee_is_future_wait(uint8_t * callee);
extern int32_t async_cps_is_sched_wrapper_name(uint8_t * name);
extern int32_t async_cps_load_i32(uint8_t * p, int32_t off);
extern uint8_t * async_cps_load_ptr(uint8_t * p, int32_t off);
extern uint8_t * async_cps_ptr_at(uint8_t * base, int32_t i);
extern int32_t async_cps_is_binop_kind(int32_t k);
extern int32_t async_cps_is_walk_unary_kind(int32_t k);
extern int32_t expr_references_run_async_impl(uint8_t * e, uint8_t * target);
extern int32_t block_has_run_async_ref_impl(uint8_t * b, uint8_t * target);
extern int32_t async_cps_name_is_read(uint8_t * name);
extern int32_t async_cps_name_is_write(uint8_t * name);
extern int32_t async_cps_name_is_read_fd(uint8_t * name);
extern int32_t async_cps_name_is_write_fd(uint8_t * name);
extern int32_t async_cps_expr_is_io_await(uint8_t * await_expr);
extern int32_t async_cps_expr_is_await_read(uint8_t * await_expr);
extern int32_t async_cps_expr_is_await_read_fd(uint8_t * await_expr);
extern int32_t async_cps_expr_is_await_write_fd(uint8_t * await_expr);
extern int32_t async_cps_expr_is_await_write(uint8_t * await_expr);
extern int32_t async_cps_expr_is_await_future_wait(uint8_t * await_expr);
extern int32_t async_cps_cstr_eq(uint8_t * a, uint8_t * b);
extern uint8_t * async_cps_cstr_skip(uint8_t * p, int32_t n);
extern uint8_t * async_cps_module_func_at(uint8_t * m, int32_t i);
extern int32_t async_cps_func_uses_void_entry(uint8_t * f, uint8_t * m);
extern int32_t async_cps_module_references_run_async(uint8_t * m, uint8_t * async_fn);
extern uint8_t * async_cps_resolve_sched_target(uint8_t * m, uint8_t * sched_name);
extern int32_t async_cps_module_has_sched_extern(uint8_t * m, uint8_t * async_fn);
extern void async_cps_store_i32(uint8_t * p, int32_t off, int32_t v);
extern void async_cps_fputs_i32_dec(uint8_t * out, int32_t v);
extern void async_cps_codegen_end(uint8_t * ctx, uint8_t * out);
extern void async_cps_codegen_emit_phase_reset(uint8_t * out, uint8_t * pad);
extern int32_t async_cps_codegen_after_await_impl(uint8_t * ctx, uint8_t * out, uint8_t * pad, uint8_t * suspend_fn);
extern int32_t async_cps_codegen_after_await(uint8_t * ctx, uint8_t * out, uint8_t * pad);
extern int32_t async_cps_codegen_after_await_io(uint8_t * ctx, uint8_t * out, uint8_t * pad);
extern void async_cps_codegen_emit_sched_wrapper(uint8_t * f, uint8_t * c_fname, uint8_t * out);
extern void async_cps_store_ptr(uint8_t * p, int32_t off, uint8_t * v);
extern void async_cps_emit_static_decl(uint8_t * out, uint8_t * ty, uint8_t * name);
extern int32_t async_cps_type_is_run_seed_scalar(uint8_t * ty);
extern void async_cps_emit_run_seed_take(uint8_t * out, uint8_t * pname, uint8_t * ty);
extern void async_cps_codegen_emit_param_statics(uint8_t * f, uint8_t * out);
extern void emit_hoisted_lets_impl(uint8_t * f, uint8_t * out);
extern void async_cps_codegen_begin(uint8_t * ctx, uint8_t * f, uint8_t * layout, uint8_t * out);
extern int32_t async_liveness_func_needs_cps_frame(uint8_t * f);
extern int32_t async_liveness_func_has_await(uint8_t * f);
extern void async_liveness_type_to_c_buf(uint8_t * ty, uint8_t * buf, int32_t cap);
extern int32_t driver_preamble_fputs(uint8_t * s, uint8_t * stream);
int32_t async_cps_codegen_x_doc_anchor(void) {
  return 0;
}
uint8_t * async_cps_load_func_name(uint8_t * callee) {
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
void emit_hoisted_lets(uint8_t * f, uint8_t * out) {
  (void)(emit_hoisted_lets_impl(f, out));
}
int32_t async_cps_callee_is_io(uint8_t * callee) {
  uint8_t * name = async_cps_load_func_name(callee);
  if ((name ==0)) {
    return 0;
  }
  if (((name)[0] ==0)) {
    return 0;
  }
  if ((((((((((name)[0] ==115) && ((name)[1] ==104)) && ((name)[2] ==117)) && ((name)[3] ==120)) && ((name)[4] ==95)) && ((name)[5] ==105)) && ((name)[6] ==111)) && ((name)[7] ==95))) {
    return 1;
  }
  if (((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==0))) {
    return 1;
  }
  if ((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==0))) {
    return 1;
  }
  if ((((((((((((((name)[0] ==115) && ((name)[1] ==117)) && ((name)[2] ==98)) && ((name)[3] ==109)) && ((name)[4] ==105)) && ((name)[5] ==116)) && ((name)[6] ==95)) && ((name)[7] ==114)) && ((name)[8] ==101)) && ((name)[9] ==97)) && ((name)[10] ==100)) && ((name)[11] ==0))) {
    return 1;
  }
  if (((((((((((((((name)[0] ==115) && ((name)[1] ==117)) && ((name)[2] ==98)) && ((name)[3] ==109)) && ((name)[4] ==105)) && ((name)[5] ==116)) && ((name)[6] ==95)) && ((name)[7] ==119)) && ((name)[8] ==114)) && ((name)[9] ==105)) && ((name)[10] ==116)) && ((name)[11] ==101)) && ((name)[12] ==0))) {
    return 1;
  }
  if ((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==100)) && ((name)[7] ==0))) {
    return 1;
  }
  if (((((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==95)) && ((name)[6] ==102)) && ((name)[7] ==100)) && ((name)[8] ==0))) {
    return 1;
  }
  if (((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==95)) && ((name)[5] ==112)) && ((name)[6] ==116)) && ((name)[7] ==114)) && ((name)[8] ==0))) {
    return 1;
  }
  if (((((((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==95)) && ((name)[5] ==115)) && ((name)[6] ==116)) && ((name)[7] ==100)) && ((name)[8] ==105)) && ((name)[9] ==110)) && ((name)[10] ==95)) && ((name)[11] ==112)) && ((name)[12] ==116)) && ((name)[13] ==114)) && ((name)[14] ==0))) {
    return 1;
  }
  if ((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==95)) && ((name)[5] ==105)) && ((name)[6] ==110)) && ((name)[7] ==116)) && ((name)[8] ==111)) && ((name)[9] ==0))) {
    return 1;
  }
  if (((((((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==95)) && ((name)[6] ==102)) && ((name)[7] ==114)) && ((name)[8] ==111)) && ((name)[9] ==109)) && ((name)[10] ==0))) {
    return 1;
  }
  return 0;
}
int32_t expr_references_run_async(uint8_t * e, uint8_t * target) {
  return expr_references_run_async_impl(e, target);
}
int32_t block_has_run_async_ref(uint8_t * b, uint8_t * target) {
  return block_has_run_async_ref_impl(b, target);
}
int32_t async_cps_callee_is_future_wait_by_name(uint8_t * n) {
  if ((n ==0)) {
    return 0;
  }
  if (((n)[0] ==0)) {
    return 0;
  }
  if ((((((((((((((n)[0] ==102) && ((n)[1] ==117)) && ((n)[2] ==116)) && ((n)[3] ==117)) && ((n)[4] ==114)) && ((n)[5] ==101)) && ((n)[6] ==95)) && ((n)[7] ==119)) && ((n)[8] ==97)) && ((n)[9] ==105)) && ((n)[10] ==116)) && ((n)[11] ==0))) {
    return 1;
  }
  if ((((((((((((((((((((((n)[0] ==114) && ((n)[1] ==117)) && ((n)[2] ==110)) && ((n)[3] ==116)) && ((n)[4] ==105)) && ((n)[5] ==109)) && ((n)[6] ==101)) && ((n)[7] ==95)) && ((n)[8] ==119)) && ((n)[9] ==97)) && ((n)[10] ==105)) && ((n)[11] ==116)) && ((n)[12] ==95)) && ((n)[13] ==102)) && ((n)[14] ==117)) && ((n)[15] ==116)) && ((n)[16] ==117)) && ((n)[17] ==114)) && ((n)[18] ==101)) && ((n)[19] ==0))) {
    return 1;
  }
  if (((((((((((((((((((((((((((n)[0] ==115) && ((n)[1] ==104)) && ((n)[2] ==117)) && ((n)[3] ==120)) && ((n)[4] ==95)) && ((n)[5] ==97)) && ((n)[6] ==115)) && ((n)[7] ==121)) && ((n)[8] ==110)) && ((n)[9] ==99)) && ((n)[10] ==95)) && ((n)[11] ==102)) && ((n)[12] ==117)) && ((n)[13] ==116)) && ((n)[14] ==117)) && ((n)[15] ==114)) && ((n)[16] ==101)) && ((n)[17] ==95)) && ((n)[18] ==119)) && ((n)[19] ==97)) && ((n)[20] ==105)) && ((n)[21] ==116)) && ((n)[22] ==95)) && ((n)[23] ==99)) && ((n)[24] ==0))) {
    return 1;
  }
  if ((((((((((((((((((((((((n)[0] ==115) && ((n)[1] ==116)) && ((n)[2] ==100)) && ((n)[3] ==95)) && ((n)[4] ==97)) && ((n)[5] ==115)) && ((n)[6] ==121)) && ((n)[7] ==110)) && ((n)[8] ==99)) && ((n)[9] ==95)) && ((n)[10] ==102)) && ((n)[11] ==117)) && ((n)[12] ==116)) && ((n)[13] ==117)) && ((n)[14] ==114)) && ((n)[15] ==101)) && ((n)[16] ==95)) && ((n)[17] ==119)) && ((n)[18] ==97)) && ((n)[19] ==105)) && ((n)[20] ==116)) && ((n)[21] ==0))) {
    return 1;
  }
  if ((((((((((((((((((((((((((((((((n)[0] ==115) && ((n)[1] ==116)) && ((n)[2] ==100)) && ((n)[3] ==95)) && ((n)[4] ==97)) && ((n)[5] ==115)) && ((n)[6] ==121)) && ((n)[7] ==110)) && ((n)[8] ==99)) && ((n)[9] ==95)) && ((n)[10] ==114)) && ((n)[11] ==117)) && ((n)[12] ==110)) && ((n)[13] ==116)) && ((n)[14] ==105)) && ((n)[15] ==109)) && ((n)[16] ==101)) && ((n)[17] ==95)) && ((n)[18] ==119)) && ((n)[19] ==97)) && ((n)[20] ==105)) && ((n)[21] ==116)) && ((n)[22] ==95)) && ((n)[23] ==102)) && ((n)[24] ==117)) && ((n)[25] ==116)) && ((n)[26] ==117)) && ((n)[27] ==114)) && ((n)[28] ==101)) && ((n)[29] ==0))) {
    return 1;
  }
  int32_t i = 0;
  while ((i < 512)) {
    if (((n)[i] ==0)) {
      break;
    }
    if (((((((((((((n)[i] ==102) && ((n)[(i + 1)] ==117)) && ((n)[(i + 2)] ==116)) && ((n)[(i + 3)] ==117)) && ((n)[(i + 4)] ==114)) && ((n)[(i + 5)] ==101)) && ((n)[(i + 6)] ==95)) && ((n)[(i + 7)] ==119)) && ((n)[(i + 8)] ==97)) && ((n)[(i + 9)] ==105)) && ((n)[(i + 10)] ==116))) {
      return 1;
    }
    if (((((((((((((((((((((n)[i] ==114) && ((n)[(i + 1)] ==117)) && ((n)[(i + 2)] ==110)) && ((n)[(i + 3)] ==116)) && ((n)[(i + 4)] ==105)) && ((n)[(i + 5)] ==109)) && ((n)[(i + 6)] ==101)) && ((n)[(i + 7)] ==95)) && ((n)[(i + 8)] ==119)) && ((n)[(i + 9)] ==97)) && ((n)[(i + 10)] ==105)) && ((n)[(i + 11)] ==116)) && ((n)[(i + 12)] ==95)) && ((n)[(i + 13)] ==102)) && ((n)[(i + 14)] ==117)) && ((n)[(i + 15)] ==116)) && ((n)[(i + 16)] ==117)) && ((n)[(i + 17)] ==114)) && ((n)[(i + 18)] ==101))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t async_cps_callee_is_future_wait(uint8_t * callee) {
  uint8_t * name = async_cps_load_func_name(callee);
  if ((name ==0)) {
    return 0;
  }
  return async_cps_callee_is_future_wait_by_name(name);
}
int32_t async_cps_is_sched_wrapper_name(uint8_t * name) {
  if ((name ==0)) {
    return 0;
  }
  if (((((((((((((((((((name)[0] ==115) && ((name)[1] ==104)) && ((name)[2] ==117)) && ((name)[3] ==120)) && ((name)[4] ==95)) && ((name)[5] ==97)) && ((name)[6] ==115)) && ((name)[7] ==121)) && ((name)[8] ==110)) && ((name)[9] ==99)) && ((name)[10] ==95)) && ((name)[11] ==115)) && ((name)[12] ==99)) && ((name)[13] ==104)) && ((name)[14] ==101)) && ((name)[15] ==100)) && ((name)[16] ==95))) {
    return 1;
  }
  return 0;
}
int32_t async_cps_load_i32(uint8_t * p, int32_t off) {
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
uint8_t * async_cps_load_ptr(uint8_t * p, int32_t off) {
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
uint8_t * async_cps_ptr_at(uint8_t * base, int32_t i) {
  if ((base ==0)) {
    return ((uint8_t *)(0));
  }
  return async_cps_load_ptr(base, (i * 8));
}
int32_t async_cps_is_binop_kind(int32_t k) {
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
int32_t async_cps_is_walk_unary_kind(int32_t k) {
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
  if ((k ==53)) {
    return 1;
  }
  if ((k ==54)) {
    return 1;
  }
  if ((k ==55)) {
    return 1;
  }
  if ((k ==56)) {
    return 1;
  }
  if ((k ==57)) {
    return 1;
  }
  return 0;
}
int32_t expr_references_run_async_impl(uint8_t * e, uint8_t * target) {
  if ((e ==0)) {
    return 0;
  }
  if ((target ==0)) {
    return 0;
  }
  int32_t k = async_cps_load_i32(e, 0);
  if ((k ==55)) {
    uint8_t * op0 = async_cps_load_ptr(e, 24);
    if ((op0 !=0)) {
      if ((async_cps_load_i32(op0, 0) ==48)) {
        uint8_t * res0 = async_cps_load_ptr(op0, 72);
        if ((res0 ==target)) {
          return 1;
        }
      }
    }
  }
  if ((k ==56)) {
    uint8_t * op1 = async_cps_load_ptr(e, 24);
    if ((op1 !=0)) {
      if ((async_cps_load_i32(op1, 0) ==48)) {
        uint8_t * res1 = async_cps_load_ptr(op1, 72);
        if ((res1 ==target)) {
          return 1;
        }
      }
    }
  }
  if ((async_cps_is_binop_kind(k) !=0)) {
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) !=0)) {
      return 1;
    }
    return expr_references_run_async_impl(async_cps_load_ptr(e, 32), target);
  }
  if ((async_cps_is_walk_unary_kind(k) !=0)) {
    return expr_references_run_async_impl(async_cps_load_ptr(e, 24), target);
  }
  if ((k ==25)) {
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) !=0)) {
      return 1;
    }
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 32), target) !=0)) {
      return 1;
    }
    uint8_t * el = async_cps_load_ptr(e, 40);
    if ((el !=0)) {
      if ((expr_references_run_async_impl(el, target) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==27)) {
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) !=0)) {
      return 1;
    }
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 32), target) !=0)) {
      return 1;
    }
    uint8_t * el2 = async_cps_load_ptr(e, 40);
    if ((el2 !=0)) {
      if ((expr_references_run_async_impl(el2, target) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((k ==48)) {
    uint8_t * args = async_cps_load_ptr(e, 32);
    int32_t n = async_cps_load_i32(e, 40);
    int32_t i = 0;
    while ((i < n)) {
      if ((expr_references_run_async_impl(async_cps_ptr_at(args, i), target) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  if ((k ==49)) {
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) !=0)) {
      return 1;
    }
    uint8_t * args2 = async_cps_load_ptr(e, 40);
    int32_t n2 = async_cps_load_i32(e, 48);
    int32_t j = 0;
    while ((j < n2)) {
      if ((expr_references_run_async_impl(async_cps_ptr_at(args2, j), target) !=0)) {
        return 1;
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
  if ((k ==44)) {
    return expr_references_run_async_impl(async_cps_load_ptr(e, 24), target);
  }
  if ((k ==47)) {
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) !=0)) {
      return 1;
    }
    return expr_references_run_async_impl(async_cps_load_ptr(e, 32), target);
  }
  if ((k ==45)) {
    uint8_t * inits = async_cps_load_ptr(e, 40);
    int32_t nf = async_cps_load_i32(e, 48);
    int32_t fi = 0;
    while ((fi < nf)) {
      if ((expr_references_run_async_impl(async_cps_ptr_at(inits, fi), target) !=0)) {
        return 1;
      }
      (void)((fi = (fi + 1)));
    }
    return 0;
  }
  if ((k ==46)) {
    uint8_t * elems = async_cps_load_ptr(e, 24);
    int32_t ne = async_cps_load_i32(e, 32);
    int32_t ei = 0;
    while ((ei < ne)) {
      if ((expr_references_run_async_impl(async_cps_ptr_at(elems, ei), target) !=0)) {
        return 1;
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  if ((k ==43)) {
    if ((expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) !=0)) {
      return 1;
    }
    uint8_t * arms = async_cps_load_ptr(e, 32);
    int32_t na = async_cps_load_i32(e, 40);
    int32_t ai = 0;
    while ((ai < na)) {
      if ((arms ==0)) {
        return 0;
      }
      uint8_t * arm = (arms + (ai * 88));
      if ((expr_references_run_async_impl(async_cps_load_ptr(arm, 80), target) !=0)) {
        return 1;
      }
      (void)((ai = (ai + 1)));
    }
    return 0;
  }
  if ((k ==26)) {
    return block_has_run_async_ref_impl(async_cps_load_ptr(e, 24), target);
  }
  return 0;
}
int32_t block_has_run_async_ref_impl(uint8_t * b, uint8_t * target) {
  if ((b ==0)) {
    return 0;
  }
  if ((target ==0)) {
    return 0;
  }
  uint8_t * stmts = async_cps_load_ptr(b, 96);
  int32_t ns = async_cps_load_i32(b, 104);
  int32_t si = 0;
  while ((si < ns)) {
    if ((expr_references_run_async_impl(async_cps_ptr_at(stmts, si), target) !=0)) {
      return 1;
    }
    (void)((si = (si + 1)));
  }
  uint8_t * fin = async_cps_load_ptr(b, 112);
  if ((fin !=0)) {
    if ((expr_references_run_async_impl(fin, target) !=0)) {
      return 1;
    }
  }
  uint8_t * labs = async_cps_load_ptr(b, 80);
  int32_t nl = async_cps_load_i32(b, 88);
  int32_t li = 0;
  while ((li < nl)) {
    if ((labs !=0)) {
      uint8_t * lab = (labs + (li * 32));
      if ((async_cps_load_i32(lab, 8) ==1)) {
        uint8_t * ret_e = async_cps_load_ptr(lab, 24);
        if ((ret_e !=0)) {
          if ((expr_references_run_async_impl(ret_e, target) !=0)) {
            return 1;
          }
        }
      }
    }
    (void)((li = (li + 1)));
  }
  uint8_t * loops = async_cps_load_ptr(b, 32);
  int32_t nloop = async_cps_load_i32(b, 40);
  int32_t wi = 0;
  while ((wi < nloop)) {
    if ((loops !=0)) {
      uint8_t * wbody = async_cps_load_ptr((loops + (wi * 16)), 8);
      if ((wbody !=0)) {
        if ((block_has_run_async_ref_impl(wbody, target) !=0)) {
          return 1;
        }
      }
    }
    (void)((wi = (wi + 1)));
  }
  uint8_t * fors = async_cps_load_ptr(b, 48);
  int32_t nfor = async_cps_load_i32(b, 56);
  int32_t fi = 0;
  while ((fi < nfor)) {
    if ((fors !=0)) {
      uint8_t * fbody = async_cps_load_ptr((fors + (fi * 32)), 24);
      if ((fbody !=0)) {
        if ((block_has_run_async_ref_impl(fbody, target) !=0)) {
          return 1;
        }
      }
    }
    (void)((fi = (fi + 1)));
  }
  return 0;
}
int32_t async_cps_name_is_read(uint8_t * name) {
  if ((name ==0)) {
    return 0;
  }
  if (((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==0))) {
    return 1;
  }
  return 0;
}
int32_t async_cps_name_is_write(uint8_t * name) {
  if ((name ==0)) {
    return 0;
  }
  if ((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==0))) {
    return 1;
  }
  return 0;
}
int32_t async_cps_name_is_read_fd(uint8_t * name) {
  if ((name ==0)) {
    return 0;
  }
  if ((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==100)) && ((name)[7] ==0))) {
    return 1;
  }
  return 0;
}
int32_t async_cps_name_is_write_fd(uint8_t * name) {
  if ((name ==0)) {
    return 0;
  }
  if (((((((((((name)[0] ==119) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==95)) && ((name)[6] ==102)) && ((name)[7] ==100)) && ((name)[8] ==0))) {
    return 1;
  }
  return 0;
}
int32_t async_cps_expr_is_io_await(uint8_t * await_expr) {
  if ((await_expr ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(await_expr, 0) !=54)) {
    return 0;
  }
  uint8_t * op = async_cps_load_ptr(await_expr, 24);
  if ((op ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 0) !=48)) {
    return 0;
  }
  uint8_t * resolved = async_cps_load_ptr(op, 72);
  if ((resolved ==0)) {
    return 0;
  }
  return async_cps_callee_is_io(resolved);
}
int32_t async_cps_expr_is_await_read(uint8_t * await_expr) {
  if ((async_cps_expr_is_io_await(await_expr) ==0)) {
    return 0;
  }
  uint8_t * op = async_cps_load_ptr(await_expr, 24);
  if ((op ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 0) !=48)) {
    return 0;
  }
  uint8_t * resolved = async_cps_load_ptr(op, 72);
  if ((resolved ==0)) {
    return 0;
  }
  uint8_t * name = async_cps_load_func_name(resolved);
  if ((async_cps_name_is_read(name) ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 40) < 3)) {
    return 0;
  }
  return 1;
}
int32_t async_cps_expr_is_await_read_fd(uint8_t * await_expr) {
  if ((async_cps_expr_is_io_await(await_expr) ==0)) {
    return 0;
  }
  uint8_t * op = async_cps_load_ptr(await_expr, 24);
  if ((op ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 0) !=48)) {
    return 0;
  }
  uint8_t * resolved = async_cps_load_ptr(op, 72);
  if ((resolved ==0)) {
    return 0;
  }
  uint8_t * name = async_cps_load_func_name(resolved);
  if ((async_cps_name_is_read_fd(name) ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 40) < 3)) {
    return 0;
  }
  return 1;
}
int32_t async_cps_expr_is_await_write_fd(uint8_t * await_expr) {
  if ((async_cps_expr_is_io_await(await_expr) ==0)) {
    return 0;
  }
  uint8_t * op = async_cps_load_ptr(await_expr, 24);
  if ((op ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 0) !=48)) {
    return 0;
  }
  uint8_t * resolved = async_cps_load_ptr(op, 72);
  if ((resolved ==0)) {
    return 0;
  }
  uint8_t * name = async_cps_load_func_name(resolved);
  if ((async_cps_name_is_write_fd(name) ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 40) < 3)) {
    return 0;
  }
  return 1;
}
int32_t async_cps_expr_is_await_write(uint8_t * await_expr) {
  if ((async_cps_expr_is_io_await(await_expr) ==0)) {
    return 0;
  }
  uint8_t * op = async_cps_load_ptr(await_expr, 24);
  if ((op ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 0) !=48)) {
    return 0;
  }
  uint8_t * resolved = async_cps_load_ptr(op, 72);
  if ((resolved ==0)) {
    return 0;
  }
  uint8_t * name = async_cps_load_func_name(resolved);
  if ((async_cps_name_is_write(name) ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(op, 40) < 3)) {
    return 0;
  }
  return 1;
}
int32_t async_cps_expr_is_await_future_wait(uint8_t * await_expr) {
  if ((await_expr ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(await_expr, 0) !=54)) {
    return 0;
  }
  uint8_t * op = async_cps_load_ptr(await_expr, 24);
  if ((op ==0)) {
    return 0;
  }
  int32_t ok = async_cps_load_i32(op, 0);
  if ((ok ==49)) {
    uint8_t * method_name = async_cps_load_ptr(op, 32);
    if ((method_name !=0)) {
      if ((async_cps_callee_is_future_wait_by_name(method_name) !=0)) {
        return 1;
      }
    }
    uint8_t * implf = async_cps_load_ptr(op, 56);
    if ((implf !=0)) {
      if ((async_cps_callee_is_future_wait(implf) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((ok !=48)) {
    return 0;
  }
  uint8_t * resolved = async_cps_load_ptr(op, 72);
  if ((resolved !=0)) {
    if ((async_cps_callee_is_future_wait(resolved) !=0)) {
      return 1;
    }
  }
  uint8_t * call_callee = async_cps_load_ptr(op, 24);
  if ((call_callee ==0)) {
    return 0;
  }
  int32_t ck = async_cps_load_i32(call_callee, 0);
  if ((ck ==44)) {
    uint8_t * field_name = async_cps_load_ptr(call_callee, 32);
    if ((field_name !=0)) {
      if ((async_cps_callee_is_future_wait_by_name(field_name) !=0)) {
        return 1;
      }
    }
    return 0;
  }
  if ((ck ==3)) {
    uint8_t * vname = async_cps_load_ptr(call_callee, 24);
    if ((vname !=0)) {
      if ((async_cps_callee_is_future_wait_by_name(vname) !=0)) {
        return 1;
      }
    }
  }
  return 0;
}
int32_t async_cps_cstr_eq(uint8_t * a, uint8_t * b) {
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
uint8_t * async_cps_cstr_skip(uint8_t * p, int32_t n) {
  if ((p ==0)) {
    return ((uint8_t *)(0));
  }
  if ((n <=0)) {
    return p;
  }
  size_t a = ((size_t)(p));
  (void)((a = (a + ((size_t)(n)))));
  return ((uint8_t *)(a));
}
uint8_t * async_cps_module_func_at(uint8_t * m, int32_t i) {
  if ((m ==0)) {
    return ((uint8_t *)(0));
  }
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  uint8_t * funcs = async_cps_load_ptr(m, 152);
  if ((funcs ==0)) {
    return ((uint8_t *)(0));
  }
  return async_cps_load_ptr(funcs, (i * 8));
}
int32_t async_cps_func_uses_void_entry(uint8_t * f, uint8_t * m) {
  if ((f ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(f, 68) ==0)) {
    return 0;
  }
  if ((m !=0)) {
  }
  return async_liveness_func_needs_cps_frame(f);
  return 0;
}
int32_t async_cps_module_references_run_async(uint8_t * m, uint8_t * async_fn) {
  if ((m ==0)) {
    return 0;
  }
  if ((async_fn ==0)) {
    return 0;
  }
  int32_t n = async_cps_load_i32(m, 160);
  if ((n <=0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * f = async_cps_module_func_at(m, i);
    (void)((i = (i + 1)));
    if ((f ==0)) {
      continue;
    }
    if ((async_cps_load_i32(f, 64) !=0)) {
      continue;
    }
    uint8_t * body = async_cps_load_ptr(f, 56);
    if ((body ==0)) {
      continue;
    }
    if ((block_has_run_async_ref(body, async_fn) !=0)) {
      return 1;
    }
  }
  return 0;
}
uint8_t * async_cps_resolve_sched_target(uint8_t * m, uint8_t * sched_name) {
  if ((m ==0)) {
    return ((uint8_t *)(0));
  }
  if ((sched_name ==0)) {
    return ((uint8_t *)(0));
  }
  if ((async_cps_is_sched_wrapper_name(sched_name) ==0)) {
    return ((uint8_t *)(0));
  }
  uint8_t * async_name = async_cps_cstr_skip(sched_name, 16);
  if ((async_name ==0)) {
    return ((uint8_t *)(0));
  }
  if (((async_name)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  int32_t n = async_cps_load_i32(m, 160);
  if ((n <=0)) {
    return ((uint8_t *)(0));
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * f = async_cps_module_func_at(m, i);
    (void)((i = (i + 1)));
    if ((f ==0)) {
      continue;
    }
    uint8_t * fname = async_cps_load_func_name(f);
    if ((fname ==0)) {
      continue;
    }
    if ((async_cps_load_i32(f, 64) !=0)) {
      continue;
    }
    if ((async_cps_cstr_eq(fname, async_name) ==0)) {
      continue;
    }
    if ((async_cps_load_i32(f, 68) ==0)) {
      continue;
    }
    int32_t has = 0;
    (void)((has = async_liveness_func_has_await(f)));
    if ((has !=0)) {
      return f;
    }
  }
  return ((uint8_t *)(0));
}
int32_t async_cps_module_has_sched_extern(uint8_t * m, uint8_t * async_fn) {
  if ((m ==0)) {
    return 0;
  }
  if ((async_fn ==0)) {
    return 0;
  }
  uint8_t * async_name = async_cps_load_func_name(async_fn);
  if ((async_name ==0)) {
    return 0;
  }
  if (((async_name)[0] ==0)) {
    return 0;
  }
  if ((async_cps_load_i32(async_fn, 68) ==0)) {
    return 0;
  }
  int32_t has = 0;
  (void)((has = async_liveness_func_has_await(async_fn)));
  if ((has ==0)) {
    return 0;
  }
  int32_t n = async_cps_load_i32(m, 160);
  if ((n <=0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * ef = async_cps_module_func_at(m, i);
    (void)((i = (i + 1)));
    if ((ef ==0)) {
      continue;
    }
    if ((async_cps_load_i32(ef, 64) ==0)) {
      continue;
    }
    uint8_t * ename = async_cps_load_func_name(ef);
    if ((ename ==0)) {
      continue;
    }
    if ((async_cps_is_sched_wrapper_name(ename) ==0)) {
      continue;
    }
    uint8_t * rest = async_cps_cstr_skip(ename, 16);
    if ((async_cps_cstr_eq(rest, async_name) !=0)) {
      return 1;
    }
  }
  return 0;
}
void async_cps_store_i32(uint8_t * p, int32_t off, int32_t v) {
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
void async_cps_fputs_i32_dec(uint8_t * out, int32_t v) {
  if ((out ==0)) {
    return;
  }
  if ((v < 0)) {
    return;
  }
  if ((v ==0)) {
    uint8_t z[2] = {48, 0};
    (void)(driver_preamble_fputs(&((z)[0]), out));
    return;
  }
  int32_t cnt = 0;
  int32_t tc = v;
  while ((tc > 0)) {
    (void)((cnt = (cnt + 1)));
    (void)((tc = (tc / 10)));
  }
  uint8_t buf[17] = { 0 };
  int32_t k = (cnt - 1);
  int32_t tm = v;
  while ((tm > 0)) {
    int32_t d = (tm % 10);
    (void)((tm = (tm / 10)));
    if ((k >=0)) {
      if ((k < 16)) {
        (void)(((buf)[k] = ((uint8_t)((d + 48)))));
      }
    }
    (void)((k = (k - 1)));
  }
  if ((cnt > 0)) {
    if ((cnt < 17)) {
      (void)(((buf)[cnt] = 0));
      (void)(driver_preamble_fputs(&((buf)[0]), out));
    }
  }
}
void async_cps_codegen_end(uint8_t * ctx, uint8_t * out) {
  if ((ctx ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  if ((async_cps_load_i32(ctx, 20) ==0)) {
    return;
  }
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x62\x72\x65\x61\x6b\x3b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x7d\x5c\x6e"), out));
  (void)(async_cps_store_i32(ctx, 20, 0));
}
void async_cps_codegen_emit_phase_reset(uint8_t * out, uint8_t * pad) {
  if ((out ==0)) {
    return;
  }
  uint8_t def[3] = {32, 32, 0};
  uint8_t * p = pad;
  if ((p ==0)) {
    (void)((p = &((def)[0])));
  }
  (void)(driver_preamble_fputs(p, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e\x5f\x5f\x70\x68\x61\x73\x65\x20\x3d\x20\x30\x3b\x5c\x6e"), out));
}
int32_t async_cps_codegen_after_await_impl(uint8_t * ctx, uint8_t * out, uint8_t * pad, uint8_t * suspend_fn) {
  if ((ctx ==0)) {
    return -1;
  }
  if ((out ==0)) {
    return -1;
  }
  if ((suspend_fn ==0)) {
    return -1;
  }
  uint8_t * layout = async_cps_load_ptr(ctx, 8);
  if ((layout ==0)) {
    return -1;
  }
  if ((async_cps_load_ptr(ctx, 0) ==0)) {
    return -1;
  }
  uint8_t def[3] = {32, 32, 0};
  uint8_t * p = pad;
  if ((p ==0)) {
    (void)((p = &((def)[0])));
  }
  int32_t phase = async_cps_load_i32(ctx, 16);
  (void)(async_cps_store_i32(ctx, 16, (phase + 1)));
  int32_t n = async_cps_load_i32(layout, 4096);
  if ((n < 0)) {
    (void)((n = 0));
  }
  if ((n > 64)) {
    (void)((n = 64));
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * v = (layout + (i * 64));
    (void)((i = (i + 1)));
    if ((v ==0)) {
      continue;
    }
    if (((v)[0] ==0)) {
      continue;
    }
    (void)(driver_preamble_fputs(p, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e"), out));
    (void)(driver_preamble_fputs(v, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x3d\x20"), out));
    (void)(driver_preamble_fputs(v, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x3b\x5c\x6e"), out));
  }
  (void)(driver_preamble_fputs(p, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e\x5f\x5f\x70\x68\x61\x73\x65\x20\x3d\x20"), out));
  (void)(async_cps_fputs_i32_dec(out, phase));
  (void)(driver_preamble_fputs(((uint8_t *)"\x3b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(p, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x69\x66\x20\x28"), out));
  (void)(driver_preamble_fputs(suspend_fn, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x28\x26\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e\x5f\x5f\x70\x68\x61\x73\x65\x2c\x20"), out));
  (void)(async_cps_fputs_i32_dec(out, phase));
  (void)(driver_preamble_fputs(((uint8_t *)"\x29\x29\x20\x72\x65\x74\x75\x72\x6e\x20\x28\x69\x6e\x74\x33\x32\x5f\x74\x29\x53\x48\x55\x58\x5f\x41\x53\x59\x4e\x43\x5f\x53\x55\x53\x50\x45\x4e\x44\x45\x44\x3b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(p, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x2f\x2a\x20\x53\x48\x55\x58\x5f\x41\x53\x59\x4e\x43\x5f\x43\x50\x53\x20\x66\x61\x6c\x6c\x74\x68\x72\x6f\x75\x67\x68\x20\x70\x68\x61\x73\x65\x3d"), out));
  (void)(async_cps_fputs_i32_dec(out, phase));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x2a\x2f\x5c\x6e"), out));
  (void)(driver_preamble_fputs(p, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x63\x61\x73\x65\x20"), out));
  (void)(async_cps_fputs_i32_dec(out, phase));
  (void)(driver_preamble_fputs(((uint8_t *)"\x3a\x5c\x6e"), out));
  int32_t j = 0;
  while ((j < n)) {
    uint8_t * v2 = (layout + (j * 64));
    (void)((j = (j + 1)));
    if ((v2 ==0)) {
      continue;
    }
    if (((v2)[0] ==0)) {
      continue;
    }
    (void)(driver_preamble_fputs(p, out));
    (void)(driver_preamble_fputs(v2, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x3d\x20\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e"), out));
    (void)(driver_preamble_fputs(v2, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x3b\x5c\x6e"), out));
  }
  return 0;
}
int32_t async_cps_codegen_after_await(uint8_t * ctx, uint8_t * out, uint8_t * pad) {
  uint8_t sn[24] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 99, 112, 115, 95, 115, 117, 115, 112, 101, 110, 100, 0, 0};
  return async_cps_codegen_after_await_impl(ctx, out, pad, &((sn)[0]));
}
int32_t async_cps_codegen_after_await_io(uint8_t * ctx, uint8_t * out, uint8_t * pad) {
  uint8_t sn[27] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 99, 112, 115, 95, 115, 117, 115, 112, 101, 110, 100, 95, 105, 111, 0, 0};
  return async_cps_codegen_after_await_impl(ctx, out, pad, &((sn)[0]));
}
void async_cps_codegen_emit_sched_wrapper(uint8_t * f, uint8_t * c_fname, uint8_t * out) {
  if ((f ==0)) {
    return;
  }
  if ((c_fname ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  uint8_t * name = async_cps_load_func_name(f);
  if ((name ==0)) {
    return;
  }
  if (((name)[0] ==0)) {
    return;
  }
  (void)(driver_preamble_fputs(((uint8_t *)"\x2f\x2a\x20\x41\x34\x3a\x20\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x20\x65\x6e\x74\x72\x79\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x73\x63\x68\x65\x64\x5f"), out));
  (void)(driver_preamble_fputs(name, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x2a\x2f\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x23\x69\x66\x6e\x64\x65\x66\x20\x53\x48\x55\x58\x5f\x41\x53\x59\x4e\x43\x5f\x53\x43\x48\x45\x44\x5f\x52\x54\x5f\x44\x45\x43\x4c\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x23\x64\x65\x66\x69\x6e\x65\x20\x53\x48\x55\x58\x5f\x41\x53\x59\x4e\x43\x5f\x53\x43\x48\x45\x44\x5f\x52\x54\x5f\x44\x45\x43\x4c\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x65\x78\x74\x65\x72\x6e\x20\x69\x6e\x74\x33\x32\x5f\x74\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x69\x33\x32\x28\x69\x6e\x74\x33\x32\x5f\x74\x20\x28\x2a\x66\x6e\x29\x28\x76\x6f\x69\x64\x29\x29\x3b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x23\x65\x6e\x64\x69\x66\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x73\x63\x68\x65\x64\x5f"), out));
  (void)(driver_preamble_fputs(name, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x28\x76\x6f\x69\x64\x29\x20\x7b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x72\x65\x74\x75\x72\x6e\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x69\x33\x32\x28\x28\x69\x6e\x74\x33\x32\x5f\x74\x20\x28\x2a\x29\x28\x76\x6f\x69\x64\x29\x29"), out));
  (void)(driver_preamble_fputs(c_fname, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x29\x3b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x7d\x5c\x6e"), out));
}
void async_cps_store_ptr(uint8_t * p, int32_t off, uint8_t * v) {
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
void async_cps_emit_static_decl(uint8_t * out, uint8_t * ty, uint8_t * name) {
  if ((out ==0)) {
    return;
  }
  if ((name ==0)) {
    return;
  }
  if (((name)[0] ==0)) {
    return;
  }
  uint8_t cty[96] = {};
  (void)(async_liveness_type_to_c_buf(ty, &((cty)[0]), 96));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x73\x74\x61\x74\x69\x63\x20"), out));
  (void)(driver_preamble_fputs(&((cty)[0]), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20"), out));
  (void)(driver_preamble_fputs(name, out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x3b\x5c\x6e"), out));
}
int32_t async_cps_type_is_run_seed_scalar(uint8_t * ty) {
  if ((ty ==0)) {
    return 0;
  }
  int32_t kind = async_cps_load_i32(ty, 0);
  if ((kind ==0)) {
    return 1;
  }
  if ((kind ==3)) {
    return 1;
  }
  if ((kind ==5)) {
    return 1;
  }
  if ((kind ==6)) {
    return 1;
  }
  return 0;
}
void async_cps_emit_run_seed_take(uint8_t * out, uint8_t * pname, uint8_t * ty) {
  if ((out ==0)) {
    return;
  }
  if ((pname ==0)) {
    return;
  }
  if ((ty ==0)) {
    return;
  }
  int32_t kind = async_cps_load_i32(ty, 0);
  if ((kind ==3)) {
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x20\x20"), out));
    (void)(driver_preamble_fputs(pname, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x3d\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x75\x33\x32\x28\x29\x3b\x5c\x6e"), out));
    return;
  }
  if ((kind ==5)) {
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x20\x20"), out));
    (void)(driver_preamble_fputs(pname, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x3d\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x69\x36\x34\x28\x29\x3b\x5c\x6e"), out));
    return;
  }
  if ((kind ==6)) {
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x20\x20"), out));
    (void)(driver_preamble_fputs(pname, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x3d\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x75\x73\x69\x7a\x65\x28\x29\x3b\x5c\x6e"), out));
    return;
  }
  if ((kind ==0)) {
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x20\x20"), out));
    (void)(driver_preamble_fputs(pname, out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x3d\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x69\x33\x32\x28\x29\x3b\x5c\x6e"), out));
    return;
  }
}
void async_cps_codegen_emit_param_statics(uint8_t * f, uint8_t * out) {
  if ((f ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  int32_t nparams = async_cps_load_i32(f, 40);
  uint8_t * params = async_cps_load_ptr(f, 32);
  if ((params ==0)) {
    return;
  }
  if ((nparams < 0)) {
    return;
  }
  int32_t pi = 0;
  while ((pi < nparams)) {
    uint8_t * pr = (params + (pi * 24));
    (void)((pi = (pi + 1)));
    uint8_t * pname = async_cps_load_ptr(pr, 0);
    uint8_t * pty = async_cps_load_ptr(pr, 8);
    if ((pname ==0)) {
      continue;
    }
    if (((pname)[0] ==0)) {
      continue;
    }
    if ((pty ==0)) {
      continue;
    }
    (void)(async_cps_emit_static_decl(out, pty, pname));
  }
}
void emit_hoisted_lets_impl(uint8_t * f, uint8_t * out) {
  if ((f ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  uint8_t * body = async_cps_load_ptr(f, 56);
  if ((body ==0)) {
    return;
  }
  uint8_t * lets = async_cps_load_ptr(body, 16);
  if ((lets ==0)) {
    return;
  }
  int32_t nlets = async_cps_load_i32(body, 24);
  if ((nlets < 0)) {
    return;
  }
  int32_t i = 0;
  while ((i < nlets)) {
    uint8_t * ld = (lets + (i * 48));
    (void)((i = (i + 1)));
    uint8_t * name = async_cps_load_ptr(ld, 0);
    if ((name ==0)) {
      continue;
    }
    if (((name)[0] ==0)) {
      continue;
    }
    uint8_t * ty = async_cps_load_ptr(ld, 8);
    (void)(async_cps_emit_static_decl(out, ty, name));
  }
}
void async_cps_codegen_begin(uint8_t * ctx, uint8_t * f, uint8_t * layout, uint8_t * out) {
  if ((ctx ==0)) {
    return;
  }
  if ((f ==0)) {
    return;
  }
  if ((layout ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  (void)(async_cps_store_ptr(ctx, 0, f));
  (void)(async_cps_store_ptr(ctx, 8, layout));
  (void)(async_cps_store_i32(ctx, 16, 1));
  (void)(async_cps_store_i32(ctx, 20, 0));
  (void)(emit_hoisted_lets(f, out));
  int32_t nparams = async_cps_load_i32(f, 40);
  uint8_t * params = async_cps_load_ptr(f, 32);
  int32_t has_seed_param = 0;
  if ((params !=0)) {
    int32_t pi = 0;
    while ((pi < nparams)) {
      uint8_t * pr = (params + (pi * 24));
      (void)((pi = (pi + 1)));
      uint8_t * pname = async_cps_load_ptr(pr, 0);
      uint8_t * pty = async_cps_load_ptr(pr, 8);
      if ((pname ==0)) {
        continue;
      }
      if ((pty ==0)) {
        continue;
      }
      if ((async_cps_type_is_run_seed_scalar(pty) !=0)) {
        (void)((has_seed_param = 1));
      }
    }
  }
  if ((has_seed_param !=0)) {
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x69\x66\x20\x28\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x76\x61\x6c\x69\x64\x28\x29\x29\x5c\x6e"), out));
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e\x5f\x5f\x70\x68\x61\x73\x65\x20\x3d\x20\x30\x3b\x5c\x6e"), out));
  }
  int32_t num_awaits = async_cps_load_i32(layout, 4100);
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x2f\x2a\x20\x53\x48\x55\x58\x5f\x41\x53\x59\x4e\x43\x5f\x43\x50\x53\x20\x73\x77\x69\x74\x63\x68\x3d\x31\x20\x61\x77\x61\x69\x74\x73\x3d"), out));
  (void)(async_cps_fputs_i32_dec(out, num_awaits));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x2a\x2f\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x73\x77\x69\x74\x63\x68\x20\x28\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e\x5f\x5f\x70\x68\x61\x73\x65\x29\x20\x7b\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x64\x65\x66\x61\x75\x6c\x74\x3a\x5c\x6e"), out));
  (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x63\x61\x73\x65\x20\x30\x3a\x5c\x6e"), out));
  if ((has_seed_param !=0)) {
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x69\x66\x20\x28\x5f\x5f\x73\x68\x75\x78\x5f\x66\x72\x61\x6d\x65\x2e\x5f\x5f\x70\x68\x61\x73\x65\x20\x3d\x3d\x20\x30\x20\x26\x26\x20\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x76\x61\x6c\x69\x64\x28"), out));
    if ((params !=0)) {
      int32_t pj = 0;
      while ((pj < nparams)) {
        uint8_t * pr2 = (params + (pj * 24));
        (void)((pj = (pj + 1)));
        uint8_t * pname2 = async_cps_load_ptr(pr2, 0);
        uint8_t * pty2 = async_cps_load_ptr(pr2, 8);
        if ((pname2 ==0)) {
          continue;
        }
        if ((pty2 ==0)) {
          continue;
        }
        (void)(async_cps_emit_run_seed_take(out, pname2, pty2));
      }
    }
    (void)(driver_preamble_fputs(((uint8_t *)"\x20\x20\x20\x20\x7d\x5c\x6e"), out));
  }
  (void)(async_cps_store_i32(ctx, 20, 1));
}
