/* Source-faithful glue_asm_mangle_import_binding_call_sym_c twin
 * (compiler/src/asm/backend_call_dispatch.x HEAD ae8638fe6 export at
 * lines 8935-9143; dirty tree must not be used as typool authority).
 * s171 hello-build residual: typool T 0x140453b58 (only T) was called
 * once from the landed w1521_emit_method_body thin ([rsp]=0x14000bd92)
 * for method xlang_io_register (expr=2, imp_j=0, pre=std_io_core_).
 * typool compiled
 *   while (di < nd) {
 *     if (pipeline_dep_ctx_module_at(dp, di) == res_mod) {
 *       ...; break;
 *     }
 *     di = di + 1;
 *   }
 * as a jump back to the loop head (0x1404546df -> 0x140454626) on a
 * match, without incrementing di and without leaving the loop
 * (typool break-as-jmp-to-head). Live samples held di=7, nd=12,
 * mangle rbp 0x103ef040 for 16s while RIP moved through typool
 * callees pipe_load_ptr_slot / pipe_load_i32_le / module_at / arena_at.
 * Same typool break-as-jmp-to-head family as
 * glue_asm_fill_c_prefix_from_module_import (s171) and
 * glue_asm_overload_param_sig_count_c (s167). =[] slots use memset.
 * This is not a fold of typool w1521_body, sret_wrap,
 * pipeline_asm_cmp_enum_rhs_tag_c, kind_ord_at, or any pipe_* helper.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_expr_call_resolved_func_index_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_resolved_dep_index_at(uint8_t *arena, int32_t expr_ref);
uint8_t *pipeline_asm_emit_dep_pipe_c(void);
int32_t pipeline_expr_method_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_num_args_at(uint8_t *arena, int32_t expr_ref);
uint8_t *glue_asm_res_mod_for_import_binding_c(uint8_t *dp, uint8_t *mod_ref, int32_t imp_j, int32_t try_dep);
uint8_t *pipeline_dep_ctx_arena_at(uint8_t *dp, int32_t ix);
int32_t pipeline_dep_ctx_ndep(uint8_t *dp);
uint8_t *pipeline_dep_ctx_module_at(uint8_t *dp, int32_t ix);
int32_t pipeline_module_num_funcs(uint8_t *mod);
int32_t pipeline_module_func_num_params_at(uint8_t *mod, int32_t fi);
int32_t pipeline_module_func_name_equal_at(uint8_t *mod, int32_t fi, uint8_t *name, int32_t len);
int32_t glue_asm_score_import_binding_func_ix_c(uint8_t *arena, int32_t expr_ref, uint8_t *res_mod, uint8_t *res_arena, uint8_t *field_name, int32_t field_len, int32_t want_np, int32_t is_method, int32_t *sc_best);
int32_t glue_module_func_overload_count_c(uint8_t *mod, uint8_t *name, int32_t len);
int32_t glue_asm_build_func_overload_mid_c(uint8_t *res_mod, uint8_t *res_arena, int32_t use_fi, uint8_t *mid, int32_t cap);
int32_t glue_asm_link_prefix_len_after_nomangle_c(uint8_t *res_mod, int32_t use_fi, int32_t pre_len);
int32_t glue_asm_build_import_binding_call_sym(uint8_t *pre_buf, int32_t pre_len, uint8_t *name, int32_t name_len, uint8_t *sym_flat);
int32_t pipeline_expr_method_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t pi);
int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t pi);
int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t arg_ref);
int32_t glue_asm_type_ref_to_suffix_c(uint8_t *arena, int32_t arg_ty, uint8_t *suf, int32_t cap);

int32_t glue_asm_mangle_import_binding_call_sym_c(
    uint8_t *arena, uint8_t *ctx, int32_t expr_ref, uint8_t *mod_ref, int32_t imp_j,
    uint8_t *pre_buf, int32_t pre_len, uint8_t *field_name, int32_t field_len,
    int32_t is_method, uint8_t *sym_flat
) {
  uint8_t *_ctx_keep;
  int32_t r_func;
  int32_t r_dep;
  uint8_t *dp;
  int32_t want_np;
  uint8_t mid[256];
  int32_t mid_len;
  int32_t sym_len;
  int32_t use_fi;
  uint8_t *res_mod;
  uint8_t *res_arena;
  int32_t attempt;
  int32_t try_dep;
  uint8_t *ra;
  int32_t nd;
  int32_t di;
  uint8_t *ra2;
  int32_t nfunc_res;
  int32_t ok;
  int32_t sc_best;
  int32_t scored;
  int32_t nd2;
  int32_t di2;
  uint8_t *rm;
  uint8_t *ra3;
  int32_t cand;
  int32_t nfunc_res2;
  int32_t mpre;
  int32_t alen;
  int32_t ci;
  int32_t pi;
  int32_t arg_ref;
  int32_t arg_ty;
  uint8_t suf[64];
  int32_t sl;
  int32_t si;
  int32_t fpre;
  int32_t pos;
  int32_t fpre2;

  if (arena == 0) { return 0 - 1; }
  if (mod_ref == 0) { return 0 - 1; }
  if (pre_buf == 0) { return 0 - 1; }
  if (pre_len <= 0) { return 0 - 1; }
  if (field_name == 0) { return 0 - 1; }
  if (field_len <= 0) { return 0 - 1; }
  if (sym_flat == 0) { return 0 - 1; }
  _ctx_keep = ctx;
  if (_ctx_keep == 0) { /* ok */ }

  r_func = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
  r_dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
  dp = pipeline_asm_emit_dep_pipe_c();
  want_np = 0;
  if (is_method != 0) {
    want_np = pipeline_expr_method_call_num_args_at(arena, expr_ref);
  } else {
    want_np = pipeline_expr_call_num_args_at(arena, expr_ref);
  }
  memset(mid, 0, sizeof(mid));
  mid_len = (0 - 1);
  sym_len = (0 - 1);
  use_fi = (0 - 1);
  res_mod = 0;
  res_arena = arena;
  if (dp != 0) {
    attempt = 0;
    while (attempt < 2) {
      if (use_fi >= 0) { break; }
      try_dep = r_dep;
      if (attempt == 1) { try_dep = 0 - 1; }
      res_mod = glue_asm_res_mod_for_import_binding_c(dp, mod_ref, imp_j, try_dep);
      if (res_mod != 0) {
        if (try_dep >= 0) {
          ra = pipeline_dep_ctx_arena_at(dp, try_dep);
          if (ra != 0) { res_arena = ra; }
        } else {
          nd = pipeline_dep_ctx_ndep(dp);
          di = 0;
          while (di < nd) {
            if (pipeline_dep_ctx_module_at(dp, di) == res_mod) {
              ra2 = pipeline_dep_ctx_arena_at(dp, di);
              if (ra2 != 0) { res_arena = ra2; }
              break;
            }
            di = di + 1;
          }
        }
        use_fi = r_func;
        if (use_fi >= 0) {
          nfunc_res = pipeline_module_num_funcs(res_mod);
          if (use_fi < nfunc_res) {
            ok = 1;
            if (pipeline_module_func_num_params_at(res_mod, use_fi) != want_np) { ok = 0; }
            if (pipeline_module_func_name_equal_at(res_mod, use_fi, field_name, field_len) == 0) { ok = 0; }
            if (ok == 0) { use_fi = 0 - 1; }
          } else {
            use_fi = 0 - 1;
          }
        }
        if (use_fi < 0) {
          use_fi = glue_asm_score_import_binding_func_ix_c(
            arena, expr_ref, res_mod, res_arena, field_name, field_len, want_np, is_method, 0
          );
        }
        if (use_fi >= 0) {
          if (glue_module_func_overload_count_c(res_mod, field_name, field_len) > 1) {
            sc_best = (0 - 1);
            scored = glue_asm_score_import_binding_func_ix_c(
              arena, expr_ref, res_mod, res_arena, field_name, field_len, want_np, is_method, &sc_best
            );
            if (scored >= 0) {
              if (sc_best >= 11) {
                use_fi = scored;
              }
            }
          }
        }
      }
      attempt = attempt + 1;
    }
    if (use_fi < 0) {
      nd2 = pipeline_dep_ctx_ndep(dp);
      di2 = 0;
      while (di2 < nd2) {
        rm = pipeline_dep_ctx_module_at(dp, di2);
        if (rm != 0) {
          ra3 = pipeline_dep_ctx_arena_at(dp, di2);
          if (ra3 == 0) { ra3 = arena; }
          cand = glue_asm_score_import_binding_func_ix_c(
            arena, expr_ref, rm, ra3, field_name, field_len, want_np, is_method, 0
          );
          if (cand >= 0) {
            res_mod = rm;
            res_arena = ra3;
            use_fi = cand;
            break;
          }
        }
        di2 = di2 + 1;
      }
    }
    if (res_mod != 0) {
      if (use_fi >= 0) {
        nfunc_res2 = pipeline_module_num_funcs(res_mod);
        if (use_fi < nfunc_res2) {
          mid_len = glue_asm_build_func_overload_mid_c(res_mod, res_arena, use_fi, &mid[0], 64);
          if (mid_len > 0) {
            if (glue_module_func_overload_count_c(res_mod, field_name, field_len) > 1) {
              if (mid_len == field_len) {
                mid_len = 0 - 1;
              }
            }
          }
          if (mid_len > 0) {
            mpre = glue_asm_link_prefix_len_after_nomangle_c(res_mod, use_fi, pre_len);
            sym_len = glue_asm_build_import_binding_call_sym(pre_buf, mpre, &mid[0], mid_len, sym_flat);
            if (sym_len <= 0) { mid_len = 0 - 1; }
          }
        }
      }
    }
  }
  if (sym_len <= 0) {
    if (res_mod != 0) {
      if (glue_module_func_overload_count_c(res_mod, field_name, field_len) > 1) {
        alen = 0;
        if (field_len < 64) {
          ci = 0;
          while (ci < field_len) {
            mid[ci] = field_name[ci];
            ci = ci + 1;
          }
          alen = field_len;
        }
        pi = 0;
        while (pi < want_np) {
          if (alen >= 60) { break; }
          arg_ref = 0;
          if (is_method != 0) {
            arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi);
          } else {
            arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
          }
          arg_ty = 0;
          if (arg_ref > 0) {
            arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
          }
          if (arg_ty > 0) {
            memset(suf, 0, sizeof(suf));
            sl = glue_asm_type_ref_to_suffix_c(arena, arg_ty, &suf[0], 64);
            if (sl > 0) {
              if (alen + 1 + sl < 64) {
                mid[alen] = 95;
                alen = alen + 1;
                si = 0;
                while (si < sl) {
                  mid[alen] = suf[si];
                  alen = alen + 1;
                  si = si + 1;
                }
              }
            }
          }
          pi = pi + 1;
        }
        if (alen > field_len) {
          fpre = pre_len;
          if (use_fi >= 0) {
            fpre = glue_asm_link_prefix_len_after_nomangle_c(res_mod, use_fi, pre_len);
          }
          pos = glue_asm_build_import_binding_call_sym(pre_buf, fpre, &mid[0], alen, sym_flat);
          if (pos > 0) { sym_len = pos; }
        }
      }
    }
  }
  if (sym_len <= 0) {
    fpre2 = pre_len;
    if (res_mod != 0) {
      if (use_fi >= 0) {
        fpre2 = glue_asm_link_prefix_len_after_nomangle_c(res_mod, use_fi, pre_len);
      }
    }
    sym_len = glue_asm_build_import_binding_call_sym(pre_buf, fpre2, field_name, field_len, sym_flat);
  }
  return sym_len;
}
