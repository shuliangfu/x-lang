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
// cbrt、pow、exp、log、abs、signum；min/max；erf/erfc/log1p/expm1（STD-115）；
// See implementation.
// See implementation.

extern function math_pi_c(): f64;
extern function math_e_c(): f64;
extern function math_tau_c(): f64;
extern function math_floor_c(x: f64): f64;
extern function math_ceil_c(x: f64): f64;
extern function math_trunc_c(x: f64): f64;
extern function math_round_c(x: f64): f64;
extern function math_sin_c(x: f64): f64;
extern function math_cos_c(x: f64): f64;
extern function math_tan_c(x: f64): f64;
extern function math_asin_c(x: f64): f64;
extern function math_acos_c(x: f64): f64;
extern function math_atan_c(x: f64): f64;
extern function math_atan2_c(y: f64, x: f64): f64;
extern function math_sqrt_c(x: f64): f64;
extern function math_cbrt_c(x: f64): f64;
extern function math_pow_c(base: f64, exp: f64): f64;
extern function math_exp_c(x: f64): f64;
extern function math_log_c(x: f64): f64;
extern function math_fabs_c(x: f64): f64;
extern function math_signum_c(x: f64): f64;
extern function math_fmin_c(a: f64, b: f64): f64;
extern function math_fmax_c(a: f64, b: f64): f64;

/** Exported function `pi`.
 * Implements `pi`.
 * @return f64
 */
export function pi(): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_pi_c(); }
  return rc;
}

/** Exported function `e`.
 * Implements `e`.
 * @return f64
 */
export function e(): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_e_c(); }
  return rc;
}

/** 2π。 */
export function tau(): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_tau_c(); }
  return rc;
}

/** Exported function `floor`.
 * Implements `floor`.
 * @param x f64
 * @return f64
 */
export function floor(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_floor_c(x); }
  return rc;
}

/** Exported function `ceil`.
 * Implements `ceil`.
 * @param x f64
 * @return f64
 */
export function ceil(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_ceil_c(x); }
  return rc;
}

/** Exported function `trunc`.
 * Implements `trunc`.
 * @param x f64
 * @return f64
 */
export function trunc(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_trunc_c(x); }
  return rc;
}

/** Exported function `round`.
 * Implements `round`.
 * @param x f64
 * @return f64
 */
export function round(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_round_c(x); }
  return rc;
}

/** Exported function `sin`.
 * Implements `sin`.
 * @param x f64
 * @return f64
 */
export function sin(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_sin_c(x); }
  return rc;
}

/** Exported function `cos`.
 * Implements `cos`.
 * @param x f64
 * @return f64
 */
export function cos(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_cos_c(x); }
  return rc;
}

/** Exported function `tan`.
 * Implements `tan`.
 * @param x f64
 * @return f64
 */
export function tan(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_tan_c(x); }
  return rc;
}

/** Exported function `asin`.
 * Implements `asin`.
 * @param x f64
 * @return f64
 */
export function asin(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_asin_c(x); }
  return rc;
}

/** Exported function `acos`.
 * Implements `acos`.
 * @param x f64
 * @return f64
 */
export function acos(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_acos_c(x); }
  return rc;
}

/** Exported function `atan`.
 * Implements `atan`.
 * @param x f64
 * @return f64
 */
export function atan(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_atan_c(x); }
  return rc;
}

/** Exported function `atan2`.
 * Implements `atan2`.
 * @param y f64
 * @param x f64
 * @return f64
 */
export function atan2(y: f64, x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_atan2_c(y, x); }
  return rc;
}

/** Exported function `sqrt`.
 * Implements `sqrt`.
 * @param x f64
 * @return f64
 */
export function sqrt(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_sqrt_c(x); }
  return rc;
}

/** Exported function `cbrt`.
 * Implements `cbrt`.
 * @param x f64
 * @return f64
 */
export function cbrt(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_cbrt_c(x); }
  return rc;
}

/** Exported function `pow`.
 * Implements `pow`.
 * @param base f64
 * @param exp f64
 * @return f64
 */
