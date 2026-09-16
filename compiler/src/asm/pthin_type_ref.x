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
// Hybrid P3b/P3c/P3d/P3e/P3g/P3h/P3i/P3j/P3k/P3l/P3m/P3n/P3o/P3p/P3q/P3r: g05_try_x_to_o this file;
// XLANG_PTHIN_TYPE_REF_BODIES_FROM_X skips the portable .inc region.
// XLANG_PTHIN_TYPE_REF_POSTFIX_FROM_X / PREFIX_FROM_X / FN_FROM_X /
// STAR_FROM_X / LINEAR_FROM_X / VEC_FROM_X / ALLOC_VEC_FROM_X /
// SCALAR_FROM_X / NAMED_FROM_X / GENERIC_FROM_X / IDENT_VEC_FROM_X /
// IMPL_FROM_X are separate defines (P6e PARSE_LAYOUT / P2c COND
// pattern) so a missing postfix_x / prefix_x / fn_x / star_x /
// linear_x / vec_x / alloc_x / scalar_x / named_x / generic_x / ident_vec_x / impl_x keeps that C twin without
// dropping P3b–P3e.
// token.h remains the TOKEN_*
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
// 7.2.1 P3h B-minus (2026-09-16): 有则补全 prefix `[N]T` / `[]T` /
// `[]T<label>` dest-buffer. The LBRACKET arm was inlined in
// parse_type_ref_impl (always host-cc; not behind BODIES/POSTFIX).
// P9a peek/step consumes `[`; empty `[]` is slice then recurse for T
// (label after T, unlike postfix `T[]<label>`). `[N]` wraps ARRAY
// around the recursive elem (multi-dim `[2][3]T` is recurse, not a
// dim loop). ARRAY/SLICE writers = P3g (init_compound ARRAY /
// init_slice_c). Elem walk = existing primary parse_type_ref_ptr
// shim (G.7; do not dest-buffer parse_type_ref — P3f hello/fmt red).
// C trampoline holds label[64]. Do not copy wrap into parse. Do not
// merge wrap. Do not FORCE pabi mega. Do not open a new P-lane.
// 7.2.1 P3i B-minus (2026-09-16): 有则补全 type-position
// `function(T0, T1, ...): Ret` dest-buffer. The FUNCTION arm was
// inlined in parse_type_ref_impl (always host-cc; not behind
// BODIES/POSTFIX/PREFIX). P9a peek/step consumes `function` then
// `(`; empty `()` is n_params=0; params recurse via the existing
// primary parse_type_ref_ptr shim (G.7; do not dest-buffer
// parse_type_ref — P3f hello/fmt red). Return type follows `:`.
// TYPE_FN writes go through pipeline_type_init_fn_c in this P3 seed
// (kind=18 raw; do not FORCE pabi mega; do not reuse
// init_compound_kind_at — kind_ord cap 15). Params land in the
// existing pipeline_type_append_type_arg sidecar (G.7). C trampoline
// publishes *out_lex. Do not apply postfix after TYPE_FN (C twin
// does not). Do not `break` out of nested while. Do not dest-buffer
// IDENT generic type-arg. parse_type_ref_impl stays C.
// 7.2.1 P3j B-minus (2026-09-16): 有则补全 prefix `*T` / `**T` /
// `*[]T` / `*[N]T` dest-buffer. The STAR arm was inlined in
// parse_type_ref_impl (always host-cc; not behind BODIES/POSTFIX/
// PREFIX/FN). P9a peek/step consumes one or more `*`; empty pointee
// fails closed. `*[` / `*dyn` / `*impl` recurse via the existing
// primary parse_type_ref_ptr shim (G.7; do not dest-buffer
// parse_type_ref — P3f hello/fmt red). Scalar/IDENT pointee mirrors
// alloc_pointee: IDENT → consume_qualified + init_named_at; builtin
// including VOID → init_primitive_kind_at (0..16; G.7). PTR wrap
// reuses init_compound_kind_at (TYPE_PTR=9 < 15). C-style `*T[N]`
// postfix is the existing P3g array helper (same file). C trampoline
// holds name[256] + qn_len + label[64] (no local u8[N], no &local
// i32). Do not copy wrap into parse. Do not merge wrap. Do not FORCE
// pabi mega. Do not open a new P-lane. Do not dest-buffer IDENT
// generic type-arg. parse_type_ref_impl stays C.
// 7.2.1 P3k B-minus (2026-09-16): 有则补全 IDENT `Linear(T)` dest-buffer.
// The Linear arm was inlined in parse_type_ref_impl (always host-cc;
// not behind BODIES/POSTFIX/PREFIX/FN/STAR). P9a peek/step consumes
// IDENT spelling `Linear` then `(`, recurse T, `)`. Bare `Linear`
// (no `(`) fails closed — same as the C twin; it is not a NAMED
// fallback. Inner T = existing primary parse_type_ref_ptr shim (G.7;
// do not dest-buffer parse_type_ref — P3f hello/fmt red). TYPE_LINEAR
// writer = init_compound_kind_at (kind 12 < 15; G.7). Do not apply
// postfix after Linear (C twin does not). Do not dest-buffer IDENT
// generic type-arg get/set. parse_type_ref_impl stays C.
// 7.2.1 P3l B-minus (2026-09-16): 有则补全 builtin vec token dest-buffer.
// The TOKEN_I32X4 / I32X8 / I32X16 / U32X4 / U32X8 / U32X16 / F32X4
// arm was inlined in parse_type_ref_impl (always host-cc). Lexer
// keyword-matches `i32x4` etc. to these tokens (not IDENT). P9a
// peek/step consumes the token; elem_ord/lanes copy the C twin
// (F32X4 elem_ord=13, not TYPE_F32=14 — do not "fix"). VECTOR
// writer = init_compound_kind_at (kind 13 < 15; G.7). Elem scalar
// = pipeline_type_ensure_by_kind_ord (G.7). No postfix (C twin
// does not). Do not dest-buffer IDENT vector spelling consume
// (pack already .x; leftover alloc wrap is P3m). Do not dest-buffer
// parse_type_ref. parse_type_ref_impl stays C.
// 7.2.1 P3m Route C (2026-09-16): 有则补全 alloc_vector_type_ref.
// Shared TYPE_VECTOR allocator used by IDENT spelling (from_ident)
// and by P3l builtin vec token. Writer = init_compound_kind_at
// (kind 13) + ensure_by_kind_ord for elem (G.7). ALLOC_VEC is a
// separate define so a missing alloc_x keeps the C twin without
// dropping P3l. Do not merge into parse_type_ref_impl (P3f red).
// Do not open a new P-lane. Do not FORCE pabi mega.
// 7.2.1 P3n B-minus (2026-09-16): 有则补全 builtin scalar/void token
// dest-buffer. The TOKEN_I32 / BOOL / I64 / U8 / U32 / U64 / USIZE /
// ISIZE / VOID / F32 / F64 arm was inlined in parse_type_ref_impl
// (always host-cc). P9a peek/step consumes the token; kind_ord is
// the existing builtin_kind_ord table (G.7). Writer =
// init_primitive_kind_at (0..16, including VOID=16). Postfix
// `i32[]` / `i32[N]` stays in the C impl (already P3g). Not-scalar
// leaves lex unchanged so IDENT still sees the token. SCALAR is a
// separate define so a missing scalar_x keeps the C twin without
// dropping P3m. Do not dest-buffer parse_type_ref (P3f red). Do not
// dest-buffer IDENT generic type-arg. Do not dest-buffer IDENT
// vector spelling consume. Do not open a new P-lane. Do not FORCE
// pabi mega. Do not touch pthin_expr_primary.x (current xlang T001).
// 7.2.1 P3o B-minus (2026-09-16): 有则补全 IDENT named / dyn / impl
// peel dest-buffer. The `dyn` P013 prefix, `impl Trait` peel, and
// TYPE_NAMED + consume_qualified soup were inlined in
// parse_type_ref_impl (always host-cc). P9a peek/step owns the
// unconsumed cursor. `dyn` + following type reports P013 and
// fail-closes (lex past `dyn`); bare `dyn` restores so NAMED
// still sees the IDENT. `impl` + following type recurses via the
// existing primary parse_type_ref_ptr shim (G.7; do not dest-buffer
// parse_type_ref — P3f hello/fmt red). IDENT NAMED writer =
// init_named_at (G.7; same as P3j pointee). C trampoline holds
// name[256] + qn_len (no local u8[N], no &local i32). Generic
// `<T,U>` type-arg dest-buffer is P3p. wrap_dyn stays P3e (after
// `<T>` so `Wrap<i32>` is not a trait). Postfix stays P3g. NAMED
// is a separate define so a missing named_x keeps the C twin
// without dropping P3n. Do not dest-buffer parse_type_ref. Do
// not FORCE pabi mega. Do not open a new P-lane.
// 7.2.1 P3p B-minus (2026-09-16): 有则补全 IDENT generic `<T,U>`
// type-arg dest-buffer. The optional angle list after TYPE_NAMED
// was inlined in parse_type_ref_impl (always host-cc). P9a
// peek/step owns the unconsumed `<`; each arg recurses via the
// existing primary parse_type_ref_ptr shim (G.7; do not dest-buffer
// parse_type_ref — P3f hello/fmt red). Sidecar append =
// pipeline_type_append_type_arg (G.7; same as P3i TYPE_FN params).
// first-arg + count stamp = pipeline_type_set_elem_array_size_at
// (G.7; do not Type by-value get/set; do not FORCE pabi mega).
// Nested `Name<Name<T>>` close reuses the P3d RSHIFT contract
// (step `>>` then rewind pos/col by 1). Not-`<` leaves lex
// unchanged so wrap_dyn / postfix still see `[`. GENERIC is a
// separate define so a missing generic_x keeps the C loop without
// dropping P3o. Do not dest-buffer parse_type_ref. Do not FORCE
// pabi mega. Do not open a new P-lane. Do not `break` out of the
// arg while (P4bh parse-drop).
// 7.2.1 P3q B-minus (2026-09-16): dest-buffer IDENT vector spelling
// consume (complete existing type_ref.x). Historical ban was "thin
// compositor" (pack already .x; alloc already P3m). Re-ranked live:
// remaining C is start recovery (token_start==0 → next_pos -
// ident_len) plus pack + alloc. C trampoline holds lexer_result
// by-value and extracts data/length/token_start/ident_len/
// next_pos (language has no lexer_result by-value). Stretch
// audit stays in the C trampoline (AUDIT_CALL product no-op).
// IDENT_VEC is a separate define so a missing ident_vec_x keeps
// the C compositor without dropping P3p. Do not dest-buffer
// parse_type_ref (P3f hello/fmt red). parse_type_ref_impl stays
// C until P3r. Do not FORCE pabi mega. Do not open a new P-lane.
// 7.2.1 P3r B-minus (2026-09-16): dest-buffer parse_type_ref_impl
// dispatcher (complete existing type_ref.x). Historical ban was
// dest-buffer parse_type_ref (P3f hello/fmt red) and "dispatcher
// stays C". Re-ranked live after P3q: every arm already lives in
// .x (peel / fn / star / prefix / vec / scalar / linear / ident
// vec / named / generic / wrap_dyn / postfix). Remaining C is
// peel + first-token dispatch + IDENT compositor. Published face
// stays parse_type_ref_impl_c / slice_c; recursion still goes
// through the existing primary parse_type_ref_ptr shim (G.7; do
// not dest-buffer parse_type_ref). C trampoline holds name[256] +
// qn_len + label[64] (language has no local u8[N] / &local i32)
// and keeps AUDIT_CALL (product no-op). IMPL is a separate define
// so a missing impl_x keeps the C compositor without dropping
// P3q. Do not FORCE pabi mega. Do not open a new P-lane.
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
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;
const TOKEN_COMMA: i32 = 90;
const TOKEN_COLON: i32 = 91;
const TOKEN_DOT: i32 = 92;
const TOKEN_STAR: i32 = 98;
const TOKEN_RSHIFT: i32 = 105;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;

