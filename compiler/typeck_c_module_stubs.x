// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24： .x — typeck_module / typeck_one_function （ -1）。
// ：./xlang-c -E → seeds/typeck_c_module_stubs.from_x.c（ __attribute__((weak))）。
//  *u8  ASTModule** （C ABI ）。

/** Function `typeck_module`.
 * Purpose: implements `typeck_module`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_module(m: *u8, dep_mods: *u8, num_deps: i32, all_dep_mods: *u8, n_all_deps: i32): i32 {
  return -1;
}

/** Function `typeck_one_function`.
 * Purpose: implements `typeck_one_function`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_one_function(m: *u8, dep_mods: *u8, num_deps: i32, all_dep_mods: *u8, n_all_deps: i32,
                             only_func_index: i32): i32 {
  return -1;
}
