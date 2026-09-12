// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// pthin_simd.x — G-02f-288 P7 parser thin simd product bodies.
//
// 7.2.1 P7b Route C productize (2026-09-13): after P3b type_ref, simd.inc
// is the next still-host-cc product slice with a portable buf-path region.
// IDENT `shuffle` / `select` spelling is Route C (*u8 + length). Callee
// name fill (`simd_shuffle` / `simd_select`) is buf-path Route C into a
// caller buffer. Arena expr alloc, lexer by-value, and
// parse_at_simd_builtin_into stay C. Do not wrap the two AUDIT_CALL sites
// (not a contiguous already-T nop block).
//
// Hybrid P7b: g05_try_x_to_o this file; XLANG_PTHIN_SIMD_BODIES_FROM_X
// skips the portable .inc region. Cold: no define, full .inc stays.
// Pack encoding: (is_shuffle << 8) | need_args; 0 = no match.
// PLATFORM: SHARED freestanding.

/**
 * Bounds check shared by IDENT spelling probes in this file.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @param want_len i32 — required spelling length
 * @return i32 — 1 if data is live, ident_len==want_len, and the span fits
 */
function parser_asm_simd_ident_span_ok(data: *u8, length: usize, token_start: usize, ident_len: i32, want_len: i32): i32 {
  if (data == 0 as *u8 || ident_len != want_len || ident_len <= 0) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  return 1;
}

/**
 * Read one already-in-span source byte.
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param token_start usize — IDENT start
 * @param i i32 — byte offset within the IDENT
 * @return u8 — data[token_start + i]
 */
function parser_asm_simd_ident_byte(data: *u8, token_start: usize, i: i32): u8 {
  let c: u8 = 0;
  unsafe {
    c = data[token_start + i as usize];
  }
  return c;
}

/**
 * IDENT spelling pack for `@shuffle` / `@select`.
 * shuffle → (1 << 8) | 2; select → 3; anything else → 0.
 * Byte compares copy the C twin (`shuffle` 7 / `select` 6).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — pack, or 0 if the spelling is not a simd builtin
 * PLATFORM: SHARED — buf-path split of the former static C twin.
 */
#[no_mangle]
export function parser_asm_simd_builtin_ident_pack_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  // `shuffle` — 115,104,117,102,102,108,101
  if (parser_asm_simd_ident_span_ok(data, length, token_start, ident_len, 7) != 0) {
    if (parser_asm_simd_ident_byte(data, token_start, 0) == 115) {
      if (parser_asm_simd_ident_byte(data, token_start, 1) == 104) {
        if (parser_asm_simd_ident_byte(data, token_start, 2) == 117) {
          if (parser_asm_simd_ident_byte(data, token_start, 3) == 102) {
            if (parser_asm_simd_ident_byte(data, token_start, 4) == 102) {
              if (parser_asm_simd_ident_byte(data, token_start, 5) == 108) {
                if (parser_asm_simd_ident_byte(data, token_start, 6) == 101) {
                  return (1 << 8) | 2;
                }
              }
            }
          }
        }
      }
    }
  }
  // `select` — 115,101,108,101,99,116
  if (parser_asm_simd_ident_span_ok(data, length, token_start, ident_len, 6) != 0) {
    if (parser_asm_simd_ident_byte(data, token_start, 0) == 115) {
      if (parser_asm_simd_ident_byte(data, token_start, 1) == 101) {
        if (parser_asm_simd_ident_byte(data, token_start, 2) == 108) {
          if (parser_asm_simd_ident_byte(data, token_start, 3) == 101) {
            if (parser_asm_simd_ident_byte(data, token_start, 4) == 99) {
              if (parser_asm_simd_ident_byte(data, token_start, 5) == 116) {
                return 3;
              }
            }
          }
        }
      }
    }
  }
  return 0;
}

/**
 * Write the lowered callee name into `out[0..64)`.
 * is_shuffle != 0 → `simd_shuffle` (12); else `simd_select` (11).
 * Bytes past the name and before 64 are written 0, matching the C twin
 * (var_name is 256 wide; only the first 64 were zeroed).
 * @param is_shuffle i32 — non-zero selects simd_shuffle
 * @param out *u8 — destination; must be >= 64 bytes; null is 0
 * @return i32 — name length, or 0 on null
 * PLATFORM: SHARED — buf-path split of the inline C name fill.
 */
#[no_mangle]
export function parser_asm_simd_callee_name_fill_c(is_shuffle: i32, out: *u8): i32 {
  let nlen: i32 = 0;
  let i: i32 = 0;
  if (out == 0 as *u8) {
    return 0;
  }
  if (is_shuffle != 0) {
    // simd_shuffle
    unsafe {
      out[0] = 115;
      out[1] = 105;
      out[2] = 109;
      out[3] = 100;
      out[4] = 95;
      out[5] = 115;
      out[6] = 104;
      out[7] = 117;
      out[8] = 102;
      out[9] = 102;
      out[10] = 108;
      out[11] = 101;
    }
    nlen = 12;
  } else {
    // simd_select
    unsafe {
      out[0] = 115;
      out[1] = 105;
      out[2] = 109;
      out[3] = 100;
      out[4] = 95;
      out[5] = 115;
      out[6] = 101;
      out[7] = 108;
      out[8] = 101;
      out[9] = 99;
      out[10] = 116;
    }
    nlen = 11;
  }
  i = nlen;
  while (i < 64) {
    unsafe {
      out[i] = 0;
    }
    i = i + 1;
  }
  return nlen;
}
