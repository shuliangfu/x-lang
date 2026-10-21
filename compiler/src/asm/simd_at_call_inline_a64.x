// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// Darwin body of the SIMD @shuffle / @select inline.
// Typeck lowers @shuffle and @select to a bare CALL named
// simd_shuffle or simd_select. That name has no module function.
// The lane writers already in the product are the body. Method
// calls (kind 49) stay on the import path and return 0 here.
// PLATFORM: SHARED lane writers. This name gate is the Darwin
// hole: the Windows C twin already owns the same symbol.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_call_callee_func_name_into_c(arena: *u8, callee_ref: i32, out: *u8, cap: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_peel_comptime_array_lit_mask_c(arena: *u8, ctx: *u8, mask_ref: i32): i32;
export extern function glue_emit_vector_shuffle_lane_scalar_elf_c(
  arena: *u8, elf_ctx: *u8, src_ref: i32, mask_ref: i32, dst_off: i32, type_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_emit_vector_select_lane_scalar_elf_c(
  arena: *u8, elf_ctx: *u8, mask_ref: i32, a_ref: i32, b_ref: i32, dst_off: i32, type_ref: i32, ctx: *u8, ta: i32
): i32;

/**
 * Read one callee-name byte as i32.
 * @param buf *u8 — name bytes; null returns -1
 * @param i i32 — index; negative returns -1
 * @return i32 — byte 0..255, or -1 when buf is null or i is negative
 * The caller checks the name length first. PLATFORM: SHARED.
 */
function at_name_byte(buf: *u8, i: i32): i32 {
  let c: u8 = 0;
  if (buf == (0 as *u8) || i < 0) {
    return 0 - 1;
  }
  unsafe {
    c = buf[i];
  }
  return c as i32;
}

/**
 * True when buf[i] is the expected byte.
 * @param buf *u8 — name bytes
 * @param i i32 — index
 * @param b i32 — expected byte 0..255
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_has(buf: *u8, i: i32, b: i32): i32 {
  if (at_name_byte(buf, i) != b) {
    return 0;
  }
  return 1;
}

/**
 * True when the name starts with simd_.
 * @param buf *u8 — name bytes; length is checked by the caller
 * @return i32 — 1 match; 0 otherwise
 * Bytes are s i m d _. PLATFORM: SHARED.
 */
function at_name_simd_us(buf: *u8): i32 {
  if (at_name_has(buf, 0, 115) == 0) {
    return 0;
  }
  if (at_name_has(buf, 1, 105) == 0) {
    return 0;
  }
  if (at_name_has(buf, 2, 109) == 0) {
    return 0;
  }
  if (at_name_has(buf, 3, 100) == 0) {
    return 0;
  }
  if (at_name_has(buf, 4, 95) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when seven bytes at off spell shuffle.
 * @param buf *u8 — name bytes
 * @param off i32 — start index
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_shuffle_at(buf: *u8, off: i32): i32 {
  if (at_name_has(buf, off, 115) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 1, 104) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 2, 117) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 3, 102) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 4, 102) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 5, 108) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 6, 101) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when six bytes at off spell select.
 * @param buf *u8 — name bytes
 * @param off i32 — start index
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_select_at(buf: *u8, off: i32): i32 {
  if (at_name_has(buf, off, 115) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 1, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 2, 108) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 3, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 4, 99) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 5, 116) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when the name starts with vec4f_.
 * @param buf *u8 — name bytes
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_vec4f_us(buf: *u8): i32 {
  if (at_name_has(buf, 0, 118) == 0) {
    return 0;
  }
  if (at_name_has(buf, 1, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, 2, 99) == 0) {
    return 0;
  }
  if (at_name_has(buf, 3, 52) == 0) {
    return 0;
  }
  if (at_name_has(buf, 4, 102) == 0) {
    return 0;
  }
  if (at_name_has(buf, 5, 95) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when the name starts with vec8i_.
 * @param buf *u8 — name bytes
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_vec8i_us(buf: *u8): i32 {
  if (at_name_has(buf, 0, 118) == 0) {
    return 0;
  }
  if (at_name_has(buf, 1, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, 2, 99) == 0) {
    return 0;
  }
  if (at_name_has(buf, 3, 56) == 0) {
    return 0;
  }
  if (at_name_has(buf, 4, 105) == 0) {
    return 0;
  }
  if (at_name_has(buf, 5, 95) == 0) {
    return 0;
  }
  return 1;
}

/**
 * Lane count required by a shuffle callee name.
 * @param buf *u8 — callee name bytes
 * @param n i32 — byte count
 * @return i32 — 0 any lane count; 4 or 8 when the prefix says so; -1 no match
 * simd_shuffle is 12 bytes. vec4f_shuffle and vec8i_shuffle are 13.
 * PLATFORM: SHARED.
 */
function at_shuffle_expect_lanes(buf: *u8, n: i32): i32 {
  if (n == 12 && at_name_simd_us(buf) != 0 && at_name_shuffle_at(buf, 5) != 0) {
    return 0;
  }
  if (n == 13 && at_name_vec4f_us(buf) != 0 && at_name_shuffle_at(buf, 6) != 0) {
    return 4;
  }
  if (n == 13 && at_name_vec8i_us(buf) != 0 && at_name_shuffle_at(buf, 6) != 0) {
    return 8;
  }
  return 0 - 1;
}

/**
 * Lane count required by a select callee name.
 * @param buf *u8 — callee name bytes
 * @param n i32 — byte count
 * @return i32 — 0 any lane count; 4 or 8 when the prefix says so; -1 no match
 * simd_select is 11 bytes. vec4f_select and vec8i_select are 12.
 * PLATFORM: SHARED.
 */
function at_select_expect_lanes(buf: *u8, n: i32): i32 {
  if (n == 11 && at_name_simd_us(buf) != 0 && at_name_select_at(buf, 5) != 0) {
    return 0;
  }
  if (n == 12 && at_name_vec4f_us(buf) != 0 && at_name_select_at(buf, 6) != 0) {
    return 4;
  }
  if (n == 12 && at_name_vec8i_us(buf) != 0 && at_name_select_at(buf, 6) != 0) {
    return 8;
  }
  return 0 - 1;
}

/**
 * Inline a bare simd_shuffle / vec4f_shuffle / vec8i_shuffle CALL.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — encoder; null returns 0
 * @param call_ref i32 — CALL expr; not kind 48 returns 0
 * @param ctx *u8 — asm function frame; null returns 0
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param stack_slot_off i32 — destination slot of lane 0; negative returns 0
 * @param type_ref i32 — result vector type
 * @return i32 — 1 stored; 0 not this call; -1 the lane writer failed
 * Kind 49 is the import method and returns 0. The source must be a
 * VAR. The mask is peeled to an array literal, or used as-is when it
 * already is one (kind 46). The lane writer returns 0 on success.
 * PLATFORM: SHARED. pshufd stays on the Windows twin.
 */
#[no_mangle]
export function pipeline_asm_simd_try_inline_shuffle_call_elf_c(
  arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let ko: i32 = 0;
  let nargs: i32 = 0;
  let callee_ref: i32 = 0;
  let clen: i32 = 0;
  let cname: u8[256] = [];
  let expect: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let arg0: i32 = 0;
  let arg1: i32 = 0;
  let mask_lit: i32 = 0;
  let mask_ko: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0;
  }
  if (call_ref <= 0 || stack_slot_off < 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, call_ref);
  }
  if (ko != 48) {
    return 0;
  }
  unsafe {
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  }
  if (nargs != 2) {
    return 0;
  }
  unsafe {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
  }
  if (callee_ref <= 0) {
    return 0;
  }
  unsafe {
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, &cname[0], 256);
  }
  if (clen <= 0 || clen >= 256) {
    return 0;
  }
  expect = at_shuffle_expect_lanes(&cname[0], clen);
  if (expect < 0) {
    return 0;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (expect != 0 && lanes != expect) {
    return 0;
  }
  unsafe {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
  }
  if (arg0 <= 0 || arg1 <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg0);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    mask_lit = glue_peel_comptime_array_lit_mask_c(arena, ctx, arg1);
  }
  if (mask_lit <= 0) {
    unsafe {
      mask_ko = pipeline_expr_kind_ord_at(arena, arg1);
    }
    if (mask_ko == 46) {
      mask_lit = arg1;
    }
  }
  if (mask_lit <= 0) {
    return 0;
  }
  unsafe {
    rc = glue_emit_vector_shuffle_lane_scalar_elf_c(
      arena, elf_ctx, arg0, mask_lit, stack_slot_off, type_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Inline a bare simd_select / vec4f_select / vec8i_select CALL.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — encoder; null returns 0
 * @param call_ref i32 — CALL expr; not kind 48 returns 0
 * @param ctx *u8 — asm function frame; null returns 0
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param stack_slot_off i32 — destination slot of lane 0; negative returns 0
 * @param type_ref i32 — result vector type
 * @return i32 — 1 stored; 0 not this call; -1 the lane writer failed
 * All three arguments must be VARs. Kind 49 returns 0. The lane
 * writer returns 0 on success. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_simd_try_inline_select_call_elf_c(
  arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let ko: i32 = 0;
  let nargs: i32 = 0;
  let callee_ref: i32 = 0;
  let clen: i32 = 0;
  let cname: u8[256] = [];
  let expect: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let arg_m: i32 = 0;
  let arg_a: i32 = 0;
  let arg_b: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0;
  }
  if (call_ref <= 0 || stack_slot_off < 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, call_ref);
  }
  if (ko != 48) {
    return 0;
  }
  unsafe {
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  }
  if (nargs != 3) {
    return 0;
  }
  unsafe {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
  }
  if (callee_ref <= 0) {
    return 0;
  }
  unsafe {
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, &cname[0], 256);
  }
  if (clen <= 0 || clen >= 256) {
    return 0;
  }
  expect = at_select_expect_lanes(&cname[0], clen);
  if (expect < 0) {
    return 0;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (expect != 0 && lanes != expect) {
    return 0;
  }
  unsafe {
    arg_m = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg_m <= 0 || arg_a <= 0 || arg_b <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg_m);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg_a);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg_b);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    rc = glue_emit_vector_select_lane_scalar_elf_c(
      arena, elf_ctx, arg_m, arg_a, arg_b, stack_slot_off, type_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}
