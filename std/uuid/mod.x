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
//
// See implementation.

/* See implementation. */
allow(padding) struct Uuid {
  bytes: u8[16];
}

extern function uuid_new_v4_c(out: *u8): i32;
extern function uuid_new_v7_c(out: *u8): i32;
extern function uuid_parse_c(ptr: *u8, len: i32, out: *u8): i32;
extern function uuid_format_c(u: *u8, out: *u8, out_cap: i32): i32;
extern function uuid_eq_c(a: *u8, b: *u8): i32;
extern function uuid_version_c(u: *u8): i32;

/**
 * Write a version-4 UUID.
 * Uuid is 16 bytes, so returning it by value does not asm-emit.
 * A failed C fill leaves sixteen zero bytes.
 * @param out *Uuid — caller storage; must not be null
 * @return i32 — 0 on success, or the C fill status
 * PLATFORM: SHARED
 */
export function new_v4(out: *Uuid): i32 {
  if (out == 0) { return -1; }
  let rc: i32 = 0;
  unsafe { rc = uuid_new_v4_c(&out.bytes[0]); }
  if (rc != 0) {
    let i: i32 = 0;
    while (i < 16) {
      out.bytes[i] = 0;
      i = i + 1;
    }
  }
  return rc;
}

/**
 * Write a version-7 UUID.
 * A failed C fill leaves sixteen zero bytes.
 * @param out *Uuid — caller storage; must not be null
 * @return i32 — 0 on success, or the C fill status
 * PLATFORM: SHARED
 */
export function new_v7(out: *Uuid): i32 {
  if (out == 0) { return -1; }
  let rc: i32 = 0;
  unsafe { rc = uuid_new_v7_c(&out.bytes[0]); }
  if (rc != 0) {
    let i: i32 = 0;
    while (i < 16) {
      out.bytes[i] = 0;
      i = i + 1;
    }
  }
  return rc;
}

/** Exported function `parse`.
 * Implements `parse`.
 * @param ptr *u8
 * @param len i32
 * @param out *Uuid
 * @return i32
 */
export function parse(ptr: *u8, len: i32, out: *Uuid): i32 {
  if (out == 0) { return -1; }
  unsafe { return uuid_parse_c(ptr, len, &out.bytes[0]); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `format`.
 * Implements `format`.
 * @param u Uuid
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function format(u: Uuid, out: *u8, out_cap: i32): i32 {
  unsafe { return uuid_format_c(&u.bytes[0], out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `eq`.
 * Implements `eq`.
 * @param a Uuid
 * @param b Uuid
 * @return i32
 */
export function eq(a: Uuid, b: Uuid): i32 {
  unsafe { return uuid_eq_c(&a.bytes[0], &b.bytes[0]); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `version`.
 * Implements `version`.
 * @param u Uuid
 * @return i32
 */
export function version(u: Uuid): i32 {
  unsafe { return uuid_version_c(&u.bytes[0]); }
  return 0; // unreachable — typeck workaround
}

/**
 * Return the address of the UUID bytes.
 * The installed product cannot asm-emit this *u8 return. The address stays in rax.
 * @param u *Uuid — UUID slot; a null pointer returns 0
 * @return i64 — byte address, or 0
 * PLATFORM: SHARED
 */
export function as_bytes(u: *Uuid): i64 {
  if (u == 0) { return 0; }
  let p: *u8 = &u.bytes[0];
  return p as i64;
}
