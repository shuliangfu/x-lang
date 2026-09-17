// Thin pure: wave210 binop VAR slot cache BSS + accessors.
// G.7: bodies MUST match mega runtime_pipeline_abi.x wave210 leave.
// ensure injects via inject_thin_leaf (PREFER_ASM).
// Unblocked after COMMON + reloc_r_type accessors (file-level let → COMMON).
// wave404: HARD BAN tip reinject both ends — standalone -c PREFER green
//   but product inject Darwin ARM64_RELOC_BRANCH26 / Ubuntu L2 SEGV.
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS.

/** Drop matching frame off from pure stack_spill table (wave208; leftover). */
export extern function glue_binop_stack_spill_drop_off(off: i32): void;

// ===========================================================================
// wave210: binop VAR slot cache BSS + thin accessors pure leave
// (was Cap residual pipeline_asm_emit_spill.c GlueBinopVarSlotCache)
// G.7 product authority for freestanding 7.3 dual-slot + arm64 x10–x15 spill
// homes:
//   glue_binop_var_slot_cache_{clear,invalidate_rax,invalidate_rbx,
//     invalidate_slot,kill_def_at_slot,ctx_matches,hit_rax,hit_rbx,
//     valid_rax|rbx_get,rax|rbx_off_get,set_ctx_key,set_rax,set_rbx,
//     set_valid_rax|rbx,set_rax|rbx_off,set_spill_slot,
//     valid_x10..x15_get,x10..x15_off_get,set_valid_x10..x15}
// Pure-owned BSS: flattened valid/ctx/off fields for rax/rbx + x10–x15.
// Consumers: pure binop leave (wave149+) + pure try_reload (wave211) /
//   cfg_merge clear / color stamp. stack_spill_drop_off pure wave208.
// Seed cold twins under FROM_X. Deferred: color/interf BSS / live_fwd BSS /
//   for_call_args mega / pipeline_x mega.
// PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path for x10–x15.
// ===========================================================================

// wave210: rax/rbx dual-slot VAR cache (block-level; skip re-ldur).
let g_var_cache_valid_rax: i32 = 0;
let g_var_cache_valid_rbx: i32 = 0;
let g_var_cache_ctx: *u8 = 0 as *u8;
let g_var_cache_rax_off: i32 = 0;
let g_var_cache_rbx_off: i32 = 0;

// wave210: arm64 linear-scan spill homes x10–x15 (which 0..5).
let g_var_cache_valid_x10: i32 = 0;
let g_var_cache_valid_x11: i32 = 0;
let g_var_cache_valid_x12: i32 = 0;
let g_var_cache_valid_x13: i32 = 0;
let g_var_cache_valid_x14: i32 = 0;
let g_var_cache_valid_x15: i32 = 0;
let g_var_cache_x10_off: i32 = 0;
let g_var_cache_x11_off: i32 = 0;
let g_var_cache_x12_off: i32 = 0;
let g_var_cache_x13_off: i32 = 0;
let g_var_cache_x14_off: i32 = 0;
let g_var_cache_x15_off: i32 = 0;

