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

// pthin_skip_tl.x — G-02f-321 P12 parser thin skip top-level product bodies.
//
// 7.2.1 P12b B-minus productize (2026-09-13): after P14b skip_if walks,
// skip_tl.inc is the largest still-host-cc product slice. skip_one_struct
// is ~800 lines of already-T AUDIT nops around a short STRUCT/IDENT/angles
// /braces walk; skip_one_enum and skip_one_extern are the sibling walks
// (no trait-reg, no module). Reuse P1b skip_balanced + skip_generic_angle
// and the P9a lexer-step bridge. By-value lexer returns stay as C
// trampolines in seeds/pthin_skip_tl.from_x.c. stash_source (file-global
// generic-bound scan) stays in those trampolines. skip_one_trait
// (method-recording state machine + globals), enum_register (void* module),
// parse_one_extern (arena), and generic_bound_* stay C.
//
// 7.2.1 P12c B-minus (2026-09-13): 有则补全 this file with skip_one_impl.
// The header walk is B-minus (opaque lexer + P1b skip_generic_angle +
// P1b copy_slice). Language has no file-local static tables; dest
// buffers carry the first IDENT and optional for-type spelling, and
// the C trampoline writes its file-local tables. Do not wrap
// skip_one_trait. Do not skip_balanced_braces (wave390 leaves methods
// for outer parse_into). Do not open a new P-lane.
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
// Do not duplicate skip_balanced / skip_generic_angle_list (authority =
// pthin_lex_skip.x). Do not wrap glue_tail scattered AUDIT as a side
// effect. Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P12b/P12c: g05_try_x_to_o this file; XLANG_PTHIN_SKIP_TL_BODIES_FROM_X
// skips the portable .inc region (struct/enum/extern + impl header).
// Requires P9a bridge + P1b skip walks (otherwise skip_balanced /
// skip_generic_angle / copy_slice would UNDEF). token.h remains the
// TOKEN_* authority via P12 C _Static_assert pins. Cold: no define,
// full .inc. Do not reuse XLANG_PTHIN_SKIP_TL_FROM_X for P12b/P12c
// bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P1b authority: in-place skip of a balanced group (caller consumed opener). */
export extern "C" function parser_asm_skip_balanced_parens_into_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_balanced_braces_into_c(lex_inout: *u8, source: *u8): i32;
/** P1b authority: skip `<T, E, ...>`; entry is the start of `<`. */
export extern "C" function parser_asm_skip_generic_angle_list_into_c(lex_inout: *u8, source: *u8): i32;
/** P9a: restore-trio + IDENT capture (P1c pattern). */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
/** P1b authority: copy IDENT bytes into a 64-byte dest. */
export extern "C" function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;

// TOKEN_* pin copies of include/token.h (133 kinds). P12 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_FOR: i32 = 8;
const TOKEN_STRUCT: i32 = 19;
const TOKEN_ENUM: i32 = 47;
const TOKEN_IMPL: i32 = 50;
const TOKEN_EXTERN: i32 = 54;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;
const TOKEN_BOOL: i32 = 61;
const TOKEN_U8: i32 = 62;
const TOKEN_U32: i32 = 63;
const TOKEN_U64: i32 = 64;
const TOKEN_I64: i32 = 65;
const TOKEN_USIZE: i32 = 66;
const TOKEN_ISIZE: i32 = 67;
const TOKEN_F32: i32 = 77;
const TOKEN_F64: i32 = 78;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_STAR: i32 = 98;
const TOKEN_LT: i32 = 120;
const TOKEN_STRING: i32 = 130;
const IMPL_NAME_CAP: i32 = 64;

/**
 * Skip a top-level `struct Name[<T…>] { … }` to just after the matching `}`.
 * Entry cursor is the start of `struct`. Non-STRUCT first token: lexer
 * unmoved (C wrote `*out = lex`). After consuming STRUCT, a non-IDENT
 * leaves the lexer after `struct`. Optional `<…>` uses P1b
 * skip_generic_angle_list (entry is the start of `<`). Matching `{` is
 * consumed then skip_balanced_braces (P1b) walks the body.
 * @param lex_inout *u8 — opaque lexer (advanced past `}`, or left on the
 *   fail cursor described above)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12 B-minus; C trampoline keeps
 * `parser_asm_skip_one_struct_into_slice_c` and stashes the source for
 * the generic-bound scan before calling this.
 */
#[no_mangle]
export function parser_asm_skip_one_struct_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRUCT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LT) {
      parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind != TOKEN_LBRACE) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_braces_into_c(lex_inout, source);
  }
  return 1;
}

/**
 * Skip a top-level `enum Name { … }` to just after the matching `}`.
 * Entry cursor is the start of `enum`. Non-ENUM first token: lexer
 * unmoved. After consuming ENUM, a non-IDENT leaves the lexer after
 * `enum`. Matching `{` is consumed then skip_balanced_braces.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12 B-minus; C trampoline stashes source
 * then calls this. enum_register (void* module) stays C.
 */
#[no_mangle]
export function parser_asm_skip_one_enum_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_ENUM) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_braces_into_c(lex_inout, source);
  }
  return 1;
}

/**
 * Skip a top-level `extern ["ABI"] function name(…) : Ret;` declaration.
 * Entry cursor is the start of `extern`. Optional STRING ABI marker is
 * consumed without recording abi_kind (same as the C twin). Matching
 * `(` is consumed then skip_balanced_parens (P1b). After `:`, tokens
 * are stepped until SEMICOLON / EOF; SEMICOLON is consumed. Leaves the
 * lexer after `;` (or at EOF without consuming it).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12 B-minus; parse_one_extern (arena) stays C.
 */
