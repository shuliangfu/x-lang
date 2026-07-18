// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-309/443 / P2 runtime rest → R2 full: static arena/module buffers.
// .x owns driver_arena_buf / driver_module_buf (memset + num_types clear).
// Product PREFER_X_O: full .x + rest under FROM_X has business T=0 (marker + BSS data).
// Cap-global-bss residual: 128MiB/2MiB arrays live in rest seed; slot API in driver_abi
// (.x export let becomes static; cannot export large arrays across TUs).

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
