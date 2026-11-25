/* Source-faithful glue_asm_build_call_export_sym_c twin
 * (compiler/src/asm/backend_call_dispatch.x; HEAD body identical to the
 * dirty tree for this function only).
 * s161 hello-build residual: uninstrumented compile_timeout=true in
 * 25.116s, no first-chance AV under DEBUG_ONLY_THIS_PROCESS. Suspended
 * RIP snapshots for 20s stayed in typool glue_asm_build_call_export_sym_c
 * (s161 T 0x14040a760) around +0x870..+0x8b9 (0x14040afd0-0x14040b019),
 * same rbp/rsp. typool loop is source `while (p0 < 120)` over
 * `dep_path[p0]` from driver_get_current_dep_path_for_codegen(): typool
 * compiled dep_path[p0] as lea rax,[rbp-0x178]; lea rax,[rax+p0*8];
 * mov rax,[rax] (scale-8 lea-of-local-slot of the local pointer, not
 * the path bytes). typool `if (dep_path[p0] == 0) { break; }` became
 * jmp to the while-head at +0x870 without incrementing p0 (typool
 * break-as-jmp-to-head), so the loop never exits. No typool WRITE AV
 * and not an SEH unwind.
 * This is not glue_asm_build_dep_export_sym_c (already folded s144,
 * first-wins thin 0x140002d60). typool lookup / typool note / typool
 * enc_* / typool store-or-load / typool glue_module_func_index_by_name
 * were not the spinner and were not folded. Later arms in this same
 * function are included only because they live in the proven typool
 * symbol, not as a batch fold of cousins. docs-only .x, do not idx8.
 */
#include <stdint.h>

int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
uint8_t *driver_get_current_dep_path_for_codegen(void);
int32_t pipeline_module_num_funcs(uint8_t *mod);
int32_t pipeline_module_func_name_equal_at(uint8_t *mod, int32_t fi, uint8_t *name, int32_t name_len);
int32_t pipeline_module_func_is_extern_at(uint8_t *mod, int32_t fi);
int32_t glue_try_std_heap_redirect_sym_local(uint8_t *name, int32_t nlen, uint8_t *out, int32_t cap);
int32_t pipeline_expr_call_resolved_dep_index_at(uint8_t *arena, int32_t call_expr_ref);
int32_t pipeline_dep_ctx_ndep(uint8_t *ctx);
uint8_t *pipeline_dep_ctx_module_at(uint8_t *ctx, int32_t j);
uint8_t *pipeline_dep_ctx_arena_at(uint8_t *ctx, int32_t j);
void pipeline_dep_ctx_import_path_copy64(uint8_t *ctx, int32_t idx, uint8_t *dst);
int32_t pipeline_expr_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_resolved_func_index_at(uint8_t *arena, int32_t call_expr_ref);
int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(uint8_t *m, uint8_t *a, int32_t call_expr_ref);
int32_t pipeline_module_func_num_params_at(uint8_t *mod, int32_t fi);
int32_t glue_asm_score_import_binding_func_ix_c(uint8_t *arena, int32_t expr_ref, uint8_t *res_mod,
                                              uint8_t *res_arena, uint8_t *field_name, int32_t field_len,
                                              int32_t want_np, int32_t is_method, int32_t *out_best_score);
void glue_codegen_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap);
int32_t glue_asm_link_prefix_len_after_nomangle_c(uint8_t *m, int32_t func_ix, int32_t proposed_plen);
int32_t glue_asm_build_func_overload_mid_c(uint8_t *m, uint8_t *a, int32_t func_ix, uint8_t *out, int32_t out_cap);
int32_t glue_asm_build_import_binding_call_sym(uint8_t *pre, int32_t pre_len, uint8_t *field_name,
                                              int32_t field_len, uint8_t *out_name);
int32_t glue_asm_build_func_export_sym_c(uint8_t *m, uint8_t *a, int32_t func_ix, uint8_t *out, int32_t out_cap);

