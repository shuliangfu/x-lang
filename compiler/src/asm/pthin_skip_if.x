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

// pthin_skip_if.x — G-02f-323 P14 parser thin skip_if product bodies.
//
// 7.2.1 P14b B-minus productize (2026-09-13): after P4bb binop TOKEN table,
// skip_if.inc is the next still-host-cc product slice whose skip walks
// reuse P1b skip_balanced + the P9a lexer-step bridge. Trait/impl block
// skip and if-core / if-statement walks are B-minus (opaque lexer).
// By-value lexer_result returns stay as C trampolines in
// seeds/pthin_skip_if.from_x.c (language has no struct-by-value).
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
// Do not duplicate skip_balanced (authority = pthin_lex_skip.x).
// Do not wrap glue_tail scattered AUDIT as a side effect.
//
// 7.2.1 P14c B-minus (2026-09-15): 有则补全 this file with
// module_try_register_enum_name. The C body lived in skip_if.inc
// (always host-cc, not behind BODIES). ABI is already pointer-legal
// (opaque module + name bytes); P12e skip_one_enum_register calls
// this symbol as an extern. Do not copy the dedupe loop into P12e.
// Do not open a new P-lane. pipeline_module_enum_* stay the sidecar
// authority (runtime_pipeline_abi.x).
//
// Hybrid P14b/P14c: g05_try_x_to_o this file; XLANG_PTHIN_SKIP_IF_BODIES_FROM_X
// skips the portable .inc region. Requires P9a bridge + P1b skip_balanced
// (otherwise skip_balanced would UNDEF). token.h remains the TOKEN_*
// authority via P14 C _Static_assert pins. Cold: no define, full .inc.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** Read / write the restore trio (pos, line, col). */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
/** P1b authority: in-place skip of a balanced group (caller consumed opener). */
export extern "C" function parser_asm_skip_balanced_parens_into_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_balanced_braces_into_c(lex_inout: *u8, source: *u8): i32;
/** Pipeline sidecar: enum name table. Authority = runtime_pipeline_abi.x. */
export extern "C" function pipeline_module_enum_name_len(module: *u8, idx: i32): i32;
export extern "C" function pipeline_module_enum_name_byte_at(module: *u8, idx: i32, off: i32): u8;
export extern "C" function pipeline_module_enum_alloc(module: *u8): i32;
export extern "C" function pipeline_module_enum_set_name(module: *u8, idx: i32, bytes: *u8, len: i32): void;

// TOKEN_* pin copies of include/token.h (133 kinds). P14 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_IF: i32 = 4;
const TOKEN_ELSE: i32 = 5;
const TOKEN_TRAIT: i32 = 49;
const TOKEN_IMPL: i32 = 50;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_SEMICOLON: i32 = 95;

/**
 * Skip a top-level `trait` / `impl` block to just after the matching `}`.
 * Entry cursor is the start of the keyword (or already at `{`). On EOF
 * before `{` the restore trio snaps back to the entry cursor (C twin
 * wrote `*out = start`). Matching `{` is consumed then skip_balanced_braces
 * (P1b) walks the body; the lexer is left after `}`.
 * @param lex_inout *u8 — opaque lexer (advanced past `}`, or restored)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success path (including EOF restore); 0 on null
 * PLATFORM: SHARED — product P14 B-minus; C trampoline keeps the original
 * `parser_asm_skip_trait_impl_block_raw_c` name (lexer* out, lexer start).
 */
#[no_mangle]
export function parser_asm_skip_trait_impl_block_raw_into_c(lex_inout: *u8, source: *u8): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_TRAIT || kind == TOKEN_IMPL) {
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_LBRACE) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        parser_asm_skip_balanced_braces_into_c(lex_inout, source);
        return 1;
      }
      if (kind == TOKEN_EOF) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Skip `if (cond) { ... }` / `if (cond) stmt;` from the token after `if`
 * (the `(`). Leaves the lexer at the start of the token after the
 * construct so the C trampoline can `lexer_next_into` to fill *out.
 * Non-`(` first token: lexer unmoved (trampoline materializes that token).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success path; 0 on null
 * PLATFORM: SHARED — product P14 B-minus.
 */
#[no_mangle]
export function parser_asm_skip_one_if_core_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_parens_into_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LBRACE) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      parser_asm_skip_balanced_braces_into_c(lex_inout, source);
      return 1;
    }
    while (kind != TOKEN_SEMICOLON && kind != TOKEN_EOF) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind == TOKEN_SEMICOLON) {
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Skip a full `if` including `else` / `else if` chains. Calls
 * skip_one_if_core then walks ELSE. Leaves the lexer at the start of
 * the token after the whole statement (C trampoline materializes *out).
 * @param lex_inout *u8 — opaque lexer (at `(` after `if`, same as core)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success path; 0 on null
 * PLATFORM: SHARED — product P14 B-minus.
 */
#[no_mangle]
export function parser_asm_skip_one_if_statement_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    parser_asm_skip_one_if_core_into_c(lex_inout, source);
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_ELSE) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_IF) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        parser_asm_skip_one_if_core_into_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_LBRACE) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        parser_asm_skip_balanced_braces_into_c(lex_inout, source);
        continue;
      }
      while (kind != TOKEN_SEMICOLON && kind != TOKEN_EOF) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      }
      if (kind == TOKEN_SEMICOLON) {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
    }
  }
  return 1;
}

/**
 * Register a top-level enum type name on the opaque module sidecar.
 * Walks existing entries for an exact name match (dedupe); on miss
 * allocates a new slot and copies `name[0..name_len)`.
 * @param module *u8 — opaque ast_Module; null → -1
 * @param name *u8 — enum spelling bytes (not required to be NUL-terminated)
 * @param name_len i32 — content length; must be 1..255 (storage name[256])
 * @return i32 — sidecar index (>=0) on match or insert; -1 on null / bad len / alloc fail
 * PLATFORM: SHARED — product P14c B-minus. Authority for
 * `parser_asm_module_try_register_enum_name_c`. P12e calls this; do not
 * copy the dedupe loop into skip_one_enum_register. Do not open a new P-lane.
 */
#[no_mangle]
export function parser_asm_module_try_register_enum_name_c(module: *u8, name: *u8, name_len: i32): i32 {
  let ei: i32 = 0;
  let j: i32 = 0;
  let slot: i32 = 0;
  let cur_len: i32 = 0;
  let eq: i32 = 0;
  let b: u8 = 0;
  if (module == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || name_len > 255) {
    return -1;
  }
  unsafe {
    ei = 0;
    while (true) {
      cur_len = pipeline_module_enum_name_len(module, ei);
      if (cur_len <= 0) {
        break;
      }
      if (cur_len == name_len) {
        eq = 1;
        j = 0;
        while (j < name_len) {
          b = pipeline_module_enum_name_byte_at(module, ei, j);
          if (b != name[j as usize]) {
            eq = 0;
            break;
          }
          j = j + 1;
        }
        if (eq != 0) {
          return ei;
        }
      }
      ei = ei + 1;
    }
    slot = pipeline_module_enum_alloc(module);
    if (slot < 0) {
      return -1;
    }
    pipeline_module_enum_set_name(module, slot, name, name_len);
  }
  return slot;
}
