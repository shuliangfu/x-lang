// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.

export extern "C" function xlang_forward_main_to_main_entry(argc: i32, argv: *u8): i32;
export extern "C" function driver_skip_codegen_dep_0_get(): i32;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;

// See implementation.
// asm_driver_skip_codegen_dep_0_get: see function docblock below.

/** Exported function `asm_driver_skip_codegen_dep_0_get`.
 * Implements `asm_driver_skip_codegen_dep_0_get`.
 * @return i32
 */
#[no_mangle]
export function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

/** Exported function `asm_driver_set_current_dep_path_for_codegen`.
 * Implements `asm_driver_set_current_dep_path_for_codegen`.
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}
