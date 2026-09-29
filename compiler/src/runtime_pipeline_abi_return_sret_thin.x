// Thin pure overlay (w1521, 终局待办 10.57): EXPR_RETURN ELF impl with the
// AAPCS64 indirect-result copy. Darwin's live impl (pabi_weak strong) only
// evaluated the operand into x0 and jumped to tail_join; for a function
// returning > 16 bytes nothing ever reached the caller's x8 buffer, so the
// caller read a pointer into the dead callee frame (bus error / garbage).
// Here, after the operand (x0 = address of the value: temp slot, &local, or
// a callee's result), the value is copied into the dest pointer parked at
// the sret home (w499_mega_emit_frame) and x0 is set to that dest. Inline
// qword+byte copy through x9/x10 (no memcpy call: leaf frames, src==dst ok).
// Same exit otherwise as runtime_pipeline_abi_return_elf_impl_thin.x.
// Linked by g05_relink_env (_g05_pure_overlay return_sret) before seeds;
// pabi_weak.o _pipeline_asm_emit_return_elf_impl weakened.
// x86_64 SysV (Linux, w1521): `return v` with a > 16-byte local only did
// mov rax,[v]. The overlay takes lea rax,[rbp-off] for a local VAR operand,
// copies into the dest parked at [rbp-home] (rdi homed by the frame), and
// returns the dest in rax. Windows x64 (w1521): same copy; the hidden dest
// arrives in rcx and is homed by win_param_home_thin; rcx/rdx are volatile.
// PLATFORM: MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.

export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function link_abi_host_is_windows(): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(shift: i32): void;
export extern function pipeline_asm_set_call_expected_ret_ty_c(type_ref: i32): void;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;

/**
 * `return f(...)` forwarding a > 16-byte result: pass this function's own
 * dest ([rbp-home]) as the callee's hidden rdi (shift 1, same as the
 * let-init sret path), then rax = dest. @return 0 ok; -1 fail.
 * PLATFORM: LINUX x86_64.
 */
function w1521_rs_fwd_call_x86(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, home: i32): i32 {
  let rc: i32 = 0;
  let ty: i32 = 0;
  unsafe {
    ty = pipeline_expr_resolved_type_ref(arena, op);
    if (ty > 0) {
      pipeline_asm_set_call_expected_ret_ty_c(ty);
    } else {
      pipeline_asm_set_call_expected_ret_ty_c(0);
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return 0 - 1;
    }
    pipeline_asm_emit_set_call_sret_reg_shift_c(1);
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    pipeline_asm_emit_set_call_sret_reg_shift_c(0);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (rc != 0) {
      return 0 - 1;
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/** Append one byte. PLATFORM: LINUX x86_64. */
function w1521_rs_b(elf_ctx: *u8, v: i32): i32 {
  let b: u8[1] = [];
  b[0] = (v & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 1);
  }
  return 0 - 1;
}

/** Append a little-endian disp32. PLATFORM: LINUX x86_64. */
function w1521_rs_d32(elf_ctx: *u8, v: i32): i32 {
  let b: u8[4] = [];
  b[0] = (v & 255) as u8;
  b[1] = ((v >> 8) & 255) as u8;
  b[2] = ((v >> 16) & 255) as u8;
  b[3] = ((v >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
  }
  return 0 - 1;
}

/**
 * Local VAR operand frame offset (rbp-off), or -1 when the operand is not a
 * plain local. PLATFORM: LINUX x86_64.
 */
function w1521_rs_local_off(arena: *u8, ctx: *u8, op: i32): i32 {
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let off: i32 = 0 - 1;
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, op) != 3) {
      return 0 - 1;
    }
    vlen = pipeline_expr_var_name_len(arena, op);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, op, &vname[0]);
    off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    if (off < 0) {
      off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
    }
  }
  return off;
}

/**
 * rax = source address. mov rcx,[rbp-home]; copy sz bytes rax to rcx via
 * rdx/dl; mov rax,rcx. @return 0 ok; 1 not applicable; -1 encoder fail.
 * PLATFORM: LINUX x86_64.
 */
function w1521_rs_copy_x86(elf_ctx: *u8, home: i32, sz: i32): i32 {
  let k: i32 = 0;
  if (home <= 0 || sz <= 16 || sz > 1000000) {
    return 1;
  }
  // mov rcx, [rbp - home]
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 141) != 0) { return 0 - 1; }
  if (w1521_rs_d32(elf_ctx, 0 - home) != 0) { return 0 - 1; }
  while (k + 8 <= sz) {
    // mov rdx, [rax + k] ; mov [rcx + k], rdx
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    k = k + 8;
  }
  while (k < sz) {
    // movzx edx, byte [rax + k] ; mov [rcx + k], dl
    if (w1521_rs_b(elf_ctx, 15) != 0 || w1521_rs_b(elf_ctx, 182) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 136) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    k = k + 1;
  }
  // mov rax, rcx
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 200) != 0) { return 0 - 1; }
  return 0;
}

