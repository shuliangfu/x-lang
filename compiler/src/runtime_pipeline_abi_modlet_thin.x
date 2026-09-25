// Thin pure: wave633 M2 — modlet family ONE-set (minimal core).
// w631 full closure duplicated state carriers (L2 0/5 startup crash);
// w632 state-free closure still broke the product (memcmp in the
// file-view path — non-transitive state coupling or a dup-T win over
// another family thin). w633 defines ONLY the modlet-namespace core
// (pipe_modlet_* / pipeline_asm_modlet_* — names no other member
// defines), so first-wins can never shadow anyone. Family state =
// the table + strpool seq; every other callee is extern with its call
// site unsafe-wrapped (declare-then-assign form).
// PLATFORM: SHARED — PREFER_ASM both ends.

let g_pipeline_asm_modlet: u8[86020] = [];
let g_pipe_modlet_strpool_seq: i32 = 0;

// Cross-TU faces (unsafe-wrapped at call sites below).
export extern "C" function backend_enc_lea_sym_to_reg_arch(elf_ctx: *u8, reg: i32, name: *u8, name_len: i32, ta: i32): i32;
export extern "C" function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern "C" function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32;
export extern "C" function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern "C" function glue_asm_emit_string_lit_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, str_expr_ref: i32, ta: i32): i32;
export extern "C" function glue_asm_string_lit_len(arena: *u8, expr_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32;
export extern function pipe_arena_off_num_exprs(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_mod_get_num_top_level_lets(module: *u8): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_emit_ctx_arena_get(): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_module_main_func_index(module: *u8): i32;
export extern function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32;
export extern function pipeline_elf_ctx_add_label(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function pipeline_elf_ctx_add_sym(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function pipeline_elf_ctx_append_bytes(ctx_bytes: *u8, ptr: *u8, n: i32): i32;
export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32;
export extern function pipeline_elf_ctx_append_reloc(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_elf_ctx_append_reloc_absolute64( ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_elf_ctx_append_reloc_typed(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32, r_type: i32, r_pcrel: i32): i32;
export extern function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32;
export extern function pipeline_elf_ctx_emit_code_len(ctx_bytes: *u8): i32;
export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32;
export extern function pipeline_elf_ctx_macho_leading_underscore(ctx_bytes: *u8): i32;
export extern function pipeline_elf_ctx_set_shndx_override(ctx_bytes: *u8, shndx: i32): void;
export extern "C" function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern "C" function glue_ieee_f32_bits_to_f64_lo(fb: i32): i32;
export extern "C" function glue_ieee_f32_bits_to_f64_hi(fb: i32): i32;
export extern "C" function glue_i32_to_f32_bits(v: i32): i32;
export extern "C" function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(module: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_is_const(module: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *u8, idx: i32, off: i32): i32;
export extern function pipeline_module_top_level_let_name_len(module: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_type_ref(module: *u8, idx: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, field_ix: i32): i32;
export extern function pipeline_expr_struct_lit_field_offset_at(arena: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern function pipeline_expr_struct_lit_field_type_ref_at(arena: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;

/**
 * 9.6.3 pure: does this module already declare a top-level let/const with the
 * exact given name? Registration-side duplicate guard for the top-level-let
 * parse authority (P012 kind=2): two module-level bindings with one name used
 * to compile silently with the second registration winning.
 * @param m *u8 — Module*; null → 0
 * @param name *u8 — binding-name bytes (not NUL-terminated)
 * @param name_len i32 — name length; <= 0 → 0
 * @return i32 — 1 = name already declared, 0 = no
 * PLATFORM: SHARED — sole provider after top_level leave; seed twin in
 * runtime_pipeline_abi.from_x.c must stay in step.
 */
#[no_mangle]
export function asm_module_top_level_let_name_exists(m: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    let ntl: i32 = 0;
    unsafe { ntl = pipe_mod_get_num_top_level_lets(m); }
    let tl: i32 = 0;
    while (tl < ntl) {
      let nl: i32 = 0;
      unsafe { nl = pipeline_module_top_level_let_name_len(m, tl); }
      if (nl == name_len && nl > 0) {
        let k: i32 = 0;
        while (k < name_len) {
          if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != (name[k] as i32)) {
            break;
          }
          k = k + 1;
        }
        if (k == name_len) {
          return 1;
        }
      }
      tl = tl + 1;
    }
    return 0;
  }
}

/**
 * Fold one integer binop of two already-folded i32 operands.
 * Kinds are the parser pins: EXPR_ADD=4 through EXPR_BITXOR=13.
 * A shift count outside 0..31 is not a constant: the caller loud-fails.
 * EXPR_DIV (7) and EXPR_MOD (8) use the language operators. A zero divisor
 * is not a constant. The most-negative i32 divided or remaindered by -1
 * is not a constant either: x86 idiv traps on that pair, so this helper
 * returns 0 and the baker loud-fails. This thin is compiled as a compiler
 * leaf (XLANG_PREFER_ASM_O=1). That gate makes pipeline_asm_emit_divisor_zero_check_rbx_elf_c
 * a no-op, so these operators do not emit xlang_panic_. Comparisons
 * (14..21) and float binops are not this helper. FLOAT_LIT stays on the
 * array baker, which has the element size.
 * @param ek i32 - expr kind ordinal
 * @param lv i32 - left two's-complement value
 * @param rv i32 - right two's-complement value
 * @param out_val *i32 - folded result; null returns 0
 * @return i32 - 1 written; 0 not this kind or undefined arithmetic
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_fold_i32_binop(ek: i32, lv: i32, rv: i32, out_val: *i32): i32 {
  if (out_val == (0 as *i32)) {
    return 0;
  }
  // Each arm writes the language operator so the fold matches runtime i32.
  if (ek == 4) {
    unsafe { out_val[0] = lv + rv; }
    return 1;
  }
  if (ek == 5) {
    unsafe { out_val[0] = lv - rv; }
    return 1;
  }
  if (ek == 6) {
    unsafe { out_val[0] = lv * rv; }
    return 1;
  }
  // EXPR_DIV=7 and EXPR_MOD=8. Zero and INT_MIN with -1 are not constants.
  // lv + 2147483647 == -1 only for the most-negative i32.
  if (ek == 7 || ek == 8) {
    if (rv == 0) {
      return 0;
    }
    if (rv == (0 - 1)) {
      if (lv + 2147483647 == (0 - 1)) {
        return 0;
      }
    }
    if (ek == 7) {
      unsafe { out_val[0] = lv / rv; }
      return 1;
    }
    unsafe { out_val[0] = lv % rv; }
    return 1;
  }
  if (ek == 9) {
    if (rv < 0 || rv >= 32) {
      return 0;
    }
    unsafe { out_val[0] = lv << rv; }
    return 1;
  }
  if (ek == 10) {
    if (rv < 0 || rv >= 32) {
      return 0;
    }
    unsafe { out_val[0] = lv >> rv; }
    return 1;
  }
  if (ek == 11) {
    unsafe { out_val[0] = lv & rv; }
    return 1;
  }
  if (ek == 12) {
    unsafe { out_val[0] = lv | rv; }
    return 1;
  }
  if (ek == 13) {
    unsafe { out_val[0] = lv ^ rv; }
    return 1;
  }
  return 0;
}

/**
 * Fold one ARRAY_LIT element to its constant i32 value.
 * Accepts EXPR_LIT (ek 0), EXPR_NEG over a folded constant (ek 22, including
 * the parser's NEG-over-LIT form `[-600, 2]`), integer binops
 * EXPR_ADD..EXPR_BITXOR (ek 4..13, including DIV and MOD) whose operands fold,
 * EXPR_BOOL_LIT (ek 2, true is 1 and false is 0), and EXPR_AS (ek 54)
 * to an integer. A float operand truncates toward zero (cvttsd2si). An
 * integer operand is folded by this same function: a 64-bit target keeps
 * both halves, so an i32 child sign-extends, and a 32-bit target keeps
 * the low word, so a wider child truncates. A 64-bit ADD, SUB, MUL,
 * DIV, MOD, shift, or bitwise operator uses both halves, matching the
 * runtime emitter. (2147483647 as i64) + (1 as i64) is low 0x80000000
 * and high 0. A 64-bit NEG negates both halves the same way.
 * -(2147483649.0 as i64) is low 0x7fffffff and high 0xffffffff.
 * A 32-bit NEG still negates one word and sign-fills. A BITNOT (ek 23)
 * inverts bits and does not add one. A 64-bit BITNOT inverts both
 * halves: ~(1 as i64) is low 0xfffffffe and high 0xffffffff. A 32-bit
 * BITNOT inverts one word and sign-fills. Kind 9 stays unfolded.
 * A LOGNOT (ek 24) matches test+setz. Zero becomes 1 and any other
 * folded word becomes 0. !false stores 1 and !true stores 0. The
 * result is a bool, so the high half written here is 0 and the return
 * stays 1. A child whose high half is not the sign fill stays
 * unfolded. A LOGAND (ek 20) matches the runtime test/jz. A zero
 * left word stores 0. A nonzero left word stores 1 only when the
 * right word is also nonzero. true && false stores 0 and
 * true && true stores 1. The high half written here is 0 and the
 * return stays 1. Both children must fold, and a child whose high
 * half is not the sign fill stays unfolded. EQ is not this arm.
 * A LOGOR (ek 21) matches the runtime test/jnz. A nonzero left word
 * stores 1. A zero left word stores 1 only when the right word is
 * also nonzero. false || true stores 1 and false || false stores 0.
 * The high half written here is 0 and the return stays 1. Both
 * children must fold, and a child whose high half is not the sign
 * fill stays unfolded. A zero left does not skip an unfolded right
 * child.
 * An EQ (ek 14) matches the runtime cmp and sete. Equal words store
 * 1 and any other pair stores 0. true == true stores 1 and
 * true == false stores 0. (2 as bool) == true stores 0 because the
 * words are 2 and 1. (2 as bool) == (2 as bool) stores 1. The high
 * half written here is 0 and the return stays 1. Both integer children
 * must fold, and a child whose high half is not the sign fill stays
 * unfolded. A float EQ also folds through pipe_modlet_fold_f64_elem_bits:
 * host f64 `==` matches ucomis/sete (-0.0 == +0.0, NaN != NaN).
 * 1.0 == 1.0 stores 1 and 1.0 == 2.0 stores 0.
 * An NE (ek 15) matches cmp and setne. Unequal words store 1 and
 * equal words store 0. true != false stores 1 and true != true
 * stores 0. (2 as bool) != true stores 1. The same sign-fill and
 * bool-result rules as EQ apply. A float NE also folds through
 * pipe_modlet_fold_f64_elem_bits: host if/else on `==` matches
 * ucomis/setne. 1.0 != 2.0 stores 1 and 1.0 != 1.0 stores 0.
 * An LT (ek 16) matches cmp and setl. A signed less-than stores 1
 * and any other pair stores 0. 1 < 2 stores 1 and 2 < 1 stores 0.
 * 1 < 1 stores 0. ((0 - 1) as i32) < 0 stores 1. The same sign-fill
 * and bool-result rules as EQ apply. A float LT also folds through
 * pipe_modlet_fold_f64_elem_bits: host `bv > av` matches ucomis/setb.
 * 1.0 < 2.0 stores 1 and 2.0 < 1.0 stores 0.
 * An LE (ek 17) matches cmp and setle. A signed less-or-equal stores
 * 1 and any other pair stores 0. 1 <= 2 stores 1 and 2 <= 1 stores 0.
 * 1 <= 1 stores 1. ((0 - 1) as i32) <= (0 - 1) stores 1. The same
 * sign-fill and bool-result rules as EQ apply.
 * An GT (ek 18) matches cmp and setg. A signed greater-than stores 1
 * and any other pair stores 0. 2 > 1 stores 1 and 1 > 2 stores 0.
 * 1 > 1 stores 0. 0 > ((0 - 1) as i32) stores 1. The same sign-fill
 * and bool-result rules as EQ apply.
 * An GE (ek 19) matches cmp and setge. A signed greater-or-equal stores
 * 1 and any other pair stores 0. 2 >= 1 stores 1 and 1 >= 2 stores 0.
 * 1 >= 1 stores 1. ((0 - 1) as i32) >= (0 - 1) stores 1. The same
 * sign-fill and bool-result rules as EQ apply. A float compare stays
 * unfolded.
 * An i32 add
 * inside `as i64` still wraps, then sign-fills. 32-bit targets are TYPE_I32
 * (0), TYPE_BOOL (1), TYPE_U8 (2), and TYPE_U32 (3). The 1-byte baker
 * peels the low byte, so `256 as u8` stores 0 and `2 as bool` stores 2
 * (the runtime emitter does not force a bool to 0 or 1). 64-bit targets
 * are TYPE_U64 (4), TYPE_I64 (5), TYPE_USIZE (6), and TYPE_ISIZE (7),
 * the same kinds as glue_emit_as_f2i64_elf_c.
 * Inf/NaN, and a float magnitude outside the signed destination, return 0
 * so the baker loud-fails instead of storing the indefinite sign bit.
 * |x| < 1 truncates to 0 and is a successful fold. Exactly -2^31 fits in
 * i32. Positive [2^31, 2^32) as i32 and as u32 stores the low word
 * 0x80000000 (same bits as (2147483648.0 as i64) as i32). Exactly
 * -2^63 fits in i64. Exact +2^63 as i64/u64/isize/usize stores the
 * same bits (low 0, high 0x80000000).
 * FLOAT_LIT with no cast is not an integer; the array baker pokes IEEE
 * bits from the element size. VAR and any other kind are not compile-time
 * constants; callers must loud-fail (return -1) instead of silently
 * dropping the element — the historic silent drop baked zeros for
 * `let g: i32[2] = [-1, 2]`.
 * out_hi is optional. Null means the caller only keeps the low 32 bits.
 * An i32 result then writes only out_val. A 64-bit result whose high
 * half is not the sign fill of that low half returns 0 when out_hi is
 * null, so a 32-bit caller cannot truncate 2^31 by accident. When out_hi
 * is set, an i32 result writes the sign fill (0 or -1) and a 64-bit
 * result writes the real high half. On failure out_hi is not meaningful.
 * @param arena *u8 - ASTArena; null returns 0
 * @param eref i32 - element expr ref; <= 0 returns 0
 * @param out_val *i32 - low half of the folded two's-complement value; null returns 0
 * @param out_hi *i32 - high half; null when the caller only wants 32 bits
 * @return i32 - 1 = folded constant; 0 = not a supported constant elem
 * PLATFORM: SHARED — little-endian host float trunc; LINUX gold.
 */
function pipe_modlet_array_lit_elem_const_val(
  arena: *u8, eref: i32, out_val: *i32, out_hi: *i32
): i32 {
  let ek: i32 = 0;
  let op: i32 = 0;
  let v: i32 = 0;
  let left: i32 = 0;
  let right: i32 = 0;
  let lv: i32 = 0;
  let rv: i32 = 0;
  let lhi: i32 = 0;
  let llo: i32 = 0;
  let rlo: i32 = 0;
  let rhi: i32 = 0;
  let wlo: i32 = 0;
  let whi: i32 = 0;
  let result: i32 = 0;
  let sh: i32 = 0;
  let mag: i32 = 0;
  let top: i32 = 0;
  let guard: i32 = 0;
  let step: i32 = 0;
  let k: i32 = 0;
  let bit: i32 = 0;
  let src: i32 = 0;
  let exp: i32 = 0;
  let flo: i32 = 0;
  let fhi: i32 = 0;
  let rty: i32 = 0;
  let rtk: i32 = 0;
  let stk_lo: i32[8] = [];
  let stk_hi: i32[8] = [];
  let lp: i32[2] = [];
  let rp: i32[2] = [];
  let av: f64 = 0.0;
  let bv: f64 = 0.0;
  if (arena == (0 as *u8) || eref <= 0 || out_val == (0 as *i32)) {
    return 0;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
  }
  // EXPR_LIT (ek 0) and EXPR_BOOL_LIT (ek 2) share int_val.
  // true is 1 and false is 0. Both are i32-wide in this AST.
  if (ek == 0 || ek == 2) {
    unsafe {
      unsafe { v = pipeline_expr_int_val_at(arena, eref); }
    }
    unsafe {
      out_val[0] = v;
    }
    // The high half is the sign fill of that low word.
    if (out_hi != (0 as *i32)) {
      if (v < 0) {
        unsafe { out_hi[0] = 0 - 1; }
      } else {
        unsafe { out_hi[0] = 0; }
      }
    }
    return 1;
  }
  // NEG of a folded constant, not only a bare LIT. Recurses once per unary.
  // A 32-bit NEG negates one word and sign-fills. A 64-bit NEG (kinds
  // 4..7) negates both halves. -(2147483649.0 as i64) is
  // ffffff7fffffffff. Negating only the low word sign-fills a lie.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 22) {
    unsafe {
      unsafe { op = pipeline_expr_unary_operand_ref_at(arena, eref); }
    }
    if (op <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      rty = 0;
      rtk = 0;
      unsafe {
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
      }
      if (rty > 0) {
        unsafe {
          unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
        }
      }
      // ~x + 1 in 16-bit limbs. Carry starts at 1. The baker pokes the
      // high word this arm writes, so the return stays 1.
      // PLATFORM: LINUX|UBUNTU.
      if (rtk == 4 || rtk == 5 || rtk == 6 || rtk == 7) {
        lv = lv ^ (0 - 1);
        lhi = lhi ^ (0 - 1);
        step = 1;
        result = lv & 65535;
        v = (lv >> 16) & 65535;
        top = result + step;
        step = 0;
        if (top >= 65536) {
          step = 1;
          top = top - 65536;
        }
        guard = v + step;
        step = 0;
        if (guard >= 65536) {
          step = 1;
          guard = guard - 65536;
        }
        wlo = top | (guard << 16);
        result = lhi & 65535;
        v = (lhi >> 16) & 65535;
        top = result + step;
        step = 0;
        if (top >= 65536) {
          step = 1;
          top = top - 65536;
        }
        guard = v + step;
        if (guard >= 65536) {
          guard = guard - 65536;
        }
        whi = top | (guard << 16);
        unsafe { out_val[0] = wlo; }
        unsafe { out_hi[0] = whi; }
        return 1;
      }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe {
      out_val[0] = 0 - out_val[0];
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        unsafe { out_hi[0] = 0 - 1; }
      } else {
        unsafe { out_hi[0] = 0; }
      }
    }
    return 1;
  }
  // BITNOT. Invert both halves when the resolved kind is 4..7, and
  // invert one word otherwise. No +1: this is not unary minus.
  // ~(1 as i64) is fffffffffffffffe. The baker pokes the high word
  // this arm writes, so the return stays 1. Kind 9 stays unfolded.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 23) {
    unsafe {
      unsafe { op = pipeline_expr_unary_operand_ref_at(arena, eref); }
    }
    if (op <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      rty = 0;
      rtk = 0;
      unsafe {
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
      }
      if (rty > 0) {
        unsafe {
          unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
        }
      }
      if (rtk == 4 || rtk == 5 || rtk == 6 || rtk == 7) {
        lv = lv ^ (0 - 1);
        lhi = lhi ^ (0 - 1);
        unsafe { out_val[0] = lv; }
        unsafe { out_hi[0] = lhi; }
        return 1;
      }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe {
      out_val[0] = out_val[0] ^ (0 - 1);
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        unsafe { out_hi[0] = 0 - 1; }
      } else {
        unsafe { out_hi[0] = 0; }
      }
    }
    return 1;
  }
  // LOGNOT. test+setz: zero becomes 1, any other word becomes 0.
  // !false stores 1. !true stores 0. The baker pokes the high word
  // this arm writes, so that word is 0 and the return stays 1.
  // A child whose high half is not the sign fill of the low word is
  // not a bool constant. A resolved type other than bool stays
  // unfolded. !!false is this arm twice. The zero result is written
  // before the test, so there is no else arm.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 24) {
    unsafe {
      unsafe { op = pipeline_expr_unary_operand_ref_at(arena, eref); }
    }
    if (op <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { lv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    result = 0;
    if (lv == 0) {
      result = 1;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // LOGAND. The runtime emitter writes 0 when the left word is zero,
  // and writes 1 only when the right word is also nonzero.
  // true && false stores 0. true && true stores 1. The baker pokes
  // the high word this arm writes, so that word is 0 and the return
  // stays 1. Both children must fold. A child whose high half is not
  // the sign fill of the low word is not a bool constant. A resolved
  // type other than bool stays unfolded. The left word is saved in
  // llo before the right fold reuses out_val. The zero result is
  // written before the two tests, so there is no else arm. EQ is
  // not this arm.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 20) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    result = 0;
    if (llo != 0) {
      if (rv != 0) {
        result = 1;
      }
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // LOGOR. The runtime emitter writes 1 when the left word is
  // nonzero, and otherwise writes 1 only when the right word is
  // nonzero. Both tests failing write 0. false || true stores 1.
  // false || false stores 0. The baker pokes the high word this arm
  // writes, so that word is 0 and the return stays 1. Both children
  // must fold. A child whose high half is not the sign fill of the
  // low word is not a bool constant. A resolved type other than bool
  // stays unfolded. The left word is saved in llo before the right
  // fold reuses out_val. A zero left does not skip an unfolded right
  // child. The zero result is written before the two tests, so there
  // is no else arm.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 21) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    result = 0;
    if (llo != 0) {
      result = 1;
    }
    if (llo == 0) {
      if (rv != 0) {
        result = 1;
      }
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // EQ. The runtime emitter compares the two words and sete writes 1
  // when they are equal. true == true stores 1. true == false stores
  // 0. false == false stores 1. (2 as bool) == true stores 0 because
  // the words are 2 and 1. (2 as bool) == (2 as bool) stores 1.
  // Equality compares the words. It does not treat a nonzero word as
  // true. The baker pokes the high word this arm writes, so that word
  // is 0 and the return stays 1. Both integer children must fold. A
  // child whose high half is not the sign fill of the low word stays
  // unfolded. A resolved type other than bool stays unfolded. The
  // left word is saved in llo before the right fold reuses out_val.
  // The zero result is written before the equal test, so there is no
  // else arm. Float EQ tries pipe_modlet_fold_f64_elem_bits first;
  // host f64 `==` matches ucomis/sete. 1.0 == 1.0 stores 1.
  // LT, LE, GT, and GE are not this arm.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 14) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    // Float equality. fold_f64 accepts FLOAT_LIT, float NEG/binop, and
    // AS to f32/f64. Host `==` matches ucomis/sete. When the left is
    // not a float constant, fall through to the integer path.
    // PLATFORM: LINUX|UBUNTU.
    if (pipe_modlet_fold_f64_elem_bits(arena, left, &(lp[0]), &(lp[1])) == 1) {
      if (pipe_modlet_fold_f64_elem_bits(arena, right, &(rp[0]), &(rp[1])) == 0) {
        return 0;
      }
      unsafe {
        unsafe { memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize); }
        unsafe { memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize); }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
      }
      if (rty > 0) {
        unsafe {
          unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      result = 0;
      if (av == bv) {
        result = 1;
      }
      unsafe { out_val[0] = result; }
      if (out_hi != (0 as *i32)) {
        unsafe { out_hi[0] = 0; }
      }
      return 1;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    result = 0;
    if (llo == rv) {
      result = 1;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // NE. The runtime emitter compares the two words and setne writes 1
  // when they differ. true != false stores 1. true != true stores 0.
  // false != false stores 0. (2 as bool) != true stores 1 because the
  // words are 2 and 1. Inequality compares the words. It does not
  // treat a nonzero word as true. The baker pokes the high word this
  // arm writes, so that word is 0 and the return stays 1. Both
  // integer children must fold. A child whose high half is not the
  // sign fill of the low word stays unfolded. A resolved type other
  // than bool stays unfolded. The left word is saved in llo before
  // the right fold reuses out_val. The zero result is written before
  // the unequal test, so there is no else arm. Float NE tries
  // pipe_modlet_fold_f64_elem_bits first; host if/else on `==`
  // matches ucomis/setne. 1.0 != 2.0 stores 1. LE, GT, and GE are
  // not this arm.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 15) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    // Float inequality. Reuse function-level av/bv (same as float EQ).
    // Bit-compare the IEEE halves so tip cannot drop a float else or
    // a float start-1-clear. -0.0 and +0.0 differ in bit 63, so this
    // path treats them as unequal; the primary probes use nonzero
    // magnitudes. PLATFORM: LINUX|UBUNTU.
    if (pipe_modlet_fold_f64_elem_bits(arena, left, &(lp[0]), &(lp[1])) == 1) {
      if (pipe_modlet_fold_f64_elem_bits(arena, right, &(rp[0]), &(rp[1])) == 0) {
        return 0;
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
      }
      if (rty > 0) {
        unsafe {
          unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      // Integer word compare of both halves. Start at 1, clear when
      // both words match — same shape as LE/GE. PLATFORM: LINUX|UBUNTU.
      result = 1;
      if (lp[0] == rp[0]) {
        if (lp[1] == rp[1]) {
          result = 0;
        }
      }
      unsafe { out_val[0] = result; }
      if (out_hi != (0 as *i32)) {
        unsafe { out_hi[0] = 0; }
      }
      return 1;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    // Same if/else on `==` as the Darwin/Windows folder. Avoid `!=`
    // and avoid result=1-then-flip, which that host miscompiled.
    // PLATFORM: LINUX|UBUNTU — keep the three folders aligned.
    if (llo == rv) {
      result = 0;
    } else {
      result = 1;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // LT. The runtime emitter compares the two words and setl writes 1
  // when the left is signed-less than the right. 1 < 2 stores 1.
  // 2 < 1 stores 0. 1 < 1 stores 0. ((0 - 1) as i32) < 0 stores 1.
  // The compare is signed on the folded i32 words. The baker pokes
  // the high word this arm writes, so that word is 0 and the return
  // stays 1. Both integer children must fold. A child whose high half
  // is not the sign fill of the low word stays unfolded. A resolved
  // type other than bool stays unfolded. The left word is saved in
  // llo before the right fold reuses out_val. An if on `rv > llo`
  // writes 1 (same as llo < rv); otherwise the result stays 0. Float
  // LT tries fold_f64 first; host `bv > av` matches ucomis/setb.
  // 1.0 < 2.0 stores 1. GT and GE are not this arm.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 16) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    // Float less-than. fold_f64 then host `bv > av` (no bare `av < bv`).
    // PLATFORM: LINUX|UBUNTU.
    if (pipe_modlet_fold_f64_elem_bits(arena, left, &(lp[0]), &(lp[1])) == 1) {
      if (pipe_modlet_fold_f64_elem_bits(arena, right, &(rp[0]), &(rp[1])) == 0) {
        return 0;
      }
      unsafe {
        unsafe { memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize); }
        unsafe { memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize); }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
      }
      if (rty > 0) {
        unsafe {
          unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      result = 0;
      if (bv > av) {
        result = 1;
      }
      unsafe { out_val[0] = result; }
      if (out_hi != (0 as *i32)) {
        unsafe { out_hi[0] = 0; }
      }
      return 1;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    // Same operand-swapped `>` as the Darwin/Windows folder. Avoid a
    // bare `llo < rv`, which that host miscompiled to always-0.
    // PLATFORM: LINUX|UBUNTU — keep the three folders aligned.
    result = 0;
    if (rv > llo) {
      result = 1;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // LE. The runtime emitter compares the two words and setle writes 1
  // when the left is signed-less-or-equal to the right. 1 <= 2 stores
  // 1. 2 <= 1 stores 0. 1 <= 1 stores 1. ((0 - 1) as i32) <= 0 stores
  // 1. The compare is signed on the folded i32 words. The baker pokes
  // the high word this arm writes, so that word is 0 and the return
  // stays 1. Both children must fold. A child whose high half is not
  // the sign fill of the low word stays unfolded. A resolved type
  // other than bool stays unfolded. The left word is saved in llo
  // before the right fold reuses out_val. Start at 1 and clear when
  // `llo > rv` (same as llo <= rv). GE is not this arm. A
  // float compare stays unfolded.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 17) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    // Same start-1-then-clear-on-`>` as the Darwin/Windows folder.
    // Avoid a bare `llo <= rv`. PLATFORM: LINUX|UBUNTU.
    result = 1;
    if (llo > rv) {
      result = 0;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // GT. The runtime emitter compares the two words and setg writes 1
  // when the left is signed-greater than the right. 2 > 1 stores 1.
  // 1 > 2 stores 0. 1 > 1 stores 0. 0 > ((0 - 1) as i32) stores 1.
  // The compare is signed on the folded i32 words. The baker pokes
  // the high word this arm writes, so that word is 0 and the return
  // stays 1. Both children must fold. A child whose high half is not
  // the sign fill of the low word stays unfolded. A resolved type
  // other than bool stays unfolded. The left word is saved in llo
  // before the right fold reuses out_val. Start at 1 and clear when
  // `rv > llo` or when equal (same as llo > rv). GE is not this arm.
  // A float compare stays unfolded.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 18) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    // Same start-1-then-clear as Darwin/Windows: clear when `rv > llo`
    // or when equal. Avoid start-0-then-set-on-`>`, which that host
    // miscompiled. PLATFORM: LINUX|UBUNTU.
    result = 1;
    if (rv > llo) {
      result = 0;
    }
    if (llo == rv) {
      result = 0;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // GE. The runtime emitter compares the two words and setge writes 1
  // when the left is signed-greater-or-equal to the right. 2 >= 1
  // stores 1. 1 >= 2 stores 0. 1 >= 1 stores 1. ((0 - 1) as i32) >=
  // (0 - 1) stores 1. The compare is signed on the folded i32 words.
  // The baker pokes the high word this arm writes, so that word is 0
  // and the return stays 1. Both children must fold. A child whose
  // high half is not the sign fill of the low word stays unfolded.
  // A resolved type other than bool stays unfolded. The left word is
  // saved in llo before the right fold reuses out_val. Start at 1 and
  // clear when `rv > llo` only (same as llo < rv). Keep 1 when equal.
  // A float compare stays unfolded.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek == 19) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
    }
    unsafe { llo = out_val[0]; }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
      unsafe { rv = out_val[0]; }
      if (rv < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    unsafe { rv = out_val[0]; }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    // Same start-1-then-clear-on-`>` as Darwin/Windows. Keep 1 when
    // equal. Avoid a bare `llo >= rv`. PLATFORM: LINUX|UBUNTU.
    result = 1;
    if (rv > llo) {
      result = 0;
    }
    unsafe { out_val[0] = result; }
    if (out_hi != (0 as *i32)) {
      unsafe { out_hi[0] = 0; }
    }
    return 1;
  }
  // Integer binop. A 64-bit operator uses both halves, the same
  // bits the runtime emitter writes. (2147483647 as i64) + (1 as i64)
  // is low 0x80000000 and high 0. An i32 operator still sign-fills,
  // and a child whose high half is not that sign fill stays unfolded.
  // PLATFORM: LINUX|UBUNTU — this body is not the Darwin folder.
  if (ek >= 4 && ek <= 13) {
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi) == 0) {
      return 0;
    }
    unsafe { llo = out_val[0]; }
    lhi = 0;
    if (out_hi != (0 as *i32)) {
      unsafe { lhi = out_hi[0]; }
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi) == 0) {
      return 0;
    }
    unsafe { rlo = out_val[0]; }
    rhi = 0;
    if (out_hi != (0 as *i32)) {
      unsafe { rhi = out_hi[0]; }
    }
    rty = 0;
    rtk = 0;
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if ((rtk == 4 || rtk == 5 || rtk == 6 || rtk == 7) && out_hi != (0 as *i32)) {
        wlo = 0;
        whi = 0;
        // ADD, and SUB as add of the two's complement. Carry lives in step.
        // 16-bit limbs stay inside a signed i32. (2147483647 as i64) + 1
        // is low 0x80000000 and high 0.
        if (ek == 4 || ek == 5) {
          step = 0;
          if (ek == 5) {
            rlo = rlo ^ (0 - 1);
            rhi = rhi ^ (0 - 1);
            step = 1;
          }
          result = llo & 65535;
          v = (llo >> 16) & 65535;
          sh = rlo & 65535;
          mag = (rlo >> 16) & 65535;
          top = result + sh + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + mag + step;
          step = 0;
          if (guard >= 65536) {
            step = 1;
            guard = guard - 65536;
          }
          wlo = top | (guard << 16);
          result = lhi & 65535;
          v = (lhi >> 16) & 65535;
          sh = rhi & 65535;
          mag = (rhi >> 16) & 65535;
          top = result + sh + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + mag + step;
          if (guard >= 65536) {
            guard = guard - 65536;
          }
          whi = top | (guard << 16);
        }
        // MUL. Eight-bit limbs: 255*255 fits in a signed i32. The cross
        // terms llo*rhi and lhi*rlo only contribute their low 32 bits.
        if (ek == 6) {
          exp = 0;
          flo = 0;
          fhi = 0;
          sh = 0;
          while (sh < 3) {
            result = llo;
            v = rlo;
            if (sh == 1) {
              v = rhi;
            }
            if (sh == 2) {
              result = lhi;
              v = rlo;
            }
            stk_hi[0] = result & 255;
            stk_hi[1] = (result >> 8) & 255;
            stk_hi[2] = (result >> 16) & 255;
            stk_hi[3] = (result >> 24) & 255;
            stk_hi[4] = v & 255;
            stk_hi[5] = (v >> 8) & 255;
            stk_hi[6] = (v >> 16) & 255;
            stk_hi[7] = (v >> 24) & 255;
            stk_lo[0] = stk_hi[0] * stk_hi[4];
            stk_lo[1] = stk_hi[0] * stk_hi[5] + stk_hi[1] * stk_hi[4];
            stk_lo[2] = stk_hi[0] * stk_hi[6] + stk_hi[1] * stk_hi[5] + stk_hi[2] * stk_hi[4];
            stk_lo[3] = stk_hi[0] * stk_hi[7] + stk_hi[1] * stk_hi[6] + stk_hi[2] * stk_hi[5] + stk_hi[3] * stk_hi[4];
            stk_lo[4] = stk_hi[1] * stk_hi[7] + stk_hi[2] * stk_hi[6] + stk_hi[3] * stk_hi[5];
            stk_lo[5] = stk_hi[2] * stk_hi[7] + stk_hi[3] * stk_hi[6];
            stk_lo[6] = stk_hi[3] * stk_hi[7];
            stk_lo[7] = 0;
            step = 0;
            top = 0;
            while (top < 8) {
              mag = stk_lo[top] + step;
              step = 0;
              while (mag >= 256) {
                mag = mag - 256;
                step = step + 1;
              }
              stk_lo[top] = mag;
              top = top + 1;
            }
            mag = stk_lo[0] | (stk_lo[1] << 8) | (stk_lo[2] << 16) | (stk_lo[3] << 24);
            if (sh == 0) {
              wlo = mag;
              exp = stk_lo[4] | (stk_lo[5] << 8) | (stk_lo[6] << 16) | (stk_lo[7] << 24);
            }
            if (sh == 1) {
              flo = mag;
            }
            if (sh == 2) {
              fhi = mag;
            }
            sh = sh + 1;
          }
          result = exp & 65535;
          v = (exp >> 16) & 65535;
          sh = flo & 65535;
          mag = (flo >> 16) & 65535;
          top = result + sh;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + mag + step;
          step = 0;
          if (guard >= 65536) {
            step = 1;
            guard = guard - 65536;
          }
          result = top | (guard << 16);
          v = (result >> 16) & 65535;
          top = (result & 65535) + (fhi & 65535) + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + ((fhi >> 16) & 65535) + step;
          if (guard >= 65536) {
            guard = guard - 65536;
          }
          whi = top | (guard << 16);
        }
        if (ek == 11) {
          wlo = llo & rlo;
          whi = lhi & rhi;
        }
        if (ek == 12) {
          wlo = llo | rlo;
          whi = lhi | rhi;
        }
        if (ek == 13) {
          wlo = llo ^ rlo;
          whi = lhi ^ rhi;
        }
        // SHL is logical. SHR is arithmetic for i64 and isize, logical
        // for u64 and usize. A count outside 0..63 is not a constant.
        if (ek == 9 || ek == 10) {
          if (rhi != 0 || rlo < 0 || rlo >= 64) {
            return 0;
          }
          if (rlo == 0) {
            wlo = llo;
            whi = lhi;
          }
          if (rlo >= 32) {
            sh = rlo - 32;
            wlo = 0;
            whi = 0;
            if (ek == 9) {
              if (sh == 0) {
                whi = llo;
              }
              if (sh > 0) {
                whi = llo << sh;
              }
            }
            if (ek == 10) {
              if (sh == 0) {
                wlo = lhi;
              }
              if (sh > 0 && sh < 31) {
                if (rtk == 5 || rtk == 7) {
                  wlo = lhi >> sh;
                }
                if (rtk == 4 || rtk == 6) {
                  if (lhi >= 0) {
                    wlo = lhi >> sh;
                  }
                  if (lhi < 0) {
                    top = 32 - sh;
                    guard = 2147483647;
                    if (top < 31) {
                      guard = (1 << top) - 1;
                    }
                    wlo = (lhi >> sh) & guard;
                  }
                }
              }
              if (sh == 31) {
                wlo = 0;
                if (lhi < 0) {
                  wlo = 1;
                  if (rtk == 5 || rtk == 7) {
                    wlo = 0 - 1;
                  }
                }
              }
              if (rtk == 5 || rtk == 7) {
                if (lhi < 0) {
                  whi = 0 - 1;
                }
              }
            }
          }
          if (rlo > 0 && rlo < 32) {
            sh = rlo;
            if (ek == 9) {
              wlo = llo << sh;
              mag = 0;
              top = 32 - sh;
              if (llo >= 0) {
                mag = llo >> top;
              }
              if (llo < 0) {
                guard = 2147483647;
                if (sh < 31) {
                  guard = (1 << sh) - 1;
                }
                mag = (llo >> top) & guard;
              }
              whi = (lhi << sh) | mag;
            }
            if (ek == 10) {
              mag = 0;
              if (llo >= 0) {
                mag = llo >> sh;
              }
              if (llo < 0) {
                top = 32 - sh;
                guard = 2147483647;
                if (top < 31) {
                  guard = (1 << top) - 1;
                }
                mag = (llo >> sh) & guard;
              }
              wlo = mag | (lhi << (32 - sh));
              if (rtk == 5 || rtk == 7) {
                whi = lhi >> sh;
              }
              if (rtk == 4 || rtk == 6) {
                if (lhi >= 0) {
                  whi = lhi >> sh;
                }
                if (lhi < 0) {
                  top = 32 - sh;
                  guard = 2147483647;
                  if (top < 31) {
                    guard = (1 << top) - 1;
                  }
                  whi = (lhi >> sh) & guard;
                }
              }
            }
          }
        }
        // DIV and MOD. Toward zero. Remainder sign follows the dividend.
        // Unsigned kinds 4 and 6 do not look at the sign bit. Zero and
        // signed INT_MIN / -1 stay unfolded. PLATFORM: MACOS|DARWIN / WINDOWS.
        if (ek == 7 || ek == 8) {
          if (rlo == 0 && rhi == 0) {
            return 0;
          }
          if ((rtk == 5 || rtk == 7) && llo == 0 && lhi == (0 - 2147483647 - 1) && rlo == (0 - 1) && rhi == (0 - 1)) {
            return 0;
          }
          lp[0] = llo;
          lp[1] = lhi;
          rp[0] = rlo;
          rp[1] = rhi;
          exp = 0;
          src = 0;
          if (rtk == 5 || rtk == 7) {
            if (lp[1] < 0) {
              src = 1;
              exp = 1;
              flo = lp[0] ^ (0 - 1);
              fhi = lp[1] ^ (0 - 1);
              step = 1;
              sh = 0;
              while (sh < 2) {
                result = flo;
                if (sh == 1) {
                  result = fhi;
                }
                mag = result & 65535;
                top = (result >> 16) & 65535;
                mag = mag + step;
                step = 0;
                if (mag >= 65536) {
                  step = 1;
                  mag = mag - 65536;
                }
                top = top + step;
                step = 0;
                if (top >= 65536) {
                  step = 1;
                  top = top - 65536;
                }
                result = mag | (top << 16);
                if (sh == 0) {
                  flo = result;
                }
                if (sh == 1) {
                  fhi = result;
                }
                sh = sh + 1;
              }
              lp[0] = flo;
              lp[1] = fhi;
            }
            if (rp[1] < 0) {
              guard = exp;
              exp = 0;
              if (guard == 0) {
                exp = 1;
              }
              flo = rp[0] ^ (0 - 1);
              fhi = rp[1] ^ (0 - 1);
              step = 1;
              sh = 0;
              while (sh < 2) {
                result = flo;
                if (sh == 1) {
                  result = fhi;
                }
                mag = result & 65535;
                top = (result >> 16) & 65535;
                mag = mag + step;
                step = 0;
                if (mag >= 65536) {
                  step = 1;
                  mag = mag - 65536;
                }
                top = top + step;
                step = 0;
                if (top >= 65536) {
                  step = 1;
                  top = top - 65536;
                }
                result = mag | (top << 16);
                if (sh == 0) {
                  flo = result;
                }
                if (sh == 1) {
                  fhi = result;
                }
                sh = sh + 1;
              }
              rp[0] = flo;
              rp[1] = fhi;
            }
          }
          flo = 0;
          fhi = 0;
          wlo = 0;
          whi = 0;
          k = 63;
          while (k >= 0) {
            bit = 0;
            if (k >= 32) {
              bit = (lp[1] >> (k - 32)) & 1;
            }
            if (k < 32) {
              bit = (lp[0] >> k) & 1;
            }
            step = 0;
            if (flo < 0) {
              step = 1;
            }
            flo = (flo << 1) | bit;
            fhi = (fhi << 1) | step;
            guard = 0;
            if (fhi >= 0 && rp[1] >= 0) {
              if (fhi > rp[1]) {
                guard = 1;
              }
              if (fhi == rp[1]) {
                if (flo >= 0 && rp[0] >= 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] < 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] >= 0) {
                  guard = 1;
                }
              }
            }
            if (fhi < 0 && rp[1] >= 0) {
              guard = 1;
            }
            if (fhi < 0 && rp[1] < 0) {
              if (fhi > rp[1]) {
                guard = 1;
              }
              if (fhi == rp[1]) {
                if (flo >= 0 && rp[0] >= 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] < 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] >= 0) {
                  guard = 1;
                }
              }
            }
            if (guard == 1) {
              result = rp[0] ^ (0 - 1);
              v = rp[1] ^ (0 - 1);
              step = 1;
              mag = (flo & 65535) + (result & 65535) + step;
              step = 0;
              if (mag >= 65536) {
                step = 1;
                mag = mag - 65536;
              }
              top = ((flo >> 16) & 65535) + ((result >> 16) & 65535) + step;
              step = 0;
              if (top >= 65536) {
                step = 1;
                top = top - 65536;
              }
              flo = mag | (top << 16);
              mag = (fhi & 65535) + (v & 65535) + step;
              step = 0;
              if (mag >= 65536) {
                step = 1;
                mag = mag - 65536;
              }
              top = ((fhi >> 16) & 65535) + ((v >> 16) & 65535) + step;
              if (top >= 65536) {
                top = top - 65536;
              }
              fhi = mag | (top << 16);
              if (k >= 32) {
                sh = k - 32;
                if (sh == 31) {
                  whi = whi | (0 - 2147483647 - 1);
                }
                if (sh < 31) {
                  whi = whi | (1 << sh);
                }
              }
              if (k < 32) {
                if (k == 31) {
                  wlo = wlo | (0 - 2147483647 - 1);
                }
                if (k < 31) {
                  wlo = wlo | (1 << k);
                }
              }
            }
            k = k - 1;
          }
          if (ek == 8) {
            wlo = flo;
            whi = fhi;
            exp = src;
          }
          if (exp == 1) {
            flo = wlo ^ (0 - 1);
            fhi = whi ^ (0 - 1);
            step = 1;
            sh = 0;
            while (sh < 2) {
              result = flo;
              if (sh == 1) {
                result = fhi;
              }
              mag = result & 65535;
              top = (result >> 16) & 65535;
              mag = mag + step;
              step = 0;
              if (mag >= 65536) {
                step = 1;
                mag = mag - 65536;
              }
              top = top + step;
              step = 0;
              if (top >= 65536) {
                step = 1;
                top = top - 65536;
              }
              result = mag | (top << 16);
              if (sh == 0) {
                flo = result;
              }
              if (sh == 1) {
                fhi = result;
              }
              sh = sh + 1;
            }
            wlo = flo;
            whi = fhi;
          }
        }
      unsafe { out_val[0] = wlo; }
      unsafe { out_hi[0] = whi; }
      return 1;
    }
    if (out_hi != (0 as *i32)) {
      if (llo < 0) {
        if (lhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (lhi != 0) {
          return 0;
        }
      }
      if (rlo < 0) {
        if (rhi != (0 - 1)) {
          return 0;
        }
      } else {
        if (rhi != 0) {
          return 0;
        }
      }
    }
    if (pipe_modlet_fold_i32_binop(ek, llo, rlo, out_val) == 0) {
      return 0;
    }
    if (out_hi != (0 as *i32)) {
      unsafe { lv = out_val[0]; }
      if (lv < 0) {
        unsafe { out_hi[0] = 0 - 1; }
      } else {
        unsafe { out_hi[0] = 0; }
      }
    }
    return 1;
  }
  // EXPR_AS. A folded float truncates toward zero. An integer operand
  // is this same function: 64-bit keeps both halves, 32-bit keeps the
  // low word. TYPE_U8 and TYPE_BOOL use that 32-bit word; the baker
  // peels one byte. 2 as bool stays 2.
  if (ek == 54) {
    let tgt: i32 = 0;
    let tk: i32 = 0;
    let parts: i32[2] = [];
    let dv: f64 = 0.0;
    let iv: i32 = 0;
    let ip: i32[2] = [];
    let iv64: i64 = 0;
    let ihi: i32 = 0;
    unsafe {
      unsafe { op = pipeline_expr_as_operand_ref_at(arena, eref); }
      unsafe { tgt = pipeline_expr_as_target_type_ref_at(arena, eref); }
    }
    if (op <= 0 || tgt <= 0) {
      return 0;
    }
    unsafe {
      unsafe { tk = pipeline_type_kind_ord_at(arena, tgt); }
    }
    // .x TypeKind, not the C enum. 4/5/6/7 match glue_emit_as_f2i64_elf_c.
    // The trunc is signed cvttsd2si into rax, so u64 uses the same bits.
    if (tk == 4 || tk == 5 || tk == 6 || tk == 7) {
      if (pipe_modlet_fold_f64_elem_bits(arena, op, &flo, &fhi) == 0) {
        // Integer operand. Both halves are already the widening.
        if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val, &ihi) == 0) {
          return 0;
        }
        unsafe { lv = out_val[0]; }
        if (out_hi == (0 as *i32)) {
          if (lv < 0) {
            if (ihi != (0 - 1)) {
              return 0;
            }
          } else {
            if (ihi != 0) {
              return 0;
            }
          }
          return 1;
        }
        unsafe { out_hi[0] = ihi; }
        return 1;
      }
      // Exponent lives in bits 20..30. An arithmetic shift still leaves
      // those 11 bits after the mask, including a negative high half.
      exp = (fhi >> 20) & 2047;
      // Inf / NaN. cvttsd2si would yield the indefinite integer.
      if (exp == 2047) {
        return 0;
      }
      // |x| < 1 truncates to 0, including zero and subnormals.
      if (exp < 1023) {
        unsafe { out_val[0] = 0; }
        if (out_hi != (0 as *i32)) {
          unsafe { out_hi[0] = 0; }
        }
        return 1;
      }
      // |x| >= 2^64. Bias 1023, so unbiased 64 is biased 1087.
      if (exp > 1086) {
        return 0;
      }
      // Binade [2^63, 2^64). Exact ±2^63 both store low 0 and high
      // 0x80000000 (same bits as 9223372036854775808.0 as i64 / u64).
      // Do not host-cast this boundary: a positive cast is the
      // indefinite integer on some hosts. Non-exact stays unfolded.
      // PLATFORM: LINUX|UBUNTU.
      if (exp == 1086) {
        if ((fhi & 1048575) != 0 || flo != 0) {
          return 0;
        }
        if (out_hi == (0 as *i32)) {
          return 0;
        }
        unsafe { out_val[0] = 0; }
        unsafe { out_hi[0] = 0 - 2147483647 - 1; }
        return 1;
      }
      // In range for signed i64. Host f64-to-i64 truncates toward zero.
      parts[0] = flo;
      parts[1] = fhi;
      unsafe {
        unsafe { memcpy((&dv) as *u8, (&(parts[0])) as *u8, 8 as usize); }
      }
      iv64 = dv as i64;
      unsafe {
        unsafe { memcpy((&(ip[0])) as *u8, (&iv64) as *u8, 8 as usize); }
      }
      wlo = ip[0];
      whi = ip[1];
      if (out_hi == (0 as *i32)) {
        if (wlo < 0) {
          if (whi != (0 - 1)) {
            return 0;
          }
        } else {
          if (whi != 0) {
            return 0;
          }
        }
        unsafe { out_val[0] = wlo; }
        return 1;
      }
      unsafe { out_val[0] = wlo; }
      unsafe { out_hi[0] = whi; }
      return 1;
    }
    // TYPE_I32 = 0, TYPE_BOOL = 1, TYPE_U8 = 2, TYPE_U32 = 3.
    // A 1-byte cell peels the low byte of this word.
    if (tk != 0 && tk != 1 && tk != 2 && tk != 3) {
      return 0;
    }
    if (pipe_modlet_fold_f64_elem_bits(arena, op, &flo, &fhi) == 0) {
      // Integer operand. The low word is the cast; a wider child truncates.
      if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val, &ihi) == 0) {
        return 0;
      }
      unsafe { lv = out_val[0]; }
      if (out_hi != (0 as *i32)) {
        if (lv < 0) {
          unsafe { out_hi[0] = 0 - 1; }
        } else {
          unsafe { out_hi[0] = 0; }
        }
      }
      return 1;
    }
    exp = (fhi >> 20) & 2047;
    if (exp == 2047) {
      return 0;
    }
    if (exp < 1023) {
      unsafe { out_val[0] = 0; }
      if (out_hi != (0 as *i32)) {
        unsafe { out_hi[0] = 0; }
      }
      return 1;
    }
    // |x| >= 2^32 stays unfolded. Binade [2^31, 2^32): exact ±2^31
    // and positive values in the binade store the wrapped 32-bit word
    // (bit 31 set). Negative non-exact stays 0. Matches Darwin
    // elem_const e==31 for i32/u32. PLATFORM: LINUX|UBUNTU.
    if (exp > 1054) {
      return 0;
    }
    if (exp == 1054) {
      if (fhi < 0) {
        if ((fhi & 1048575) != 0 || flo != 0) {
          return 0;
        }
        unsafe { out_val[0] = 0 - 2147483647 - 1; }
        if (out_hi != (0 as *i32)) {
          unsafe { out_hi[0] = 0 - 1; }
        }
        return 1;
      }
      // Positive [2^31, 2^32). Build the low word like Darwin e==31:
      // exact 2^31 is 0x80000000; other values keep bit 31 set.
      // Each shift stays inside a positive i32. Bit 31 is ORed last.
      mag = flo;
      top = 0;
      sh = 21;
      if (mag < 0) {
        mag = mag & 2147483647;
        top = 1 << 10;
      }
      mag = (mag >> sh) | top;
      step = (1 << 20) | (fhi & 1048575);
      mag = mag | ((step & 2047) << 11);
      mag = mag | (((step >> 11) & 511) << 22);
      mag = mag | (0 - 2147483647 - 1);
      unsafe { out_val[0] = mag; }
      if (out_hi != (0 as *i32)) {
        if (mag < 0) {
          unsafe { out_hi[0] = 0 - 1; }
        } else {
          unsafe { out_hi[0] = 0; }
        }
      }
      return 1;
    }
    parts[0] = flo;
    parts[1] = fhi;
    unsafe {
      unsafe { memcpy((&dv) as *u8, (&(parts[0])) as *u8, 8 as usize); }
    }
    iv = dv as i32;
    unsafe { out_val[0] = iv; }
    if (out_hi != (0 as *i32)) {
      if (iv < 0) {
        unsafe { out_hi[0] = 0 - 1; }
      } else {
        unsafe { out_hi[0] = 0; }
      }
    }
    return 1;
  }
  return 0;
}

/**
 * Detect ARRAY_LIT elems holding compile-time addresses (9.4.2): dest
 * elem type ptr (9) / fn (18) with elem VAR (3, bare same-module fn),
 * AS (54, `fn as *u8`), or ADDR_OF (51, `&global` / `&fn`). Recursive
 * over nested TYPE_ARRAY rows, mirroring the entry seeder walk. Prepare
 * now bakes such arrays via absolute64 RELA when the cell fits; this
 * predicate remains for the COMMON+seeder fallback (budget miss) and
 * documents the address-elem shape. Ptr-typed dest only — a bare global
 * in an i32 table is a value copy and keeps the fold path.
 * @param arena *u8 - ASTArena
 * @param init_ref i32 - ARRAY_LIT expr
 * @param elem_ty i32 - dest elem type_ref at this nesting level
 * @return i32 - 1 = has address elem (any level); 0 = none
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_array_lit_has_ptr_addr_elem(
  arena: *u8, init_ref: i32, elem_ty: i32
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let etk: i32 = 0;
  if (arena == (0 as *u8) || init_ref <= 0 || elem_ty <= 0) {
    return 0;
  }
  unsafe {
    unsafe { etk = pipeline_type_kind_ord_at(arena, elem_ty); }
  }
  if (etk != 9 && etk != 18 && etk != 10) {
    return 0;
  }
  unsafe {
    unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
    }
    if (eref > 0) {
      unsafe {
        unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
      }
      if (etk == 10) {
        // Nested row: recurse with the row's elem type (seeder twin walk).
        if (ek == 46) {
          if (pipe_modlet_array_lit_has_ptr_addr_elem(
              arena, eref, pipeline_type_elem_ref_at(arena, elem_ty)) != 0) {
            return 1;
          }
        }
      } else {
        if (ek == 3 || ek == 51 || ek == 54) {
          return 1;
        }
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Report whether an ARRAY_LIT contains STRING_LIT elements (recursively).
 * Used by the seeder (COMMON fallback) and by tests; prepare's use_data
 * gate now allows string-bearing arrays through the bake path when the
 * interned pool fits (pipe_modlet_array_lit_string_pool_bytes). Nested
 * `[K][N]*u8` rows are covered (ek==46 recurse).
 * @param arena *u8 - ASTArena
 * @param init_ref i32 - ARRAY_LIT expr
 * @return i32 - 1 = has STRING_LIT elem (any nesting level); 0 = none
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_array_lit_has_string_elem(
  arena: *u8, init_ref: i32
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  if (arena == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  unsafe {
    unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
    }
    if (eref > 0) {
      unsafe {
        unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
      }
      if (ek == 59) {
        return 1;
      }
      if (ek == 46) {
        if (pipe_modlet_array_lit_has_string_elem(arena, eref) != 0) {
          return 1;
        }
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Sum interned-pool bytes for every STRING_LIT elem (recursively).
 * Each STRING_LIT contributes slen+1 (payload + NUL). slen>4095 is the
 * parser STRING_LIT overflow cap: return -1 so prepare keeps the cell
 * COMMON rather than silently truncating. Nested ARRAY_LIT rows recurse.
 * @param arena *u8 - ASTArena
 * @param init_ref i32 - ARRAY_LIT expr
 * @return i32 - >=0 interned byte count (0 = no strings); -1 too-long/null
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_array_lit_string_pool_bytes(
  arena: *u8, init_ref: i32
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let slen: i32 = 0;
  let sub: i32 = 0;
  let total: i32 = 0;
  if (arena == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  unsafe {
    unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
    }
    if (eref > 0) {
      unsafe {
        unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
      }
      if (ek == 59) {
        unsafe {
          unsafe { slen = glue_asm_string_lit_len(arena, eref); }
        }
        if (slen < 0 || slen > 4095) {
          return 0 - 1;
        }
        total = total + slen + 1;
      }
      if (ek == 46) {
        sub = pipe_modlet_array_lit_string_pool_bytes(arena, eref);
        if (sub < 0) {
          return 0 - 1;
        }
        total = total + sub;
      }
    }
    ei = ei + 1;
  }
  return total;
}

/**
 * Assign a TU-unique COMMON symbol into label[idx].
 * Format (21 bytes): Lxml_<hex8(fnv32(name||idx))><hex8(module_fp)>
 * Historic Lxlang_ml_<idx> collided across every assembled TU (SHN_COMMON
 * takes the largest size). Ubuntu then aliased driver_check_only_flag_slot
 * to a 512-byte Lxlang_ml_0 whose first word was entry source len (0xa7),
 * so -o ran under parse_strict / check_only.
 * @param idx i32 — table index 0..n-1
 * @param module_fp i64 — pipe_modlet_module_fp()
 * @return void
 * PLATFORM: SHARED — ELF SHN_COMMON + Mach-O __DATA,__common.
 */
function pipe_modlet_assign_unique_label(idx: i32, module_fp: i64): void {
  let nl: i32 = 0;
  unsafe { nl = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(idx)); }
  let nbase: i32 = pipe_modlet_off_name(idx);
  let h: i64 = 2166136261;
  let k: i32 = 0;
  while (k < nl) {
    let b: i32 = 0;
    unsafe {
      b = g_pipeline_asm_modlet[nbase + k] as i32;
    }
    h = pipe_modlet_fnv32_mix(h, b);
    k = k + 1;
  }
  h = pipe_modlet_fnv32_mix(h, idx & 255);
  let lbase: i32 = pipe_modlet_off_label(idx);
  unsafe {
    g_pipeline_asm_modlet[lbase] = 76 as u8;
    g_pipeline_asm_modlet[lbase + 1] = 120 as u8;
    g_pipeline_asm_modlet[lbase + 2] = 109 as u8;
    g_pipeline_asm_modlet[lbase + 3] = 108 as u8;
    g_pipeline_asm_modlet[lbase + 4] = 95 as u8;
  }
  pipe_modlet_write_hex8(lbase, 5, h);
  pipe_modlet_write_hex8(lbase, 13, module_fp);
  unsafe { pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx), 21); }
}

/**
 * Width in bytes of one integer field inside a STRUCT_LIT.
 * @param arena *u8 — ASTArena; null returns -1
 * @param m *u8 — Module* that owns the layout; null returns -1
 * @param lit_ref i32 — STRUCT_LIT expr
 * @param fi i32 — field index
 * @return i32 — 1, 4, or 8; -1 when the field is not an integer scalar
 * PLATFORM: SHARED — same widths as a scalar ARRAY_LIT element.
 */
function pipe_modlet_struct_field_int_width(
  arena: *u8, m: *u8, lit_ref: i32, fi: i32
): i32 {
  let fty: i32 = 0;
  let k: i32 = 0;
  if (arena == (0 as *u8) || m == (0 as *u8) || lit_ref <= 0 || fi < 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi); }
  }
  if (fty <= 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { k = pipeline_type_kind_ord_at(arena, fty); }
  }
  // u8 / bool, then the 4-byte integers, then the 8-byte integers.
  // A named or aggregate field is not an integer scalar.
  if (k == 1 || k == 2) {
    return 1;
  }
  if (k == 0 || k == 3 || k == 13 || k == 14) {
    return 4;
  }
  if (k == 4 || k == 5 || k == 6 || k == 7 || k == 15) {
    return 8;
  }
  return 0 - 1;
}

/**
 * Poke one STRUCT_LIT into an already-zeroed .data span.
 * Integer fields (LIT and NEG-over-LIT) are stored little-endian at
 * elem_base plus the layout offset. f32 and f64 fields reuse
 * pipe_modlet_fold_f64_elem_bits and poke IEEE bits (esz 4 packs, esz 8
 * pokes both halves). Nested STRUCT_LIT recurses.
 * STRING_LIT fields intern through pipe_modlet_bake_string_lit_elem_to_data.
 * Pointer and function fields record an absolute64 reloc through
 * pipe_modlet_bake_ptr_addr_elem_to_data. ARRAY_LIT fields reuse
 * pipe_modlet_bake_array_lit_elems_to_data on the field span.
 * Any other field kind loud-fails. Padding stays the reserved zero.
 * @param arena *u8 — ASTArena
 * @param elf_ctx *u8 — ElfCodegenCtx
 * @param lit_ref i32 — STRUCT_LIT expr
 * @param elem_base i32 — absolute .data offset of this struct
 * @param m *u8 — Module*
 * @return i32 — 0 ok; -1 unsupported field, bad offset, or poke fail
 * PLATFORM: SHARED — ELF .data and Mach-O __DATA.
 */
function pipe_modlet_bake_struct_lit_to_data(
  arena: *u8, elf_ctx: *u8, lit_ref: i32, elem_base: i32, m: *u8
): i32 {
  let nf: i32 = 0;
  let fi: i32 = 0;
  let iref: i32 = 0;
  let ik: i32 = 0;
  let foff: i32 = 0;
  let fsz: i32 = 0;
  let ev: i32 = 0;
  let bi: i32 = 0;
  let rc: i32 = 0;
  let b: i32 = 0;
  let uw: u32 = 0 as u32;
  let fty: i32 = 0;
  let fk: i32 = 0;
  let et: i32 = 0;
  let span: i32 = 0;
  let pa: i32 = 0;
  let flo: i32 = 0;
  let fhi: i32 = 0;
  let fb: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || m == (0 as *u8) || lit_ref <= 0 || elem_base < 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref); }
  }
  if (nf < 0 || nf > 64) {
    return 0 - 1;
  }
  while (fi < nf) {
    unsafe {
      unsafe { iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi); }
    }
    if (iref > 0) {
      unsafe {
        unsafe { ik = pipeline_expr_kind_ord_at(arena, iref); }
        unsafe { foff = pipeline_expr_struct_lit_field_offset_at(arena, m, lit_ref, fi); }
      }
      if (foff < 0) {
        return 0 - 1;
      }
      if (ik == 45) {
        rc = pipe_modlet_bake_struct_lit_to_data(arena, elf_ctx, iref, elem_base + foff, m);
        if (rc != 0) {
          return rc;
        }
      } else {
        // STRING_LIT, ARRAY_LIT, and pointer/fn inits already have bakers.
        // An integer LIT stays on the peel below. PLATFORM: SHARED.
        if (ik == 59) {
          rc = pipe_modlet_bake_string_lit_elem_to_data(
            arena, elf_ctx, iref, elem_base + foff);
          if (rc != 0) {
            return rc;
          }
        } else {
          if (ik == 46) {
            fty = 0;
            span = 0;
            et = 0;
            unsafe {
              unsafe { fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi); }
            }
            if (fty <= 0) {
              return 0 - 1;
            }
            unsafe { span = glue_fixed_array_total_bytes_c(arena, fty, 0); }
            if (span <= 0) {
              return 0 - 1;
            }
            unsafe {
              unsafe { et = pipeline_type_elem_ref_at(arena, fty); }
            }
            rc = pipe_modlet_bake_array_lit_elems_to_data(
              arena, elf_ctx, iref, et, elem_base + foff, 0, span, m);
            if (rc != 0) {
              return rc;
            }
          } else {
            fk = 0;
            fty = 0;
            pa = 1;
            unsafe {
              unsafe { fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi); }
            }
            if (fty > 0) {
              unsafe {
                unsafe { fk = pipeline_type_kind_ord_at(arena, fty); }
              }
            }
            // TYPE_PTR (9) and TYPE_FN (18) take an absolute64 slot.
            // pa == 1 means the init is not an address literal.
            if (fk == 9 || fk == 18) {
              pa = pipe_modlet_bake_ptr_addr_elem_to_data(
                arena, elf_ctx, m, iref, 8, elem_base + foff);
              if (pa < 0) {
                return 0 - 1;
              }
            }
            if (pa != 0) {
              // TYPE_F32 (14) and TYPE_F64 (15) reuse the array-element
              // folder. A fold of 0 loud-fails (VAR, a non-float cast, or
              // an integer div0 inside the operand). Integer fields stay
              // on the peel below. PLATFORM: SHARED.
              if (fk == 14 || fk == 15) {
                flo = 0;
                fhi = 0;
                fb = 0;
                if (pipe_modlet_fold_f64_elem_bits(arena, iref, &flo, &fhi) == 0) {
                  return 0 - 1;
                }
                if (fk == 14) {
                  unsafe {
                    unsafe { fb = glue_ieee_f64_bits_to_f32_bits(flo, fhi); }
                  }
                  rc = pipe_modlet_data_poke_u32_le(elf_ctx, elem_base + foff, fb);
                  if (rc != 0) {
                    return rc;
                  }
                } else {
                  rc = pipe_modlet_data_poke_u32_le(elf_ctx, elem_base + foff, flo);
                  if (rc != 0) {
                    return rc;
                  }
                  rc = pipe_modlet_data_poke_u32_le(elf_ctx, elem_base + foff + 4, fhi);
                  if (rc != 0) {
                    return rc;
                  }
                }
              } else {
        fsz = pipe_modlet_struct_field_int_width(arena, m, lit_ref, fi);
        if (fsz <= 0) {
          return 0 - 1;
        }
        let ehi: i32 = 0;
        if (pipe_modlet_array_lit_elem_const_val(arena, iref, &ev, &ehi) == 0) {
          return 0 - 1;
        }
        // Low four bytes, then the high half from the folder. A value that
        // fits in i32 has a sign-filled high half. A wider i64 trunc carries
        // the real high half, so 2^31 is not sign-extended to a negative.
        // Unsigned division inside each half. PLATFORM: SHARED.
        uw = ev as u32;
        bi = 0;
        while (bi < fsz && bi < 4) {
          b = (uw & 255) as i32;
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, elem_base + foff + bi, b);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          uw = uw / 256;
          bi = bi + 1;
        }
        uw = ehi as u32;
        while (bi < fsz) {
          b = (uw & 255) as i32;
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, elem_base + foff + bi, b);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          uw = uw / 256;
          bi = bi + 1;
        }
              }
            }
          }
        }
      }
    }
    fi = fi + 1;
  }
  return 0;
}

