/*
 * Host-gcc first-wins twin of glue_emit_block_final_expr_elf.
 *
 * DIG s258 Soft Cap (PLATFORM: WINDOWS host-cc):
 * Soft Cap w1010 body_sync reaches final_expr after let init, but the
 * global T is tipU (large frame) while the thin.x copy stays a local `t`.
 * tipU final_expr SEGV (RIP=0) on bare `let x: i32 = 7; return x;`.
 * Tip-land this host-cc twin (seed leftover shape) + win_patch fold.
 *
 * G.7: complete existing final_expr authority; do not open a second probe.
 */
#include <stdint.h>

extern void *pipeline_arena_block_ptr(void *a, int32_t ref);
extern int32_t pipeline_block_stmt_order_kind(void *arena, int32_t block_ref, int32_t si);
extern int32_t pipeline_block_stmt_order_idx(void *arena, int32_t block_ref, int32_t si);
extern int32_t pipeline_block_expr_stmt_ref(void *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_return_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_rec(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);

/**
 * Read little-endian i32 at byte offset from a block sidecar pointer.
 * @param blk block object from pipeline_arena_block_ptr
 * @param off byte offset (final_expr_ref=0x4c, num_stmt_order=0x54)
 * @return i32 field value; 0 if blk null
 */
static int32_t dig_blk_i32(void *blk, int32_t off) {
  const uint8_t *p;
  if (!blk) {
    return 0;
  }
  p = (const uint8_t *)blk + off;
  return (int32_t)((uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24));
}

/**
 * Emit block final_expr when stmt_order has no RETURN expr-stmt.
 * Matches seed leftover hybrid: skip if RETURN already in stmt_order;
 * kind 41 → emit_return_elf_impl; else emit_expr_elf_rec.
 *
 * @param arena ASTArena*
 * @param elf_ctx ElfCodegenCtx*
 * @param block_ref block id
 * @param ctx AsmFuncCtx*
 * @param ta target arch
 * @return 0 ok; -1 emit failure
 */
int32_t glue_emit_block_final_expr_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta) {
  void *blk;
  int32_t fref;
  int32_t ko;
  int32_t nso;
  int32_t si;
  int32_t idx;
  int32_t er;

  if (!arena || !elf_ctx || !ctx || block_ref <= 0) {
    return 0;
  }
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (!blk) {
    return 0;
  }
  fref = dig_blk_i32(blk, 0x4c); /* final_expr_ref */
  if (fref == 0) {
    return 0;
  }
  /* Skip only when stmt_order already emitted a RETURN expr-stmt (ko==41). */
  nso = dig_blk_i32(blk, 0x54); /* num_stmt_order */
  for (si = 0; si < nso; si++) {
    if (pipeline_block_stmt_order_kind(arena, block_ref, si) != 2) {
      continue;
    }
    idx = pipeline_block_stmt_order_idx(arena, block_ref, si);
    er = pipeline_block_expr_stmt_ref(arena, block_ref, idx);
    if (er > 0 && pipeline_expr_kind_ord_at(arena, er) == 41) {
      return 0;
    }
  }
  ko = pipeline_expr_kind_ord_at(arena, fref);
  if (ko == 41) {
    return pipeline_asm_emit_return_elf_impl(arena, elf_ctx, fref, ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, fref, ctx, ta) != 0) {
    return -1;
  }
  return 0;
}
