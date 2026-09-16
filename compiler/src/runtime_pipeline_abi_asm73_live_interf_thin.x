// Thin pure: wave213 live control + Chaitin interf BSS + linear_ctx.
// G.7: bodies MUST match mega runtime_pipeline_abi.x wave213 leave.
// ensure injects via inject_thin_leaf (PREFER_ASM).
// Calls wave212 final_expr_use_n_set + wave214 live/peak overlays (leftover).
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS.

/** wave212: clear final_expr VAR-use count (cfg stack-spill gate). */
export extern function glue_asm73_cfg_final_expr_use_n_set(n: i32): void;
/** wave214: clear cfg peak live BSS (still residual layout in leftover). */
export extern function glue_asm73_cfg_peak_clear(): void;
/** wave214: opaque GlueBlockLiveFwd n / off accessors. */
export extern function glue_live_fwd_n_get(live: *u8): i32;
export extern function glue_live_fwd_off_at(live: *u8, i: i32): i32;
/** wave214: live_at_stmt[stmt_i] as *u8 overlay. */
export extern function glue_asm73_live_at_stmt_as_u8(stmt_i: i32): *u8;


// ---------------------------------------------------------------------------
// wave213: live control scalars + Chaitin interf BSS + linear_ctx pure leave
// ---------------------------------------------------------------------------
// G.7 single authority (was Cap residual spill.c). Pure-owned BSS:
//   · cfg_parent / live_fwd_active / emit_stmt_i / linear_max_live_n
//   · interf n + off[32] + adj[32] + stack (depth 8 × max 32)
//   · linear_ctx bind (arena/ctx ptrs + block_ref/slot_base/nconst/nlet/nso)
// Residual keeps live set arrays (block_live_fwd / live_at_stmt / snap /
// break-continue / peak_live) + opaque u8 overlay thins.
// PLATFORM: SHARED freestanding 7.3.
// ---------------------------------------------------------------------------

// wave213: live control scalars (block emit / stack-spill gates).
let g_block_live_cfg_parent: i32 = 0;
let g_block_live_fwd_active: i32 = 0;
let g_block_emit_stmt_i: i32 = 0;
let g_asm73_linear_max_live_n: i32 = 0;
/* stage10 10.2.1 slice9: 1 after options(noreturn) asm — skip unreachable emit. */
let g_asm_block_diverged: i32 = 0;

// wave213: Chaitin interf graph (max 32 verts; undirected adj bitmasks as i32).
let g_asm73_interf_n: i32 = 0;
let g_asm73_interf_off: i32[32] = [];
let g_asm73_interf_adj: i32[32] = [];
// wave213: child-block push/pop stack (depth 8); flattened row-major d*32+i.
let g_asm73_interf_stack_depth: i32 = 0;
let g_asm73_interf_stack_n: i32[8] = [];
let g_asm73_interf_stack_off: i32[256] = [];
let g_asm73_interf_stack_adj: i32[256] = [];

// wave213: linear-scan / next-use context bind (opaque arena/ctx pointers).
let g_asm73_linear_arena: *u8 = 0 as *u8;
let g_asm73_linear_ctx: *u8 = 0 as *u8;
let g_asm73_linear_block_ref: i32 = 0;
let g_asm73_linear_slot_base: i32 = 0;
let g_asm73_linear_nconst: i32 = 0;
let g_asm73_linear_nlet: i32 = 0;
let g_asm73_linear_nso: i32 = 0;

