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
// (runtime_pipeline_abi.x). parse / library / one_function stay C.
// block_from_res is P6f. Compare cap `ii < 64` is the C twin's
// historical bound — keep it.
// 7.2.1 P6c B-minus (2026-09-15): 有则补全 packed/soa modifier predicates.
// Language has no lexer_result field access; the C trampoline in
// struct_layout.inc forwards tok.kind / ident_len / next_lex.pos plus
// source data/length. IDENT fallback uses next_pos - ident_len (same
// formula as the C twin; do not switch to token_start). Do not merge
// with P19d field-name kind (field start vs struct-name modifier).
// Do not copy these probes into parse_struct_record_layout. Do not
// open a new P-lane.
//
// 7.2.1 P6d B-minus (2026-09-15): 有则补全 library-shape wrap dest-buffer
// in this same domain file (efficiency: one L2 for remaining wrap soup
// in library_slice.inc). Always-host-cc wrap sites:
//   TYPE_BOOL return type
//   TYPE_NAMED param type
//   EXPR_VAR param + EXPR_FIELD_ACCESS + EXPR_ENUM_VARIANT + EXPR_EQ
// Language has no Type/Expr by-value / no local u8[N]; C trampoline
// forwards scan name buffers. Sidecar writes reuse existing pabi
// pipeline_type_init_primitive_kind_at / init_named_at and
// pipeline_expr_set_kind / set_common_zeros / set_line_col /
// set_var_name / set_field_access_c / set_resolved_type_ref plus
// P4bc set_binop_operands_c (G.7 one writer for binop slots; do not
// copy; do not FORCE pabi mega; do not merge with P4bc wrap).
// parse_one_function_library published face + scan stay C
// (struct-by-value result). Remaining compositor is P6g. Do not
// copy wrap into parse_type_ref / parse_match / P15 library_wrap
// scan. Do not copy name-match loops into library_slice. Do not
// mix range_for. Do not wrap AUDIT. Do not open a new P-lane.
//
// 7.2.1 P6e B-minus (2026-09-16): 有则补全 parse_struct_record_layout
// dest-buffer. P9a peek/step walks IDENT name / optional <T,U> /
// packed|soa / { align? let? field: T ;|, ... }. Name-match stays
// P6b; packed/soa stays P6c; type_ref stays the primary ptr shim
// (do not dest-buffer parse_type_ref — P3f was hello/fmt red).
// Language has no local u8[N] / u8[8][256]; C trampoline holds the
// sname/fname/tp pack. Skip-generic / skip-braces stay P1b. Field
// names stay P19d from_kind. Do not `break` out of nested while.
// Do not merge wrap. Do not mix range_for. Do not wrap AUDIT. Do
// not open a new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P6f B-minus (2026-09-16): dest-buffer fill_block_const_let_from_res
// + append_block_lets_from_res. Historical ban was Expr by-value init
// (elf_ec=-1). Re-ranked live: writers already exist
// (pipeline_expr_set_kind / set_int_val / set_common_zeros_c +
// pipeline_block_append_const / append_let + pipeline_onefunc_*).
// Language has no local u8[N] / onefunc_result by-value; the C
// trampoline holds name[256], extracts the sidecar pool, and writes
// res->num_consts / num_lets. AUDIT stays in the C trampoline
// (product AUDIT_CALL is nop). Do not dest-buffer parse_one_function.
// parse_one_function_library remaining compositor is P6g. Do not
// dest-buffer parse_type_ref (P3f). Do not dest-buffer append_byte.
// Do not mix range_for. Do not wrap AUDIT. Do not open a new P-lane.
// Do not FORCE pabi mega.
//
// 7.2.1 P6g B-minus (2026-09-16): dest-buffer the remaining
// parse_one_function_library compositor (labeled block + maybe
// layout + module func slot). Historical ban was Block by-value
// zeros without writers. Re-ranked live: writer already exists
// (pipeline_parser_library_init_labeled_block_c — zeros, append
// labeled return, zeros expr/final/order). Layout writers =
// name_exists_arr_c (P6b) + pipeline_module_struct_layout_*.
// Func slot writers = existing pipeline_module_func_* (G.7; do
// not copy skip_tl extern-add — is_extern=0 and body=block_ref).
// Language has no library_parse_result by-value; published face
// stays slice_c; C trampoline holds scan + writes ok/next_lex/name.
// AUDIT stays in the C trampoline. Do not dest-buffer scan (P15b).
// Do not dest-buffer wrap (P6d). Do not dest-buffer parse_one_function.
// Do not dest-buffer parse_type_ref (P3f). Do not dest-buffer
// append_byte. Do not mix range_for. Do not wrap AUDIT. Do not
// open a new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P6h B-minus (2026-09-16): dest-buffer parse_one_function_buf
// header (LPAREN params RPAREN `: Type {`). Name copy + AUDIT + body
// stmt loop stay C (local u8[256] + lexer_next_buf + nested for-init
// while). type_ref stays the primary ptr shim (do not dest-buffer
// parse_type_ref — P3f was hello/fmt red). Param names use P1b
// copy_slice_to_param32 (G.7). Sidecar writes reuse
// pipeline_onefunc_append_param / set_param_type_ref. P011 / P014 /
// P012 reporters stay C. Language has no onefunc_result by-value;
// C trampoline holds pname[256] and writes num_params /
// func_return_type_ref. Do not dest-buffer parse_one_function.
// Do not dest-buffer the buf body loop this wave. Do not mix
// range_for. Do not wrap AUDIT. Do not open a new P-lane. Do not
// FORCE pabi mega.
//
// Hybrid P6b/P6c/P6d/P6e/P6f/P6g/P6h: g05_try_x_to_o this file;
// XLANG_PTHIN_FN_BLOCK_BODIES_FROM_X skips name-match + modifiers +
// library wrap; XLANG_PTHIN_FN_BLOCK_PARSE_LAYOUT_FROM_X skips the
// layout parse C twin when parse_x is present;
// XLANG_PTHIN_FN_BLOCK_BLOCK_FROM_RES_FROM_X skips the block_from_res
// C twin when fill_x is present (independent sibling after
// PARSE_LAYOUT so a missing fill_x keeps the C twin without dropping
// P6e). XLANG_PTHIN_FN_BLOCK_LIBRARY_FROM_X skips the remaining
// library compositor when init_block_x + register_x are present
// (independent sibling after BLOCK_FROM_RES so a missing finish
// keeps the C twin without dropping P6f).
// XLANG_PTHIN_FN_BLOCK_ONEFUNC_BUF_HDR_FROM_X skips the buf-path
// header C twin when header_x is present (independent sibling after
// LIBRARY so a missing header_x keeps the C twin without dropping
// P6g). P9a is linked later into the same thin_glue (same as
// P7d/P4ud). Cold: no define, full .inc.
// Do not reuse XLANG_PTHIN_FN_BLOCK_FROM_X for P6b–P6h bodies.
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
/** Sidecar: allocate a layout slot; -1 on full. */
export extern "C" function pipeline_module_struct_layout_alloc(module: *u8): i32;
/** Sidecar: wipe one layout slot before rewrite. */
export extern "C" function pipeline_module_struct_layout_reset_slot(module: *u8, idx: i32): void;
/** Sidecar: write layout name bytes. */
export extern "C" function pipeline_module_struct_layout_set_name(module: *u8, idx: i32, bytes: *u8, len: i32): void;
/** Sidecar: write field count. */
export extern "C" function pipeline_module_struct_layout_set_num_fields(module: *u8, idx: i32, nf: i32): void;
/** Sidecar: allow_padding flag. */
export extern "C" function pipeline_module_struct_layout_set_allow_padding(module: *u8, idx: i32, v: i32): void;
/** Sidecar: soa flag. */
export extern "C" function pipeline_module_struct_layout_set_soa(module: *u8, idx: i32, v: i32): void;
/** Sidecar: packed flag. */
export extern "C" function pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void;
/** Sidecar: repr_compatible flag. */
export extern "C" function pipeline_module_struct_layout_set_repr_compatible(module: *u8, idx: i32, v: i32): void;
/** Sidecar: write one field name/type/offset at (layout, field). */
export extern "C" function pipeline_module_struct_layout_set_field(module: *u8, li: i32, j: i32, fname: *u8, fname_len: i32, type_ref: i32, field_off: i32): void;
/** Sidecar: write field_align at (layout, field). */
export extern "C" function pipeline_module_struct_layout_set_field_align(module: *u8, li: i32, j: i32, al: i32): void;
/** Sidecar: next field offset given type + align req. */
export extern "C" function pipeline_struct_layout_next_field_offset_ex(module: *u8, arena: *u8, layout_idx: i32, new_field_type_ref: i32, field_align_req: i32): i32;

