/* Host-gcc twin of glue_emit_call_args_elf_sysv_f32_xmm_c
 * (backend_call_dispatch.x). typool first-wins T 0x1403fb42c typool of
 * i32[96] locals does typool shallow-lea + scale-4 then push of a stack
 * address over a caller retaddr (writer RIP typool 0x1403fdba3).
 * Do not idx8. */
#include <stdint.h>

extern int32_t glue_sysv_x86_call_n_stack_c(uint8_t *arena, int32_t er, int32_t nargs);
extern int32_t backend_enc_call_stack_reserve_arch(uint8_t *elf, int32_t bytes, int32_t ta);
extern void glue_sysv_x86_call_arg_slot_c(uint8_t *arena, int32_t er, int32_t nargs, int32_t i,
                                          int32_t *kind, int32_t *reg_k, int32_t *stack_k);
extern int32_t backend_enc_mov_imm32_to_w0_arch(uint8_t *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(uint8_t *elf, int32_t ta);
extern int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t er, int32_t i);
extern int32_t glue_call_param_type_ref_at(uint8_t *arena, int32_t er, int32_t i);
extern int32_t glue_sysv_arg_byte_size_c(uint8_t *arena, uint8_t *ctx, int32_t pty, int32_t arg_ref);
extern int32_t backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(int32_t sz);
extern int32_t pipeline_asm_push_sysv_memory_by_value_elf_c(
    uint8_t *arena, uint8_t *elf, uint8_t *ctx, int32_t arg_ref, int32_t sz, int32_t ta);
extern int32_t glue_emit_one_call_arg_elf_c(
    uint8_t *arena, uint8_t *elf, int32_t er, int32_t arg_ref, int32_t i, uint8_t *ctx, int32_t ta);
extern int32_t glue_sysv_arg_gp_units_from_size_c(int32_t sz);
extern int32_t backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(uint8_t *elf, int32_t ta, int32_t u);
extern void pipeline_asm_emit_set_call_f32_xmm(int32_t v);
extern int32_t backend_call_dispatch_glue_arg_ref_is_sse_float_c(uint8_t *arena, int32_t ar, int32_t pty);
extern int32_t backend_call_dispatch_glue_arg_ref_is_f64_width_c(
    uint8_t *arena, uint8_t *ctx, int32_t ar, int32_t pty);
