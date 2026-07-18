// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// runtime_env_os_x_doc_anchor: see function docblock below.


/** Exported function `runtime_env_os_x_doc_anchor`.
 * Implements `runtime_env_os_x_doc_anchor`.
 * @return i32
 */
export function runtime_env_os_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

// env_build_key: see function docblock below.

/** Exported function `env_build_key`.
 * Implements `env_build_key`.
 * @param key *u8
 * @param key_len i32
 * @param key_buf *u8
 * @return i32
 */
#[no_mangle]
export function env_build_key(key: *u8, key_len: i32, key_buf: *u8): i32 {
  // ENV_KEY_MAX = 256
  if (key == 0) { return 0 - 1; }
  if (key_buf == 0) { return 0 - 1; }
  if (key_len <= 0) { return 0 - 1; }
  if (key_len >= 256) { return 0 - 1; }
  let i: i32 = 0;
  while (i < key_len) {
    key_buf[i] = key[i];
    i = i + 1;
  }
  key_buf[key_len] = 0;
  return 0;
}
