// Thin pure: wave217/411/492 CALL/METHOD text wrappers.
// G.7: body MUST match mega runtime_pipeline_abi.x wave217 leave.
// Seed cold twin is freestanding stub (-1); this thin restores real
// pool-snapshot + backend_emit_* via inject first-wins.
// wave411: PREFER both ends (Darwin/Ubuntu product inject + L2 5/5).
// wave492: no-local arena expr ptr (tip U starved `ep=call()`); BOTH PREFER L2.
// PLATFORM: SHARED freestanding text CALL/METHOD M8-tail.

/** Arena main-pool expr row pointer (C layout). Null on bad ref. */
export extern function pipeline_arena_expr_ptr(arena: *u8, ref: i32): *u8;
/** Pipe cell store for tip-stable ptr (no mid `x=call()`). */
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
/** Pipe cell load for tip-stable ptr. */
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;

// wave217: CALL/METHOD text thin wrappers pure leave
// (was Cap residual pipeline_asm_emit_call_args.c pipeline_asm_emit_expr_call_c
//  + pipeline_asm_emit_expr_method_call_c)
// G.7 product authority for M8-tail text EXPR_CALL / EXPR_METHOD_CALL:
//   pool-snapshot ast_Expr then delegate seed partial backend_emit_expr{,_method}_call.
// Why leave: Cap residual call_args body closed except intentional host-cc shell;
//   text wrappers are the last real bodies in that leaf.
// Why stack copy (not live arena ptr): match historical get_copy snapshot so a
//   partial that mutates e cannot corrupt the arena row (same as Cap residual).
// ABI: LP64 large-struct-by-value ≡ pointer-to-temp; pure passes *u8 snapshot.
// sizeof(struct ast_Expr) = 1224 (Cap 4.2.8 name[256]; mac+Ubuntu dual-end).
// Deferred: pipeline_x mega host-cc.
// PLATFORM: SHARED — pure delegation, no arch branch.
// ===========================================================================

/** LP64 byte size of struct ast_Expr (seed/parser layout). PLATFORM: SHARED. */
function pipeline_ast_expr_sizeof_c(): i32 {
  return 1224;
}


/**
 * Seed partial text EXPR_CALL emit (asm_backend_partial / weak mega fallback).
 * Large Expr is ABI pointer-to-temp; pure passes stack snapshot *u8.
 * @param arena *u8 — ASTArena*
 * @param out *u8 — CodegenOutBuf*
 * @param expr_ref i32 — CALL expr ref
 * @param e *u8 — pointer to struct ast_Expr snapshot (C layout)
 * @param ctx *u8 — AsmFuncCtx*
 * @param target_arch i32 — 0 x86_64 / 1 arm64
 * @return i32 — 0 ok; non-zero fail (partial may stub 0)
 * PLATFORM: SHARED text path.
 */
export extern "C" function backend_emit_expr_call(arena: *u8, out: *u8, expr_ref: i32, e: *u8, ctx: *u8, target_arch: i32): i32;

/**
 * Seed partial text EXPR_METHOD_CALL emit (same ABI as backend_emit_expr_call).
 * @param arena *u8 — ASTArena*
 * @param out *u8 — CodegenOutBuf*
 * @param expr_ref i32 — METHOD_CALL expr ref
 * @param e *u8 — pointer to struct ast_Expr snapshot (C layout)
 * @param ctx *u8 — AsmFuncCtx*
 * @param target_arch i32 — 0 x86_64 / 1 arm64
 * @return i32 — 0 ok; non-zero fail
 * PLATFORM: SHARED text path.
 */
export extern "C" function backend_emit_expr_method_call(arena: *u8, out: *u8, expr_ref: i32, e: *u8, ctx: *u8, target_arch: i32): i32;

/**
 * Emit text asm for EXPR_CALL — M8-tail thin wrapper (pool snapshot + partial).
 *
 * Re-fetches Expr from the arena (C layout) so backend.x callers never pass a
 * misaligned X-side Expr by value into the seed partial.
 *
 * wave492: no-local — pipe cell for arena ptr; ban mid `ep=pipeline_arena_expr_ptr()`.
 *
 * @param arena *u8 — ASTArena*; null → -1
 * @param out *u8 — CodegenOutBuf*
 * @param expr_ref i32 — CALL expression ref; <=0 → -1
 * @param ctx *u8 — AsmFuncCtx*
 * @param target_arch i32 — 0 x86_64 / 1 arm64
 * @return i32 — partial return, or -1 on gate fail
 *
 * wave217 pure: G.7 authority (was Cap residual call_args thin wrapper).
 * PLATFORM: SHARED — pure delegation, no arch branch.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_call_c(
    arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32): i32 {
  // Stack snapshot of C-layout Expr (sizeof 1224); matches Cap get_copy temp.
  let ebuf: u8[712] = [];
  let cell: u8[8];
  let esz: i32 = 0;
  let i: i32 = 0;
  if (expr_ref <= 0) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  // Load live arena row then copy to stack (snapshot; no arena mutate by partial).
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `ep=pipeline_arena_expr_ptr()`; pipe cell. */
    pipe_store_ptr_slot(&cell[0], 0, pipeline_arena_expr_ptr(arena, expr_ref));
    if (pipe_load_ptr_slot(&cell[0], 0) == (0 as *u8)) {
      return 0 - 1;
    }
  }
  esz = pipeline_ast_expr_sizeof_c();
  // Byte-copy C row into ebuf (equivalent to pipeline_arena_expr_get_copy).
  i = 0;
  while (i < esz) {
    unsafe {
      ebuf[i] = pipe_load_ptr_slot(&cell[0], 0)[i];
    }
    i = i + 1;
  }
  unsafe {
    return backend_emit_expr_call(arena, out, expr_ref, &ebuf[0], ctx, target_arch);
  }
}

/**
 * Emit text asm for EXPR_METHOD_CALL — M8-tail thin wrapper (pool snapshot + partial).
 *
 * Same pool-snapshot contract as pipeline_asm_emit_expr_call_c; delegates to
 * backend_emit_expr_method_call.
 *
 * wave492: no-local — pipe cell for arena ptr; ban mid `ep=pipeline_arena_expr_ptr()`.
 *
 * @param arena *u8 — ASTArena*; null → -1
 * @param out *u8 — CodegenOutBuf*
 * @param expr_ref i32 — METHOD_CALL expression ref; <=0 → -1
 * @param ctx *u8 — AsmFuncCtx*
 * @param target_arch i32 — 0 x86_64 / 1 arm64
 * @return i32 — partial return, or -1 on gate fail
 *
 * wave217 pure: G.7 authority (was Cap residual call_args thin wrapper).
 * PLATFORM: SHARED — pure delegation, no arch branch.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_method_call_c(
    arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32): i32 {
  let ebuf: u8[712] = [];
  let cell: u8[8];
  let esz: i32 = 0;
  let i: i32 = 0;
  if (expr_ref <= 0) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `ep=pipeline_arena_expr_ptr()`; pipe cell. */
    pipe_store_ptr_slot(&cell[0], 0, pipeline_arena_expr_ptr(arena, expr_ref));
    if (pipe_load_ptr_slot(&cell[0], 0) == (0 as *u8)) {
      return 0 - 1;
    }
  }
  esz = pipeline_ast_expr_sizeof_c();
  i = 0;
  while (i < esz) {
    unsafe {
      ebuf[i] = pipe_load_ptr_slot(&cell[0], 0)[i];
    }
    i = i + 1;
  }
  unsafe {
    return backend_emit_expr_method_call(arena, out, expr_ref, &ebuf[0], ctx, target_arch);
  }
}
