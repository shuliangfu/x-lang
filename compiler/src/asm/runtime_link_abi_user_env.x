// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_link_abi_user_env.x — Darwin arm64 user-domain getenv face.
//
// This is the whole product body of runtime_link_abi_user_env.o on Darwin
// arm64. The cold ensure path pure-asms this file and does not pass the C
// seed to host cc. Linux and Windows still compile the C seed: Linux reads
// the environ symbol directly, and Windows uses the CRT getenv.
//
// Both faces are weakened after emit. runtime_panic_arm64.x defines the
// same two names as strong symbols. When a user link includes both objects,
// the strong panic faces win. This object still has to stand alone for a
// residual link that does not pull panic.
//
// The scan matches include/xlang_environ_cap.h: walk the process block,
// match "name=", return the bytes after '='. No libc getenv.
//
// This object is a user / STD_AND_PANIC companion. It is not in the g05
// compiler image.
//
// PLATFORM: MACOS|DARWIN arm64.

export extern "C" function __NSGetEnviron(): ***u8;

/**
 * Count bytes in a NUL-terminated string, capped at 4096.
 * @param s pointer to a C string, or null
 * @return 0 when s is null; otherwise the number of bytes before the NUL
 * PLATFORM: MACOS|DARWIN
 */
function user_env_cstr_len(s: *u8): i32 {
  if (s == 0) { return 0; }
  let n: i32 = 0;
  while (s[n] != 0 as u8) {
    n = n + 1;
    if (n >= 4096) { return n; }
  }
  return n;
}

/**
 * Scan the Darwin process environment for name.
 * Null, empty, or a missing block returns null. The returned pointer
 * addresses the value bytes after '=' inside the environ entry.
 * Weak after emit, so the strong panic twin can replace it.
 * @param name NUL-terminated key; null and empty are rejected
 * @return value pointer, or null
 * PLATFORM: MACOS|DARWIN — _NSGetEnviron, not libc getenv
 */
#[no_mangle]
export function link_abi_getenv_impl(name: *u8): *u8 {
  if (name == 0) { return 0; }
  if (name[0] == 0 as u8) { return 0; }
  let nlen: i32 = user_env_cstr_len(name);
  if (nlen <= 0) { return 0; }
  unsafe {
    let slot: ***u8 = __NSGetEnviron();
    if (slot == 0) { return 0; }
    let env: **u8 = slot[0];
    if (env == 0) { return 0; }
    let i: i32 = 0;
    while (i < 4096) {
      let ent: *u8 = env[i];
      if (ent == 0) { return 0; }
      let k: i32 = 0;
      let matched: i32 = 1;
      while (k < nlen) {
        if (ent[k] != name[k]) {
          matched = 0;
          break;
        }
        k = k + 1;
      }
      if (matched == 1 && ent[nlen] == 61 as u8) {
        return &ent[nlen + 1];
      }
      i = i + 1;
    }
  }
  return 0;
}

/**
 * Public getenv face: null and empty keys return null.
 * Weak after emit. Same contract as the C seed face.
 * @param name NUL-terminated key
 * @return null on null or empty; otherwise link_abi_getenv_impl
 * PLATFORM: MACOS|DARWIN user-domain weak symbol
 */
#[no_mangle]
export function link_abi_getenv(name: *u8): *u8 {
  if (name == 0) { return 0; }
  if (name[0] == 0 as u8) { return 0; }
  return link_abi_getenv_impl(name);
}

/**
 * Marks this translation unit as the Darwin arm64 user-env body.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_link_abi_user_env_x_doc_anchor(): i32 {
  return 0;
}