/** P9a: peek next kind without advancing the opaque lexer. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek line of the next token (P013 dyn prefix). */
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek column of the next token (P013 dyn prefix). */
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
/** P9a: consume one token; returns its kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: lexer line / col for restore after a failed peel probe. */
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
/** P013 reporter (body_tl). G.7 one diagnostic; do not copy. */
export extern "C" function parser_report_dyn_prefix_p013_c(line: i32, col: i32): void;
/** P9a: peek ident_len of the next token. */
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek TOKEN_INT payload as i32 (array dim). */
export extern "C" function parser_asm_lex_peek_int_val_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek token_start of the next token (IDENT label copy). */
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
/** P9a: peek next_lex.pos of the next token (IDENT vec start recovery). */
export extern "C" function parser_asm_lex_peek_next_pos_c(lex_inout: *u8, source: *u8): usize;
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
const TYPE_LINEAR: i32 = 12;
const TYPE_VECTOR: i32 = 13;
const TYPE_F32: i32 = 14;
const TYPE_F64: i32 = 15;
const TYPE_VOID: i32 = 16;
const TYPE_DYN: i32 = 17;
const TYPE_FN: i32 = 18;

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
 * array_size. TYPE_ARRAY=10 / TYPE_LINEAR=12 fit the cap (G.7). Do not
 * reuse for TYPE_DYN=17 (P3e). Labeled TYPE_SLICE uses
 * pipeline_type_init_slice_c (set_region_label_at wipes elem_type_ref
 * on the current Type layout).
 */