/**
 * Clear binop VAR slot cache (block entry / slow binop / bitwise rbx write).
 *
 * Contract: zeros all valid_* flags only; offs/ctx left stale until next set.
 *
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_clear(): void {
  g_var_cache_valid_rax = 0;
  g_var_cache_valid_rbx = 0;
  g_var_cache_valid_x10 = 0;
  g_var_cache_valid_x11 = 0;
  g_var_cache_valid_x12 = 0;
  g_var_cache_valid_x13 = 0;
  g_var_cache_valid_x14 = 0;
  g_var_cache_valid_x15 = 0;
}

/**
 * Invalidate rax home only (binary result landed in rax; rbx may keep right VAR).
 *
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill wave149).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_invalidate_rax(): void {
  g_var_cache_valid_rax = 0;
}

/**
 * Invalidate rbx home (rbx about to hold non-VAR operand e.g. literal).
 *
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill wave137).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_invalidate_rbx(): void {
  g_var_cache_valid_rbx = 0;
}

/**
 * Return 1 when cache ctx pointer matches AsmFuncCtx*.
 *
 * @param ctx *u8 — AsmFuncCtx*; null → 0
 * @return i32 — 1 match; 0 miss/null
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_ctx_matches(ctx: *u8): i32 {
  if (ctx == (0 as *u8)) {
    return 0;
  }
  if (g_var_cache_ctx != ctx) {
    return 0;
  }
  return 1;
}

/**
 * Return 1 when rax home is valid for ctx and stack-slot off.
 *
 * @param ctx *u8 — AsmFuncCtx*
 * @param off i32 — stack frame slot offset
 * @return i32 — 1 hit; 0 miss
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_hit_rax(ctx: *u8, off: i32): i32 {
  if (g_var_cache_valid_rax == 0) {
    return 0;
  }
  if (g_var_cache_ctx != ctx) {
    return 0;
  }
  if (g_var_cache_rax_off != off) {
    return 0;
  }
  return 1;
}

/**
 * Return 1 when rbx home is valid for ctx and stack-slot off.
 *
 * @param ctx *u8 — AsmFuncCtx*
 * @param off i32 — stack frame slot offset
 * @return i32 — 1 hit; 0 miss
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_hit_rbx(ctx: *u8, off: i32): i32 {
  if (g_var_cache_valid_rbx == 0) {
    return 0;
  }
  if (g_var_cache_ctx != ctx) {
    return 0;
  }
  if (g_var_cache_rbx_off != off) {
    return 0;
  }
  return 1;
}

/**
 * rax home valid flag.
 * @return i32 — 1 valid; 0 clear
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_rax_get(): i32 {
  return g_var_cache_valid_rax;
}

/**
 * rbx home valid flag.
 * @return i32 — 1 valid; 0 clear
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_rbx_get(): i32 {
  return g_var_cache_valid_rbx;
}

/**
 * Stack-slot off currently cached in rax.
 * @return i32 — frame off (stale when valid_rax==0)
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_rax_off_get(): i32 {
  return g_var_cache_rax_off;
}

/**
 * Stack-slot off currently cached in rbx.
 * @return i32 — frame off (stale when valid_rbx==0)
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_rbx_off_get(): i32 {
  return g_var_cache_rbx_off;
}

/**
 * Stamp cache ctx pointer only (no valid change).
 *
 * @param ctx *u8 — AsmFuncCtx*
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_ctx_key(ctx: *u8): void {
  g_var_cache_ctx = ctx;
}

/**
 * Stamp rax home: valid=1, off, and ctx.
 *
 * @param ctx *u8 — AsmFuncCtx*
 * @param off i32 — stack frame slot offset
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_rax(ctx: *u8, off: i32): void {
  g_var_cache_ctx = ctx;
  g_var_cache_valid_rax = 1;
  g_var_cache_rax_off = off;
}

/**
 * Stamp rbx home: valid=1, off, and ctx.
 *
 * @param ctx *u8 — AsmFuncCtx*
 * @param off i32 — stack frame slot offset
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_rbx(ctx: *u8, off: i32): void {
  g_var_cache_ctx = ctx;
  g_var_cache_valid_rbx = 1;
  g_var_cache_rbx_off = off;
}

/**
 * Set rax valid flag only (off/ctx unchanged).
 * @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_rax(v: i32): void {
  g_var_cache_valid_rax = v;
}

/**
 * Set rbx valid flag only (off/ctx unchanged).
 * @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_rbx(v: i32): void {
  g_var_cache_valid_rbx = v;
}

/**
 * Set rax_off only (valid/ctx unchanged).
 * @param off i32 — stack frame slot offset
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_rax_off(off: i32): void {
  g_var_cache_rax_off = off;
}

/**
 * Set rbx_off only (valid/ctx unchanged).
 * @param off i32 — stack frame slot offset
 * wave210 pure. PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_rbx_off(off: i32): void {
  g_var_cache_rbx_off = off;
}

/**
 * Invalidate any home (rax/rbx/x10–x15) that holds stack-slot off.
 *
 * Also drops off from pure stack_spill table (wave208 drop_off). Used after
 * stores to that slot so cached register values are not reused.
 *
 * @param off i32 — stack frame slot offset
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3 · stack_spill pure wave208.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_invalidate_slot(off: i32): void {
  if (g_var_cache_valid_rax != 0 && g_var_cache_rax_off == off) {
    g_var_cache_valid_rax = 0;
  }
  if (g_var_cache_valid_rbx != 0 && g_var_cache_rbx_off == off) {
    g_var_cache_valid_rbx = 0;
  }
  if (g_var_cache_valid_x10 != 0 && g_var_cache_x10_off == off) {
    g_var_cache_valid_x10 = 0;
  }
  if (g_var_cache_valid_x11 != 0 && g_var_cache_x11_off == off) {
    g_var_cache_valid_x11 = 0;
  }
  if (g_var_cache_valid_x12 != 0 && g_var_cache_x12_off == off) {
    g_var_cache_valid_x12 = 0;
  }
  if (g_var_cache_valid_x13 != 0 && g_var_cache_x13_off == off) {
    g_var_cache_valid_x13 = 0;
  }
  if (g_var_cache_valid_x14 != 0 && g_var_cache_x14_off == off) {
    g_var_cache_valid_x14 = 0;
  }
  if (g_var_cache_valid_x15 != 0 && g_var_cache_x15_off == off) {
    g_var_cache_valid_x15 = 0;
  }
  // Pure stack_spill table (wave208): drop matching frame off.
  unsafe {
    glue_binop_stack_spill_drop_off(off);
  }
}

/**
 * Definition-point kill: invalidate_slot(off) then invalidate_rax.
 *
 * Used after let/assign writes a stack slot (result already stored; rax stale).
 *
 * @param off i32 — stack frame slot; off < 0 skips slot invalidate only
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void {
  if (off >= 0) {
    glue_binop_var_slot_cache_invalidate_slot(off);
  }
  glue_binop_var_slot_cache_invalidate_rax();
}

/**
 * Stamp physical spill home which (0=x10 … 5=x15) after enc mov rax/rbx → xN.
 *
 * @param which i32 — 0..5; OOB → no-op
 * @param off i32 — stack-slot off held in that spill home
 * @return void
 *
 * wave210 pure: G.7 authority (was Cap residual spill wave175).
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_spill_slot(which: i32, off: i32): void {
  if (which == 0) {
    g_var_cache_valid_x10 = 1;
    g_var_cache_x10_off = off;
    return;
  }
  if (which == 1) {
    g_var_cache_valid_x11 = 1;
    g_var_cache_x11_off = off;
    return;
  }
  if (which == 2) {
    g_var_cache_valid_x12 = 1;
    g_var_cache_x12_off = off;
    return;
  }
  if (which == 3) {
    g_var_cache_valid_x13 = 1;
    g_var_cache_x13_off = off;
    return;
  }
  if (which == 4) {
    g_var_cache_valid_x14 = 1;
    g_var_cache_x14_off = off;
    return;
  }
  if (which == 5) {
    g_var_cache_valid_x15 = 1;
    g_var_cache_x15_off = off;
  }
}

/**
 * x10 home valid flag. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_x10_get(): i32 {
  return g_var_cache_valid_x10;
}

/**
 * x11 home valid flag. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_x11_get(): i32 {
  return g_var_cache_valid_x11;
}

/**
 * x12 home valid flag. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_x12_get(): i32 {
  return g_var_cache_valid_x12;
}

/**
 * x13 home valid flag. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_x13_get(): i32 {
  return g_var_cache_valid_x13;
}

/**
 * x14 home valid flag. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_x14_get(): i32 {
  return g_var_cache_valid_x14;
}

/**
 * x15 home valid flag. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_valid_x15_get(): i32 {
  return g_var_cache_valid_x15;
}

/**
 * x10 cached stack off. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_x10_off_get(): i32 {
  return g_var_cache_x10_off;
}

/**
 * x11 cached stack off. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_x11_off_get(): i32 {
  return g_var_cache_x11_off;
}

/**
 * x12 cached stack off. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_x12_off_get(): i32 {
  return g_var_cache_x12_off;
}

/**
 * x13 cached stack off. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_x13_off_get(): i32 {
  return g_var_cache_x13_off;
}

/**
 * x14 cached stack off. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_x14_off_get(): i32 {
  return g_var_cache_x14_off;
}

/**
 * x15 cached stack off. wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_x15_off_get(): i32 {
  return g_var_cache_x15_off;
}

/**
 * Set x10 valid flag only. @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_x10(v: i32): void {
  g_var_cache_valid_x10 = v;
}

/**
 * Set x11 valid flag only. @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_x11(v: i32): void {
  g_var_cache_valid_x11 = v;
}

/**
 * Set x12 valid flag only. @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_x12(v: i32): void {
  g_var_cache_valid_x12 = v;
}

/**
 * Set x13 valid flag only. @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_x13(v: i32): void {
  g_var_cache_valid_x13 = v;
}

/**
 * Set x14 valid flag only. @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_x14(v: i32): void {
  g_var_cache_valid_x14 = v;
}

/**
 * Set x15 valid flag only. @param v i32 — non-zero → valid
 * wave210 pure. PLATFORM: SHARED · MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_var_slot_cache_set_valid_x15(v: i32): void {
  g_var_cache_valid_x15 = v;
}

// end wave210 pure-owned leave

