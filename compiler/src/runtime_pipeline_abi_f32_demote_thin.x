// Thin pure overlay: f32-dest demote for Linux (w1507, 终局待办 10.34).
// glue_maybe_demote_f64_to_f32_eax_elf_c (runtime_pipeline_abi.x, banned to
// edit) asks glue_binop_operand_is_scalar_f64_elf_c about the source only, and
// that classifier calls every FLOAT_LIT f64. But a FLOAT_LIT into an f32 dest
// is always emitted dest-typed (glue_emit_assign_rhs_elf_c imm32; let-init
// init_f32_lit, which already skips this call), and a compound op with a
// FLOAT_LIT right side computes in the lhs type. So on the Linux VAR assign
// path (build_asm/selfhost_pabi/assign.o from runtime_pipeline_abi_assign_thin.x,
// which calls this after rhs_to_rax) `x = 2.25` / `x += 2.25` / `x *= 2.0`
// ran cvtsd2ss over f32 bits and stored garbage.
// Same body as the pabi original plus one rule: a FLOAT_LIT source (kind 1)
// never demotes. The pabi copy is weak on Linux, so this strong body wins.
// Darwin and Windows skip the demote in the VAR gate instead
// (runtime_pipeline_abi_assign_var_compound_thin.x, w1507_f32_bits_ready).
// PLATFORM: LINUX (g05_relink_env links it first; Darwin/Windows do not build it).

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Maybe demote f64 bits in rax to f32 bits in eax (cvtsd2ss) before a 4-byte
 * f32 store. FLOAT_LIT sources are already f32 bits for an f32 dest.
 * @param arena *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param ctx *u8 - AsmFuncCtx* (VAR decl lookup; may be null)
 * @param dest_ty_ref i32 - dest type ref; f32 (kind 14) triggers demote
 * @param src_expr_ref i32 - source expr ref; <=0 no-op
 * @param ta i32 - target arch (0 x86_64 / 1 arm64)
 * @return i32 - 0 ok or no-op; -1 encode failure
 * PLATFORM: LINUX x86_64 (arch helper also encodes arm64).
 */
#[no_mangle]
export function glue_maybe_demote_f64_to_f32_eax_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, dest_ty_ref: i32, src_expr_ref: i32, ta: i32): i32 {
  let dk: i32 = 0;
  let is_f64_src: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || dest_ty_ref <= 0 || src_expr_ref <= 0) {
    return 0;
  }
  unsafe {
    dk = pipeline_type_kind_ord_at(arena, dest_ty_ref);
    if (dk != 14) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, src_expr_ref) == 1) {
      return 0;
    }
    is_f64_src = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, src_expr_ref);
    if (is_f64_src != 0) {
      return backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx, ta);
    }
  }
  return 0;
}
