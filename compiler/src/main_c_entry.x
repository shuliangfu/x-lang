// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

export extern "C" function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32;

#[no_mangle]
/** Exported function `main`.
 * Program/test entry point.
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
export function main(argc: i32, argv: *u8): i32 {
  unsafe {
    let r: i32 = shux_forward_main_to_main_entry(argc, argv);
    return r;
  }
  return 0;
}
