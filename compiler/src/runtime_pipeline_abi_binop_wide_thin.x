// Thin pure override: 64-bit integer MUL, MOD and divisor zero check.
// w1499 (终局待办 10.20): the pabi bodies always emit 32-bit forms
// (arm64 `mul w0,w0,w1`, `sdiv w2`/`msub w0`, `tst w1`; x86 `imul %ebx,%eax`,
// `mov %edx,%eax`, `test %ebx,%ebx`). An i64/u64/usize/isize/pointer product
// or remainder lost its high 32 bits, and a divisor whose low 32 bits are zero
// (2^40) hit the div-zero panic. diag_snap_load_ptr rebuilds the source
// pointer with usize MUL, so every located diagnostic (typeck `-->`, L011 on a
// literal of 4096+ bytes) loaded a truncated pointer and crashed.
// G.7: 32-bit paths match glue_emit_binop_mul_rax_rbx_elf_c,
// pipeline_asm_emit_binop_mod_elf_c, glue_emit_assign_rhs_mod_elf_c and
// pipeline_asm_emit_divisor_zero_check_rbx_elf_c in runtime_pipeline_abi.x
// (same exported symbols; src/runtime_pipeline_abi.x itself is not edited).
// 64-bit paths follow the ADD/SUB REX.W / X-reg model already in pabi.
// g05_relink_env.sh compiles this with the current product (pure asm, no
// host cc) and links it ahead of pabi: Darwin pabi copies are weak, Linux is
// first-wins, Windows weakens pabi_weak and jmp-patches leftovers.
// PLATFORM: SHARED freestanding emit · MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.

export extern function glue_binop_operand_is_64bit_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function glue_binop_operand_is_unsigned_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f32_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function backend_enc_mulsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mulss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rem_mod_unsigned_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_try_binop_left_rax_right_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_binop_var_slot_cache_invalidate_rax(): void;
export extern function glue_binop_var_slot_cache_invalidate_rbx(): void;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern function link_abi_getenv(name: *u8): *u8;

/**
 * True when the expr is an INT_LIT whose i64 value does not fit in i32.
 * Twin of the private glue_binop_expr_is_wide_int_lit_elf_c in pabi.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — expression ref
 * @return i32 — 1 when wide, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1499_expr_is_wide_int_lit(arena: *u8, expr_ref: i32): i32 {
  let ko: i32 = 0;
  let v64: i64 = 0;
  let i32_max: i64 = 2147483647;
  let i32_min: i64 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 0) {
    return 0;
  }
  unsafe {
    v64 = pipeline_expr_int64_val_at(arena, expr_ref);
  }
  i32_min = 0 - 2147483647 - 1;
  if (v64 < i32_min || v64 > i32_max) {
    return 1;
  }
  return 0;
}

/**
 * Whether expr is an i32-fit INT/BOOL literal; writes it to out_imm[0].
 * Twin of the private pipeline_asm_cmp_expr_lit_i32_at in pabi.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — expression ref
 * @param out_imm *i32 — receives the value; null only tests
 * @return i32 — 1 when it is an i32-fit literal, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1499_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32 {
  let ko: i32 = 0;
  let v: i32 = 0;
  if (expr_ref == 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 0 || ko == 2) {
    if (ko == 0 && w1499_expr_is_wide_int_lit(arena, expr_ref) != 0) {
      return 0;
    }
    unsafe {
      v = pipeline_expr_int_val_at(arena, expr_ref);
    }
    if (out_imm != 0 as *i32) {
      unsafe {
        out_imm[0] = v;
      }
    }
    return 1;
  }
  return 0;
}

/**
 * Twin of the private glue_binop_maybe_sxt_i32_result_elf_c in pabi: after a
 * 32-bit MUL, sign-extend when either side is i32 or an unstamped INT_LIT.
 * 64-bit width never gets sxt.
 * @return i32 — 0 ok, non-zero encode failure
 * PLATFORM: SHARED freestanding · MACOS|ARM64 sxtw · x86_64 cdqe.
 */
