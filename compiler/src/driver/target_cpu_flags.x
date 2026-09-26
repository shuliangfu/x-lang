// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// w1138: the pending-feature word is stored through a pointer slot.
// A direct store to the file-level let does not emit (elf_ec=-1).
// PLATFORM: SHARED.

let g_driver_pending_target_cpu_features: u32 = 0;

/** Exported function `driver_set_pending_target_cpu_features`.
 * Implements `driver_set_pending_target_cpu_features`.
 * @param features u32
 * @return void
 */
#[no_mangle]
export function driver_set_pending_target_cpu_features(features: u32): void {
  let slot: *u32 = &g_driver_pending_target_cpu_features;
  slot[0] = features;
}

/** Exported function `driver_get_pending_target_cpu_features`.
 * Implements `driver_get_pending_target_cpu_features`.
 * @return u32
 */
#[no_mangle]
export function driver_get_pending_target_cpu_features(): u32 {
  let slot: *u32 = &g_driver_pending_target_cpu_features;
  return slot[0];
}

/** Exported function `tcp_tolower`.
 * Implements `tcp_tolower`.
 * @param c u8
 * @return u8
 */
#[no_mangle]
export function tcp_tolower(c: u8): u8 {
  if (c >= 65 && c <= 90) {
    return (c + 32) as u8;
  }
  return c;
}

/** Exported function `tcp_eq5`.
 * Implements `tcp_eq5`.
 * @param name *u8
 * @param a0 u8
 * @param a1 u8
 * @param a2 u8
 * @param a3 u8
 * @param a4 u8
 * @return i32
 */
#[no_mangle]
export function tcp_eq5(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  let s: *u8 = name;
  if (tcp_tolower(s[0]) != a0) {
    return 0;
  }
  if (tcp_tolower(s[1]) != a1) {
    return 0;
  }
  if (tcp_tolower(s[2]) != a2) {
    return 0;
  }
  if (tcp_tolower(s[3]) != a3) {
    return 0;
  }
  if (tcp_tolower(s[4]) != a4) {
    return 0;
  }
  return 1;
}

/** Exported function `tcp_eq6`.
 * Implements `tcp_eq6`.
 * @param name *u8
 * @param a0 u8
 * @param a1 u8
 * @param a2 u8
 * @param a3 u8
 * @param a4 u8
 * @param a5 u8
 * @return i32
 */
#[no_mangle]
export function tcp_eq6(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  let s: *u8 = name;
  if (tcp_eq5(s, a0, a1, a2, a3, a4) == 0) {
    return 0;
  }
  if (tcp_tolower(s[5]) != a5) {
    return 0;
  }
  return 1;
}