/**
 * Store one STRUCT_LIT into the COMMON cell whose address is in rbx.
 * Integer fields use mov-imm64 plus a sized store at base_off plus the
 * layout offset. f32 and f64 fields reuse pipe_modlet_fold_f64_elem_bits
 * and store the IEEE bits (f32 sign-extends only the unused high half).
 * Nested STRUCT_LIT recurses. STRING_LIT fields lea the
 * bytes and store the pointer. Pointer and function fields use
 * pipe_modlet_seed_ptr_addr_elem_to_rbx. ARRAY_LIT fields reuse
 * pipe_modlet_seed_array_lit_elems_to_rbx. Any other field kind
 * loud-fails. The cell is BSS zero, so padding stays zero.
 * @param arena *u8 — ASTArena
 * @param elf_ctx *u8 — ElfCodegenCtx
 * @param lit_ref i32 — STRUCT_LIT expr
 * @param ta i32 — target arch
 * @param base_off i32 — byte offset of this struct inside the cell
 * @param m *u8 — Module*
 * @return i32 — 0 ok; -1 unsupported field or encode fail
 * PLATFORM: SHARED — x86_64 SysV and AArch64.
 */
function pipe_modlet_seed_struct_lit_to_rbx(
  arena: *u8, elf_ctx: *u8, lit_ref: i32, ta: i32, base_off: i32, m: *u8
): i32 {
  let nf: i32 = 0;
  let fi: i32 = 0;
  let iref: i32 = 0;
  let ik: i32 = 0;
  let foff: i32 = 0;
  let fsz: i32 = 0;
  let ev: i32 = 0;
  let hi: i32 = 0;
  let rc: i32 = 0;
  let fty: i32 = 0;
  let fk: i32 = 0;
  let et: i32 = 0;
  let span: i32 = 0;
  let pa: i32 = 0;
  let flo: i32 = 0;
  let fhi: i32 = 0;
  let fb: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || m == (0 as *u8) || lit_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref); }
  }
  if (nf < 0 || nf > 64) {
    return 0 - 1;
  }
  while (fi < nf) {
    unsafe {
      unsafe { iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi); }
    }
    if (iref > 0) {
      unsafe {
        unsafe { ik = pipeline_expr_kind_ord_at(arena, iref); }
        unsafe { foff = pipeline_expr_struct_lit_field_offset_at(arena, m, lit_ref, fi); }
      }
      if (foff < 0) {
        return 0 - 1;
      }
      if (ik == 45) {
        rc = pipe_modlet_seed_struct_lit_to_rbx(arena, elf_ctx, iref, ta, base_off + foff, m);
        if (rc != 0) {
          return rc;
        }
      } else {
        // Same field kinds as the .data baker. This path runs only when
        // the cell stayed COMMON. PLATFORM: SHARED.
        if (ik == 59) {
          unsafe {
            unsafe { rc = glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, iref, ta); }
          }
          if (rc != 0) {
            return rc;
          }
          unsafe {
            unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + foff, 8, ta); }
          }
          if (rc != 0) {
            return 0 - 1;
          }
        } else {
          if (ik == 46) {
            fty = 0;
            span = 0;
            et = 0;
            unsafe {
              unsafe { fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi); }
            }
            if (fty <= 0) {
              return 0 - 1;
            }
            unsafe { span = glue_fixed_array_total_bytes_c(arena, fty, 0); }
            if (span <= 0) {
              return 0 - 1;
            }
            unsafe {
              unsafe { et = pipeline_type_elem_ref_at(arena, fty); }
            }
            rc = pipe_modlet_seed_array_lit_elems_to_rbx(
              arena, elf_ctx, iref, et, ta, base_off + foff, m);
            if (rc != 0) {
              return rc;
            }
          } else {
            fk = 0;
            fty = 0;
            pa = 1;
            unsafe {
              unsafe { fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi); }
            }
            if (fty > 0) {
              unsafe {
                unsafe { fk = pipeline_type_kind_ord_at(arena, fty); }
              }
            }
            if (fk == 9 || fk == 18) {
              pa = pipe_modlet_seed_ptr_addr_elem_to_rbx(
                arena, elf_ctx, m, iref, 8, base_off + foff, ta);
              if (pa < 0) {
                return 0 - 1;
              }
            }
            if (pa != 0) {
              // Same f32/f64 contract as the .data baker. COMMON cells only.
              // PLATFORM: SHARED.
              if (fk == 14 || fk == 15) {
                flo = 0;
                fhi = 0;
                fb = 0;
                if (pipe_modlet_fold_f64_elem_bits(arena, iref, &flo, &fhi) == 0) {
                  return 0 - 1;
                }
                if (fk == 14) {
                  unsafe {
                    unsafe { fb = glue_ieee_f64_bits_to_f32_bits(flo, fhi); }
                  }
                  hi = 0;
                  if (fb < 0) {
                    hi = 0 - 1;
                  }
                  unsafe {
                    unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, fb, hi, ta); }
                  }
                  if (rc != 0) {
                    return 0 - 1;
                  }
                  unsafe {
                    unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + foff, 4, ta); }
                  }
                  if (rc != 0) {
                    return 0 - 1;
                  }
                } else {
                  unsafe {
                    unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, flo, fhi, ta); }
                  }
                  if (rc != 0) {
                    return 0 - 1;
                  }
                  unsafe {
                    unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + foff, 8, ta); }
                  }
                  if (rc != 0) {
                    return 0 - 1;
                  }
                }
              } else {
              fsz = pipe_modlet_struct_field_int_width(arena, m, lit_ref, fi);
              if (fsz <= 0) {
                return 0 - 1;
              }
              if (pipe_modlet_array_lit_elem_const_val(arena, iref, &ev, &hi) == 0) {
                return 0 - 1;
              }
              unsafe {
                unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, ev, hi, ta); }
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + foff, fsz, ta); }
              }
              if (rc != 0) {
                return 0 - 1;
              }
              }
            }
          }
        }
      }
    }
    fi = fi + 1;
  }
  return 0;
}

