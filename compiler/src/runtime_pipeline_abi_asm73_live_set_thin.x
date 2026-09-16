// Thin pure: wave214 live set arrays + opaque u8 overlay thins.
// G.7: bodies MUST match mega runtime_pipeline_abi.x wave214 leave.
// ensure injects via inject_thin_leaf (PREFER_ASM).
// pipe_load/store + wave176/159 helpers are leftover; wrap unsafe.
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS.

/** Host LE i32 load/store (product helpers; leftover T). */
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
/** wave213: live_fwd_active gate for loop note_current. */
export extern function glue_block_live_fwd_active_get(): i32;
/** wave159: stmt_order has if/while/for. */
export extern function glue_block_stmt_order_has_cfg(arena: *u8, block_ref: i32): i32;
/** wave176: reverse DF live-end for linear blocks. */
export extern function glue_block_compute_live_end_linear(arena: *u8, ctx: *u8, block_ref: i32, out: *u8): void;
/** wave176: collect expr uses into live overlay. */
export extern function glue_live_fwd_collect_expr_uses(arena: *u8, ctx: *u8, expr_ref: i32, gen: *u8): void;

// wave214: live set arrays + opaque u8 overlay thins pure leave
// ---------------------------------------------------------------------------
// G.7 single authority (was Cap residual spill.c). Pure-owned BSS:
//   · block_live_fwd / live_at_stmt[32] / snap_before_if / sub_exit_snap
//   · cfg_peak_live + peak_stmt_i
//   · loop break-exit + continue-head stacks (depth 8) + depth
// Layout: GlueBlockLiveFwd = offs[32] i32 + n i32 at byte 128; blob stride 136
// (matches pure stack u8[136] overlays used by wave160/176).
// Residual spill keeps only cache_invalidate_at_cfg_merge shell.
// PLATFORM: SHARED freestanding 7.3.
// ---------------------------------------------------------------------------

// LIVE blob stride bytes (offs[32]*4 + n*4 + pad to 136).
// n lives at byte offset 128; offs[i] at i*4.

let g_block_live_fwd_blob: u8[136] = [];
let g_live_snap_before_if_blob: u8[136] = [];
let g_block_live_sub_exit_snap_blob: u8[136] = [];
let g_asm73_cfg_peak_live_blob: u8[136] = [];
let g_asm73_cfg_peak_stmt_i: i32 = 0;
// 32 × 136 = 4352
let g_block_live_at_stmt_blob: u8[4352] = [];
// 8 × 136 = 1088
let g_loop_break_exit_live_stack_blob: u8[1088] = [];
let g_loop_continue_head_live_stack_blob: u8[1088] = [];
let g_loop_break_exit_depth: i32 = 0;

/**
 * Private: load live.n from opaque GlueBlockLiveFwd overlay (byte 128).
 * @param live *u8 — overlay; null → 0
 * @return i32 — n
 * PLATFORM: SHARED freestanding 7.3.
 */
function w214_live_n(live: *u8): i32 {
  let n: i32 = 0;
  if (live == (0 as *u8)) {
    return 0;
  }
  unsafe {
    n = pipe_load_i32_le(live, 128);
  }
  return n;
}

/**
 * Private: store live.n.
 * @param live *u8 — overlay; null → no-op
 * @param n i32 — count
 * @return void
 * PLATFORM: SHARED freestanding 7.3.
 */
function w214_live_set_n(live: *u8, n: i32): void {
  if (live == (0 as *u8)) {
    return;
  }
  unsafe {
    pipe_store_i32_le(live, 128, n);
  }
}

/**
 * Private: load live.offs[i].
 * @param live *u8 — overlay
 * @param i i32 — index
 * @return i32 — stack off
 * PLATFORM: SHARED freestanding 7.3.
 */
function w214_live_off(live: *u8, i: i32): i32 {
  if (live == (0 as *u8) || i < 0) {
    return 0 - 1;
  }
  let v: i32 = 0;
  unsafe {
    v = pipe_load_i32_le(live, i * 4);
  }
  return v;
}

