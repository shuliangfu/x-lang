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
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.

extern function simd_hw_available_c(): i32;
extern function simd_recommend_path_c(): i32;

/** Exported function `SIMD_PATH_SCALAR`.
 * Implements `SIMD_PATH_SCALAR`.
 * @return i32
 */
export function SIMD_PATH_SCALAR(): i32 { return 0; }
/** Exported function `SIMD_PATH_HW`.
 * Implements `SIMD_PATH_HW`.
 * @return i32
 */
export function SIMD_PATH_HW(): i32 { return 1; }

/** Exported function `hw_available`.
 * Implements `hw_available`.
 * @return i32
 */
export function hw_available(): i32 {
  unsafe { return simd_hw_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `recommend_path`.
 * Implements `recommend_path`.
 * @return i32
 */
export function recommend_path(): i32 {
  unsafe { return simd_recommend_path_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `add`.
 * Implements `add`.
 * @param a Vec8i
 * @param b Vec8i
 * @return Vec8i
 */
export function add(a: Vec8i, b: Vec8i): Vec8i {
  return a + b;
}

/** Exported function `sub`.
 * Implements `sub`.
 * @param a Vec8i
 * @param b Vec8i
 * @return Vec8i
 */
export function sub(a: Vec8i, b: Vec8i): Vec8i {
  return a - b;
}

/** Exported function `mul`.
 * Implements `mul`.
 * @param a Vec8i
 * @param b Vec8i
 * @return Vec8i
 */
export function mul(a: Vec8i, b: Vec8i): Vec8i {
  return a * b;
}

/** Exported function `splat`.
 * Implements `splat`.
 * @param x i32
 * @return Vec8i
 */
export function splat(x: i32): Vec8i {
  let v: Vec8i = [x, x, x, x, x, x, x, x];
  return v;
}

/** Exported function `add`.
 * Implements `add`.
 * @param a Vec4f
 * @param b Vec4f
 * @return Vec4f
 */
export function add(a: Vec4f, b: Vec4f): Vec4f {
  return a + b;
}

/** Exported function `sub`.
 * Implements `sub`.
 * @param a Vec4f
 * @param b Vec4f
 * @return Vec4f
 */
export function sub(a: Vec4f, b: Vec4f): Vec4f {
  return a - b;
}

/** Exported function `mul`.
 * Implements `mul`.
 * @param a Vec4f
 * @param b Vec4f
 * @return Vec4f
 */
export function mul(a: Vec4f, b: Vec4f): Vec4f {
  return a * b;
}

/** Exported function `hsum`.
 * Implements `hsum`.
 * @param v Vec4f
 * @return f32
 */
export function hsum(v: Vec4f): f32 {
  return v[0] + v[1] + v[2] + v[3];
}

/** Exported function `dot`.
 * Implements `dot`.
 * @param a Vec4f
 * @param b Vec4f
 * @return f32
 */
export function dot(a: Vec4f, b: Vec4f): f32 {
  return hsum(mul(a, b));
}

/**
 * See implementation.
 * See implementation.
 */
export function fma(a: Vec4f, b: Vec4f, c: Vec4f): Vec4f {
  let r: Vec4f = [
    a[0] + b[0] * c[0],
    a[1] + b[1] * c[1],
    a[2] + b[2] * c[2],
    a[3] + b[3] * c[3]
  ];
  return r;
}

/** Exported function `madd`.
 * Implements `madd`.
 * @param a Vec4f
 * @param b Vec4f
 * @param c Vec4f
 * @return Vec4f
 */
export function madd(a: Vec4f, b: Vec4f, c: Vec4f): Vec4f {
  return fma(a, b, c);
}

/** Exported function `splat`.
 * Implements `splat`.
 * @param x f32
 * @return Vec4f
 */
export function splat(x: f32): Vec4f {
  let v: Vec4f = [x, x, x, x];
  return v;
}

/**
 * See implementation.
 * See implementation.
 */
export function shuffle(v: Vec4f, mask: i32[4]): Vec4f {
  let r: Vec4f = [v[mask[0]], v[mask[1]], v[mask[2]], v[mask[3]]];
  return r;
}

/**
 * See implementation.
 * See implementation.
 */
export function shuffle(v: Vec8i, mask: i32[8]): Vec8i {
  let r: Vec8i = [
    v[mask[0]], v[mask[1]], v[mask[2]], v[mask[3]],
    v[mask[4]], v[mask[5]], v[mask[6]], v[mask[7]]
  ];
  return r;
}

/** Exported function `select_lane`.
 * Implements `select_lane`.
 * @param mask_lane i32
 * @param a_lane i32
 * @param b_lane i32
 * @return i32
 */
export function select_lane(mask_lane: i32, a_lane: i32, b_lane: i32): i32 {
  if (mask_lane != 0) { return a_lane; }
  return b_lane;
}

/**
 * See implementation.
 */
export function select(mask: Vec8i, a: Vec8i, b: Vec8i): Vec8i {
  let r: Vec8i = [
    select_lane(mask[0], a[0], b[0]),
    select_lane(mask[1], a[1], b[1]),
    select_lane(mask[2], a[2], b[2]),
    select_lane(mask[3], a[3], b[3]),
    select_lane(mask[4], a[4], b[4]),
    select_lane(mask[5], a[5], b[5]),
    select_lane(mask[6], a[6], b[6]),
    select_lane(mask[7], a[7], b[7])
  ];
  return r;
}

/** Exported function `select_lane`.
 * Implements `select_lane`.
 * @param mask_lane f32
 * @param a_lane f32
 * @param b_lane f32
 * @return f32
 */
export function select_lane(mask_lane: f32, a_lane: f32, b_lane: f32): f32 {
  if (mask_lane != 0.0) { return a_lane; }
  return b_lane;
}

/**
 * See implementation.
 */
export function select(mask: Vec4f, a: Vec4f, b: Vec4f): Vec4f {
  let r: Vec4f = [
    select_lane(mask[0], a[0], b[0]),
    select_lane(mask[1], a[1], b[1]),
    select_lane(mask[2], a[2], b[2]),
    select_lane(mask[3], a[3], b[3])
  ];
  return r;
}

/** Exported function `placeholder`.
 * Module import/smoke marker; returns 0.
 * @return i32
 */
export function placeholder(): i32 {
  return 0;
}