extern int32_t link_abi_host_is_windows(void);
extern void w1547_win_place_float(int32_t *gp_cur, int32_t *use_xmm, int32_t *slot);
extern int32_t glue_asm_call_reg_max(int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t ref);
extern int32_t backend_call_dispatch_w1521_win_mem_byref_sz(int32_t sz);
extern int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t ref);
extern int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t ref);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t ref, uint8_t *out);
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, uint8_t *arena, uint8_t *name, int32_t len);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t len);
extern int32_t backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(
    uint8_t *elf, uint8_t *ctx, int32_t ta, int32_t units);
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(uint8_t *elf, int32_t reg, int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(uint8_t *elf, int32_t reg, int32_t ta);
extern int32_t backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(
    uint8_t *elf, int32_t ta, int32_t spill_off, int32_t gp_start, int32_t gp_units);
extern void pipeline_asm_emit_set_call_param_type_ref(int32_t pty);

int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(
    uint8_t *arena, uint8_t *elf, int32_t er, uint8_t *ctx, int32_t ta, int32_t nargs) {
  int32_t n_stack, stack_reserve, n_stk_push, i, si, kind, reg_k, stack_k;
  int32_t arg_ref, pty_s, sz_s, pushed_s, u_s;
  int32_t gp_cur_f, xmm_cur_f, win_f, use_xmm_f, slot_f, sz_f, u_f, rm_f;
  int32_t ar_f, pty_f, home_off_f, arg_ty_f, arg_tk_f, vlen_f, so_f;
  int32_t stk_push[96];
  int32_t gp_start_f[96], gp_units_f[96], spill_off_f[96], is_sse_f[96], is_f64_f[96];
  uint8_t vname_f[256];

  if (!arena || !elf || !ctx || nargs < 0 || nargs > 96)
    return -1;

  n_stack = glue_sysv_x86_call_n_stack_c(arena, er, nargs);
  stack_reserve = 0;
  if (n_stack > 0) {
    stack_reserve = n_stack * 8;
    if ((n_stack & 1) != 0)
      stack_reserve += 8;
  }
  if (backend_enc_call_stack_reserve_arch(elf, stack_reserve, ta) != 0)
    return -1;

  n_stk_push = 0;
  for (i = 0; i < nargs; i++) {
    kind = reg_k = stack_k = 0;
    glue_sysv_x86_call_arg_slot_c(arena, er, nargs, i, &kind, &reg_k, &stack_k);
    if (kind == 2 && n_stk_push < 96) {
      stk_push[n_stk_push] = i;
      n_stk_push++;
    }
  }
  if (n_stack > 0 && (n_stack & 1) != 0) {
    if (backend_enc_mov_imm32_to_w0_arch(elf, 0, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf, ta) != 0)
      return -1;
  }
  for (si = n_stk_push - 1; si >= 0; si--) {
    i = stk_push[si];
    arg_ref = pipeline_expr_call_arg_ref(arena, er, i);
    if (arg_ref != 0) {
      pty_s = glue_call_param_type_ref_at(arena, er, i);
      sz_s = glue_sysv_arg_byte_size_c(arena, ctx, pty_s, arg_ref);
      if (backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(sz_s) != 0) {
        pushed_s = pipeline_asm_push_sysv_memory_by_value_elf_c(arena, elf, ctx, arg_ref, sz_s, ta);
        if (pushed_s < 0)
          return -1;
      } else if (glue_emit_one_call_arg_elf_c(arena, elf, er, arg_ref, i, ctx, ta) != 0) {
        return -1;
      } else {
        u_s = glue_sysv_arg_gp_units_from_size_c(sz_s);
        if (backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(elf, ta, u_s) < 0)
          return -1;
      }
    }
  }
  pipeline_asm_emit_set_call_f32_xmm(1);

  gp_cur_f = 0;
  xmm_cur_f = 0;
  for (i = 0; i < nargs; i++) {
    ar_f = pipeline_expr_call_arg_ref(arena, er, i);
    pty_f = glue_call_param_type_ref_at(arena, er, i);
    is_sse_f[i] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, ar_f, pty_f);
    is_f64_f[i] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, ar_f, pty_f);
    spill_off_f[i] = -1;
    if (is_sse_f[i] != 0) {
      win_f = (link_abi_host_is_windows() != 0) ? 1 : 0;
      if (win_f != 0) {
        use_xmm_f = 0;
        slot_f = 0;
        w1547_win_place_float(&gp_cur_f, &use_xmm_f, &slot_f);
        gp_start_f[i] = slot_f;
        gp_units_f[i] = 1;
        if (use_xmm_f == 0)
          is_sse_f[i] = 0;
      } else if (xmm_cur_f < 8) {
        gp_start_f[i] = xmm_cur_f;
        gp_units_f[i] = 1;
        xmm_cur_f++;
      } else {
        gp_start_f[i] = -1;
        gp_units_f[i] = 0;
      }
    } else {
      sz_f = glue_sysv_arg_byte_size_c(arena, ctx, pty_f, ar_f);
      if (backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(sz_f) != 0) {
        gp_start_f[i] = -1;
        gp_units_f[i] = 0;
      } else {
        u_f = glue_sysv_arg_gp_units_from_size_c(sz_f);
        gp_start_f[i] = gp_cur_f;
        gp_units_f[i] = u_f;
        if (u_f > 0) {
          rm_f = glue_asm_call_reg_max(0);
          if (rm_f < 1)
            rm_f = 6;
          if (gp_cur_f + u_f <= rm_f)
            gp_cur_f += u_f;
          else
            gp_start_f[i] = -1;
        } else {
          gp_start_f[i] = -1;
        }
      }
    }
  }

  for (i = 0; i < nargs; i++) {
    if (gp_start_f[i] < 0)
      continue;
    arg_ref = pipeline_expr_call_arg_ref(arena, er, i);
    if (arg_ref == 0)
      continue;
    home_off_f = -1;
    if (is_sse_f[i] == 0 && gp_units_f[i] == 1
        && pipeline_expr_kind_ord_at(arena, arg_ref) == 3
        && backend_call_dispatch_w1521_win_mem_byref_sz(
               glue_sysv_arg_byte_size_c(arena, ctx,
                   glue_call_param_type_ref_at(arena, er, i), arg_ref)) == 0) {
      arg_ty_f = pipeline_expr_resolved_type_ref(arena, arg_ref);
      arg_tk_f = 0;
      if (arg_ty_f > 0)
        arg_tk_f = pipeline_type_kind_ord_at(arena, arg_ty_f);
      if (arg_tk_f != 10 && arg_tk_f != 11) {
        vlen_f = pipeline_expr_var_name_len(arena, arg_ref);
        if (vlen_f > 0 && vlen_f <= 255) {
          pipeline_expr_var_name_into(arena, arg_ref, &vname_f[0]);
          home_off_f = asm_ctx_local_find_offset_scoped(ctx, arena, &vname_f[0], vlen_f);
          if (home_off_f < 0)
            home_off_f = asm_ctx_local_find_offset(ctx, &vname_f[0], vlen_f);
        }
      }
    }
    if (home_off_f >= 0) {
      spill_off_f[i] = home_off_f;
    } else {
      if (glue_emit_one_call_arg_elf_c(arena, elf, er, arg_ref, i, ctx, ta) != 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
      so_f = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf, ctx, ta, gp_units_f[i]);
      if (so_f < 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
      spill_off_f[i] = so_f;
    }
  }

  for (i = 0; i < nargs; i++) {
    if (spill_off_f[i] < 0)
      continue;
    if (is_sse_f[i] != 0) {
      if (backend_enc_load_rbp_to_rax_arch(elf, spill_off_f[i], ta) != 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
      if (is_f64_f[i] != 0) {
        if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf, gp_start_f[i], ta) != 0) {
          pipeline_asm_emit_set_call_f32_xmm(0);
          return -1;
        }
      } else if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf, gp_start_f[i], ta) != 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
    } else {
      if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(
              elf, ta, spill_off_f[i], gp_start_f[i], gp_units_f[i]) != 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
    }
  }
  pipeline_asm_emit_set_call_f32_xmm(0);
  pipeline_asm_emit_set_call_param_type_ref(0);
  return 0;
}