/**
 * Fold one array element that is an f64 constant into IEEE lo/hi halves.
 * Accepts EXPR_FLOAT_LIT (ek 1), EXPR_NEG over a folded float (ek 22,
 * including the parser form `[-1.0, 2.0]`), EXPR_ADD / EXPR_SUB / EXPR_MUL
 * / EXPR_DIV (ek 4, 5, 6, 7) of two folded floats, and EXPR_AS (ek 54)
 * whose target is TYPE_F32 (14) or TYPE_F64 (15) of a folded float or
 * of an integer constant.
 * Integer literals and integer binops return 0 so the caller keeps
 * pipe_modlet_array_lit_elem_const_val, which folds integer DIV and MOD.
 * Float MOD is not an operator: typeck rejects `%` on f32 and f64, so
 * this helper never sees ek 8 for a float. A zero float divisor stays
 * the IEEE result of the host divide (infinity or NaN), the same result
 * as divsd. It is not the integer idiv trap.
 * NEG flips the f64 sign bit (high half xor 0x80000000). That is unary
 * minus on the IEEE encoding, including a negated float binop.
 * ADD, SUB, MUL, and DIV copy the halves into f64 with memcpy, apply the
 * language operator, and copy the bits back. Same host-float path as
 * glue_ieee_f64_bits_to_f32_bits. A binop whose resolved type is f32 is
 * rounded back to f32 and widened, so a nested f32 op does not keep extra
 * f64 bits. Two f32 values' quotient is rounded once, matching an f32
 * operator.
 * EXPR_AS to f64 of a folded float keeps the operand bits. EXPR_AS to
 * f32 of a folded float rounds through glue_ieee_f64_bits_to_f32_bits
 * and widens with glue_ieee_f32_bits_to_f64_lo / hi, the same carry as
 * glue_emit_float_lit_to_rax_elf_c. EXPR_AS of an integer constant uses
 * pipe_modlet_array_lit_elem_const_val, then glue_i32_to_f32_bits or
 * glue_i64_to_f64_bits (the runtime emitter's host cast). An f32 result
 * is widened the same way, so the baker's esz-4 pack is exact. A zero
 * integer divisor or INT_MIN divided by -1 inside that operand still
 * returns 0. Other cast targets return 0.
 * Little-endian: lo is the first word.
 * @param arena *u8 - ASTArena; null returns 0
 * @param eref i32 - element expr ref; <= 0 returns 0
 * @param out_lo *i32 - low 32 bits of the f64 pattern; null returns 0
 * @param out_hi *i32 - high 32 bits of the f64 pattern; null returns 0
 * @return i32 - 1 when both halves are written; 0 when this is not a float constant
 * PLATFORM: SHARED — little-endian host float; LINUX gold.
 */
