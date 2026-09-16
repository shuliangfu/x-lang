// Thin pure: wave212 Chaitin color/pin BSS + accessors.
// G.7: bodies MUST match mega runtime_pipeline_abi.x wave212 leave.
// ensure injects via inject_thin_leaf (PREFER_ASM).
// stack_spill_enabled calls wave213 getters (leftover); wrap unsafe.
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS.

/** wave213: cfg parent flag (0 = linear path). */
export extern function glue_block_live_cfg_parent_get(): i32;
/** wave213: linear-scan max live count for stack-spill gate. */
export extern function glue_asm73_linear_max_live_n_get(): i32;

// ---------------------------------------------------------------------------
// wave212: Chaitin color/pin BSS + thin accessors pure leave
// ---------------------------------------------------------------------------
// G.7 single authority for spill preference maps (was Cap residual spill.c).
// Pure-owned BSS: pin[6] + color_off/which[16] + color_n + cfg_coloring_active
// + cfg_final_expr_use_n. wave213 pure owns cfg_parent + linear_max_live_n
// (stack_spill_enabled reads pure BSS). Live set arrays still Cap residual.
// PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path (x10–x15).
// ---------------------------------------------------------------------------

// wave212: pin spill homes (which 0..5 → x10–x15); -1 = empty.
let g_asm73_pin_spill_off: i32[6] = [];
// wave212: Chaitin color map (stack off → which 0..5 or 6=stack frame); cap 16.
let g_asm73_spill_color_off: i32[16] = [];
let g_asm73_spill_color_which: i32[16] = [];
let g_asm73_spill_color_n: i32 = 0;
// wave212: 1 while cfg parent is coloring (next-use uses forward scan).
let g_asm73_cfg_coloring_active: i32 = 0;
// wave212: final_expr direct VAR-slot use count (cfg stack-spill gate ≥12).
let g_asm73_cfg_final_expr_use_n: i32 = 0;

