// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-309/443 / P2 runtime rest → R2 full: static arena/module buffers.
// w844: driver_arena_buf and driver_module_buf live only in this file.
// w858: labi_rt_arena_buf_slice_marker lives here too. It returns 1.
// Their C twins were deleted from seeds/rt_arena_buf.from_x.c. The product
// installer pure-asm's this file, then cc's the seed for the 128MiB arena
// array and the 2MiB module array only. There is no full-seed fallback and
// XLANG_G05_PREFER_X_O is ignored. Windows takes the same path.
// Do not gcc -E this TU. Product PREFER_X_O temps must not replace this .o.
// The .x calls libc memset; the deleted full-cc body was lowered to bzero.
// Cap-global-bss residual: the arrays stay in the seed. Slot API is in
// driver_abi. An export let lowers to static and cannot publish the arrays.

export extern "C" function driver_arena_static_slot(): *u8;
export extern "C" function driver_module_static_slot(): *u8;
export extern "C" function driver_arena_static_size(): usize;
export extern "C" function driver_module_static_size(): usize;
export extern "C" function pipeline_arena_offset_num_types(): usize;
export extern "C" function memset(p: *u8, c: i32, n: usize): *u8;

/**
 * Zero and return the static arena buffer (>= pipeline_sizeof_arena; host 128MiB).
 * Params: none (uses residual static slot + size).
 * Returns: *u8 to zeroed arena, or null if slot unavailable.
 * Contracts: after memset, also force num_types=0 at pipeline offset (LE i32 four bytes)
 * so type_alloc does not mis-read if .x layout drifts from C.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — slot residual in driver_abi.
 */
#[no_mangle]
export function driver_arena_buf(): *u8 {
  let p: *u8 = 0 as *u8;
  let sz: usize = 0 as usize;
  let off: usize = 0 as usize;
  unsafe {
    p = driver_arena_static_slot();
    sz = driver_arena_static_size();
  }
  if (p == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    memset(p, 0, sz);
    off = pipeline_arena_offset_num_types();
  }
  // Force num_types=0 (little-endian i32 write of 0) so type_alloc cannot mis-read.
  if (off + 4 as usize <= sz) {
    p[off] = 0;
    p[off + 1 as usize] = 0;
    p[off + 2 as usize] = 0;
    p[off + 3 as usize] = 0;
  }
  return p;
}

/**
 * Zero and return the static module buffer (host 2MiB).
 * Params: none (uses residual static slot + size).
 * Returns: *u8 to zeroed module buffer, or null if slot unavailable.
 * Contracts: full memset of residual size; no field-level fixups.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — slot residual in driver_abi.
 */
#[no_mangle]
export function driver_module_buf(): *u8 {
  let p: *u8 = 0 as *u8;
  let sz: usize = 0 as usize;
  unsafe {
    p = driver_module_static_slot();
    sz = driver_module_static_size();
  }
  if (p == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    memset(p, 0, sz);
  }
  return p;
}

/**
 * Slice presence marker for this translation unit.
 * Returns 1, the same value the former host-cc marker returned.
 * No product caller reads it. The ensure nm gate only checks the symbol exists.
 * @return i32 — always 1
 * PLATFORM: SHARED — pure asm. The 128MiB and 2MiB arrays stay in the C seed.
 */
#[no_mangle]
export function labi_rt_arena_buf_slice_marker(): i32 {
  return 1;
}
