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
// w1546: same object also overrides glue_try_emit_mixed_f32_f64_arith_elf_c.
// The egg body returns -2 when ta != 0 and only promotes f32 next to f64, so
// `f64 * integer` (lexer `frac * (d - 48)`) fell through to a 32-bit integer
// mul and kept only the low half of the f64 bit pattern. The override accepts
// ta 0 and 1, leaves both-f64, both-f32, and integer×integer on the existing
// paths, and converts the integer side before addsd/subsd/mulsd/divsd.
// f32×integer stays -2. Do not edit runtime_pipeline_abi.x for this symbol.
// w1595: an i32 on the left hides an i64 variable from the pair helper, so
// the product stayed on `imul %ebx,%eax` plus cltq and lost the high half.
// A left i32 literal is parked in rbx and the wide value is in rax. Every
// other hidden-width case leaves the i32 in rax and the i64 in rbx. Both
// shapes emit the 64-bit multiply and skip cltq. u32 and u8 stay on the
// 32-bit imul. A wide left already takes the 64-bit arm.
// PLATFORM: SHARED freestanding emit · MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.
// LINUX installs this object. Darwin and Windows keep the previous body
// until they relink.

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
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_addsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_subsd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_divsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;

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
 * Type kind of one operand, or -1 when it has no type ref.
 * Resolved type wins. A VAR with an empty stamp uses its declaration.
 * The pair helper stops at the first typed operand, so a right-hand i64
 * next to a left-hand i32 is invisible there. This predicate reads each
 * side on its own. Pointers stay kind 9 and are not wide integers.
 * @param arena *u8 — AST arena; null returns -1
 * @param ctx *u8 — emit context for the VAR declaration; null skips that fallback
 * @param expr_ref i32 — operand expression; <=0 returns -1
 * @return i32 — type kind, or -1
 * PLATFORM: SHARED freestanding emit.
 */
function w1595_operand_kind(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let tr: i32 = 0;
  let kind: i32 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (tr <= 0 && ctx != (0 as *u8)) {
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
    }
    if (tr <= 0) {
      return 0 - 1;
    }
    kind = pipeline_type_kind_ord_at(arena, tr);
  }
  return kind;
}

/**
 * True when the operand is a 64-bit integer, not a pointer.
 * u64, i64, usize, and isize count. Kind 9 stays on the pointer path.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context
 * @param expr_ref i32 — one operand
 * @return i32 — 1 when the operand is a wide integer, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1595_is_wide_int(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let kind: i32 = 0;
  kind = w1595_operand_kind(arena, ctx, expr_ref);
  if (kind == 4 || kind == 5 || kind == 6 || kind == 7) {
    return 1;
  }
  return 0;
}

/**
 * True when expr is an INT_LIT that fits in i32.
 * The mul literal shortcut parks that immediate in rbx with a
 * zero-extending mov. A wide literal is not this case.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — expression ref
 * @return i32 — 1 when it is an i32-fit literal, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1595_is_narrow_lit(arena: *u8, expr_ref: i32): i32 {
  let ko: i32 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 0) {
    return 0;
  }
  if (w1499_expr_is_wide_int_lit(arena, expr_ref) != 0) {
    return 0;
  }
  return 1;
}

/**
 * Sign-extend the i32 in rbx to 64 bits and restore rax.
 * The lit encoder writes mov imm32 to ebx, which zero-extends.
 * cdqe runs on rax, so rbx moves through rax around the saved value.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED — x86_64 cdqe and arm64 sxtw.
 */
function w1595_sxt_rbx(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Emit rax = rax * rbx at 64-bit width and leave the high half in place.
 * x86 bytes are 48 0f af c3 (`imulq %rbx, %rax`). arm64 is `mul x0, x0, x1`
 * (word 0x9B017C00). No following cltq.
 * @param elf_ctx *u8 — encoder context; null is rejected by append
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED — x86_64 REX.W imul and arm64 MUL X.
 */
function w1595_emit_wide_mul(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2600565760 as u32);
    }
  }
  unsafe {
    if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c(elf_ctx, 175) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c(elf_ctx, 195);
  }
}

/**
 * Integer or float MUL of the values already in rax and rbx.
 * Same both-f64 and both-f32 arms as before. A wide operand still uses
 * the 64-bit multiply. When the pair helper misses a right-hand i64
 * because the left operand is an i32, sign-extend that i32 and multiply
 * at 64 bits with no cltq. A left i32 literal is the value in rbx; every
 * other i32 left is the value in rax. u32 and u8 stay on the 32-bit imul.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left expression; rax for a variable, rbx for an i32 literal
 * @param right_ref i32 — right expression; rbx for a variable
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, nonzero encode failure
 * PLATFORM: SHARED — x86_64 imulq and arm64 MUL X. LINUX links this body.
 */
