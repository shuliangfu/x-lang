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

// pthin_type_ref.x — G-02f-280 P3 parser thin type_ref product bodies.
//
// 7.2.1 P3b Route C productize (2026-09-13): after P4b primary ident
// spelling, type_ref.inc is the next still-host-cc product slice with a
// portable scalar / buf-path region. token_starts_type and builtin
// TOKEN→TypeKind ordinal are Route C (int32). IDENT `dyn` and vector
// spellings (i32x4 / Vec4f / …) are buf-path Route C (*u8 + length).
// Arena Type alloc, lexer by-value, and parse_type_ref_impl stay C.
// skip_tl's xlang_trait_token_to_type_kind_c is a thin trampoline to
// builtin_kind_ord (G.7: one TOKEN→TypeKind table).
//
// Hybrid P3b/P3c/P3d/P3e/P3g: g05_try_x_to_o this file;
// XLANG_PTHIN_TYPE_REF_BODIES_FROM_X skips the portable .inc region.
// XLANG_PTHIN_TYPE_REF_POSTFIX_FROM_X is a separate define (P6e
// PARSE_LAYOUT / P2c COND pattern) so a missing postfix_x keeps the C
// postfix twins without dropping P3b–P3e. token.h remains the TOKEN_*
// authority via P3 C _Static_assert pins. Cold: no define, full .inc stays.
// Vector IDENT checks copy the C twin byte-for-byte (including the
// historical i32x* / u32x* nibble pattern); do not "fix" as a side effect.
// 7.2.1 P3c B-minus (2026-09-15): 有则补全 type-inst mangle dest-buffer.
// parser_asm_type_ref_mangle_suffix_c / append_type_inst_mangle were
// always-host-cc statics in primary.inc (not behind BODIES). Bodies
// land here because pthin_expr_primary.x suffix_loop still XT001 on
// the pin egg (P4b thin already falls back to C). Language has no
// local u8[N]; the C trampoline in primary.inc holds suf[64].
// Do not merge with codegen_type_ref_to_suffix or
// typeck_type_ref_mangle_suffix (parser-local copy avoids a
// parser→codegen link edge). Do not copy into suffix_loop / parse.
// 7.2.1 P3d B-minus (2026-09-15): 有则补全 consume_qualified IDENT
// path (`a.b.Type`) and type-pos angle close (GT / nested `>>`).
// Both were always-host-cc in type_ref.inc (not behind BODIES).
// Language has no lexer_result by-value; the C trampoline holds r
// and forwards &r->next_lex plus first ident_len. Walk uses the
// existing P9a peek/step family (peek, then step — no save/restore).
// Name copy is P1b at_end (do not copy the copy loop). parse_type_ref
// stays C. Do not open a new P-lane. Do not touch P4b pending_n.
// 7.2.1 P3e B-minus (2026-09-15): 有则补全 TYPE_DYN wrap dest-buffer.
// alloc_dyn_type_ref + wrap_registered_trait_as_dyn were always
// host-cc statics in type_ref.inc (not behind BODIES). Language has
// no Type by-value; dest-buffer both wrap soups in this domain file.
// C trampoline holds name[256] for sidecar named_name_into.
// Sidecar reads go through existing pipeline_type_kind_ord_at /
// named_name_into (G.7). TYPE_DYN writes go through
// pipeline_type_init_dyn_c in this P3 seed (consumer-wave writer;
// do not FORCE pabi mega; do not reuse init_compound_kind_at —
// that helper caps kind_ord at 15 and pipe_ty_kind_from_ord
// clamps >16 to TYPE_I32). parse_type_ref stays C. Do not copy
// wrap into parse. Do not merge with P3c mangle. Do not dest-buffer
// the IDENT generic type-arg get/set soup this wave (extra
// lexer_next). Do not open a new P-lane.
// 7.2.1 P3g B-minus (2026-09-16): 有则补全 postfix `T[]` / `T[]<label>` /
// `T[N]` / `T[N][M]…` dest-buffer. Both helpers were always-host-cc
// statics in type_ref.inc (not behind BODIES). P9a peek/step walks
// the bracket chain; empty `[]` as the first postfix is slice
// (`T[N][]` fail-closed). ARRAY/SLICE writes reuse
// pipeline_type_init_compound_kind_at (kind 10/11 < 15; G.7). Optional
// region label goes through pipeline_type_set_region_label_at; the C
// trampoline holds label[64] (language has no local u8[N]). Local
// i32[8] dims match skip_tl. parse_type_ref stays C. Do not dest-buffer
// parse_type_ref (P3f was hello/fmt red). Do not copy wrap into parse.
// Do not merge wrap. Do not FORCE pabi mega. Do not open a new P-lane.
// Do not `break` out of nested while (P4bh parse drops the function).
// PLATFORM: SHARED freestanding.

