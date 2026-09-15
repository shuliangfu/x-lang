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

// pthin_fn_block.x — G-02f-287 P6 parser thin fn/block product bodies.
//
// 7.2.1 P6b B-minus (2026-09-15): 有则补全 this existing P6 file with the
// three always-compiled struct-layout name matchers. The C bodies lived
// in struct_layout.inc (always host-cc, not behind BODIES). ABI is already
// pointer-legal (opaque module + name bytes). parse_struct_record_layout
// and library_slice stay C and call these symbols; do not copy the
// compare loops into those consumers. Do not open a new P-lane.
// pipeline_module_struct_layout_* stay the sidecar authority
// (runtime_pipeline_abi.x). parse / library / one_function / block_from_res
// stay C. Compare cap `ii < 64` is the C twin's historical bound — keep it.
// 7.2.1 P6c B-minus (2026-09-15): 有则补全 packed/soa modifier predicates.
// Language has no lexer_result field access; the C trampoline in
// struct_layout.inc forwards tok.kind / ident_len / next_lex.pos plus
// source data/length. IDENT fallback uses next_pos - ident_len (same
// formula as the C twin; do not switch to token_start). Do not merge
// with P19d field-name kind (field start vs struct-name modifier).
// Do not copy these probes into parse_struct_record_layout. Do not
// open a new P-lane.
//
// Hybrid P6b/P6c: g05_try_x_to_o this file; XLANG_PTHIN_FN_BLOCK_BODIES_FROM_X
// skips the portable .inc region (name-match trio + modifier predicates).
// No lexer-step bridge. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_FN_BLOCK_FROM_X for P6b/P6c bodies.
// PLATFORM: SHARED freestanding.

/** Sidecar: count of struct layouts on the opaque module. */
export extern "C" function pipeline_module_num_struct_layouts_at(module: *u8): i32;
/** Sidecar: layout name length at idx; 0 if empty/missing. */
export extern "C" function pipeline_module_struct_layout_name_len(module: *u8, idx: i32): i32;
/** Sidecar: one name byte at (idx, off). */
export extern "C" function pipeline_module_struct_layout_name_byte_at(module: *u8, idx: i32, off: i32): u8;
/** Sidecar: field count at layout idx. */
export extern "C" function pipeline_module_struct_layout_num_fields(module: *u8, idx: i32): i32;
/** Sidecar: field-name length at (layout, field). */
export extern "C" function pipeline_module_struct_layout_field_name_len(module: *u8, li: i32, j: i32): i32;
/** Sidecar: field type_ref at (layout, field). */
export extern "C" function pipeline_module_struct_layout_field_type_ref(module: *u8, li: i32, j: i32): i32;

// TOKEN_* pin copies of include/token.h. P6 C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_PACKED: i32 = 21;
const TOKEN_SOA: i32 = 22;
const TOKEN_IDENT: i32 = 59;

/**
 * Return 1 if `module` already has a struct layout whose name equals
 * `nm[0..nlen)` (byte-exact; compare stops at 64 bytes, matching the C twin).
 * @param module *u8 — opaque ast_Module; null → 0
 * @param nm *u8 — spelling bytes (not required to be NUL-terminated)
 * @param nlen i32 — content length; <= 0 → 0
 * @return i32 — 1 if a slot matches, 0 otherwise
 * PLATFORM: SHARED — product P6b B-minus. Authority for
 * `parser_asm_struct_layout_name_exists_arr_c`. Consumers are
 * parse_struct_record_layout and library_slice; do not copy this loop.
 */