#[no_mangle]
export function glue_emit_binop_mul_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  let rc: i32 = 0;
  let is_64bit: i32 = 0;
  let left_kind: i32 = 0;
  unsafe {
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta);
    }
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_mulss_rax_rbx_arch(elf_ctx, ta);
    }
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  }
  // Left i32 literal: rbx holds the immediate, rax holds the wide value.
  // Sign-extend rbx before imulq. cdqe on rax would wipe the wide half.
  if ((ta == 0 || ta == 1) && w1595_is_narrow_lit(arena, left_ref) != 0 && w1595_is_wide_int(arena, ctx, right_ref) != 0) {
    if (w1595_sxt_rbx(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return w1595_emit_wide_mul(elf_ctx, ta);
  }
  // i32 in rax, hidden i64 in rbx. The slot load is often already
  // sign-extended; cdqe keeps a negative i32 negative. Skip cltq.
  if ((ta == 0 || ta == 1) && is_64bit == 0 && w1595_is_wide_int(arena, ctx, right_ref) != 0) {
    left_kind = w1595_operand_kind(arena, ctx, left_ref);
    if (left_kind == 0) {
      unsafe {
        if (glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
      }
      return w1595_emit_wide_mul(elf_ctx, ta);
    }
  }
  unsafe {
    if ((ta == 0 || ta == 1) && is_64bit != 0) {
      return w1595_emit_wide_mul(elf_ctx, ta);
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

/**
 * Scalar integer type-kind of one binop operand, or -1 when it is not one.
 * The resolved type wins. A VAR whose resolved type is empty uses its decl
 * type. An INT_LIT (expr kind 0) with no resolved type is i32 (kind 0).
 * Accepted kinds are i32=0, u8=2, u32=3, u64=4, i64=5, usize=6, isize=7, and
 * kind 8 (the existing `as f64` path treats kind 8 like i32). bool (1) and
 * pointer (9) return -1 so the caller leaves them on the integer path.
 * @param arena *u8 — AST arena; null returns -1
 * @param ctx *u8 — emit context; used only for the VAR decl fallback
 * @param expr_ref i32 — operand expression; <=0 returns -1
 * @return i32 — type kind, or -1
 * PLATFORM: SHARED freestanding emit.
 */
function w1546_binop_int_kind(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let tr: i32 = 0;
  let ko: i32 = 0;
  let kind: i32 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  if (tr <= 0) {
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    }
    // INT_LIT with no resolved type is the i32 literal fallback.
    if (ko == 0) {
      return 0;
    }
    if (ko == 3 && ctx != (0 as *u8)) {
      unsafe {
        tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
      }
    }
  }
  if (tr <= 0) {
    return 0 - 1;
  }
  unsafe {
    kind = pipeline_type_kind_ord_at(arena, tr);
  }
  if (kind == 0 || kind == 2 || kind == 3 || kind == 4 || kind == 5 || kind == 6 || kind == 7 || kind == 8) {
    return kind;
  }
  return 0 - 1;
}

/**
 * Convert the integer bit pattern in rax into an f64 bit pattern in rax.
 * u64, usize, and u32 use the unsigned 64-bit converter. A 32-bit result is
 * already zero-extended, so u32 must not take the signed 32-bit converter
 * (values >= 2^31 would become negative). i64 and isize use the signed
 * 64-bit converter. i32, u8, and kind 8 use the signed 32-bit converter.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @param kind i32 — type kind from w1546_binop_int_kind
 * @return i32 — 0 when the converter is appended, non-zero on encode failure
 * PLATFORM: SHARED — x86_64 cvtsi2sd and arm64 scvtf/ucvtf.
 */
function w1546_emit_int_kind_to_f64_rax(elf_ctx: *u8, ta: i32, kind: i32): i32 {
  unsafe {
    if (kind == 4 || kind == 6 || kind == 3) {
      return backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx, ta);
    }
    if (kind == 5 || kind == 7) {
      return backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx, ta);
    }
    return backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx, ta);
  }
}

/**
 * Promote the value in rax to f64 bits.
 * is_f32 selects cvtss2sd. int_kind >= 0 selects the integer converter.
 * Both clear means the value is already f64 and this is a no-op.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @param is_f32 i32 — non-zero when rax holds f32 bits
 * @param int_kind i32 — integer type kind, or -1 when rax is not an integer
 * @return i32 — 0 ok, non-zero encode failure
 * PLATFORM: SHARED freestanding emit.
 */
function w1546_promote_rax_to_f64(elf_ctx: *u8, ta: i32, is_f32: i32, int_kind: i32): i32 {
  if (is_f32 != 0) {
    unsafe {
      return backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta);
    }
  }
  if (int_kind >= 0) {
    return w1546_emit_int_kind_to_f64_rax(elf_ctx, ta, int_kind);
  }
  return 0;
}

/**
 * Promote rbx to f64 bits and leave rax unchanged.
 * A push/mov/pop pair moves rbx through rax, where the converters write.
 * Already-f64 (is_f32 == 0 and int_kind < 0) does not touch the stack.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @param is_f32 i32 — non-zero when rbx holds f32 bits
 * @param int_kind i32 — integer type kind, or -1 when rbx is not an integer
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED freestanding emit.
 */