function pipe_modlet_fold_f64_elem_bits(
  arena: *u8, eref: i32, out_lo: *i32, out_hi: *i32
): i32 {
  let ek: i32 = 0;
  let op: i32 = 0;
  let left: i32 = 0;
  let right: i32 = 0;
  let llo: i32 = 0;
  let lhi: i32 = 0;
  let rlo: i32 = 0;
  let rhi: i32 = 0;
  let hu: u32 = 0;
  let sign: u32 = 2147483648;
  let flo: i32 = 0;
  let fhi: i32 = 0;
  if (arena == (0 as *u8) || eref <= 0 || out_lo == (0 as *i32) || out_hi == (0 as *i32)) {
    return 0;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
  }
  if (ek == 1) {
    unsafe {
      unsafe { flo = pipeline_expr_float_bits_lo_at(arena, eref); }
      unsafe { fhi = pipeline_expr_float_bits_hi_at(arena, eref); }
    }
    unsafe {
      out_lo[0] = flo;
      out_hi[0] = fhi;
    }
    return 1;
  }
  // Unary minus of a float constant. Integer NEG returns 0 here.
  if (ek == 22) {
    unsafe {
      unsafe { op = pipeline_expr_unary_operand_ref_at(arena, eref); }
    }
    if (op <= 0) {
      return 0;
    }
    if (pipe_modlet_fold_f64_elem_bits(arena, op, out_lo, out_hi) == 0) {
      return 0;
    }
    unsafe { hu = out_hi[0] as u32; }
    hu = hu ^ sign;
    unsafe { out_hi[0] = hu as i32; }
    return 1;
  }
  // Float ADD/SUB/MUL/DIV. A zero divisor stays IEEE (divsd).
  // Float MOD is rejected by typeck and never reaches this helper.
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7) {
    let av: f64 = 0.0;
    let bv: f64 = 0.0;
    let fr: f64 = 0.0;
    let lp: i32[2] = [];
    let rp: i32[2] = [];
    let oparts: i32[2] = [];
    let rty: i32 = 0;
    let rtk: i32 = 0;
    let fb2: i32 = 0;
    unsafe {
      unsafe { left = pipeline_expr_binop_left_ref_at(arena, eref); }
      unsafe { right = pipeline_expr_binop_right_ref_at(arena, eref); }
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    // Left bits must be copied out before the right call reuses out_lo/out_hi.
    if (pipe_modlet_fold_f64_elem_bits(arena, left, out_lo, out_hi) == 0) {
      return 0;
    }
    unsafe {
      llo = out_lo[0];
      lhi = out_hi[0];
    }
    if (pipe_modlet_fold_f64_elem_bits(arena, right, out_lo, out_hi) == 0) {
      return 0;
    }
    unsafe {
      rlo = out_lo[0];
      rhi = out_hi[0];
    }
    lp[0] = llo;
    lp[1] = lhi;
    rp[0] = rlo;
    rp[1] = rhi;
    // Host f64 operator. memcpy is the same bit copy as glue_ieee_f64_bits_to_f32_bits.
    unsafe {
      unsafe { memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize); }
      unsafe { memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize); }
    }
    if (ek == 4) {
      fr = av + bv;
    } else {
      if (ek == 5) {
        fr = av - bv;
      } else {
        if (ek == 6) {
          fr = av * bv;
        } else {
          // EXPR_DIV. Host f64 `/` lowers to divsd. Zero stays IEEE.
          fr = av / bv;
        }
      }
    }
    unsafe {
      unsafe { memcpy((&(oparts[0])) as *u8, (&fr) as *u8, 8 as usize); }
    }
    unsafe {
      out_lo[0] = oparts[0];
      out_hi[0] = oparts[1];
    }
    // TYPE_F32 result: round, then widen. Unset resolved type stays f64;
    // the baker still packs from the element size.
    unsafe {
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, eref); }
    }
    if (rty > 0) {
      unsafe {
        unsafe { rtk = pipeline_type_kind_ord_at(arena, rty); }
      }
    }
    if (rtk == 14) {
      unsafe {
        unsafe { fb2 = glue_ieee_f64_bits_to_f32_bits(oparts[0], oparts[1]); }
      }
      unsafe {
        unsafe { out_lo[0] = glue_ieee_f32_bits_to_f64_lo(fb2); }
        unsafe { out_hi[0] = glue_ieee_f32_bits_to_f64_hi(fb2); }
      }
    }
    return 1;
  }
  // EXPR_AS to f32 or f64. A folded float keeps the round path.
  // An integer constant uses glue_i32_to_f32_bits / glue_i64_to_f64_bits.
  // Pointer casts and other targets return 0. Integer div0 stays 0.
  if (ek == 54) {
    let tgt: i32 = 0;
    let tk: i32 = 0;
    let fb: i32 = 0;
    let iv: i32 = 0;
    unsafe {
      unsafe { op = pipeline_expr_as_operand_ref_at(arena, eref); }
      unsafe { tgt = pipeline_expr_as_target_type_ref_at(arena, eref); }
    }
    if (op <= 0 || tgt <= 0) {
      return 0;
    }
    unsafe {
      unsafe { tk = pipeline_type_kind_ord_at(arena, tgt); }
    }
    // .x TypeKind: TYPE_F32 = 14, TYPE_F64 = 15. Not the C enum.
    if (tk != 14 && tk != 15) {
      return 0;
    }
    if (pipe_modlet_fold_f64_elem_bits(arena, op, out_lo, out_hi) == 0) {
      // Operand is not a float constant. Fold it as an i32 constant.
      // glue_* is the same host cast the runtime emitter already calls.
      if (pipe_modlet_array_lit_elem_const_val(arena, op, &iv, (0 as *i32)) == 0) {
        return 0;
      }
      if (tk == 14) {
        unsafe {
          unsafe { fb = glue_i32_to_f32_bits(iv); }
        }
        unsafe {
          unsafe { out_lo[0] = glue_ieee_f32_bits_to_f64_lo(fb); }
          unsafe { out_hi[0] = glue_ieee_f32_bits_to_f64_hi(fb); }
        }
        return 1;
      }
      unsafe {
        unsafe { glue_i64_to_f64_bits(iv as i64, out_lo, out_hi); }
      }
      return 1;
    }
    if (tk == 15) {
      return 1;
    }
    unsafe {
      flo = out_lo[0];
      fhi = out_hi[0];
    }
    unsafe {
      unsafe { fb = glue_ieee_f64_bits_to_f32_bits(flo, fhi); }
    }
    unsafe {
      unsafe { out_lo[0] = glue_ieee_f32_bits_to_f64_lo(fb); }
      unsafe { out_hi[0] = glue_ieee_f32_bits_to_f64_hi(fb); }
    }
    return 1;
  }
  return 0;
}

/**
 * Poke four little-endian bytes of an i32 bit pattern into the .data buffer.
 * Used for an f32 pack and for each half of an f64 FLOAT_LIT. The value is
 * a bit pattern, not a numeric magnitude: high bytes are shifted with
 * unsigned division so a negative pattern does not sign-fill.
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param off i32 - absolute offset in the .data buffer
 * @param bits i32 - 32-bit pattern to store
 * @return i32 - 0 ok; -1 poke failed
 * PLATFORM: SHARED freestanding · ELF .data · Mach-O __DATA.
 */
