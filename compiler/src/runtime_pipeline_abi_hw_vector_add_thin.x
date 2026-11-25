// Live body of glue_try_hw_vector_add_binop_elf_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link: that copy calls
// iadd for f32x8, because its classifier returns 0 for that name.
// f32 add of two 1.0 lanes then compared as 2.0 and failed.
// vector_let_init_array_lit_a64_vlet_f32_fill_lane is the f32x8 check
// a let already uses. f32x4 and Vec4f still come from the classifier.
// An integer spelling still takes iadd. Kind 5 (sub) of an f32 vector
// still returns -1 so the scalar lane path runs, as before.
// PLATFORM: SHARED. HW bodies are LINUX|x86 and MACOS|ARM64.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function link_abi_getenv(name: *u8): *u8;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_simd_emit_cpu_features_c(): u32;
export extern function xlang_target_cpu_detect_host(): u32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena: *u8, type_ref: i32): i32;
export extern function simd_enc_try_hw_vector_iadd_rbp(elf_ctx: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern function simd_enc_try_hw_vector_isub_rbp(elf_ctx: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern function simd_enc_try_hw_vector_imul_rbp(elf_ctx: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern function simd_enc_try_hw_vector_fadd_rbp(elf_ctx: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern function simd_enc_try_hw_vector_fmul_rbp(elf_ctx: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;

/**
 * Try a hardware vector add, sub, or mul of two local vars.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit context. Null returns -1.
 * @param binop_ko i32 — 4 add, 5 sub, 6 mul. Any other kind returns -1.
 * @param left_ref i32 — left expr. Not a VAR (kind 3) returns -1.
 * @param right_ref i32 — right expr. Not a VAR returns -1.
 * @param dst_off i32 — destination frame slot.
 * @param type_ref i32 — vector type. Lane count comes from the existing helper.
 * @param ctx *u8 — asm ctx. Null returns -1.
 * @param ta i32 — 0 x86_64, 1 arm64. Forwarded to the encoder.
 * @return i32 — 0 when the hardware op was emitted, -1 to fall back.
 * f32x8 is not accepted by the linked classifier. The fill helper
 * returns 1 for that spelling, and for f32x4 and Vec4f. The f32 add
 * and f32 mul encoders already split eight lanes into two 128-bit ops.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_try_hw_vector_add_binop_elf_c(arena: *u8, elf_ctx: *u8, binop_ko: i32, left_ref: i32, right_ref: i32, dst_off: i32, type_ref: i32, ctx: *u8, ta: i32): i32 {
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let off_a: i32 = 0;
  let off_b: i32 = 0;
  let feats: u32 = 0;
  let hw_env: *u8 = 0 as *u8;
  let hw_b: i32 = 0;
  let ko_l: i32 = 0;
  let ko_r: i32 = 0;
  let rc: i32 = 0;
  let is_f32: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (binop_ko != 4) {
    if (binop_ko != 5) {
      if (binop_ko != 6) {
        return 0 - 1;
      }
    }
  }
  unsafe {
    ko_l = pipeline_expr_kind_ord_at(arena, left_ref);
    ko_r = pipeline_expr_kind_ord_at(arena, right_ref);
  }
  if (ko_l != 3) {
    return 0 - 1;
  }
  if (ko_r != 3) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    hw_env = link_abi_getenv("XLANG_SIMD_HW");
  }
  if (hw_env != (0 as *u8)) {
    unsafe {
      hw_b = hw_env[0] as i32;
    }
    if (hw_b == 48) {
      return 0 - 1;
    }
  }
  unsafe {
    off_a = glue_asm_local_var_stack_off_scoped(arena, ctx, left_ref);
    off_b = glue_asm_local_var_stack_off_scoped(arena, ctx, right_ref);
  }
  if (off_a < 0) {
    return 0 - 1;
  }
  if (off_b < 0) {
    return 0 - 1;
  }
  unsafe {
    feats = glue_simd_emit_cpu_features_c();
  }
  if (feats == 0) {
    unsafe {
      feats = xlang_target_cpu_detect_host();
    }
  }
  unsafe {
    is_f32 = glue_vector_elem_is_f32_c(arena, type_ref);
  }
  // The linked classifier returns 0 for f32x8. Integer add of the f32
  // bits is not 2.0. The fill helper already accepts that spelling.
  // f32x4 and Vec4f already returned 1 above, so this call is the
  // f32x8 gap. An integer vector stays 0 and keeps iadd.
  // PLATFORM: MACOS|ARM64 and LINUX|x86. The helper is SHARED.
  if (is_f32 == 0) {
    unsafe {
      is_f32 = vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena, type_ref);
    }
  }
  if (is_f32 != 0) {
    if (binop_ko == 6) {
      unsafe {
        return simd_enc_try_hw_vector_fmul_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
      }
    }
    if (binop_ko != 4) {
      return 0 - 1;
    }
    unsafe {
      return simd_enc_try_hw_vector_fadd_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
    }
  }
  if (binop_ko == 5) {
    unsafe {
      return simd_enc_try_hw_vector_isub_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
    }
  }
  if (binop_ko == 6) {
    unsafe {
      return simd_enc_try_hw_vector_imul_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
    }
  }
  unsafe {
    return simd_enc_try_hw_vector_iadd_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
  }
}
