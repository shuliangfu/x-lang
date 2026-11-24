/* Source-faithful glue_asm_score_import_binding_func_ix_c twin
 * (compiler/src/asm/backend_call_dispatch.x HEAD 706edd712 export at
 * lines 8705-8853; dirty tree must not be used as typool authority).
 * s172 hello-build residual: after the mangle thin started returning,
 * typool T 0x140451b58 (prologue sub rsp,0xc48) ran as the only live
 * typool frame for 360s (100% of samples, unique rbp 0x103e4d50,
 * RIP 0x140451da3..0x140451df7). typool compiled
 *   while (pi < np) { if (pi >= 8) { break; } ...; pi = pi + 1; }
 * as a jump back to the loop head (0x140451df7 -> 0x140451da3) when
 * pi >= 8, without incrementing pi and without leaving the loop
 * (typool break-as-jmp-to-head). Live samples held pi=8, np=11 at
 * [rbp-0x90]/[rbp-0x80] for 12s. Same family as s167/s171/s172.
 * =[] slots use memset. This is not a fold of typool w1521_body,
 * sret_wrap, pipeline_asm_cmp_enum_rhs_tag_c, kind_ord_at (only
 * called), or any pipe_* helper. docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_module_num_funcs(uint8_t *mod);
int32_t pipeline_asm_module_func_is_extern_at(uint8_t *mod, int32_t fi);
int32_t pipeline_module_func_name_equal_at(uint8_t *mod, int32_t fi, uint8_t *name, int32_t len);
int32_t pipeline_module_func_num_params_at(uint8_t *mod, int32_t fi);
int32_t pipeline_expr_method_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t pi);
int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t pi);
int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t arg_ref);
int32_t pipeline_typeck_call_arg_effective_type_c(uint8_t *arena, int32_t arg_ref);
int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t arg_ref);
int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t arg_ref);
void pipeline_expr_var_name_into(uint8_t *arena, int32_t arg_ref, uint8_t *out);
uint8_t *pipeline_asm_emit_dep_pipe_c(void);
int32_t pipeline_dep_ctx_current_func_index(uint8_t *dp);
int32_t pipeline_module_func_param_name_len_at(uint8_t *mod, int32_t fi, int32_t pj);
void pipeline_module_func_param_name_copy32(uint8_t *mod, int32_t fi, int32_t pj, uint8_t *out);
int32_t pipeline_module_func_param_type_ref_at(uint8_t *mod, int32_t fi, int32_t pi);
int32_t glue_asm_type_ref_to_suffix_c(uint8_t *arena, int32_t ty, uint8_t *buf, int32_t cap);
int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t ty);
int32_t pipeline_type_elem_ref_at(uint8_t *arena, int32_t ty);

int32_t glue_asm_score_import_binding_func_ix_c(
    uint8_t *arena, int32_t expr_ref, uint8_t *res_mod, uint8_t *res_arena,
    uint8_t *field_name, int32_t field_len, int32_t want_np, int32_t is_method,
    int32_t *out_best_score
) {
  int32_t best;
  int32_t best_score;
  int32_t nfunc;
  int32_t fi;
  int32_t np;
  int32_t score;
  int32_t pi;
  int32_t arg_ref;
  int32_t arg_ty;
  int32_t vn_len;
  uint8_t vn[256];
  uint8_t *dp_sc;
  int32_t cur_fi;
  int32_t np_cur;
  int32_t pj;
  int32_t plen;
  uint8_t pn[256];
  int32_t eqn;
  int32_t vk;
  int32_t pty;
  uint8_t sa[64];
  uint8_t sb[64];
  int32_t na;
  int32_t nb;
  int32_t hit;
  int32_t eq;
  int32_t k;
  int32_t ak;
  int32_t pk;
  int32_t ae;
  int32_t pe;
  uint8_t sea[64];
  uint8_t seb[64];
  int32_t nea;
  int32_t neb;
  int32_t eqe;
  int32_t ke;

  if (arena == 0) { return 0 - 1; }
  if (res_mod == 0) { return 0 - 1; }
  if (field_name == 0) { return 0 - 1; }
  if (field_len <= 0) { return 0 - 1; }
  if (res_arena == 0) { res_arena = arena; }

  best = (0 - 1);
  best_score = (0 - 1);
  nfunc = pipeline_module_num_funcs(res_mod);
  fi = 0;
  while (fi < nfunc) {
    if (pipeline_asm_module_func_is_extern_at(res_mod, fi) == 0) {
      if (pipeline_module_func_name_equal_at(res_mod, fi, field_name, field_len) != 0) {
        np = pipeline_module_func_num_params_at(res_mod, fi);
        if (np == want_np) {
          score = 1;
          pi = 0;
          while (pi < np) {
            if (pi >= 8) { break; }
            arg_ref = 0;
            if (is_method != 0) {
              arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi);
            } else {
              arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
            }
            arg_ty = 0;
            if (arg_ref > 0) {
              arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
              if (arg_ty <= 0) {
                arg_ty = pipeline_typeck_call_arg_effective_type_c(arena, arg_ref);
              }
              if (arg_ty <= 0) {
                if (pipeline_expr_kind_ord_at(arena, arg_ref) == 3) {
                  vn_len = pipeline_expr_var_name_len(arena, arg_ref);
                  if (vn_len > 0) {
                    if (vn_len <= 255) {
                      memset(vn, 0, sizeof(vn));
                      pipeline_expr_var_name_into(arena, arg_ref, &vn[0]);
                      dp_sc = pipeline_asm_emit_dep_pipe_c();
                      if (dp_sc != 0) {
                        cur_fi = pipeline_dep_ctx_current_func_index(dp_sc);
                        if (cur_fi >= 0) {
                          np_cur = pipeline_module_func_num_params_at(res_mod, cur_fi);
                          pj = 0;
                          while (pj < np_cur) {
                            plen = pipeline_module_func_param_name_len_at(res_mod, cur_fi, pj);
                            if (plen == vn_len) {
                              if (plen > 0) {
                                memset(pn, 0, sizeof(pn));
                                pipeline_module_func_param_name_copy32(res_mod, cur_fi, pj, &pn[0]);
                                eqn = 1;
                                vk = 0;
                                while (vk < plen) {
                                  if (pn[vk] != vn[vk]) { eqn = 0; break; }
                                  vk = vk + 1;
                                }
                                if (eqn != 0) {
                                  arg_ty = pipeline_module_func_param_type_ref_at(res_mod, cur_fi, pj);
                                  pj = np_cur;
                                }
                              }
                            }
                            pj = pj + 1;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            pty = pipeline_module_func_param_type_ref_at(res_mod, fi, pi);
            if (arg_ty > 0) {
              if (pty > 0) {
                memset(sa, 0, sizeof(sa));
                memset(sb, 0, sizeof(sb));
                na = glue_asm_type_ref_to_suffix_c(arena, arg_ty, &sa[0], 64);
                nb = glue_asm_type_ref_to_suffix_c(res_arena, pty, &sb[0], 64);
                hit = 0;
                if (na > 0) {
                  if (na == nb) {
                    eq = 1;
                    k = 0;
                    while (k < na) {
                      if (sa[k] != sb[k]) { eq = 0; break; }
                      k = k + 1;
                    }
                    if (eq != 0) { hit = 1; }
                  }
                }
                if (hit == 0) {
                  ak = pipeline_type_kind_ord_at(arena, arg_ty);
                  pk = pipeline_type_kind_ord_at(res_arena, pty);
                  if (ak == 10) {
                    if (pk == 9) {
                      ae = pipeline_type_elem_ref_at(arena, arg_ty);
                      pe = pipeline_type_elem_ref_at(res_arena, pty);
                      if (ae > 0) {
                        if (pe > 0) {
                          memset(sea, 0, sizeof(sea));
                          memset(seb, 0, sizeof(seb));
                          nea = glue_asm_type_ref_to_suffix_c(arena, ae, &sea[0], 64);
                          neb = glue_asm_type_ref_to_suffix_c(res_arena, pe, &seb[0], 64);
                          if (nea > 0) {
                            if (nea == neb) {
                              eqe = 1;
                              ke = 0;
                              while (ke < nea) {
                                if (sea[ke] != seb[ke]) { eqe = 0; break; }
                                ke = ke + 1;
                              }
                              if (eqe != 0) { hit = 1; }
                            }
                          }
                        }
                      }
                    }
                  }
                }
                if (hit != 0) { score = score + 10; }
              }
            }
            pi = pi + 1;
          }
          if (score > best_score) {
            best_score = score;
            best = fi;
          }
        }
      }
    }
    fi = fi + 1;
  }
  if (out_best_score != 0) {
    out_best_score[0] = best_score;
  }
  return best;
}
