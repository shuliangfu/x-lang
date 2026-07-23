// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

extern "C" function getenv(name: *u8): *u8;

/* See implementation. */
export const SIMD_PATH_SCALAR: i32 = 0;
/* See implementation. */
export const SIMD_PATH_HW: i32 = 1;

/* See implementation. */
export const SIM_LIT_XLANG_SIMD_AUTOVEC: u8[19] = [88, 76, 65, 78, 71, 95, 83, 73, 77, 68, 95, 65, 85, 84, 111, 118, 101, 99, 0];
export const SIM_LIT_XLANG_SIMD_HW: u8[14] = [88, 76, 65, 78, 71, 95, 83, 73, 77, 68, 95, 72, 87, 0];

/** Exported function `simd_str_eq`.
 * Implements `simd_str_eq`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function simd_str_eq(a: *u8, b: *u8): i32 {
  let i: i32 = 0;
  let ca: u8 = 0;
  let cb: u8 = 0;
  if (a == 0 || b == 0) { return 0; }
  i = 0;
  while (1 != 0) {
    ca = a[i];
    cb = b[i];
    if (ca != cb) { return 0; }
    if (ca == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

/** Exported function `simd_env_force_scalar`.
 * Implements `simd_env_force_scalar`.
 * @return i32
 */
export function simd_env_force_scalar(): i32 {
  let hw: *u8 = 0;
  let aut: *u8 = 0;
  let lit0: u8[2] = [48, 0];
  let lit_scalar: u8[7] = [115, 99, 97, 108, 97, 114, 0];
  unsafe { hw = getenv(&SIM_LIT_XLANG_SIMD_HW[0]); }
  if (hw != 0 && hw[0] == 48 && hw[1] == 0) { return 1; }
  unsafe { aut = getenv(&SIM_LIT_XLANG_SIMD_AUTOVEC[0]); }
  if (aut == 0) { return 0; }
  if (simd_str_eq(aut, &lit_scalar[0]) != 0) { return 1; }
  if (simd_str_eq(aut, &lit0[0]) != 0) { return 1; }
  return 0;
}

/** Exported function `simd_env_force_hw`.
 * Implements `simd_env_force_hw`.
 * @return i32
 */
export function simd_env_force_hw(): i32 {
  let aut: *u8 = 0;
  let lit_hw: u8[3] = [104, 119, 0];
  let lit1: u8[2] = [49, 0];
  unsafe { aut = getenv(&SIM_LIT_XLANG_SIMD_AUTOVEC[0]); }
  if (aut == 0) { return 0; }
  if (simd_str_eq(aut, &lit_hw[0]) != 0) { return 1; }
  if (simd_str_eq(aut, &lit1[0]) != 0) { return 1; }
  return 0;
}

/** Exported function `simd_recommend_path_c`.
 * Implements `simd_recommend_path_c`.
 * @return i32
 */
export function simd_recommend_path_c(): i32 {
  if (simd_env_force_scalar() != 0) { return SIMD_PATH_SCALAR; }
  if (simd_env_force_hw() != 0) {
    if (simd_hw_available_c() != 0) { return SIMD_PATH_HW; }
    return SIMD_PATH_SCALAR;
  }
  if (simd_hw_available_c() != 0) { return SIMD_PATH_HW; }
  return SIMD_PATH_SCALAR;
}

/** Exported function `simd_f_zero_c_marker_c`.
 * Implements `simd_f_zero_c_marker_c`.
 * @return i32
 */
export function simd_f_zero_c_marker_c(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function simd_hw_available_c(): i32 {
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function simd_autovec_smoke_c(): i32 {
  let hw: i32 = 0;
  let path: i32 = 0;
  let hw_env: *u8 = 0;
  let aut_env: *u8 = 0;
  hw = simd_hw_available_c();
  path = simd_recommend_path_c();
  if (hw != 0 && path == SIMD_PATH_SCALAR && simd_env_force_scalar() == 0) {
    unsafe { hw_env = getenv(&SIM_LIT_XLANG_SIMD_HW[0]); }
    unsafe { aut_env = getenv(&SIM_LIT_XLANG_SIMD_AUTOVEC[0]); }
    if (hw_env == 0 && aut_env == 0) { return 1; }
  }
  if (hw == 0 && path != SIMD_PATH_SCALAR) { return 2; }
  return 0;
}