export extern "C" function pipeline_type_init_compound_kind_at(a: *u8, ref: i32, kind_ord: i32, elem_ref: i32, array_size: i32): i32;
/**
 * P3g consumer-wave writer: stamp TYPE_SLICE + elem + optional region
 * label. Lives in the P3 seed; do not copy; do not FORCE pabi mega.
 */
export extern "C" function pipeline_type_init_slice_c(a: *u8, ref: i32, elem_tr: i32, label: *u8, nlen: i32): void;
/**
 * P3i consumer-wave writer: stamp TYPE_FN (kind=18) + return elem +
 * n_params in array_size. Lives in the P3 seed; do not copy; do not
 * FORCE pabi mega; do not reuse init_compound_kind_at (kind_ord cap
 * 15; pipe_ty_kind_from_ord clamps >16 to TYPE_I32).
 */
export extern "C" function pipeline_type_init_fn_c(a: *u8, ref: i32, ret_tr: i32, n_params: i32): void;
/**
 * Existing sidecar: append one type-arg (TYPE_FN params / generic
 * args). G.7 one writer; do not copy.
 */
export extern "C" function pipeline_type_append_type_arg(arena: *u8, type_ref: i32, arg_ref: i32): i32;
/**
 * Existing sidecar: stamp Type.elem_type_ref + array_size.
 * G.7 one writer for the IDENT generic first-arg/count pair
 * (C twin used Type by-value get/set). Do not FORCE pabi mega.
 */
export extern "C" function pipeline_type_set_elem_array_size_at(arena: *u8, ref: i32, elem_ref: i32, array_size: i32): i32;
/**
 * Existing pabi writer: zero a Type slot and write a primitive
 * kind_ord 0..16 (VOID=16). G.7 one scalar writer; do not copy;
 * do not FORCE pabi mega.
 */
export extern "C" function pipeline_type_init_primitive_kind_at(a: *u8, ref: i32, kind_ord: i32): i32;
/**
 * Existing pabi writer: zero a Type slot and write TYPE_NAMED +
 * spelling (nlen 1..255). G.7 one NAMED writer; do not copy.
 */
export extern "C" function pipeline_type_init_named_at(a: *u8, ref: i32, name: *u8, name_len: i32): i32;
/**
 * Existing pabi: intern a primitive TypeKind (0..16) and return its
 * type_ref. G.7 one intern; VECTOR elem uses this (do not alloc a
 * second primitive table).
 */
export extern "C" function pipeline_type_ensure_by_kind_ord(arena: *u8, kind: i32): i32;
/** P1b: token that may follow `*` as a pointee. G.7 one table. */
export extern "C" function parser_asm_is_pointee_type_token_c(kind: i32): i32;
/** Skip-trait registry predicate (skip_tl). G.7: one lookup table. */
export extern "C" function xlang_skip_trait_is_registered_c(trait_nm: *u8, trait_nlen: i32): i32;
/**
 * Existing primary pointer-face parse_type_ref (G.7 one shim).
 * Prefix `[N]T` / `[]T` recurse through this; do not dest-buffer
 * parse_type_ref (P3f was hello/fmt red).
 */
export extern "C" function parser_asm_parse_type_ref_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;

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
 * True when IDENT spelling is type-position `Linear` (docs Linear(T)).
 * Byte values copy the C twin (76/105/110/101/97/114) — capital L,
 * not lowercase `linear`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the six bytes are `Linear`; 0 otherwise
 * PLATFORM: SHARED — buf-path sibling of ident_is_dyn (G.7 spelling family).
 */