function w1499_maybe_sxt_i32_result(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32, elf_ctx: *u8, ta: i32): i32 {
  let tr: i32 = 0;
  let k: i32 = 0;
  let need: i32 = 0;
  let ko_l: i32 = 0;
  let ko_r: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8)) {
    return 0;
  }
  unsafe {
    if (glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref) != 0) {
      return 0;
    }
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr > 0) {
      k = pipeline_type_kind_ord_at(arena, tr);
      if (k == 0) {
        need = 1;
      }
    }
    if (need == 0 && ctx != (0 as *u8)) {
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
      if (tr > 0) {
        k = pipeline_type_kind_ord_at(arena, tr);
        if (k == 0) {
          need = 1;
        }
      }
    }
    if (need == 0) {
      tr = pipeline_expr_resolved_type_ref(arena, right_ref);
      if (tr > 0) {
        k = pipeline_type_kind_ord_at(arena, tr);
        if (k == 0) {
          need = 1;
        }
      }
    }
    if (need == 0 && ctx != (0 as *u8)) {
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, right_ref);
      if (tr > 0) {
        k = pipeline_type_kind_ord_at(arena, tr);
        if (k == 0) {
          need = 1;
        }
      }
    }
    if (need == 0) {
      ko_l = pipeline_expr_kind_ord_at(arena, left_ref);
      ko_r = pipeline_expr_kind_ord_at(arena, right_ref);
      if (ko_l == 0 || ko_r == 0) {
        need = 1;
      }
    }
    if (need != 0) {
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    }
  }
  return 0;
}

/**
 * Emit a 64-bit signed or unsigned remainder of rax by rbx into rax.
 * x86_64: cqo; idiv %rbx (or xor %edx,%edx; div %rbx); mov %rdx,%rax.
 * arm64: sdiv/udiv x2,x0,x1; msub x0,x2,x1,x0.
 * Other targets keep the existing rem encoders.
 * @param elf_ctx *u8 — emit context
 * @param is_unsigned i32 — 1 for u64/usize
 * @param ta i32 — 0 x86_64, 1 arm64, 2 riscv64
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED · MACOS|ARM64 X-reg · x86_64 REX.W.
 */
function w1499_emit_rem64(elf_ctx: *u8, is_unsigned: i32, ta: i32): i32 {
  unsafe {
    if (ta == 1) {
      if (is_unsigned != 0) {
        // udiv x2, x0, x1
        if (backend_enc_append_u32_le_c(elf_ctx, 2596341762 as u32) != 0) { return 0 - 1; }
      } else {
        // sdiv x2, x0, x1
        if (backend_enc_append_u32_le_c(elf_ctx, 2596342786 as u32) != 0) { return 0 - 1; }
      }
      // msub x0, x2, x1, x0
      return backend_enc_append_u32_le_c(elf_ctx, 2600566848 as u32);
    }
    if (ta == 0) {
      if (is_unsigned != 0) {
        // xor %edx,%edx (31 d2); div %rbx (48 f7 f3)
        if (backend_enc_append_u8_c(elf_ctx, 49) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 210) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 247) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 243) != 0) { return 0 - 1; }
      } else {
        // cqo (48 99); idiv %rbx (48 f7 fb)
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 153) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 247) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 251) != 0) { return 0 - 1; }
      }
      // mov %rdx,%rax (48 89 d0)
      if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 137) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 208);
    }
    if (is_unsigned != 0) {
      return backend_enc_rem_mod_unsigned_arch(elf_ctx, ta);
    }
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  }
  return 0 - 1;
}

