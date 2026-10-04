// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Allow-legacy-extern flag for typeck. The cold seed
// compiler/seeds/typeck_allow_legacy.from_x.c keeps the same contract:
// the flag starts at 0, set stores 0 or 1 and returns the previous value,
// get returns the current value. This file is the product body so the
// link does not pull typeck_cap_residual.o (that object also defines the
// typeck scratch slots already provided elsewhere).
// PLATFORM: SHARED — link names stay the source names via #[no_mangle].

/** Previous allow-legacy value. 0 means extern calls stay in an unsafe block. */
let g_typeck_allow_legacy_extern_calls: i32 = 0;

/**
 * Store whether typeck accepts an extern call outside unsafe.
 * Params: allow — nonzero becomes 1, zero becomes 0.
 * Returns: the flag value before this call.
 * Contracts: the stored value is only 0 or 1. Default before any set is 0.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_set_allow_legacy_extern_calls(allow: i32): i32 {
  let old: i32 = g_typeck_allow_legacy_extern_calls;
  if (allow != 0) {
    g_typeck_allow_legacy_extern_calls = 1;
  } else {
    g_typeck_allow_legacy_extern_calls = 0;
  }
  return old;
}

/**
 * Read whether typeck accepts an extern call outside unsafe.
 * Returns: 0 or 1. 0 until the first successful set of a nonzero allow.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_get_allow_legacy_extern_calls(): i32 {
  return g_typeck_allow_legacy_extern_calls;
}