// TOKEN_* pin copies of include/token.h. P3 C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_IMPL: i32 = 50;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;
const TOKEN_BOOL: i32 = 61;
const TOKEN_U8: i32 = 62;
const TOKEN_U32: i32 = 63;
const TOKEN_U64: i32 = 64;
const TOKEN_I64: i32 = 65;
const TOKEN_USIZE: i32 = 66;
const TOKEN_ISIZE: i32 = 67;
const TOKEN_I32X4: i32 = 68;
const TOKEN_I32X8: i32 = 69;
const TOKEN_I32X16: i32 = 70;
const TOKEN_U32X4: i32 = 71;
const TOKEN_U32X8: i32 = 72;
const TOKEN_U32X16: i32 = 73;
const TOKEN_F32X4: i32 = 74;
const TOKEN_F32: i32 = 77;
const TOKEN_F64: i32 = 78;
const TOKEN_VOID: i32 = 79;
const TOKEN_INT: i32 = 80;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;
const TOKEN_DOT: i32 = 92;
const TOKEN_STAR: i32 = 98;
const TOKEN_RSHIFT: i32 = 105;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;

/** P9a: peek next kind without advancing the opaque lexer. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: consume one token; returns its kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek ident_len of the next token. */
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek TOKEN_INT payload as i32 (array dim). */
export extern "C" function parser_asm_lex_peek_int_val_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek token_start of the next token (IDENT label copy). */
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
/** P1b authority: copy nlen bytes starting at start. Do not copy the loop. */
export extern "C" function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P9a: lexer pos (copy-at-end uses this as IDENT end). */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
/** P9a: slice data / length for P1b at_end copy. */
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
/** P1b authority: copy nlen bytes ending at end_pos. Do not copy the loop. */
export extern "C" function parser_asm_copy_slice_to_name64_at_end_buf_c(source: *u8, source_len: i32, end_pos: usize, nlen: i32, out: *u8): void;

// TypeKind ordinals — G.7 ≡ ast.x / PARSER_ASM_TYPE_* in type_ref.inc.
const TYPE_I32: i32 = 0;
const TYPE_BOOL: i32 = 1;
const TYPE_U8: i32 = 2;
const TYPE_U32: i32 = 3;
const TYPE_U64: i32 = 4;
const TYPE_I64: i32 = 5;
const TYPE_USIZE: i32 = 6;
const TYPE_ISIZE: i32 = 7;
const TYPE_NAMED: i32 = 8;
const TYPE_PTR: i32 = 9;
const TYPE_ARRAY: i32 = 10;
const TYPE_SLICE: i32 = 11;
const TYPE_F32: i32 = 14;
const TYPE_F64: i32 = 15;
const TYPE_VOID: i32 = 16;
const TYPE_DYN: i32 = 17;

/** Sidecar: TypeKind ordinal at type_ref. */
export extern "C" function pipeline_type_kind_ord_at(a: *u8, type_ref: i32): i32;
/** Sidecar: pointer/array element type_ref. */
export extern "C" function pipeline_type_elem_ref_at(a: *u8, type_ref: i32): i32;
/** Sidecar: copy NAMED spelling into out; returns length. */
export extern "C" function pipeline_type_named_name_into(a: *u8, type_ref: i32, out: *u8): i32;
/** Allocate a fresh Type slot; 0 on failure. */
export extern "C" function ast_ast_arena_type_alloc(arena: *u8): i32;
/**
 * P3e consumer-wave writer: stamp TYPE_DYN (kind=17) + elem + optional
 * NAMED spelling copy. Lives in the P3 seed; do not copy; do not FORCE
 * pabi mega; do not reuse init_compound_kind_at (kind_ord cap 15).
 */
export extern "C" function pipeline_type_init_dyn_c(a: *u8, ref: i32, inner_tr: i32, name: *u8, nlen: i32): void;
/**
 * Existing pipeline_abi writer: stamp compound Type (kind 0..15) + elem +
 * array_size. TYPE_ARRAY=10 fits the cap (G.7). Do not reuse for
 * TYPE_DYN=17 (P3e). Labeled TYPE_SLICE uses pipeline_type_init_slice_c
 * (set_region_label_at wipes elem_type_ref on the current Type layout).
 */
export extern "C" function pipeline_type_init_compound_kind_at(a: *u8, ref: i32, kind_ord: i32, elem_ref: i32, array_size: i32): i32;
/**
 * P3g consumer-wave writer: stamp TYPE_SLICE + elem + optional region
 * label. Lives in the P3 seed; do not copy; do not FORCE pabi mega.
 */
export extern "C" function pipeline_type_init_slice_c(a: *u8, ref: i32, elem_tr: i32, label: *u8, nlen: i32): void;
/** Skip-trait registry predicate (skip_tl). G.7: one lookup table. */
export extern "C" function xlang_skip_trait_is_registered_c(trait_nm: *u8, trait_nlen: i32): i32;

