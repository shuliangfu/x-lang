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

// pthin_imports.x — G-02f-320 P11 parser thin imports product bodies.
//
// 7.2.1 P11b B-minus productize (2026-09-13): after P13b try_skip_allow
// padding, imports.inc is the next still-host-cc product slice whose
// skip walk is portable. skip_imports is a peek loop over ATTR_CFG /
// pending cfg-skip / CONST + try_skip_const_import. Reuse the P9a
// lexer-step bridge. try_skip_const_import_stmt (consume_path + path
// buffer + stretch validate/finalize) stays C. collect_imports
// (void* module + binding/path buffers) stays C; its contiguous
// already-T AUDIT prefix is compiled only under
// XLANG_PARSER_STRETCH_AUDIT (same slice, P4ub pattern).
// By-value lexer returns stay as C trampolines in
// seeds/pthin_imports.from_x.c (language has no struct-by-value).
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
// Do not duplicate consume_path / collect_imports (authority = .inc).
// Do not wrap skip_one_trait/impl (trait-reg globals).
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P11b: g05_try_x_to_o this file;
// XLANG_PTHIN_IMPORTS_BODIES_FROM_X skips the portable .inc region.
// Requires P9a bridge (otherwise peek/step would UNDEF). token.h
// remains the TOKEN_* authority via P11 C _Static_assert pins. Cold:
// no define, full .inc. Do not reuse XLANG_PTHIN_IMPORTS_FROM_X for
// P11b bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's int_val (ATTR_CFG keep/skip flag) without advancing. */
export extern "C" function parser_asm_lex_peek_int_val_c(lex_inout: *u8, source: *u8): i32;
/** P18 C authority: apply cfg-skip of the next top-level item; returns new pending. */
export extern "C" function parser_asm_cfg_skip_pending_apply_c(lex_inout: *u8, source: *u8, pending: i32): i32;
/** C authority: skip `IDENT = import("path");` after CONST; 1 updates lex, 0 unmoved. */
export extern "C" function parser_asm_try_skip_const_import_stmt(lex_inout: *u8, source: *u8): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P11 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_CONST: i32 = 3;
const TOKEN_ATTR_CFG: i32 = 24;

/**
 * Skip leading top-level `const name = import("path");` statements
 * (and `#[cfg]` that prunes the following top-level item).
 * Entry cursor is the start of the first token. Peek ATTR_CFG: step
 * and set pending from int_val==0. While pending, P18 cfg-skip
 * consumes the next top-level construct (const/let/struct/function).
 * Peek CONST: step then try_skip_const_import_stmt (C; consume_path
 * stays C). Non-CONST / failed try_skip: leave the lexer at that
 * cursor (after CONST on a failed import-shaped stmt, unmoved on
 * a non-CONST peek), matching the C twin.
 * @param lex_inout *u8 — opaque lexer (advanced to the first
 *   non-import token, or left after a failed CONST)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P11 B-minus; C trampoline keeps
 * `parser_asm_skip_imports_slice_c` and the buf twin.
 */
#[no_mangle]
export function parser_asm_skip_imports_into_c(lex_inout: *u8, source: *u8): i32 {
  let pending: i32 = 0;
  let kind: i32 = 0;
  let skipped: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      // B-01/B-19: unmatched `#[cfg]` prunes the following top-level item.
      if (kind == TOKEN_ATTR_CFG) {
        pending = 0;
        if (parser_asm_lex_peek_int_val_c(lex_inout, source) == 0) {
          pending = 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (pending != 0) {
        pending = parser_asm_cfg_skip_pending_apply_c(lex_inout, source, pending);
        if (pending != 0) {
          pending = 0;
        }
        continue;
      }
      if (kind != TOKEN_CONST) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      skipped = parser_asm_try_skip_const_import_stmt(lex_inout, source);
      if (skipped != 0) {
        continue;
      }
      return 1;
    }
  }
  return 1;
}
