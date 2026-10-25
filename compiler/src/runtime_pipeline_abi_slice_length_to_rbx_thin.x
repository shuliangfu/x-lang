// Cap tip／tip-cold thin: glue_emit_slice_length_to_rbx_elf_c — 10.22
// INDEX(47)/DEREF(52)/any TYPE_SLICE rvalue: dual-GP length (x1/rdx),
// not *(data+8). Fixes dyn_add_arr_slice p[0][i] panic:0/run1.
// G.7: first-win over mega T. No FORCE_CC / new host-cc .c.
// PLATFORM: SHARED freestanding · MACOS Cap tip · LINUX tip-cold.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, buf: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, len: i32): i32;
export extern function glue_local_var_slot_needs_ptr_load_elf_c(arena: *u8, base_ref: i32, off: i32, ctx: *u8): i32;
export extern function glue_slice_dual_gp_length_off_c(off: i32, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_arg_reg_to_rax_arch(elf_ctx: *u8, arg_reg: i32, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena: *u8, expr_ref: i32): i32;

/**
 * Slice base length → rbx ({data,length} home, *slice param, FIELD fat home, or dual-GP call).
 * Bounds guard holds index in rax; emit of base that clobbers rax must push/pop.
 * FIELD (44) bases use lvalue fat address + length@+8 (not emit_expr peel of .data).
 * @return i32 - 0 ok; -1 error
 * wave147 pure: G.7 authority (was static glue_emit_slice_length_to_rbx_elf_c).
 * PLATFORM: SHARED freestanding · LINUX gold · dual-GP polarity via glue_slice_dual_gp_length_off_c.
 */
#[no_mangle]
export function glue_emit_slice_length_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, base_ref: i32): i32 {
  let base_ko: i32 = 0;
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let off: i32 = 0;
  let bty: i32 = 0;
  let btk: i32 = 0;
  let needs_ptr: i32 = 0;
  let len_off: i32 = 0;
  let nd: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (base_ko == 3) {
    unsafe {
      vlen = pipeline_expr_var_name_len(arena, base_ref);
    }
    if (vlen <= 0 || vlen > 255) {
      return 0 - 1;
    }
    unsafe {
      pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
      off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    }
    if (off < 0) {
      unsafe {
        off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
      }
    }
    if (off < 0) {
      return 0 - 1;
    }
    unsafe {
      needs_ptr = glue_local_var_slot_needs_ptr_load_elf_c(arena, base_ref, off, ctx);
    }
    if (needs_ptr != 0) {
      // wave332d: preserve rax (index live) across length load for *slice param
      unsafe {
        rc = backend_enc_push_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_pop_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    unsafe {
      len_off = glue_slice_dual_gp_length_off_c(off, ta);
      return backend_enc_load_rbp_to_rbx_arch(elf_ctx, len_off, ta);
    }
  }
  // FIELD base (44): by-value nested fat (e.g. sp.left[i]). Keep fat home address
  // and load length@+8. Do NOT emit_expr rvalue then +8 — that peels .data as a
  // pointer (and may load 32-bit), SEGV on *(data+8). Index stays live in rax.
  // PLATFORM: SHARED freestanding INDEX bounds on nested TYPE_SLICE fields.
  if (base_ko == 44) {
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  // non-VAR slice base (esp. CALL take()[1]) — index live in rax
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    bty = pipeline_expr_resolved_type_ref(arena, base_ref);
  }
  if (bty > 0) {
    unsafe {
      btk = pipeline_type_kind_ord_at(arena, bty);
    }
  } else {
    btk = 0;
  }
  // 10.22: INDEX(47)/DEREF(52)/any TYPE_SLICE rvalue also returns dual-GP
  // {data,len}; *(data+8) peels .data and panics (dyn_add_arr_slice p[0][0]).
  // CALL(48) still checks struct16-ret needs rax deref. PLATFORM: SHARED.
  if (bty > 0 && btk == 11) {
    if (base_ko == 48) {
      unsafe {
        nd = pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, base_ref);
      }
    } else {
      nd = 0;
    }
    if (nd == 0) {
      // SysV arg_reg 2 = rdx — length half after dual-GP return
      unsafe {
        rc = backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 2, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_pop_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
  }
  unsafe {
    rc = backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