function pipe_modlet_data_poke_u32_le(elf_ctx: *u8, off: i32, bits: i32): i32 {
  let bi: i32 = 0;
  let uw: u32 = 0;
  let rc: i32 = 0;
  uw = bits as u32;
  while (bi < 4) {
    unsafe {
      unsafe {
        rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, off + bi, (uw & 255) as i32);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    uw = uw / 256;
    bi = bi + 1;
  }
  return 0;
}

/**
 * Bake ARRAY_LIT constant elems into an already-reserved .data cell.
 * Twin of pipe_modlet_seed_array_lit_elems_to_rbx but writes object-file
 * bytes (library TUs never enter hoist-target seed). One nested ARRAY_LIT
 * level for `[K][N]T` rows; deeper nest is a later leaf. Empty lit is a
 * no-op (zeros already reserved). Elem contract: EXPR_LIT, EXPR_NEG over
 * a folded constant, and integer binops EXPR_ADD..EXPR_BITXOR fold via
 * pipe_modlet_array_lit_elem_const_val. Float constants
 * (FLOAT_LIT, NEG of a float, ADD/SUB/MUL/DIV of floats, AS to f32 or f64
 * of a folded float or an integer constant)
 * poke IEEE bits via
 * pipe_modlet_fold_f64_elem_bits: esz 4 packs f64 bits to f32 through
 * glue_ieee_f64_bits_to_f32_bits, esz 8 pokes both halves. STRUCT_LIT elems
 * poke integer, string, pointer, and nested array fields. EXPR_AS of a
 * folded float, or of an integer constant, to i32/u32/i64/u64/usize/isize
 * folds through the same integer helper; the 8-byte peel writes that
 * helper's high half.
 * Anything else (VAR, a bool or u8 cast, a pointer cast, ...) loud-fails —
 * the historic silent drop baked zeros for `[-1, 2]`. STRING_LIT elems intern into the
 * .data string pool and record an absolute64 reloc on the pointer slot.
 * 9.4.2 ptr/fn ADDR_OF / bare-fn elems record an absolute64 reloc on the
 * named symbol (G.7 complete of pipeline_elf_ctx_append_reloc_absolute64).
 * slen>4095 loud-fails (parser STRING_LIT overflow cap / L011).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param init_ref i32 - ARRAY_LIT expr
 * @param elem_ty i32 - dest elem type_ref (scalar or TYPE_ARRAY row)
 * @param data_base i32 - absolute offset of the cell in g_pipe_elf_data_buf
 * @param base_off i32 - byte offset within the cell
 * @param span_bytes i32 - bytes this literal may occupy (cell size at top
 *     call, row size for nested rows); literal exceeding span = loud fail
 * @param m *u8 - Module* (fn lookup for address elems; may be null)
 * @return i32 - 0 ok; -1 poke fail / non-constant elem / span overflow
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 · ELF .data.
 */
function pipe_modlet_bake_array_lit_elems_to_data(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32, data_base: i32, base_off: i32,
  span_bytes: i32, m: *u8
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let ev: i32 = 0;
  let esz: i32 = 4;
  let etk: i32 = 0;
  let inner_et: i32 = 0;
  let row_sz: i32 = 0;
  let rc: i32 = 0;
  let bi: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  if (elem_ty > 0) {
    unsafe {
      unsafe { etk = pipeline_type_kind_ord_at(arena, elem_ty); }
    }
  }
  if (etk == 10) {
    unsafe {
      unsafe { inner_et = pipeline_type_elem_ref_at(arena, elem_ty); }
      unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
    }
    unsafe { row_sz = glue_fixed_array_total_bytes_c(arena, elem_ty, 0); }
    if (row_sz <= 0) {
      unsafe { row_sz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty); }
    }
    // ne<=0: empty row lit is a no-op (zeros already reserved). Span guard:
    // row count must fit this literal's row span — a mismatch (typeck gap
    // or absurd literal) loud-fails instead of silently leaving rows zero.
    if (ne <= 0) {
      return 0;
    }
    if (row_sz > 0 && ne > span_bytes / row_sz) {
      return 0 - 1;
    }
    ei = 0;
    while (ei < ne) {
      unsafe {
        unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
      }
      if (eref > 0) {
        unsafe {
          unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
        }
        if (ek == 46) {
          rc = pipe_modlet_bake_array_lit_elems_to_data(
            arena, elf_ctx, eref, inner_et, data_base, base_off + ei * row_sz, row_sz, m);
          if (rc != 0) {
            return rc;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
  unsafe { esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty); }
  // TYPE_NAMED keeps the struct stride. Clamping a 12-byte struct to 4
  // would overlap the next element. Scalar elems stay 1/2/4/8.
  if (etk != 8) {
    if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
      esz = 4;
    }
  }
  if (etk == 8 && esz <= 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
  }
  // ne<=0: empty lit is a no-op (zeros already reserved). Span guard:
  // elem count must fit this literal's elem span (no silent truncation).
  if (ne <= 0) {
    return 0;
  }
  if (esz > 0 && ne > span_bytes / esz) {
    return 0 - 1;
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
    }
    if (eref > 0) {
      unsafe {
        unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
      }
      // STRING_LIT elem: intern bytes + NUL into the .data pool and
      // record an absolute64 reloc on this pointer slot. Prepare now
      // routes string-bearing arrays here when the pool fits.
      if (ek == 59) {
        rc = pipe_modlet_bake_string_lit_elem_to_data(
          arena, elf_ctx, eref, data_base + base_off + ei * esz);
        if (rc != 0) {
          return rc;
        }
        ei = ei + 1;
        continue;
      }
      // 9.4.2 address-valued elem (bare fn / `fn as *u8` / `&global`):
      // record an absolute64 reloc on this pointer slot. rc==1 → not an
      // address literal, fall through to the const fold (loud-fail).
      if ((etk == 9 || etk == 18) && m != (0 as *u8)) {
        rc = pipe_modlet_bake_ptr_addr_elem_to_data(
          arena, elf_ctx, m, eref, esz, data_base + base_off + ei * esz);
        if (rc < 0) {
          return 0 - 1;
        }
        if (rc == 0) {
          ei = ei + 1;
          continue;
        }
      }
      // STRUCT_LIT: poke integer, string, pointer, and array fields.
      // PLATFORM: SHARED.
      if (ek == 45) {
        rc = pipe_modlet_bake_struct_lit_to_data(
          arena, elf_ctx, eref, data_base + base_off + ei * esz, m);
        if (rc != 0) {
          return rc;
        }
        ei = ei + 1;
        continue;
      }
      // Float constant, or `as f32` / `as f64` of a folded float or an
      // integer constant. Bare integer elems return 0 and fall through.
      // esz 4 packs to f32; esz 8 pokes both halves. Other sizes are not
      // a float slot. PLATFORM: SHARED.
      let flo: i32 = 0;
      let fhi: i32 = 0;
      let fb: i32 = 0;
      if (pipe_modlet_fold_f64_elem_bits(arena, eref, &flo, &fhi) == 1) {
        if (esz == 4) {
          unsafe {
            unsafe { fb = glue_ieee_f64_bits_to_f32_bits(flo, fhi); }
          }
          rc = pipe_modlet_data_poke_u32_le(elf_ctx, data_base + base_off + ei * esz, fb);
          if (rc != 0) {
            return rc;
          }
        } else {
          if (esz == 8) {
            rc = pipe_modlet_data_poke_u32_le(elf_ctx, data_base + base_off + ei * esz, flo);
            if (rc != 0) {
              return rc;
            }
            rc = pipe_modlet_data_poke_u32_le(elf_ctx, data_base + base_off + ei * esz + 4, fhi);
            if (rc != 0) {
              return rc;
            }
          } else {
            return 0 - 1;
          }
        }
        ei = ei + 1;
        continue;
      }
      // LIT / NEG / integer binop: fold, then peel two's-complement bytes
      // little-endian via u32 (unsigned division). The historic signed
      // `cur / 256` peel corrupted bytes 1..3 of negative elems.
      let ehi: i32 = 0;
      if (pipe_modlet_array_lit_elem_const_val(arena, eref, &ev, &ehi) == 0) {
        return 0 - 1;
      }
      // Low half, then the high half. esz <= 4 never reads ehi, so an i32
      // slot stays the historic 4-byte peel. esz 8 writes the i64 high half.
      // Unsigned division so a negative pattern does not sign-fill inside
      // one half. PLATFORM: SHARED.
      let uw: u32 = ev as u32;
      bi = 0;
      while (bi < esz && bi < 4) {
        unsafe {
          rc = pipeline_elf_ctx_data_poke_u8(
            elf_ctx, data_base + base_off + ei * esz + bi, (uw & 255) as i32);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        uw = uw / 256;
        bi = bi + 1;
      }
      uw = ehi as u32;
      while (bi < esz) {
        unsafe {
          rc = pipeline_elf_ctx_data_poke_u8(
            elf_ctx, data_base + base_off + ei * esz + bi, (uw & 255) as i32);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        uw = uw / 256;
        bi = bi + 1;
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Bake one address-valued ARRAY_LIT elem as an absolute64 reloc on an
 * already-reserved .data pointer slot (9.4.2).
 *
 * Completes the STRING_LIT intern path: named-symbol addresses (bare
 * same-module fn, `fn as *u8`, `&global`) cannot be poked as immediates,
 * so prepare used to keep those tables COMMON and rely on the hoist-target
 * seeder. Library TUs never seed, leaving the slots NULL. G.7: reloc
 * authority is pipeline_elf_ctx_append_reloc_absolute64 (F7 vtable +
 * STRING_LIT intern). Symbol spelling is pipe_modlet_fn_sym_spell_into
 * (same Mach-O '_' / ELF bare as pipe_modlet_lea_fn_sym_to_rax).
 *
 * ADDR_OF prefers the modlet unique label (COMMON or .data cell), then
 * the same-module function link symbol. A bare VAR that is not a
 * same-module fn is a VALUE copy, not an address literal: return 1 so
 * the caller falls through to the const fold (which loud-fails).
 *
 * Called with shndx_override already 4 (prepare's bake window).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param m *u8 - Module* (fn lookup; null → not-an-address-elem)
 * @param eref i32 - element expr ref
 * @param esz i32 - dest elem byte size (must be 8)
 * @param slot_off i32 - absolute .data offset of the 8-byte pointer slot
 * @return i32 - 0 recorded reloc; 1 not an address elem; -1 loud fail
 * PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA unsigned64.
 */
function pipe_modlet_bake_ptr_addr_elem_to_data(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, slot_off: i32
): i32 {
  let ek: i32 = 0;
  let is_addr_of: i32 = 0;
  let nref: i32 = 0;
  let vlen: i32 = 0;
  let name: u8[256] = [];
  let sym: u8[130] = [];
  let slen: i32 = 0;
  let fi: i32 = 0;
  let idx: i32 = 0;
  let llen: i32 = 0;
  let lbase: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0 || slot_off < 0) {
    return 1;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
  }
  if (ek == 54) {
    unsafe {
      unsafe { nref = pipeline_expr_as_operand_ref_at(arena, eref); }
    }
  } else {
    if (ek == 51) {
      is_addr_of = 1;
      unsafe {
        unsafe { nref = pipeline_expr_unary_operand_ref_at(arena, eref); }
      }
    } else {
      if (ek != 3) {
        return 1;
      }
      nref = eref;
    }
  }
  if (nref <= 0) {
    return 1;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, nref); }
  }
  if (ek != 3) {
    return 1;
  }
  unsafe {
    unsafe { vlen = pipeline_expr_var_name_len(arena, nref); }
  }
  if (vlen <= 0 || vlen > 255) {
    return 0 - 1;
  }
  unsafe {
    unsafe { pipeline_expr_var_name_into(arena, nref, &name[0]); }
  }
  if (esz != 8) {
    return 0 - 1;
  }
  if (is_addr_of != 0) {
    idx = pipeline_asm_modlet_find(&name[0], vlen);
    if (idx >= 0) {
      unsafe { llen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx)); }
      lbase = pipe_modlet_off_label(idx);
      if (llen <= 0 || llen > 24) {
        return 0 - 1;
      }
      unsafe {
        rc = pipeline_elf_ctx_append_reloc_absolute64(
          elf_ctx, slot_off, &g_pipeline_asm_modlet[lbase], llen);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    if (m == (0 as *u8)) {
      return 0 - 1;
    }
    unsafe {
      unsafe { fi = glue_module_func_index_by_name_c(m, &name[0], vlen); }
    }
    if (fi < 0) {
      return 0 - 1;
    }
    slen = pipe_modlet_fn_sym_spell_into(elf_ctx, &name[0], vlen, &sym[0]);
    if (slen <= 0) {
      return 0 - 1;
    }
    unsafe {
      unsafe { rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &sym[0], slen); }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  if (m == (0 as *u8)) {
    return 1;
  }
  unsafe {
    unsafe { fi = glue_module_func_index_by_name_c(m, &name[0], vlen); }
  }
  if (fi < 0) {
    return 1;
  }
  slen = pipe_modlet_fn_sym_spell_into(elf_ctx, &name[0], vlen, &sym[0]);
  if (slen <= 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &sym[0], slen); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Bake a scalar module-let immediate into an already-reserved .data cell.
 * wave344: library Cap TUs never run seed_nonzero; non-zero COMMON stays 0.
 * Peels two's-complement LE bytes via u32 (same as ARRAY_LIT LIT peel).
 * Sign-extends into bytes beyond 4 when csz>=8 (NEG -1 → 0xff..ff).
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param data_off i32 — absolute .data offset of the cell
 * @param imm i32 — folded init (may be negative)
 * @param csz i32 — cell payload bytes (1..8 typical; capped at 8)
 * @return i32 — 0 ok; -1 poke fail / bad args
 * PLATFORM: SHARED freestanding · ELF .data · Mach-O __DATA,__const.
 */
function pipe_modlet_bake_scalar_imm_to_data(
  elf_ctx: *u8, data_off: i32, imm: i32, csz: i32
): i32 {
  let bi: i32 = 0;
  let n: i32 = 0;
  let rc: i32 = 0;
  let uw: u32 = 0;
  let hi: u32 = 0;
  if (elf_ctx == (0 as *u8) || data_off < 0 || csz <= 0) {
    return 0 - 1;
  }
  n = csz;
  if (n > 8) {
    n = 8;
  }
  // Same unsigned LE peel as ARRAY_LIT LIT elems (signed /256 corrupts).
  uw = imm as u32;
  bi = 0;
  while (bi < n && bi < 4) {
    unsafe {
      unsafe { rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, data_off + bi, (uw & 255) as i32); }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    uw = uw / 256;
    bi = bi + 1;
  }
  // Sign-extend into bytes 4..7 for 8-byte cells (NEG -1 → 0xff..ff).
  if (bi < n) {
    hi = 0;
    if (imm < 0) {
      hi = 4294967295 as u32;
    }
    while (bi < n) {
      unsafe {
        unsafe { rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, data_off + bi, (hi & 255) as i32); }
      }
      if (rc != 0) {
        return 0 - 1;
      }
      hi = hi / 256;
      bi = bi + 1;
    }
  }
  return 0;
}

/**
 * Intern one STRING_LIT into the F7 .data string pool and record an
 * absolute64 reloc on the already-reserved pointer slot.
 *
 * Label form (22 bytes, TU-unique): Lxmls_ + hex8(seq) + hex8(module_fp).
 * Seq resets with the modlet table. G.7: reloc authority is
 * pipeline_elf_ctx_append_reloc_absolute64 (same sentinel the F7 vtable
 * statics use). Bytes come from the STRING_LIT overflow chain (head
 * var_name plus int_val-linked chunks); slen>4095 loud-fails.
 *
 * Called with shndx_override already 4 (prepare's bake window).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param eref i32 - STRING_LIT expr
 * @param slot_off i32 - absolute .data offset of the 8-byte pointer slot
 * @return i32 - 0 ok; -1 intern/reloc/label fail
 * PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA unsigned64.
 */
function pipe_modlet_bake_string_lit_elem_to_data(
  arena: *u8, elf_ctx: *u8, eref: i32, slot_off: i32
): i32 {
  let slen: i32 = 0;
  let pool_off: i32 = 0;
  let rc: i32 = 0;
  let bi: i32 = 0;
  let seq: i32 = 0;
  let fp: i64 = 0;
  let lab: u8[24] = [];
  let i: i32 = 0;
  let shift: i32 = 0;
  let nib: i32 = 0;
  let ch: u8 = 0 as u8;
  let sbuf: u8[256] = [];
  let cur: i32 = 0;
  let n: i32 = 0;
  let copied: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0 || slot_off < 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { slen = glue_asm_string_lit_len(arena, eref); }
  }
  if (slen < 0 || slen > 4095) {
    return 0 - 1;
  }
  unsafe {
    unsafe { pool_off = pipeline_elf_ctx_emit_data_len(elf_ctx); }
  }
  if (pool_off < 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, slen + 1); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  copied = 0;
  cur = eref;
  while (copied < slen && cur > 0) {
    unsafe {
      unsafe { pipeline_expr_var_name_into(arena, cur, &sbuf[0]); }
    }
    if (cur == eref) {
      n = slen;
      if (n > 255) {
        n = 255;
      }
    } else {
      unsafe {
        unsafe { n = glue_asm_string_lit_len(arena, cur); }
      }
    }
    if (n < 0) {
      n = 0;
    }
    if (n > slen - copied) {
      n = slen - copied;
    }
    bi = 0;
    while (bi < n) {
      unsafe {
        unsafe { rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, pool_off + copied + bi, sbuf[bi] as i32); }
      }
      if (rc != 0) {
        return 0 - 1;
      }
      bi = bi + 1;
    }
    copied = copied + n;
    unsafe {
      unsafe { cur = pipeline_expr_int_val_at(arena, cur); }
    }
  }
  g_pipe_modlet_strpool_seq = g_pipe_modlet_strpool_seq + 1;
  seq = g_pipe_modlet_strpool_seq;
  fp = pipe_modlet_module_fp();
  unsafe {
    lab[0] = 76 as u8;
    lab[1] = 120 as u8;
    lab[2] = 109 as u8;
    lab[3] = 108 as u8;
    lab[4] = 115 as u8;
    lab[5] = 95 as u8;
  }
  i = 0;
  while (i < 8) {
    shift = (7 - i) * 4;
    nib = (seq >> shift) & 15;
    if (nib >= 10) {
      ch = (87 + nib) as u8;
    } else {
      ch = (48 + nib) as u8;
    }
    unsafe {
      lab[6 + i] = ch;
    }
    i = i + 1;
  }
  i = 0;
  while (i < 8) {
    shift = (7 - i) * 4;
    nib = ((fp >> shift) & 15) as i32;
    if (nib >= 10) {
      ch = (87 + nib) as u8;
    } else {
      ch = (48 + nib) as u8;
    }
    unsafe {
      lab[14 + i] = ch;
    }
    i = i + 1;
  }
  unsafe {
    unsafe { rc = pipeline_elf_ctx_add_label(elf_ctx, &lab[0], 22, pool_off); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { rc = pipeline_elf_ctx_add_sym(elf_ctx, &lab[0], 22, pool_off); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &lab[0], 22); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * TYPE_ARRAY flag in cell_size: bit 30 = 0x40000000 = 1073741824.
 * @return i32 — flag mask
 * PLATFORM: SHARED — modlet table encoding.
 */
function pipe_modlet_cell_array_bit(): i32 {
  return 1073741824;
}

/**
 * Non-empty ARRAY_LIT baked into .data flag: bit 29 = 0x20000000 = 536870912.
 * When set, hoist-target seed_nonzero must not store over the cell (may be
 * RO after final link on Mach-O __const). Library TUs never enter hoist.
 * @return i32 — flag mask
 * PLATFORM: SHARED — modlet table encoding · ELF .data + Mach-O __DATA,__const.
 */
function pipe_modlet_cell_data_bit(): i32 {
  return 536870912;
}

/**
 * Whether load must return address (array decay), not first qword.
 * @param csz i32 — stored cell_size word
 * @return i32 — 1 LEA-only; 0 load qword
 * PLATFORM: SHARED.
 */
function pipe_modlet_cell_is_array(csz: i32): i32 {
  if ((csz & 1073741824) != 0) {
    return 1;
  }
  // Legacy: arrays registered without the bit still used payload!=8.
  let p: i32 = csz & 536870911;
  if (p != 8 && p > 0) {
    return 1;
  }
  return 0;
}

/**
 * Whether the ARRAY_LIT payload was baked into .data at prepare time.
 * @param csz i32 — stored cell_size word
 * @return i32 — 1 .data-backed; 0 COMMON/BSS (needs hoist seed if non-empty)
 * PLATFORM: SHARED.
 */
function pipe_modlet_cell_is_data(csz: i32): i32 {
  if ((csz & 536870912) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Payload bytes for COMMON / .data emit (mask out array + data flags).
 * @param csz i32 — stored cell_size word
 * @return i32 — size >= 1 (default 8 if empty)
 * PLATFORM: SHARED.
 */
function pipe_modlet_cell_payload(csz: i32): i32 {
  let p: i32 = csz & 536870911;
  if (p <= 0) {
    return 8;
  }
  return p;
}

/**
 * Spell a same-module function's link name into dst.
 * Mach-O leading '_' on Darwin, bare ELF name on Linux. Completes the
 * spelling previously inlined in pipe_modlet_lea_fn_sym_to_rax so LEA
 * and .data absolute64 relocs share one authority.
 * @param elf_ctx *u8 - ElfCodegenCtx (reads macho_leading_underscore)
 * @param name *u8 - source-level function name
 * @param name_len i32 - 1..255
 * @param dst *u8 - caller buffer; capacity >= name_len+1 (typically 130)
 * @return i32 - spelled length; -1 bad args
 * PLATFORM: SHARED · MACOS Mach-O '_' · LINUX ELF bare name.
 */
function pipe_modlet_fn_sym_spell_into(
  elf_ctx: *u8, name: *u8, name_len: i32, dst: *u8
): i32 {
  let macho: i32 = 0;
  let k: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || dst == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  unsafe {
    unsafe { macho = pipeline_elf_ctx_macho_leading_underscore(elf_ctx); }
  }
  if (macho != 0) {
    unsafe {
      dst[0] = 95 as u8;
    }
    k = 0;
    while (k < name_len) {
      unsafe {
        dst[k + 1] = name[k];
      }
      k = k + 1;
    }
    return name_len + 1;
  }
  k = 0;
  while (k < name_len) {
    unsafe {
      dst[k] = name[k];
    }
    k = k + 1;
  }
  return name_len;
}

/**
 * FNV-1a 32-bit mix of one byte (unsigned 32-bit wrap).
 * Same basis/prime as asm_empty_text_stub_label (G.7: no second hash family).
 * @param h i64 — hash in 0..2^32-1
 * @param b i32 — byte 0..255
 * @return i64 — mixed hash in 0..2^32-1
 * PLATFORM: SHARED — COMMON label identity only.
 */
function pipe_modlet_fnv32_mix(h: i64, b: i32): i64 {
  let x: i64 = (h ^ (b as i64)) * 16777619;
  return x & 4294967295;
}

function pipe_modlet_get_n(): i32 {
  unsafe { return pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_n()); }
}

/**
 * LEA a same-module function's link symbol into rax/x0.
 * 9.4.2 single authority for the Cap-fn-ptr symbol spell (was inlined in
 * pipeline_asm_emit_as_elf_impl, the VAR fast face, and their twins):
 * source-level name; Mach-O leading '_' on Darwin, bare ELF symbol on
 * Linux. Callers must have confirmed the name resolves to a same-module
 * function (glue_module_func_index_by_name_c >= 0); this face re-checks
 * bounds only. Spelling is pipe_modlet_fn_sym_spell_into.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param name *u8 - source-level function name
 * @param name_len i32 - name length (1..255)
 * @param ta i32 - target arch (0=x86_64 1=arm64)
 * @return i32 - 0 ok; -1 bad args / encode fail
 * Exported for the first-wins fnptr_as thin (same spell, one authority).
 * PLATFORM: SHARED · MACOS Mach-O '_' · LINUX ELF bare name.
 */
#[no_mangle]
export function pipe_modlet_lea_fn_sym_to_rax(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  let sym: u8[130] = [];
  let len: i32 = 0;
  let rc: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255 || (ta != 0 && ta != 1)) {
    return 0 - 1;
  }
  len = pipe_modlet_fn_sym_spell_into(elf_ctx, name, name_len, &sym[0]);
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { rc = backend_enc_lea_sym_to_reg_arch(elf_ctx, 0, &sym[0], len, ta); }
  }
  return rc;
}

/**
 * LEA a non-local named binding's ADDRESS into rax/x0 (9.4.2).
 * Module-let COMMON cell first (pipeline_asm_modlet_lea_rax_arch — the
 * same home the generic VAR emit reads, array bit30 included), then the
 * same-module function link symbol. Returns -1 when the name is neither:
 * callers loud-fail (ADDR_OF keeps -99; lvalue keeps -1).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param m *u8 - Module* (fn lookup; null skips the fn branch)
 * @param name *u8 - source-level name
 * @param name_len i32 - name length (1..255)
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 not a modlet cell / not a same-module fn
 * Exported: the FROM_X seed rest lvalue fallback (Ubuntu hybrid) resolves
 * this WEAK mega face; the cold student uses the _cold static twin.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx: *u8, m: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  let idx: i32 = 0;
  let fi: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255 || (ta != 0 && ta != 1)) {
    return 0 - 1;
  }
  idx = pipeline_asm_modlet_find(name, name_len);
  if (idx >= 0) {
    return pipeline_asm_modlet_lea_rax_arch(elf_ctx, idx, ta);
  }
  if (m != (0 as *u8)) {
    unsafe {
      unsafe { fi = glue_module_func_index_by_name_c(m, name, name_len); }
    }
    if (fi >= 0) {
      return pipe_modlet_lea_fn_sym_to_rax(elf_ctx, name, name_len, ta);
    }
  }
  return 0 - 1;
}

/**
 * Fixed modlet table capacity (COMMON / .data cells per TU).
 * @return i32 — XLANG_ASM_MODLET_MAX; index range 0 .. max-1
 * PLATFORM: SHARED — single authority for offset bases and the prepare cap.
 * G.7: complete the existing table; do not add a second growable table.
 */
function pipe_modlet_max(): i32 {
  /* wave624: 512 — the mega TU itself has 331 registrable top-level lets;
   * the old 256 cap hit the loud-fail gate at monofile codegen START
   * (CG002 code_len=0, mega FORCE blocker head). 512 covers the mega with
   * headroom; buffer g_pipeline_asm_modlet grows 43012→86020 to match.
   * PLATFORM: SHARED — single authority (seed twin mirrors). */
  return 512;
}

/**
 * Fingerprint of every registered modlet name (order-sensitive).
 * Two TUs with different let sets get different COMMON prefixes.
 * @return i64 — FNV-1a 32-bit in 0..2^32-1
 * PLATFORM: SHARED — SHN_COMMON / Mach-O __common merge by symbol name.
 */
function pipe_modlet_module_fp(): i64 {
  let h: i64 = 2166136261;
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  while (i < n) {
    let nl: i32 = 0;
    unsafe { nl = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i)); }
    let base: i32 = pipe_modlet_off_name(i);
    h = pipe_modlet_fnv32_mix(h, nl & 255);
    let k: i32 = 0;
    while (k < nl) {
      let b: i32 = 0;
      unsafe {
        b = g_pipeline_asm_modlet[base + k] as i32;
      }
      h = pipe_modlet_fnv32_mix(h, b);
      k = k + 1;
    }
    h = pipe_modlet_fnv32_mix(h, 0);
    i = i + 1;
  }
  return h;
}

/**
 * Byte offset of cell_size[i] in the modlet table (COMMON payload size).
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout Stage 12.0.5. Base = init_imm_base + max*4.
 *
 * Encoding (Stage 12.0.5 / invoke_cc_list + library-TU .data):
 *   low 29 bits = payload bytes for SHN_COMMON or .data
 *   bit 29 (0x20000000) = non-empty ARRAY_LIT baked into ELF .data /
 *     Mach-O __DATA,__const (library TUs have no hoist-target seed)
 *   bit 30 (0x40000000) = TYPE_ARRAY address-decay (LEA-only load)
 * Scalar lit cells store plain 8 (no bit). Arrays store N|bit30 so u8[8]
 * (payload==8) does not collide with scalar load-qword (labi g_labi_icc_oopt_buf).
 * Product max payload 8 MiB << bit29; mask shrink 30→29 is safe.
 */
function pipe_modlet_off_cell_size(i: i32): i32 {
  return pipe_modlet_off_init_imm(0) + (pipe_modlet_max() * 4) + (i * 4);
}

/**
 * Byte offset of init_imm[i] in the modlet table.
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = label_base + max*24.
 */
function pipe_modlet_off_init_imm(i: i32): i32 {
  return pipe_modlet_off_label(0) + (pipe_modlet_max() * 24) + (i * 4);
}

/**
 * Byte offset of label[i][0] in the modlet table (24B slot).
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = label_len_base + max*4.
 */
function pipe_modlet_off_label(i: i32): i32 {
  return pipe_modlet_off_label_len(0) + (pipe_modlet_max() * 4) + (i * 24);
}

/**
 * Byte offset of label_len[i] in the modlet table.
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = name_base + max*128.
 */
function pipe_modlet_off_label_len(i: i32): i32 {
  return pipe_modlet_off_name(0) + (pipe_modlet_max() * 128) + (i * 4);
}

/**
 * Byte offset of n (registered cell count) in the modlet table.
 * @return i32 — always 0
 * PLATFORM: SHARED — LP64 table layout.
 */
function pipe_modlet_off_n(): i32 {
  return 0;
}

/**
 * Byte offset of name[i][0] in the modlet table (128B slot).
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = 4 + max*4.
 */
function pipe_modlet_off_name(i: i32): i32 {
  return 4 + (pipe_modlet_max() * 4) + (i * 128);
}

/**
 * Byte offset of name_len[i] in the modlet table.
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout.
 */
function pipe_modlet_off_name_len(i: i32): i32 {
  return 4 + (i * 4);
}

/**
 * wave338: True when a mutable scalar module-let init is prepare-COMMON-owned.
 * Completes the historic LIT/BOOL gate (ek 0/2) with:
 *   · EXPR_NEG-over-LIT (ek 22) — parser normal form for `let g: i32 = -1`
 *   · Null TYPE_PTR (tk 9): bare LIT 0 or AS(LIT 0) — `let p: *u8 = 0 as *u8`
 * Library TUs / Cap thins have no hoist-target main; without COMMON the
 * pure-asm backend constant-folds loads and drops stores (typeck_active /
 * emit_ctx_sret home_off=-1 class). Hoist skip MUST agree (9.6.0 dual-home).
 * @param arena *u8 — ASTArena
 * @param init_ref i32 — top-level let init expr
 * @param tk i32 — type kind ord (9 = TYPE_PTR)
 * @param is_const i32 — 1 = const let (prepare skips; hoist keeps)
 * @param out_imm *i32 — folded two's-complement init (0 for null ptr)
 * @return i32 — 1 register 8-byte COMMON; 0 keep other arms / hoist
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_scalar_init_common_imm(
  arena: *u8, init_ref: i32, tk: i32, is_const: i32, out_imm: *i32
): i32 {
  let ik: i32 = 0;
  let fold_buf: i32[1] = [];
  let op: i32 = 0;
  let oek: i32 = 0;
  let v: i32 = 0;
  if (is_const != 0 || arena == (0 as *u8) || init_ref <= 0 || out_imm == (0 as *i32)) {
    return 0;
  }
  fold_buf[0] = 0;
  unsafe {
    unsafe { ik = pipeline_expr_kind_ord_at(arena, init_ref); }
  }
  if (ik == 2) {
    unsafe {
      unsafe { v = pipeline_expr_int_val_at(arena, init_ref); }
    }
    unsafe {
      out_imm[0] = v;
    }
    return 1;
  }
  if (pipe_modlet_array_lit_elem_const_val(arena, init_ref, &fold_buf[0], (0 as *i32)) == 1) {
    unsafe {
      out_imm[0] = fold_buf[0];
    }
    return 1;
  }
  if (tk == 9) {
    if (ik == 0) {
      unsafe {
        unsafe { v = pipeline_expr_int_val_at(arena, init_ref); }
      }
      if (v == 0) {
        unsafe {
          out_imm[0] = 0;
        }
        return 1;
      }
    } else {
      if (ik == 54) {
        unsafe {
          unsafe { op = pipeline_expr_as_operand_ref_at(arena, init_ref); }
        }
        if (op > 0) {
          unsafe {
            unsafe { oek = pipeline_expr_kind_ord_at(arena, op); }
          }
          if (oek == 0) {
            unsafe {
              unsafe { v = pipeline_expr_int_val_at(arena, op); }
            }
            if (v == 0) {
              unsafe {
                out_imm[0] = 0;
              }
              return 1;
            }
          }
        }
      }
    }
  }
  return 0;
}

/**
 * True when a scalar module-let init is a compile-time address that
 * prepare can bake as an 8-byte .data cell + absolute64 reloc.
 *
 * Completes 9.4.2 ARRAY_LIT table bake for the scalar leftover:
 *   `let p: *i32 = &g` (ADDR_OF 51 over a pass-1 modlet cell or fn)
 *   `let h: *u8 = inc` (VAR 3 naming a same-module fn)
 *   TYPE_FN init `inc as ...` (AS 54 over a fn)
 *
 * Pass-1 cells (independently knowable at hoist time, before the
 * modlet table exists): mutable scalar LIT/BOOL (init 0/2,
 * is_const==0) and TYPE_ARRAY + ARRAY_LIT (tk 10, ik 46).
 *
 * Rejects VAR copies of another pointer/fn-ptr let (`let g = f`) so
 * those keep historic hoist. Rejects ADDR_OF of const scalars
 * (prepare does not give them a cell).
 *
 * Hoist skip and prepare register MUST agree (9.6.0 dual-home class).
 * @param arena *u8 - ASTArena
 * @param m *u8 - Module* (fn lookup + top-level let scan; null → 0)
 * @param init_ref i32 - scalar let init expr
 * @return i32 - 1 bake-able address init; 0 keep hoist
 * PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA unsigned64.
 */
function pipe_modlet_scalar_init_is_ptr_addr(
  arena: *u8, m: *u8, init_ref: i32
): i32 {
  let ek: i32 = 0;
  let is_addr_of: i32 = 0;
  let nref: i32 = 0;
  let vlen: i32 = 0;
  let name: u8[256] = [];
  let fi: i32 = 0;
  let nlets: i32 = 0;
  let tl: i32 = 0;
  let nlen: i32 = 0;
  let k: i32 = 0;
  let b: i32 = 0;
  let same: i32 = 0;
  let t_init: i32 = 0;
  let t_ik: i32 = 0;
  let t_tr: i32 = 0;
  let t_tk: i32 = 0;
  let t_const: i32 = 0;
  let nexprs: i32 = 0;
  if (arena == (0 as *u8) || m == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, init_ref); }
  }
  if (ek == 54) {
    unsafe {
      unsafe { nref = pipeline_expr_as_operand_ref_at(arena, init_ref); }
    }
  } else {
    if (ek == 51) {
      is_addr_of = 1;
      unsafe {
        unsafe { nref = pipeline_expr_unary_operand_ref_at(arena, init_ref); }
      }
    } else {
      if (ek != 3) {
        return 0;
      }
      nref = init_ref;
    }
  }
  if (nref <= 0) {
    return 0;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, nref); }
  }
  if (ek != 3) {
    return 0;
  }
  unsafe {
    unsafe { vlen = pipeline_expr_var_name_len(arena, nref); }
  }
  if (vlen <= 0 || vlen > 255) {
    return 0;
  }
  unsafe {
    unsafe { pipeline_expr_var_name_into(arena, nref, &name[0]); }
    unsafe { fi = glue_module_func_index_by_name_c(m, &name[0], vlen); }
  }
  if (fi >= 0) {
    return 1;
  }
  if (is_addr_of == 0) {
    return 0;
  }
  // ADDR_OF of a pass-1 modlet cell. Walk the module lets (not the
  // live table) so hoist — which runs before prepare — agrees.
  unsafe { nlets = pipe_mod_get_num_top_level_lets(m); }
  unsafe { nexprs = pipe_load_i32_le(arena, pipe_arena_off_num_exprs()); }
  tl = 0;
  while (tl < nlets) {
    unsafe {
      unsafe { nlen = pipeline_module_top_level_let_name_len(m, tl); }
    }
    if (nlen == vlen) {
      same = 1;
      k = 0;
      while (k < nlen) {
        unsafe {
          unsafe { b = pipeline_module_top_level_let_name_byte_at(m, tl, k); }
        }
        if (b != (name[k] as i32)) {
          same = 0;
          break;
        }
        k = k + 1;
      }
      if (same != 0) {
        unsafe {
          unsafe { t_const = pipeline_module_top_level_let_is_const(m, tl); }
          unsafe { t_init = pipeline_module_top_level_let_init_ref(m, tl); }
          unsafe { t_tr = pipeline_module_top_level_let_type_ref(m, tl); }
        }
        t_ik = 0;
        t_tk = 0;
        if (t_init > 0 && t_init <= nexprs) {
          unsafe {
            unsafe { t_ik = pipeline_expr_kind_ord_at(arena, t_init); }
          }
        }
        if (t_tr > 0) {
          unsafe {
            unsafe { t_tk = pipeline_type_kind_ord_at(arena, t_tr); }
          }
        }
        if (t_const == 0 && (t_ik == 0 || t_ik == 2)) {
          return 1;
        }
        if (t_tk == 10 && t_ik == 46) {
          return 1;
        }
        return 0;
      }
    }
    tl = tl + 1;
  }
  return 0;
}

/**
 * Store ARRAY_LIT LIT elems into COMMON already LEA'd in rbx.
 * One nested ARRAY_LIT level is enough for `[K][N]T` rows; deeper
 * nest is a later leaf. Empty lit is a no-op (BSS zero).
 * 9.4.2: ptr/fn-typed tables with address elems (bare fn / `fn as *u8` /
 * `&global`) store the link-time address via
 * pipe_modlet_seed_ptr_addr_elem_to_rbx — `m` feeds the fn lookup.
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param init_ref i32 - ARRAY_LIT expr
 * @param elem_ty i32 - dest elem type_ref (scalar or TYPE_ARRAY row)
 * @param ta i32 - 0=x86_64 1=arm64
 * @param base_off i32 - byte offset in the COMMON cell
 * @param m *u8 - Module* (address-elem fn lookup; may be null)
 * @return i32 - 0 ok; -1 store fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_seed_array_lit_elems_to_rbx(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32, ta: i32, base_off: i32, m: *u8
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let ev: i32 = 0;
  let esz: i32 = 4;
  let etk: i32 = 0;
  let inner_et: i32 = 0;
  let row_sz: i32 = 0;
  let rc: i32 = 0;
  let hi: i32 = 0;
  let sa: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  if (elem_ty > 0) {
    unsafe {
      unsafe { etk = pipeline_type_kind_ord_at(arena, elem_ty); }
    }
  }
  if (etk == 10) {
    unsafe {
      unsafe { inner_et = pipeline_type_elem_ref_at(arena, elem_ty); }
      unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
    }
    unsafe { row_sz = glue_fixed_array_total_bytes_c(arena, elem_ty, 0); }
    if (row_sz <= 0) {
      unsafe { row_sz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty); }
    }
    // ne<=0: empty row lit is a no-op (BSS zero). ne>1024: entry-seed code
    // bound — loud-fail instead of the historic silent zero fill.
    if (ne <= 0) {
      return 0;
    }
    if (ne > 1024) {
      return 0 - 1;
    }
    ei = 0;
    while (ei < ne) {
      unsafe {
        unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
      }
      if (eref > 0) {
        unsafe {
          unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
        }
        if (ek == 46) {
          rc = pipe_modlet_seed_array_lit_elems_to_rbx(
            arena, elf_ctx, eref, inner_et, ta, base_off + ei * row_sz, m);
          if (rc != 0) {
            return rc;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
  unsafe { esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty); }
  // TYPE_NAMED keeps the struct stride. See the bake twin.
  if (etk != 8) {
    if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
      esz = 4;
    }
  }
  if (etk == 8 && esz <= 0) {
    return 0 - 1;
  }
  unsafe {
    unsafe { ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
  }
  // ne<=0: empty lit is a no-op (BSS zero). ne>1024: entry-seed code-size
  // bound (~16B emitted per elem) — loud-fail instead of silent zero fill.
  if (ne <= 0) {
    return 0;
  }
  if (ne > 1024) {
    return 0 - 1;
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      unsafe { eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei); }
    }
    if (eref > 0) {
      unsafe {
        unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
      }
      // STRING_LIT elem: emit the string bytes inline in .text and LEA
      // their address (rax/x0), then store esz bytes at rbx+off. Cells
      // reach here when the .data bake+pool does not fit (budget or
      // 9.4.2 ADDR_OF neighbor); loud-fails on len > 126 (jmp-skip cap).
      if (ek == 59) {
        unsafe {
          unsafe { rc = glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, eref, ta); }
        }
        if (rc != 0) {
          return rc;
        }
        unsafe {
          unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + ei * esz, esz, ta); }
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        if ((etk == 9 || etk == 18) && m != (0 as *u8)) {
          // 9.4.2 address-valued elem (bare fn / `fn as *u8` / `&global`):
          // resolve the link-time address at hoist-target entry and store
          // 8B into COMMON. sa==1 → not an address literal, fall through
          // to the const fold (which loud-fails, keeping old behavior).
          sa = pipe_modlet_seed_ptr_addr_elem_to_rbx(
            arena, elf_ctx, m, eref, esz, base_off + ei * esz, ta);
          if (sa < 0) {
            return 0 - 1;
          }
          if (sa == 0) {
            ei = ei + 1;
            continue;
          }
        }
        // STRUCT_LIT: store integer, string, pointer, and array fields. PLATFORM: SHARED.
        if (ek == 45) {
          rc = pipe_modlet_seed_struct_lit_to_rbx(
            arena, elf_ctx, eref, ta, base_off + ei * esz, m);
          if (rc != 0) {
            return rc;
          }
          ei = ei + 1;
          continue;
        }
        // Float constant: esz 4 stores the f32 pack; esz 8 stores both
        // f64 halves. A negative f32 pattern sign-extends only the unused
        // high half of the imm64 so the 4-byte store keeps the IEEE bits.
        // Integer elems return 0 and fall through. PLATFORM: SHARED.
        let flo: i32 = 0;
        let fhi: i32 = 0;
        let fb: i32 = 0;
        if (pipe_modlet_fold_f64_elem_bits(arena, eref, &flo, &fhi) == 1) {
          if (esz == 4) {
            unsafe {
              unsafe { fb = glue_ieee_f64_bits_to_f32_bits(flo, fhi); }
            }
            hi = 0;
            if (fb < 0) {
              hi = 0 - 1;
            }
            unsafe {
              unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, fb, hi, ta); }
            }
          } else {
            if (esz == 8) {
              unsafe {
                unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, flo, fhi, ta); }
              }
            } else {
              return 0 - 1;
            }
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + ei * esz, esz, ta); }
          }
          if (rc != 0) {
            return 0 - 1;
          }
          ei = ei + 1;
          continue;
        }
        // LIT / NEG / integer binop / float-to-integer AS: fold to the
        // constant. out_hi is the sign fill of an i32, or the real high
        // half of an i64 trunc. The (hi:lo) imm64 is stored at esz.
        // Any other elem kind loud-fails (was: silently left zero).
        if (pipe_modlet_array_lit_elem_const_val(arena, eref, &ev, &hi) == 0) {
          return 0 - 1;
        }
        unsafe {
          unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, ev, hi, ta); }
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + ei * esz, esz, ta); }
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Seed one address-valued ARRAY_LIT elem (9.4.2) at rbx+off.
 * Accepts bare same-module fn (VAR 3), `fn as *u8` (AS 54), and ADDR_OF
 * (51) over a global let or fn. The address is resolved at hoist-target
 * entry: bare/AS fn name → link symbol (pipe_modlet_lea_fn_sym_to_rax),
 * ADDR_OF → modlet COMMON cell address first, then fn symbol (shared
 * resolver). A VAR naming a module let is a VALUE copy, not an address
 * literal: return 1 so the caller's const fold loud-fails (historic
 * behavior, never a silent zero).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param m *u8 - Module*
 * @param eref i32 - element expr ref
 * @param esz i32 - dest elem byte size (must be 8: pointers/fn addrs)
 * @param off i32 - byte offset of the elem inside the COMMON cell
 * @param ta i32 - target arch
 * @return i32 - 0 = stored; 1 = not an address elem (caller falls back
 *         to the const fold); -1 = loud fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_seed_ptr_addr_elem_to_rbx(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, off: i32, ta: i32
): i32 {
  let ek: i32 = 0;
  let is_addr_of: i32 = 0;
  let nref: i32 = 0;
  let vlen: i32 = 0;
  let name: u8[256] = [];
  let fi: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0) {
    return 1;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, eref); }
  }
  if (ek == 54) {
    unsafe {
      unsafe { nref = pipeline_expr_as_operand_ref_at(arena, eref); }
    }
  } else {
    if (ek == 51) {
      is_addr_of = 1;
      unsafe {
        unsafe { nref = pipeline_expr_unary_operand_ref_at(arena, eref); }
      }
    } else {
      if (ek != 3) {
        return 1;
      }
      nref = eref;
    }
  }
  if (nref <= 0) {
    return 1;
  }
  unsafe {
    unsafe { ek = pipeline_expr_kind_ord_at(arena, nref); }
  }
  if (ek != 3) {
    return 1;
  }
  unsafe {
    unsafe { vlen = pipeline_expr_var_name_len(arena, nref); }
  }
  if (vlen <= 0 || vlen > 255) {
    return 0 - 1;
  }
  unsafe {
    unsafe { pipeline_expr_var_name_into(arena, nref, &name[0]); }
  }
  if (is_addr_of != 0) {
    // &global → COMMON cell address (modlet-first); &fn → link symbol.
    rc = pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx, m, &name[0], vlen, ta);
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    if (m == (0 as *u8)) {
      return 1;
    }
    unsafe {
      unsafe { fi = glue_module_func_index_by_name_c(m, &name[0], vlen); }
    }
    if (fi < 0) {
      // Bare name that is not a same-module fn (module-let value copy):
      // not an address literal — the const fold loud-fails downstream.
      return 1;
    }
    rc = pipe_modlet_lea_fn_sym_to_rax(elf_ctx, &name[0], vlen, ta);
    if (rc != 0) {
      return 0 - 1;
    }
  }
  if (esz != 8) {
    // Pointer/fn addresses are 8B; narrower elem types never reach here.
    return 0 - 1;
  }
  unsafe {
    unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, off, esz, ta); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

function pipe_modlet_set_n(n: i32): void {
  unsafe { pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_n(), n); }
}

/**
 * Write 8 lowercase hex digits of a 32-bit value into the modlet label slot.
 * @param lbase i32 — byte offset of label[idx] in g_pipeline_asm_modlet
 * @param off i32 — write offset 0..15 within that 24-byte label
 * @param v i64 — value; only low 32 bits are written
 * @return void
 * PLATFORM: SHARED — label field is 24 bytes (Stage 12.0.5 layout).
 */
function pipe_modlet_write_hex8(lbase: i32, off: i32, v: i64): void {
  let i: i32 = 0;
  while (i < 8) {
    let shift: i32 = (7 - i) * 4;
    let nib: i32 = ((v >> shift) & 15) as i32;
    let ch: u8 = 48 as u8;
    if (nib >= 10) {
      ch = (87 + nib) as u8;
    } else {
      ch = (48 + nib) as u8;
    }
    unsafe {
      g_pipeline_asm_modlet[lbase + off + i] = ch;
    }
    i = i + 1;
  }
}

/**
 * Find the modlet table index for a given name.
 * @param name *u8 - name bytes; null -> -1
 * @param name_len i32 - length; <=0 -> -1
 * @return i32 - >=0 index on match; -1 on miss
 * wave139 pure: was static pipeline_asm_modlet_find.
 * The pabi copy is a weak global that reads that object's local table.
 * Callers outside the family (durable array address) must hit this
 * definition so they see the same table prepare filled.
 * PLATFORM: SHARED - linear scan; cold asm emit path.
 */
#[no_mangle]
export function pipeline_asm_modlet_find(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0 - 1;
  }
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  while (i < n) {
    let nl: i32 = 0;
    unsafe { nl = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i)); }
    if (nl == name_len) {
      let k: i32 = 0;
      let base: i32 = pipe_modlet_off_name(i);
      while (k < name_len) {
        let b: i32 = 0;
        unsafe {
          b = g_pipeline_asm_modlet[base + k] as i32;
          if (b != (name[k] as i32)) {
            break;
          }
        }
        k = k + 1;
      }
      if (k == name_len) {
        return i;
      }
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Emit adrp x0 + add x0,pageoff for a modlet COMMON cell (arm64).
 * Used by load_to_rax so value loads do not clobber cmp's parked left in x1.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * PLATFORM: MACOS|ARM64 — ARM64_RELOC_PAGE21 + PAGEOFF12.
 */
function pipeline_asm_modlet_lea_rax_adrp_arm64(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = 0;
  unsafe { llen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx)); }
  let lbase: i32 = pipe_modlet_off_label(idx);
  // adrp x0, #0 → 0x90000000
  let adrp4: u8[4] = [];
  adrp4[0] = 0x00 as u8;
  adrp4[1] = 0x00 as u8;
  adrp4[2] = 0x00 as u8;
  adrp4[3] = 0x90 as u8;
  let rc: i32 = 0;
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &adrp4[0], 4); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let adrp_at: i32 = 0;
  unsafe {
    unsafe { adrp_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4; }
    unsafe { rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, adrp_at, &g_pipeline_asm_modlet[lbase], llen, 3, 1); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // add x0, x0, #0 → 0x91000000
  let add4: u8[4] = [];
  add4[0] = 0x00 as u8;
  add4[1] = 0x00 as u8;
  add4[2] = 0x00 as u8;
  add4[3] = 0x91 as u8;
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &add4[0], 4); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let add_at: i32 = 0;
  unsafe {
    unsafe { add_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4; }
    unsafe { rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, add_at, &g_pipeline_asm_modlet[lbase], llen, 4, 0); }
  }
  return rc;
}

