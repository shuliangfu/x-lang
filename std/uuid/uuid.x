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

const mem = import("core.mem");

/* See implementation. */
extern function random_fill_bytes_c(buf: *u8, len: i32): i32;
/* See implementation. */
extern function time_now_wall_ms_c(): i64;

/* See implementation. */
let uuid_v7_last_ms: i64 = -1;
let uuid_v7_seq: u16 = 0;

/** Exported function `uuid_hex_val`.
 * Implements `uuid_hex_val`.
 * @param c u8
 * @return i32
 */
export function uuid_hex_val(c: u8): i32 {
  if (c >= 48 && c <= 57) { return (c - 48) as i32; }
  if (c >= 97 && c <= 102) { return (c - 97 + 10) as i32; }
  if (c >= 65 && c <= 70) { return (c - 65 + 10) as i32; }
  return -1;
}

/** Exported function `uuid_nibble_hex`.
 * Implements `uuid_nibble_hex`.
 * @param d u8
 * @return u8
 */
export function uuid_nibble_hex(d: u8): u8 {
  if (d < 10) { return (d + 48) as u8; }
  return (d - 10 + 97) as u8;
}

/** Exported function `uuid_apply_v4_variant`.
 * Implements `uuid_apply_v4_variant`.
 * @param u *u8
 * @return void
 */
export function uuid_apply_v4_variant(u: *u8): void {
  u[6] = (u[6] & 15) | 64;
  u[8] = (u[8] & 63) | 128;
}

/** Exported function `uuid_new_v4_c`.
 * Implements `uuid_new_v4_c`.
 * @param out *u8
 * @return i32
 */
export function uuid_new_v4_c(out: *u8): i32 {
  if (out == 0) { return -1; }
  unsafe { if (random_fill_bytes_c(out, 16) != 16) { return -1; } }
  uuid_apply_v4_variant(out);
  return 0;
}

/** Exported function `uuid_new_v7_c`.
 * Implements `uuid_new_v7_c`.
 * @param out *u8
 * @return i32
 */
export function uuid_new_v7_c(out: *u8): i32 {
  let ms: i64 = 0;
  let rand_a: u16 = 0;
  let rand_buf: u8[2] = [0, 0];
  let tail: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  if (out == 0) { return -1; }
  unsafe { ms = time_now_wall_ms_c(); }
  if (ms < 0) { ms = 0; }
  if (ms == uuid_v7_last_ms) {
    uuid_v7_seq = (uuid_v7_seq + 1) & 4095;
    if (uuid_v7_seq == 0) {
      /* See implementation. */
      while (ms == uuid_v7_last_ms) {
        unsafe { ms = time_now_wall_ms_c(); }
        if (ms < 0) { ms = 0; }
      }
      uuid_v7_last_ms = ms;
      unsafe { if (random_fill_bytes_c(&rand_buf[0], 2) != 2) { return -1; } }
      rand_a = ((rand_buf[0] as u16) | ((rand_buf[1] as u16) << 8)) & 4095;
      uuid_v7_seq = rand_a;
    } else {
      rand_a = uuid_v7_seq;
    }
  } else {
    uuid_v7_last_ms = ms;
    unsafe { if (random_fill_bytes_c(&rand_buf[0], 2) != 2) { return -1; } }
    rand_a = ((rand_buf[0] as u16) | ((rand_buf[1] as u16) << 8)) & 4095;
    uuid_v7_seq = rand_a;
  }
  out[0] = ((ms >> 40) & 255) as u8;
  out[1] = ((ms >> 32) & 255) as u8;
  out[2] = ((ms >> 24) & 255) as u8;
  out[3] = ((ms >> 16) & 255) as u8;
  out[4] = ((ms >> 8) & 255) as u8;
  out[5] = (ms & 255) as u8;
  out[6] = (112 | ((rand_a >> 8) & 15)) as u8;
  out[7] = (rand_a & 255) as u8;
  unsafe { if (random_fill_bytes_c(&tail[0], 8) != 8) { return -1; } }
  out[8] = ((tail[0] & 63) | 128) as u8;
  mem.mem_copy(out + 9, &tail[1], 7);
  return 0;
}

/** Exported function `uuid_parse_c`.
 * Implements `uuid_parse_c`.
 * @param ptr *u8
 * @param len i32
 * @param out *u8
 * @return i32
 */
