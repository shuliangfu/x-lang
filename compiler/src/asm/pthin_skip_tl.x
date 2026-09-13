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
// parse_one_extern (arena) stay C. generic_bound_scan walk is P12d;
// check / register / stash stay C.
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
// 7.2.1 P12d B-minus (2026-09-13): 有则补全 this file with
// generic_bound_scan. The full-file token walk is B-minus (opaque lexer
// + P1b skip_generic_angle + P1b copy_slice). Language has no file-local
// static tables; dest buffers are the C g_fn_bound_* / g_call_* /
// g_fn_gp_* arrays (flat *u8 / *i32). Do not wrap skip_one_trait.
// Do not duplicate skip_generic_angle_list or copy_slice. Do not open
// a new P-lane. Check / register / stash stay C.
//
// 7.2.1 P12e B-minus (2026-09-13): 有则补全 this file with
// skip_one_enum_register + append_enum_variants. The token walk is
// B-minus (opaque lexer + P1b copy_slice). Language has no local
// u8[N]; dest 128-byte name/variant scratches are C-stack-owned.
// Module writes stay in the existing C helpers (try_register +
// pipeline_module_enum_append_variant) called as externs. Do not
// wrap skip_one_trait. Do not call skip_one_enum (opaque brace skip
// would drop variant capture). Do not open a new P-lane.
//
// 7.2.1 P12f B-minus (2026-09-13): 有则补全 this file with
// parse_one_extern_skip. The token walk is B-minus (opaque lexer +
// P1b copy_slice). Language has no local u8[N]; dest 64-byte name and
// 256-byte param scratches are C-stack-owned. type_ref parse and
// onefunc append stay the existing C helpers called as externs
// (pointer-ABI wrap for the by-value lexer IN). Do not wrap
// skip_one_trait. Do not call skip_one_extern (opaque paren skip
// would drop param/type capture). Do not open a new P-lane.
// parse_one_extern_and_add (arena+module+ast_Func) stays C.
//
// Hybrid P12b/P12c/P12d/P12e/P12f: g05_try_x_to_o this file; XLANG_PTHIN_SKIP_TL_BODIES_FROM_X
// skips the portable .inc region (struct/enum/extern + impl header +
// generic_bound_scan + enum_register + parse_one_extern_skip). Requires P9a bridge + P1b skip
// walks (otherwise skip_balanced / skip_generic_angle / copy_slice
// would UNDEF). token.h remains the TOKEN_* authority via P12 C
// _Static_assert pins. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_SKIP_TL_FROM_X for P12b/P12c/P12d/P12e/P12f bodies.
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
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
/** P1b authority: copy IDENT bytes into a dest (nlen bytes; caller sizes it). */
export extern "C" function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P1b authority: 256-byte param/name row (zeros past nlen). */
export extern "C" function parser_asm_copy_slice_to_param32_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P12f: pointer-ABI wrap of parse_type_ref_for_arena (C still owns the walk). */
export extern "C" function parser_asm_skip_tl_parse_type_ref_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;
/** Pipeline onefunc pool: append a param name; type_ref filled later. */
export extern "C" function pipeline_onefunc_append_param(pool: *u8, name: *u8, name_len: i32, type_ref: i32): i32;
/** Pipeline onefunc pool: write param i's type_ref. */
export extern "C" function pipeline_onefunc_set_param_type_ref(pool: *u8, i: i32, type_ref: i32): void;
/** P14 skip_if authority: register enum name on the opaque module; -1 on fail. */
export extern "C" function parser_asm_module_try_register_enum_name_c(module: *u8, name: *u8, name_len: i32): i32;
/** Pipeline sidecar: append one variant name to enum slot `idx`. */
export extern "C" function pipeline_module_enum_append_variant(module: *u8, idx: i32, bytes: *u8, len: i32): i32;

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
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_RBRACE: i32 = 85;
const TOKEN_COMMA: i32 = 90;
const TOKEN_COLON: i32 = 91;
const TOKEN_DOT: i32 = 92;
const TOKEN_ELLIPSIS: i32 = 94;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_PLUS: i32 = 96;
const TOKEN_STAR: i32 = 98;
const TOKEN_ASSIGN: i32 = 117;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;
const TOKEN_STRING: i32 = 130;
const IMPL_NAME_CAP: i32 = 64;
const FN_BOUND_MAX: i32 = 16;
const GENERIC_CALL_MAX: i32 = 32;
const GENERIC_CALL_MAX_ARGS: i32 = 4;
const FN_GP_MAX: i32 = 32;
const BOUND_NAME_CAP: i32 = 64;
const ENUM_NAME_CAP: i32 = 128;
const EXTERN_NAME_CAP: i32 = 64;
const PARAM_NAME_MAX: i32 = 127;
const BYTE_ABI_C: u8 = 67;
const BYTE_ABI_X: u8 = 88;

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
 * then calls this. enum_register is P12e (module writes stay C helpers).
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
 * PLATFORM: SHARED — product P12 B-minus; parse_one_extern_skip is P12f
 * (different contract: captures types/params). Do not merge the two.
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