/**
 * Return 1 when parent block has if/while/for (cfg forward live + stack spill gate).
 *
 * @return i32 — 0 or 1
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_cfg_parent_get(): i32 {
  return g_block_live_cfg_parent;
}

/**
 * Set cfg-parent flag (non-zero → 1).
 *
 * @param v i32 — 0 clear; non-zero set
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_cfg_parent_set(v: i32): void {
  if (v != 0) {
    g_block_live_cfg_parent = 1;
  } else {
    g_block_live_cfg_parent = 0;
  }
}

/**
 * Return 1 when global block live_fwd is actively maintained (forward path).
 *
 * @return i32 — 0 or 1
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_active_get(): i32 {
  return g_block_live_fwd_active;
}

/**
 * Set live_fwd active flag (non-zero → 1).
 *
 * @param v i32 — 0 clear; non-zero set
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_live_fwd_active_set(v: i32): void {
  if (v != 0) {
    g_block_live_fwd_active = 1;
  } else {
    g_block_live_fwd_active = 0;
  }
}

/**
 * Stamp current stmt_order index during block emit (final_expr uses nso).
 *
 * @param v i32 — stmt index
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_emit_stmt_i_set(v: i32): void {
  g_block_emit_stmt_i = v;
}

/**
 * Return current emit stmt_order index.
 *
 * @return i32 — stmt index
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_block_emit_stmt_i_get(): i32 {
  return g_block_emit_stmt_i;
}

/**
 * Stamp block-emit diverged flag (stage10 10.2.1 slice9).
 * Set by inline asm options(noreturn) after ud2; consumers skip trailing
 * stmt_order entries and final_expr until the next function body entry clears.
 * Slice11: if-stmt CFG join clears or ANDs arm flags (if-only → clear;
 * if/else → set only when both arms diverged).
 *
 * @param v i32 — non-zero ⇒ diverged
 * @return void
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_asm_block_diverged_set(v: i32): void {
  if (v != 0) {
    g_asm_block_diverged = 1;
  } else {
    g_asm_block_diverged = 0;
  }
}

/**
 * Return 1 when block emit should skip unreachable trailing code.
 *
 * @return i32 — 0 or 1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_asm_block_diverged_get(): i32 {
  return g_asm_block_diverged;
}

/**
 * Return linear-block peak |live| (pressure thresh + stack-spill gate).
 *
 * @return i32 — max |live_in|
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave174).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_max_live_n_get(): i32 {
  return g_asm73_linear_max_live_n;
}

/**
 * Set linear-block peak |live| (compute_linear_live_in resets then raises).
 *
 * @param n i32 — new max |live|
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_max_live_n_set(n: i32): void {
  g_asm73_linear_max_live_n = n;
}

/**
 * Raise linear max |live| when n is larger (pressure / Chaitin input).
 *
 * @param n i32 — candidate |live|
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_max_live_n_maybe_raise(n: i32): void {
  if (n > g_asm73_linear_max_live_n) {
    g_asm73_linear_max_live_n = n;
  }
}

/**
 * Pressure-evict |live| threshold from linear max (default 3; scales with max).
 *
 * @return i32 — thresh 3..8
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave166).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_pressure_live_thresh_get(): i32 {
  if (g_asm73_linear_max_live_n >= 12) {
    return 8;
  }
  if (g_asm73_linear_max_live_n >= 9) {
    return 7;
  }
  if (g_asm73_linear_max_live_n >= 8) {
    return 6;
  }
  if (g_asm73_linear_max_live_n >= 7) {
    return 5;
  }
  if (g_asm73_linear_max_live_n >= 6) {
    return 4;
  }
  return 3;
}

/**
 * Clear interference graph vertex count (edges left stale until rewritten).
 *
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave165).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_clear(): void {
  g_asm73_interf_n = 0;
}

/**
 * Current interference graph vertex count (0..32).
 *
 * @return i32 — n
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_n_get(): i32 {
  return g_asm73_interf_n;
}

/**
 * Stack-slot off for interf vertex i; -1 when OOB.
 *
 * @param i i32 — vertex index
 * @return i32 — stack off or -1
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_off_at(i: i32): i32 {
  if (i < 0 || i >= g_asm73_interf_n) {
    return 0 - 1;
  }
  return g_asm73_interf_off[i];
}

/**
 * Return 1 when undirected edge (i,j) exists in adj bitmasks.
 *
 * @param i i32 — vertex index
 * @param j i32 — vertex index
 * @return i32 — 1 edge; 0 absent/OOB
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_has_edge(i: i32, j: i32): i32 {
  if (i < 0 || j < 0 || i >= g_asm73_interf_n || j >= g_asm73_interf_n) {
    return 0;
  }
  if ((g_asm73_interf_adj[i] & (1 << j)) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Return or allocate vertex index for stack slot off; -1 if table full.
 *
 * @param off i32 — stack slot; <0 → -1
 * @return i32 — vertex index or -1
 *
 * wave213 pure private helper for add_live_set.
 * PLATFORM: SHARED freestanding 7.3.
 */