export function pow(base: f64, exp: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_pow_c(base, exp); }
  return rc;
}

/** Exported function `exp`.
 * Implements `exp`.
 * @param x f64
 * @return f64
 */
export function exp(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_exp_c(x); }
  return rc;
}

/** Exported function `log`.
 * Implements `log`.
 * @param x f64
 * @return f64
 */
export function log(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_log_c(x); }
  return rc;
}

/** Exported function `abs`.
 * Implements `abs`.
 * @param x f64
 * @return f64
 */
export function abs(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_fabs_c(x); }
  return rc;
}

/** Exported function `signum`.
 * Implements `signum`.
 * @param x f64
 * @return f64
 */
export function signum(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_signum_c(x); }
  return rc;
}

/** Exported function `min`.
 * Implements `min`.
 * @param a f64
 * @param b f64
 * @return f64
 */
export function min(a: f64, b: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_fmin_c(a, b); }
  return rc;
}

/** Exported function `max`.
 * Implements `max`.
 * @param a f64
 * @param b f64
 * @return f64
 */
export function max(a: f64, b: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_fmax_c(a, b); }
  return rc;
}

// See implementation.
extern function math_erf_c(x: f64): f64;
extern function math_erfc_c(x: f64): f64;
extern function math_log1p_c(x: f64): f64;
extern function math_expm1_c(x: f64): f64;
extern function math_special_smoke_c(): i32;

/** Exported function `erf`.
 * Implements `erf`.
 * @param x f64
 * @return f64
 */
export function erf(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_erf_c(x); }
  return rc;
}

/** Exported function `erfc`.
 * Implements `erfc`.
 * @param x f64
 * @return f64
 */
export function erfc(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_erfc_c(x); }
  return rc;
}

/** Exported function `log1p`.
 * Implements `log1p`.
 * @param x f64
 * @return f64
 */
export function log1p(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_log1p_c(x); }
  return rc;
}

/** Exported function `expm1`.
 * Implements `expm1`.
 * @param x f64
 * @return f64
 */
export function expm1(x: f64): f64 {
  let rc: f64 = 0.0;
  unsafe { rc = math_expm1_c(x); }
  return rc;
}

/** Exported function `special_smoke`.
 * Implements `special_smoke`.
 * @return i32
 */
export function special_smoke(): i32 {
  let rc: i32 = 0;
  unsafe { rc = math_special_smoke_c(); }
  return rc;
}

// See implementation.
export const FENV_INVALID: i32 = 1;
export const FENV_DIVBYZERO: i32 = 2;
export const FENV_OVERFLOW: i32 = 4;
export const FENV_UNDERFLOW: i32 = 8;
export const FENV_INEXACT: i32 = 16;
export const FENV_ALL: i32 = 31;
export const FENV_NOT_IMPL: i32 = -9;

extern function math_fenv_available_c(): i32;
extern function math_fenv_test_c(mask: i32): i32;
extern function math_fenv_clear_c(mask: i32): i32;
extern function math_fenv_raise_c(mask: i32): i32;

/** Exported function `fenv_available`.
 * Implements `fenv_available`.
 * @return i32
 */
export function fenv_available(): i32 {
  let rc: i32 = 0;
  unsafe { rc = math_fenv_available_c(); }
  return rc;
}

/** Exported function `test_exceptions`.
 * Implements `test_exceptions`.
 * @param mask i32
 * @return i32
 */
export function test_exceptions(mask: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = math_fenv_test_c(mask); }
  return rc;
}

/** Exported function `clear_exceptions`.
 * Implements `clear_exceptions`.
 * @param mask i32
 * @return i32
 */
export function clear_exceptions(mask: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = math_fenv_clear_c(mask); }
  return rc;
}

/** Exported function `raise_exceptions`.
 * Implements `raise_exceptions`.
 * @param mask i32
 * @return i32
 */
export function raise_exceptions(mask: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = math_fenv_raise_c(mask); }
  return rc;
}