/**
 * Peek `impl[<T>] Type [for Type]` without moving the caller's lexer.
 * Entry cursor is the start of `<` (C used a local lexer copy). Restore
 * trio always snaps back before return. On `impl<T> Foo` the captured
 * name is Foo; on `impl<T> Foo for Bar` it is Bar (for-type).
 * @param lex *u8 — opaque lexer; restored on every path
 * @param source *u8 — opaque slice
 * @param name64 *u8 — dest 64-byte IDENT; caller owns it
 * @return i32 — captured IDENT length (1..63) on success; 0 on fail / null
 * PLATFORM: SHARED — P12d helper; not a second skip_generic_angle.
 * Language has no address-of for local i32; length is the return value.
 */
function parser_asm_skip_tl_peek_impl_for_type(lex: *u8, source: *u8, name64: *u8): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let kind: i32 = 0;
  let pl: i32 = 0;
  let n1: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  if (lex == 0 as *u8 || source == 0 as *u8 || name64 == 0 as *u8) {
    return 0;
  }
  unsafe {
    zi = 0;
    while (zi < BOUND_NAME_CAP) {
      name64[zi as usize] = 0;
      zi = zi + 1;
    }
    pos0 = parser_asm_lex_pos_c(lex);
    line0 = parser_asm_lex_line_c(lex);
    col0 = parser_asm_lex_col_c(lex);
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    if (slen_us > 2147483647 as usize) {
      slen = 2147483647;
    } else {
      slen = slen_us as i32;
    }
    parser_asm_skip_generic_angle_list_into_c(lex, source);
    kind = parser_asm_lex_peek_kind_c(lex, source);
    if (kind != TOKEN_IDENT) {
      parser_asm_lex_set_pos_c(lex, pos0);
      parser_asm_lex_set_line_c(lex, line0);
      parser_asm_lex_set_col_c(lex, col0);
      return 0;
    }
    pl = parser_asm_lex_peek_ident_len_c(lex, source);
    if (pl > 63) {
      pl = 63;
    }
    ts = parser_asm_lex_peek_token_start_c(lex, source);
    if (ts == 0 as usize) {
      ts = parser_asm_lex_pos_c(lex);
    }
    if (pl > 0 && data != 0 as *u8) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, name64);
      n1 = pl;
    }
    parser_asm_lex_step_kind_c(lex, source);
    kind = parser_asm_lex_peek_kind_c(lex, source);
    if (kind == TOKEN_LT) {
      parser_asm_skip_generic_angle_list_into_c(lex, source);
      kind = parser_asm_lex_peek_kind_c(lex, source);
    }
    if (kind == TOKEN_FOR) {
      parser_asm_lex_step_kind_c(lex, source);
      kind = parser_asm_lex_peek_kind_c(lex, source);
      if (kind == TOKEN_STAR) {
        parser_asm_lex_step_kind_c(lex, source);
        kind = parser_asm_lex_peek_kind_c(lex, source);
      }
      if (kind != TOKEN_IDENT) {
        parser_asm_lex_set_pos_c(lex, pos0);
        parser_asm_lex_set_line_c(lex, line0);
        parser_asm_lex_set_col_c(lex, col0);
        return 0;
      }
      pl = parser_asm_lex_peek_ident_len_c(lex, source);
      if (pl > 63) {
        pl = 63;
      }
      ts = parser_asm_lex_peek_token_start_c(lex, source);
      if (ts == 0 as usize) {
        ts = parser_asm_lex_pos_c(lex);
      }
      zi = 0;
      while (zi < BOUND_NAME_CAP) {
        name64[zi as usize] = 0;
        zi = zi + 1;
      }
      n1 = 0;
      if (pl > 0 && data != 0 as *u8) {
        parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, name64);
        n1 = pl;
      }
    }
    parser_asm_lex_set_pos_c(lex, pos0);
    parser_asm_lex_set_line_c(lex, line0);
    parser_asm_lex_set_col_c(lex, col0);
    if (n1 <= 0) {
      return 0;
    }
  }
  return n1;
}

