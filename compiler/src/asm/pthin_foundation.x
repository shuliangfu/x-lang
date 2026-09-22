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

// pthin_foundation.x — G-02f-329 / Class AD P20b parser thin foundation bodies.
//
// Product hybrid: seeds/pthin_foundation.from_x.c keeps by-value
// lexer_init + arena_expr_get/set (no struct-by-value in .x). This file
// owns parser_asm_expr_set_common_zeros_c (pointer ABI). Offsets are
// pinned by _Static_assert offsetof in the seed TU — do not treat the
// constants here as a second layout authority.
//
// Hybrid P20b: g05_try_x_to_o this file;
// XLANG_PTHIN_FOUNDATION_BODIES_FROM_X skips the zeros body in
// parser_asm_foundation_slice.inc. Cap expr-watch (getenv/snprintf/io)
// was stripped Class AD — set path is memcpy + ast_arena_expr_set only.
// Cold: no BODIES define, full .inc zeros stay host-cc.
// PLATFORM: SHARED freestanding.

/** LE i32 store; shift-only (no div — pure-asm sdiv ban). */
#[no_mangle]
export function parser_asm_foundation_store_i32_le(p: *u8, off: i32, v: i32): void {
  let a: u32 = 0;
  if (p == 0 as *u8) {
    return;
  }
  unsafe {
    a = v as u32;
    p[off] = (a & 255) as u8;
    a = a >> 8;
    p[off + 1] = (a & 255) as u8;
    a = a >> 8;
    p[off + 2] = (a & 255) as u8;
    a = a >> 8;
    p[off + 3] = (a & 255) as u8;
  }
}

/**
 * expr_set_common_zeros C twin: field clear order matches
 * parser_asm_foundation_slice.inc (and parser.x). call_resolved_* = -1.
 * @param e *u8 — opaque parser_asm_ast_expr*; null is a no-op
 * PLATFORM: SHARED — Class AD P20b; Cap watch removed from set path.
 */
#[no_mangle]
export function parser_asm_expr_set_common_zeros_c(e: *u8): void {
  if (e == 0 as *u8) {
    return;
  }
  unsafe {
    // Offsets: seed _Static_assert pins (Darwin arm64 / Ubuntu x86_64).
    parser_asm_foundation_store_i32_le(e, 4, 0);      // resolved_type_ref
    parser_asm_foundation_store_i32_le(e, 292, 0);    // binop_left_ref
    parser_asm_foundation_store_i32_le(e, 296, 0);    // binop_right_ref
    parser_asm_foundation_store_i32_le(e, 300, 0);    // unary_operand_ref
    parser_asm_foundation_store_i32_le(e, 304, 0);    // if_cond_ref
    parser_asm_foundation_store_i32_le(e, 308, 0);    // if_then_ref
    parser_asm_foundation_store_i32_le(e, 312, 0);    // if_else_ref
    parser_asm_foundation_store_i32_le(e, 316, 0);    // block_ref
    parser_asm_foundation_store_i32_le(e, 320, 0);    // match_matched_ref
    parser_asm_foundation_store_i32_le(e, 324, 0);    // match_arm_base
    parser_asm_foundation_store_i32_le(e, 328, 0);    // match_num_arms
    parser_asm_foundation_store_i32_le(e, 324, 0);    // match_arm_base (inc twin re-clear)
    parser_asm_foundation_store_i32_le(e, 1204, 0);   // enum_variant_tag
    parser_asm_foundation_store_i32_le(e, 332, 0);    // field_access_base_ref
    parser_asm_foundation_store_i32_le(e, 592, 0);    // field_access_field_len
    parser_asm_foundation_store_i32_le(e, 596, 0);    // field_access_is_enum_variant
    parser_asm_foundation_store_i32_le(e, 600, 0);    // field_access_offset
    parser_asm_foundation_store_i32_le(e, 608, 0);    // index_base_ref
    parser_asm_foundation_store_i32_le(e, 612, 0);    // index_index_ref
    parser_asm_foundation_store_i32_le(e, 616, 0);    // index_base_is_slice
    parser_asm_foundation_store_i32_le(e, 620, 0);    // call_callee_ref
    parser_asm_foundation_store_i32_le(e, 624, 0);    // call_arg_base
    parser_asm_foundation_store_i32_le(e, 628, 0);    // call_num_args
    parser_asm_foundation_store_i32_le(e, 632, 0);    // call_num_type_args
    parser_asm_foundation_store_i32_le(e, 636, 0);    // method_call_base_ref
    parser_asm_foundation_store_i32_le(e, 896, 0);    // method_call_name_len
    parser_asm_foundation_store_i32_le(e, 900, 0);    // method_call_arg_base
    parser_asm_foundation_store_i32_le(e, 904, 0);    // method_call_num_args
    parser_asm_foundation_store_i32_le(e, 908, 0);    // const_folded_val
    parser_asm_foundation_store_i32_le(e, 912, 0);    // const_folded_valid
    parser_asm_foundation_store_i32_le(e, 916, 0);    // index_proven_in_bounds
    parser_asm_foundation_store_i32_le(e, 1180, 0);   // struct_lit_field_base
    parser_asm_foundation_store_i32_le(e, 1184, 0);   // struct_lit_num_fields
    parser_asm_foundation_store_i32_le(e, 1188, 0);   // array_lit_elem_base
    parser_asm_foundation_store_i32_le(e, 1192, 0);   // array_lit_num_elems
    parser_asm_foundation_store_i32_le(e, 1208, 0);   // as_operand_ref
    parser_asm_foundation_store_i32_le(e, 1212, 0);   // as_target_type_ref
    parser_asm_foundation_store_i32_le(e, 1216, -1);  // call_resolved_func_index
    parser_asm_foundation_store_i32_le(e, 1220, -1);  // call_resolved_dep_index
  }
}
