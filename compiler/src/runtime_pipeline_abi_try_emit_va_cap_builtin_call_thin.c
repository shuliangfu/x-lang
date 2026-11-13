/*
 * Host-gcc twin of try_emit_va_cap_builtin_call_elf_c
 * (language in compiler/src/asm/backend_call_dispatch.x).
 *
 * Root (s56 typool compile of takes_ptr(&nl[0], 1) BUILD_RC=139 after
 *   funcs=2): typool first-wins T 0x140425f4c
 *   backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c (chkstk frame
 *   0x2568) is entered on every CALL/METHOD_CALL before typool addr_of /
 *   typool one_call_arg. typool of
 *   `let nm_start: u8[8] = [118, 97, 95, 115, 116, 97, 114, 116]`
 *   (and the sibling va_end / va_arg_* literals) uses typool huge-lea
 *   `lea 0x6b3196e0(%rbp),%rax` then stores 'v' at typool writer RIP
 *   0x140426728 (`mov %rax,0x0(%rbx)`), ER C0000005 write, with typool
 *   element stride 0x4798 for later bytes of the same literal. The probe
 *   should return 0 when the callee is not a va cap builtin (language
 *   `if (which == 0) { return 0; }` after the name match); typool never
 *   reaches that return because the literal init AVs first.
 *
 * Class: typool huge-lea / typool u8[N] literal-init smash (own class,
 *   not the typool pointer-slot lea of `&arr[0]` as a call argument).
 * Fold allowlist: backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c
 *   only (named typool T 0x140425f4c; two .text E8 sites). Do not idx8.
 * Do not ship xor eax,eax; ret. Do not fold typool try_emit import-method,
 *   typool win_fwd_ret_call, typool mid_ret, typool pend BSS, typool
 *   bind_eq, typool one_call_arg, or typool va_cap_ov_select (callee).
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_method_call_name_len(uint8_t *arena, int32_t expr_ref);
void pipeline_expr_method_call_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_method_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_method_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t index);
int32_t pipeline_expr_call_callee_ref_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_field_access_name_len(uint8_t *arena, int32_t expr_ref);
void pipeline_expr_field_access_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t index);
int32_t pipeline_expr_call_num_type_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_type_arg_ref_at(uint8_t *arena, int32_t expr_ref, int32_t index);
int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t ty_ref);
int32_t glue_asm_local_var_stack_off_scoped(uint8_t *arena, uint8_t *ctx, int32_t expr_ref);
uint8_t *call_dispatch_load_ptr_le(uint8_t *ctx, int32_t off);
int32_t pipeline_asm_emit_func_index_c(void);
int32_t pipeline_module_func_num_params_at(uint8_t *mod, int32_t fi);
int32_t pipeline_module_func_param_type_ref_at(uint8_t *mod, int32_t fi, int32_t k);
int32_t glue_call_param_is_f32_c(uint8_t *arena, int32_t pty);
int32_t call_dispatch_load_i32_le(uint8_t *ctx, int32_t off);
void call_dispatch_store_i32_le(uint8_t *ctx, int32_t off, int32_t val);
int32_t glue_type_size_simple(uint8_t *mod, uint8_t *arena, int32_t ty_ref, int32_t flag);
int32_t backend_enc_mov_arg_reg_to_rax_arch(uint8_t *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_store_rax_to_rbp_arch(uint8_t *elf_ctx, int32_t off, int32_t ta);
int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(uint8_t *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_load_x29_pos_to_rax_arch(uint8_t *elf_ctx, int32_t off, int32_t ta);
int32_t backend_enc_load_rbp_pos_to_rax_arch(uint8_t *elf_ctx, int32_t off, int32_t ta);
int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t *elf_ctx, int32_t off, int32_t ta);
int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_mov_rbx_to_rax_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_add_imm_to_rax_arch(uint8_t *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_ldr_xreg_xreg_imm_arch(uint8_t *elf_ctx, int32_t rd, int32_t rn, int32_t imm, int32_t ta);
int32_t arch_arm64_enc_enc_mov_x0_to_x3(uint8_t *elf_ctx);
int32_t arch_arm64_enc_enc_str_x0_x3(uint8_t *elf_ctx);
int32_t arch_arm64_enc_enc_ldr_x0_x3(uint8_t *elf_ctx);
int32_t arch_arm64_enc_enc_mov_rax_to_x8(uint8_t *elf_ctx);
int32_t arch_arm64_enc_enc_mov_x0_to_x4(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_mov_rax_to_rcx(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_movq_rax_to_mem_rcx(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_movq_mem_rcx_to_rax(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_mov_rax_to_r10(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_movl_mem_rax_to_eax(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_mov_eax_to_edx(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_movq_mem_rax_to_rax(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_mov_edx_to_eax(uint8_t *elf_ctx);
int32_t arch_x86_64_enc_enc_mov_r10_to_rax(uint8_t *elf_ctx);
int32_t backend_call_dispatch_try_emit_va_cap_ov_select_elf_c(
    uint8_t *elf_ctx, uint8_t *ctx, int32_t ta, int32_t is_fp, int32_t gp_n);

int32_t backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta) {
  int32_t ko;
  uint8_t name[256];
  int32_t nlen;
  int32_t n_args;
  int32_t is_method;
  int32_t which;
  int32_t i;
  const uint8_t nm_start[8] = {118, 97, 95, 115, 116, 97, 114, 116};
  const uint8_t nm_end[6] = {118, 97, 95, 101, 110, 100};
  const uint8_t nm_argi32_full[10] = {118, 97, 95, 97, 114, 103, 95, 105, 51, 50};
  const uint8_t nm_argi64_full[10] = {118, 97, 95, 97, 114, 103, 95, 105, 54, 52};
  const uint8_t nm_argptr_full[10] = {118, 97, 95, 97, 114, 103, 95, 112, 116, 114};
  const uint8_t nm_arg_typed[6] = {118, 97, 95, 97, 114, 103};
  int32_t ty_ref;
  int32_t tk;
  int32_t tsz;
  int32_t ap_ref;
  int32_t ap_off;
  int32_t cur;
  int32_t save_off;
  uint8_t *mod;
  int32_t fi;
  int32_t np;
  int32_t k;
  int32_t gp_n;
  int32_t fp_n;
  int32_t np_gp;
  int32_t np_fp;
  int32_t gp_save;
  int32_t fp_save;
  int32_t ov;
  int32_t ov_n;
  int32_t named_stk;
  int32_t stk_pos;
  int32_t pty;
  int32_t is_fp;
  int32_t callee_ref;
  int32_t cko;

  if (arena == 0 || elf_ctx == 0 || ctx == 0 || expr_ref <= 0) {
    return 0;
  }
  if (ta != 0 && ta != 1) {
    return 0;
  }

  memset(name, 0, sizeof(name));
  ko = 0;
  nlen = 0;
  n_args = 0;
  is_method = 0;
  which = 0;
  i = 0;
  ty_ref = 0;
  tk = 0;
  tsz = 0;
  ap_ref = 0;
  ap_off = 0;
  cur = 0;
  save_off = 0;
  mod = 0;
  fi = 0;
  np = 0;
  k = 0;
  gp_n = 6;
  fp_n = 8;
  np_gp = 0;
  np_fp = 0;
  gp_save = 0;
  fp_save = 0;
  ov = 0;
  ov_n = 8;
  named_stk = 0;
  stk_pos = 0;
  pty = 0;
  is_fp = 0;

  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 49) {
    nlen = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (nlen <= 0 || nlen > 255) {
      return 0;
    }
    pipeline_expr_method_call_name_into(arena, expr_ref, &name[0]);
    n_args = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    is_method = 1;
  } else if (ko == 48) {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    cko = 0;
    if (callee_ref <= 0) {
      return 0;
    }
    cko = pipeline_expr_kind_ord_at(arena, callee_ref);
    if (cko == 44) {
      nlen = pipeline_expr_field_access_name_len(arena, callee_ref);
      if (nlen <= 0 || nlen > 255) {
        return 0;
      }
      pipeline_expr_field_access_name_into(arena, callee_ref, &name[0]);
    } else if (cko == 3) {
      nlen = pipeline_expr_var_name_len(arena, callee_ref);
      if (nlen <= 0 || nlen > 255) {
        return 0;
      }
      pipeline_expr_var_name_into(arena, callee_ref, &name[0]);
    } else {
      return 0;
    }
    n_args = pipeline_expr_call_num_args_at(arena, expr_ref);
  } else {
    return 0;
  }

  which = 0;
  if (nlen == 8) {
    i = 0;
    while (i < 8) {
      if (name[i] != nm_start[i]) {
        i = 99;
      } else {
        i = i + 1;
      }
    }
    if (i == 8) {
      which = 1;
    }
  }
  if (which == 0 && nlen == 6) {
    i = 0;
    while (i < 6) {
      if (name[i] != nm_end[i]) {
        i = 99;
      } else {
        i = i + 1;
      }
    }
    if (i == 6) {
      which = 2;
    }
    if (which == 0) {
      i = 0;
      while (i < 6) {
        if (name[i] != nm_arg_typed[i]) {
          i = 99;
        } else {
          i = i + 1;
        }
      }
      if (i == 6) {
        which = 6;
      }
    }
  }
  if (which == 0 && nlen == 10) {
    i = 0;
    while (i < 10) {
      if (name[i] != nm_argi32_full[i]) {
        i = 99;
      } else {
        i = i + 1;
      }
    }
    if (i == 10) {
      which = 3;
    }
    if (which == 0) {
      i = 0;
      while (i < 10) {
        if (name[i] != nm_argi64_full[i]) {
          i = 99;
        } else {
          i = i + 1;
        }
      }
      if (i == 10) {
        which = 4;
      }
    }
    if (which == 0) {
      i = 0;
      while (i < 10) {
        if (name[i] != nm_argptr_full[i]) {
          i = 99;
        } else {
          i = i + 1;
        }
      }
      if (i == 10) {
        which = 5;
      }
    }
  }
  if (which == 0) {
    return 0;
  }

  /* va_end(ap): Cap no-op (do not emit call). */
  if (which == 2) {
    if (n_args != 1) {
      return 0;
    }
    return 1;
  }

  if (which == 1) {
    /* va_start(ap, last): need ap as local VAR. */
    if (n_args != 2) {
      return 0;
    }
    if (is_method != 0) {
      ap_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
    } else {
      ap_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    }
    if (ap_ref <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, ap_ref) != 3) {
      return 0;
    }
    ap_off = glue_asm_local_var_stack_off_scoped(arena, ctx, ap_ref);
    if (ap_off < 16) {
      return 0 - 1;
    }

    mod = call_dispatch_load_ptr_le(ctx, 16);
    fi = pipeline_asm_emit_func_index_c();
    np = 0;
    if (mod != 0 && fi >= 0) {
      np = pipeline_module_func_num_params_at(mod, fi);
    }
    if (np < 0) {
      np = 0;
    }
    gp_n = 6;
    if (ta == 1) {
      gp_n = 8;
    }
    fp_n = 8;
    np_gp = 0;
    np_fp = 0;
    k = 0;
    while (k < np) {
      pty = 0;
      if (mod != 0 && fi >= 0) {
        pty = pipeline_module_func_param_type_ref_at(mod, fi, k);
      }
      if (glue_call_param_is_f32_c(arena, pty) != 0) {
        np_fp = np_fp + 1;
      } else {
        np_gp = np_gp + 1;
      }
      k = k + 1;
    }
    named_stk = 0;
    if (np_gp > gp_n) {
      named_stk = named_stk + (np_gp - gp_n);
    }
    if (np_fp > fp_n) {
      named_stk = named_stk + (np_fp - fp_n);
    }
    if (np_gp > gp_n) {
      np_gp = gp_n;
    }
    if (np_fp > fp_n) {
      np_fp = fp_n;
    }

    cur = call_dispatch_load_i32_le(ctx, 4);
    save_off = cur + 16;
    if (save_off < 16) {
      save_off = 16;
    }
    gp_save = save_off + 24;
    ov_n = 8;
    fp_save = gp_save + gp_n * 8;
    ov = fp_save + fp_n * 8;
    call_dispatch_store_i32_le(ctx, 4, ov + ov_n * 8);

    k = 0;
    while (k < gp_n) {
      if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, k, ta) != 0) {
        return 0 - 1;
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, gp_save + k * 8, ta) != 0) {
        return 0 - 1;
      }
      k = k + 1;
    }
    k = 0;
    while (k < fp_n) {
      if (backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, k, ta) != 0) {
        return 0 - 1;
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, fp_save + k * 8, ta) != 0) {
        return 0 - 1;
      }
      k = k + 1;
    }

    stk_pos = 16;
    if (ta == 1) {
      cur = call_dispatch_load_i32_le(ctx, 0);
      if (cur > 16) {
        stk_pos = cur;
      }
      stk_pos = stk_pos + 16;
    }
    stk_pos = stk_pos + named_stk * 8;
    k = 0;
    while (k < ov_n) {
      if (ta == 1) {
        if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stk_pos + k * 8, ta) != 0) {
          return 0 - 1;
        }
      } else {
        if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stk_pos + k * 8, ta) != 0) {
          return 0 - 1;
        }
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, ov + k * 8, ta) != 0) {
        return 0 - 1;
      }
      k = k + 1;
    }

    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, gp_save + np_gp * 8, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, save_off, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, fp_save + np_fp * 8, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, save_off + 8, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, ov, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, save_off + 16, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, save_off, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, ap_off, ta) != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      if (arch_arm64_enc_enc_mov_x0_to_x3(elf_ctx) != 0) {
        return 0 - 1;
      }
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
      if (arch_arm64_enc_enc_str_x0_x3(elf_ctx) != 0) {
        return 0 - 1;
      }
      return 1;
    }
    if (arch_x86_64_enc_enc_mov_rax_to_rcx(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (arch_x86_64_enc_enc_movq_rax_to_mem_rcx(elf_ctx) != 0) {
      return 0 - 1;
    }
    return 1;
  }

  /* which == 6: typed va_arg<T>(ap) → classify T into 3/4/5/7/8. */
  if (which == 6) {
    if (n_args != 1) {
      return 0;
    }
    if (pipeline_expr_call_num_type_args_at(arena, expr_ref) < 1) {
      return 0;
    }
    ty_ref = pipeline_expr_call_type_arg_ref_at(arena, expr_ref, 0);
    if (ty_ref <= 0) {
      return 0;
    }
    tk = pipeline_type_kind_ord_at(arena, ty_ref);
    if (tk == 14) {
      which = 7;
    } else if (tk == 15) {
      which = 8;
    } else {
      mod = call_dispatch_load_ptr_le(ctx, 16);
      tsz = glue_type_size_simple(mod, arena, ty_ref, 0);
      if (tk == 9) {
        which = 5;
      } else if (tsz >= 8) {
        which = 4;
      } else {
        which = 3;
      }
    }
  }
  /* 3=i32 4=i64 5=ptr (GP) · 7=f32 8=f64 (FP). */
  if (which < 3 || which == 6 || which > 8) {
    return 0;
  }
  is_fp = 0;
  if (which >= 7) {
    is_fp = 1;
  }
  if (n_args != 1) {
    return 0;
  }
  if (is_method != 0) {
    ap_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
  } else {
    ap_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  }
  if (ap_ref <= 0) {
    return 0 - 1;
  }
  if (pipeline_expr_kind_ord_at(arena, ap_ref) != 3) {
    return 0;
  }
  ap_off = glue_asm_local_var_stack_off_scoped(arena, ctx, ap_ref);
  if (ap_off < 16) {
    return 0 - 1;
  }

  gp_n = 6;
  if (ta == 1) {
    gp_n = 8;
  }
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, ap_off, ta) != 0) {
    return 0 - 1;
  }
  if (ta == 1) {
    if (arch_arm64_enc_enc_mov_x0_to_x3(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_arm64_enc_enc_ldr_x0_x3(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_arm64_enc_enc_mov_rax_to_x8(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (is_fp != 0) {
      if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0) {
        return 0 - 1;
      }
    }
    if (arch_arm64_enc_enc_mov_x0_to_x3(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_arm64_enc_enc_ldr_x0_x3(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (backend_call_dispatch_try_emit_va_cap_ov_select_elf_c(elf_ctx, ctx, ta, is_fp, gp_n) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 0, 1, 0, ta) != 0) {
      return 0 - 1;
    }
    if (arch_arm64_enc_enc_mov_x0_to_x4(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0) {
      return 0 - 1;
    }
    if (arch_arm64_enc_enc_str_x0_x3(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 4, ta) != 0) {
      return 0 - 1;
    }
    return 1;
  }
  if (arch_x86_64_enc_enc_mov_rax_to_rcx(elf_ctx) != 0) {
    return 0 - 1;
  }
  if (arch_x86_64_enc_enc_movq_mem_rcx_to_rax(elf_ctx) != 0) {
    return 0 - 1;
  }
  if (arch_x86_64_enc_enc_mov_rax_to_r10(elf_ctx) != 0) {
    return 0 - 1;
  }
  if (is_fp != 0) {
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 0 - 8, ta) != 0) {
      return 0 - 1;
    }
  }
  if (arch_x86_64_enc_enc_mov_rax_to_rcx(elf_ctx) != 0) {
    return 0 - 1;
  }
  if (arch_x86_64_enc_enc_movq_mem_rcx_to_rax(elf_ctx) != 0) {
    return 0 - 1;
  }
  if (backend_call_dispatch_try_emit_va_cap_ov_select_elf_c(elf_ctx, ctx, ta, is_fp, gp_n) != 0) {
    return 0 - 1;
  }
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
    return 0 - 1;
  }
  if (which == 3 || which == 7) {
    if (arch_x86_64_enc_enc_movl_mem_rax_to_eax(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_x86_64_enc_enc_mov_eax_to_edx(elf_ctx) != 0) {
      return 0 - 1;
    }
  } else {
    if (arch_x86_64_enc_enc_movq_mem_rax_to_rax(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_x86_64_enc_enc_mov_rax_to_r10(elf_ctx) != 0) {
      return 0 - 1;
    }
  }
  if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
    return 0 - 1;
  }
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, 0 - 8, ta) != 0) {
    return 0 - 1;
  }
  if (arch_x86_64_enc_enc_movq_rax_to_mem_rcx(elf_ctx) != 0) {
    return 0 - 1;
  }
  if (which == 3 || which == 7) {
    if (arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx) != 0) {
      return 0 - 1;
    }
  } else {
    if (arch_x86_64_enc_enc_mov_r10_to_rax(elf_ctx) != 0) {
      return 0 - 1;
    }
  }
  return 1;
}
