// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

let g_driver_pending_target_cpu_features: u32 = 0;

/** Exported function `driver_set_pending_target_cpu_features`.
 * Implements `driver_set_pending_target_cpu_features`.
 * @param features u32
 * @return void
 */
#[no_mangle]
export function driver_set_pending_target_cpu_features(features: u32): void {
  g_driver_pending_target_cpu_features = features;
}

/** Exported function `driver_get_pending_target_cpu_features`.
 * Implements `driver_get_pending_target_cpu_features`.
 * @return u32
 */
#[no_mangle]
export function driver_get_pending_target_cpu_features(): u32 {
  return g_driver_pending_target_cpu_features;
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
  if (tcp_tolower(name[0]) != a0) {
    return 0;
  }
  if (tcp_tolower(name[1]) != a1) {
    return 0;
  }
  if (tcp_tolower(name[2]) != a2) {
    return 0;
  }
  if (tcp_tolower(name[3]) != a3) {
    return 0;
  }
  if (tcp_tolower(name[4]) != a4) {
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
  if (tcp_eq5(name, a0, a1, a2, a3, a4) == 0) {
    return 0;
  }
  if (tcp_tolower(name[5]) != a5) {
    return 0;
  }
  return 1;
}
