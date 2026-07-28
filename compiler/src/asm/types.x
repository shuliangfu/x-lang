// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

const codegen_outbuf_abi = import("codegen_outbuf_abi");

/** See implementation for details. */
export enum TargetArch {
  TARGET_X86_64,
  TARGET_ARM64,
  TARGET_RISCV64,
  TARGET_NONE
}

/** Exported function `append_asm_line`.
 * Implements `append_asm_line`.
 * @param out *CodegenOutBuf
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function append_asm_line(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i < len && out.length < 8388608) {
    out.data[out.length] = ptr[i];
    out.length = out.length + 1;
    i = i + 1;
  }
  if (i < len) {
    return -1;
  }
  if (out.length < 8388608) {
    let nl: u8[1] = [10];
    out.data[out.length] = nl[0];
    out.length = out.length + 1;
    return 0;
  }
  return -1;
}

/**
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
export function format_u32_to_buf(buf: *u8, off: i32, max: i32, u: i32): i32 {
  let digit_chars: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  if (max < 1) {
    return -1;
  }
  let tmp: u8[10] = [];
  let num_digits: i32 = 0;
  let v: i32 = u;
  while (v > 0 && num_digits < 10) {
    tmp[num_digits] = digit_chars[v % 10];
    num_digits = num_digits + 1;
    v = v / 10;
  }
  /* If value is 0, num_digits stays 0 — write '0' so num_digits=1 before return (avoid codegen reorder). */
  if (num_digits == 0) {
    buf[off] = digit_chars[0];
    num_digits = 1;
  } else {
    if (num_digits > max) {
      return -1;
    }
    if (off + num_digits >= 8388608) {
      return -1;
    }
    let idx: i32 = 0;
    while (idx < num_digits) {
      buf[off + idx] = tmp[num_digits - 1 - idx];
      idx = idx + 1;
    }
  }
  return num_digits;
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function format_i32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  if (val < 0) {
    let u: i32 = 0 - val;
    if (u < 0) {
      if (max < 11) {
        return -1;
      }
      let s: u8[12] = [45, 50, 49, 52, 55, 52, 56, 51, 54, 52, 56, 0];
      let k: i32 = 0;
      while (k < 11) {
        buf[off + k] = s[k];
        k = k + 1;
      }
      return 11;
    }
    if (max < 1) {
      return -1;
    }
    let minus: u8[1] = [45];
    buf[off] = minus[0];
    let n: i32 = format_u32_to_buf(buf, off + 1, max - 1, u);
    if (n < 0) {
      return -1;
    }
    return n + 1;
  }
  return format_u32_to_buf(buf, off, max, val);
}

/** Exported function `format_u32_hex8_to_buf`.
 * Implements `format_u32_hex8_to_buf`.
 * @param buf *u8
 * @param off i32
 * @param val i32
 * @return i32
 */
export function format_u32_hex8_to_buf(buf: *u8, off: i32, val: i32): i32 {
  let hex: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];
  let i: i32 = 0;
  while (i < 8) {
    let shift: i32 = (7 - i) * 4;
    let nibble: i32 = (val >> shift) & 15;
    buf[off + i] = hex[nibble];
    i = i + 1;
  }
  return 8;
}

/* See implementation. */
// See implementation.