function parser_asm_type_ref_ident_is_linear(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_type_ref_ident_span_ok(data, length, token_start, ident_len, 6) == 0) {
    return 0;
  }
  if (parser_asm_type_ref_ident_byte(data, token_start, 0) == 76 && parser_asm_type_ref_ident_byte(data, token_start, 1) == 105
      && parser_asm_type_ref_ident_byte(data, token_start, 2) == 110 && parser_asm_type_ref_ident_byte(data, token_start, 3) == 101
      && parser_asm_type_ref_ident_byte(data, token_start, 4) == 97 && parser_asm_type_ref_ident_byte(data, token_start, 5) == 114) {
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

/**
 * Parse prefix array/slice: `[N]T` / `[]T` / `[]T<label>`. Entry cursor
 * is unconsumed. First token must be `[`; otherwise 0 and the cursor
 * is left unchanged. Empty `[]` is slice, then recurse for T; optional
 * `<ident>` label is after T (not after `[]` — that is postfix). `[N]`
 * wraps TYPE_ARRAY around the recursive elem. Multi-dim `[2][3]T` is
 * recurse, not a dim loop.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param label_scratch *u8 — dest for region label; caller owns ≥64
 *   bytes; null fails the `<ident>` path (no-label `[]T` still works)
 * @return i32 — TYPE_ARRAY / TYPE_SLICE type_ref, or 0
 * PLATFORM: SHARED type grammar. P3h dest-buffer split of the former
 * inlined LBRACKET arm. Writer = P3g init_compound ARRAY /
 * init_slice_c. Elem = primary parse_type_ref_ptr (G.7). Do not
 * dest-buffer parse_type_ref. parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_prefix_array_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, label_scratch: *u8): i32 {
  let kind: i32 = 0;
  let nlen: i32 = 0;
  let iv: i32 = 0;
  let elem_tr: i32 = 0;
  let slice_ref: i32 = 0;
  let arr_ref: i32 = 0;
  let ok: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let ts: usize = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACKET) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RBRACKET) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      elem_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
      if (elem_tr == 0) {
        return 0;
      }
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
        /* G.7 ≡ C twin copy from token_start (not at_end). */
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
    if (kind != TOKEN_INT) {
      return 0;
    }
    iv = parser_asm_lex_peek_int_val_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RBRACKET) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    elem_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (elem_tr == 0) {
      return 0;
    }
    arr_ref = ast_ast_arena_type_alloc(arena);
    if (arr_ref == 0) {
      return 0;
    }
    ok = pipeline_type_init_compound_kind_at(arena, arr_ref, TYPE_ARRAY, elem_tr, iv);
    if (ok == 0) {
      return 0;
    }
    return arr_ref;
  }
  return 0;
}

/**
 * Parse type-position `function(T0, T1, ...): Ret` into a TYPE_FN slot.
 * Peek must be TOKEN_FUNCTION else 0 (lex unchanged). Bare `function`
 * (no `(`) consumes the keyword and returns 0, leaving lex before the
 * next token — same as the C twin. Empty `()` is n_params=0. Each
 * param and the return type recurse through parse_type_ref_ptr.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @return i32 — TYPE_FN type_ref, or 0
 * PLATFORM: SHARED type grammar. P3i dest-buffer split of the former
 * inlined FUNCTION arm. Writer = pipeline_type_init_fn_c. Params =
 * pipeline_type_append_type_arg (G.7). Elem walk = primary
 * parse_type_ref_ptr (G.7). Do not dest-buffer parse_type_ref. Do not
 * apply postfix after TYPE_FN. parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_fn_type_x_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let param_tr: i32 = 0;
  let ret_tr: i32 = 0;
  let fn_ref: i32 = 0;
  let n_params: i32 = 0;
  let done: i32 = 0;
  let ap: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_FUNCTION) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    fn_ref = ast_ast_arena_type_alloc(arena);
    if (fn_ref == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
    } else {
      done = 0;
      while (done == 0) {
        param_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
        if (param_tr == 0) {
          return 0;
        }
        ap = pipeline_type_append_type_arg(arena, fn_ref, param_tr);
        n_params = n_params + 1;
        if (ap != 0) {
          return 0;
        }
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
        } else {
          if (kind == TOKEN_RPAREN) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            done = 1;
          } else {
            return 0;
          }
        }
      }
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ret_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (ret_tr == 0) {
      return 0;
    }
    pipeline_type_init_fn_c(arena, fn_ref, ret_tr, n_params);
    return fn_ref;
  }
  return 0;
}

/**
 * Parse prefix pointer type `*T` / `**T` / `*[]T` / `*[N]T`.
 * Peek must be TOKEN_STAR else 0 (lex unchanged). One or more `*`
 * are consumed; the pointee is then:
 *   - unconsumed `[` / contextual `dyn` / `impl` → parse_type_ref_ptr
 *     (inner owns the token; `*[]T` is PTR-to-SLICE, not slice-of-PTR)
 *   - IDENT → consume_qualified + TYPE_NAMED (alloc_pointee mirror)
 *   - builtin scalar/void → init_primitive_kind_at (0..16)
 * Each `*` wraps TYPE_PTR around the pointee (inner-first). C-style
 * postfix `*T[N]` is parse_postfix_array_x (same file).
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param name_scratch *u8 — dest for qualified NAMED spelling;
 *   caller owns ≥256 bytes; null fails the IDENT pointee path
 * @param qn_len_slot *i32 — C-owned length slot for consume_qualified
 *   (language has no &local i32); null fails the IDENT pointee path
 * @param label_scratch *u8 — forwarded to postfix array/slice;
 *   caller owns ≥64 bytes
 * @return i32 — TYPE_PTR (possibly postfix ARRAY/SLICE) type_ref, or 0
 * PLATFORM: SHARED type grammar. P3j dest-buffer split of the former
 * inlined STAR arm. PTR writer = init_compound_kind_at (kind 9).
 * NAMED writer = init_named_at. Scalar writer = init_primitive_kind_at.
 * Elem walk = primary parse_type_ref_ptr (G.7). Do not dest-buffer
 * parse_type_ref. parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_star_type_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, name_scratch: *u8, qn_len_slot: *i32, label_scratch: *u8): i32 {
  let kind: i32 = 0;
  let ptr_depth: i32 = 0;
  let elem_tr: i32 = 0;
  let wrap_tr: i32 = 0;
  let got_elem: i32 = 0;
  let first: i32 = 0;
  let nlen: i32 = 0;
  let ord: i32 = 0;
  let ok: i32 = 0;
  let rc: i32 = 0;
  let ts: usize = 0;
  let slen: usize = 0;
  let data: *u8 = 0 as *u8;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STAR) {
      return 0;
    }
    ptr_depth = 0;
    while (kind == TOKEN_STAR) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      ptr_depth = ptr_depth + 1;
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    got_elem = 0;
    if (kind == TOKEN_LBRACKET) {
      elem_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
      got_elem = 1;
    } else {
      if (kind == TOKEN_IMPL) {
        elem_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
        got_elem = 1;
      } else {
        if (kind == TOKEN_IDENT) {
          nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
          ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
          data = parser_asm_lex_source_data_c(source);
          slen = parser_asm_lex_source_length_c(source);
          if (parser_asm_type_ref_ident_is_dyn_buf_c(data, slen, ts, nlen) != 0) {
            elem_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
            got_elem = 1;
          }
        }
      }
    }
    if (got_elem == 0) {
      if (parser_asm_is_pointee_type_token_c(kind) == 0) {
        return 0;
      }
      if (kind == TOKEN_IDENT) {
        first = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        parser_asm_lex_step_kind_c(lex_inout, source);
        rc = parser_asm_consume_qualified_type_ident_name_into_c(source, lex_inout, name_scratch, qn_len_slot, first);
        if (rc != 0) {
          return 0;
        }
        elem_tr = ast_ast_arena_type_alloc(arena);
        if (elem_tr == 0) {
          return 0;
        }
        nlen = 0;
        if (qn_len_slot != 0 as *i32) {
          nlen = qn_len_slot[0];
        }
        ok = pipeline_type_init_named_at(arena, elem_tr, name_scratch, nlen);
        if (ok == 0) {
          return 0;
        }
      } else {
        ord = parser_asm_type_ref_builtin_kind_ord_c(kind);
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (ord < 0) {
          ord = TYPE_VOID;
        }
        elem_tr = ast_ast_arena_type_alloc(arena);
        if (elem_tr == 0) {
          return 0;
        }
        ok = pipeline_type_init_primitive_kind_at(arena, elem_tr, ord);
        if (ok == 0) {
          return 0;
        }
      }
    }
    if (elem_tr == 0) {
      return 0;
    }
    while (ptr_depth > 0) {
      wrap_tr = ast_ast_arena_type_alloc(arena);
      if (wrap_tr == 0) {
        return 0;
      }
      ok = pipeline_type_init_compound_kind_at(arena, wrap_tr, TYPE_PTR, elem_tr, 0);
      if (ok == 0) {
        return 0;
      }
      elem_tr = wrap_tr;
      ptr_depth = ptr_depth - 1;
    }
    return parser_asm_parse_postfix_array_x_into_c(arena, elem_tr, lex_inout, source, label_scratch);
  }
  return 0;
}

/**
 * Parse type-position `Linear(T)` into a TYPE_LINEAR slot.
 * Peek must be IDENT spelling `Linear` else 0 (lex unchanged) so the
 * C IDENT arm can still see vector aliases / NAMED / generic args.
 * Bare `Linear` (no `(`) consumes the IDENT and returns 0 — same as
 * the C twin; it is not a NAMED fallback. Inner T recurses through
 * parse_type_ref_ptr. No postfix after Linear (C twin does not).
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @return i32 — TYPE_LINEAR type_ref, or 0
 * PLATFORM: SHARED type grammar. P3k dest-buffer split of the former
 * inlined Linear IDENT arm. Writer = init_compound_kind_at (kind 12).
 * Elem walk = primary parse_type_ref_ptr (G.7). Do not dest-buffer
 * parse_type_ref. Do not dest-buffer IDENT generic type-arg.
 * parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_linear_type_x_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let nlen: i32 = 0;
  let ts: usize = 0;
  let slen: usize = 0;
  let data: *u8 = 0 as *u8;
  let inner_tr: i32 = 0;
  let linear_ref: i32 = 0;
  let ok: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    if (parser_asm_type_ref_ident_is_linear(data, slen, ts, nlen) == 0) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    inner_tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (inner_tr == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    linear_ref = ast_ast_arena_type_alloc(arena);
    if (linear_ref == 0) {
      return 0;
    }
    ok = pipeline_type_init_compound_kind_at(arena, linear_ref, TYPE_LINEAR, inner_tr, 0);
    if (ok == 0) {
      return 0;
    }
    return linear_ref;
  }
  return 0;
}

/**
 * Map a builtin SIMD type token to the elem TypeKind ordinal.
 * Copies the C twin: i32x* → 0, u32x* → 3, f32x4 → 13 (not TYPE_F32=14).
 * @param kind i32 — lexer token kind
 * @return i32 — elem_ord, or -1 if kind is not a vec token
 * PLATFORM: SHARED — P3l. Do not "fix" F32X4=13.
 */