/**
 * Dispatch lea rax/x0 to modlet COMMON cell by target arch.
 * Value-load path only — must not touch rbx/x1 (cmp parks left there).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @param ta i32 - 0 x86_64, 1 arm64
 * @return i32 - 0 ok; -1 unsupported or encoder fail
 * PLATFORM: SHARED.
 */
function pipeline_asm_modlet_lea_rax_arch(elf_ctx: *u8, idx: i32, ta: i32): i32 {
  if (ta == 1) {
    return pipeline_asm_modlet_lea_rax_adrp_arm64(elf_ctx, idx);
  }
  if (ta == 0) {
    return pipeline_asm_modlet_lea_rax_rip_x86(elf_ctx, idx);
  }
  return 0 - 1;
}

/**
 * Emit lea rax, [rip+disp32] for a modlet COMMON cell (x86_64).
 * Used by load_to_rax so value loads do not clobber cmp's parked left in rbx.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * PLATFORM: LINUX|UBUNTU x86_64 — R_X86_64_PC32 to SHN_COMMON BSS.
 */
function pipeline_asm_modlet_lea_rax_rip_x86(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = 0;
  unsafe { llen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx)); }
  let lbase: i32 = pipe_modlet_off_label(idx);
  // REX.W LEA rax, [rip+disp32] = 48 8d 05 disp32
  let lea7: u8[7] = [];
  lea7[0] = 0x48 as u8;
  lea7[1] = 0x8d as u8;
  lea7[2] = 0x05 as u8;
  lea7[3] = 0 as u8;
  lea7[4] = 0 as u8;
  lea7[5] = 0 as u8;
  lea7[6] = 0 as u8;
  let rc: i32 = 0;
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &lea7[0], 7); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let rel32_at: i32 = 0;
  unsafe {
    unsafe { rel32_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4; }
    unsafe { rc = pipeline_elf_ctx_append_reloc(elf_ctx, rel32_at, &g_pipeline_asm_modlet[lbase], llen); }
  }
  return rc;
}