/**
 * Bounds check shared by IDENT spelling probes in this file.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @param want_len i32 — required spelling length
 * @return i32 — 1 if data is live, ident_len==want_len, and the span fits
 */
function parser_asm_type_ref_ident_span_ok(data: *u8, length: usize, token_start: usize, ident_len: i32, want_len: i32): i32 {
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
function parser_asm_type_ref_ident_byte(data: *u8, token_start: usize, i: i32): u8 {
  let c: u8 = 0;
  unsafe {
    c = data[token_start + i as usize];
  }
  return c;
}

/**
 * Token that may start a type after a peeled `dyn` / `impl` prefix.
 * @param kind i32 — lexer token kind (token.h numbering)
 * @return i32 — 1 if the token can start a type; 0 otherwise
 * PLATFORM: SHARED — scalar split of the former static C twin.
 */
#[no_mangle]
export function parser_asm_type_ref_token_starts_type_c(kind: i32): i32 {
  if (kind == TOKEN_IDENT || kind == TOKEN_STAR || kind == TOKEN_LBRACKET) {
    return 1;
  }
  if (kind == TOKEN_IMPL) {
    return 1;
  }
  if (kind == TOKEN_FUNCTION) {
    return 1;
  }
  if (kind == TOKEN_I32 || kind == TOKEN_I64 || kind == TOKEN_BOOL) {
    return 1;
  }
  if (kind == TOKEN_U8 || kind == TOKEN_U32 || kind == TOKEN_U64) {
    return 1;
  }
  if (kind == TOKEN_USIZE || kind == TOKEN_ISIZE || kind == TOKEN_VOID) {
    return 1;
  }
  if (kind == TOKEN_F32 || kind == TOKEN_F64) {
    return 1;
  }
  if (kind == TOKEN_I32X4 || kind == TOKEN_I32X8 || kind == TOKEN_I32X16) {
    return 1;
  }
  if (kind == TOKEN_U32X4 || kind == TOKEN_U32X8 || kind == TOKEN_U32X16) {
    return 1;
  }
  if (kind == TOKEN_F32X4) {
    return 1;
  }
  return 0;
}

/**
 * Map builtin scalar/void type token → TypeKind ordinal.
 * IDENT / pointer / array / vector tokens are not builtins here
 * (return -1); callers alloc NAMED/PTR/ARRAY/VECTOR separately.
 * @param kind i32 — lexer token kind (token.h numbering)
 * @return i32 — TypeKind ordinal >=0, or -1 if not a scalar/void builtin
 * PLATFORM: SHARED — single TOKEN→TypeKind table; skip_tl trampolines here.
 */
#[no_mangle]
export function parser_asm_type_ref_builtin_kind_ord_c(kind: i32): i32 {
  if (kind == TOKEN_I32) {
    return TYPE_I32;
  }
  if (kind == TOKEN_BOOL) {
    return TYPE_BOOL;
  }
  if (kind == TOKEN_U8) {
    return TYPE_U8;
  }
  if (kind == TOKEN_U32) {
    return TYPE_U32;
  }
  if (kind == TOKEN_U64) {
    return TYPE_U64;
  }
  if (kind == TOKEN_I64) {
    return TYPE_I64;
  }
  if (kind == TOKEN_USIZE) {
    return TYPE_USIZE;
  }
  if (kind == TOKEN_ISIZE) {
    return TYPE_ISIZE;
  }
  if (kind == TOKEN_F32) {
    return TYPE_F32;
  }
  if (kind == TOKEN_F64) {
    return TYPE_F64;
  }
  if (kind == TOKEN_VOID) {
    return TYPE_VOID;
  }
  return -1;
}

/**
 * True when IDENT spelling is contextual prefix `dyn`.
 * docs/01 does not list dyn as a keyword; same TOKEN_IDENT shape as `mut`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the three bytes are `dyn`; 0 otherwise
 * PLATFORM: SHARED — buf-path authority; slice wrapper stays a C trampoline.
 */
#[no_mangle]
export function parser_asm_type_ref_ident_is_dyn_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_type_ref_ident_span_ok(data, length, token_start, ident_len, 3) == 0) {
    return 0;
  }
  if (parser_asm_type_ref_ident_byte(data, token_start, 0) == 100 && parser_asm_type_ref_ident_byte(data, token_start, 1) == 121
      && parser_asm_type_ref_ident_byte(data, token_start, 2) == 110) {
    return 1;
  }
  return 0;
}

/**
 * Pack vector IDENT spelling into `(elem_ord << 8) | lanes`, or 0.
 * Byte probes copy the C twin exactly (i32x4/u32x4 historical nibble
 * pattern: nlen==5 checks i/u, '3', 'x', '4' — not a silent rewrite).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — packed elem_ord/lanes, or 0 if the spelling is not a vector alias
 * PLATFORM: SHARED — buf-path authority; C still allocs TYPE_VECTOR.
 */
