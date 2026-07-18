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
//
// See implementation.
// See implementation.
// See implementation.

extern function env_getenv_c(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32;
extern function env_getenv_ptr_c(key: *u8, key_len: i32, out_len: *i32): *u8;
extern function env_getenv_z_c(key_z: *u8, out_len: *i32): *u8;
extern function env_getenv_exists_c(key: *u8, key_len: i32): i32;
extern function env_setenv_c(name: *u8, value: *u8, overwrite: i32): i32;
extern function env_unsetenv_c(name: *u8): i32;
extern function env_temp_dir_c(out: *u8, cap: i32): i32;
extern function env_iter_count_c(): i32;
extern function env_iter_at_c(index: i32, key_out: *u8, key_cap: i32, val_out: *u8, val_cap: i32): i32;
extern function args_iter_count_c(): i32;
extern function args_iter_at_c(i: i32): *u8;

/**
 * See implementation.
 * See implementation.
 */
export function getenv(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = env_getenv_c(key, key_len, out, out_cap); }
  return _rc;
}

/**
 * See implementation.
 * See implementation.
 */
export function getenv_ptr(key: *u8, key_len: i32, out_len: *i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = env_getenv_ptr_c(key, key_len, out_len); }
  return _rc;
}

/**
 * See implementation.
 * See implementation.
 */
export function getenv_z(key_z: *u8, out_len: *i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = env_getenv_z_c(key_z, out_len); }
  return _rc;
}

/** Exported function `getenv_exists`.
 * Implements `getenv_exists`.
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function getenv_exists(key: *u8, key_len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = env_getenv_exists_c(key, key_len); }
  return _rc;
}

/** Exported function `setenv`.
 * Implements `setenv`.
 * @param name *u8
 * @param value *u8
 * @param overwrite i32
 * @return i32
 */
export function setenv(name: *u8, value: *u8, overwrite: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = env_setenv_c(name, value, overwrite); }
  return _rc;
}

/** Exported function `unsetenv`.
 * Implements `unsetenv`.
 * @param name *u8
 * @return i32
 */
export function unsetenv(name: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = env_unsetenv_c(name); }
  return _rc;
}

/** Exported function `temp_dir`.
 * Implements `temp_dir`.
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function temp_dir(out: *u8, cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = env_temp_dir_c(out, cap); }
  return _rc;
}

/* See implementation. */
export struct EnvIter {
  index: i32;
}

/* See implementation. */
export struct ArgsIter {
  index: i32;
}

/** Exported function `iter`.
 * Implements `iter`.
 * @return EnvIter
 */
export function iter(): EnvIter {
  return EnvIter { index: 0 };
}

/** Exported function `iter_count`.
 * Implements `iter_count`.
 * @return i32
 */
export function iter_count(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = env_iter_count_c(); }
  return _rc;
}

/** Exported function `iter_next`.
 * Implements `iter_next`.
 * @param it *EnvIter
 * @param key_out *u8
 * @param key_cap i32
 * @param val_out *u8
 * @param val_cap i32
 * @return i32
 */
export function iter_next(it: *EnvIter, key_out: *u8, key_cap: i32, val_out: *u8, val_cap: i32): i32 {
  loop {
    let r: i32 = 0;
    unsafe {
      r = env_iter_at_c(it.index, key_out, key_cap, val_out, val_cap);
      if (r == 1) {
        it.index = it.index + 1;
        return 1;
      }
    }
    if (r == 0) { return 0; }
    if (r < 0) {
      unsafe {
        it.index = it.index + 1;
      }
      continue;
    }
    return -1;
  }
  return 0;
}

/** Exported function `args_iter`.
 * Implements `args_iter`.
 * @return ArgsIter
 */
export function args_iter(): ArgsIter {
  return ArgsIter { index: 0 };
}

/** Exported function `args_iter_count`.
 * Implements `args_iter_count`.
 * @return i32
 */
export function args_iter_count(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = args_iter_count_c(); }
  return _rc;
}

/** Exported function `args_iter_next`.
 * Implements `args_iter_next`.
 * @param it *ArgsIter
 * @return *u8
 */
export function args_iter_next(it: *ArgsIter): *u8 {
  let total: i32 = 0;
  unsafe {
    total = args_iter_count_c();
    if (it.index >= total) { return 0 as *u8; }
    let p: *u8 = args_iter_at_c(it.index);
    it.index = it.index + 1;
    return p;
  }
  return 0 as *u8;
}
