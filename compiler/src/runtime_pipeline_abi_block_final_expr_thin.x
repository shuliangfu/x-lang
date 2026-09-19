// Thin pure: wave601 M2 — block final_expr tail_join gate.
// Ubuntu if-in-while run=1: leftover PREFER emit_ctx func_index_get
// returns -1, so glue_emit_block_final_expr_elf takes the unknown-identity
// fallback and jmp function tail_join (.Lf0_0), skipping the while backedge.
// LINUX -E of emit_ctx BSS getters dual-BSS option ptr load SEGV (w380 class).
// G.7: complete the tail_join gate — unknown module/func_index must NOT
// jmp function tail_join (nested while/if bodies are not the function body).
// Body matches mega wave153 leave except the unsafe fallback (now 0).
// PRODUCT: LINUX -E replace leftover T; HARD BAN PREFER; MACOS overlay.
// PLATFORM: SHARED · LINUX gold · MACOS.

export extern function pipeline_asm_block_final_expr_ref_at(arena: *u8, block_ref: i32): i32;
export extern function glue_block_stmt_order_has_return(arena: *u8, block_ref: i32): i32;
export extern function glue_block_body_bind_module_dep_from_ctx(ctx: *u8): void;
export extern function glue_asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_if_expr_arm_emit_depth_get(): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_module_func_body_ref_at(mod: *u8, fi: i32): i32;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;

/**
 * Block tail final_expr emit (no RETURN in stmt_order).
 * After emitting fref, jmp function tail_join only when this block is
 * the current function body. Unknown emit module/func_index → no jmp
 * (do not skip while backedges).
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param block_ref i32 — block whose final_expr is emitted
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 encoder/cleanup failure
 * wave153 pure: G.7 authority (was static glue_emit_block_final_expr_elf).
 * wave601: LINUX product path is host-cc -E of this gate (PREFER BAN).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_block_final_expr_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32 {
  let fref: i32 = 0;
  let rc: i32 = 0;
  let allow_tail_join: i32 = 0;
  let fref_ko: i32 = 0;
  let depth: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let fi: i32 = 0;
  let fb: i32 = 0;
  let ly: *u8 = 0 as *u8;
  let tj_len: i32 = 0;
  let tj_lbl: u8[256] = [];
  let tk: i32 = 0;
  if (arena == 0 as *u8 || elf_ctx == 0 as *u8 || ctx == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  fref = pipeline_asm_block_final_expr_ref_at(arena, block_ref);
  if (fref == 0) {
    return 0;
  }
  if (glue_block_stmt_order_has_return(arena, block_ref) != 0) {
    return 0;
  }
  unsafe {
    glue_block_body_bind_module_dep_from_ctx(ctx);
    glue_asm_ctx_set_scope_block(ctx, block_ref);
    rc = glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, fref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  allow_tail_join = 0;
  unsafe {
    fref_ko = pipeline_expr_kind_ord_at(arena, fref);
    depth = glue_if_expr_arm_emit_depth_get();
  }
  if (depth <= 0 && fref_ko != 41) {
    mod = pipeline_asm_emit_module_ref_c();
    fi = pipeline_asm_emit_func_index_c();
    if (mod != 0 as *u8 && fi >= 0) {
      unsafe {
        fb = pipeline_module_func_body_ref_at(mod, fi);
      }
      if (fb > 0 && fb == block_ref) {
        allow_tail_join = 1;
      }
    }
    // Unknown emit module/func_index: keep allow_tail_join=0.
    // Smash leftover func_index_get returns -1; the old fallback
    // jmp .Lf0_0 skipped while backedges (if-in-while run=1).
  }
  if (allow_tail_join != 0) {
    ly = pipeline_asm_ctx_layout(ctx);
    if (ly != 0 as *u8) {
      tj_len = pipe_load_i32_le(ly, 1520);
      if (tj_len > 0) {
        tk = 0;
        while (tk < tj_len && tk < 128) {
          unsafe {
            tj_lbl[tk] = ly[1392 + tk];
          }
          tk = tk + 1;
        }
        unsafe {
          rc = backend_enc_jmp_arch(elf_ctx, &tj_lbl[0], tj_len, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
  }
  return 0;
}