#[no_mangle]
export function parser_asm_vector_type_ident_pack_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (data == 0 as *u8 || ident_len <= 0 || ident_len > 63) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  let b0: u8 = parser_asm_type_ref_ident_byte(data, token_start, 0);
  let b1: u8 = parser_asm_type_ref_ident_byte(data, token_start, 1);
  let b2: u8 = 0;
  let b3: u8 = 0;
  let b4: u8 = 0;
  if (ident_len >= 3) {
    b2 = parser_asm_type_ref_ident_byte(data, token_start, 2);
  }
  if (ident_len >= 4) {
    b3 = parser_asm_type_ref_ident_byte(data, token_start, 3);
  }
  if (ident_len >= 5) {
    b4 = parser_asm_type_ref_ident_byte(data, token_start, 4);
  }
  // i32x4 / i3x4 nibble (C twin): nlen==5, i, '3', 'x', '4'
  if (ident_len == 5 && b0 == 105 && b1 == 51 && b2 == 120 && b3 == 52) {
    return (TYPE_I32 << 8) | 4;
  }
  if (ident_len == 5 && b0 == 105 && b1 == 51 && b2 == 120 && b3 == 56) {
    return (TYPE_I32 << 8) | 8;
  }
  if (ident_len == 6 && b0 == 105 && b1 == 51 && b2 == 120 && b3 == 49 && b4 == 54) {
    return (TYPE_I32 << 8) | 16;
  }
  if (ident_len == 5 && b0 == 117 && b1 == 51 && b2 == 120 && b3 == 52) {
    return (TYPE_U32 << 8) | 4;
  }
  if (ident_len == 5 && b0 == 117 && b1 == 51 && b2 == 120 && b3 == 56) {
    return (TYPE_U32 << 8) | 8;
  }
  if (ident_len == 6 && b0 == 117 && b1 == 51 && b2 == 120 && b3 == 49 && b4 == 54) {
    return (TYPE_U32 << 8) | 16;
  }
  // f32x4: elem_ord=14 (TYPE_F32). C twin checks all five bytes.
  if (ident_len == 5 && b0 == 102 && b1 == 51 && b2 == 50 && b3 == 120 && b4 == 52) {
    return (TYPE_F32 << 8) | 4;
  }
  // Vec4f: elem_ord=14 (TYPE_F32).
  if (ident_len == 5 && b0 == 86 && b1 == 101 && b2 == 99 && b3 == 52 && b4 == 102) {
    return (TYPE_F32 << 8) | 4;
  }
  // Vec8i: elem_ord=0 (TYPE_I32), lanes=8.
  if (ident_len == 5 && b0 == 86 && b1 == 101 && b2 == 99 && b3 == 56 && b4 == 105) {
    return (TYPE_I32 << 8) | 8;
  }
  return 0;
}

/**
 * Map one type_ref to a C-safe mangle suffix into buf[0..).
 * PTR peels to the element then appends `_ptr` ptr_n times. NAMED copies
 * the sidecar name. Scalars: i32/i64/u8/u32/u64/bool/usize/isize.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param type_ref i32 — type slot; <= 0 → 0
 * @param buf *u8 — destination; null → 0
 * @param buf_cap i32 — capacity in bytes; <= 0 → 0
 * @return i32 — bytes written, or 0 on failure
 * PLATFORM: SHARED — product P3c B-minus. Parser-local STRUCT_LIT
 * suffix authority. Do not merge with codegen_type_ref_to_suffix or
 * typeck_type_ref_mangle_suffix. PTR uses `n + 4 < buf_cap` (C twin).
 */