/** Allocate a fresh Type slot; 0 on failure. */
export extern "C" function ast_ast_arena_type_alloc(arena: *u8): i32;
/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** Allocate a fresh Block slot; 0 on failure. */
export extern "C" function ast_ast_arena_block_alloc(arena: *u8): i32;
/**
 * pabi library helper: zero Block counts, append a labeled return of
 * eq_ref, then zero num_expr_stmts / final_expr_ref / num_stmt_order.
 * @return i32 — 0 ok, -1 fail
 */
export extern "C" function pipeline_parser_library_init_labeled_block_c(arena: *u8, block_ref: i32, eq_ref: i32): i32;
/** Module func slot alloc; -1 on full. */
export extern "C" function pipeline_module_func_alloc_slot(m: *u8): i32;
/** Write func name bytes. */
export extern "C" function pipeline_module_func_name_write(m: *u8, fi: i32, name: *u8, name_len: i32): void;
/** Write func param count. */
export extern "C" function pipeline_module_func_set_num_params(m: *u8, fi: i32, n: i32): void;
/** Write one param name + type. */
export extern "C" function pipeline_module_func_param_write(m: *u8, fi: i32, i: i32, name: *u8, name_len: i32, type_ref: i32): void;
/** Write func return type_ref. */
export extern "C" function pipeline_module_func_set_return_type(m: *u8, fi: i32, tr: i32): void;
/** Write func body block_ref. */
export extern "C" function pipeline_module_func_set_body_ref(m: *u8, fi: i32, br: i32): void;
/** Write func body expr ref (library path stores 0). */
export extern "C" function pipeline_module_func_set_body_expr_ref(m: *u8, fi: i32, er: i32): void;
/** Write is_extern flag (library path stores 0). */
export extern "C" function pipeline_module_func_set_is_extern(m: *u8, fi: i32, v: i32): void;
/** pabi: zero a Type slot and write a primitive kind_ord (0..16). */
export extern "C" function pipeline_type_init_primitive_kind_at(a: *u8, ref: i32, kind_ord: i32): i32;
/** pabi: zero a Type slot and write TYPE_NAMED + spelling (nlen 1..255). */
export extern "C" function pipeline_type_init_named_at(a: *u8, ref: i32, name: *u8, name_len: i32): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.int_val (i64 slot; i32 coerces). */
export extern "C" function pipeline_expr_set_int_val(a: *u8, er: i32, v: i64): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/** Wave-0: write Expr.resolved_type_ref. */
export extern "C" function pipeline_expr_set_resolved_type_ref(a: *u8, er: i32, type_ref: i32): void;
/** Sidecar: append a const decl onto the block; -1 on failure. */
export extern "C" function pipeline_block_append_const(arena: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
/** Sidecar: append a let decl onto the block; -1 on failure. */
export extern "C" function pipeline_block_append_let(arena: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
/** OneFunc sidecar: const count. */
export extern "C" function pipeline_onefunc_num_consts(out: *u8): i32;
/** OneFunc sidecar: let count. */
export extern "C" function pipeline_onefunc_num_lets(out: *u8): i32;
/** OneFunc sidecar: const type_ref at i (0 → caller fallback). */
export extern "C" function pipeline_onefunc_const_type_ref(out: *u8, i: i32): i32;
/** OneFunc sidecar: const init expr ref at i (0 → synthesize LIT). */
export extern "C" function pipeline_onefunc_const_init_ref(out: *u8, i: i32): i32;
/** OneFunc sidecar: const init integer when init_ref is 0. */
export extern "C" function pipeline_onefunc_const_init_val(out: *u8, i: i32): i32;
/** OneFunc sidecar: const name length at i. */
export extern "C" function pipeline_onefunc_const_name_len(out: *u8, i: i32): i32;
/** OneFunc sidecar: copy const name bytes into dst. */
export extern "C" function pipeline_onefunc_const_name_copy64(out: *u8, i: i32, dst: *u8): void;
/** OneFunc sidecar: let type_ref at i (0 → caller fallback). */
export extern "C" function pipeline_onefunc_let_type_ref(out: *u8, i: i32): i32;
/** OneFunc sidecar: let init expr ref at i (0 → LIT; -1 → no init). */
export extern "C" function pipeline_onefunc_let_init_ref(out: *u8, i: i32): i32;
/** OneFunc sidecar: let init integer when init_ref is 0. */
export extern "C" function pipeline_onefunc_let_init_val(out: *u8, i: i32): i32;
/** OneFunc sidecar: let name length at i. */
export extern "C" function pipeline_onefunc_let_name_len(out: *u8, i: i32): i32;
/** OneFunc sidecar: copy let name bytes into dst. */
export extern "C" function pipeline_onefunc_let_name_copy64(out: *u8, i: i32, dst: *u8): void;
/** Wave-0 pabi: write Expr.var_name / var_name_len (zeros the 256-byte slot). */
export extern "C" function pipeline_expr_set_var_name(a: *u8, er: i32, nm: *u8, nlen: i32): void;
/** Suffix pabi: write field_access_base_ref + field name (cap 255). */
export extern "C" function pipeline_expr_set_field_access_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void;
/**
 * P4bc consumer-wave writer: write Expr.binop_left_ref / binop_right_ref.
 * G.7: one writer for those slots. Lives in the P4bc seed; do not copy
 * into this seed; do not FORCE pabi mega; do not merge with P4bc wrap.
 */
export extern "C" function pipeline_expr_set_binop_operands_c(a: *u8, er: i32, left_ref: i32, right_ref: i32): void;

// TOKEN_* pin copies of include/token.h. P6 C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_LET: i32 = 2;
const TOKEN_CONST: i32 = 3;
const TOKEN_PACKED: i32 = 21;
const TOKEN_SOA: i32 = 22;
const TOKEN_ALIGN: i32 = 46;
const TOKEN_SELF: i32 = 51;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;
const TOKEN_BOOL: i32 = 61;
const TOKEN_U8: i32 = 62;
const TOKEN_U32: i32 = 63;
const TOKEN_U64: i32 = 64;
const TOKEN_I64: i32 = 65;
const TOKEN_USIZE: i32 = 66;
const TOKEN_VOID: i32 = 79;
const TOKEN_INT: i32 = 80;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_RBRACE: i32 = 85;
const TOKEN_COMMA: i32 = 90;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_PLUS: i32 = 96;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;

/** P9a lexer-step bridge. Pure peeks re-lex the same token. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_int_val_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_next_pos_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
/** P1b skip walks (pointer ABI). */
export extern "C" function parser_asm_skip_generic_angle_list_into_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_balanced_braces_into_c(lex_inout: *u8, source: *u8): i32;
/** G.7 one type_ref ptr shim (primary.inc). Do not dest-buffer parse_type_ref. */
export extern "C" function parser_asm_parse_type_ref_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;
/** P9a: token_start of the unconsumed peek; 0 → caller uses lex pos. */
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
/** P9a: current lexer byte pos. */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
/** P1b: fill a 256-byte param row from source[start..start+nlen). */
export extern "C" function parser_asm_copy_slice_to_param32_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** OneFunc sidecar: append a param; -1 on full. */
export extern "C" function pipeline_onefunc_append_param(pool: *u8, name: *u8, name_len: i32, type_ref: i32): i32;
/** OneFunc sidecar: write param type_ref at idx. */
export extern "C" function pipeline_onefunc_set_param_type_ref(pool: *u8, i: i32, type_ref: i32): void;
/** Cap residual: 1 if name already appears in params [0, nparams). */
export extern "C" function parser_onefunc_param_name_dup_c(pool: *u8, nparams: i32, name: *u8, name_len: i32): i32;
/** P014: keyword used as a binding name. */
export extern "C" function parser_report_keyword_binding_p014_c(line: i32, col: i32): void;
/** P012: duplicate name (kind 0 = param). */
export extern "C" function parser_report_duplicate_name_p012_c(line: i32, col: i32, kind: i32): void;
/** P011: untyped formal (kind 0) or missing return type (kind 1). */
export extern "C" function parser_report_untyped_formal_p011_c(line: i32, col: i32, kind: i32): void;
/** Trait-default hoist window: 1 allows bare `self` without `: Type`. */
export extern "C" function parser_allow_bare_self_pending_c(): i32;
/** P19d: field list can continue after `;` (name / let / const / align). */
export extern "C" function parser_asm_struct_field_continues_tok_kind_c(k: i32): i32;
/** P6e pack trampolines (C stack; language has no local u8[N]). */
export extern "C" function parser_asm_struct_layout_pack_reset_c(pack: *u8): void;
export extern "C" function parser_asm_struct_layout_pack_copy_sname_src_c(pack: *u8, source: *u8, next_pos: usize, ident_len: i32): i32;
export extern "C" function parser_asm_struct_layout_pack_name_exists_c(pack: *u8, module: *u8): i32;
export extern "C" function parser_asm_struct_layout_pack_placeholder_idx_c(pack: *u8, module: *u8): i32;
export extern "C" function parser_asm_struct_layout_pack_first_name_match_idx_c(pack: *u8, module: *u8): i32;
export extern "C" function parser_asm_struct_layout_pack_set_name_c(pack: *u8, module: *u8, layout_idx: i32): void;
export extern "C" function parser_asm_struct_layout_pack_tp_append_src_c(pack: *u8, source: *u8, next_pos: usize, ident_len: i32): i32;
export extern "C" function parser_asm_struct_layout_pack_tp_clear_c(pack: *u8): void;
export extern "C" function parser_asm_struct_layout_pack_tp_commit_c(pack: *u8, module: *u8, layout_idx: i32): void;
export extern "C" function parser_asm_struct_layout_pack_copy_fname_c(pack: *u8, source: *u8, kind: i32, ident_len: i32, next_pos: usize): i32;
export extern "C" function parser_asm_struct_layout_pack_dup_field_c(pack: *u8, module: *u8, layout_idx: i32, nf: i32, line: i32, col: i32): i32;
export extern "C" function parser_asm_struct_layout_pack_set_field_c(pack: *u8, module: *u8, layout_idx: i32, nf: i32, tr: i32, field_off: i32): void;

// TypeKind / ExprKind ords from ast.x (library_slice.inc pins the same
// subset). Do not treat these as a second enum authority.
const TYPE_BOOL: i32 = 1;
const TYPE_NAMED: i32 = 8;
const EXPR_VAR: i32 = 3;
const EXPR_EQ: i32 = 14;
const EXPR_FIELD_ACCESS: i32 = 44;
const EXPR_ENUM_VARIANT: i32 = 50;

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
 * `parser_asm_tok_is_modifier_packed`. parse_struct_record_layout dest-buffer
 * is P6e and calls this predicate; do not copy the spelling probe.
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
 * `parser_asm_tok_is_modifier_soa`. parse_struct_record_layout dest-buffer
 * is P6e and calls this predicate; do not copy the spelling probe.
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

/**
 * Allocate an Expr, wipe sidecar refs, write kind and line/col=0.
 * C twin writes kind then a handful of zeros + init_match; dest-buffer
 * uses pabi set_common_zeros_c (covers match slots and enum_variant_tag)
 * then kind then line/col. Extra zeros on a fresh slot are equivalent.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param kind i32 — ExprKind ordinal
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — P6d helper. Not a second wrap authority.
 */
function skip_lib_wrap_prep(arena: *u8, kind: i32): i32 {
  let ref: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  unsafe {
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      return 0;
    }
    pipeline_expr_set_common_zeros_c(arena, ref);
    pipeline_expr_set_kind(arena, ref, kind);
    pipeline_expr_set_line_col(arena, ref, 0, 0);
  }
  return ref;
}

/**
 * Allocate TYPE_BOOL (kind_ord=1). Dest-buffer twin of the bool_type
 * wrap soup in parser_asm_parse_one_function_library_slice_c.
 * @param arena *u8 — opaque AST arena; null → 0
 * @return i32 — new type ref, or 0 on null/alloc/init fail
 * PLATFORM: SHARED — P6d helper. Writer = pipeline_type_init_primitive_kind_at.
 */
function skip_lib_type_bool(arena: *u8): i32 {
  let ref: i32 = 0;
  let ok: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  unsafe {
    ref = ast_ast_arena_type_alloc(arena);
    if (ref == 0) {
      return 0;
    }
    ok = pipeline_type_init_primitive_kind_at(arena, ref, TYPE_BOOL);
  }
  if (ok == 0) {
    return 0;
  }
  return ref;
}

/**
 * Allocate TYPE_NAMED from `name[0..nlen)`. nlen<=0 still wraps as an
 * empty TYPE_NAMED (C twin writes kind=NAMED + name_len=0); pabi
 * init_named_at rejects nlen<=0 so that arm uses primitive_kind_at(8).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param name *u8 — param-type spelling; null → 0
 * @param nlen i32 — content length; <0 treated as 0
 * @return i32 — new type ref, or 0 on null/alloc/init fail
 * PLATFORM: SHARED — P6d helper. Writer = init_named_at / primitive_kind_at.
 * Do not reuse init_compound (P3e TYPE_DYN ban).
 */
function skip_lib_type_named(arena: *u8, name: *u8, nlen: i32): i32 {
  let ref: i32 = 0;
  let n: i32 = 0;
  let ok: i32 = 0;
  if (arena == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  n = nlen;
  if (n < 0) {
    n = 0;
  }
  if (n > 255) {
    n = 255;
  }
  unsafe {
    ref = ast_ast_arena_type_alloc(arena);
    if (ref == 0) {
      return 0;
    }
    if (n <= 0) {
      ok = pipeline_type_init_primitive_kind_at(arena, ref, TYPE_NAMED);
    } else {
      ok = pipeline_type_init_named_at(arena, ref, name, n);
    }
  }
  if (ok == 0) {
    return 0;
  }
  return ref;
}

/**
 * Allocate TYPE_BOOL + TYPE_NAMED + the `p.field == E.v` expr chain
 * (VAR + FIELD_ACCESS + ENUM_VARIANT + EQ) used by the library-shape
 * parser. Dest-buffer twin of the always-host-cc wrap soup in
 * parser_asm_parse_one_function_library_slice_c. C trampoline forwards
 * scan name buffers (language has no local u8[N]). Does not reject
 * nlen<=0 (C twin only checks alloc). nlen<0 is treated as 0.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param param_name *u8 — param IDENT bytes; null → 0
 * @param pnlen i32 — param name length
 * @param type_name *u8 — param type IDENT bytes; null → 0
 * @param tnlen i32 — param type name length
 * @param field_name *u8 — field IDENT bytes; null → 0
 * @param flen i32 — field name length
 * @param out_bool_tr *i32 — dest for TYPE_BOOL ref; null → 0
 * @param out_token_tr *i32 — dest for TYPE_NAMED ref; null → 0
 * @return i32 — EQ expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P6d Route C. Authority for the library
 * wrap family. Remaining compositor is P6g; do not copy wrap.
 * Do not merge with P4bc wrap / P5g match wrap / P3e TYPE_DYN wrap.
 */
#[no_mangle]
export function parser_asm_library_bool_eq_shape_wrap_into_c(arena: *u8, param_name: *u8, pnlen: i32, type_name: *u8, tnlen: i32, field_name: *u8, flen: i32, out_bool_tr: *i32, out_token_tr: *i32): i32 {
  let bool_tr: i32 = 0;
  let token_tr: i32 = 0;
  let var_ref: i32 = 0;
  let field_ref: i32 = 0;
  let enum_ref: i32 = 0;
  let eq_ref: i32 = 0;
  let pn: i32 = 0;
  let fn: i32 = 0;
  if (arena == 0 as *u8 || param_name == 0 as *u8 || type_name == 0 as *u8 || field_name == 0 as *u8 || out_bool_tr == 0 as *i32 || out_token_tr == 0 as *i32) {
    return 0;
  }
  pn = pnlen;
  if (pn < 0) {
    pn = 0;
  }
  fn = flen;
  if (fn < 0) {
    fn = 0;
  }
  bool_tr = skip_lib_type_bool(arena);
  if (bool_tr == 0) {
    return 0;
  }
  token_tr = skip_lib_type_named(arena, type_name, tnlen);
  if (token_tr == 0) {
    return 0;
  }
  var_ref = skip_lib_wrap_prep(arena, EXPR_VAR);
  if (var_ref == 0) {
    return 0;
  }
  unsafe {
    pipeline_expr_set_var_name(arena, var_ref, param_name, pn);
    pipeline_expr_set_resolved_type_ref(arena, var_ref, token_tr);
  }
  field_ref = skip_lib_wrap_prep(arena, EXPR_FIELD_ACCESS);
  if (field_ref == 0) {
    return 0;
  }
  unsafe {
    pipeline_expr_set_field_access_c(arena, field_ref, var_ref, field_name, fn);
  }
  enum_ref = skip_lib_wrap_prep(arena, EXPR_ENUM_VARIANT);
  if (enum_ref == 0) {
    return 0;
  }
  eq_ref = skip_lib_wrap_prep(arena, EXPR_EQ);
  if (eq_ref == 0) {
    return 0;
  }
  unsafe {
    pipeline_expr_set_binop_operands_c(arena, eq_ref, field_ref, enum_ref);
    pipeline_expr_set_resolved_type_ref(arena, eq_ref, bool_tr);
    out_bool_tr[0] = bool_tr;
    out_token_tr[0] = token_tr;
  }
  return eq_ref;
}

/**
 * Consume an optional `struct Name<T,U>` type-param list into `pack`.
 * Entry peek is the token after the struct name. No `<` is a no-op.
 * Malformed lists fall back to P1b skip_generic and clear captured names
 * (C twin). Leaves the cursor unconsumed on packed/soa/`{`.
 * Do not `break` out of the nested while.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param pack *u8 — C-stack name pack
 * @return i32 — 1 (always; malformed is recovered)
 * PLATFORM: SHARED — P6e helper. Not a second parse authority.
 */
function skip_layout_angle_list(lex_inout: *u8, source: *u8, pack: *u8): i32 {
  let kind: i32 = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let tp_done: i32 = 0;
  let bound_done: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || pack == 0 as *u8) {
    return 1;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    tp_done = 0;
    while (tp_done == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (kind != TOKEN_IDENT || il <= 0 || il > 255) {
        parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
        parser_asm_struct_layout_pack_tp_clear_c(pack);
        tp_done = 1;
      } else {
        np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
        parser_asm_struct_layout_pack_tp_append_src_c(pack, source, np, il);
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_COLON) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          bound_done = 0;
          while (bound_done == 0) {
            kind = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (kind == TOKEN_IDENT) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              kind = parser_asm_lex_peek_kind_c(lex_inout, source);
              if (kind == TOKEN_PLUS) {
                parser_asm_lex_step_kind_c(lex_inout, source);
              } else {
                bound_done = 1;
              }
            } else {
              bound_done = 1;
            }
          }
        }
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
        } else {
          if (kind == TOKEN_GT) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            tp_done = 1;
          } else {
            parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
            parser_asm_struct_layout_pack_tp_clear_c(pack);
            tp_done = 1;
          }
        }
      }
    }
  }
  return 1;
}