/**
 * Private: store live.offs[i].
 * @param live *u8 — overlay
 * @param i i32 — index
 * @param off i32 — stack slot
 * @return void
 * PLATFORM: SHARED freestanding 7.3.
 */
function w214_live_set_off(live: *u8, i: i32, off: i32): void {
  if (live == (0 as *u8) || i < 0) {
    return;
  }
  unsafe {
    pipe_store_i32_le(live, i * 4, off);
  }
}

/**
 * |live| n for opaque GlueBlockLiveFwd overlay.
 * @param live *u8 — overlay; null → 0
 * @return i32 — n
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_n_get(live: *u8): i32 {
  return w214_live_n(live);
}

/**
 * live.offs[i]; -1 when OOB/null.
 * @param live *u8 — overlay
 * @param i i32 — index
 * @return i32 — off or -1
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_off_at(live: *u8, i: i32): i32 {
  let n: i32 = 0;
  if (live == (0 as *u8) || i < 0) {
    return 0 - 1;
  }
  n = w214_live_n(live);
  if (i >= n) {
    return 0 - 1;
  }
  return w214_live_off(live, i);
}

/**
 * Clear opaque live set (n=0).
 * @param live *u8 — overlay; null → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_clear_u8(live: *u8): void {
  if (live == (0 as *u8)) {
    return;
  }
  w214_live_set_n(live, 0);
}

/**
 * Add stack slot off to opaque live (set-add; cap 32).
 * @param live *u8 — overlay; null → no-op
 * @param off i32 — stack slot; <0 → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_add_u8(live: *u8, off: i32): void {
  let n: i32 = 0;
  let i: i32 = 0;
  if (live == (0 as *u8) || off < 0) {
    return;
  }
  n = w214_live_n(live);
  while (i < n) {
    if (w214_live_off(live, i) == off) {
      return;
    }
    i = i + 1;
  }
  if (n >= 32) {
    return;
  }
  w214_live_set_off(live, n, off);
  w214_live_set_n(live, n + 1);
}

/**
 * Copy opaque live src → dst (n + used offs only).
 * @param dst *u8 — destination overlay; null → no-op
 * @param src *u8 — source overlay; null → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave168).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_copy_u8(dst: *u8, src: *u8): void {
  let n: i32 = 0;
  let i: i32 = 0;
  if (dst == (0 as *u8) || src == (0 as *u8)) {
    return;
  }
  n = w214_live_n(src);
  w214_live_set_n(dst, n);
  while (i < n) {
    w214_live_set_off(dst, i, w214_live_off(src, i));
    i = i + 1;
  }
}

/**
 * Remove stack slot off from opaque live (if present).
 * @param live *u8 — overlay; null → no-op
 * @param off i32 — stack slot; <0 → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_remove_u8(live: *u8, off: i32): void {
  let n: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  if (live == (0 as *u8) || off < 0) {
    return;
  }
  n = w214_live_n(live);
  while (i < n) {
    if (w214_live_off(live, i) == off) {
      j = i + 1;
      while (j < n) {
        w214_live_set_off(live, j - 1, w214_live_off(live, j));
        j = j + 1;
      }
      w214_live_set_n(live, n - 1);
      return;
    }
    i = i + 1;
  }
}

/**
 * Return 1 if opaque live contains stack slot off.
 * @param live *u8 — overlay; null → 0
 * @param off i32 — stack slot; <0 → 0
 * @return i32 — 0 or 1
 * wave214 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_contains_u8(live: *u8, off: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  if (live == (0 as *u8) || off < 0) {
    return 0;
  }
  n = w214_live_n(live);
  while (i < n) {
    if (w214_live_off(live, i) == off) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Opaque pointer to global block_live_fwd BSS.
 * @return *u8 — GlueBlockLiveFwd overlay
 * wave214 pure: G.7 authority (was Cap residual spill wave166).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_as_u8(): *u8 {
  return &g_block_live_fwd_blob[0];
}

/**
 * Clear global block_live_fwd.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_clear_global(): void {
  glue_live_fwd_clear_u8(&g_block_live_fwd_blob[0]);
}

/**
 * Return 1 if global block_live_fwd contains off.
 * @param off i32 — stack slot; <0 → 0
 * @return i32 — 0 or 1
 * wave214 pure: G.7 authority (was Cap residual spill wave163).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_contains_off(off: i32): i32 {
  return glue_live_fwd_contains_u8(&g_block_live_fwd_blob[0], off);
}

/**
 * Add off to global block_live_fwd.
 * @param off i32 — stack slot; <0 → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_add_off(off: i32): void {
  glue_live_fwd_add_u8(&g_block_live_fwd_blob[0], off);
}

/**
 * Remove off from global block_live_fwd.
 * @param off i32 — stack slot; <0 → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_remove_off(off: i32): void {
  glue_live_fwd_remove_u8(&g_block_live_fwd_blob[0], off);
}

/**
 * Copy opaque live into global block_live_fwd (null → clear).
 * @param src *u8 — overlay; null → clear global
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave160).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_copy_from_u8(src: *u8): void {
  if (src == (0 as *u8)) {
    glue_live_fwd_clear_u8(&g_block_live_fwd_blob[0]);
    return;
  }
  glue_live_fwd_copy_u8(&g_block_live_fwd_blob[0], src);
}

/**
 * Union opaque live into global block_live_fwd.
 * @param src *u8 — overlay; null → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave161).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_union_from_u8(src: *u8): void {
  let n: i32 = 0;
  let i: i32 = 0;
  let off: i32 = 0;
  if (src == (0 as *u8)) {
    return;
  }
  n = w214_live_n(src);
  while (i < n) {
    off = w214_live_off(src, i);
    glue_live_fwd_add_u8(&g_block_live_fwd_blob[0], off);
    i = i + 1;
  }
}

/**
 * Snapshot global block_live_fwd into snap_before_if.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_snap_before_if_copy_from_block_live_fwd(): void {
  glue_live_fwd_copy_u8(&g_live_snap_before_if_blob[0], &g_block_live_fwd_blob[0]);
}

/**
 * Copy snap_before_if into opaque dst.
 * @param dst *u8 — overlay; null → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave129).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_live_fwd_copy_from_snap_before_if(dst: *u8): void {
  if (dst == (0 as *u8)) {
    return;
  }
  glue_live_fwd_copy_u8(dst, &g_live_snap_before_if_blob[0]);
}

/**
 * Clear sub_exit snap.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_sub_exit_snap_clear(): void {
  glue_live_fwd_clear_u8(&g_block_live_sub_exit_snap_blob[0]);
}

/**
 * Copy global block_live_fwd into sub_exit snap.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_sub_exit_snap_copy_from_block_live_fwd(): void {
  glue_live_fwd_copy_u8(&g_block_live_sub_exit_snap_blob[0], &g_block_live_fwd_blob[0]);
}

/**
 * Copy opaque live into sub_exit snap (null → clear).
 * @param src *u8 — overlay; null → clear
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_sub_exit_snap_copy_from_u8(src: *u8): void {
  if (src == (0 as *u8)) {
    glue_live_fwd_clear_u8(&g_block_live_sub_exit_snap_blob[0]);
    return;
  }
  glue_live_fwd_copy_u8(&g_block_live_sub_exit_snap_blob[0], src);
}

/**
 * |live| at live_at_stmt[stmt_i].
 * @param stmt_i i32 — 0..31; OOB → 0
 * @return i32 — n
 * wave214 pure: G.7 authority (was Cap residual spill wave165).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_live_at_stmt_n_get(stmt_i: i32): i32 {
  let base: *u8 = 0 as *u8;
  if (stmt_i < 0 || stmt_i >= 32) {
    return 0;
  }
  base = &g_block_live_at_stmt_blob[stmt_i * 136];
  return w214_live_n(base);
}

/**
 * Opaque pointer to live_at_stmt[stmt_i].
 * @param stmt_i i32 — 0..31; OOB → null
 * @return *u8 — overlay or null
 * wave214 pure: G.7 authority (was Cap residual spill wave165).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_live_at_stmt_as_u8(stmt_i: i32): *u8 {
  if (stmt_i < 0 || stmt_i >= 32) {
    return 0 as *u8;
  }
  return &g_block_live_at_stmt_blob[stmt_i * 136];
}

/**
 * Copy opaque live into live_at_stmt[stmt_i] (null → clear entry).
 * @param stmt_i i32 — 0..31; OOB → no-op
 * @param live *u8 — overlay; null → clear
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_at_stmt_copy_from_u8(stmt_i: i32, live: *u8): void {
  let base: *u8 = 0 as *u8;
  if (stmt_i < 0 || stmt_i >= 32) {
    return;
  }
  base = &g_block_live_at_stmt_blob[stmt_i * 136];
  if (live == (0 as *u8)) {
    glue_live_fwd_clear_u8(base);
    return;
  }
  glue_live_fwd_copy_u8(base, live);
}

/**
 * |cfg_peak_live| n.
 * @return i32 — n
 * wave214 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_peak_live_n_get(): i32 {
  return w214_live_n(&g_asm73_cfg_peak_live_blob[0]);
}

/**
 * Opaque pointer to cfg_peak_live.
 * @return *u8 — overlay
 * wave214 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_peak_live_as_u8(): *u8 {
  return &g_asm73_cfg_peak_live_blob[0];
}

/**
 * Peak program-point stmt index.
 * @return i32 — stmt_i
 * wave214 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_peak_stmt_i_get(): i32 {
  return g_asm73_cfg_peak_stmt_i;
}

/**
 * Snapshot live into cfg_peak_live and set peak stmt_i.
 * @param live *u8 — overlay; null → no-op
 * @param stmt_i i32 — peak program point
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_peak_snapshot_from_u8(live: *u8, stmt_i: i32): void {
  if (live == (0 as *u8)) {
    return;
  }
  glue_live_fwd_copy_u8(&g_asm73_cfg_peak_live_blob[0], live);
  g_asm73_cfg_peak_stmt_i = stmt_i;
}

/**
 * Clear cfg peak_live set + peak stmt index (cfg_interf_prepare callee).
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave213 peak_clear).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_peak_clear(): void {
  g_asm73_cfg_peak_stmt_i = 0;
  glue_live_fwd_clear_u8(&g_asm73_cfg_peak_live_blob[0]);
}

/**
 * Clear global live_fwd then collect uses of final_expr.
 * @param arena *u8 — ASTArena*
 * @param ctx *u8 — AsmFuncCtx*
 * @param expr_ref i32 — expr ref; <=0 → clear only
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_set_from_expr_uses(arena: *u8, ctx: *u8, expr_ref: i32): void {
  glue_live_fwd_clear_u8(&g_block_live_fwd_blob[0]);
  if (expr_ref > 0 && arena != (0 as *u8) && ctx != (0 as *u8)) {
    unsafe {
      glue_live_fwd_collect_expr_uses(arena, ctx, expr_ref, &g_block_live_fwd_blob[0]);
    }
  }
}

/**
 * Fill out with sub-block exit live: cfg → sub_exit snap; linear → reverse DF.
 * @param arena *u8 — ASTArena*
 * @param ctx *u8 — AsmFuncCtx*
 * @param block_ref i32 — block ref; <=0 → clear out
 * @param out_live *u8 — overlay; null → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave129).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_fill_live_end_for_merge(arena: *u8, ctx: *u8, block_ref: i32, out_live: *u8): void {
  let has_cfg: i32 = 0;
  if (out_live == (0 as *u8)) {
    return;
  }
  glue_live_fwd_clear_u8(out_live);
  if (arena == (0 as *u8) || ctx == (0 as *u8) || block_ref <= 0) {
    return;
  }
  unsafe {
    has_cfg = glue_block_stmt_order_has_cfg(arena, block_ref);
  }
  if (has_cfg != 0) {
    glue_live_fwd_copy_u8(out_live, &g_block_live_sub_exit_snap_blob[0]);
  } else {
    unsafe {
      glue_block_compute_live_end_linear(arena, ctx, block_ref, out_live);
    }
  }
}

/**
 * Current break/continue live stack depth (0 = no open loop).
 * @return i32 — depth
 * wave214 pure: G.7 authority (was Cap residual spill wave160).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_break_exit_depth_get(): i32 {
  return g_loop_break_exit_depth;
}

/**
 * Enter loop: clear current-layer break/continue live accumulators.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave155).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_break_exit_push(): void {
  let d: i32 = 0;
  if (g_loop_break_exit_depth < 8) {
    d = g_loop_break_exit_depth;
    glue_live_fwd_clear_u8(&g_loop_break_exit_live_stack_blob[d * 136]);
    glue_live_fwd_clear_u8(&g_loop_continue_head_live_stack_blob[d * 136]);
    g_loop_break_exit_depth = g_loop_break_exit_depth + 1;
  }
}

/**
 * Leave loop: pop break-exit stack (after loop merge).
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave155).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_break_exit_pop(): void {
  if (g_loop_break_exit_depth > 0) {
    g_loop_break_exit_depth = g_loop_break_exit_depth - 1;
  }
}

/**
 * Private: union src into dst live overlay.
 * @param dst / src *u8 — overlays
 * @return void
 * PLATFORM: SHARED freestanding 7.3.
 */