function parser_asm_builtin_vec_token_elem_ord(kind: i32): i32 {
  if (kind == TOKEN_U32X4 || kind == TOKEN_U32X8 || kind == TOKEN_U32X16) {
    return 3;
  }
  if (kind == TOKEN_F32X4) {
    return 13;
  }
  if (kind == TOKEN_I32X4 || kind == TOKEN_I32X8 || kind == TOKEN_I32X16) {
    return 0;
  }
  return -1;
}

/**
 * Map a builtin SIMD type token to lane count.
 * Copies the C twin: default 4; *X8 → 8; *X16 → 16.
 * @param kind i32 — lexer token kind (caller already checked vec)
 * @return i32 — 4, 8, or 16
 * PLATFORM: SHARED — P3l lanes table. Do not merge with IDENT pack.
 */
function parser_asm_builtin_vec_token_lanes(kind: i32): i32 {
  if (kind == TOKEN_I32X8 || kind == TOKEN_U32X8) {
    return 8;
  }
  if (kind == TOKEN_I32X16 || kind == TOKEN_U32X16) {
    return 16;
  }
  return 4;
}

/**
 * Parse type-position builtin SIMD tokens (`i32x4` / `u32x8` / `f32x4` …)
 * into a TYPE_VECTOR slot. Peek must be a vec token else 0 (lex
 * unchanged) so the C scalar/IDENT arms still see the token. No
 * postfix (C twin does not).
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @return i32 — TYPE_VECTOR type_ref, or 0
 * PLATFORM: SHARED type grammar. P3l dest-buffer split of the former
 * inlined vec-token arm. Writer = init_compound_kind_at (kind 13).
 * Elem intern = ensure_by_kind_ord (G.7). Do not dest-buffer
 * parse_type_ref. Do not dest-buffer IDENT vector spelling.
 * parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_builtin_vec_type_x_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let elem_ord: i32 = 0;
  let lanes: i32 = 0;
  let elem_tr: i32 = 0;
  let vec_ref: i32 = 0;
  let ok: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    elem_ord = parser_asm_builtin_vec_token_elem_ord(kind);
    if (elem_ord < 0) {
      return 0;
    }
    lanes = parser_asm_builtin_vec_token_lanes(kind);
    parser_asm_lex_step_kind_c(lex_inout, source);
    elem_tr = pipeline_type_ensure_by_kind_ord(arena, elem_ord);
    if (elem_tr == 0) {
      return 0;
    }
    vec_ref = ast_ast_arena_type_alloc(arena);
    if (vec_ref == 0) {
      return 0;
    }
    ok = pipeline_type_init_compound_kind_at(arena, vec_ref, TYPE_VECTOR, elem_tr, lanes);
    if (ok == 0) {
      return 0;
    }
    return vec_ref;
  }
  return 0;
}

/**
 * Allocate a TYPE_VECTOR node (elem_ord = TypeKind ordinal, lanes = width).
 * @param arena *u8 — AST arena; null → 0
 * @param elem_ord i32 — scalar elem kind ordinal (ensure_by_kind_ord)
 * @param lanes i32 — vector lane count (stored as array_size)
 * @return i32 — TYPE_VECTOR type_ref, or 0
 * PLATFORM: SHARED — product P3m Route C. Shared by IDENT spelling
 * (from_ident C trampoline) and P3l builtin vec. Writer =
 * init_compound_kind_at (kind 13). Do not merge into parse_type_ref_impl.
 */