#[no_mangle]
export function parser_asm_skip_one_extern_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_EXTERN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_STRING) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind != TOKEN_FUNCTION) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_parens_into_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
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
 * Skip an `impl` header through the opening `{`, leaving the body for
 * outer parse_into (wave390 does not skip_balanced_braces).
 * Entry cursor is the start of `impl`. Non-IMPL first token: lexer
 * unmoved. Optional `impl<T…>` uses P1b skip_generic_angle_list (entry
 * is the start of `<`). The first type/trait token must be IDENT or a
 * scalar type keyword. Optional `for [*]? Type[<T…>]` is consumed the
 * same way. Matching `{` is consumed; the lexer is left after `{`.
 * Dest buffers capture the first IDENT spelling (cap 63) and, when
 * `for` is seen, the for-type IDENT spelling plus STAR/token-kind so
 * the C trampoline can update its file-local tables. This file does
 * not write those tables.
 * @param lex_inout *u8 — opaque lexer (advanced past `{`, or left on
 *   the fail cursor: start of the unconsumed failing token)
 * @param source *u8 — opaque slice
 * @param first_nm *u8 — dest 64-byte first IDENT; trampoline owns it
 * @param first_nlen *i32 — out slot; 0 if first token is not IDENT
 * @param impl_line *i32 — out slot; IMPL token line
 * @param impl_col *i32 — out slot; IMPL token column
 * @param saw_for *i32 — out slot; 1 if `for` was consumed
 * @param for_is_ptr *i32 — out slot; 1 if `for *Type`
 * @param for_tok_kind *i32 — out slot; TOKEN_* of the for-type, or 0
 * @param for_nm *u8 — dest 64-byte for-type IDENT
 * @param for_nlen *i32 — out slot; 0 if for-type is not IDENT
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12c B-minus; C trampoline keeps
 * `parser_asm_skip_one_impl_into_slice_c` and writes file-local tables.
 * Do not wrap skip_one_trait. Do not duplicate skip_generic_angle_list
 * or copy_slice (authority = pthin_lex_skip.x).
 */
#[no_mangle]
export function parser_asm_skip_one_impl_into_c(lex_inout: *u8, source: *u8, first_nm: *u8, first_nlen: *i32, impl_line: *i32, impl_col: *i32, saw_for: *i32, for_is_ptr: *i32, for_tok_kind: *i32, for_nm: *u8, for_nlen: *i32): i32 {
  let kind: i32 = 0;
  let pl: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  let is_ty: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || first_nm == 0 as *u8 || first_nlen == 0 as *i32 || impl_line == 0 as *i32 || impl_col == 0 as *i32 || saw_for == 0 as *i32 || for_is_ptr == 0 as *i32 || for_tok_kind == 0 as *i32 || for_nm == 0 as *u8 || for_nlen == 0 as *i32) {
    return 0;
  }
  unsafe {
    first_nlen[0] = 0;
    impl_line[0] = 0;
    impl_col[0] = 0;
    saw_for[0] = 0;
    for_is_ptr[0] = 0;
    for_tok_kind[0] = 0;
    for_nlen[0] = 0;
    zi = 0;
    while (zi < IMPL_NAME_CAP) {
      first_nm[zi as usize] = 0;
      for_nm[zi as usize] = 0;
      zi = zi + 1;
    }
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    if (slen_us > 2147483647 as usize) {
      slen = 2147483647;
    } else {
      slen = slen_us as i32;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IMPL) {
      return 1;
    }
    impl_line[0] = parser_asm_lex_line_c(lex_inout);
    impl_col[0] = parser_asm_lex_col_c(lex_inout);
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LT) {
      parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    is_ty = 0;
    if (kind == TOKEN_IDENT || kind == TOKEN_I32 || kind == TOKEN_I64 || kind == TOKEN_BOOL || kind == TOKEN_U8 || kind == TOKEN_U32 || kind == TOKEN_U64 || kind == TOKEN_USIZE || kind == TOKEN_ISIZE || kind == TOKEN_F32 || kind == TOKEN_F64) {
      is_ty = 1;
    }
    if (is_ty == 0) {
      return 1;
    }
    if (kind == TOKEN_IDENT) {
      pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (pl > 63) {
        pl = 63;
      }
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      if (ts == 0 as usize) {
        ts = parser_asm_lex_pos_c(lex_inout);
      }
      if (pl > 0 && data != 0 as *u8) {
        parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, first_nm);
        first_nlen[0] = pl;
      }
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LT) {
      parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind == TOKEN_FOR) {
      saw_for[0] = 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_STAR) {
        for_is_ptr[0] = 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      }
      is_ty = 0;
      if (kind == TOKEN_IDENT || kind == TOKEN_I32 || kind == TOKEN_I64 || kind == TOKEN_BOOL || kind == TOKEN_U8 || kind == TOKEN_U32 || kind == TOKEN_U64 || kind == TOKEN_USIZE || kind == TOKEN_ISIZE || kind == TOKEN_F32 || kind == TOKEN_F64) {
        is_ty = 1;
      }
      if (is_ty == 0) {
        return 1;
      }
      for_tok_kind[0] = kind;
      if (kind == TOKEN_IDENT) {
        pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (pl > 63) {
          pl = 63;
        }
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        if (ts == 0 as usize) {
          ts = parser_asm_lex_pos_c(lex_inout);
        }
        if (pl > 0 && data != 0 as *u8) {
          parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, for_nm);
          for_nlen[0] = pl;
        }
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_LT) {
        parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      }
    }
    if (kind != TOKEN_LBRACE) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}