#[no_mangle]
export function parser_asm_type_ref_mangle_suffix_c(arena: *u8, type_ref: i32, buf: *u8, buf_cap: i32): i32 {
  let tk: i32 = 0;
  let n: i32 = 0;
  let elem: i32 = 0;
  let ptr_n: i32 = 0;
  let cur: i32 = 0;
  let pi: i32 = 0;
  if (arena == 0 as *u8 || type_ref <= 0 || buf == 0 as *u8 || buf_cap <= 0) {
    return 0;
  }
  cur = type_ref;
  ptr_n = 0;
  tk = pipeline_type_kind_ord_at(arena, cur);
  while (tk == TYPE_PTR) {
    elem = pipeline_type_elem_ref_at(arena, cur);
    if (elem <= 0) {
      return 0;
    }
    cur = elem;
    ptr_n = ptr_n + 1;
    if (ptr_n > 64) {
      return 0;
    }
    tk = pipeline_type_kind_ord_at(arena, cur);
  }
  n = 0;
  if (tk == TYPE_NAMED) {
    n = pipeline_type_named_name_into(arena, cur, buf);
    if (n <= 0 || n >= buf_cap) {
      return 0;
    }
  } else if (tk == TYPE_I32) {
    if (buf_cap < 3) {
      return 0;
    }
    unsafe {
      buf[0] = 105;
      buf[1] = 51;
      buf[2] = 50;
    }
    n = 3;
  } else if (tk == TYPE_I64) {
    if (buf_cap < 3) {
      return 0;
    }
    unsafe {
      buf[0] = 105;
      buf[1] = 54;
      buf[2] = 52;
    }
    n = 3;
  } else if (tk == TYPE_U8) {
    if (buf_cap < 2) {
      return 0;
    }
    unsafe {
      buf[0] = 117;
      buf[1] = 56;
    }
    n = 2;
  } else if (tk == TYPE_U32) {
    if (buf_cap < 3) {
      return 0;
    }
    unsafe {
      buf[0] = 117;
      buf[1] = 51;
      buf[2] = 50;
    }
    n = 3;
  } else if (tk == TYPE_U64) {
    if (buf_cap < 3) {
      return 0;
    }
    unsafe {
      buf[0] = 117;
      buf[1] = 54;
      buf[2] = 52;
    }
    n = 3;
  } else if (tk == TYPE_BOOL) {
    if (buf_cap < 4) {
      return 0;
    }
    unsafe {
      buf[0] = 98;
      buf[1] = 111;
      buf[2] = 111;
      buf[3] = 108;
    }
    n = 4;
  } else if (tk == TYPE_USIZE) {
    if (buf_cap < 5) {
      return 0;
    }
    unsafe {
      buf[0] = 117;
      buf[1] = 115;
      buf[2] = 105;
      buf[3] = 122;
      buf[4] = 101;
    }
    n = 5;
  } else if (tk == TYPE_ISIZE) {
    if (buf_cap < 5) {
      return 0;
    }
    unsafe {
      buf[0] = 105;
      buf[1] = 115;
      buf[2] = 105;
      buf[3] = 122;
      buf[4] = 101;
    }
    n = 5;
  } else {
    return 0;
  }
  pi = 0;
  while (pi < ptr_n) {
    if (n > 0 && n + 4 < buf_cap) {
      unsafe {
        buf[n as usize] = 95;
        buf[(n + 1) as usize] = 112;
        buf[(n + 2) as usize] = 116;
        buf[(n + 3) as usize] = 114;
      }
      n = n + 4;
      pi = pi + 1;
    } else {
      return n;
    }
  }
  return n;
}

/**
 * `Name` + type_arg refs → `Name_suf0[_suf1…]` (cap 255 content).
 * CORE-016: `Result<T,i32>` compresses to `Result_T` (drop trailing `_i32`
 * when E=i32). Suffix scratch `suf` is trampoline-owned (no local u8[N]).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param base *u8 — type name bytes; null → 0
 * @param base_len i32 — name length; <= 0 → 0
 * @param type_refs *i32 — type_arg refs; null → 0
 * @param nrefs i32 — type_arg count; <= 0 → 0; walk cap 8
 * @param out *u8 — destination; null → 0
 * @param out_cap i32 — destination capacity; <= 0 → 0
 * @param suf *u8 — 64-byte suffix scratch from the C trampoline; null → 0
 * @param suf_cap i32 — scratch capacity; C twin uses 64
 * @return i32 — mangled length, or 0 on failure
 * PLATFORM: SHARED — product P3c B-minus. Historical 7-arg name
 * `parser_asm_append_type_inst_mangle_c` stays a C trampoline in
 * primary.inc that holds `suf[64]`. Do not copy this loop into
 * suffix_loop or parse_primary.
 */
#[no_mangle]
export function parser_asm_append_type_inst_mangle_into_c(arena: *u8, base: *u8, base_len: i32, type_refs: *i32, nrefs: i32, out: *u8, out_cap: i32, suf: *u8, suf_cap: i32): i32 {
  let pos: i32 = 0;
  let ai: i32 = 0;
  let is_result: i32 = 0;
  let e_is_i32: i32 = 0;
  let sl: i32 = 0;
  let sj: i32 = 0;
  let tr: i32 = 0;
  let b: u8 = 0;
  if (arena == 0 as *u8 || base == 0 as *u8 || base_len <= 0 || type_refs == 0 as *i32 || nrefs <= 0 || out == 0 as *u8 || out_cap <= 0 || suf == 0 as *u8 || suf_cap <= 0) {
    return 0;
  }
  if (base_len >= out_cap) {
    return 0;
  }
  unsafe {
    pos = 0;
    while (pos < base_len) {
      out[pos] = base[pos];
      pos = pos + 1;
    }
    is_result = 0;
    if (base_len == 6 && base[0] == 82 && base[1] == 101 && base[2] == 115 && base[3] == 117 && base[4] == 108 && base[5] == 116) {
      is_result = 1;
    }
    e_is_i32 = 0;
    if (is_result != 0 && nrefs >= 2) {
      tr = type_refs[1];
      if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == TYPE_I32) {
        e_is_i32 = 1;
      }
    }
    ai = 0;
    while (ai < nrefs && ai < 8) {
      if (is_result != 0 && e_is_i32 != 0 && ai == 1) {
        ai = ai + 1;
        continue;
      }
      tr = type_refs[ai];
      if (tr <= 0) {
        return 0;
      }
      sl = parser_asm_type_ref_mangle_suffix_c(arena, tr, suf, suf_cap);
      if (sl <= 0) {
        return 0;
      }
      if (pos + 1 + sl >= out_cap) {
        return 0;
      }
      out[pos] = 95;
      pos = pos + 1;
      sj = 0;
      while (sj < sl) {
        b = suf[sj];
        out[pos] = b;
        pos = pos + 1;
        sj = sj + 1;
      }
      ai = ai + 1;
    }
  }
  if (pos <= base_len) {
    return 0;
  }
  return pos;
}

