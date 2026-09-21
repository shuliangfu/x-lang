// Thin pure: wave602 M2 — EXPR_RETURN ELF impl exit (operand + tail_join jmp).
// Ubuntu `if { return 7 } return 1` run=1 (Darwin overlay run=7): leftover
// PREFER pipeline_asm_emit_return_elf_impl is smash (`sub $0xe98`, no
// endbr64). gdb: impl is entered and emit_expr writes `mov $7,%eax`, but
// backend_enc_jmp_arch is never called — fall through the if-done join
// overwrites eax with 1. Same class as add_defs early-return `e9 00 00 00 00`.
// Do not call smash emit_ctx BSS getters (w601 dual-BSS option SEGV).
// G.7: complete mega pipeline_asm_emit_return_elf_impl EXIT (operand emit
// then jmp ly[1392..] tail_join). sret/array Path A–C stay on leftover
// helpers via emit_expr of the operand. Do not un-BAN arr_return Soft-Cap.
// PRODUCT: LINUX leftover gcc W overlay; HARD BAN PREFER; MACOS overlay.
// wave740 Class A: wrap remaining export-extern calls in unsafe so
// standalone `-backend asm -c` is no longer T001. Small-file
// `let x=call(); if` UND-drop is green both ends; this thin is T=1 U=7
// after the wrap. Do not product-PREFER this simplified exit (leftover
// gcc W already run=7; Path A–C stay on leftover).
// PLATFORM: SHARED · LINUX gold · MACOS.

export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;

/**
 * EXPR_RETURN ELF emit: evaluate operand into rax/x0 then jmp function
 * tail_join. Completes the mega wave144 exit that leftover PREFER smash
 * dropped (no ENC_JMP). Does not read smash emit_ctx BSS getters.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param expr_ref i32 — EXPR_RETURN (kind 41)
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @return i32 — 0 ok; -1 encoder/null/missing tail_join
 * PLATFORM: SHARED freestanding · LINUX leftover gcc W overlay · MACOS overlay.
 * wave740: Class A unsafe wrap; HARD BAN product PREFER.
 */
#[no_mangle]
export function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let ly: *u8 = 0 as *u8;
  let ret_op: i32 = 0;
  let rc: i32 = 0;
  let tj_len: i32 = 0;
  let tj_lbl: u8[256] = [];
  let ti: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  // Class A: export-extern calls must sit in unsafe (wave740).
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
    ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (ret_op != 0) {
    unsafe {
      rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
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
  // AsmFuncCtxLayout: tail_join name at 1392, length i32 at 1520.
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