/**
 * Parse `Name [ <T,U> ] [packed] [soa] { [align(N)] [let|const] field: T ;|, ... }`
 * into the module sidecar. .x mirror of
 * parser_asm_parse_struct_record_layout_into_slice_c. Entry cursor is
 * the unconsumed struct name (caller already consumed `struct`).
 * ident_len<=0 or >255 fails (C twin; not clamp). Packed+soa together
 * fails. Duplicate field names report P012 and fail. Duplicate
 * non-placeholder layouts skip the body and return 0. Do not `break`
 * out of the field while.
 * @param arena *u8 — opaque AST arena; null → -1
 * @param module *u8 — opaque ast_Module; null → -1
 * @param lex_inout *u8 — cursor on the name; success parks after `}`
 * @param source *u8 — opaque slice
 * @param allow_pad i32 — sidecar allow_padding
 * @param force_soa i32 — #[soa] / caller soa; OR'd with `soa` modifier
 * @param repr_compat i32 — sidecar repr_compatible
 * @param pack *u8 — C-stack sname/fname/tp pack
 * @return i32 — 0 success (including dup-skip), -1 fail
 * PLATFORM: SHARED — product P6e B-minus. Name-match = P6b; packed/soa
 * = P6c; type_ref = primary ptr shim (do not dest-buffer parse_type_ref).
 * Do not merge wrap. Do not mix range_for. Do not wrap AUDIT. Do not
 * open a new lane. Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_parse_struct_record_layout_x_into_c(arena: *u8, module: *u8, lex_inout: *u8, source: *u8, allow_pad: i32, force_soa: i32, repr_compat: i32, pack: *u8): i32 {
  let kind: i32 = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  let is_soa: i32 = 0;
  let is_packed: i32 = 0;
  let dup: i32 = 0;
  let weak_idx: i32 = 0;
  let replace_idx: i32 = 0;
  let layout_idx: i32 = 0;
  let nf: i32 = 0;
  let fields_done: i32 = 0;
  let field_align_req: i32 = 0;
  let fn_len: i32 = 0;
  let tr: i32 = 0;
  let field_off: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let ival: i32 = 0;
  if (arena == 0 as *u8 || module == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || pack == 0 as *u8) {
    return -1;
  }
  unsafe {
    parser_asm_struct_layout_pack_reset_c(pack);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind != TOKEN_IDENT || il <= 0 || il > 255) {
      return -1;
    }
    np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    if (parser_asm_struct_layout_pack_copy_sname_src_c(pack, source, np, il) == 0) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    skip_layout_angle_list(lex_inout, source, pack);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    is_soa = force_soa;
    is_packed = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    if (parser_asm_tok_is_modifier_packed_c(kind, il, np, data, slen) != 0) {
      is_packed = 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    }
    if (parser_asm_tok_is_modifier_soa_c(kind, il, np, data, slen) != 0) {
      is_soa = 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (is_packed != 0 && is_soa != 0) {
      return -1;
    }
    if (kind != TOKEN_LBRACE) {
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    dup = parser_asm_struct_layout_pack_name_exists_c(pack, module);
    weak_idx = parser_asm_struct_layout_pack_placeholder_idx_c(pack, module);
    replace_idx = -1;
    if (dup != 0) {
      if (weak_idx < 0) {
        replace_idx = parser_asm_struct_layout_pack_first_name_match_idx_c(pack, module);
        if (replace_idx < 0) {
          parser_asm_skip_balanced_braces_into_c(lex_inout, source);
          return 0;
        }
      } else {
        replace_idx = weak_idx;
      }
    }
    layout_idx = replace_idx;
    if (layout_idx < 0) {
      layout_idx = pipeline_module_struct_layout_alloc(module);
      if (layout_idx < 0) {
        return -1;
      }
    }
    pipeline_module_struct_layout_reset_slot(module, layout_idx);
    parser_asm_struct_layout_pack_set_name_c(pack, module, layout_idx);
    parser_asm_struct_layout_pack_tp_commit_c(pack, module, layout_idx);
    nf = 0;
    fields_done = 0;
    while (fields_done == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      field_align_req = 0;
      if (kind == TOKEN_ALIGN) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_LPAREN) {
          return -1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        ival = parser_asm_lex_peek_int_val_c(lex_inout, source);
        if (kind != TOKEN_INT || ival <= 0) {
          return -1;
        }
        field_align_req = ival;
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_RPAREN) {
          return -1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      }
      if (kind == TOKEN_RBRACE) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        fields_done = 1;
      } else {
        if (kind == TOKEN_LET || kind == TOKEN_CONST) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        }
        il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
        tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
        tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
        fn_len = parser_asm_struct_layout_pack_copy_fname_c(pack, source, kind, il, np);
        if (fn_len < 0) {
          return -1;
        }
        if (parser_asm_struct_layout_pack_dup_field_c(pack, module, layout_idx, nf, tl, tc) != 0) {
          return -1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_COLON) {
          return -1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
        if (tr == 0) {
          return -1;
        }
        field_off = pipeline_struct_layout_next_field_offset_ex(module, arena, layout_idx, tr, field_align_req);
        parser_asm_struct_layout_pack_set_field_c(pack, module, layout_idx, nf, tr, field_off);
        if (field_align_req > 0) {
          pipeline_module_struct_layout_set_field_align(module, layout_idx, nf, field_align_req);
        }
        nf = nf + 1;
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_SEMICOLON || kind == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
        } else {
          if (kind == TOKEN_RBRACE) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            fields_done = 1;
          } else {
            if (parser_asm_struct_field_continues_tok_kind_c(kind) != 0) {
              fields_done = 0;
            } else {
              return -1;
            }
          }
        }
      }
    }
    pipeline_module_struct_layout_set_num_fields(module, layout_idx, nf);
    pipeline_module_struct_layout_set_allow_padding(module, layout_idx, allow_pad);
    pipeline_module_struct_layout_set_soa(module, layout_idx, is_soa);
    pipeline_module_struct_layout_set_packed(module, layout_idx, is_packed);
    pipeline_module_struct_layout_set_repr_compatible(module, layout_idx, repr_compat);
  }
  return 0;
}

/**
 * Allocate EXPR_LIT with int_val. Matches the C twin net effect:
 * common_zeros wipes resolved_type_ref after the C twin wrote type_ref,
 * so the stored expr has kind=LIT, int_val=v, resolved_type_ref=0.
 * The decl type lives on pipeline_block_append_const/let, not on the lit.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param int_val i32 — literal payload (i32 coerces to the i64 setter)
 * @return i32 — expr ref, or 0 on alloc failure
 * PLATFORM: SHARED — product P6f B-minus.
 */