/**
 * Close one type-position angle level.
 * TOKEN_GT consumes fully. TOKEN_RSHIFT (`>>` max-munch) closes this
 * level and leaves one `>` for the outer list by rewinding pos/col by 1.
 * Does not accept TOKEN_RSHIFT_EQ.
 * @param peek_kind i32 — already-peeked close token (token.h)
 * @param lex_inout *u8 — opaque lexer; written on success; null → 0
 * @param next_pos usize — peek.next_lex.pos (past the close token)
 * @param next_line i32 — peek.next_lex.line
 * @param next_col i32 — peek.next_lex.col
 * @return i32 — 1 if closed, 0 if peek_kind is neither GT nor RSHIFT
 * PLATFORM: SHARED type grammar. P3d dest-buffer split of the former
 * static C twin. parse_type_ref_impl stays C and calls the trampoline.
 */
#[no_mangle]
export function parser_asm_type_angle_close_into_c(peek_kind: i32, lex_inout: *u8, next_pos: usize, next_line: i32, next_col: i32): i32 {
  let p: usize = 0;
  let c: i32 = 0;
  if (lex_inout == 0 as *u8) {
    return 0;
  }
  if (peek_kind == TOKEN_GT) {
    unsafe {
      parser_asm_lex_set_pos_c(lex_inout, next_pos);
      parser_asm_lex_set_line_c(lex_inout, next_line);
      parser_asm_lex_set_col_c(lex_inout, next_col);
    }
    return 1;
  }
  if (peek_kind == TOKEN_RSHIFT) {
    p = next_pos;
    c = next_col;
    if (p > 0 as usize) {
      p = p - 1 as usize;
    }
    if (c > 1) {
      c = c - 1;
    }
    unsafe {
      parser_asm_lex_set_pos_c(lex_inout, p);
      parser_asm_lex_set_line_c(lex_inout, next_line);
      parser_asm_lex_set_col_c(lex_inout, c);
    }
    return 1;
  }
  return 0;
}

/**
 * Consume qualified type IDENT path `a.b.Type` into out[0..*out_len).
 * wave582 Cap residual: content cap 63→255 (Type.name[256]). First
 * IDENT is already in hand (first_ident_len); lex_inout sits past it.
 * Peek DOT then step — no lexer_result save/restore. Caps copy the C
 * twin (`>255 → 127`; `total>=127` fail; `total+seg>255 → 127-total`).
 * @param source *u8 — opaque slice; null → -1
 * @param lex_inout *u8 — opaque lexer (r.next_lex); mutated; null → -1
 * @param out *u8 — destination; caller cap ≥128; null → -1
 * @param out_len *i32 — written byte count slot; null → -1
 * @param first_ident_len i32 — already-consumed first IDENT length; ≤0 → -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: SHARED product type_ref path. P3d dest-buffer split.
 * Name copy is P1b at_end (G.7). parse_type_ref stays C.
 */
#[no_mangle]
export function parser_asm_consume_qualified_type_ident_name_into_c(source: *u8, lex_inout: *u8, out: *u8, out_len: *i32, first_ident_len: i32): i32 {
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let seg_len: i32 = 0;
  let total: i32 = 0;
  let kind: i32 = 0;
  let zi: i32 = 0;
  let start: usize = 0;
  if (source == 0 as *u8 || lex_inout == 0 as *u8 || out == 0 as *u8 || out_len == 0 as *i32 || first_ident_len <= 0) {
    return -1;
  }
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source) as i32;
    if (data == 0 as *u8) {
      return -1;
    }
    seg_len = first_ident_len;
    if (seg_len > 255) {
      seg_len = 127;
    }
    parser_asm_copy_slice_to_name64_at_end_buf_c(data, slen, parser_asm_lex_pos_c(lex_inout), seg_len, out);
    total = seg_len;
    while (1 == 1) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_DOT) {
        out_len[0] = total;
        return 0;
      }
      if (total >= 127) {
        return -1;
      }
      out[total as usize] = 46;
      total = total + 1;
      kind = parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_IDENT) {
        return -1;
      }
      seg_len = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (seg_len <= 0) {
        return -1;
      }
      if (total + seg_len > 255) {
        seg_len = 127 - total;
      }
      if (seg_len <= 0) {
        return -1;
      }
      kind = parser_asm_lex_step_kind_c(lex_inout, source);
      // Subsequent segments write at out[total]; P1b at_end dest is out[0]
      // only. Index copy matches name64_buf (skip bytes past slen).
      zi = 0;
      start = parser_asm_lex_pos_c(lex_inout) - (seg_len as usize);
      while (zi < seg_len) {
        if (start + zi as usize < slen as usize) {
          out[(total + zi) as usize] = data[start + zi as usize];
        }
        zi = zi + 1;
      }
      total = total + seg_len;
    }
  }
  return -1;
}

