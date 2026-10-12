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
 * A literal f64 return does not asm-emit on the installed product. f64 uses xmm0, not rax.
 * @param out *f64 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function math_pi_c(out: *f64): i32 {
  let x: f64 = 3.14159265358979323846 as f64;
  out[0] = x;
  return 0;
}

/**
 * Write e into the caller slot.
 * @param out *f64 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED — the installed product cannot asm-emit this f64 literal return.
 */
export function math_e_c(out: *f64): i32 {
  let x: f64 = 2.7182818284590452354 as f64;
  out[0] = x;
  return 0;
}

/**
 * Write tau (2 * pi) into the caller slot.
 * @param out *f64 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function math_tau_c(out: *f64): i32 {
  let p: f64 = 0.0;
  math_pi_c(&p);
  let t: f64 = p * 2.0;
  out[0] = t;
  return 0;
}
