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

/**
 * Write pi into the caller slot.
 * 10.90: i64 bit-pattern out-slot (tip Linux as-f64 literal omit/P001).
 * @param out *f64 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function math_pi_c(out: *f64): i32 {
  let b: i64 = 4614256656552045848;
  let p: *i64 = &b;
  let q: *f64 = p as *f64;
  out[0] = q[0];
  return 0;
}

/**
 * Write e into the caller slot.
 * 10.90: i64 bit-pattern out-slot (tip Linux as-f64 literal omit/P001).
 * @param out *f64 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function math_e_c(out: *f64): i32 {
  let b: i64 = 4613303445314885481;
  let p: *i64 = &b;
  let q: *f64 = p as *f64;
  out[0] = q[0];
  return 0;
}

/**
 * Write tau (2 * pi) into the caller slot.
 * 10.90: i64 bit-pattern (no math_pi_c call — tip Linux XT001; no as-f64 lit).
 * @param out *f64 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function math_tau_c(out: *f64): i32 {
  let b: i64 = 4618760256179416344;
  let p: *i64 = &b;
  let q: *f64 = p as *f64;
  out[0] = q[0];
  return 0;
}
