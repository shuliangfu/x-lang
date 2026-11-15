/* Host-gcc twin of pipeline_asm_emit_call_args_elf_c
 * (backend_call_dispatch.x). typool first-wins T 0x14040acb0 compiles
 * `let gp_start: i32[96] = []` (and the sibling gp_units / spill_off /
 * is_sse / is_f64 arrays) as a shallow lea at [rbp-0x130] then 96
 * scale-4 dword zeros. Writer RIP typool 0x14040d6cd stores 0 at
 * [base+0x138] = [rbp+8] and overwrites the return address into already-
 * folded emit_call_with_cleanup (was 0x14a3e4e57). typool-rebuild of
 * core/result/mod.x then SIGSEGV with leftover RIP=0 on the pend-set
 * CALL core_result_ok path (SET_FUNC n=12 map, w1545_pend=1 so the
 * already-folded sysv_f32 early return is skipped). Same class as typool
 * sysv_f32_xmm i32[96] shallow-lea (writer 0x1403fdba3, already folded).
 * Do not idx8 the documentation .x twin. */
#include <stdint.h>

extern int32_t glue_asm_call_reg_max(int32_t ta);
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
extern int32_t pipeline_asm_emit_call_sret_reg_shift_c(void);
extern int32_t backend_call_dispatch_w1545_pend_is(int32_t expr_ref);
extern int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(
    uint8_t *arena, uint8_t *elf, int32_t er, uint8_t *ctx, int32_t ta, int32_t nargs);
extern int32_t backend_call_dispatch_w1546_park_call_sret_arg0(
    uint8_t *elf, uint8_t *ctx, int32_t ta);
extern int32_t glue_sysv_x86_call_n_stack_c(uint8_t *arena, int32_t er, int32_t nargs);
extern int32_t backend_enc_call_stack_reserve_arch(uint8_t *elf, int32_t bytes, int32_t ta);
extern int32_t backend_call_dispatch_glue_aapcs64_call_n_stack_c(
    uint8_t *arena, uint8_t *ctx, int32_t er, int32_t nargs);
extern int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
extern int32_t backend_enc_mov_imm32_to_w0_arch(uint8_t *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(uint8_t *elf, int32_t ta);
extern int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t er, int32_t i);
extern void glue_sysv_x86_call_arg_slot_c(uint8_t *arena, int32_t er, int32_t nargs, int32_t i,
                                          int32_t *kind, int32_t *reg_k, int32_t *stack_k);
extern int32_t glue_call_param_type_ref_at(uint8_t *arena, int32_t er, int32_t i);
extern int32_t glue_sysv_arg_byte_size_c(uint8_t *arena, uint8_t *ctx, int32_t pty, int32_t arg_ref);
extern int32_t backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(int32_t sz);
extern int32_t pipeline_asm_push_sysv_memory_by_value_elf_c(
    uint8_t *arena, uint8_t *elf, uint8_t *ctx, int32_t arg_ref, int32_t sz, int32_t ta);
extern int32_t glue_emit_one_call_arg_elf_c(
    uint8_t *arena, uint8_t *elf, int32_t er, int32_t arg_ref, int32_t i, uint8_t *ctx, int32_t ta);
extern int32_t glue_sysv_arg_gp_units_from_size_c(int32_t sz);
extern int32_t backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(uint8_t *elf, int32_t ta, int32_t u);
extern int32_t backend_call_dispatch_glue_apple_va_force_stack_c(uint8_t *arena, int32_t er, int32_t i);
extern int32_t backend_call_dispatch_glue_aapcs64_arg_is_byref_c(
    uint8_t *arena, uint8_t *ctx, int32_t pty, int32_t sz);
extern int32_t backend_call_dispatch_glue_aapcs64_hfa_nregs_c(
    uint8_t *arena, uint8_t *ctx, int32_t pty);
extern int32_t backend_call_dispatch_glue_arg_ref_is_f64_width_c(
    uint8_t *arena, uint8_t *ctx, int32_t ar, int32_t pty);