function parser_asm_block_lit_init_ref_x(arena: *u8, int_val: i32): i32 {
  let ref: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  // PLATFORM: SHARED — asm typeck requires unsafe around export-extern
  // calls (`-E` is looser). Match glue.x / unary wrap (M2 class A).
  unsafe {
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      return 0;
    }
    pipeline_expr_set_common_zeros_c(arena, ref);
    pipeline_expr_set_kind(arena, ref, 0);
    pipeline_expr_set_int_val(arena, ref, int_val);
  }
  return ref;
}

/**
 * Copy one OneFunc const sidecar entry onto the block.
 * init_ref==0 synthesizes EXPR_LIT from const_init_val (C twin).
 * @param arena *u8 — opaque AST arena
 * @param block_ref i32 — dest block
 * @param pool *u8 — OneFunc sidecar pool (C trampoline extracted)
 * @param src_i i32 — const index
 * @param type_ref i32 — fallback decl type when sidecar type is 0
 * @param name_scratch *u8 — C-owned name[256]
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6f B-minus.
 */
function parser_asm_block_append_one_const_x(arena: *u8, block_ref: i32, pool: *u8, src_i: i32, type_ref: i32, name_scratch: *u8): i32 {
  let const_decl_ty: i32 = 0;
  let cinit_ref: i32 = 0;
  let nlen: i32 = 0;
  let sc_ty: i32 = 0;
  if (arena == 0 as *u8 || pool == 0 as *u8 || name_scratch == 0 as *u8) {
    return 0;
  }
  // PLATFORM: SHARED — M2 class A: sidecar / block writers are export-extern.
  unsafe {
    const_decl_ty = type_ref;
    sc_ty = pipeline_onefunc_const_type_ref(pool, src_i);
    if (sc_ty != 0) {
      const_decl_ty = sc_ty;
    }
    cinit_ref = pipeline_onefunc_const_init_ref(pool, src_i);
    if (cinit_ref == 0) {
      cinit_ref = parser_asm_block_lit_init_ref_x(arena, pipeline_onefunc_const_init_val(pool, src_i));
      if (cinit_ref == 0) {
        return 0;
      }
    }
    nlen = pipeline_onefunc_const_name_len(pool, src_i);
    pipeline_onefunc_const_name_copy64(pool, src_i, name_scratch);
    if (pipeline_block_append_const(arena, block_ref, name_scratch, nlen, const_decl_ty, cinit_ref) < 0) {
      return 0;
    }
  }
  return 1;
}