#[no_mangle]
export function parser_asm_struct_layout_name_exists_arr_c(module: *u8, nm: *u8, nlen: i32): i32 {
  let k: i32 = 0;
  let nsl: i32 = 0;
  let ii: i32 = 0;
  let same: i32 = 0;
  let b: u8 = 0;
  if (module == 0 as *u8 || nm == 0 as *u8 || nlen <= 0) {
    return 0;
  }
  unsafe {
    nsl = pipeline_module_num_struct_layouts_at(module);
    k = 0;
    while (k < nsl) {
      if (pipeline_module_struct_layout_name_len(module, k) == nlen) {
        same = 1;
        ii = 0;
        while (ii < nlen && ii < 64) {
          b = pipeline_module_struct_layout_name_byte_at(module, k, ii);
          if (b != nm[ii as usize]) {
            same = 0;
            break;
          }
          ii = ii + 1;
        }
        if (same != 0) {
          return 1;
        }
      }
      k = k + 1;
    }
  }
  return 0;
}

/**
 * Return the first struct-layout index whose name equals `nm[0..nlen)`,
 * or -1 if none (byte-exact; compare stops at 64 bytes, matching the C twin).
 * @param module *u8 — opaque ast_Module; null → -1
 * @param nm *u8 — spelling bytes (not required to be NUL-terminated)
 * @param nlen i32 — content length; <= 0 → -1
 * @return i32 — sidecar index >= 0, or -1
 * PLATFORM: SHARED — product P6b B-minus. parse_struct_record_layout uses
 * this for duplicate-name replace; do not copy the loop into that C body.
 */
#[no_mangle]
export function parser_asm_struct_layout_first_name_match_idx_c(module: *u8, nm: *u8, nlen: i32): i32 {
  let k: i32 = 0;
  let nsl: i32 = 0;
  let ii: i32 = 0;
  let same: i32 = 0;
  let b: u8 = 0;
  if (module == 0 as *u8 || nm == 0 as *u8 || nlen <= 0) {
    return -1;
  }
  unsafe {
    nsl = pipeline_module_num_struct_layouts_at(module);
    k = 0;
    while (k < nsl) {
      if (pipeline_module_struct_layout_name_len(module, k) == nlen) {
        same = 1;
        ii = 0;
        while (ii < nlen && ii < 64) {
          b = pipeline_module_struct_layout_name_byte_at(module, k, ii);
          if (b != nm[ii as usize]) {
            same = 0;
            break;
          }
          ii = ii + 1;
        }
        if (same != 0) {
          return k;
        }
      }
      k = k + 1;
    }
  }
  return -1;
}

/**
 * Return the index of a same-name *placeholder* layout (library pre-register
 * overlay), or -1. A match is a placeholder when nf==0, or nf==1 with empty
 * field name, or nf==1 with type_ref==0. Name compare stops at 64 bytes.
 * @param module *u8 — opaque ast_Module; null → -1
 * @param nm *u8 — spelling bytes (not required to be NUL-terminated)
 * @param nlen i32 — content length; <= 0 → -1
 * @return i32 — placeholder sidecar index >= 0, or -1
 * PLATFORM: SHARED — product P6b B-minus. parse_struct_record_layout overlays
 * library placeholders; do not copy this scan into that C body.
 */
#[no_mangle]
export function parser_asm_struct_layout_placeholder_idx_c(module: *u8, nm: *u8, nlen: i32): i32 {
  let k: i32 = 0;
  let nsl: i32 = 0;
  let ii: i32 = 0;
  let same: i32 = 0;
  let nf: i32 = 0;
  let b: u8 = 0;
  if (module == 0 as *u8 || nm == 0 as *u8 || nlen <= 0) {
    return -1;
  }
  unsafe {
    nsl = pipeline_module_num_struct_layouts_at(module);
    k = 0;
    while (k < nsl) {
      if (pipeline_module_struct_layout_name_len(module, k) == nlen) {
        same = 1;
        ii = 0;
        while (ii < nlen && ii < 64) {
          b = pipeline_module_struct_layout_name_byte_at(module, k, ii);
          if (b != nm[ii as usize]) {
            same = 0;
            break;
          }
          ii = ii + 1;
        }
        if (same != 0) {
          nf = pipeline_module_struct_layout_num_fields(module, k);
          if (nf == 0) {
            return k;
          }
          if (nf == 1 && pipeline_module_struct_layout_field_name_len(module, k, 0) == 0) {
            return k;
          }
          if (nf == 1 && pipeline_module_struct_layout_field_type_ref(module, k, 0) == 0) {
            return k;
          }
        }
      }
      k = k + 1;
    }
  }
  return -1;
}