/**
 * Allocate TYPE_DYN wrapping `inner_tr`. If inner is already TYPE_DYN,
 * return it (no nested fat). Copies the trait name from a TYPE_NAMED
 * inner for diagnostics / F2 impl lookup when name_len is in (0, 128).
 * G.7: single TYPE_DYN allocator for type-position registered trait names.
 * @param arena *u8 — AST arena; null → inner_tr
 * @param inner_tr i32 — inner type_ref (trait NAMED, or already DYN); <=0 → inner_tr
 * @param name_scratch *u8 — dest for sidecar NAMED spelling; caller owns
 *   ≥256 bytes; null skips the name copy (name_len stays 0)
 * @return i32 — TYPE_DYN type_ref, or inner_tr on alloc failure
 * PLATFORM: SHARED type grammar. P3e dest-buffer split of the former
 * static C twin. Writer = pipeline_type_init_dyn_c (P3 seed).
 */
#[no_mangle]
export function parser_asm_alloc_dyn_type_ref_into_c(arena: *u8, inner_tr: i32, name_scratch: *u8): i32 {
  let ik: i32 = 0;
  let dyn_tr: i32 = 0;
  let nlen: i32 = 0;
  if (arena == 0 as *u8 || inner_tr <= 0) {
    return inner_tr;
  }
  ik = pipeline_type_kind_ord_at(arena, inner_tr);
  if (ik == TYPE_DYN) {
    return inner_tr;
  }
  dyn_tr = ast_ast_arena_type_alloc(arena);
  if (dyn_tr == 0) {
    return inner_tr;
  }
  nlen = 0;
  if (ik == TYPE_NAMED && name_scratch != 0 as *u8) {
    nlen = pipeline_type_named_name_into(arena, inner_tr, name_scratch);
    if (nlen <= 0) {
      nlen = 0;
    }
    if (nlen >= 128) {
      nlen = 0;
    }
  }
  pipeline_type_init_dyn_c(arena, dyn_tr, inner_tr, name_scratch, nlen);
  return dyn_tr;
}

/**
 * If `named_tr` is TYPE_NAMED of a registered trait, wrap TYPE_DYN.
 * This is the only type-position producer of TYPE_DYN (write `Clone`,
 * not `dyn Clone`). Struct/alias names stay TYPE_NAMED.
 * @param arena *u8 — AST arena; null → named_tr
 * @param named_tr i32 — candidate type_ref; <=0 → named_tr
 * @param name_scratch *u8 — dest for sidecar NAMED spelling; caller
 *   owns ≥256 bytes; null → named_tr
 * @return i32 — TYPE_DYN type_ref, or the original ref
 * PLATFORM: SHARED type grammar. P3e dest-buffer split of the former
 * static C twin. parse_type_ref stays C and calls the trampoline.
 */
#[no_mangle]
export function parser_asm_wrap_registered_trait_as_dyn_into_c(arena: *u8, named_tr: i32, name_scratch: *u8): i32 {
  let kind: i32 = 0;
  let nlen: i32 = 0;
  if (arena == 0 as *u8 || named_tr <= 0 || name_scratch == 0 as *u8) {
    return named_tr;
  }
  kind = pipeline_type_kind_ord_at(arena, named_tr);
  if (kind != TYPE_NAMED) {
    return named_tr;
  }
  nlen = pipeline_type_named_name_into(arena, named_tr, name_scratch);
  if (nlen <= 0) {
    return named_tr;
  }
  if (xlang_skip_trait_is_registered_c(name_scratch, nlen) == 0) {
    return named_tr;
  }
  return parser_asm_alloc_dyn_type_ref_into_c(arena, named_tr, name_scratch);
}