/**
 * Copy one OneFunc let sidecar entry onto the block.
 * init_ref==-1: no initializer (do not synthesize LIT 0).
 * init_ref==0: synthesize EXPR_LIT from let_init_val (C twin).
 * @param arena *u8 — opaque AST arena
 * @param block_ref i32 — dest block
 * @param pool *u8 — OneFunc sidecar pool
 * @param src_i i32 — let index
 * @param type_ref i32 — fallback decl type when sidecar type is 0
 * @param name_scratch *u8 — C-owned name[256]
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6f B-minus.
 */
function parser_asm_block_append_one_let_x(arena: *u8, block_ref: i32, pool: *u8, src_i: i32, type_ref: i32, name_scratch: *u8): i32 {
  let let_decl_ty: i32 = 0;
  let init_ref: i32 = 0;
  let nlen: i32 = 0;
  let sc_ty: i32 = 0;
  if (arena == 0 as *u8 || pool == 0 as *u8 || name_scratch == 0 as *u8) {
    return 0;
  }
  // PLATFORM: SHARED — M2 class A: sidecar / block writers are export-extern.
  unsafe {
    let_decl_ty = type_ref;
    sc_ty = pipeline_onefunc_let_type_ref(pool, src_i);
    if (sc_ty != 0) {
      let_decl_ty = sc_ty;
    }
    init_ref = pipeline_onefunc_let_init_ref(pool, src_i);
    if (init_ref == -1) {
      init_ref = 0;
    } else {
      if (init_ref == 0) {
        init_ref = parser_asm_block_lit_init_ref_x(arena, pipeline_onefunc_let_init_val(pool, src_i));
        if (init_ref == 0) {
          return 0;
        }
      }
    }
    nlen = pipeline_onefunc_let_name_len(pool, src_i);
    pipeline_onefunc_let_name_copy64(pool, src_i, name_scratch);
    if (pipeline_block_append_let(arena, block_ref, name_scratch, nlen, let_decl_ty, init_ref) < 0) {
      return 0;
    }
  }
  return 1;
}