extern int32_t backend_call_dispatch_glue_arg_ref_is_sse_float_c(uint8_t *arena, int32_t ar, int32_t pty);
extern int32_t backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c(
    uint8_t *arena, uint8_t *elf, uint8_t *ctx, int32_t arg_ref, int32_t sz, int32_t ta);
extern int32_t backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(
    uint8_t *elf, uint8_t *ctx, int32_t ta, int32_t units);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t ref);
extern int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t ref);
extern int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t ref);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t ref, uint8_t *out);
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, uint8_t *arena, uint8_t *name, int32_t len);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t len);
extern int32_t backend_call_dispatch_glue_call_stk_extra_align(int32_t pos, int32_t sz, int32_t ta);
extern int32_t backend_enc_store_arg_sp_offset_arch(uint8_t *elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t backend_call_dispatch_glue_call_stk_extra_advance(int32_t off, int32_t sz, int32_t ta);
extern int32_t pipeline_asm_store_memory_by_value_to_sp_elf_c(
    uint8_t *arena, uint8_t *elf, uint8_t *ctx, int32_t arg_ref, int32_t sz, int32_t ta, int32_t off);
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(uint8_t *elf, int32_t reg, int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(uint8_t *elf, int32_t reg, int32_t ta);
extern int32_t backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(
    uint8_t *elf, int32_t ta, int32_t spill_off, int32_t gp_start, int32_t gp_units);
extern int32_t backend_call_dispatch_w1546_reload_call_sret_arg0(
    uint8_t *elf, int32_t sret_park, int32_t ta);
extern int32_t backend_call_dispatch_w1545_pend_rcx_emit(uint8_t *elf, int32_t expr_ref);
extern void pipeline_asm_emit_set_call_param_type_ref(int32_t pty);
extern int32_t link_abi_host_is_windows(void);
extern void w1547_win_place_float(int32_t *gp_cur, int32_t *use_xmm, int32_t *slot);
extern int32_t backend_call_dispatch_w1521_win_mem_byref_sz(int32_t sz);

static int32_t find_home_off(uint8_t *arena, uint8_t *ctx, int32_t arg_ref) {
  int32_t arg_ty, arg_tk, vlen, home_off;
  uint8_t vname[256];
  arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
  arg_tk = 0;
  if (arg_ty > 0)
    arg_tk = pipeline_type_kind_ord_at(arena, arg_ty);
  if (arg_tk == 10 || arg_tk == 11)
    return -1;
  vlen = pipeline_expr_var_name_len(arena, arg_ref);
  if (vlen <= 0 || vlen > 255)
    return -1;
  pipeline_expr_var_name_into(arena, arg_ref, &vname[0]);
  home_off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
  if (home_off < 0)
    home_off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
  return home_off;
}

int32_t pipeline_asm_emit_call_args_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta, int32_t nargs) {
  int32_t reg_max, sret_sh, sret_park, stack_reserve, nw, nw2, i0;
  int32_t kind_i, reg_k_i, stack_k_i, arg_ref0, pty0, sz0, pushed0, u0;
  int32_t gp_start[96], gp_units[96], spill_off[96], arg_sz_a[96], is_mem_a[96], fp_slot[96];
  int32_t is_sse[96], is_f64[96];
  int32_t gp_cur, fp_cur, i, ar_i, pty_i, sz_i, hn, u;
  int32_t arg_ref, home_off, so, so_br, stk_pos, arg_ref2, poff, moff, stored, aoff;
  int32_t win_fb, use_xmm_b, slot_b;

  if (nargs < 0)
    return -1;
  if (nargs > 96)
    return -1;

  reg_max = glue_asm_call_reg_max(ta);
  if (ta == 0) {
    if (pipeline_asm_abi_f32_xmm_enabled_c() != 0) {
      if (pipeline_asm_emit_call_sret_reg_shift_c() == 0) {
        if (backend_call_dispatch_w1545_pend_is(expr_ref) == 0) {
          return glue_emit_call_args_elf_sysv_f32_xmm_c(arena, elf_ctx, expr_ref, ctx, ta, nargs);
        }
      }
    }
  }

  sret_sh = 0;
  sret_park = -2;
  if (ta == 0) {
    sret_sh = pipeline_asm_emit_call_sret_reg_shift_c();
    if (sret_sh == 0)
      sret_sh = backend_call_dispatch_w1545_pend_is(expr_ref);
    sret_park = backend_call_dispatch_w1546_park_call_sret_arg0(elf_ctx, ctx, ta);
    if (sret_park == -1)
      return -1;
  }
  if (ta == 2)
    return -1;

  stack_reserve = 0;
  if (ta == 0) {
    if (arena != 0 && expr_ref > 0) {
      nw = glue_sysv_x86_call_n_stack_c(arena, expr_ref, nargs);
      stack_reserve = nw * 8;
      if (nw > 0 && (nw & 1) != 0)
        stack_reserve = stack_reserve + 8;
    }
  } else if (ta == 1) {
    nw = backend_call_dispatch_glue_aapcs64_call_n_stack_c(arena, ctx, expr_ref, nargs);
    stack_reserve = nw * 8;
    if (stack_reserve > 0)
      stack_reserve = (stack_reserve + 15) & (-16);
  } else {
    stack_reserve = glue_asm_call_stack_cleanup_bytes(ta, nargs);
  }
  if (stack_reserve < 0)
    return -1;
  if (backend_enc_call_stack_reserve_arch(elf_ctx, stack_reserve, ta) != 0)
    return -1;

  if (ta == 0) {
    nw2 = glue_sysv_x86_call_n_stack_c(arena, expr_ref, nargs);
    if (nw2 > 0 && (nw2 & 1) != 0) {
      if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    i0 = nargs - 1;
    while (i0 >= 0) {
      kind_i = 0;
      reg_k_i = 0;
      stack_k_i = 0;
      arg_ref0 = pipeline_expr_call_arg_ref(arena, expr_ref, i0);
      if (arg_ref0 != 0) {
        glue_sysv_x86_call_arg_slot_c(arena, expr_ref, nargs, i0, &kind_i, &reg_k_i, &stack_k_i);
        if (kind_i == 2) {
          pty0 = glue_call_param_type_ref_at(arena, expr_ref, i0);
          sz0 = glue_sysv_arg_byte_size_c(arena, ctx, pty0, arg_ref0);
          if (backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(sz0) != 0) {
            pushed0 = pipeline_asm_push_sysv_memory_by_value_elf_c(
                arena, elf_ctx, ctx, arg_ref0, sz0, ta);
            if (pushed0 < 0)
              return -1;
          } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref0, i0, ctx, ta) != 0) {
            return -1;
          } else {
            u0 = glue_sysv_arg_gp_units_from_size_c(sz0);
            if (backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(elf_ctx, ta, u0) < 0)
              return -1;
          }
        }
      }
      i0 = i0 - 1;
    }
  }

  if (ta == 1) {
    gp_cur = 0;
    fp_cur = 0;
    i = 0;
    while (i < nargs) {
      ar_i = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      pty_i = glue_call_param_type_ref_at(arena, expr_ref, i);
      sz_i = glue_sysv_arg_byte_size_c(arena, ctx, pty_i, ar_i);
      spill_off[i] = -1;
      arg_sz_a[i] = sz_i;
      is_mem_a[i] = 0;
      if (backend_call_dispatch_glue_apple_va_force_stack_c(arena, expr_ref, i) != 0) {
        gp_units[i] = 1;
        gp_start[i] = -1;
        fp_slot[i] = -1;
        i = i + 1;
        continue;
      }
      if (backend_call_dispatch_glue_aapcs64_arg_is_byref_c(arena, ctx, pty_i, sz_i) != 0)
        is_mem_a[i] = 2;
      fp_slot[i] = -1;
      if (is_mem_a[i] == 2) {
        gp_units[i] = 1;
        if (gp_cur + 1 <= reg_max) {
          gp_start[i] = gp_cur;
          gp_cur = gp_cur + 1;
        } else {
          gp_start[i] = -1;
        }
      } else if (backend_call_dispatch_glue_aapcs64_hfa_nregs_c(arena, ctx, pty_i) != 0) {
        hn = backend_call_dispatch_glue_aapcs64_hfa_nregs_c(arena, ctx, pty_i);
        gp_units[i] = hn;
        gp_start[i] = -1;
        if (fp_cur + hn <= 8) {
          fp_slot[i] = fp_cur;
          fp_cur = fp_cur + hn;
        }
      } else if (backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, ar_i, pty_i) != 0
                 || backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, ar_i, pty_i) != 0) {
        gp_units[i] = 1;
        gp_start[i] = -1;
        if (fp_cur < 8) {
          fp_slot[i] = fp_cur;
          fp_cur = fp_cur + 1;
        }
      } else {
        u = glue_sysv_arg_gp_units_from_size_c(sz_i);
        if (u < 1)
          u = 1;
        if (u > 2)
          u = 2;
        gp_start[i] = gp_cur;
        gp_units[i] = u;
        if (gp_cur + u <= reg_max)
          gp_cur = gp_cur + u;
        else
          gp_start[i] = -1;
      }
      i = i + 1;
    }

    i = 0;
    while (i < nargs) {
      if (gp_start[i] >= 0 || fp_slot[i] >= 0) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        if (arg_ref != 0) {
          home_off = -1;
          if (is_mem_a[i] == 2) {
            if (backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c(
                    arena, elf_ctx, ctx, arg_ref, arg_sz_a[i], ta) != 0)
              return -1;
            so_br = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, 1);
            if (so_br < 0)
              return -1;
            spill_off[i] = so_br;
            i = i + 1;
            continue;
          }
          if (fp_slot[i] < 0 && gp_units[i] == 1
              && pipeline_expr_kind_ord_at(arena, arg_ref) == 3) {
            home_off = find_home_off(arena, ctx, arg_ref);
          }
          if (home_off >= 0) {
            spill_off[i] = home_off;
          } else {
            if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
              return -1;
            so = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(
                elf_ctx, ctx, ta, gp_units[i]);
            if (so < 0)
              return -1;
            spill_off[i] = so;
          }
        }
      }
      i = i + 1;
    }

    stk_pos = 0;
    i = 0;
    while (i < nargs) {
      if (gp_start[i] < 0 && fp_slot[i] < 0) {
        arg_ref2 = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        if (arg_ref2 != 0) {
          if (is_mem_a[i] == 2) {
            poff = backend_call_dispatch_glue_call_stk_extra_align(stk_pos, 8, ta);
            if (backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c(
                    arena, elf_ctx, ctx, arg_ref2, arg_sz_a[i], ta) != 0)
              return -1;
            if (backend_enc_store_arg_sp_offset_arch(elf_ctx, poff, 8, ta) != 0)
              return -1;
            stk_pos = backend_call_dispatch_glue_call_stk_extra_advance(poff, 8, ta);
          } else if (is_mem_a[i] != 0) {
            moff = backend_call_dispatch_glue_call_stk_extra_align(stk_pos, arg_sz_a[i], ta);
            stored = pipeline_asm_store_memory_by_value_to_sp_elf_c(
                arena, elf_ctx, ctx, arg_ref2, arg_sz_a[i], ta, moff);
            if (stored < 0)
              return -1;
            stk_pos = backend_call_dispatch_glue_call_stk_extra_advance(moff, stored, ta);
          } else {
            aoff = backend_call_dispatch_glue_call_stk_extra_align(stk_pos, arg_sz_a[i], ta);
            if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref2, i, ctx, ta) != 0)
              return -1;
            if (backend_enc_store_arg_sp_offset_arch(elf_ctx, aoff, arg_sz_a[i], ta) != 0)
              return -1;
            stk_pos = backend_call_dispatch_glue_call_stk_extra_advance(aoff, arg_sz_a[i], ta);
          }
        }
      }
      i = i + 1;
    }

    i = 0;
    while (i < nargs) {
      if (fp_slot[i] >= 0 && spill_off[i] >= 0) {
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off[i], ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, fp_slot[i], ta) != 0)
          return -1;
      }
      i = i + 1;
    }
    i = nargs - 1;
    while (i >= 0) {
      if (spill_off[i] >= 0 && gp_start[i] >= 0) {
        if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(
                elf_ctx, ta, spill_off[i], gp_start[i], gp_units[i]) != 0)
          return -1;
      }
      i = i - 1;
    }
    pipeline_asm_emit_set_call_param_type_ref(0);
    return 0;
  }

  if (ta == 0) {
    gp_cur = sret_sh;
    /* xmm_cur reused as fp_cur */
    fp_cur = 0;
    i = 0;
    while (i < nargs) {
      ar_i = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      pty_i = glue_call_param_type_ref_at(arena, expr_ref, i);
      is_sse[i] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, ar_i, pty_i);
      is_f64[i] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, ar_i, pty_i);
      spill_off[i] = -1;
      if (is_sse[i] != 0) {
        win_fb = 0;
        if (link_abi_host_is_windows() != 0)
          win_fb = 1;
        if (win_fb != 0) {
          use_xmm_b = 0;
          slot_b = 0;
          w1547_win_place_float(&gp_cur, &use_xmm_b, &slot_b);
          gp_start[i] = slot_b;
          gp_units[i] = 1;
          if (use_xmm_b == 0)
            is_sse[i] = 0;
        } else if (fp_cur < 8) {
          gp_start[i] = fp_cur;
          gp_units[i] = 1;
          fp_cur = fp_cur + 1;
        } else {
          gp_start[i] = -1;
          gp_units[i] = 0;
        }
      } else {
        sz_i = glue_sysv_arg_byte_size_c(arena, ctx, pty_i, ar_i);
        if (backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(sz_i) != 0) {
          gp_start[i] = -1;
          gp_units[i] = 0;
        } else {
          u = glue_sysv_arg_gp_units_from_size_c(sz_i);
          gp_start[i] = gp_cur;
          gp_units[i] = u;
          if (u > 0) {
            if (gp_cur + u <= reg_max)
              gp_cur = gp_cur + u;
            else
              gp_start[i] = -1;
          } else {
            gp_start[i] = -1;
          }
        }
      }
      i = i + 1;
    }

    i = 0;
    while (i < nargs) {
      if (gp_start[i] >= 0) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        if (arg_ref != 0) {
          home_off = -1;
          if (is_sse[i] == 0 && gp_units[i] == 1
              && pipeline_expr_kind_ord_at(arena, arg_ref) == 3
              && backend_call_dispatch_w1521_win_mem_byref_sz(
                     glue_sysv_arg_byte_size_c(
                         arena, ctx, glue_call_param_type_ref_at(arena, expr_ref, i), arg_ref)) == 0) {
            home_off = find_home_off(arena, ctx, arg_ref);
          }
          if (home_off >= 0) {
            spill_off[i] = home_off;
          } else {
            if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
              return -1;
            so = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(
                elf_ctx, ctx, ta, gp_units[i]);
            if (so < 0)
              return -1;
            spill_off[i] = so;
          }
        }
      }
      i = i + 1;
    }

    i = 0;
    while (i < nargs) {
      if (spill_off[i] >= 0) {
        if (is_sse[i] != 0) {
          if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off[i], ta) != 0)
            return -1;
          if (is_f64[i] != 0) {
            if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, gp_start[i], ta) != 0)
              return -1;
          } else if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, gp_start[i], ta) != 0) {
            return -1;
          }
        } else {
          if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(
                  elf_ctx, ta, spill_off[i], gp_start[i], gp_units[i]) != 0)
            return -1;
        }
      }
      i = i + 1;
    }
    if (backend_call_dispatch_w1546_reload_call_sret_arg0(elf_ctx, sret_park, ta) != 0)
      return -1;
    if (backend_call_dispatch_w1545_pend_rcx_emit(elf_ctx, expr_ref) != 0)
      return -1;
    pipeline_asm_emit_set_call_param_type_ref(0);
    return 0;
  }

  pipeline_asm_emit_set_call_param_type_ref(0);
  return 0;
}
