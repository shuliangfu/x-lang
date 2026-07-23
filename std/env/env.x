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

/* See implementation. */
export const ENV_LIT_KEY: u8[4] = [75, 69, 89, 0];
export const ENV_LIT_K: u8[2] = [75, 0];
export const ENV_LIT_V_EQ_W: u8[4] = [86, 61, 87, 0];
export const ENV_LIT_NOEQ: u8[5] = [78, 79, 69, 81, 0];
export const ENV_LIT_EMPTY: u8[1] = [0];

extern "C" function strchr(s: *u8, c: i32): *u8;
extern "C" function strlen(s: *u8): usize;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

extern function process_args_count_c(): i32;
extern function process_arg_c(i: i32): *u8;

extern function env_getenv_c(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32;
extern function env_setenv_c(name: *u8, value: *u8, overwrite: i32): i32;
extern function env_unsetenv_c(name: *u8): i32;

/* See implementation. */
/** Exported function `args_iter_count_c`.
 * Implements `args_iter_count_c`.
 * @return i32
 */
#[no_mangle]
export function args_iter_count_c(): i32 {
  unsafe { return process_args_count_c(); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
/** Exported function `args_iter_at_c`.
 * Implements `args_iter_at_c`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function args_iter_at_c(i: i32): *u8 {
  unsafe { return process_arg_c(i); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `env_cstr_eq`.
 * Implements `env_cstr_eq`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function env_cstr_eq(a: *u8, b: *u8): i32 {
  let i: i32 = 0;
  if (a == 0 || b == 0) { return 0; }
  while (a[i] != 0 && a[i] == b[i]) {
    i = i + 1;
  }
  if (a[i] != b[i]) { return 0; }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function env_parse_kv_entry(entry: *u8, key_out: *u8, key_cap: i32,
                          val_out: *u8, val_cap: i32): i32 {
  let eq: *u8 = 0;
  let key_len: i32 = 0;
  let val_len: i32 = 0;
  if (entry == 0 || key_out == 0 || val_out == 0 || key_cap <= 0 || val_cap <= 0) {
    return -1;
  }
  unsafe { eq = strchr(entry, 61); }
  if (eq != 0) {
    key_len = (eq - entry) as i32;
    unsafe { val_len = strlen(eq + 1) as i32; }
  } else {
    unsafe { key_len = strlen(entry) as i32; }
    val_len = 0;
  }
  if (key_len + 1 > key_cap || val_len + 1 > val_cap) {
    return -1;
  }
  unsafe { memcpy(key_out, entry, key_len); }
  key_out[key_len] = 0;
  if (val_len > 0) {
    unsafe { memcpy(val_out, eq + 1, val_len); }
  }
  val_out[val_len] = 0;
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function env_platform_encoding_smoke_c(): i32 {
  let key: u8[64];
  let val: u8[64];
  let out: u8[32];
  let gl: i32 = 0;
  let test_empty: u8[20] = [88, 76, 65, 78, 71, 95, 69, 78, 86, 95, 80, 69, 95, 69, 77, 80, 84, 89, 0, 0];
  let test_eq: u8[16] = [88, 76, 65, 78, 71, 95, 69, 78, 86, 95, 80, 69, 95, 69, 81, 0];
  let kv1: u8[5] = [75, 69, 89, 61, 0];
  let kv2: u8[6] = [75, 61, 86, 61, 87, 0];
  let kv3: u8[5] = [78, 79, 69, 81, 0];
  let kv4: u8[6] = [65, 66, 61, 67, 68, 0];
  let ab_val: u8[3] = [97, 61, 98];

  if (env_parse_kv_entry(&kv1[0], &key[0], 64, &val[0], 64) != 0) { return 1; }
  if (env_cstr_eq(&key[0], &ENV_LIT_KEY[0]) == 0) { return 2; }
  if (val[0] != 0) { return 3; }

  if (env_parse_kv_entry(&kv2[0], &key[0], 64, &val[0], 64) != 0) { return 4; }
  if (env_cstr_eq(&key[0], &ENV_LIT_K[0]) == 0) { return 5; }
  if (env_cstr_eq(&val[0], &ENV_LIT_V_EQ_W[0]) == 0) { return 6; }

  if (env_parse_kv_entry(&kv3[0], &key[0], 64, &val[0], 64) != 0) { return 7; }
  if (env_cstr_eq(&key[0], &ENV_LIT_NOEQ[0]) == 0) { return 8; }
  if (val[0] != 0) { return 9; }

  if (env_parse_kv_entry(&kv4[0], &key[0], 2, &val[0], 64) != -1) { return 10; }

  unsafe { env_unsetenv_c(&test_empty[0]); }
  unsafe { if (env_setenv_c(&test_empty[0], &ENV_LIT_EMPTY[0], 1) != 0) { return 11; } }
  unsafe { gl = env_getenv_c(&test_empty[0], 18, &out[0], 32); }
  if (gl != 0) { return 12; }

  unsafe { env_unsetenv_c(&test_eq[0]); }
  unsafe { if (env_setenv_c(&test_eq[0], &ab_val[0], 1) != 0) { return 13; } }
  unsafe { gl = env_getenv_c(&test_eq[0], 14, &out[0], 32); }
  if (gl != 3) { return 14; }
  if (out[0] != 97 || out[1] != 61 || out[2] != 98) { return 15; }

  unsafe { env_unsetenv_c(&test_empty[0]); }
  unsafe { env_unsetenv_c(&test_eq[0]); }
  return 0;
}