#[no_mangle]
export function parser_asm_alloc_vector_type_ref_x_into_c(arena: *u8, elem_ord: i32, lanes: i32): i32 {
  let elem_tr: i32 = 0;
  let vec_ref: i32 = 0;
  let ok: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  unsafe {
    elem_tr = pipeline_type_ensure_by_kind_ord(arena, elem_ord);
    if (elem_tr == 0) {
      return 0;
    }
    vec_ref = ast_ast_arena_type_alloc(arena);
    if (vec_ref == 0) {
      return 0;
    }
    ok = pipeline_type_init_compound_kind_at(arena, vec_ref, TYPE_VECTOR, elem_tr, lanes);
    if (ok == 0) {
      return 0;
    }
    return vec_ref;
  }
  return 0;
}

/**
 * Parse type-position builtin scalar/void tokens (`i32` / `bool` /
 * `i64` / `u8` / `u32` / `u64` / `usize` / `isize` / `void` / `f32` /
 * `f64`) into a primitive Type slot. Peek must map through
 * builtin_kind_ord else 0 (lex unchanged) so the C IDENT arm still
 * sees the token. Postfix `T[]` / `T[N]` stays in the C impl (P3g).
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @return i32 — primitive type_ref, or 0
 * PLATFORM: SHARED type grammar. P3n dest-buffer split of the former
 * inlined scalar-token arm. Writer = init_primitive_kind_at (0..16).
 * Kind table = builtin_kind_ord (G.7). Do not dest-buffer
 * parse_type_ref. Do not dest-buffer IDENT generic type-arg.
 * parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_builtin_scalar_type_x_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let ord: i32 = 0;
  let type_ref: i32 = 0;
  let ok: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    ord = parser_asm_type_ref_builtin_kind_ord_c(kind);
    if (ord < 0) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    type_ref = ast_ast_arena_type_alloc(arena);
    if (type_ref == 0) {
      return 0;
    }
    ok = pipeline_type_init_primitive_kind_at(arena, type_ref, ord);
    if (ok == 0) {
      return 0;
    }
    return type_ref;
  }
  return 0;
}

/**
 * Peel type-position `dyn` / `impl` prefixes. Unconsumed cursor.
 * `dyn` followed by a type is P013 (hard-fail; lex parks past `dyn`).
 * Bare `dyn` restores so the IDENT NAMED arm still sees the token.
 * `impl` followed by a type recurses through parse_type_ref_ptr
 * (inner owns postfix / wrap_dyn). `impl` without a type restores
 * and returns 0 (C twin then fail-closes; TOKEN_IMPL is not NAMED).
 * Not dyn/impl leaves lex unchanged.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @return i32 — peeled type_ref, or 0 (P013 / not-this-path / fail)
 * PLATFORM: SHARED type grammar. P3o dest-buffer split of the former
 * inlined dyn/impl arms. Recurse = primary parse_type_ref_ptr (G.7).
 * Do not dest-buffer parse_type_ref. Do not dest-buffer IDENT
 * generic type-arg. parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_peel_dyn_impl_prefix_x_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let kind2: i32 = 0;
  let nlen: i32 = 0;
  let ts: usize = 0;
  let slen: usize = 0;
  let data: *u8 = 0 as *u8;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let dyn_line: i32 = 0;
  let dyn_col: i32 = 0;
  let inner: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_IDENT) {
      nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      data = parser_asm_lex_source_data_c(source);
      slen = parser_asm_lex_source_length_c(source);
      if (parser_asm_type_ref_ident_is_dyn_buf_c(data, slen, ts, nlen) != 0) {
        dyn_line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
        dyn_col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (parser_asm_type_ref_token_starts_type_c(kind2) != 0) {
          parser_report_dyn_prefix_p013_c(dyn_line, dyn_col);
          return 0;
        }
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 0;
      }
    } else {
      if (kind == TOKEN_IMPL) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (parser_asm_type_ref_token_starts_type_c(kind2) != 0) {
          inner = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
          return inner;
        }
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 0;
      }
    }
    return 0;
  }
  return 0;
}

/**
 * Parse type-position IDENT NAMED (`Foo` / `a.b.Type`) into a
 * TYPE_NAMED slot. Peek must be IDENT else 0 (lex unchanged) so
 * Linear / vector IDENT still own those spellings. consume_qualified
 * walks `a.b.Type` via P3d. Generic `<T,U>` is P3p. wrap_dyn
 * stays P3e (after `<T>`). Postfix stays P3g. consume fail
 * restores the entry cursor.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param name_scratch *u8 — dest for qualified spelling; caller owns
 *   ≥256 bytes; null → 0
 * @param qn_len_slot *i32 — dest for name_len; C trampoline owns;
 *   null → 0
 * @return i32 — TYPE_NAMED type_ref, or 0
 * PLATFORM: SHARED type grammar. P3o dest-buffer split of the former
 * inlined IDENT NAMED arm. Writer = init_named_at (G.7). Do not
 * dest-buffer parse_type_ref. Generic `<T,U>` is P3p.
 * parse_type_ref_impl stays C.
 */