/**
 * Parse postfix slice after a consumed `[`: first token must be `]`.
 * Optional `<ident>` region label (M-3, ident_len in 1..63). Entry
 * cursor is unconsumed; success parks after `]` or after `>`.
 * @param arena *u8 — AST arena; null → 0
 * @param elem_tr i32 — element type_ref; <=0 → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param label_scratch *u8 — dest for region label; caller owns ≥64
 *   bytes; null fails the `<ident>` path (no-label `T[]` still works)
 * @return i32 — TYPE_SLICE type_ref, or 0
 * PLATFORM: SHARED type grammar. P3g dest-buffer split of the former
 * static C twin. Writer = pipeline_type_init_slice_c (P3 seed). Name
 * copy is P1b from token_start (G.7 ≡ C twin). parse_type_ref stays C.
 */
#[no_mangle]
export function parser_asm_parse_postfix_slice_x_into_c(arena: *u8, elem_tr: i32, lex_inout: *u8, source: *u8, label_scratch: *u8): i32 {
  let kind: i32 = 0;
  let nlen: i32 = 0;
  let slice_ref: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let ts: usize = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || elem_tr == 0) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RBRACKET) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    slice_ref = ast_ast_arena_type_alloc(arena);
    if (slice_ref == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LT) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (kind != TOKEN_IDENT || nlen <= 0 || nlen > 63 || label_scratch == 0 as *u8) {
        return 0;
      }
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      parser_asm_lex_step_kind_c(lex_inout, source);
      data = parser_asm_lex_source_data_c(source);
      slen = parser_asm_lex_source_length_c(source) as i32;
      if (data == 0 as *u8) {
        return 0;
      }
      /* G.7 ≡ C twin copy from token_start (not at_end: next_lex.pos
       * may sit past the IDENT). */
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, nlen, label_scratch);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_GT) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      pipeline_type_init_slice_c(arena, slice_ref, elem_tr, label_scratch, nlen);
      return slice_ref;
    }
    pipeline_type_init_slice_c(arena, slice_ref, elem_tr, 0 as *u8, 0);
    return slice_ref;
  }
  return 0;
}

/**
 * Parse postfix array/slice after an element type: `T[]` / `T[]<label>` /
 * `T[N]` / `T[N][M]…`. Entry cursor is unconsumed. If the next token is
 * not `[`, the cursor is left unchanged and `elem_tr` is returned.
 * Empty `[]` is slice only as the first postfix (`T[N][]` fail-closed).
 * Cap 8 dims; wrap right-to-left so `i32[2][3]` ≡ array-of-2 of
 * array-of-3 of i32.
 * @param arena *u8 — AST arena; null → elem_tr when no `[`, else 0
 * @param elem_tr i32 — element type_ref; <=0 → elem_tr
 * @param lex_inout *u8 — opaque lexer; mutated; null → elem_tr
 * @param source *u8 — opaque slice; null → elem_tr
 * @param label_scratch *u8 — forwarded to the slice helper; caller
 *   owns ≥64 bytes
 * @return i32 — TYPE_ARRAY / TYPE_SLICE type_ref, elem_tr if no `[`,
 *   or 0 on failure
 * PLATFORM: SHARED type grammar. P3g dest-buffer split of the former
 * static C twin. Writer = pipeline_type_init_compound_kind_at (ARRAY).
 * Do not `break` out of the dim while (P4bh). parse_type_ref stays C.
 */
#[no_mangle]
export function parser_asm_parse_postfix_array_x_into_c(arena: *u8, elem_tr: i32, lex_inout: *u8, source: *u8, label_scratch: *u8): i32 {
  let kind: i32 = 0;
  let iv: i32 = 0;
  let ndims: i32 = 0;
  let more: i32 = 0;
  let di: i32 = 0;
  let cur: i32 = 0;
  let arr_ref: i32 = 0;
  let ok: i32 = 0;
  let dims: i32[8] = [];
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || elem_tr == 0) {
    return elem_tr;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACKET) {
      return elem_tr;
    }
    ndims = 0;
    more = 1;
    while (more == 1) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_RBRACKET) {
        if (ndims > 0) {
          return 0;
        }
        return parser_asm_parse_postfix_slice_x_into_c(arena, elem_tr, lex_inout, source, label_scratch);
      }
      if (kind != TOKEN_INT) {
        return 0;
      }
      iv = parser_asm_lex_peek_int_val_c(lex_inout, source);
      if (iv <= 0) {
        return 0;
      }
      if (ndims >= 8) {
        return 0;
      }
      dims[ndims] = iv;
      ndims = ndims + 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_RBRACKET) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_LBRACKET) {
        more = 0;
      }
    }
    if (arena == 0 as *u8) {
      return 0;
    }
    cur = elem_tr;
    di = ndims - 1;
    while (di >= 0) {
      arr_ref = ast_ast_arena_type_alloc(arena);
      if (arr_ref == 0) {
        return 0;
      }
      ok = pipeline_type_init_compound_kind_at(arena, arr_ref, TYPE_ARRAY, cur, dims[di]);
      if (ok == 0) {
        return 0;
      }
      cur = arr_ref;
      di = di - 1;
    }
    return cur;
  }
  return 0;
}