/**
 * Full-file generic-bound scan: record `Name<T: Trait>` bounds, declaration
 * type-param names, and simple `callee<A,B>` instantiations into dest
 * tables. Entry lexer is a freshly inited cursor (line=1 col=1 pos=0).
 * C trampoline owns the file-local g_fn_bound_* / g_call_* / g_fn_gp_*
 * arrays and passes them as flat dest buffers. last_nm is 64-byte scratch
 * for the most recent IDENT (language has no local u8[N]).
 * Table caps match the C twin: bound 16, call 32, gp 32, args 4, name 64.
 * @param lex_inout *u8 — opaque lexer; trampoline inits it
 * @param source *u8 — opaque slice wrapping the file bytes
 * @param last_nm *u8 — dest 64-byte last IDENT scratch; trampoline owns it
 * @param bound_name *u8 — dest bound callee names, stride 64, cap 16
 * @param bound_name_len *i32 — dest bound callee lens, cap 16
 * @param bound_trait *u8 — dest bound trait names, stride 64, cap 16
 * @param bound_trait_len *i32 — dest bound trait lens, cap 16
 * @param bound_pos *i32 — dest bound type-param positions, cap 16
 * @param bound_n *i32 — out slot; number of bound rows written
 * @param call_callee *u8 — dest call callee names, stride 64, cap 32
 * @param call_callee_len *i32 — dest call callee lens, cap 32
 * @param call_typearg *u8 — dest first type-arg names, stride 64, cap 32
 * @param call_typearg_len *i32 — dest first type-arg lens, cap 32
 * @param call_typeargs *u8 — dest all type-args, stride 64, 32 x 4
 * @param call_typearg_lens *i32 — dest all type-arg lens, 32 x 4
 * @param call_nargs *i32 — dest type-arg counts, cap 32
 * @param call_line *i32 — dest following-token lines, cap 32
 * @param call_col *i32 — dest following-token cols, cap 32
 * @param call_n *i32 — out slot; number of call rows written
 * @param gp_fname *u8 — dest generic-fn names, stride 64, cap 32
 * @param gp_fname_len *i32 — dest generic-fn name lens, cap 32
 * @param gp_names *u8 — dest type-param names, stride 64, 32 x 4
 * @param gp_lens *i32 — dest type-param lens, 32 x 4
 * @param gp_nargs *i32 — dest type-param counts, cap 32
 * @param gp_n *i32 — out slot; number of gp rows written
 * @return i32 — 1 on a completed scan; 0 on null
 * PLATFORM: SHARED — product P12d B-minus; C trampoline keeps
 * `xlang_generic_bound_scan_c` and owns the file-local tables.
 * Do not wrap skip_one_trait. Do not duplicate skip_generic_angle_list
 * or copy_slice (authority = pthin_lex_skip.x).
 */