#[no_mangle]
export function parser_asm_parse_named_type_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, name_scratch: *u8, qn_len_slot: *i32): i32 {
  let kind: i32 = 0;
  let first: i32 = 0;
  let nlen: i32 = 0;
  let rc: i32 = 0;
  let ok: i32 = 0;
  let type_ref: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  if (name_scratch == 0 as *u8 || qn_len_slot == 0 as *i32) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    first = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (first <= 0) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    qn_len_slot[0] = 0;
    rc = parser_asm_consume_qualified_type_ident_name_into_c(source, lex_inout, name_scratch, qn_len_slot, first);
    if (rc != 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 0;
    }
    nlen = qn_len_slot[0];
    if (nlen <= 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 0;
    }
    type_ref = ast_ast_arena_type_alloc(arena);
    if (type_ref == 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 0;
    }
    ok = pipeline_type_init_named_at(arena, type_ref, name_scratch, nlen);
    if (ok == 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 0;
    }
    return type_ref;
  }
  return 0;
}

/**
 * Parse optional type-position generic args after a TYPE_NAMED slot
 * (`Name<T>` / `Name<T,U>` / nested `Name<Name<T>>`). Peek must be
 * TOKEN_LT else `named_tr` is returned and lex is unchanged so
 * wrap_dyn / postfix still see `[`. Each arg recurses through
 * parse_type_ref_ptr. COMMA continues; TOKEN_GT consumes; TOKEN_RSHIFT
 * (`>>`) closes this level and leaves one `>` (P3d contract: step
 * then rewind pos/col by 1). Fail-closed: a missing arg or a non
 * comma/close token returns 0 with lex parked at the fail site.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param named_tr i32 — TYPE_NAMED type_ref from P3o; <=0 → 0
 * @return i32 — named_tr with sidecar args, named_tr if no `<`, or 0
 * PLATFORM: SHARED type grammar. P3p dest-buffer split of the former
 * inlined IDENT generic get/set soup. Append =
 * pipeline_type_append_type_arg (G.7). first-arg + count =
 * pipeline_type_set_elem_array_size_at (G.7). Recurse = primary
 * parse_type_ref_ptr (G.7). Do not dest-buffer parse_type_ref.
 * parse_type_ref_impl stays C. wrap_dyn stays P3e (after this).
 * Postfix stays P3g. Do not `break` out of the arg while.
 */
#[no_mangle]
export function parser_asm_parse_named_generic_args_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, named_tr: i32): i32 {
  let kind: i32 = 0;
  let ta_ref: i32 = 0;
  let first_ta: i32 = 0;
  let n_ta: i32 = 0;
  let done: i32 = 0;
  let p: usize = 0;
  let c: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  if (named_tr <= 0) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LT) {
      return named_tr;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    done = 0;
    while (done == 0) {
      ta_ref = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
      if (ta_ref == 0) {
        return 0;
      }
      if (n_ta == 0) {
        first_ta = ta_ref;
      }
      if (ta_ref > 0) {
        pipeline_type_append_type_arg(arena, named_tr, ta_ref);
      }
      n_ta = n_ta + 1;
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_COMMA) {
        parser_asm_lex_step_kind_c(lex_inout, source);
      } else {
        if (kind == TOKEN_GT) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          done = 1;
        } else {
          if (kind == TOKEN_RSHIFT) {
            /* P3d nested `>>`: consume both bytes then leave one `>`
             * for the outer list (rewind pos/col by 1; line stays). */
            parser_asm_lex_step_kind_c(lex_inout, source);
            p = parser_asm_lex_pos_c(lex_inout);
            c = parser_asm_lex_col_c(lex_inout);
            if (p > 0 as usize) {
              p = p - 1 as usize;
            }
            if (c > 1) {
              c = c - 1;
            }
            parser_asm_lex_set_pos_c(lex_inout, p);
            parser_asm_lex_set_col_c(lex_inout, c);
            done = 1;
          } else {
            return 0;
          }
        }
      }
    }
    if (first_ta > 0) {
      pipeline_type_set_elem_array_size_at(arena, named_tr, first_ta, n_ta);
    }
    return named_tr;
  }
  return 0;
}

/**
 * IDENT spelling consume: recover start, pack i32x4/Vec4f/…, alloc TYPE_VECTOR.
 * token_start==0 recovers start from next_pos - ident_len (lexer_result
 * token_start was unset). Writers = pack_c (G.7) + alloc_x (P3m G.7).
 * Stretch audit stays in the C trampoline (AUDIT_CALL product no-op).
 * @param arena *u8 — AST arena; null → 0
 * @param data *u8 — source bytes; null → 0 (pack rejects)
 * @param length usize — source length
 * @param token_start usize — IDENT first byte; 0 may mean unset
 * @param ident_len i32 — IDENT payload length; <=0 or >63 → 0
 * @param next_pos usize — lexer next_lex.pos for start recovery
 * @return i32 — TYPE_VECTOR type_ref, or 0 if the spelling is not a vector alias
 * PLATFORM: SHARED type grammar. P3q dest-buffer of from_ident_spelling.
 * parse_type_ref_impl stays C. Do not dest-buffer parse_type_ref (P3f).
 * Do not FORCE pabi mega. Do not open a new P-lane.
 */