/** Append one little-endian arm64 instruction word. PLATFORM: MACOS|ARM64. */
function w1521_rs_a64(elf_ctx: *u8, word: i64): i32 {
  let b: u8[4] = [];
  b[0] = (word & 255) as u8;
  b[1] = ((word >> 8) & 255) as u8;
  b[2] = ((word >> 16) & 255) as u8;
  b[3] = ((word >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
  }
  return 0 - 1;
}

/**
 * x0 = source address. ldr x9,[x29,#home]; copy sz bytes x0 to x9 via x10;
 * mov x0,x9. @return 0 ok; 1 not applicable; -1 encoder fail.
 * PLATFORM: MACOS|ARM64.
 */
function w1521_rs_copy_to_dest(elf_ctx: *u8, home: i32, sz: i32): i32 {
  let k: i32 = 0;
  if (home < 0 || home > 32760 || (home % 8) != 0 || sz <= 16 || sz > 32000) {
    return 1;
  }
  // ldr x9, [x29, #home]
  if (w1521_rs_a64(elf_ctx, 4181722025 + (((home / 8) as i64) << 10)) != 0) { return 0 - 1; }
  k = 0;
  while (k + 8 <= sz) {
    // ldr x10, [x0, #k] ; str x10, [x9, #k]
    if (w1521_rs_a64(elf_ctx, 4181721098 + (((k / 8) as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 4177527082 + (((k / 8) as i64) << 10)) != 0) { return 0 - 1; }
    k = k + 8;
  }
  while (k < sz) {
    // ldrb w10, [x0, #k] ; strb w10, [x9, #k]
    if (w1521_rs_a64(elf_ctx, 960495626 + ((k as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 956301610 + ((k as i64) << 10)) != 0) { return 0 - 1; }
    k = k + 1;
  }
  // mov x0, x9
  if (w1521_rs_a64(elf_ctx, 2852717536) != 0) { return 0 - 1; }
  return 0;
}

/**
 * EXPR_RETURN ELF emit: operand into rax/x0, arm64 sret copy, then jmp
 * function tail_join (AsmFuncCtxLayout name at 1392, length at 1520).
 * @return 0 ok; -1 encoder/null/missing tail_join. PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let ly: *u8 = 0 as *u8;
  let ret_op: i32 = 0;
  let rc: i32 = 0;
  let tj_len: i32 = 0;
  let tj_lbl: u8[256] = [];
  let ti: i32 = 0;
  let act: i32 = 0;
  let home: i32 = 0 - 1;
  let rsz: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
    ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (ret_op != 0) {
    let x86_off: i32 = 0 - 1;
    let x86_fwd: i32 = 0;
    let opk: i32 = 0;
    if (ta == 0) {
      unsafe {
        act = pipeline_asm_emit_ctx_sret_active_get();
        home = pipeline_asm_emit_ctx_sret_home_off_get();
        rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
        if (act != 0 && home > 0 && rsz > 16) {
          x86_off = w1521_rs_local_off(arena, ctx, ret_op);
          opk = pipeline_expr_kind_ord_at(arena, ret_op);
          if (opk == 48 || opk == 49) {
            x86_fwd = 1;
          }
        }
      }
    }
    if (x86_fwd != 0) {
      if (w1521_rs_fwd_call_x86(arena, elf_ctx, ret_op, ctx, ta, home) != 0) {
        return 0 - 1;
      }
    } else if (x86_off >= 0) {
      unsafe {
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, x86_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (w1521_rs_copy_x86(elf_ctx, home, rsz) < 0) {
        return 0 - 1;
      }
    } else {
      unsafe {
        rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      // w1521: Windows builds a > 16-byte STRUCT_LIT (or other aggregate
      // operand) in a frame temp and leaves its address in rax; copy it into
      // the hidden dest (Linux pabi writes the dest itself). PLATFORM: WINDOWS.
      if (ta == 0 && act != 0 && home > 0 && rsz > 16) {
        let on_win: i32 = 0;
        unsafe {
          on_win = link_abi_host_is_windows();
        }
        if (on_win != 0) {
          if (w1521_rs_copy_x86(elf_ctx, home, rsz) < 0) {
            return 0 - 1;
          }
        }
      }
    }
    if (ta == 1) {
      unsafe {
        act = pipeline_asm_emit_ctx_sret_active_get();
        home = pipeline_asm_emit_ctx_sret_home_off_get();
        rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
      }
      if (act != 0 && home >= 0 && rsz > 16) {
        if (w1521_rs_copy_to_dest(elf_ctx, home, rsz) < 0) {
          return 0 - 1;
        }
      }
    }
  }
  unsafe {
    rc = glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_async_cps_emit_phase_reset(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (ly == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    tj_len = pipe_load_i32_le(ly, 1520);
  }
  if (tj_len <= 0) {
    return 0 - 1;
  }
  ti = 0;
  while (ti < tj_len && ti < 128) {
    unsafe {
      tj_lbl[ti] = ly[1392 + ti];
    }
    ti = ti + 1;
  }
  unsafe {
    return backend_enc_jmp_arch(elf_ctx, &tj_lbl[0], tj_len, ta);
  }
}