/**
 * Emit a 32-bit signed or unsigned remainder of rax by rbx into rax, with the
 * result widened the way a 32-bit value lives in a register (i32 sign-
 * extended, u32 zero-extended). The pabi rem encoders ran 32-bit sdiv on
 * u32 and left a negative i32 remainder zero-extended.
 * x86_64: movsxd both then cqo; idiv %rbx (or mov %eax,%eax / %ebx,%ebx;
 * xor %edx,%edx; div %rbx); mov %rdx,%rax.
 * arm64: sdiv w2,w0,w1; msub w0,w2,w1,w0; sxtw x0,w0 (udiv and no sxtw for
 * unsigned).
 * @param elf_ctx *u8 — emit context
 * @param is_unsigned i32 — 1 for u8/u16/u32
 * @param ta i32 — 0 x86_64, 1 arm64, 2 riscv64
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED · MACOS|ARM64 W-reg · x86_64 LINUX|WINDOWS.
 */
function w1499_emit_rem32(elf_ctx: *u8, is_unsigned: i32, ta: i32): i32 {
  unsafe {
    if (ta == 1) {
      if (is_unsigned != 0) {
        // udiv w2, w0, w1 ; msub w0, w2, w1, w0
        if (backend_enc_append_u32_le_c(elf_ctx, 448858114 as u32) != 0) { return 0 - 1; }
        return backend_enc_append_u32_le_c(elf_ctx, 453083200 as u32);
      }
      // sdiv w2, w0, w1 ; msub w0, w2, w1, w0 ; sxtw x0, w0
      if (backend_enc_append_u32_le_c(elf_ctx, 448859138 as u32) != 0) { return 0 - 1; }
      if (backend_enc_append_u32_le_c(elf_ctx, 453083200 as u32) != 0) { return 0 - 1; }
      return backend_enc_append_u32_le_c(elf_ctx, 2470476800 as u32);
    }
    if (ta == 0) {
      if (is_unsigned != 0) {
        // mov %eax,%eax ; mov %ebx,%ebx ; xor %edx,%edx ; div %rbx
        if (backend_enc_append_u8_c(elf_ctx, 137) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 137) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 219) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 49) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 210) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 247) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 243) != 0) { return 0 - 1; }
      } else {
        // movsxd %eax,%rax ; movsxd %ebx,%rbx ; cqo ; idiv %rbx
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 99) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 99) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 219) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 153) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 247) != 0) { return 0 - 1; }
        if (backend_enc_append_u8_c(elf_ctx, 251) != 0) { return 0 - 1; }
      }
      // mov %rdx,%rax (48 89 d0)
      if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 137) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 208);
    }
    if (is_unsigned != 0) {
      return backend_enc_rem_mod_unsigned_arch(elf_ctx, ta);
    }
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  }
  return 0 - 1;
}

/**
 * Emit the remainder for one MOD: 64-bit when either operand is 64-bit,
 * otherwise the widened 32-bit remainder.
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED freestanding emit.
 */
function w1499_emit_rem_for(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, is_unsigned: i32, ta: i32): i32 {
  unsafe {
    if (glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref) != 0) {
      return w1499_emit_rem64(elf_ctx, is_unsigned, ta);
    }
    return w1499_emit_rem32(elf_ctx, is_unsigned, ta);
  }
  return 0 - 1;
}

/**
 * Integer/float MUL of rax by rbx (operands already loaded).
 * 64-bit width: x86 `imul %rbx,%rax` (48 0f af c3); arm64 `mul x0,x0,x1`
 * (9b017c00). Otherwise the 32-bit encoder plus i32 sxt, as before.
 * @return i32 — 0 ok, non-zero encode failure
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_binop_mul_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  let rc: i32 = 0;
  unsafe {
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta);
    }
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_mulss_rax_rbx_arch(elf_ctx, ta);
    }
    if ((ta == 0 || ta == 1) && glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref) != 0) {
      if (ta == 1) {
        // mul x0, x0, x1
        return backend_enc_append_u32_le_c(elf_ctx, 2600565760 as u32);
      }
      // imul %rbx, %rax
      if (backend_enc_append_u8_c(elf_ctx, 72) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 175) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 195);
    }
    rc = backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return rc;
  }
  return w1499_maybe_sxt_i32_result(arena, ctx, left_ref, right_ref, elf_ctx, ta);
}

/**
 * Divisor zero check on rbx before DIV/MOD: panic when rbx is zero.
 * The test is 64-bit (x86 `test %rbx,%rbx` 48 85 db; arm64 `tst x1,x1`
 * ea01003f) so a 64-bit divisor such as 2^40 no longer reads as zero.
 * 32-bit values are zero- or sign-extended in rbx, so their result is
 * unchanged. XLANG_PREFER_ASM_O=1 still skips the check.
 * @return i32 — 0 ok, -1 failure
 * PLATFORM: SHARED — Darwin ARM64, Linux/Windows x86_64.
 */