#[no_mangle]
export function parser_asm_vector_type_ref_from_ident_spelling_x_into_c(arena: *u8, data: *u8, length: usize, token_start: usize, ident_len: i32, next_pos: usize): i32 {
  let start: usize = 0;
  let pack: i32 = 0;
  let vec_ref: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  if (ident_len <= 0 || ident_len > 63) {
    return 0;
  }
  start = token_start;
  if (token_start == 0 as usize && next_pos >= ident_len as usize) {
    start = next_pos - ident_len as usize;
  }
  unsafe {
    pack = parser_asm_vector_type_ident_pack_c(data, length, start, ident_len);
    if (pack == 0) {
      return 0;
    }
    vec_ref = parser_asm_alloc_vector_type_ref_x_into_c(arena, pack >> 8, pack & 255);
    return vec_ref;
  }
  return 0;
}

/**
 * IDENT arm of parse_type_ref_impl: Linear, IDENT vector spelling,
 * TYPE_NAMED + optional `<T,U>`, wrap_dyn, postfix. Unconsumed cursor.
 * Linear miss with a moved cursor fail-closes (bare `Linear` is not
 * NAMED). Vector miss leaves IDENT for NAMED. Named fail-closes.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param name_scratch *u8 — dest for NAMED spelling / wrap_dyn;
 *   caller owns ≥256 bytes; null → 0
 * @param qn_len_slot *i32 — C-owned length slot; null → 0
 * @param label_scratch *u8 — dest for postfix region label;
 *   caller owns ≥64 bytes; null → 0
 * @return i32 — type_ref, or 0
 * PLATFORM: SHARED type grammar. P3r dest-buffer split of the former
 * inlined IDENT compositor. Writers stay in the existing arm helpers
 * (G.7). Do not dest-buffer parse_type_ref (P3f). 8 lets.
 */
#[no_mangle]
export function parser_asm_parse_type_ref_impl_ident_x(arena: *u8, lex_inout: *u8, source: *u8, name_scratch: *u8, qn_len_slot: *i32, label_scratch: *u8): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let ref: i32 = 0;
  let nlen: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  if (name_scratch == 0 as *u8 || qn_len_slot == 0 as *i32 || label_scratch == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    ref = parser_asm_parse_linear_type_x_into_c(arena, lex_inout, source);
    if (ref != 0) {
      return ref;
    }
    if (parser_asm_lex_pos_c(lex_inout) != pos0) {
      return 0;
    }
    if (parser_asm_lex_line_c(lex_inout) != line0) {
      return 0;
    }
    if (parser_asm_lex_col_c(lex_inout) != col0) {
      return 0;
    }
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    ref = parser_asm_vector_type_ref_from_ident_spelling_x_into_c(
        arena, data, slen, ts, nlen, parser_asm_lex_peek_next_pos_c(lex_inout, source));
    if (ref != 0) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return ref;
    }
    ref = parser_asm_parse_named_type_x_into_c(arena, lex_inout, source, name_scratch, qn_len_slot);
    if (ref == 0) {
      return 0;
    }
    ref = parser_asm_parse_named_generic_args_x_into_c(arena, lex_inout, source, ref);
    if (ref == 0) {
      return 0;
    }
    ref = parser_asm_wrap_registered_trait_as_dyn_into_c(arena, ref, name_scratch);
    return parser_asm_parse_postfix_array_x_into_c(arena, ref, lex_inout, source, label_scratch);
  }
  return 0;
}

/**
 * parse_type_ref_impl dispatcher: peel dyn/impl, then dispatch the
 * first unconsumed token to the existing arm helpers. FUNCTION / STAR
 * / LBRACKET return even on 0 (those helpers may consume on fail).
 * Vec / scalar self-reject and leave lex unchanged. IDENT goes to
 * impl_ident_x. Recursion stays on parse_type_ref_ptr (G.7).
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — opaque lexer; mutated; null → 0
 * @param source *u8 — opaque slice; null → 0
 * @param name_scratch *u8 — dest for NAMED / star pointee / wrap_dyn;
 *   caller owns ≥256 bytes; null → 0
 * @param qn_len_slot *i32 — C-owned length slot; null → 0
 * @param label_scratch *u8 — dest for prefix/postfix/star label;
 *   caller owns ≥64 bytes; null → 0
 * @return i32 — type_ref, or 0
 * PLATFORM: SHARED type grammar. P3r dest-buffer of the former C
 * compositor. AUDIT stays in the C trampoline. Do not dest-buffer
 * parse_type_ref (P3f hello/fmt red). Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_parse_type_ref_impl_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, name_scratch: *u8, qn_len_slot: *i32, label_scratch: *u8): i32 {
  let peeled: i32 = 0;
  let kind: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let type_ref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  if (name_scratch == 0 as *u8 || qn_len_slot == 0 as *i32 || label_scratch == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    peeled = parser_asm_peel_dyn_impl_prefix_x_into_c(arena, lex_inout, source);
    if (peeled != 0) {
      return peeled;
    }
    if (parser_asm_lex_pos_c(lex_inout) != pos0) {
      return 0;
    }
    if (parser_asm_lex_line_c(lex_inout) != line0) {
      return 0;
    }
    if (parser_asm_lex_col_c(lex_inout) != col0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_FUNCTION) {
      return parser_asm_parse_fn_type_x_into_c(arena, lex_inout, source);
    }
    if (kind == TOKEN_STAR) {
      return parser_asm_parse_star_type_x_into_c(arena, lex_inout, source, name_scratch, qn_len_slot, label_scratch);
    }
    if (kind == TOKEN_LBRACKET) {
      return parser_asm_parse_prefix_array_x_into_c(arena, lex_inout, source, label_scratch);
    }
    type_ref = parser_asm_parse_builtin_vec_type_x_into_c(arena, lex_inout, source);
    if (type_ref != 0) {
      return type_ref;
    }
    type_ref = parser_asm_parse_builtin_scalar_type_x_into_c(arena, lex_inout, source);
    if (type_ref != 0) {
      return parser_asm_parse_postfix_array_x_into_c(arena, type_ref, lex_inout, source, label_scratch);
    }
    if (kind == TOKEN_IDENT) {
      return parser_asm_parse_type_ref_impl_ident_x(arena, lex_inout, source, name_scratch, qn_len_slot, label_scratch);
    }
    return 0;
  }
  return 0;
}