/**
 * Fill block const/let decls from a OneFunc sidecar pool (all consts,
 * then all lets). C trampoline extracts the pool from onefunc_result
 * and writes res->num_consts / num_lets after success.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param block_ref i32 — dest block
 * @param pool *u8 — OneFunc sidecar pool pointer
 * @param type_ref i32 — fallback decl type
 * @param name_scratch *u8 — C-owned name[256]
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6f B-minus. Do not dest-buffer
 * parse_one_function. Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_fill_block_const_let_from_res_x_into_c(arena: *u8, block_ref: i32, pool: *u8, type_ref: i32, name_scratch: *u8): i32 {
  let const_i: i32 = 0;
  let nc: i32 = 0;
  let let_i: i32 = 0;
  let nl: i32 = 0;
  if (arena == 0 as *u8 || pool == 0 as *u8 || name_scratch == 0 as *u8) {
    return 0;
  }
  // PLATFORM: SHARED — M2 class A: num_consts/num_lets are export-extern.
  unsafe {
    nc = pipeline_onefunc_num_consts(pool);
    while (const_i < nc) {
      if (parser_asm_block_append_one_const_x(arena, block_ref, pool, const_i, type_ref, name_scratch) == 0) {
        return 0;
      }
      const_i = const_i + 1;
    }
    nl = pipeline_onefunc_num_lets(pool);
    while (let_i < nl) {
      if (parser_asm_block_append_one_let_x(arena, block_ref, pool, let_i, type_ref, name_scratch) == 0) {
        return 0;
      }
      let_i = let_i + 1;
    }
  }
  return 1;
}

/**
 * Append res consts (always from 0) then lets from let_base onto the
 * block. Mid-body TOKEN_CONST reuses this face. C trampoline extracts
 * the pool and writes res->num_consts / num_lets after success.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param block_ref i32 — dest block
 * @param pool *u8 — OneFunc sidecar pool pointer
 * @param let_base i32 — first let index to copy (consts always from 0)
 * @param type_ref i32 — fallback decl type
 * @param name_scratch *u8 — C-owned name[256]
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6f B-minus.
 */
#[no_mangle]
export function parser_asm_append_block_lets_from_res_x_into_c(arena: *u8, block_ref: i32, pool: *u8, let_base: i32, type_ref: i32, name_scratch: *u8): i32 {
  let src_i: i32 = 0;
  let nc: i32 = 0;
  let nl: i32 = 0;
  if (arena == 0 as *u8 || pool == 0 as *u8 || name_scratch == 0 as *u8) {
    return 0;
  }
  // PLATFORM: SHARED — M2 class A: num_consts/num_lets are export-extern.
  unsafe {
    nc = pipeline_onefunc_num_consts(pool);
    while (src_i < nc) {
      if (parser_asm_block_append_one_const_x(arena, block_ref, pool, src_i, type_ref, name_scratch) == 0) {
        return 0;
      }
      src_i = src_i + 1;
    }
    src_i = let_base;
    nl = pipeline_onefunc_num_lets(pool);
    while (src_i < nl) {
      if (parser_asm_block_append_one_let_x(arena, block_ref, pool, src_i, type_ref, name_scratch) == 0) {
        return 0;
      }
      src_i = src_i + 1;
    }
  }
  return 1;
}