export function uuid_parse_c(ptr: *u8, len: i32, out: *u8): i32 {
  let i: i32 = 0;
  let pos: i32 = 0;
  let digit: i32 = 0;
  let hi: i32 = 0;
  if (ptr == 0 || out == 0 || len <= 0) { return -1; }
  i = 0;
  while (i < 16) {
    if (pos < len && ptr[pos] == 45) { pos = pos + 1; }
    if (pos + 1 >= len) { return -1; }
    hi = uuid_hex_val(ptr[pos]);
    if (hi < 0) { return -1; }
    digit = hi * 16;
    hi = uuid_hex_val(ptr[pos + 1]);
    if (hi < 0) { return -1; }
    digit = digit + hi;
    out[i] = digit as u8;
    pos = pos + 2;
    i = i + 1;
  }
  while (pos < len && ptr[pos] == 45) { pos = pos + 1; }
  if (pos != len) { return -1; }
  return 0;
}

/** Exported function `uuid_format_c`.
 * Implements `uuid_format_c`.
 * @param u *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function uuid_format_c(u: *u8, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  if (u == 0 || out == 0 || out_cap < 37) { return -1; }
  while (i < 16) {
    if (o + 2 > out_cap) { return -1; }
    out[o] = uuid_nibble_hex(((u[i] >> 4) & 15) as u8);
    out[o + 1] = uuid_nibble_hex((u[i] & 15) as u8);
    o = o + 2;
    if (i == 3 || i == 5 || i == 7 || i == 9) {
      if (o >= out_cap) { return -1; }
      out[o] = 45;
      o = o + 1;
    }
    i = i + 1;
  }
  if (o != 36) { return -1; }
  return 36;
}

/** Exported function `uuid_eq_c`.
 * Implements `uuid_eq_c`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function uuid_eq_c(a: *u8, b: *u8): i32 {
  if (a == 0 || b == 0) { return 0; }
  if (mem.mem_compare(a, b, 16) == 0) { return 1; }
  return 0;
}

/** Exported function `uuid_version_c`.
 * Implements `uuid_version_c`.
 * @param u *u8
 * @return i32
 */
export function uuid_version_c(u: *u8): i32 {
  if (u == 0) { return -1; }
  return ((u[6] >> 4) & 15) as i32;
}

/** Exported function `uuid_smoke_c`.
 * Implements `uuid_smoke_c`.
 * @return i32
 */
export function uuid_smoke_c(): i32 {
  let known: u8[37] = [
    53, 48, 48, 101, 56, 52, 48, 48, 45, 101, 50, 57, 98, 45, 52, 49, 100, 52,
    45, 97, 55, 49, 54, 45, 52, 52, 54, 54, 53, 53, 52, 52, 48, 48, 48, 48, 0
  ];
  let u: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let buf: u8[40] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let v4: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let v7: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let plain: u8[33] = [
    53, 48, 48, 101, 56, 52, 48, 48, 101, 50, 57, 98, 52, 49, 100, 52, 97, 55,
    49, 54, 52, 52, 54, 54, 53, 53, 52, 52, 48, 48, 48, 48, 0
  ];
  let u2: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let v7b: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let prev: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let cur: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  if (uuid_parse_c(&known[0], 36, &u[0]) != 0) { return 1; }
  if (uuid_format_c(&u[0], &buf[0], 40) != 36) { return 2; }
  if (mem.mem_compare(&buf[0], &known[0], 36) != 0) { return 3; }
  if (uuid_eq_c(&u[0], &u[0]) != 1) { return 4; }
  if (uuid_parse_c(&plain[0], 32, &u2[0]) != 0) { return 5; }
  if (uuid_eq_c(&u[0], &u2[0]) != 1) { return 6; }
  if (uuid_new_v4_c(&v4[0]) != 0) { return 7; }
  if (uuid_version_c(&v4[0]) != 4) { return 8; }
  if (uuid_new_v7_c(&v7[0]) != 0) { return 9; }
  if (uuid_version_c(&v7[0]) != 7) { return 10; }
  if (uuid_new_v7_c(&v7b[0]) != 0) { return 11; }
  if (mem.mem_compare(&v7[0], &v7b[0], 16) >= 0) { return 12; }
  mem.mem_copy(&prev[0], &v7[0], 16);
  k = 0;
  while (k < 8) {
    if (uuid_new_v7_c(&cur[0]) != 0) { return 13; }
    if (mem.mem_compare(&prev[0], &cur[0], 16) >= 0) { return 14; }
    mem.mem_copy(&prev[0], &cur[0], 16);
    k = k + 1;
  }
  return 0;
}
