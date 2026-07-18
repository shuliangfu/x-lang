// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Dispatch thin gates + full entry + shux-c sibling (G.9 English; body is authoritative).
// Dispatch thin gates + full entry + shux-c sibling (G.9 English; body is authoritative).
// Dispatch thin gates + full entry + shux-c sibling (G.9 English; body is authoritative).
// Dispatch thin gates + full entry + shux-c sibling (G.9 English; body is authoritative).
// Dispatch thin gates + full entry + shux-c sibling (G.9 English; body is authoritative).

export extern "C" function driver_run_asm_backend_impl_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32, argv: *u8
): i32;
export extern "C" function driver_run_emit_c_path_impl_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8,
  opt_level: *u8, use_lto: i32, argc: i32, argv: *u8
): i32;
export extern "C" function driver_run_compiler_full_x_impl_c(argc: i32, argv: *u8): i32;
/* See signature and body for contracts. */
export extern "C" function driver_dispatch_sibling_try_spawn(argc: i32, argv: *u8): i32;

/* See signature and body for contracts. */
#[no_mangle]
export function driver_run_asm_backend_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32, argv: *u8
): i32 {
  unsafe {
    return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
  }
  return 0;
}

/* See signature and body for contracts. */
#[no_mangle]
export function driver_run_emit_c_path_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8,
  opt_level: *u8, use_lto: i32, argc: i32, argv: *u8
): i32 {
  unsafe {
    return driver_run_emit_c_path_impl_c(
      input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv
    );
  }
  return 0;
}

/**
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
 */
#[no_mangle]
export function driver_run_compiler_full(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full_x_impl_c(argc, argv);
  }
  return 0;
}

/**
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
 */
#[no_mangle]
export function driver_try_compile_via_shu_c_sibling(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_dispatch_sibling_try_spawn(argc, argv);
  }
  return 0 - 1;
}