/**
 * Allocate a Block and install the library-shape labeled return of
 * `eq_ref`. Writer = existing pipeline_parser_library_init_labeled_block_c
 * (G.7; zeros, append labeled, zeros expr/final/order). Do not copy
 * Block by-value get/set. Do not FORCE pabi mega.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param eq_ref i32 — EQ expr ref from P6d wrap; <=0 → 0
 * @return i32 — new block_ref, or 0 on null/alloc/init fail
 * PLATFORM: SHARED — product P6g helper.
 */
function parser_asm_library_init_block_x(arena: *u8, eq_ref: i32): i32 {
  let block_ref: i32 = 0;
  let rc: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  if (eq_ref <= 0) {
    return 0;
  }
  unsafe {
    block_ref = ast_ast_arena_block_alloc(arena);
    if (block_ref == 0) {
      return 0;
    }
    rc = pipeline_parser_library_init_labeled_block_c(arena, block_ref, eq_ref);
  }
  if (rc != 0) {
    return 0;
  }
  return block_ref;
}

/**
 * If the library param type has a field and that type name is not yet
 * a struct layout, allocate one slot and write a single field (type_ref
 * 0, offset 0) — same as the C twin. Layout alloc failure is ignored
 * (C twin does not fail-close).
 * @param module *u8 — opaque ast_Module; null → 0
 * @param type_name *u8 — param type IDENT bytes; null → 0
 * @param tnlen i32 — param type name length
 * @param field_name *u8 — field IDENT bytes; null → 0
 * @param flen i32 — field name length; <=0 skips the layout
 * @return i32 — 1 ok (including skipped), 0 on null
 * PLATFORM: SHARED — product P6g helper. Name-match stays P6b.
 */
function parser_asm_library_maybe_layout_x(module: *u8, type_name: *u8, tnlen: i32, field_name: *u8, flen: i32): i32 {
  let idx: i32 = 0;
  let exists: i32 = 0;
  if (module == 0 as *u8 || type_name == 0 as *u8 || field_name == 0 as *u8) {
    return 0;
  }
  if (flen <= 0) {
    return 1;
  }
  exists = parser_asm_struct_layout_name_exists_arr_c(module, type_name, tnlen);
  if (exists != 0) {
    return 1;
  }
  unsafe {
    idx = pipeline_module_struct_layout_alloc(module);
    if (idx >= 0) {
      pipeline_module_struct_layout_set_name(module, idx, type_name, tnlen);
      pipeline_module_struct_layout_set_num_fields(module, idx, 1);
      pipeline_module_struct_layout_set_field(module, idx, 0, field_name, flen, 0, 0);
    }
  }
  return 1;
}

/**
 * Register the library-shape function: one param, bool return, body =
 * `block_ref`, is_extern=0. Writers = existing pipeline_module_func_*
 * (G.7). Do not copy skip_tl extern-add (that path sets is_extern=1
 * and body=0).
 * @param module *u8 — opaque ast_Module; null → 0
 * @param name *u8 — func IDENT bytes; null → 0
 * @param nlen i32 — func name length (scan already capped 1..255)
 * @param pname *u8 — param IDENT bytes; null → 0
 * @param pnlen i32 — param name length
 * @param token_ty i32 — TYPE_NAMED param type ref
 * @param bool_ty i32 — TYPE_BOOL return type ref
 * @param block_ref i32 — labeled-return block
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6g helper.
 */
function parser_asm_library_register_x(module: *u8, name: *u8, nlen: i32, pname: *u8, pnlen: i32, token_ty: i32, bool_ty: i32, block_ref: i32): i32 {
  let fi: i32 = 0;
  if (module == 0 as *u8 || name == 0 as *u8 || pname == 0 as *u8) {
    return 0;
  }
  if (block_ref <= 0) {
    return 0;
  }
  unsafe {
    fi = pipeline_module_func_alloc_slot(module);
    if (fi < 0) {
      return 0;
    }
    pipeline_module_func_name_write(module, fi, name, nlen);
    pipeline_module_func_set_num_params(module, fi, 1);
    pipeline_module_func_param_write(module, fi, 0, pname, pnlen, token_ty);
    pipeline_module_func_set_return_type(module, fi, bool_ty);
    pipeline_module_func_set_body_ref(module, fi, block_ref);
    pipeline_module_func_set_body_expr_ref(module, fi, 0);
    pipeline_module_func_set_is_extern(module, fi, 0);
  }
  return 1;
}

/**
 * Finish parse_one_function_library after P6d wrap: labeled block,
 * optional struct-layout slot, module func slot. C trampoline holds
 * the scan buffers and writes the by-value result.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param module *u8 — opaque ast_Module; null → 0
 * @param eq_ref i32 — EQ expr ref from wrap
 * @param bool_ty i32 — TYPE_BOOL return type ref
 * @param token_ty i32 — TYPE_NAMED param type ref
 * @param name *u8 — func IDENT bytes; null → 0
 * @param nlen i32 — func name length
 * @param pname *u8 — param IDENT bytes; null → 0
 * @param pnlen i32 — param name length
 * @param tname *u8 — param type IDENT bytes; null → 0
 * @param tnlen i32 — param type name length
 * @param fname *u8 — field IDENT bytes; null → 0
 * @param flen i32 — field name length
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6g B-minus. Published face stays
 * slice_c. Do not dest-buffer scan. Do not dest-buffer wrap.
 */
#[no_mangle]
export function parser_asm_parse_one_function_library_finish_x_into_c(arena: *u8, module: *u8, eq_ref: i32, bool_ty: i32, token_ty: i32, name: *u8, nlen: i32, pname: *u8, pnlen: i32, tname: *u8, tnlen: i32, fname: *u8, flen: i32): i32 {
  let block_ref: i32 = 0;
  if (arena == 0 as *u8 || module == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8 || pname == 0 as *u8 || tname == 0 as *u8 || fname == 0 as *u8) {
    return 0;
  }
  if (eq_ref <= 0) {
    return 0;
  }
  if (bool_ty <= 0) {
    return 0;
  }
  if (token_ty <= 0) {
    return 0;
  }
  block_ref = parser_asm_library_init_block_x(arena, eq_ref);
  if (block_ref == 0) {
    return 0;
  }
  if (parser_asm_library_maybe_layout_x(module, tname, tnlen, fname, flen) == 0) {
    return 0;
  }
  if (parser_asm_library_register_x(module, name, nlen, pname, pnlen, token_ty, bool_ty, block_ref) == 0) {
    return 0;
  }
  return 1;
}

/**
 * Return-type token allowed on the buf path: scalar / void / IDENT.
 * Twin of parser_asm_onefunc_buf_return_type_ok_c. Unknown kinds fail
 * closed (caller then set_onefunc_fail).
 * @param kind i32 — lexer token kind
 * @return i32 — 1 allowed, 0 otherwise
 * PLATFORM: SHARED — product P6h helper.
 */