function w1546_promote_rbx_to_f64(elf_ctx: *u8, ta: i32, is_f32: i32, int_kind: i32): i32 {
  if (is_f32 == 0 && int_kind < 0) {
    return 0;
  }
  unsafe {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  if (w1546_promote_rax_to_f64(elf_ctx, ta, is_f32, int_kind) != 0) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Place ADD, SUB, and MUL operands: rbx = left, rax = right.
 * Emit left, push it, emit right, pop the left into rbx. This is the
 * placement the egg mixed helper uses, so a conversion here is not confused
 * by callers that disagree about which register holds left.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left expression ref
 * @param right_ref i32 — right expression ref
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, -1 if an operand or a push/pop fails
 * PLATFORM: SHARED freestanding emit.
 */
function w1546_emit_left_rbx_right_rax(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  unsafe {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Place DIV operands: rax = left, rbx = right.
 * Emit left, push it, emit right, move right into rbx, pop left back to rax.
 * divsd then divides rax by rbx.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left expression ref
 * @param right_ref i32 — right expression ref
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, -1 if an operand or a move fails
 * PLATFORM: SHARED freestanding emit.
 */
function w1546_emit_left_rax_right_rbx(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  unsafe {
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
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Emit one f32↔f64 or f64×integer add, sub, mul, or div, or refuse it.
 * Return -2 when the running paths must handle the op: both f64, both f32,
 * integer×integer, f32×integer, a pointer, or ta other than 0 or 1.
 * Return 0 after the scalar fp op is appended. Return -1 on encode failure.
 * f32↔f64 uses cvtss2sd. An integer side uses scvtf/ucvtf (cvtsi2sd).
 * The egg copy of this symbol stays weak; this strong body is the product.
 * @param arena *u8 — AST arena; null returns -2
 * @param elf_ctx *u8 — encoder context; null returns -2
 * @param ctx *u8 — emit context; null returns -2
 * @param left_ref i32 — left expression ref
 * @param right_ref i32 — right expression ref
 * @param ta i32 — 0 is x86_64, 1 is arm64; any other value returns -2
 * @param op_kind i32 — 4 add, 5 sub, 6 mul, 7 div; anything else returns -2
 * @return i32 — 0 consumed, -1 failure, -2 fall through
 * PLATFORM: SHARED — Darwin arm64 and Linux/Windows x86_64.
 */
#[no_mangle]
export function glue_try_emit_mixed_f32_f64_arith_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32, op_kind: i32): i32 {
  let lf32: i32 = 0;
  let rf32: i32 = 0;
  let lf64: i32 = 0;
  let rf64: i32 = 0;
  let lk: i32 = 0;
  let rk: i32 = 0;
  let f32f64: i32 = 0;
  let f64int: i32 = 0;
  lk = 0 - 1;
  rk = 0 - 1;
  if ((ta != 0 && ta != 1) || arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0 - 2;
  }
  if (op_kind != 4 && op_kind != 5 && op_kind != 6 && op_kind != 7) {
    return 0 - 2;
  }
  unsafe {
    lf32 = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref);
    rf32 = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref);
    lf64 = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref);
    rf64 = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref);
  }
  // Same-class floats stay on mulsd/mulss/addsd/addss in the existing leaves.
  if (lf32 != 0 && rf32 != 0) {
    return 0 - 2;
  }
  if (lf64 != 0 && rf64 != 0 && lf32 == 0 && rf32 == 0) {
    return 0 - 2;
  }
  if (lf32 == 0 && lf64 == 0) {
    lk = w1546_binop_int_kind(arena, ctx, left_ref);
  }
  if (rf32 == 0 && rf64 == 0) {
    rk = w1546_binop_int_kind(arena, ctx, right_ref);
  }
  if ((lf32 != 0 && rf64 != 0) || (lf64 != 0 && rf32 != 0)) {
    f32f64 = 1;
  }
  // f32×integer is a different hole and is not consumed here.
  if ((lf64 != 0 && rk >= 0) || (rf64 != 0 && lk >= 0)) {
    f64int = 1;
  }
  if (f32f64 == 0 && f64int == 0) {
    return 0 - 2;
  }
  if (op_kind == 7) {
    if (w1546_emit_left_rax_right_rbx(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0) {
      return 0 - 1;
    }
    if (w1546_promote_rax_to_f64(elf_ctx, ta, lf32, lk) != 0) {
      return 0 - 1;
    }
    if (w1546_promote_rbx_to_f64(elf_ctx, ta, rf32, rk) != 0) {
      return 0 - 1;
    }
    unsafe {
      if (backend_enc_divsd_rax_rbx_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
    }
  } else {
    if (w1546_emit_left_rbx_right_rax(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0) {
      return 0 - 1;
    }
    if (w1546_promote_rbx_to_f64(elf_ctx, ta, lf32, lk) != 0) {
      return 0 - 1;
    }
    if (w1546_promote_rax_to_f64(elf_ctx, ta, rf32, rk) != 0) {
      return 0 - 1;
    }
    unsafe {
      if (op_kind == 4) {
        if (backend_enc_addsd_rax_rbx_arch(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
      } else if (op_kind == 5) {
        if (backend_enc_subsd_rbx_rax_arch(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
      } else {
        if (backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
      }
    }
  }
  unsafe {
    glue_binop_var_slot_cache_invalidate_rax();
  }
  return 0;
}