#[no_mangle]
export function parser_asm_generic_bound_scan_into_c(lex_inout: *u8, source: *u8, last_nm: *u8, bound_name: *u8, bound_name_len: *i32, bound_trait: *u8, bound_trait_len: *i32, bound_pos: *i32, bound_n: *i32, call_callee: *u8, call_callee_len: *i32, call_typearg: *u8, call_typearg_len: *i32, call_typeargs: *u8, call_typearg_lens: *i32, call_nargs: *i32, call_line: *i32, call_col: *i32, call_n: *i32, gp_fname: *u8, gp_fname_len: *i32, gp_names: *u8, gp_lens: *i32, gp_nargs: *i32, gp_n: *i32): i32 {
  let kind: i32 = 0;
  let nk: i32 = 0;
  let pl: i32 = 0;
  let tl: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  let last_nlen: i32 = 0;
  let last_is_fn: i32 = 0;
  let last_is_struct: i32 = 0;
  let last_is_impl: i32 = 0;
  let prev_function: i32 = 0;
  let prev_struct: i32 = 0;
  let prev_impl: i32 = 0;
  let angle_depth: i32 = 0;
  let expect_trait: i32 = 0;
  let expect_tp: i32 = 0;
  let after_bound: i32 = 0;
  let pos: i32 = 0;
  let gp_slot: i32 = 0;
  let bn: i32 = 0;
  let cn: i32 = 0;
  let gn: i32 = 0;
  let pi: i32 = 0;
  let k: i32 = 0;
  let simple: i32 = 0;
  let nargs: i32 = 0;
  let expect_arg: i32 = 0;
  let slot_off: usize = 0;
  let row: *u8 = 0 as *u8;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || last_nm == 0 as *u8 || bound_name == 0 as *u8 || bound_name_len == 0 as *i32 || bound_trait == 0 as *u8 || bound_trait_len == 0 as *i32 || bound_pos == 0 as *i32 || bound_n == 0 as *i32 || call_callee == 0 as *u8 || call_callee_len == 0 as *i32 || call_typearg == 0 as *u8 || call_typearg_len == 0 as *i32 || call_typeargs == 0 as *u8 || call_typearg_lens == 0 as *i32 || call_nargs == 0 as *i32 || call_line == 0 as *i32 || call_col == 0 as *i32 || call_n == 0 as *i32 || gp_fname == 0 as *u8 || gp_fname_len == 0 as *i32 || gp_names == 0 as *u8 || gp_lens == 0 as *i32 || gp_nargs == 0 as *i32 || gp_n == 0 as *i32) {
    return 0;
  }
  unsafe {
    bound_n[0] = 0;
    call_n[0] = 0;
    gp_n[0] = 0;
    last_nlen = 0;
    last_is_fn = 0;
    last_is_struct = 0;
    last_is_impl = 0;
    prev_function = 0;
    prev_struct = 0;
    prev_impl = 0;
    zi = 0;
    while (zi < BOUND_NAME_CAP) {
      last_nm[zi as usize] = 0;
      zi = zi + 1;
    }
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    if (slen_us > 2147483647 as usize) {
      slen = 2147483647;
    } else {
      slen = slen_us as i32;
    }
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_EOF) {
        break;
      }
      if (kind == TOKEN_FUNCTION) {
        prev_function = 1;
        prev_struct = 0;
        prev_impl = 0;
        last_nlen = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_STRUCT) {
        prev_struct = 1;
        prev_function = 0;
        prev_impl = 0;
        last_nlen = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_IMPL) {
        prev_impl = 1;
        prev_function = 0;
        prev_struct = 0;
        last_nlen = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_IDENT) {
        pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (pl > 63) {
          pl = 63;
        }
        last_nlen = pl;
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        if (ts == 0 as usize) {
          ts = parser_asm_lex_pos_c(lex_inout);
        }
        zi = 0;
        while (zi < BOUND_NAME_CAP) {
          last_nm[zi as usize] = 0;
          zi = zi + 1;
        }
        if (pl > 0 && data != 0 as *u8) {
          parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, last_nm);
        }
        last_is_fn = prev_function;
        last_is_struct = prev_struct;
        last_is_impl = prev_impl;
        prev_function = 0;
        prev_struct = 0;
        prev_impl = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_LT && (last_nlen > 0 || prev_impl != 0)) {
        if (prev_impl != 0 && last_nlen == 0) {
          pl = parser_asm_skip_tl_peek_impl_for_type(lex_inout, source, last_nm);
          if (pl > 0) {
            last_nlen = pl;
            last_is_impl = 1;
          }
          prev_impl = 0;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (last_nlen > 0 && (last_is_fn != 0 || last_is_struct != 0 || last_is_impl != 0)) {
          angle_depth = 1;
          expect_trait = 0;
          expect_tp = 1;
          after_bound = 0;
          pos = 0;
          gp_slot = -1;
          gn = gp_n[0];
          if (gn < FN_GP_MAX) {
            gp_slot = gn;
            slot_off = (gn as usize) * (BOUND_NAME_CAP as usize);
            zi = 0;
            while (zi < BOUND_NAME_CAP) {
              gp_fname[slot_off + zi as usize] = 0;
              zi = zi + 1;
            }
            zi = 0;
            while (zi < last_nlen) {
              gp_fname[slot_off + zi as usize] = last_nm[zi as usize];
              zi = zi + 1;
            }
            gp_fname_len[gn] = last_nlen;
            gp_nargs[gn] = 0;
            k = 0;
            while (k < GENERIC_CALL_MAX_ARGS) {
              gp_lens[(gn as usize) * (GENERIC_CALL_MAX_ARGS as usize) + k as usize] = 0;
              k = k + 1;
            }
            gp_n[0] = gn + 1;
          }
          while (angle_depth > 0) {
            kind = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (kind == TOKEN_EOF) {
              break;
            }
            if (kind == TOKEN_LT) {
              angle_depth = angle_depth + 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_GT) {
              angle_depth = angle_depth - 1;
              if (angle_depth == 0) {
                break;
              }
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_COLON && angle_depth == 1) {
              expect_trait = 1;
              expect_tp = 0;
              after_bound = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_PLUS && angle_depth == 1 && after_bound != 0) {
              expect_trait = 1;
              expect_tp = 0;
              after_bound = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_IDENT && angle_depth == 1 && expect_trait != 0) {
              bn = bound_n[0];
              if (bn < FN_BOUND_MAX) {
                slot_off = (bn as usize) * (BOUND_NAME_CAP as usize);
                zi = 0;
                while (zi < BOUND_NAME_CAP) {
                  bound_name[slot_off + zi as usize] = 0;
                  bound_trait[slot_off + zi as usize] = 0;
                  zi = zi + 1;
                }
                zi = 0;
                while (zi < last_nlen) {
                  bound_name[slot_off + zi as usize] = last_nm[zi as usize];
                  zi = zi + 1;
                }
                bound_name_len[bn] = last_nlen;
                tl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
                if (tl > 63) {
                  tl = 63;
                }
                ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
                if (ts == 0 as usize) {
                  ts = parser_asm_lex_pos_c(lex_inout);
                }
                if (tl > 0 && data != 0 as *u8) {
                  parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, tl, bound_trait + slot_off);
                }
                bound_trait_len[bn] = tl;
                bound_pos[bn] = pos;
                bound_n[0] = bn + 1;
              }
              expect_trait = 0;
              after_bound = 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_IDENT && angle_depth == 1 && expect_tp != 0 && expect_trait == 0) {
              if (gp_slot >= 0 && gp_nargs[gp_slot] < GENERIC_CALL_MAX_ARGS) {
                pi = gp_nargs[gp_slot];
                pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
                if (pl > 63) {
                  pl = 63;
                }
                ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
                if (ts == 0 as usize) {
                  ts = parser_asm_lex_pos_c(lex_inout);
                }
                slot_off = ((gp_slot as usize) * (GENERIC_CALL_MAX_ARGS as usize) + pi as usize) * (BOUND_NAME_CAP as usize);
                zi = 0;
                while (zi < BOUND_NAME_CAP) {
                  gp_names[slot_off + zi as usize] = 0;
                  zi = zi + 1;
                }
                if (pl > 0 && data != 0 as *u8) {
                  parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, gp_names + slot_off);
                }
                gp_lens[(gp_slot as usize) * (GENERIC_CALL_MAX_ARGS as usize) + pi as usize] = pl;
                gp_nargs[gp_slot] = pi + 1;
              }
              expect_tp = 0;
              after_bound = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_COMMA && angle_depth == 1) {
              expect_trait = 0;
              expect_tp = 1;
              after_bound = 0;
              pos = pos + 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
          parser_asm_lex_step_kind_c(lex_inout, source);
        } else if (last_is_fn == 0 && last_nlen > 0 && call_n[0] < GENERIC_CALL_MAX) {
          cn = call_n[0];
          angle_depth = 1;
          simple = 1;
          nargs = 0;
          expect_arg = 1;
          k = 0;
          while (k < GENERIC_CALL_MAX_ARGS) {
            call_typearg_lens[(cn as usize) * (GENERIC_CALL_MAX_ARGS as usize) + k as usize] = 0;
            k = k + 1;
          }
          while (angle_depth > 0) {
            kind = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (kind == TOKEN_EOF) {
              break;
            }
            if (kind == TOKEN_LT) {
              angle_depth = angle_depth + 1;
              simple = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_GT) {
              angle_depth = angle_depth - 1;
              if (angle_depth == 0) {
                break;
              }
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_IDENT && angle_depth == 1 && expect_arg != 0 && nargs < GENERIC_CALL_MAX_ARGS) {
              pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
              if (pl > 63) {
                pl = 63;
              }
              ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
              if (ts == 0 as usize) {
                ts = parser_asm_lex_pos_c(lex_inout);
              }
              slot_off = ((cn as usize) * (GENERIC_CALL_MAX_ARGS as usize) + nargs as usize) * (BOUND_NAME_CAP as usize);
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_typeargs[slot_off + zi as usize] = 0;
                zi = zi + 1;
              }
              if (pl > 0 && data != 0 as *u8) {
                parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, call_typeargs + slot_off);
              }
              call_typearg_lens[(cn as usize) * (GENERIC_CALL_MAX_ARGS as usize) + nargs as usize] = pl;
              nargs = nargs + 1;
              expect_arg = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_COMMA && angle_depth == 1) {
              expect_arg = 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
          if (nargs > 0 && simple != 0) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            nk = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (nk == TOKEN_LPAREN || nk == TOKEN_LBRACE || nk == TOKEN_ASSIGN || nk == TOKEN_SEMICOLON || nk == TOKEN_COMMA || nk == TOKEN_RPAREN) {
              slot_off = (cn as usize) * (BOUND_NAME_CAP as usize);
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_callee[slot_off + zi as usize] = 0;
                call_typearg[slot_off + zi as usize] = 0;
                zi = zi + 1;
              }
              zi = 0;
              while (zi < last_nlen) {
                call_callee[slot_off + zi as usize] = last_nm[zi as usize];
                zi = zi + 1;
              }
              call_callee_len[cn] = last_nlen;
              row = call_typeargs + ((cn as usize) * (GENERIC_CALL_MAX_ARGS as usize) * (BOUND_NAME_CAP as usize));
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_typearg[slot_off + zi as usize] = row[zi as usize];
                zi = zi + 1;
              }
              call_typearg_len[cn] = call_typearg_lens[(cn as usize) * (GENERIC_CALL_MAX_ARGS as usize)];
              call_nargs[cn] = nargs;
              call_line[cn] = parser_asm_lex_line_c(lex_inout);
              call_col[cn] = parser_asm_lex_col_c(lex_inout);
              call_n[0] = cn + 1;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
          } else {
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
        }
        last_nlen = 0;
        last_is_fn = 0;
        last_is_struct = 0;
        last_is_impl = 0;
        prev_function = 0;
        prev_struct = 0;
        prev_impl = 0;
        continue;
      }
      prev_function = 0;
      prev_struct = 0;
      prev_impl = 0;
      if (kind != TOKEN_DOT && kind != TOKEN_COLON) {
        last_nlen = 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Scan an enum body after the caller consumed `{`, record depth-1 IDENT
 * variants onto the opaque module, and leave the lexer just after the
 * matching `}`. Nested `{...}` raise depth so inner IDENTs are not
 * variants. `enum_idx < 0` or a null module still skip the body (no
 * append). Language has no local u8[N]; `var_buf` is a 128-byte dest
 * the C trampoline owns. EOF or a 4096-step guard leaves the lexer on
 * the unconsumed token (C twin had no EOF guard; hang on malformed
 * input is not a product path).
 * @param lex_inout *u8 — opaque lexer; entry is the first token after `{`
 * @param source *u8 — opaque slice
 * @param module *u8 — opaque Module; null skips appends
 * @param enum_idx i32 — sidecar slot from try_register; <0 skips appends
 * @param var_buf *u8 — dest 128-byte variant spelling; trampoline owns it
 * @return i32 — 1 on the success / fail-leave path; 0 on null lex/source/var_buf
 * PLATFORM: SHARED — product P12e B-minus. Do not duplicate skip_one_enum
 * (opaque brace skip would drop variant capture). Do not wrap skip_one_trait.
 */
#[no_mangle]
export function parser_asm_module_append_enum_variants_and_skip_body_into_c(lex_inout: *u8, source: *u8, module: *u8, enum_idx: i32, var_buf: *u8): i32 {
  let kind: i32 = 0;
  let depth: i32 = 0;
  let guard: i32 = 0;
  let pl: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || var_buf == 0 as *u8) {
    return 0;
  }
  unsafe {
    depth = 1;
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    slen = slen_us as i32;
    while (depth > 0 && guard < 4096) {
      guard = guard + 1;
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_EOF) {
        break;
      }
      if (kind == TOKEN_RBRACE) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        depth = depth - 1;
        continue;
      }
      if (kind == TOKEN_LBRACE) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        depth = depth + 1;
        continue;
      }
      if (depth == 1 && enum_idx >= 0 && module != 0 as *u8 && kind == TOKEN_IDENT) {
        pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (pl > 127) {
          pl = 127;
        }
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        if (ts == 0 as usize) {
          ts = parser_asm_lex_pos_c(lex_inout);
        }
        zi = 0;
        while (zi < ENUM_NAME_CAP) {
          var_buf[zi as usize] = 0;
          zi = zi + 1;
        }
        if (pl > 0 && data != 0 as *u8) {
          parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, var_buf);
        }
        if (pl > 0) {
          pipeline_module_enum_append_variant(module, enum_idx, var_buf, pl);
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Register a top-level `enum Name { variants }` onto the opaque module
 * and skip to just after the matching `}`. Entry cursor is the start of
 * `enum`. Non-ENUM first token: lexer unmoved. After consuming ENUM, a
 * non-IDENT leaves the lexer after `enum`. After IDENT, a non-LBRACE
 * leaves the lexer after the name. Language has no local u8[N]; dest
 * 128-byte name/variant scratches are C-stack-owned. Module writes go
 * through P14 try_register and pipeline_module_enum_append_variant
 * (not a second walk). Do not call skip_one_enum (would drop variants).
 * @param lex_inout *u8 — opaque lexer (advanced past `}`, or left on the
 *   fail cursor described above)
 * @param source *u8 — opaque slice
 * @param module *u8 — opaque Module; null still skips the body
 * @param name_buf *u8 — dest 128-byte enum name; trampoline owns it
 * @param var_buf *u8 — dest 128-byte variant scratch; trampoline owns it
 * @return i32 — 1 on the success / fail-leave path; 0 on null lex/source/bufs
 * PLATFORM: SHARED — product P12e B-minus. Do not wrap skip_one_trait.
 * Do not open a new P-lane.
 */
#[no_mangle]
export function parser_asm_skip_one_enum_register_into_c(lex_inout: *u8, source: *u8, module: *u8, name_buf: *u8, var_buf: *u8): i32 {
  let kind: i32 = 0;
  let pl: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  let enum_idx: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || name_buf == 0 as *u8 || var_buf == 0 as *u8) {
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
    pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (pl > 127) {
      pl = 127;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    if (ts == 0 as usize) {
      ts = parser_asm_lex_pos_c(lex_inout);
    }
    zi = 0;
    while (zi < ENUM_NAME_CAP) {
      name_buf[zi as usize] = 0;
      zi = zi + 1;
    }
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    slen = slen_us as i32;
    if (pl > 0 && data != 0 as *u8) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, name_buf);
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    enum_idx = -1;
    if (module != 0 as *u8 && pl > 0) {
      enum_idx = parser_asm_module_try_register_enum_name_c(module, name_buf, pl);
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_module_append_enum_variants_and_skip_body_into_c(lex_inout, source, module, enum_idx, var_buf);
  }
  return 1;
}

/**
 * Parse `extern ["C"|"X"] function name(params): Ret ;` (or `{` body)
 * into dest buffers. Entry cursor is the start of `extern`.
 *
 * Fail-leave (return -1) leaves the lexer at the start of the failing
 * token (C `lexer_next_into` into `r` then `set_fail(out, lex)` without
 * writing `r.next_lex` back). Success with `has_body=1` leaves the
 * lexer BEFORE `{` so the caller can parse_block. Success with
 * `has_body=0` consumes the trailing `;`.
 *
 * Optional ABI STRING is `"C"` (abi_kind=1) or `"X"` (abi_kind=0);
 * any other spelling fails. Variadic `...` must be the last param
 * token and is only recorded (C ABI check stays with the caller).
 * Param names use P1b copy_slice_to_param32 (cap 127, 256-byte row).
 * Function name uses P1b copy_slice_to_name64 (cap 63).
 *
 * type_ref parse stays the C arena walk via
 * `parser_asm_skip_tl_parse_type_ref_into_c`. onefunc append/set stay
 * pipeline helpers. Do not call skip_one_extern (would drop capture).
 * Do not wrap leftover AUDIT. Do not wrap skip_one_trait.
 *
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param arena *u8 — opaque ASTArena for type_ref; may be null (then
 *   type_ref returns 0 → fail)
 * @param pool *u8 — onefunc pool (the C `extern_parse_result`); trampoline
 *   owns it and resets it before this call
 * @param name_buf *u8 — dest 64-byte function name; trampoline owns it
 * @param pname_buf *u8 — dest 256-byte param-name scratch; trampoline owns it
 * @param name_len *i32 — out slot; 1..63 on success
 * @param return_ty *i32 — out slot; type_ref of the return type
 * @param num_params *i32 — out slot; onefunc param count
 * @param abi_kind *i32 — out slot; 0=X ABI, 1=C ABI
 * @param is_variadic *i32 — out slot; 1 if `...` was the last param
 * @param has_body *i32 — out slot; 1 if the next token is `{` (unconsumed)
 * @return i32 — 1 success; -1 fail-leave; 0 on null dests
 * PLATFORM: SHARED — product P12f B-minus. C trampoline keeps
 * `parser_asm_parse_one_extern_skip_into_slice_c` and calls set_fail
 * on -1. Do not open a new P-lane.
 */
#[no_mangle]
export function parser_asm_parse_one_extern_skip_into_c(lex_inout: *u8, source: *u8, arena: *u8, pool: *u8, name_buf: *u8, pname_buf: *u8, name_len: *i32, return_ty: *i32, num_params: *i32, abi_kind: *i32, is_variadic: *i32, has_body: *i32): i32 {
  let kind: i32 = 0;
  let pl: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  let abi_byte: u8 = 0;
  let params_done: i32 = 0;
  let pidx: i32 = 0;
  let ty: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || pool == 0 as *u8 || name_buf == 0 as *u8 || pname_buf == 0 as *u8 || name_len == 0 as *i32 || return_ty == 0 as *i32 || num_params == 0 as *i32 || abi_kind == 0 as *i32 || is_variadic == 0 as *i32 || has_body == 0 as *i32) {
    return 0;
  }
  unsafe {
    name_len[0] = 0;
    return_ty[0] = 0;
    num_params[0] = 0;
    abi_kind[0] = 0;
    is_variadic[0] = 0;
    has_body[0] = 0;
    zi = 0;
    while (zi < EXTERN_NAME_CAP) {
      name_buf[zi as usize] = 0;
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
    if (kind != TOKEN_EXTERN) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_STRING) {
      pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      if (pl != 1 || data == 0 as *u8 || ts >= slen_us) {
        return -1;
      }
      abi_byte = data[ts];
      if (abi_byte == BYTE_ABI_C) {
        abi_kind[0] = 1;
      } else {
        if (abi_byte == BYTE_ABI_X) {
          abi_kind[0] = 0;
        } else {
          return -1;
        }
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind != TOKEN_FUNCTION) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return -1;
    }
    pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (pl <= 0 || pl > 63) {
      return -1;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    if (ts == 0 as usize) {
      ts = parser_asm_lex_pos_c(lex_inout);
    }
    if (pl > 0 && data != 0 as *u8) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, name_buf);
    }
    name_len[0] = pl;
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      params_done = 1;
    }
    while (params_done == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_ELLIPSIS) {
        is_variadic[0] = 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_RPAREN) {
          return -1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        params_done = 1;
      } else {
        if (kind != TOKEN_IDENT) {
          return -1;
        }
        pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (pl <= 0 || pl > PARAM_NAME_MAX) {
          return -1;
        }
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        if (ts == 0 as usize) {
          ts = parser_asm_lex_pos_c(lex_inout);
        }
        parser_asm_copy_slice_to_param32_buf_c(data, slen, ts, pl, pname_buf);
        pidx = pipeline_onefunc_append_param(pool, pname_buf, pl, 0);
        if (pidx < 0) {
          return -1;
        }
        num_params[0] = pidx + 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_COLON) {
          return -1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        ty = parser_asm_skip_tl_parse_type_ref_into_c(arena, lex_inout, source);
        if (ty == 0) {
          return -1;
        }
        pipeline_onefunc_set_param_type_ref(pool, pidx, ty);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_RPAREN) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          params_done = 1;
        } else {
          if (kind != TOKEN_COMMA) {
            return -1;
          }
          parser_asm_lex_step_kind_c(lex_inout, source);
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (kind == TOKEN_RPAREN) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            params_done = 1;
          }
        }
      }
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ty = parser_asm_skip_tl_parse_type_ref_into_c(arena, lex_inout, source);
    if (ty == 0) {
      return -1;
    }
    return_ty[0] = ty;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LBRACE) {
      has_body[0] = 1;
      return 1;
    }
    if (kind != TOKEN_SEMICOLON) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    has_body[0] = 0;
  }
  return 1;
}