function parser_asm_onefunc_buf_return_type_ok_x(kind: i32): i32 {
  if (kind == TOKEN_I32) {
    return 1;
  }
  if (kind == TOKEN_I64) {
    return 1;
  }
  if (kind == TOKEN_BOOL) {
    return 1;
  }
  if (kind == TOKEN_VOID) {
    return 1;
  }
  if (kind == TOKEN_U8) {
    return 1;
  }
  if (kind == TOKEN_U32) {
    return 1;
  }
  if (kind == TOKEN_U64) {
    return 1;
  }
  if (kind == TOKEN_USIZE) {
    return 1;
  }
  if (kind == TOKEN_IDENT) {
    return 1;
  }
  return 0;
}

/**
 * Write binding name `self` (4 bytes + NUL) into a C-owned 256-byte row.
 * Twin of the TOKEN_SELF arm in parse_one_function_buf (ident_len=0).
 * @param buf *u8 — dest row; null → 0
 * @return i32 — 4 on success, 0 on null
 * PLATFORM: SHARED — product P6h helper.
 */
function parser_asm_onefunc_buf_fill_self_name_x(buf: *u8): i32 {
  if (buf == 0 as *u8) {
    return 0;
  }
  unsafe {
    buf[0] = 115 as u8;
    buf[1] = 101 as u8;
    buf[2] = 108 as u8;
    buf[3] = 102 as u8;
    buf[4] = 0 as u8;
  }
  return 4;
}

/**
 * True when `buf[0..4)` is the lowercase binding `self`.
 * @param buf *u8 — name bytes; null → 0
 * @param nlen i32 — name length
 * @return i32 — 1 match, 0 otherwise
 * PLATFORM: SHARED — product P6h helper.
 */
function parser_asm_onefunc_buf_is_self_name_x(buf: *u8, nlen: i32): i32 {
  if (buf == 0 as *u8) {
    return 0;
  }
  if (nlen != 4) {
    return 0;
  }
  unsafe {
    if (buf[0] != 115 as u8) {
      return 0;
    }
    if (buf[1] != 101 as u8) {
      return 0;
    }
    if (buf[2] != 108 as u8) {
      return 0;
    }
    if (buf[3] != 102 as u8) {
      return 0;
    }
  }
  return 1;
}

/**
 * Parse one buf-path formal from the unconsumed peek.
 * IDENT / TOKEN_SELF name, optional `: Type` (bare `self` only inside
 * the trait-default hoist window). Writes num_params as pidx+1.
 * @param arena *u8 — AST arena
 * @param lex_inout *u8 — cursor; parked after this param
 * @param source *u8 — opaque slice
 * @param pool *u8 — OneFunc sidecar
 * @param pname_buf *u8 — C-owned 256-byte name row
 * @param num_params *i32 — in/out param count
 * @return i32 — 1 more params, 2 done (RPAREN consumed), 0 fail
 * PLATFORM: SHARED — product P6h helper. type_ref = primary ptr shim.
 */
function parser_asm_onefunc_buf_parse_one_param_x(arena: *u8, lex_inout: *u8, source: *u8, pool: *u8, pname_buf: *u8, num_params: *i32): i32 {
  let kind: i32 = 0;
  let plen: i32 = 0;
  let pidx: i32 = 0;
  let ty: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let ts: usize = 0 as usize;
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || pool == 0 as *u8 || pname_buf == 0 as *u8 || num_params == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      if (kind != TOKEN_SELF) {
        parser_report_keyword_binding_p014_c(tl, tc);
        return 0;
      }
    }
    if (kind == TOKEN_SELF) {
      plen = parser_asm_onefunc_buf_fill_self_name_x(pname_buf);
    } else {
      plen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (plen <= 0 || plen > 255) {
        return 0;
      }
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      if (ts == 0 as usize) {
        ts = parser_asm_lex_pos_c(lex_inout);
      }
      data = parser_asm_lex_source_data_c(source);
      slen = parser_asm_lex_source_length_c(source) as i32;
      parser_asm_copy_slice_to_param32_buf_c(data, slen, ts, plen, pname_buf);
    }
    if (parser_onefunc_param_name_dup_c(pool, num_params[0], pname_buf, plen) != 0) {
      parser_report_duplicate_name_p012_c(tl, tc, 0);
      return 0;
    }
    pidx = pipeline_onefunc_append_param(pool, pname_buf, plen, 0);
    if (pidx < 0) {
      return 0;
    }
    num_params[0] = pidx + 1;
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      if (parser_asm_onefunc_buf_is_self_name_x(pname_buf, plen) != 0) {
        if (parser_allow_bare_self_pending_c() != 0) {
          if (kind == TOKEN_RPAREN || kind == TOKEN_COMMA) {
            pipeline_onefunc_set_param_type_ref(pool, pidx, 0);
            if (kind == TOKEN_RPAREN) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              return 2;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
            kind = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (kind == TOKEN_RPAREN) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              return 2;
            }
            return 1;
          }
        }
      }
      parser_report_untyped_formal_p011_c(tl, tc, 0);
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ty = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (ty == 0) {
      return 0;
    }
    pipeline_onefunc_set_param_type_ref(pool, pidx, ty);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 2;
    }
    if (kind != TOKEN_COMMA) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 2;
    }
  }
  return 1;
}

/**
 * Parse the buf-path header after the function name: `(params): Ret {`.
 * Entry is the unconsumed `(` (C trampoline already copied the name
 * and ran AUDIT). Success parks the cursor after `{` and writes
 * num_params / func_return_type_ref.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — cursor; parked after `{`
 * @param source *u8 — opaque slice
 * @param pool *u8 — OneFunc sidecar (`out` address)
 * @param pname_buf *u8 — C-owned 256-byte param-name row
 * @param out_num_params *i32 — dest num_params
 * @param out_ret_ty *i32 — dest func_return_type_ref
 * @return i32 — 1 ok, 0 fail
 * PLATFORM: SHARED — product P6h B-minus. Body loop stays C.
 */
#[no_mangle]
export function parser_asm_parse_one_function_buf_header_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, pool: *u8, pname_buf: *u8, out_num_params: *i32, out_ret_ty: *i32): i32 {
  let kind: i32 = 0;
  let ret_ty: i32 = 0;
  let rc: i32 = 0;
  let params_done: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || pool == 0 as *u8 || pname_buf == 0 as *u8 || out_num_params == 0 as *i32 || out_ret_ty == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_num_params[0] = 0;
    out_ret_ty[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      params_done = 1;
    }
    while (params_done == 0) {
      rc = parser_asm_onefunc_buf_parse_one_param_x(arena, lex_inout, source, pool, pname_buf, out_num_params);
      if (rc == 0) {
        return 0;
      }
      if (rc == 2) {
        params_done = 1;
      }
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      parser_report_untyped_formal_p011_c(tl, tc, 1);
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (parser_asm_onefunc_buf_return_type_ok_x(kind) == 0) {
      return 0;
    }
    ret_ty = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (ret_ty == 0) {
      return 0;
    }
    out_ret_ty[0] = ret_ty;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}