int32_t glue_asm_build_call_export_sym_c(uint8_t *arena, int32_t call_expr_ref, int32_t callee_ref,
                                         uint8_t *mod, uint8_t *dep_pipe, uint8_t *out, int32_t out_cap) {
  int32_t clen;
  uint8_t cname[256];
  uint8_t *dep_path;
  int32_t skip_heap_redirect;
  int32_t has_local;
  int32_t saw_extern;
  int32_t p0;
  int32_t nfunc_scan;
  int32_t efi;
  int32_t rlen;
  int32_t ci_e;
  int32_t dep_ix;
  int32_t nd;
  int32_t j;
  uint8_t *dm;
  int32_t nfunc;
  int32_t fi;
  uint8_t *dep_mod;
  uint8_t *dep_arena;
  int32_t nfunc_dep;
  int32_t saw_non_extern;
  int32_t fi2;
  int32_t ci_x;
  uint8_t path[256];
  int32_t zi;
  int32_t want_np;
  int32_t use_fi;
  int32_t r_func;
  int32_t r_dep;
  uint8_t mid[256];
  int32_t mid_len;
  uint8_t *da;
  int32_t nfunc_use;
  uint8_t prefix[128];
  int32_t plen;
  int32_t call_plen;
  int32_t want_np2;
  int32_t func_ix;
  int32_t twin_ix;
  int32_t scan_i;
  int32_t nfuncs_scan;
  int32_t ci2;
  int32_t ci3;

  if (arena == 0) {
    return 0 - 1;
  }
  if (callee_ref <= 0) {
    return 0 - 1;
  }
  if (out == 0) {
    return 0 - 1;
  }
  if (out_cap <= 0) {
    return 0 - 1;
  }
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0) {
    return 0 - 1;
  }
  if (clen > 255) {
    return 0 - 1;
  }
  pipeline_expr_var_name_into(arena, callee_ref, &cname[0]);
  dep_path = driver_get_current_dep_path_for_codegen();
  skip_heap_redirect = 0;
  has_local = 0;
  saw_extern = 0;
  if (dep_path != 0) {
    if (dep_path[0] != 0) {
      p0 = 0;
      while (p0 < 120) {
        if (dep_path[p0] == 0) {
          break;
        }
        if (dep_path[p0] == 104 && dep_path[p0 + 1] == 101 && dep_path[p0 + 2] == 97
            && dep_path[p0 + 3] == 112) {
          if (dep_path[p0 + 4] == 46 || dep_path[p0 + 4] == 47) {
            skip_heap_redirect = 1;
            break;
          }
        }
        p0 = p0 + 1;
      }
    }
  }
  if (mod != 0) {
    nfunc_scan = pipeline_module_num_funcs(mod);
    efi = 0;
    while (efi < nfunc_scan) {
      if (pipeline_module_func_name_equal_at(mod, efi, &cname[0], clen) != 0) {
        if (pipeline_module_func_is_extern_at(mod, efi) != 0) {
          saw_extern = 1;
        } else {
          has_local = 1;
        }
      }
      efi = efi + 1;
    }
  }
  if (has_local == 0) {
    if (saw_extern != 0) {
      if (clen > 0) {
        if (clen < out_cap) {
          ci_e = 0;
          while (ci_e < clen) {
            out[ci_e] = cname[ci_e];
            ci_e = ci_e + 1;
          }
          return clen;
        }
      }
      return 0 - 1;
    }
  }
  if (skip_heap_redirect == 0) {
    if (has_local == 0) {
      rlen = glue_try_std_heap_redirect_sym_local(&cname[0], clen, out, out_cap);
      if (rlen > 0) {
        return rlen;
      }
    }
  }
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
  if (dep_ix < 0) {
    if (dep_pipe != 0) {
      nd = pipeline_dep_ctx_ndep(dep_pipe);
      j = 0;
      while (j < nd) {
        dm = pipeline_dep_ctx_module_at(dep_pipe, j);
        if (dm != 0) {
          nfunc = pipeline_module_num_funcs(dm);
          fi = 0;
          while (fi < nfunc) {
            if (pipeline_module_func_name_equal_at(dm, fi, &cname[0], clen) != 0) {
              dep_ix = j;
              break;
            }
            fi = fi + 1;
          }
        }
        if (dep_ix >= 0) {
          break;
        }
        j = j + 1;
      }
    }
  }
  if (dep_ix >= 0) {
    if (dep_pipe != 0) {
      dep_mod = pipeline_dep_ctx_module_at(dep_pipe, dep_ix);
      dep_arena = pipeline_dep_ctx_arena_at(dep_pipe, dep_ix);
      if (dep_mod != 0) {
        nfunc_dep = pipeline_module_num_funcs(dep_mod);
        saw_non_extern = 0;
        fi2 = 0;
        while (fi2 < nfunc_dep) {
          if (pipeline_module_func_name_equal_at(dep_mod, fi2, &cname[0], clen) != 0) {
            if (pipeline_module_func_is_extern_at(dep_mod, fi2) == 0) {
              saw_non_extern = 1;
              break;
            }
          }
          fi2 = fi2 + 1;
        }
        if (saw_non_extern == 0) {
          fi2 = 0;
          while (fi2 < nfunc_dep) {
            if (pipeline_module_func_name_equal_at(dep_mod, fi2, &cname[0], clen) != 0) {
              if (pipeline_module_func_is_extern_at(dep_mod, fi2) != 0) {
                if (clen > 0) {
                  if (clen < out_cap) {
                    ci_x = 0;
                    while (ci_x < clen) {
                      out[ci_x] = cname[ci_x];
                      ci_x = ci_x + 1;
                    }
                    return clen;
                  }
                }
                return 0 - 1;
              }
            }
            fi2 = fi2 + 1;
          }
        }
      }
      zi = 0;
      while (zi < 256) {
        path[zi] = 0;
        zi = zi + 1;
      }
      pipeline_dep_ctx_import_path_copy64(dep_pipe, dep_ix, &path[0]);
      if (path[0] != 0) {
        if (dep_mod != 0) {
          want_np = pipeline_expr_call_num_args_at(arena, call_expr_ref);
          use_fi = (0 - 1);
          r_func = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
          r_dep = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
          mid_len = (0 - 1);
          da = dep_arena;
          if (da == 0) {
            da = arena;
          }
          use_fi = pipeline_typeck_resolve_call_func_index_for_emit_c(dep_mod, arena, call_expr_ref);
          nfunc_use = pipeline_module_num_funcs(dep_mod);
          if (use_fi >= 0) {
            if (use_fi >= nfunc_use) {
              use_fi = 0 - 1;
            } else {
              if (pipeline_module_func_is_extern_at(dep_mod, use_fi) != 0) {
                use_fi = 0 - 1;
              } else {
                if (pipeline_module_func_name_equal_at(dep_mod, use_fi, &cname[0], clen) == 0) {
                  use_fi = 0 - 1;
                } else {
                  if (pipeline_module_func_num_params_at(dep_mod, use_fi) != want_np) {
                    use_fi = 0 - 1;
                  }
                }
              }
            }
          }
          if (use_fi < 0) {
            if (r_dep == dep_ix) {
              if (r_func >= 0) {
                if (r_func < nfunc_use) {
                  if (pipeline_module_func_is_extern_at(dep_mod, r_func) == 0) {
                    if (pipeline_module_func_name_equal_at(dep_mod, r_func, &cname[0], clen) != 0) {
                      if (pipeline_module_func_num_params_at(dep_mod, r_func) == want_np) {
                        use_fi = r_func;
                      }
                    }
                  }
                }
              }
            }
          }
          if (use_fi < 0) {
            use_fi = glue_asm_score_import_binding_func_ix_c(
                arena, call_expr_ref, dep_mod, da, &cname[0], clen, want_np, 0, (int32_t *)0);
          }
          glue_codegen_import_path_to_c_prefix_into(&path[0], &prefix[0], 128);
          plen = 0;
          while (plen < 255) {
            if (prefix[plen] == 0) {
              break;
            }
            plen = plen + 1;
          }
          if (plen > 0) {
            call_plen = plen;
            if (use_fi >= 0) {
              call_plen = glue_asm_link_prefix_len_after_nomangle_c(dep_mod, use_fi, plen);
            }
            if (use_fi >= 0) {
              mid_len = glue_asm_build_func_overload_mid_c(dep_mod, da, use_fi, &mid[0], 256);
              if (mid_len > 0) {
                return glue_asm_build_import_binding_call_sym(&prefix[0], call_plen, &mid[0], mid_len, out);
              }
            }
            return glue_asm_build_import_binding_call_sym(&prefix[0], call_plen, &cname[0], clen, out);
          }
        }
      }
    }
  }
  if (mod != 0) {
    want_np2 = pipeline_expr_call_num_args_at(arena, call_expr_ref);
    func_ix = pipeline_typeck_resolve_call_func_index_for_emit_c(mod, arena, call_expr_ref);
    if (func_ix < 0) {
      func_ix = glue_asm_score_import_binding_func_ix_c(
          arena, call_expr_ref, mod, arena, &cname[0], clen, want_np2, 0, (int32_t *)0);
    }
    if (func_ix >= 0) {
      if (pipeline_module_func_is_extern_at(mod, func_ix) != 0) {
        twin_ix = (0 - 1);
        if (clen > 0) {
          scan_i = 0;
          nfuncs_scan = pipeline_module_num_funcs(mod);
          while (scan_i < nfuncs_scan) {
            if (pipeline_module_func_is_extern_at(mod, scan_i) == 0) {
              if (pipeline_module_func_name_equal_at(mod, scan_i, &cname[0], clen) != 0) {
                if (pipeline_module_func_num_params_at(mod, scan_i) == want_np2) {
                  twin_ix = scan_i;
                  break;
                }
              }
            }
            scan_i = scan_i + 1;
          }
        }
        if (twin_ix >= 0) {
          return glue_asm_build_func_export_sym_c(mod, arena, twin_ix, out, out_cap);
        }
        if (clen > 0) {
          if (clen < out_cap) {
            ci2 = 0;
            while (ci2 < clen) {
              out[ci2] = cname[ci2];
              ci2 = ci2 + 1;
            }
            return clen;
          }
        }
        return 0 - 1;
      }
      return glue_asm_build_func_export_sym_c(mod, arena, func_ix, out, out_cap);
    }
  }
  if (clen > 0) {
    if (clen < out_cap) {
      ci3 = 0;
      while (ci3 < clen) {
        out[ci3] = cname[ci3];
        ci3 = ci3 + 1;
      }
      return clen;
    }
  }
  return 0 - 1;
}