/**
 * Emit adrp x1 + add x1,pageoff for a modlet COMMON cell (arm64).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * wave139 pure: was static lea_rbx_adrp_arm64.
 * PLATFORM: MACOS|ARM64 — ARM64_RELOC_PAGE21 + PAGEOFF12.
 */
function pipeline_asm_modlet_lea_rbx_adrp_arm64(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = 0;
  unsafe { llen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx)); }
  let lbase: i32 = pipe_modlet_off_label(idx);
  let adrp4: u8[4] = [];
  adrp4[0] = 0x01 as u8;
  adrp4[1] = 0x00 as u8;
  adrp4[2] = 0x00 as u8;
  adrp4[3] = 0x90 as u8;
  let rc: i32 = 0;
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &adrp4[0], 4); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let adrp_at: i32 = 0;
  unsafe {
    unsafe { adrp_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4; }
    unsafe { rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, adrp_at, &g_pipeline_asm_modlet[lbase], llen, 3, 1); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let add4: u8[4] = [];
  add4[0] = 0x21 as u8;
  add4[1] = 0x00 as u8;
  add4[2] = 0x00 as u8;
  add4[3] = 0x91 as u8;
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &add4[0], 4); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let add_at: i32 = 0;
  unsafe {
    unsafe { add_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4; }
    unsafe { rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, add_at, &g_pipeline_asm_modlet[lbase], llen, 4, 0); }
  }
  return rc;
}

/**
 * Dispatch lea rbx/x1 to modlet COMMON cell by target arch.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @param ta i32 - 0 x86_64, 1 arm64
 * @return i32 - 0 ok; -1 unsupported or encoder fail
 * wave139 pure: was static lea_rbx_arch.
 * PLATFORM: SHARED.
 */
function pipeline_asm_modlet_lea_rbx_arch(elf_ctx: *u8, idx: i32, ta: i32): i32 {
  if (ta == 1) {
    return pipeline_asm_modlet_lea_rbx_adrp_arm64(elf_ctx, idx);
  }
  if (ta == 0) {
    return pipeline_asm_modlet_lea_rbx_rip_x86(elf_ctx, idx);
  }
  return 0 - 1;
}

/**
 * Emit lea rbx, [rip+disp32] for a modlet COMMON cell (x86_64).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * wave139 pure: was static lea_rbx_rip_x86.
 * PLATFORM: LINUX|UBUNTU x86_64 — R_X86_64_PC32 to SHN_COMMON BSS.
 */
function pipeline_asm_modlet_lea_rbx_rip_x86(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = 0;
  unsafe { llen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx)); }
  let lbase: i32 = pipe_modlet_off_label(idx);
  let lea7: u8[7] = [];
  lea7[0] = 0x48 as u8;
  lea7[1] = 0x8d as u8;
  lea7[2] = 0x1d as u8;
  lea7[3] = 0 as u8;
  lea7[4] = 0 as u8;
  lea7[5] = 0 as u8;
  lea7[6] = 0 as u8;
  let rc: i32 = 0;
  unsafe {
    unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &lea7[0], 7); }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let rel32_at: i32 = 0;
  unsafe {
    unsafe { rel32_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4; }
    unsafe { rc = pipeline_elf_ctx_append_reloc(elf_ctx, rel32_at, &g_pipeline_asm_modlet[lbase], llen); }
  }
  return rc;
}

/**
 * Load a shared modlet cell into rax/x0.
 * Scalar cells (cell_size==8, no array bit): LEA base into rax then load qword.
 * Array/blob cells (array bit or legacy payload!=8): LEA base into rax only
 *   (C array decay). Fixed TYPE_ARRAY module lets need the address for
 *   INDEX / `&arr[0]` / call args; loading the first qword is wrong.
 *
 * G.7 root fix (fmt pure-asm format residual): LEA must target rax/x0, NOT
 * rbx/x1. cmp parks the left operand in rbx/x1; the old lea_rbx + ldr
 * clobbered it so `i >= g_modlet_n[0]` compared (&n) >= n (always true) and
 * fmt_file_list_at always returned null → driver_fmt_one_file never ran.
 * store_from_rax still uses lea_rbx (address in rbx, value in rax).
 *
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param name *u8 - modlet name
 * @param name_len i32 - length
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 miss/null/bad arch
 * wave139 pure: G.7 authority (was static load_to_rax_elf_c).
 * Stage 12.0.5: array bit30 on cell_size so u8[8] (e.g. g_labi_icc_oopt_buf)
 *   is LEA-only; prior payload!=8 heuristic collided with scalar 8-byte cells
 *   → pure-asm hybrid SEGV on invoke_cc_list head_flags strb [null].
 * Cap residual: append_bytes for arm64 ldr x0,[x0] / x86 movq (%rax),%rax.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if ((ta != 0 && ta != 1) || elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let idx: i32 = pipeline_asm_modlet_find(name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (pipeline_asm_modlet_lea_rax_arch(elf_ctx, idx, ta) != 0) {
    return 0 - 1;
  }
  // Array/blob COMMON: address already in rax (C array decay), do not load payload.
  // G.7: bit30 marks TYPE_ARRAY (incl. payload==8); legacy unflagged N!=8 still LEA.
  let csz: i32 = 0;
  unsafe { csz = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(idx)); }
  if (pipe_modlet_cell_is_array(csz) != 0) {
    return 0;
  }
  if (ta == 1) {
    // ldr x0, [x0] = 0xf9400000
    let ldr4: u8[4] = [];
    ldr4[0] = 0x00 as u8;
    ldr4[1] = 0x00 as u8;
    ldr4[2] = 0x40 as u8;
    ldr4[3] = 0xf9 as u8;
    let rc: i32 = 0;
    unsafe {
      unsafe { rc = pipeline_elf_ctx_append_bytes(elf_ctx, &ldr4[0], 4); }
    }
    return rc;
  }
  // movq (%rax), %rax = 48 8b 00
  let mov3: u8[3] = [];
  mov3[0] = 0x48 as u8;
  mov3[1] = 0x8b as u8;
  mov3[2] = 0x00 as u8;
  let rc2: i32 = 0;
  unsafe {
    unsafe { rc2 = pipeline_elf_ctx_append_bytes(elf_ctx, &mov3[0], 3); }
  }
  return rc2;
}

/**
 * Check whether a name is a text-embedded module shared mutable let for this mega emit.
 * @param name *u8 - candidate name; null -> 0
 * @param name_len i32 - length
 * @return i32 - 1 if registered modlet; 0 otherwise
 * wave139 pure: G.7 authority (was pipeline_asm_emit_modlet.c).
 * PLATFORM: SHARED - sole provider after leave; assign + top_level + register faces.
 */
#[no_mangle]
export function pipeline_asm_modlet_name_is_shared(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0 || pipe_modlet_get_n() <= 0) {
    return 0;
  }
  if (pipeline_asm_modlet_find(name, name_len) >= 0) {
    return 1;
  }
  return 0;
}

/**
 * Build the modlet table and emit homes for module lets.
 * Accepts:
 *   (1) mutable scalar COMMON init → 8-byte COMMON (historic wave139 LIT/BOOL;
 *       wave338 adds EXPR_NEG-over-LIT + null TYPE_PTR AS/LIT 0)
 *   (2) fixed TYPE_ARRAY (kind 10) with ARRAY_LIT init (kind 46), e.g. `u8[N]=[]`
 *       and `const A:[2]i32=[10,32]`:
 *       · empty lit `[]` → SHN_COMMON / Mach-O __common (BSS zero; correct)
 *       · non-empty lit that fits in the F7 .data buf (64 KiB, including
 *         interned STRING_LIT pool + absolute64 RELA on pointer slots,
 *         including 9.4.2 named-symbol ADDR_OF / fn-ptr elems) →
 *         ELF .data / Mach-O __DATA baked at prepare time
 *         (library TUs have no hoist-target entry; COMMON+seed stays zero)
 *       · non-empty lit that does not fit → COMMON + hoist seed_nonzero (historic)
 *   (3) scalar ADDR_OF / fn-ptr (tk 9/18, pipe_modlet_scalar_init_is_ptr_addr):
 *       `let p: *i32 = &g` / `let h: *u8 = inc` / `inc as *u8` → 8-byte
 *       .data + absolute64 RELA (same reloc authority as (2) elems).
 *       Hoist skip uses the same predicate (9.6.0 dual-home class).
 * Without (2), pure-asm stacked every module array into each function frame
 * (~sum of all g_labi_* buffers per call) → stack overflow / dangling path
 * returns (labi_path_pure hybrid SEGV on opt/si/hello).
 * Const TYPE_ARRAY used to skip here (is_const) and hoist into main only —
 * non-main INDEX then had no home (CG002). Same home path as mutable
 * when the elem is not TYPE_SLICE; seed_nonzero writes ARRAY_LIT elems
 * only for COMMON-backed cells (skips .data-backed — may be RO after link).
 * Const `[N][]T` (elem SLICE) still skips — fat rows hoist + durable.
 * Other const (scalars, dest-SLICE) still skip — those hoist / use text cells.
 * COMMON / .data names are Lxml_<name-hash><module-fp> (not Lxlang_ml_<idx>):
 * SHN_COMMON / Mach-O __common merge by name, so per-index labels aliased
 * every TU's N-th module let (check_only 512B leftover).
 * @param m *u8 - Module*
 * @param a *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok (incl no-op); -1 COMMON / .data emit fail
 * wave139 pure: G.7 authority (was static prepare_and_emit_elf_c).
 * Cap residual: top_level readers + expr_kind/int_val + type_kind/array size +
 *   common_sym + F7 .data bake + fixed_array_total_bytes + pipe nlets/nexprs.
 * PLATFORM: SHARED — ELF .data + Mach-O __DATA,__const for non-empty ARRAY_LIT.
 */
