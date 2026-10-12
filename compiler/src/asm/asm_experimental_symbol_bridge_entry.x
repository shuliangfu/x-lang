// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// asm_experimental_symbol_bridge_entry: the weak `entry` of
// asm_experimental_symbol_bridge, split out because a TU that defines
// `entry` is compiled in entry-module mode (only entry is emitted).
// w1520 (5.8c): g05 builds this with product pure asm (G05_X_O_WEAK_FUNCS
// = entry) and merges it with asm_experimental_symbol_bridge.x via ld -r
// into build_asm/asm_experimental_symbol_bridge.o.
// main.o strong entry wins when linked; else route to runtime run_compiler_c.
// PLATFORM: MACOS arm64 (product); the file itself is target-neutral.

export extern "C" function run_compiler_c(argc: i32, argv: *u8): i32;

/**
 * Weak entry: forwards to run_compiler_c(argc, argv).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function entry(argc: i32, argv: *u8): i32 {
  unsafe {
    return run_compiler_c(argc, argv);
  }
}