#[no_mangle]
export function pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32): i32 {
  if (elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0;
  }
  unsafe {
    let pe: *u8 = link_abi_getenv("XLANG_PREFER_ASM_O");
    if (pe != (0 as *u8) && pe[0] == 49) {
      return 0;
    }
  }
  let ok_lbl: u8[256] = [];
  let ok_len: i32 = 0;
  unsafe {
    ok_len = pipeline_asm_emit_next_label_c(ctx, &ok_lbl[0], 64);
  }
  if (ok_len <= 0) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    if (ta == 1) {
      rc = backend_enc_append_u32_le_c(elf_ctx, 3925934143 as u32);
    } else if (ta == 0) {
      rc = backend_enc_append_u8_c(elf_ctx, 72);
      if (rc == 0) {
        rc = backend_enc_append_u8_c(elf_ctx, 133);
      }
      if (rc == 0) {
        rc = backend_enc_append_u8_c(elf_ctx, 219);
      }
    } else {
      rc = backend_enc_test_rbx_rbx_arch(elf_ctx, ta);
    }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_jne_arch(elf_ctx, &ok_lbl[0], ok_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &ok_lbl[0], ok_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Integer MOD: left in rax, right in rbx, remainder in rax.
 * Same three placement paths as pabi (i32 literal divisor, cached
 * left/right placement, push/pop); the remainder is 64-bit when either
 * operand is 64-bit.
 * @return i32 — 0 ok, -1 failure
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_binop_mod_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let lit_slot: i32[1] = [];
    let lit_imm: i32 = 0;
    let vr: i32 = 0;
    let is_unsigned: i32 = 0;
    is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
    if (w1499_expr_lit_i32_at(arena, right_ref, &lit_slot[0]) != 0) {
      lit_imm = lit_slot[0];
      if (lit_imm == 0) {
        return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
      }
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
      glue_binop_var_slot_cache_invalidate_rbx();
      if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0) {
        return 0 - 1;
      }
      if (w1499_emit_rem_for(arena, elf_ctx, ctx, left_ref, right_ref, is_unsigned, ta) != 0) {
        return 0 - 1;
      }
      glue_binop_var_slot_cache_invalidate_rax();
      glue_binop_var_slot_cache_invalidate_rbx();
      return 0;
    }
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == 0 - 1) {
      return 0 - 1;
    }
    if (vr == 0) {
      if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0) {
        return 0 - 1;
      }
      if (w1499_emit_rem_for(arena, elf_ctx, ctx, left_ref, right_ref, is_unsigned, ta) != 0) {
        return 0 - 1;
      }
      glue_binop_var_slot_cache_invalidate_rax();
      glue_binop_var_slot_cache_invalidate_rbx();
      return 0;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (w1499_emit_rem_for(arena, elf_ctx, ctx, left_ref, right_ref, is_unsigned, ta) != 0) {
      return 0 - 1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    return 0;
  }
}

/**
 * Compound `%=` arm: zero check, then the remainder. 64-bit operands use
 * the 64-bit remainder, 32-bit operands the widened 32-bit one (unsigned
 * when either side is unsigned).
 * @return i32 — 0 ok, -1 failure
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 · WINDOWS.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mod_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref) != 0) {
      return w1499_emit_rem64(elf_ctx, glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref), ta);
    }
    return w1499_emit_rem32(elf_ctx, glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref), ta);
  }
}