#[no_mangle]
export function pipeline_asm_modlet_prepare_and_emit_elf_c(m: *u8, a: *u8, elf_ctx: *u8, ta: i32): i32 {
  pipeline_asm_modlet_reset();
  if (m == 0 as *u8 || a == 0 as *u8 || elf_ctx == 0 as *u8 || (ta != 0 && ta != 1)) {
    return 0;
  }
  let nlets: i32 = 0;
  unsafe { nlets = pipe_mod_get_num_top_level_lets(m); }
  if (nlets <= 0) {
    return 0;
  }
  let nexprs: i32 = 0;
  unsafe { nexprs = pipe_load_i32_le(a, pipe_arena_off_num_exprs()); }
  let tl: i32 = 0;
  while (tl < nlets) {
    let is_const: i32 = 0;
    unsafe {
      unsafe { is_const = pipeline_module_top_level_let_is_const(m, tl); }
    }
    // Do not skip all const here: const TYPE_ARRAY + ARRAY_LIT needs COMMON
    // so non-main INDEX can LEA. Gate is after tk / init_kind below.
    let name_len: i32 = 0;
    unsafe {
      unsafe { name_len = pipeline_module_top_level_let_name_len(m, tl); }
    }
    if (name_len <= 0 || name_len > 255) {
      tl = tl + 1;
      continue;
    }
    let init_ref: i32 = 0;
    unsafe {
      unsafe { init_ref = pipeline_module_top_level_let_init_ref(m, tl); }
    }
    if (init_ref <= 0 || init_ref > nexprs) {
      tl = tl + 1;
      continue;
    }
    let init_kind: i32 = 0;
    unsafe {
      unsafe { init_kind = pipeline_expr_kind_ord_at(a, init_ref); }
    }
    // Classify: scalar COMMON (LIT/BOOL/NEG-over-LIT/null-ptr) vs fixed
    // array ARRAY_LIT (46) vs scalar ADDR_OF / fn-ptr bake.
    // wave338: NEG-over-LIT + null TYPE_PTR join the COMMON arm (was
    // only ek 0/2) so Cap library TUs get durable homes. PLATFORM: SHARED.
    let cell_sz: i32 = 8;
    let imm: i32 = 0;
    let type_ref: i32 = 0;
    unsafe {
      unsafe { type_ref = pipeline_module_top_level_let_type_ref(m, tl); }
    }
    let tk: i32 = 0;
    if (type_ref > 0) {
      unsafe {
        unsafe { tk = pipeline_type_kind_ord_at(a, type_ref); }
      }
    }
    let imm_buf: i32[1] = [];
    imm_buf[0] = 0;
    if (pipe_modlet_scalar_init_common_imm(a, init_ref, tk, is_const, &imm_buf[0]) == 1) {
      imm = imm_buf[0];
      cell_sz = 8;
    } else {
      // TYPE_ARRAY (10) + ARRAY_LIT (46): durable BSS for mutable *and*
      // const scalar / nested `[K][N]T` arrays. Const `[N][]T` (elem
      // TYPE_SLICE) stays skipped — payload is fat rows, seed writes LIT
      // only; hoist + durable dest_elem_ty is that home (cmns na).
      // Scalar ADDR_OF / fn-ptr (tk 9/18): 8-byte .data cell, baked
      // below via pipe_modlet_bake_ptr_addr_elem_to_data. Predicate
      // matches hoist skip (9.6.0 dual-home). PLATFORM: SHARED.
      if (tk == 9 || tk == 18) {
        let is_pa: i32 = 0;
        is_pa = pipe_modlet_scalar_init_is_ptr_addr(a, m, init_ref);
        if (is_pa == 0) {
          tl = tl + 1;
          continue;
        }
        cell_sz = 8;
        imm = 0;
      } else {
      if (tk != 10 || init_kind != 46) {
        tl = tl + 1;
        continue;
      }
      if (is_const != 0) {
        let et_p: i32 = 0;
        let etk_p: i32 = 0;
        unsafe {
          unsafe { et_p = pipeline_type_elem_ref_at(a, type_ref); }
        }
        if (et_p > 0) {
          unsafe {
            unsafe { etk_p = pipeline_type_kind_ord_at(a, et_p); }
          }
        }
        if (etk_p == 11) {
          tl = tl + 1;
          continue;
        }
      }
      unsafe {
        unsafe { cell_sz = glue_fixed_array_total_bytes_c(a, type_ref, 0); }
      }
      if (cell_sz <= 0) {
        tl = tl + 1;
        continue;
      }
      // Cap residual guard: reject absurd COMMON sizes (not product BSS).
      // PLATFORM: SHARED — low 30 bits hold payload; bit30 = array decay.
      // Product: fmt_check_cmd_thin g_fmt_file_list_paths = DRIVER_FMT_MAX_FILES(8192)×512
      // = 4194304 (4 MiB). Historical 1 MiB cap skipped that cell → pure-asm
      // &g_fmt_file_list_paths[0] UNHANDLED → CG002 in fmt_file_list_at (Stage12.0.5).
      // Cap 8 MiB: covers 4 MiB product + headroom; still << 0x3FFFFFFF encoding max.
      if (cell_sz > 8388608) {
        tl = tl + 1;
        continue;
      }
      // Mark array decay so payload==8 (u8[8]) is not treated as scalar load.
      cell_sz = cell_sz | pipe_modlet_cell_array_bit();
      imm = 0;
      }
    }
    // PLATFORM: SHARED — table is a fixed BSS (pipe_modlet_max).
    // Silent `break` at 64 used to drop extras: load/store then missed the
    // cell and fell through to a stack slot (9.6.0 dual-home class).
    // G.7: complete this existing table — loud-fail (return -1 → CG002)
    // when a registrable cell would exceed the cap. Skip-only leftover
    // lets (const scalars, nameless, non-ARRAY) must not trip the cap.
    if (pipe_modlet_get_n() >= pipe_modlet_max()) {
      return 0 - 1;
    }
    let idx: i32 = pipe_modlet_get_n();
    unsafe { pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(idx), name_len); }
    let k: i32 = 0;
    let nbase: i32 = pipe_modlet_off_name(idx);
    while (k < name_len) {
      let b: i32 = 0;
      unsafe {
        unsafe { b = pipeline_module_top_level_let_name_byte_at(m, tl, k); }
        g_pipeline_asm_modlet[nbase + k] = b as u8;
      }
      k = k + 1;
    }
    unsafe { pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(idx), imm); }
    unsafe { pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(idx), cell_sz); }
    pipe_modlet_set_n(idx + 1);
    tl = tl + 1;
  }
  let i: i32 = 0;
  let nn: i32 = pipe_modlet_get_n();
  let module_fp: i64 = pipe_modlet_module_fp();
  while (i < nn) {
    pipe_modlet_assign_unique_label(i, module_fp);
    i = i + 1;
  }
  i = 0;
  while (i < nn) {
    let llen2: i32 = 0;
    unsafe { llen2 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(i)); }
    let lbase2: i32 = pipe_modlet_off_label(i);
    let csz_raw: i32 = 0;
    unsafe { csz_raw = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(i)); }
    // Home size = payload only (strip array-decay bit30 / data bit29).
    let csz2: i32 = pipe_modlet_cell_payload(csz_raw);
    let calign: i32 = 8;
    let use_data: i32 = 0;
    let init_ref2: i32 = 0;
    let type_ref2: i32 = 0;
    let ik2: i32 = 0;
    let tk2: i32 = 0;
    let et2: i32 = 0;
    let ne2: i32 = 0;
    let data_off: i32 = 0;
    let data_len_now: i32 = 0;
    let pad: i32 = 0;
    let nbase2: i32 = 0;
    let nlen2: i32 = 0;
    let tl2: i32 = 0;
    let match_tl: i32 = 0;
    let k2: i32 = 0;
    let b2: i32 = 0;
    let rc: i32 = 0;
    let pool_bytes: i32 = 0;
    if (csz2 == 1) {
      calign = 1;
    } else {
      if (csz2 == 2) {
        calign = 2;
      } else {
        if (csz2 == 4) {
          calign = 4;
        } else {
          if (csz2 >= 16) {
            calign = 16;
          }
        }
      }
    }
    // Resolve the originating top-level let by name (array bake AND
    // scalar ptr-addr). Non-empty TYPE_ARRAY ARRAY_LIT → F7 .data when
    // cell+pool fits. Scalar ADDR_OF / fn-ptr → 8-byte .data + absolute64
    // RELA (library TUs have no hoist-target seed). Empty `u8[N]=[]`
    // stays COMMON. Oversized falls back to COMMON + hoist seed.
    // PLATFORM: SHARED library-TU .data.
    unsafe { nlen2 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i)); }
    nbase2 = pipe_modlet_off_name(i);
    match_tl = 0 - 1;
    tl2 = 0;
    while (tl2 < nlets) {
      let tln: i32 = 0;
      unsafe {
        unsafe { tln = pipeline_module_top_level_let_name_len(m, tl2); }
      }
      if (tln == nlen2 && tln > 0) {
        k2 = 0;
        while (k2 < tln) {
          let mb: i32 = 0;
          unsafe {
            unsafe { b2 = pipeline_module_top_level_let_name_byte_at(m, tl2, k2); }
            mb = g_pipeline_asm_modlet[nbase2 + k2] as i32;
          }
          if (b2 != mb) {
            break;
          }
          k2 = k2 + 1;
        }
        if (k2 == tln) {
          match_tl = tl2;
          break;
        }
      }
      tl2 = tl2 + 1;
    }
    if (match_tl >= 0) {
      unsafe {
        unsafe { init_ref2 = pipeline_module_top_level_let_init_ref(m, match_tl); }
        unsafe { type_ref2 = pipeline_module_top_level_let_type_ref(m, match_tl); }
      }
      if (init_ref2 > 0 && init_ref2 <= nexprs && type_ref2 > 0) {
        unsafe {
          unsafe { ik2 = pipeline_expr_kind_ord_at(a, init_ref2); }
          unsafe { tk2 = pipeline_type_kind_ord_at(a, type_ref2); }
          unsafe { ne2 = pipeline_expr_array_lit_num_elems_at(a, init_ref2); }
        }
        if (pipe_modlet_cell_is_array(csz_raw) != 0 && ik2 == 46 && tk2 == 10 && ne2 > 0) {
          pool_bytes = pipe_modlet_array_lit_string_pool_bytes(a, init_ref2);
          if (pool_bytes >= 0) {
            unsafe {
              unsafe { data_len_now = pipeline_elf_ctx_emit_data_len(elf_ctx); }
            }
            if (data_len_now < 0) {
              data_len_now = 0;
            }
            pad = 0;
            if (calign > 1) {
              pad = (calign - (data_len_now & (calign - 1))) & (calign - 1);
            }
            if (data_len_now + pad + csz2 + pool_bytes <= 65536) {
              use_data = 1;
            }
          }
        } else {
          if (pipe_modlet_cell_is_array(csz_raw) == 0 && (tk2 == 9 || tk2 == 18)) {
            if (pipe_modlet_scalar_init_is_ptr_addr(a, m, init_ref2) != 0) {
              unsafe {
                unsafe { data_len_now = pipeline_elf_ctx_emit_data_len(elf_ctx); }
              }
              if (data_len_now < 0) {
                data_len_now = 0;
              }
              pad = 0;
              if (calign > 1) {
                pad = (calign - (data_len_now & (calign - 1))) & (calign - 1);
              }
              if (data_len_now + pad + csz2 <= 65536) {
                use_data = 1;
              }
            }
          }
          // wave344: non-zero scalar imm (ordinals / home_off=-1) → .data.
          // Library Cap thins never run seed_nonzero hoist; COMMON stays 0
          // and poisons kind tables (check_expr XT001). Zero imm stays COMMON.
          // PLATFORM: SHARED library-TU .data knife · LINUX gold · MACOS.
          if (use_data == 0 && pipe_modlet_cell_is_array(csz_raw) == 0) {
            let imm_d: i32 = 0;
            unsafe { imm_d = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(i)); }
            if (imm_d != 0) {
              unsafe {
                unsafe { data_len_now = pipeline_elf_ctx_emit_data_len(elf_ctx); }
              }
              if (data_len_now < 0) {
                data_len_now = 0;
              }
              pad = 0;
              if (calign > 1) {
                pad = (calign - (data_len_now & (calign - 1))) & (calign - 1);
              }
              if (data_len_now + pad + csz2 <= 65536) {
                use_data = 1;
              }
            }
          }
        }
      }
    }
    if (use_data != 0) {
      if (pad > 0) {
        unsafe {
          unsafe { rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, pad); }
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      unsafe {
        unsafe { data_off = pipeline_elf_ctx_emit_data_len(elf_ctx); }
        unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 4); }
        unsafe { rc = pipeline_elf_ctx_add_label(elf_ctx, &g_pipeline_asm_modlet[lbase2], llen2, data_off); }
      }
      if (rc != 0) {
        unsafe {
          unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 0); }
        }
        return 0 - 1;
      }
      unsafe {
        unsafe { rc = pipeline_elf_ctx_add_sym(elf_ctx, &g_pipeline_asm_modlet[lbase2], llen2, data_off); }
      }
      if (rc != 0) {
        unsafe {
          unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 0); }
        }
        return 0 - 1;
      }
      unsafe {
        unsafe { rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, csz2); }
      }
      if (rc != 0) {
        unsafe {
          unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 0); }
        }
        return 0 - 1;
      }
      if (pipe_modlet_cell_is_array(csz_raw) != 0) {
        unsafe {
          unsafe { et2 = pipeline_type_elem_ref_at(a, type_ref2); }
          rc = pipe_modlet_bake_array_lit_elems_to_data(
            a, elf_ctx, init_ref2, et2, data_off, 0, csz2, m);
          unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 0); }
        }
      } else {
        // Ptr-addr bake OR wave344 scalar non-zero imm poke.
        // bake_ptr_addr returns 1 = not-an-address (must not trip -1).
        // PLATFORM: SHARED library-TU .data.
        let pa_b: i32 = 0;
        let imm_b: i32 = 0;
        if (init_ref2 > 0) {
          pa_b = pipe_modlet_scalar_init_is_ptr_addr(a, m, init_ref2);
        }
        if (pa_b != 0) {
          unsafe {
            rc = pipe_modlet_bake_ptr_addr_elem_to_data(
              a, elf_ctx, m, init_ref2, 8, data_off);
            unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 0); }
          }
        } else {
          unsafe { imm_b = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(i)); }
          unsafe {
            rc = pipe_modlet_bake_scalar_imm_to_data(elf_ctx, data_off, imm_b, csz2);
            unsafe { pipeline_elf_ctx_set_shndx_override(elf_ctx, 0); }
          }
        }
      }
      if (rc != 0) {
        return 0 - 1;
      }
unsafe { pipe_store_i32_le( &g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(i), csz_raw | pipe_modlet_cell_data_bit()); }
    } else {
      unsafe {
        unsafe { rc = pipeline_elf_ctx_add_common_sym(elf_ctx, &g_pipeline_asm_modlet[lbase2], llen2, csz2, calign); }
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    i = i + 1;
  }
  return 0;

}

/**
 * Reset the modlet table to empty (n=0).
 * @return void
 * wave139 pure: was static pipeline_asm_modlet_reset in modlet.c.
 * PLATFORM: SHARED - O(1); called once per mega emit.
 */
function pipeline_asm_modlet_reset(): void {
  pipe_modlet_set_n(0);
  g_pipe_modlet_strpool_seq = 0;
}

/**
 * Seed COMMON cells once on hoist-target entry.
 * Scalar cells: non-zero init_imm (historic wave139).
 * TYPE_ARRAY ARRAY_LIT cells: prepare emits zero BSS; write LIT elems
 * into COMMON so dest-SLICE / INDEX LEA sees the source payload
 * (`let A:[2]i32=[10,32]` and `const A:[2]i32=[10,32]`). Empty
 * `u8[N]=[]` stays zero (correct).
 * Arena/module from emit ctx (no extra pointer arg).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 mov/store fail
 * wave139 pure: G.7 authority (was static seed_nonzero_inits_elf_c).
 * wave344 / wave699: library TUs (main_func_index < 0) bake non-zero
 *   scalar imms into .data at prepare. Runtime seed is for programs
 *   with main(). FORCE mega has no main; dumping seed into the first
 *   export made parser_parse_into_init first-win over parser_x.
 * Cap residual: backend_enc_mov_imm64_to_rax_arch + store_from_rax +
 *   store_rax_to_rbx_offset + ARRAY_LIT readers.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx: *u8, ta: i32): i32 {
  if (elf_ctx == 0 as *u8 || (ta != 0 && ta != 1)) {
    return 0;
  }
  // wave344 / wave699: no runtime seed for library TUs (no main).
  // PLATFORM: SHARED.
  let mod0: *u8 = (0 as *u8);
  unsafe { mod0 = pipeline_asm_emit_module_ref_c(); }
  if (mod0 != (0 as *u8)) {
    let mi: i32 = 0;
    unsafe { mi = pipeline_module_main_func_index(mod0); }
    if (mi < 0) {
      return 0;
    }
  }
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  while (i < n) {
    let imm: i32 = 0;
    unsafe { imm = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(i)); }
    if (imm != 0) {
      let rc: i32 = 0;
      unsafe {
        unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta); }
      }
      if (rc != 0) {
        return 0 - 1;
      }
      let nlen: i32 = 0;
      unsafe { nlen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i)); }
      let nbase: i32 = pipe_modlet_off_name(i);
      if (pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, &g_pipeline_asm_modlet[nbase], nlen, ta) != 0) {
        return 0 - 1;
      }
    }
    i = i + 1;
  }
  // Module TYPE_ARRAY ARRAY_LIT (const + mutable) → COMMON is BSS zero
  // until we store elems here (hoist skips all TYPE_ARRAY). dest-SLICE
  // wrap / INDEX LEAs the cell; without this seed A[0] reads 0.
  // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
  let arena: *u8 = (0 as *u8);
  unsafe { arena = pipeline_asm_emit_ctx_arena_get(); }
  let mod: *u8 = (0 as *u8);
  unsafe { mod = pipeline_asm_emit_module_ref_c(); }
  if (arena != (0 as *u8) && mod != (0 as *u8)) {
    let nlets: i32 = 0;
    unsafe { nlets = pipe_mod_get_num_top_level_lets(mod); }
    let nexprs: i32 = 0;
    unsafe { nexprs = pipe_load_i32_le(arena, pipe_arena_off_num_exprs()); }
    let tl: i32 = 0;
    while (tl < nlets) {
      let nlen: i32 = 0;
      let init_ref: i32 = 0;
      let type_ref: i32 = 0;
      let ik: i32 = 0;
      let tk: i32 = 0;
      let idx: i32 = 0;
      let csz: i32 = 0;
      let et: i32 = 0;
      let rc2: i32 = 0;
      let name_buf: u8[256] = [];
      let k: i32 = 0;
      unsafe {
        unsafe { nlen = pipeline_module_top_level_let_name_len(mod, tl); }
      }
      if (nlen > 0 && nlen <= 255) {
        k = 0;
        while (k < nlen) {
          unsafe {
            unsafe { name_buf[k] = pipeline_module_top_level_let_name_byte_at(mod, tl, k) as u8; }
          }
          k = k + 1;
        }
        idx = pipeline_asm_modlet_find(&name_buf[0], nlen);
        if (idx >= 0) {
          unsafe { csz = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(idx)); }
          // Skip .data-backed cells: bytes already baked at prepare; stores
          // into Mach-O __DATA,__const may fault after final link.
          // PLATFORM: SHARED — library-TU .data knife.
          if (pipe_modlet_cell_is_array(csz) != 0 && pipe_modlet_cell_is_data(csz) == 0) {
            unsafe {
              unsafe { init_ref = pipeline_module_top_level_let_init_ref(mod, tl); }
              unsafe { type_ref = pipeline_module_top_level_let_type_ref(mod, tl); }
            }
            if (init_ref > 0 && init_ref <= nexprs && type_ref > 0) {
              unsafe {
                unsafe { ik = pipeline_expr_kind_ord_at(arena, init_ref); }
                unsafe { tk = pipeline_type_kind_ord_at(arena, type_ref); }
              }
              if (ik == 46 && tk == 10) {
                unsafe {
                  unsafe { et = pipeline_type_elem_ref_at(arena, type_ref); }
                }
                if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) == 0) {
                  rc2 = pipe_modlet_seed_array_lit_elems_to_rbx(
                    arena, elf_ctx, init_ref, et, ta, 0, mod);
                  if (rc2 != 0) {
                    return rc2;
                  }
                }
              }
            }
          }
        }
      }
      tl = tl + 1;
    }
  }
  return 0;
}

/**
 * Store rax/x0 into a shared modlet cell.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param name *u8 - modlet name
 * @param name_len i32 - length
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 miss/null/bad arch
 * wave139 pure: G.7 authority (was static store_from_rax_elf_c).
 * Cap residual: backend_enc_store_rax_to_rbx_indirect_arch (sz=8).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if ((ta != 0 && ta != 1) || elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let idx: i32 = pipeline_asm_modlet_find(name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) != 0) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    unsafe { rc = backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, 8, ta); }
  }
  return rc;
}