/**
 * True when the current token is a `packed` struct-layout modifier:
 * TOKEN_PACKED, or IDENT whose six bytes ending at `next_pos` are `packed`.
 * @param kind i32 — lexer token kind (token.h)
 * @param ident_len i32 — IDENT payload length (ignored unless kind is IDENT)
 * @param next_pos usize — lexer pos after the token (IDENT end)
 * @param data *u8 — source bytes; IDENT fallback is 0 if null
 * @param length usize — source length
 * @return i32 — 1 if packed modifier, 0 otherwise
 * PLATFORM: SHARED — product P6c B-minus. Authority for
 * `parser_asm_tok_is_modifier_packed`. parse_struct_record_layout stays C
 * and calls the historical static via a zero-algorithm trampoline.
 * Do not merge with P19d field-name kind. IDENT start is
 * `next_pos - ident_len` (C twin formula; do not use token_start).
 */
#[no_mangle]
export function parser_asm_tok_is_modifier_packed_c(kind: i32, ident_len: i32, next_pos: usize, data: *u8, length: usize): i32 {
  let start: usize = 0;
  let b0: u8 = 0;
  let b1: u8 = 0;
  let b2: u8 = 0;
  let b3: u8 = 0;
  let b4: u8 = 0;
  let b5: u8 = 0;
  if (kind == TOKEN_PACKED) {
    return 1;
  }
  if (kind != TOKEN_IDENT || ident_len != 6) {
    return 0;
  }
  if (data == 0 as *u8) {
    return 0;
  }
  start = next_pos - (ident_len as usize);
  if (start + 6 as usize > length) {
    return 0;
  }
  unsafe {
    b0 = data[start];
    b1 = data[start + 1 as usize];
    b2 = data[start + 2 as usize];
    b3 = data[start + 3 as usize];
    b4 = data[start + 4 as usize];
    b5 = data[start + 5 as usize];
  }
  if (b0 == 112 && b1 == 97 && b2 == 99 && b3 == 107 && b4 == 101 && b5 == 100) {
    return 1;
  }
  return 0;
}

/**
 * True when the current token is an `soa` struct-layout modifier:
 * TOKEN_SOA, or IDENT whose three bytes ending at `next_pos` are `soa`.
 * @param kind i32 — lexer token kind (token.h)
 * @param ident_len i32 — IDENT payload length (ignored unless kind is IDENT)
 * @param next_pos usize — lexer pos after the token (IDENT end)
 * @param data *u8 — source bytes; IDENT fallback is 0 if null
 * @param length usize — source length
 * @return i32 — 1 if soa modifier, 0 otherwise
 * PLATFORM: SHARED — product P6c B-minus. Authority for
 * `parser_asm_tok_is_modifier_soa`. parse_struct_record_layout stays C
 * and calls the historical static via a zero-algorithm trampoline.
 * Do not merge with packed (left/right vs unary analog: 6-byte vs 3-byte
 * spelling) or with P19d field-name kind.
 */
#[no_mangle]
export function parser_asm_tok_is_modifier_soa_c(kind: i32, ident_len: i32, next_pos: usize, data: *u8, length: usize): i32 {
  let start: usize = 0;
  let b0: u8 = 0;
  let b1: u8 = 0;
  let b2: u8 = 0;
  if (kind == TOKEN_SOA) {
    return 1;
  }
  if (kind != TOKEN_IDENT || ident_len != 3) {
    return 0;
  }
  if (data == 0 as *u8) {
    return 0;
  }
  start = next_pos - (ident_len as usize);
  if (start + 3 as usize > length) {
    return 0;
  }
  unsafe {
    b0 = data[start];
    b1 = data[start + 1 as usize];
    b2 = data[start + 2 as usize];
  }
  if (b0 == 115 && b1 == 111 && b2 == 97) {
    return 1;
  }
  return 0;
}
