// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Runtime asm stub helpers (G.9 English; body is authoritative).
// Runtime asm stub helpers (G.9 English; body is authoritative).
// Runtime asm stub helpers (G.9 English; body is authoritative).
// Runtime asm stub helpers (G.9 English; body is authoritative).
// Runtime asm stub helpers (G.9 English; body is authoritative).
// Runtime asm stub helpers (G.9 English; body is authoritative).

export extern "C" function shux_output_want_exe(path: *u8): i32;
export extern "C" function driver_asm_stub_gas_line_at(i: i32): *u8;
export extern "C" function driver_asm_stub_gas_line_count(): i32;
export extern "C" function driver_asm_stub_out_append_cstr(out: *u8, s: *u8): i32;

/** Exported function `driver_asm_output_want_exe`.
 * Implements `driver_asm_output_want_exe`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_asm_output_want_exe(path: *u8): i32 {
  unsafe {
    return shux_output_want_exe(path);
  }
  return 0;
}

/**
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
 */
#[no_mangle]
export function asm_codegen_ast(module: *u8, arena: *u8, out: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  if (out == 0 as *u8) {
    return 0 - 1;
  }
  // silence unused (cold C also voids them)
  if (module == 0 as *u8) {
    // no-op: keep signature isomorphic with seed
  }
  if (arena == 0 as *u8) {
    // no-op
  }
  unsafe {
    n = driver_asm_stub_gas_line_count();
  }
  while (i < n) {
    let line: *u8 = 0 as *u8;
    let rc: i32 = 0;
    unsafe {
      line = driver_asm_stub_gas_line_at(i);
      rc = driver_asm_stub_out_append_cstr(out, line);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    i = i + 1;
  }
  return 0;
}