function w214_live_union_into(dst: *u8, src: *u8): void {
  let n: i32 = 0;
  let i: i32 = 0;
  if (dst == (0 as *u8) || src == (0 as *u8)) {
    return;
  }
  n = w214_live_n(src);
  while (i < n) {
    glue_live_fwd_add_u8(dst, w214_live_off(src, i));
    i = i + 1;
  }
}

/**
 * 7.3 break: union current (or sub_exit snap) live into this layer break exit ∪.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave162).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_break_exit_note_current(): void {
  let d: i32 = 0;
  let dst: *u8 = 0 as *u8;
  if (g_loop_break_exit_depth <= 0) {
    return;
  }
  d = g_loop_break_exit_depth - 1;
  dst = &g_loop_break_exit_live_stack_blob[d * 136];
  let act: i32 = 0;
  unsafe {
    act = glue_block_live_fwd_active_get();
  }
  if (act != 0) {
    w214_live_union_into(dst, &g_block_live_fwd_blob[0]);
  } else {
    w214_live_union_into(dst, &g_block_live_sub_exit_snap_blob[0]);
  }
}

/**
 * 7.3 continue: union current live into this layer continue-head ∪.
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave162).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_continue_head_note_current(): void {
  let d: i32 = 0;
  let dst: *u8 = 0 as *u8;
  if (g_loop_break_exit_depth <= 0) {
    return;
  }
  d = g_loop_break_exit_depth - 1;
  dst = &g_loop_continue_head_live_stack_blob[d * 136];
  let act: i32 = 0;
  unsafe {
    act = glue_block_live_fwd_active_get();
  }
  if (act != 0) {
    w214_live_union_into(dst, &g_block_live_fwd_blob[0]);
  } else {
    w214_live_union_into(dst, &g_block_live_sub_exit_snap_blob[0]);
  }
}

/**
 * Union break-exit live stack[d] into opaque dst.
 * @param dst *u8 — overlay; null → no-op
 * @param d i32 — stack index; OOB → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave160).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_break_exit_live_union_into_u8(dst: *u8, d: i32): void {
  if (dst == (0 as *u8) || d < 0 || d >= 8) {
    return;
  }
  w214_live_union_into(dst, &g_loop_break_exit_live_stack_blob[d * 136]);
}

/**
 * Union continue-head live stack[d] into opaque dst.
 * @param dst *u8 — overlay; null → no-op
 * @param d i32 — stack index; OOB → no-op
 * @return void
 * wave214 pure: G.7 authority (was Cap residual spill wave160).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_loop_continue_head_live_union_into_u8(dst: *u8, d: i32): void {
  if (dst == (0 as *u8) || d < 0 || d >= 8) {
    return;
  }
  w214_live_union_into(dst, &g_loop_continue_head_live_stack_blob[d * 136]);
}

// end wave214 pure-owned leave