function w213_interf_index(off: i32): i32 {
  let i: i32 = 0;
  if (off < 0) {
    return 0 - 1;
  }
  while (i < g_asm73_interf_n) {
    if (g_asm73_interf_off[i] == off) {
      return i;
    }
    i = i + 1;
  }
  if (g_asm73_interf_n >= 32) {
    return 0 - 1;
  }
  i = g_asm73_interf_n;
  g_asm73_interf_off[i] = off;
  g_asm73_interf_adj[i] = 0;
  g_asm73_interf_n = g_asm73_interf_n + 1;
  return i;
}

/**
 * Add undirected interf edges for all pairs in opaque live set.
 * Uses residual live_fwd_n_get / off_at on Cap residual GlueBlockLiveFwd layout.
 *
 * @param live *u8 — GlueBlockLiveFwd* overlay; null → no-op
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_add_live_set_u8(live: *u8): void {
  let n: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  let off_i: i32 = 0;
  let off_j: i32 = 0;
  let ii: i32 = 0;
  let jj: i32 = 0;
  if (live == 0 as *u8) {
    return;
  }
  unsafe {
    n = glue_live_fwd_n_get(live);
  }
  while (i < n) {
    unsafe {
      off_i = glue_live_fwd_off_at(live, i);
    }
    ii = w213_interf_index(off_i);
    if (ii < 0) {
      return;
    }
    j = i + 1;
    while (j < n) {
      unsafe {
        off_j = glue_live_fwd_off_at(live, j);
      }
      jj = w213_interf_index(off_j);
      if (jj < 0) {
        return;
      }
      g_asm73_interf_adj[ii] = g_asm73_interf_adj[ii] | (1 << jj);
      g_asm73_interf_adj[jj] = g_asm73_interf_adj[jj] | (1 << ii);
      j = j + 1;
    }
    i = i + 1;
  }
}

/**
 * Add interf edges for precomputed live_at_stmt[stmt_i] (residual live_at BSS).
 *
 * @param stmt_i i32 — linear stmt index 0..31; OOB → no-op
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave165).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_add_live_at_stmt(stmt_i: i32): void {
  let live: *u8 = 0 as *u8;
  if (stmt_i < 0 || stmt_i >= 32) {
    return;
  }
  unsafe {
    live = glue_asm73_live_at_stmt_as_u8(stmt_i);
  }
  glue_asm73_interf_add_live_set_u8(live);
}

/**
 * Enter child-block cfg simulate: push parent interf graph and clear current.
 *
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave168).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_push(): void {
  let d: i32 = 0;
  let i: i32 = 0;
  let base: i32 = 0;
  if (g_asm73_interf_stack_depth >= 8) {
    return;
  }
  d = g_asm73_interf_stack_depth;
  g_asm73_interf_stack_n[d] = g_asm73_interf_n;
  base = d * 32;
  while (i < 32) {
    g_asm73_interf_stack_off[base + i] = g_asm73_interf_off[i];
    g_asm73_interf_stack_adj[base + i] = g_asm73_interf_adj[i];
    i = i + 1;
  }
  g_asm73_interf_stack_depth = g_asm73_interf_stack_depth + 1;
  glue_asm73_interf_clear();
}

/**
 * Exit child-block cfg simulate: merge child interf into saved parent graph.
 * Parent verts/edges live on stack[d]; child is current graph; result replaces current.
 *
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave168).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_interf_pop_merge(): void {
  let d: i32 = 0;
  let base: i32 = 0;
  let child_n: i32 = 0;
  let dn: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  let di: i32 = 0;
  let dj: i32 = 0;
  let k: i32 = 0;
  let found: i32 = 0;
  let map: i32[32] = [];
  let dst_off: i32[32] = [];
  let dst_adj: i32[32] = [];
  let src_off: i32 = 0;
  if (g_asm73_interf_stack_depth <= 0) {
    return;
  }
  g_asm73_interf_stack_depth = g_asm73_interf_stack_depth - 1;
  d = g_asm73_interf_stack_depth;
  base = d * 32;
  child_n = g_asm73_interf_n;
  dn = g_asm73_interf_stack_n[d];
  // Copy parent snapshot into working dst.
  while (i < 32) {
    dst_off[i] = g_asm73_interf_stack_off[base + i];
    dst_adj[i] = g_asm73_interf_stack_adj[base + i];
    i = i + 1;
  }
  // Map each child vertex into dst (by stack off). Full table mid-map aborts
  // edge merge (matches residual glue_asm73_interf_merge_into early return).
  i = 0;
  found = 1;
  while (i < child_n && found != 0) {
    src_off = g_asm73_interf_off[i];
    found = 0;
    j = 0;
    while (j < dn) {
      if (dst_off[j] == src_off) {
        map[i] = j;
        found = 1;
        j = dn;
      } else {
        j = j + 1;
      }
    }
    if (found == 0) {
      if (dn >= 32) {
        // Table full — leave found=0 to skip edge merge.
        found = 0;
        i = child_n;
      } else {
        dst_off[dn] = src_off;
        dst_adj[dn] = 0;
        map[i] = dn;
        dn = dn + 1;
        found = 1;
        i = i + 1;
      }
    } else {
      i = i + 1;
    }
  }
  // Merge undirected child edges only when every child vertex mapped.
  if (found != 0) {
    i = 0;
    while (i < child_n) {
      di = map[i];
      j = 0;
      while (j < child_n) {
        if ((g_asm73_interf_adj[i] & (1 << j)) != 0) {
          dj = map[j];
          dst_adj[di] = dst_adj[di] | (1 << dj);
          dst_adj[dj] = dst_adj[dj] | (1 << di);
        }
        j = j + 1;
      }
      i = i + 1;
    }
  }
  // Install merged graph as current.
  g_asm73_interf_n = dn;
  k = 0;
  while (k < 32) {
    g_asm73_interf_off[k] = dst_off[k];
    g_asm73_interf_adj[k] = dst_adj[k];
    k = k + 1;
  }
}

/**
 * Reset interf graph + stack depth + max-live + cfg peak before simulate.
 * Peak live array clear is residual (peak BSS still host-cc).
 *
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_interf_prepare(): void {
  glue_asm73_interf_clear();
  g_asm73_interf_stack_depth = 0;
  g_asm73_linear_max_live_n = 0;
  unsafe {
    glue_asm73_cfg_final_expr_use_n_set(0);
    glue_asm73_cfg_peak_clear();
  }
}

/**
 * Bind linear-scan / next-use context used by pure Chaitin after peak build.
 *
 * @param arena *u8 — AST arena (opaque)
 * @param ctx *u8 — AsmFuncCtx (opaque)
 * @param block_ref i32 — block pool ref
 * @param slot_base i32 — local slot base
 * @param nconst i32 — const count
 * @param nlet i32 — let count
 * @param nso i32 — stmt_order length
 * @return void
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave167).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_ctx_bind(arena: *u8, ctx: *u8, block_ref: i32, slot_base: i32, nconst: i32, nlet: i32, nso: i32): void {
  g_asm73_linear_arena = arena;
  g_asm73_linear_ctx = ctx;
  g_asm73_linear_block_ref = block_ref;
  g_asm73_linear_slot_base = slot_base;
  g_asm73_linear_nconst = nconst;
  g_asm73_linear_nlet = nlet;
  g_asm73_linear_nso = nso;
}

/**
 * Linear-scan bind: arena pointer (opaque).
 *
 * @return *u8 — arena or null
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_arena_get(): *u8 {
  return g_asm73_linear_arena;
}

/**
 * Linear-scan bind: AsmFuncCtx pointer (opaque).
 *
 * @return *u8 — ctx or null
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_ctx_get(): *u8 {
  return g_asm73_linear_ctx;
}

/**
 * Linear-scan bind: block_ref.
 *
 * @return i32 — block pool ref
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_block_ref_get(): i32 {
  return g_asm73_linear_block_ref;
}

/**
 * Linear-scan bind: local slot base.
 *
 * @return i32 — slot base
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_slot_base_get(): i32 {
  return g_asm73_linear_slot_base;
}

/**
 * Linear-scan bind: nconst.
 *
 * @return i32 — const count
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_nconst_get(): i32 {
  return g_asm73_linear_nconst;
}

/**
 * Linear-scan bind: nlet.
 *
 * @return i32 — let count
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave176).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_nlet_get(): i32 {
  return g_asm73_linear_nlet;
}

/**
 * Linear-scan bind: stmt_order length (nso).
 *
 * @return i32 — nso
 *
 * wave213 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_linear_nso_get(): i32 {
  return g_asm73_linear_nso;
}

// end wave213 pure-owned leave