/**
 * Clear all six pin spill homes to -1 (block entry / before Chaitin pin pick).
 *
 * @return void
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_pin_spill_off_clear_all(): void {
  g_asm73_pin_spill_off[0] = 0 - 1;
  g_asm73_pin_spill_off[1] = 0 - 1;
  g_asm73_pin_spill_off[2] = 0 - 1;
  g_asm73_pin_spill_off[3] = 0 - 1;
  g_asm73_pin_spill_off[4] = 0 - 1;
  g_asm73_pin_spill_off[5] = 0 - 1;
}

/**
 * Set pin spill home which (0=x10 … 5=x15) to stack off (-1 clears).
 *
 * @param which i32 — physical spill color 0..5; OOB → no-op
 * @param off i32 — stack slot off or -1
 * @return void
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_pin_spill_off_set(which: i32, off: i32): void {
  if (which < 0 || which > 5) {
    return;
  }
  g_asm73_pin_spill_off[which] = off;
}

/**
 * Return 1 when stack slot off is a current-block spill pin
 * (closer next-use; prefer not to overwrite with a farther slot).
 *
 * @param off i32 — stack slot; <0 → 0
 * @return i32 — 1 pin; 0 not pin
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave175).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_off_is_spill_pin(off: i32): i32 {
  if (off < 0) {
    return 0;
  }
  if (off == g_asm73_pin_spill_off[0]) {
    return 1;
  }
  if (off == g_asm73_pin_spill_off[1]) {
    return 1;
  }
  if (off == g_asm73_pin_spill_off[2]) {
    return 1;
  }
  if (off == g_asm73_pin_spill_off[3]) {
    return 1;
  }
  if (off == g_asm73_pin_spill_off[4]) {
    return 1;
  }
  if (off == g_asm73_pin_spill_off[5]) {
    return 1;
  }
  return 0;
}

/**
 * Clear this block's spill color map (n = 0; offs/which left stale).
 *
 * @return void
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_clear_spill_color_map(): void {
  g_asm73_spill_color_n = 0;
}

/**
 * Record spill preference for stack slot off (0=x10 … 5=x15, 6=stack frame).
 * Updates existing entry or appends when n < 16.
 *
 * @param off i32 — stack slot; <0 → no-op
 * @param which i32 — color 0..6; OOB → no-op
 * @return void
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_set_spill_color(off: i32, which: i32): void {
  let i: i32 = 0;
  // SPILL_WHICH_STACK = 6 (index_helpers / residual define)
  if (off < 0 || which < 0 || which > 6) {
    return;
  }
  while (i < g_asm73_spill_color_n) {
    if (g_asm73_spill_color_off[i] == off) {
      g_asm73_spill_color_which[i] = which;
      return;
    }
    i = i + 1;
  }
  if (g_asm73_spill_color_n >= 16) {
    return;
  }
  g_asm73_spill_color_off[g_asm73_spill_color_n] = off;
  g_asm73_spill_color_which[g_asm73_spill_color_n] = which;
  g_asm73_spill_color_n = g_asm73_spill_color_n + 1;
}

/**
 * Return preferred spill color for stack slot off; -1 if uncolored.
 *
 * @param off i32 — stack slot; <0 → -1
 * @return i32 — which 0..6 or -1
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave164).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_off_spill_color_which(off: i32): i32 {
  let i: i32 = 0;
  if (off < 0) {
    return 0 - 1;
  }
  while (i < g_asm73_spill_color_n) {
    if (g_asm73_spill_color_off[i] == off) {
      return g_asm73_spill_color_which[i];
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Return 1 when cfg parent coloring is active (forward next-use path).
 *
 * @return i32 — 0 or 1
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_coloring_active_get(): i32 {
  return g_asm73_cfg_coloring_active;
}

/**
 * Set cfg coloring active flag (0/1).
 *
 * @param v i32 — non-zero → 1; zero → 0
 * @return void
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave153).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_coloring_active_set(v: i32): void {
  if (v != 0) {
    g_asm73_cfg_coloring_active = 1;
  } else {
    g_asm73_cfg_coloring_active = 0;
  }
}

/**
 * Set final_expr direct VAR-slot use count (cfg stack-spill gate input).
 *
 * @param n i32 — use count from collect_expr_uses
 * @return void
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave168).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_cfg_final_expr_use_n_set(n: i32): void {
  g_asm73_cfg_final_expr_use_n = n;
}

/**
 * Whether stack-frame spill (which=6) is enabled for this block.
 * Linear: |live|max ≥ 15; cfg parent: final_expr VAR uses ≥ 12.
 * wave213: cfg_parent + linear_max_live_n are pure BSS (same TU).
 *
 * @return i32 — 1 enabled; 0 disabled
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave174).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_stack_spill_enabled(): i32 {
  let parent: i32 = 0;
  let max_n: i32 = 0;
  unsafe {
    parent = glue_block_live_cfg_parent_get();
  }
  if (parent != 0) {
    if (g_asm73_cfg_final_expr_use_n >= 12) {
      return 1;
    }
    return 0;
  }
  unsafe {
    max_n = glue_asm73_linear_max_live_n_get();
  }
  if (max_n >= 15) {
    return 1;
  }
  return 0;
}

/**
 * Return 1 when off is colored which=6 and stack-frame spill is enabled.
 *
 * @param off i32 — stack slot; <0 → 0
 * @return i32 — 1 prefers real stack spill home; 0 otherwise
 *
 * wave212 pure: G.7 authority (was Cap residual spill wave149).
 * PLATFORM: SHARED freestanding 7.3.
 */
#[no_mangle]
export function glue_asm73_var_prefers_stack_spill(off: i32): i32 {
  let en: i32 = 0;
  let which: i32 = 0;
  if (off < 0) {
    return 0;
  }
  en = glue_asm73_stack_spill_enabled();
  if (en == 0) {
    return 0;
  }
  which = glue_asm73_off_spill_color_which(off);
  // SPILL_WHICH_STACK = 6
  if (which == 6) {
    return 1;
  }
  return 0;
}

// end wave212 pure-owned leave
