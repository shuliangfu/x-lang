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

/** Exported function `new_v4`.
 * Implements `new_v4`.
 * @return Uuid
 */
export function new_v4(): Uuid {
  let u: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  unsafe { if (uuid_new_v4_c(&u.bytes[0]) != 0) {
    return Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  } }
  return u;
}

/** Exported function `new_v7`.
 * Implements `new_v7`.
 * @return Uuid
 */
export function new_v7(): Uuid {
  let u: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  unsafe { 
    if (uuid_new_v7_c(&u.bytes[0]) != 0) {
      return Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
    } 
  }
  return u;
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

/** Exported function `as_bytes`.
 * Implements `as_bytes`.
 * @param u *Uuid
 * @return *u8
 */
export function as_bytes(u: *Uuid): *u8 {
  if (u == 0) { return 0 as *u8; }
  return &u.bytes[0];
}
