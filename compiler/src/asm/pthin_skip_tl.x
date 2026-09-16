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
// 7.2.1 P12i B-minus (2026-09-15): 有则补全 skip_name_is_self +
// skip_impl_self_matches_for dest-buffer. Both were always-host-cc
// statics in skip_tl.inc (not behind BODIES). ABI is already
// pointer-legal (opaque arena + name bytes). Language has no local
// u8[N]; the C trampoline holds gnm[64] (same dest cap as the C
// twin). Sidecar authority stays pipeline_type_kind_ord_at /
// elem_ref_at / named_name_into. concrete_implements_trait stays C
// (file-local impl-seen tables). Do not copy this match into typeck
// (typeck already calls concrete_implements_trait). Do not merge
// with P6b layout name-match. Do not copy skip_name_is_self into
// P4b. Do not open a new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P12j B-minus (2026-09-15): 有则补全 named_eq_self +
// rewrite_self dest-buffer. Both were always-host-cc statics in
// skip_tl.inc (not behind BODIES). named_eq_self is already pointer
// ABI (name bytes). rewrite_self needs local u8[N]; the C trampoline
// holds gnm[64] + for_copy[64]. Sidecar authority stays
// pipeline_type_* (including existing find_or_alloc_named /
// find_or_alloc_compound — do not FORCE pabi mega). Seed
// seed_parse_into_buf twins stay C this wave. Do not copy into
// typeck. Do not merge with P6b. Do not merge with
// concrete_implements_trait. Do not open a new P-lane.
//
// 7.2.1 P12k B-minus (2026-09-15): 有则补全 register_type_params +
// type_param_index dest-buffer. Both were always-host-cc (not behind
// BODIES). Language has no file-local statics; the C trampoline
// passes the existing g_fn_gp_* tables as flat dest (same layout as
// P12d scan: fname stride 64 / names 32x4x64 / args cap 4).
// register_pending stays C (reads g_gp_pending_* then calls this).
// method_on_param stays C (fat trait-reg). bound_check is P12o.
// Do not merge with P1c pending tables. Do not open a
// new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P12l B-minus (2026-09-15): 有则补全 concrete_implements_trait
// dest-buffer. Always-host-cc (not behind BODIES). Language has no
// file-local statics; the C trampoline passes g_xlang_skip_impl_*
// parallel arrays (trait stride 64, for-name stride 64, cap 16) and
// holds gnm[64] for the P12i self_matches_for dest. Reuses
// skip_named_bytes_eq + xlang_skip_impl_self_matches_for_into_c.
// Accessors (seen_count / trait_name_into / for_type_into) are P12n.
// method_on_param stays C (fat trait-reg struct). bound_check is P12o.
// Do not copy into typeck. Do not merge with P6b. Do not merge with
// trait-reg accessors. Do not open a new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P12m B-minus (2026-09-15): 有则补全 bound_check_type_args
// dest-buffer. Always-host-cc (not behind BODIES). Walks parallel
// g_fn_bound_* + g_xlang_skip_impl_* arrays (NOT the fat trait-reg
// struct). Language has no file-local statics / no printf varargs;
// the C trampoline passes those tables and the two diag helpers
// format lsp_diag_report_typeck. bound_check_c is P12o (thin
// iterator over g_call_*). method_on_param stays C (fat trait-reg).
// Accessors are P12n. Do not copy into typeck (typeck already calls
// the historical _c). Do not wrap method_on_param. Do not open a
// new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P12n B-minus (2026-09-15): 有则补全 F4 impl-seen accessors
// dest-buffer (seen_count / trait_name_into / for_type_into). Always
// host-cc (not behind BODIES). Same parallel g_xlang_skip_impl_*
// tables as P12l (trait stride 64 / for-name stride 64 / cap 16);
// for_type also reads for_kinds / for_is_ptr. Language has no
// file-local statics; the C trampoline passes those tables.
// Historical public names stay (`_c` / already-`_into_c`); dest
// bodies are `_into_c` / `_dest_into_c` so they do not collide.
// method_on_param stays C (fat trait-reg). F3 accessors stay C.
// bound_check_c is P12o. Do not merge with concrete_implements.
// Do not copy into typeck / codegen (they already call `_c`).
// Do not wrap method_on_param. Do not open a new P-lane.
// Do not FORCE pabi mega.
//
// 7.2.1 P12o B-minus (2026-09-15): 有则补全 bound_check_c dest-buffer.
// Always host-cc (not behind BODIES). Thin iterator over the
// parallel g_call_* tables P12d scan already writes (callee stride
// 64 / typeargs 32x4x64 / args cap 4 / call cap 32). Each site
// delegates to the historical public
// xlang_generic_bound_check_type_args_c (P12m trampoline injects
// g_fn_bound_* + g_xlang_skip_impl_*). Language has no file-local
// statics; the C trampoline passes g_call_*. method_on_param stays
// C (fat trait-reg). F3 scalar getters stay C. Do not merge with
// bound_check_type_args (iterator vs per-site). Do not copy into
// typeck (typeck already calls type_args `_c`). Do not wrap
// method_on_param. Do not open a new P-lane. Do not FORCE pabi mega.
//
// 7.2.1 P12p B-minus (2026-09-15): 有则补全 F3 lookup-core dest-buffer
// (find_reg / method_count / method_slot / method_name). Always
// host-cc (not behind BODIES). Fat trait-reg is one
// xlang_skip_trait_reg_ent_t[] (sizeof 46792, cap 16); names live
// inside the struct, so dest is the C table as *u8 + stride + n.
// Field offsets reuse the P12g pins (C layout is authority).
// is_registered stays a C thin wrapper over find_reg (already G.7).
// Simple F3 scalar getters are P12q. dest-extras elem_array_dim
// are P12r. method_on_param stays C. Do not wrap method_on_param.
// Do not copy into typeck / codegen (they already call historical
// `_c`). Do not open a new P-lane. Do not FORCE pabi mega. Do not
// reuse skip_copy_row64 (F3 name copy rejects nlen>64; F4 returns
// stored nlen).
//
// 7.2.1 P12q B-minus (2026-09-15): 有则补全 F3 simple scalar getters
// dest-buffer (slot i32 / param i32 / simple ret+param dims /
// ret+param name copy). Always host-cc (not behind BODIES). Same
// fat table as P12p; C trampoline passes *u8 + sizeof stride + n
// plus offsetof for the slot/param i32 family (one .x body per
// access shape, not 15 copies). dest-extras
// ret_elem_array_dim / param_elem_array_dim are P12r. is_registered
// stays a C thin wrapper. method_on_param stays C. Do not wrap
// method_on_param. Do not copy into typeck / codegen. Do not open
// a new P-lane. Do not FORCE pabi mega. Do not reuse
// skip_copy_row64 for F3 name copy.
//
// 7.2.1 P12r B-minus (2026-09-15): 有则补全 F3 dest-extras
// elem_array_dim dest-buffer (ret_elem_array_dim /
// param_elem_array_dim). Always host-cc (not behind BODIES). Same
// fat table as P12p/P12q; wrap soup lives in one helper
// (ndims==-2 / ndims==0 unused slots / dim_ix>=ndims extra wrap).
// C trampoline passes *u8 + sizeof stride + n. is_registered stays
// a C thin wrapper. method_on_param is P12s. Do not copy into
// typeck / codegen. Do not open a new P-lane. Do not FORCE pabi
// mega. Do not merge with simple ret/param array_dim (those
// reject dim_ix>=ndims).
//
// 7.2.1 P12s B-minus (2026-09-15): 有则补全 method_on_param
// dest-buffer. Always host-cc (not behind BODIES). Walks dest
// g_fn_bound_* (stride 64, cap 16) then the fat trait-reg image
// (same table as P12p/P12q/P12r). type_param_index is the P12k
// historical `_c` trampoline (injects g_fn_gp_*). Method walk
// stays here (arity `continue` is not method_slot first-match).
// is_registered stays a C thin wrapper. register_pending stays C.
// Do not copy into typeck / codegen (they already call historical
// `_c`). Do not merge with bound_check_type_args (impl check vs
// method grant). Do not merge with F3 lookup (name→slot vs bound
// grant). Do not reuse skip_copy_row64 / ret_name_dest (this
// fill memset-64 + cap 63). Do not open a new P-lane. Do not
// FORCE pabi mega.
//
// 7.2.1 P12t B-minus (2026-09-15): 有则补全 skip_hoist_default_methods
// dest-buffer. Always host-cc (not behind BODIES). Walks dest
// g_xlang_skip_impl_* (stride 64, cap 16) then the fat trait-reg
// image (same table as P12p–P12s). Parse+commit of a default body
// stays C (`xlang_skip_hoist_inject_one_c` holds onefunc_result by
// value). self_matches_for is the P12i dest-buffer (C trampoline
// holds gnm[64]). trait_check_impls_complete outer walk is P12u.
// register_pending stays C. Do not copy into typeck / codegen. Do
// not merge with method_on_param (grant vs hoist inject). Do not
// merge with F3 lookup (name→slot vs default inject). Do not wrap
// trait_check as an extra of hoist. Do not open a new P-lane. Do
// not FORCE pabi mega.
//
// 7.2.1 P12u B-minus (2026-09-15): 有则补全 trait_check_impls_complete
// dest-buffer of the missing-method / arity / find-func outer walk.
// Always host-cc (not behind BODIES). Walks dest g_xlang_skip_impl_*
// (stride 64, cap 16) then the fat trait-reg image (same table as
// P12p–P12t). dest-SLICE param shape is P12v (SHAPE define);
// ret_shape is P12v (same SHAPE); varargs diags stay C. Hoist stays the P12t
// trampoline (C wrapper calls it first). bound_scan / bound_check
// stay the historical `_c` trampolines. find-func is not
// skip_hoist_method_exists (first-name fallback vs override skip).
// register_pending stays C. Do not copy into typeck / codegen. Do
// not merge with skip_hoist / method_on_param / F3 lookup. Do not
// open a new P-lane. Do not FORCE pabi mega.
//
// Hybrid P12b/P12c/P12d/P12e/P12f/P12h/P12i/P12j/P12k/P12l/P12m/P12n/P12o/P12p/P12q/P12r/P12s/P12t/P12u: g05_try_x_to_o this
// file; XLANG_PTHIN_SKIP_TL_BODIES_FROM_X skips the portable .inc
// region (struct/enum/extern + impl header + generic_bound_scan +
// enum_register + parse_one_extern_skip + parse_one_extern_and_add +
// skip_name_is_self + self_matches_for + named_eq_self +
// rewrite_self + register_type_params + type_param_index +
// concrete_implements_trait + bound_check_type_args +
// impl-seen accessors + bound_check + F3 lookup + F3 simple
// getters + dest-extras elem_array_dim + method_on_param +
// skip_hoist_default_methods + trait_check_impls_complete outer). Requires P9a
// bridge + P1b skip walks (otherwise skip_balanced / skip_generic_angle
// / copy_slice would UNDEF). token.h remains the TOKEN_* authority via
// P12 C _Static_assert pins. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_SKIP_TL_FROM_X for P12b–P12u bodies. P12g skip_one_trait
// ent-image stays PRESET (not linked).
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
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
/** P9a bridge: peek the NEXT token's int_val (array dims) without advancing. */
export extern "C" function parser_asm_lex_peek_int_val_c(lex_inout: *u8, source: *u8): i32;
/** P3b builtin TypeKind authority (token → builtin kind ord; -1 = not builtin). */
export extern "C" function parser_asm_type_ref_builtin_kind_ord_c(kind: i32): i32;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
/** P1b authority: copy IDENT bytes into a dest (nlen bytes; caller sizes it). */
export extern "C" function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P1b authority: 256-byte param/name row (zeros past nlen). */
export extern "C" function parser_asm_copy_slice_to_param32_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P12f: pointer-ABI wrap of parse_type_ref_for_arena (C still owns the walk). */
export extern "C" function parser_asm_skip_tl_parse_type_ref_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;
/** Pipeline onefunc pool: append a param name; type_ref filled later. */
/* P12h parse_one_extern_and_add orchestration bridges — all resolve from
 * seed C (diagnostics, module func row setters, arena copy, onefunc pool). */
export extern "C" function driver_diagnostic_parse_skip_function(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern "C" function pipeline_module_num_funcs(m: *u8): i32;
/** Sidecar: 1 if func `fi` name equals `nm[0..nlen)`. */
export extern "C" function pipeline_module_func_name_equal_at(m: *u8, fi: i32, nm: *u8, nlen: i32): i32;
/** Sidecar: param `pi` type_ref at func `fi`; 0 if missing. */
export extern "C" function pipeline_module_func_param_type_ref_at(m: *u8, fi: i32, pi: i32): i32;
/** Sidecar: param count at func `fi`. */
export extern "C" function pipeline_module_func_num_params_at(m: *u8, fi: i32): i32;
/**
 * P12t C helper: parse+commit one default-method body.
 * Language has no local onefunc_result; C holds it. Zero walk.
 */
export extern "C" function xlang_skip_hoist_inject_one_c(module: *u8, arena: *u8, src: *u8, src_len: i32, fn_pos: i32, fn_line: i32, fn_col: i32, for_nm: *u8, for_nl: i32, for_ptr: i32): i32;
/**
 * P12u C varargs: "impl for unknown trait %.*s". Reads g_xlang_skip_impl_*.
 * @param si i32 — impl-seen index
 * @return i32 — always -1
 */
export extern "C" function xlang_skip_trait_check_diag_unknown_c(si: i32): i32;
/**
 * P12u C varargs: "missing method %.*s".
 * @param si i32 — impl-seen index
 * @param mnm *u8 — method spelling
 * @param mlen i32 — byte count
 * @return i32 — always -1
 */
export extern "C" function xlang_skip_trait_check_diag_missing_c(si: i32, mnm: *u8, mlen: i32): i32;
/**
 * P12u C varargs: "method %.*s parameter count mismatch".
 * @param si i32 — impl-seen index
 * @param mnm *u8 — method spelling
 * @param mlen i32 — byte count
 * @return i32 — always -1
 */
export extern "C" function xlang_skip_trait_check_diag_param_count_c(si: i32, mnm: *u8, mlen: i32): i32;
export extern "C" function pipeline_type_array_size_at(arena: *u8, ref: i32): i32;
export extern "C" function xlang_skip_trait_check_diag_param_type_c(si: i32, mnm: *u8, mlen: i32): i32;
export extern "C" function xlang_skip_trait_check_diag_self_type_c(si: i32, mnm: *u8, mlen: i32): i32;
export extern "C" function xlang_skip_trait_check_diag_ret_type_c(si: i32, mnm: *u8, mlen: i32): i32;
export extern "C" function pipeline_module_func_return_type_at(module: *u8, fi: i32): i32;


/**
 * P12u C dest-SLICE param soup + self for-type match. Language-permanent.
 * @param module *u8 — opaque ast_Module
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param found_fi i32 — module func index; <0 → 0
 * @param si i32 — impl-seen index into file-local tables
 * @param ti i32 — fat-reg slot
 * @param mi i32 — method slot
 * @param mnm *u8 — method spelling
 * @param mlen i32 — byte count
 * @param expect_np i32 — trait param count; <0 → 0
 * @return i32 — -1 mismatch (diag emitted), 0 ok
 */
export extern "C" function xlang_skip_trait_check_param_shape_c(module: *u8, arena: *u8, found_fi: i32, si: i32, ti: i32, mi: i32, mnm: *u8, mlen: i32, expect_np: i32): i32;
/**
 * P12u C dest-SLICE ret soup. Language-permanent.
 * @param module *u8 — opaque ast_Module
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param found_fi i32 — module func index; <0 → 0
 * @param si i32 — impl-seen index
 * @param ti i32 — fat-reg slot
 * @param mi i32 — method slot
 * @param mnm *u8 — method spelling
 * @param mlen i32 — byte count
 * @return i32 — -1 mismatch (diag emitted), 0 ok / skipped
 */
export extern "C" function xlang_skip_trait_check_ret_shape_c(module: *u8, arena: *u8, found_fi: i32, si: i32, ti: i32, mi: i32, mnm: *u8, mlen: i32): i32;
/** P12d public trampoline: tokenize stashed source into g_fn_bound_* / g_call_*. */
export extern "C" function xlang_generic_bound_scan_c(data: *u8, len: i32): void;
/** P12o public trampoline: verify captured generic call sites against bounds. */
export extern "C" function xlang_generic_bound_check_c(): i32;
export extern "C" function ast_ast_arena_func_alloc(arena: *u8): i32;
export extern "C" function pipeline_module_func_alloc_slot(m: *u8): i32;
export extern "C" function pipeline_module_func_name_write(m: *u8, fi: i32, name: *u8, name_len: i32): void;
export extern "C" function pipeline_module_func_set_num_params(m: *u8, fi: i32, n: i32): void;
export extern "C" function pipeline_module_func_set_return_type(m: *u8, fi: i32, tr: i32): void;
export extern "C" function pipeline_module_func_set_body_ref(m: *u8, fi: i32, br: i32): void;
export extern "C" function pipeline_module_func_set_body_expr_ref(m: *u8, fi: i32, er: i32): void;
export extern "C" function pipeline_module_func_set_is_extern(m: *u8, fi: i32, v: i32): void;
export extern "C" function pipeline_module_func_set_is_async(m: *u8, fi: i32, v: i32): void;
export extern "C" function pipeline_module_func_set_abi_kind(m: *u8, fi: i32, abi_kind: i32): void;
export extern "C" function pipeline_module_func_set_is_variadic(m: *u8, fi: i32, v: i32): void;
export extern "C" function pipeline_module_func_ref_set(m: *u8, fi: i32, fr: i32): void;
export extern "C" function pipeline_arena_func_copy_slot_from_module(arena: *u8, func_ref: i32, m: *u8, fi: i32): void;
export extern "C" function pipeline_onefunc_param_name_copy32(pool: *u8, i: i32, out32: *u8): void;
export extern "C" function pipeline_onefunc_param_name_len(pool: *u8, i: i32): i32;
export extern "C" function pipeline_onefunc_param_type_ref(pool: *u8, i: i32): i32;
export extern "C" function pipeline_arena_func_param_write(arena: *u8, func_ref: i32, i: i32, name: *u8, name_len: i32, type_ref: i32): void;
export extern "C" function pipeline_module_func_param_write(m: *u8, fi: i32, i: i32, name: *u8, name_len: i32, type_ref: i32): void;
export extern "C" function pipeline_onefunc_append_param(pool: *u8, name: *u8, name_len: i32, type_ref: i32): i32;
/** Pipeline onefunc pool: write param i's type_ref. */
export extern "C" function pipeline_onefunc_set_param_type_ref(pool: *u8, i: i32, type_ref: i32): void;
/** P14 skip_if authority: register enum name on the opaque module; -1 on fail. */
export extern "C" function parser_asm_module_try_register_enum_name_c(module: *u8, name: *u8, name_len: i32): i32;
/** Pipeline sidecar: append one variant name to enum slot `idx`. */
export extern "C" function pipeline_module_enum_append_variant(module: *u8, idx: i32, bytes: *u8, len: i32): i32;
/** Sidecar: TypeKind ordinal at type_ref; -1 if the slot is missing. */
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
/** Sidecar: elem_type_ref at type_ref (PTR/ARRAY/SLICE); 0 if missing. */
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
/** Sidecar: copy TYPE_NAMED spelling into dest; return full name_len (may exceed dest cap). */
export extern "C" function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;
/** Sidecar: find or alloc TYPE_NAMED by spelling. Already in product; do not FORCE pabi mega. */
export extern "C" function pipeline_type_find_or_alloc_named(arena: *u8, name: *u8, name_len: i32): i32;
/** Sidecar: find or alloc compound (PTR/ARRAY/…) by kind+elem+size. Already in product. */
export extern "C" function pipeline_type_find_or_alloc_compound(arena: *u8, kind_ord: i32, elem_ref: i32, array_size: i32): i32;
/** P12k public trampoline: look up a type-param index on g_fn_gp_*. */
export extern "C" function xlang_generic_func_type_param_index_c(fn_name: *u8, fn_name_len: i32, tp_name: *u8, tp_name_len: i32): i32;
/** P12m C varargs trampoline: "generic function '%.*s' requires type arguments…". */
export extern "C" function xlang_generic_bound_diag_need_type_args_c(fn_name: *u8, fn_name_len: i32, line: i32, col: i32): void;
/** P12m C varargs trampoline: "generic bound not satisfied: %.*s does not impl %.*s". Returns 0. */
export extern "C" function xlang_generic_bound_diag_not_impl_c(ta: *u8, ta_len: i32, trait_nm: *u8, trait_nlen: i32, line: i32, col: i32): i32;
/** P12m public trampoline: per-site bound check (injects g_fn_bound_* + g_xlang_skip_impl_*). */
export extern "C" function xlang_generic_bound_check_type_args_c(fn_name: *u8, fn_name_len: i32, type_args: *u8, type_arg_lens: *i32, nargs: i32, line: i32, col: i32): i32;

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
// TypeKind pins ≡ XLANG_TRAIT_TY_* in skip_tl.inc / ast.x. P12 C
// _Static_assert fires if the pin drifts.
const TYPE_NAMED: i32 = 8;
const TYPE_PTR: i32 = 9;
const GNM_CAP: i32 = 64;
const SKIP_IMPL_SEEN_MAX: i32 = 16;
const SKIP_TRAIT_REG_MAX: i32 = 16;
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
 * Parse one top-level extern declaration AND register it (P12h).
 * Dest-buffer orchestration over the P12f skip: on a successful skip the
 * function is allocated a module row, filled through the scalar setters,
 * copied to the arena Func via copy_slot_from_module, and its params are
 * written into both pools. On any failure path (skip fail, missing return
 * type, alloc failure) this mirrors the C twin: emit the parse-skip
 * diagnostic and fall back to the in-place extern skip so the module
 * still parses.
 * @param lex_inout *u8 — cursor at the start of `extern`; advanced in
 *   place (next_lex semantics of the C twin's result struct)
 * @param source *u8 — opaque slice
 * @param arena *u8 — opaque ASTArena for the func row + type refs
 * @param module *u8 — opaque module receiving the registered function
 * @param pool *u8 — onefunc pool (the C extern_parse_result sidecar)
 * @param name_buf *u8 — trampoline-owned 64-byte function name dest
 * @param pname_buf *u8 — trampoline-owned 256-byte param-name scratch
 * @return void — failures are reported via diagnostics + fallback skip
 * PLATFORM: SHARED — product P12h B-minus; C trampoline keeps the
 * by-value face (parser_asm_parse_one_extern_and_add_into_slice_c).
 * Do not wrap skip_one_extern here (fallback uses the P12b lane body).
 */
#[no_mangle]
export function parser_asm_parse_one_extern_and_add_into_c(lex_inout: *u8, source: *u8, arena: *u8, module: *u8, pool: *u8, name_buf: *u8, pname_buf: *u8): void {
  let name_len: i32 = 0;
  let return_ty: i32 = 0;
  let num_params: i32 = 0;
  let abi_kind: i32 = 0;
  let is_variadic: i32 = 0;
  let has_body: i32 = 0;
  let rc: i32 = 0;
  let func_ref: i32 = 0;
  let fi: i32 = 0;
  let p: i32 = 0;
  let plen: i32 = 0;
  let pty: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || arena == 0 as *u8 || module == 0 as *u8 || pool == 0 as *u8 || name_buf == 0 as *u8 || pname_buf == 0 as *u8) {
    return;
  }
  unsafe {
    /* C twin fallback re-skips from the ORIGINAL lexer position; the
     * in-place skip walk advances lex_inout, so snapshot and restore. */
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    rc = parser_asm_parse_one_extern_skip_into_c(lex_inout, source, arena, pool, name_buf, pname_buf, &name_len, &return_ty, &num_params, &abi_kind, &is_variadic, &has_body);
    if (rc != 1 || name_len < 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      rc = parser_asm_skip_one_extern_into_c(lex_inout, source);
      return;
    }
    if (rc != 1 || name_len < 0) {
      rc = parser_asm_skip_one_extern_into_c(lex_inout, source);
      return;
    }
    if (return_ty == 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      driver_diagnostic_parse_skip_function(parser_asm_lex_pos_c(lex_inout) as i32, pipeline_module_num_funcs(module), name_len, name_buf);
      rc = parser_asm_skip_one_extern_into_c(lex_inout, source);
      return;
    }
    func_ref = ast_ast_arena_func_alloc(arena);
    if (func_ref == 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      driver_diagnostic_parse_skip_function(parser_asm_lex_pos_c(lex_inout) as i32, pipeline_module_num_funcs(module), name_len, name_buf);
      rc = parser_asm_skip_one_extern_into_c(lex_inout, source);
      return;
    }
    fi = pipeline_module_func_alloc_slot(module);
    if (fi < 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      driver_diagnostic_parse_skip_function(parser_asm_lex_pos_c(lex_inout) as i32, pipeline_module_num_funcs(module), name_len, name_buf);
      rc = parser_asm_skip_one_extern_into_c(lex_inout, source);
      return;
    }
    pipeline_module_func_name_write(module, fi, name_buf, name_len);
    pipeline_module_func_set_num_params(module, fi, num_params);
    pipeline_module_func_set_return_type(module, fi, return_ty);
    pipeline_module_func_set_body_ref(module, fi, 0);
    pipeline_module_func_set_body_expr_ref(module, fi, 0);
    /* Body-bearing extern parses the body via the caller: is_extern=0
     * (C twin's has_body rule); pure declaration keeps is_extern=1. */
    if (has_body == 1) {
      pipeline_module_func_set_is_extern(module, fi, 0);
    } else {
      pipeline_module_func_set_is_extern(module, fi, 1);
    }
    pipeline_module_func_set_is_async(module, fi, 0);
    pipeline_module_func_set_abi_kind(module, fi, abi_kind);
    pipeline_module_func_set_is_variadic(module, fi, is_variadic);
    pipeline_module_func_ref_set(module, fi, func_ref);
    pipeline_arena_func_copy_slot_from_module(arena, func_ref, module, fi);
    p = 0;
    while (p < num_params) {
      pipeline_onefunc_param_name_copy32(pool, p, pname_buf);
      plen = pipeline_onefunc_param_name_len(pool, p);
      pty = pipeline_onefunc_param_type_ref(pool, p);
      pipeline_arena_func_param_write(arena, func_ref, p, pname_buf, plen, pty);
      pipeline_module_func_param_write(module, fi, p, pname_buf, plen, pty);
      p = p + 1;
    }
  }
}

/**
 * g-1 preset: walk the `trait Name {` header and record the trait name into
 * the ent stack-image. Entry cursor at the `trait` keyword start. Returns 1
 * with the cursor after `{` on success; 0 (cursor restored to entry) when
 * 0 when the first token is not `trait` (cursor untouched), or -1 when the
 * trait keyword was consumed but the name is not IDENT (cursor after
 * `trait`) or `{` is absent (cursor after the name) — each fail leaves the
 * cursor at the last consumed token, the C twin's out = lex semantics,
 * which the g-3 trampoline materializes as *out. The distinct -1 keeps the
 * trampoline's 5-byte 't','r','a','i','t' raw fallback (C, byte path) from
 * firing on consumed-token fails.
 * @param lex_inout *u8 — opaque lexer cursor (fail = last consumed token)
 * @param source *u8 — opaque slice
 * @param ent_img *u8 — ent image (name/name_len written on the token path)
 * @return i32 — 1 header walked (cursor after `{`); 0 not-a-trait (cursor
 *   untouched); -1 trait keyword consumed but malformed
 * PLATFORM: SHARED — live via the g-3 C trampoline when
 * XLANG_PTHIN_SKIP_TL_BODIES_FROM_X is on; cold C twin otherwise.
 */
#[no_mangle]
export function parser_asm_skip_one_trait_header_into_c(lex_inout: *u8, source: *u8, ent_img: *u8): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let kind: i32 = 0;
  let nlen: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let slen_us: usize = 0;
  let k: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || ent_img == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source) as i32;
    slen_us = parser_asm_lex_source_length_c(source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  }
  if (kind != TOKEN_TRAIT) {
    return 0;
  }
  unsafe {
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0 - 1;
    }
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    if (ts == 0 as usize) {
      ts = pos0;
    }
    if (nlen > 64) {
      nlen = 64;
    }
    k = 0;
    while (k < 64) {
      ent_img[P12G_OFF_NAME + k] = 0;
      k = k + 1;
    }
    if (nlen > 0 && data != 0 as *u8) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, nlen, ent_img);
    }
    p12g_store_i32(ent_img, P12G_OFF_NAME_LEN, nlen);
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 0 - 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}


/** P12g g-2 extra pins: trait registry caps + TY kind row values (C _Static
 * pins: XLANG_SKIP_TRAIT_METH_MAX 32 / PARAM_MAX 8 / DIM_MAX 8; TY kinds
 * are TypeKind ordinals NAMED=8 PTR=9 ARRAY=10 SLICE=11). */
const P12G_METH_MAX: i32 = 32;
const P12G_PARAM_MAX: i32 = 8;
const P12G_DIM_MAX: i32 = 8;
const P12G_TY_NAMED: i32 = 8;
const P12G_TY_PTR: i32 = 9;
const P12G_TY_ARRAY: i32 = 10;
const P12G_TY_SLICE: i32 = 11;
/** Sentinel elem_array_ndims: extra SLICE wrap count lives in dims[0..]. */
const P12G_ELEM_PTR_TO_SLICE_NDIMS: i32 = 0 - 2;

/** P12g local: load i32 at base+off (LE; mirror of p12g_store_i32). */
function p12g_load_i32(base: *u8, off: i32): i32 {
  let a: usize = 0;
  unsafe {
    a = base[off + 0] as usize;
    a = a | ((base[off + 1] as usize) << 8);
    a = a | ((base[off + 2] as usize) << 16);
    a = a | ((base[off + 3] as usize) << 24);
  }
  return a as i32;
}

/**
 * g-2 preset: walk the trait body method loop — FUNCTION/IDENT discovery
 * with the full per-method ent registration (name row copy via the P1b
 * authority, fn_pos/line/col capture, all ret/param field defaults reset,
 * num_methods bump) — plus the wave421–438 signature state machine for
 * `( params ) : Ret ;` / default `{...}` bodies, writing param/ret kinds,
 * names, elem kinds, array sizes/dims into the ent image at the pinned
 * offsets. Success (RBRACE) leaves the cursor after `}`; the C twin's
 * `g_xlang_skip_trait_reg_n++` commit-on-success stays in the g-3
 * trampoline (an uncalled .x body cannot own the commit anyway).
 * Token-for-token faithful to the C twin incl. fail-leave (EOF/`}` mid
 * signature restores nothing — the C loop simply exits with out=lex).
 * Live via the g-3 C trampoline (the registry commit-on-success bump and
 * the raw byte fallback stay C — the registry global is .inc file-static).
 * @param lex_inout *u8 — cursor positioned AFTER the header `{`
 * @param source *u8 — opaque slice
 * @param ent_img *u8 — ent image (header name already written)
 * @return i32 — 1 walked to the closing `}` (cursor after it); 0 EOF hit
 *   (cursor left at the EOF-time lex; the trampoline decides out)
 * PLATFORM: SHARED — live via g-3 trampoline. This .x rides the -E
 * transpile lane (pure-asm banned: asm-emitter big-function call-arg slot
 * bug — see the P12g RFC).
 */
#[no_mangle]
export function parser_asm_skip_one_trait_body_into_c(lex_inout: *u8, source: *u8, ent_img: *u8): i32 {
  let kind: i32 = 0;
  let guard: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let num_methods: i32 = 0;
  let mi_reg: i32 = 0;
  let fn_pos: i32 = 0;
  let fn_line: i32 = 0;
  let fn_col: i32 = 0;
  let mlen: i32 = 0;
  let ts: usize = 0;
  let pii: i32 = 0;
  let k: i32 = 0;
  let nlen: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || ent_img == 0 as *u8) {
    return 0;
  }
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source) as i32;
    num_methods = p12g_load_i32(ent_img, P12G_OFF_NUM_METHODS);
  }
  guard = 0;
  while (guard < 512) {
    guard = guard + 1;
    unsafe {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind == TOKEN_RBRACE) {
      unsafe {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
      return 1;
    }
    if (kind == TOKEN_EOF) {
      return 0;
    }
    if (kind == TOKEN_FUNCTION) {
      mi_reg = -1;
      unsafe {
        fn_pos = parser_asm_lex_peek_token_start_c(lex_inout, source) as i32;
        fn_line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
        fn_col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_IDENT && num_methods < P12G_METH_MAX) {
          nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
          ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
          mi_reg = num_methods;
          if (nlen > 64) {
            nlen = 64;
          }
          k = 0;
          while (k < 64) {
            ent_img[P12G_OFF_METHODS + mi_reg * P12G_METHOD_NAME_ROW + k] = 0;
            k = k + 1;
          }
          if (nlen > 0 && data != 0 as *u8) {
            parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, nlen, ent_img + (((P12G_OFF_METHODS + mi_reg * P12G_METHOD_NAME_ROW)) as usize));
          }
          p12g_store_i32(ent_img, P12G_OFF_METHOD_LENS + mi_reg * 4, nlen);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_HAS_DEFAULT + mi_reg * 4, 0);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_FN_POS + mi_reg * 4, fn_pos);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_FN_LINE + mi_reg * 4, fn_line);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_FN_COL + mi_reg * 4, fn_col);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi_reg * 4, -1);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_NAME_LENS + mi_reg * 4, 0);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi_reg * 4, -1);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_SIZES + mi_reg * 4, -1);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_NDIMS + mi_reg * 4, 0);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi_reg * 4, 0);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi_reg * 4, -1);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_COUNTS + mi_reg * 4, -1);
          pii = 0;
          while (pii < P12G_PARAM_MAX) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi_reg * P12G_PARAM_KINDS_ROW + pii * 4, -1);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_NAME_LENS + mi_reg * P12G_PARAM_LENS_ROW + pii * 4, 0);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi_reg * P12G_PARAM_KINDS_ROW + pii * 4, -1);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi_reg * P12G_PARAM_LENS_ROW + pii * 4, 0);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi_reg * P12G_PARAM_LENS_ROW + pii * 4, 0);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi_reg * P12G_PARAM_KINDS_ROW + pii * 4, -1);
            pii = pii + 1;
          }
          mlen = nlen;
          if (mlen > 0) {
            num_methods = num_methods + 1;
            p12g_store_i32(ent_img, P12G_OFF_NUM_METHODS, num_methods);
          } else {
            mi_reg = -1;
          }
        }
      }
      if (mi_reg >= 0) {
        // Signature machine for this method: `( params ) : Ret ;` or `{...}`.
        unsafe {
          parser_asm_skip_one_trait_method_sig_into_c(lex_inout, source, ent_img, mi_reg);
        }
      } else {
        unsafe {
          parser_asm_lex_step_kind_c(lex_inout, source);
        }
      }
    } else {
      unsafe {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
    }
  }
  return 0;
}


/**
 * P12g local: copy the current IDENT bytes into ent method param name row
 * [mi][p] via the P1b copy authority, zero-padded to 64, and store the
 * length row. Mirrors xlang_skip_trait_copy_ident_c on the stack image.
 */
function p12g_param_copy_name(ent_img: *u8, mi: i32, p: i32, source: *u8, lex_inout: *u8): void {
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let ts: usize = 0;
  let n: i32 = 0;
  let base: i32 = 0;
  let k: i32 = 0;
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source) as i32;
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  }
  if (n > 64) {
    n = 64;
  }
  base = P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + p * P12G_PARAM_NAME_INNER;
  unsafe {
    while (k < 64) {
      ent_img[base + k] = 0;
      k = k + 1;
    }
    if (n > 0 && data != 0 as *u8) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, n, ent_img + (base as usize));
    }
    p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + p * 4, n);
  }
}

/**
 * P12g local: copy the current IDENT bytes into the ent method ret name row
 * [mi] via the P1b copy authority, zero-padded to 64, and store the length
 * row. Mirrors xlang_skip_trait_copy_ident_c on the stack image.
 */
function p12g_ret_copy_name(ent_img: *u8, mi: i32, source: *u8, lex_inout: *u8): void {
  let data: *u8 = 0 as *u8;
  let slen: i32 = 0;
  let ts: usize = 0;
  let n: i32 = 0;
  let base: i32 = 0;
  let k: i32 = 0;
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source) as i32;
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  }
  if (n > 64) {
    n = 64;
  }
  base = P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER;
  unsafe {
    while (k < 64) {
      ent_img[base + k] = 0;
      k = k + 1;
    }
    if (n > 0 && data != 0 as *u8) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, n, ent_img + (base as usize));
    }
    p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4, n);
  }
}

/**
 * g-2 preset: one method's `( params ) : Ret ;` / default-body signature
 * walk (waves 425–438 state machine). Faithful shape capture into the ent
 * image per method row mi: param kinds/names/elem/dims and ret kind/name/
 * elem/sizes/dims, has_default on `{`. Terminates on `;` (or the token
 * after a default body's matching `}`) leaving the cursor on the next
 * body token the outer loop peeks.
 * Live via the g-3 trampoline (called by the .x body walker per method).
 * @param lex_inout *u8 — cursor at the token after the method IDENT
 * @param source *u8 — opaque slice
 * @param ent_img *u8 — ent image
 * @param mi i32 — method row index (already registered)
 * @return void
 * PLATFORM: SHARED — live via g-3 trampoline.
 */
function parser_asm_skip_one_trait_method_sig_into_c(lex_inout: *u8, source: *u8, ent_img: *u8, mi: i32): void {
  let kind: i32 = 0;
  let steps: i32 = 0;
  let depth: i32 = 0;
  let paren: i32 = 0;
  let saw_params_close: i32 = 0;
  let want_ret: i32 = 0;
  let param_count: i32 = 0;
  let saw_param_tok: i32 = 0;
  let want_param_ty: i32 = 0;
  let param_slice_need_rb: i32 = 0;
  let param_prefix_arr_need_rb: i32 = 0;
  let param_prefix_arr_need_size: i32 = 0;
  let param_prefix_arr_elem_pending: i32 = 0;
  let param_suffix_pending: i32 = 0;
  let param_arr_need_size: i32 = 0;
  let param_arr_need_rb: i32 = 0;
  let param_dim_n: i32 = 0;
  let param_elem_pending: i32 = 0;
  let param_elem_slice_need_rb: i32 = 0;
  let param_elem_prefix_arr_need_rb: i32 = 0;
  let param_elem_prefix_arr_more: i32 = 0;
  let param_elem_arr_need_size: i32 = 0;
  let param_elem_arr_need_rb: i32 = 0;
  let param_elem_suffix_pending: i32 = 0;
  let param_elem_dim_n: i32 = 0;
  let param_elem_elem_pending: i32 = 0;
  let nd: i32 = 0;
  let extra: i32 = 0;
  let di: i32 = 0;
  let param_dims: i32[8] = [];
  let leaf: i32 = 0;
  let bk2: i32 = 0;
  let leaf2: i32 = 0;
  let b0: i32 = 0;
  let bk3: i32 = 0;
  let bk4: i32 = 0;
  let bk5: i32 = 0;
  let bk6: i32 = 0;
  let param_elem_dims: i32[8] = [];
  let ret_slice_need_rb: i32 = 0;
  let ret_prefix_arr_need_rb: i32 = 0;
  let ret_prefix_arr_need_size: i32 = 0;
  let ret_prefix_arr_elem_pending: i32 = 0;
  let ret_suffix_pending: i32 = 0;
  let ret_arr_need_size: i32 = 0;
  let ret_arr_need_rb: i32 = 0;
  let ret_dim_n: i32 = 0;
  let ret_elem_pending: i32 = 0;
  let ret_elem_slice_need_rb: i32 = 0;
  let ret_elem_prefix_arr_need_rb: i32 = 0;
  let ret_elem_prefix_arr_more: i32 = 0;
  let ret_elem_arr_need_size: i32 = 0;
  let ret_elem_arr_need_rb: i32 = 0;
  let ret_elem_suffix_pending: i32 = 0;
  let ret_elem_dim_n: i32 = 0;
  let ret_elem_elem_pending: i32 = 0;
  let ret_dims: i32[8] = [];
  let ret_elem_dims: i32[8] = [];
  let iv: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || ent_img == 0 as *u8) {
    return;
  }
  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_COUNTS + mi * 4, 0);
  steps = 0;
  while (steps < 4096) {
    steps = steps + 1;
    unsafe {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      iv = parser_asm_lex_peek_int_val_c(lex_inout, source);
    }
    if (kind == TOKEN_EOF) {
      return;
    }
    if (kind == TOKEN_LPAREN) {
      paren = paren + 1;
      if (paren == 1 && depth == 0 && saw_params_close == 0) {
        // opening the param list
      }
    } else if (kind == TOKEN_RPAREN) {
      if (paren == 1 && depth == 0 && saw_params_close == 0) {
        if (param_suffix_pending != 0 && param_dim_n > 0) {
          // wave433: finalize pending suffix T[N][M] before the count bump.
          leaf = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, leaf);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_dim_n);
          di = 0;
          while (di < param_dim_n && di < P12G_DIM_MAX) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_dims[di]);
            di = di + 1;
          }
        }
        param_suffix_pending = 0;
        param_dim_n = 0;
        if (param_elem_dim_n > 0) {
          // wave434: *T[N] postfix lift → top-level ARRAY of PTR (dims move to
          // the top rows; the former elem kind becomes the leaf elem_elem).
          bk2 = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_PTR);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, bk2);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_elem_dim_n);
          di = 0;
          while (di < param_elem_dim_n && di < P12G_DIM_MAX) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
            di = di + 1;
          }
        }
        param_elem_suffix_pending = 0;
        param_elem_dim_n = 0;
        param_prefix_arr_need_rb = 0;
        param_prefix_arr_need_size = 0;
        param_prefix_arr_elem_pending = 0;
        if (saw_param_tok != 0) {
          param_count = param_count + 1;
        }
        p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_COUNTS + mi * 4, param_count);
        saw_params_close = 1;
      }
      if (paren > 0) {
        paren = paren - 1;
      }
    } else if (saw_params_close == 0 && paren == 1 && depth == 0) {
      if (kind == TOKEN_COMMA) {
        if (param_suffix_pending != 0 && param_dim_n > 0) {
          // finalize multi-dim T[N][M] before the count bump (wave433)
          leaf = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, leaf);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_dim_n);
          di = 0;
          while (di < param_dim_n && di < P12G_DIM_MAX) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_dims[di]);
            di = di + 1;
          }
        }
        param_suffix_pending = 0;
        param_dim_n = 0;
        param_prefix_arr_need_rb = 0;
        param_prefix_arr_need_size = 0;
        param_prefix_arr_elem_pending = 0;
        if (param_elem_dim_n > 0) {
          // wave434 *T[N] postfix lift: elem=PTR stays, dims move to elem rows
          bk2 = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_PTR);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, bk2);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_elem_dim_n);
          di = 0;
          while (di < param_elem_dim_n && di < P12G_DIM_MAX) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
            di = di + 1;
          }
        }
        param_elem_suffix_pending = 0;
        param_elem_dim_n = 0;
        if (saw_param_tok != 0) {
          param_count = param_count + 1;
        }
        saw_param_tok = 0;
        want_param_ty = 0;
      } else if (kind == TOKEN_COLON) {
        want_param_ty = 1;
      } else if (want_param_ty != 0 && param_count < P12G_PARAM_MAX) {
        if (param_arr_need_rb != 0) {
          if (kind == TOKEN_RBRACKET) {
            // wave433: after T[N], stay open for further [M] dims.
            param_arr_need_rb = 0;
            param_suffix_pending = 1;
          } else {
            param_arr_need_rb = 0;
            want_param_ty = 0;
          }
        } else if (param_arr_need_size != 0) {
          if (kind == TOKEN_RBRACKET) {
            // Suffix T[] -> SLICE with the prior base as elem (no multi after).
            b0 = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, b0);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_SLICE);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, 0);
            param_arr_need_size = 0;
            param_dim_n = 0;
            want_param_ty = 0;
            saw_param_tok = 1;
          } else if (kind == TOKEN_INT && iv > 0) {
            // Collect one dim; finalize on non-`[` after the closing `]`.
            if (param_dim_n < P12G_DIM_MAX) {
              param_dims[param_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
              param_dim_n = param_dim_n + 1;
            }
            param_arr_need_size = 0;
            param_arr_need_rb = 1;
          } else {
            param_arr_need_size = 0;
            want_param_ty = 0;
          }
        } else if (param_suffix_pending != 0) {
          if (kind == TOKEN_LBRACKET) {
            param_suffix_pending = 0;
            param_arr_need_size = 1;
          } else {
            if (param_dim_n > 0) {
              leaf2 = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, leaf2);
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_dim_n);
              di = 0;
              while (di < param_dim_n && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_dims[di]);
                di = di + 1;
              }
            }
            param_suffix_pending = 0;
            param_dim_n = 0;
            want_param_ty = 0;
          }
        } else if (param_slice_need_rb != 0) {
          // Prefix `[...`T after the opening `[` (kind tentatively SLICE):
          // `]` -> []T (SLICE; capture pointee next); INT N -> [N]T ARRAY.
          if (kind == TOKEN_RBRACKET) {
            param_slice_need_rb = 0;
            param_elem_pending = 1;
          } else if (kind == TOKEN_INT && iv > 0) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
            param_dim_n = 0;
            if (param_dim_n < P12G_DIM_MAX) {
              param_dims[param_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
              param_dim_n = param_dim_n + 1;
            }
            param_slice_need_rb = 0;
            param_prefix_arr_need_rb = 1;
          } else {
            want_param_ty = 0;
            param_slice_need_rb = 0;
          }
        } else if (param_prefix_arr_need_rb != 0) {
          // Prefix `[N` — want `]` then leaf T or another `[`.
          if (kind == TOKEN_RBRACKET) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_dim_n);
            di = 0;
            while (di < param_dim_n && di < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_dims[di]);
              di = di + 1;
            }
            param_prefix_arr_need_rb = 0;
            param_prefix_arr_elem_pending = 1;
          } else {
            param_prefix_arr_need_rb = 0;
            want_param_ty = 0;
          }
        } else if (param_prefix_arr_need_size != 0) {
          // Prefix `[N][` — next dim INT (`[N][M]T`) or `]` (`[N][]T` = ARRAY
          // of SLICE of T; leaf T captured via param_elem_elem_pending).
          if (kind == TOKEN_INT && iv > 0) {
            if (param_dim_n < P12G_DIM_MAX) {
              param_dims[param_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
              param_dim_n = param_dim_n + 1;
            }
            param_prefix_arr_need_size = 0;
            param_prefix_arr_need_rb = 1;
          } else if (kind == TOKEN_RBRACKET) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_SLICE);
            param_dim_n = 0;
            param_prefix_arr_need_size = 0;
            param_elem_elem_pending = 1;
          } else {
            param_prefix_arr_need_size = 0;
            want_param_ty = 0;
          }
        } else if (param_prefix_arr_elem_pending != 0) {
          // After `[N]` / `[N][M]…` — capture the leaf T, or another `[`.
          if (kind == TOKEN_LBRACKET) {
            param_prefix_arr_elem_pending = 0;
            param_prefix_arr_need_size = 1;
          } else if (kind == TOKEN_STAR) {
            // Prefix `[N]*T` — STAR is a PTR elem, not a scalar builtin kind.
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_PTR);
            param_prefix_arr_elem_pending = 0;
            param_elem_elem_pending = 1;
            saw_param_tok = 1;
          } else if (kind == TOKEN_IDENT) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_NAMED);
            p12g_param_copy_name(ent_img, mi, param_count, source, lex_inout);
            param_dim_n = 0;
            param_prefix_arr_elem_pending = 0;
            want_param_ty = 0;
            saw_param_tok = 1;
          } else {
            unsafe {
            bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
            }
            if (bk6 >= 0) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, bk6);
              param_dim_n = 0;
              param_prefix_arr_elem_pending = 0;
              want_param_ty = 0;
              saw_param_tok = 1;
            } else {
              param_prefix_arr_elem_pending = 0;
              want_param_ty = 0;
            }
          }
        } else if (param_elem_slice_need_rb != 0) {
          // wave435/436: `*[...` — saw `[` after PTR. `]` -> *[]T (PTR to
          // SLICE; capture base T next); INT N -> *[N]T (PTR to ARRAY).
          if (kind == TOKEN_RBRACKET) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_SLICE);
            param_elem_slice_need_rb = 0;
            param_elem_elem_pending = 1;
          } else if (kind == TOKEN_INT && iv > 0) {
            // wave436: *[N]T -> PTR to ARRAY of N T. Capture N, expect `]`.
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
            if (param_elem_dim_n < P12G_DIM_MAX) {
              param_elem_dims[param_elem_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
              param_elem_dim_n = param_elem_dim_n + 1;
            }
            param_elem_slice_need_rb = 0;
            param_elem_prefix_arr_need_rb = 1;
          } else {
            param_elem_slice_need_rb = 0;
            want_param_ty = 0;
          }
        } else if (param_elem_prefix_arr_need_rb != 0) {
          // wave436/437: `*[N` — want `]` then base T. Dims stay in the local
          // buffer until base T capture commits them (multi-dim *[N][M]T).
          if (kind == TOKEN_RBRACKET) {
            param_elem_prefix_arr_need_rb = 0;
            param_elem_elem_pending = 1;
          } else {
            param_elem_prefix_arr_need_rb = 0;
            want_param_ty = 0;
          }
        } else if (param_elem_elem_pending != 0) {
          // wave435/436/437: slice/array closed; capture base T (NAMED name
          // or builtin) and commit accumulated ARRAY dims from the buffer.
          if (kind == TOKEN_IDENT) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_NAMED);
            p12g_param_copy_name(ent_img, mi, param_count, source, lex_inout);
            // Commit accumulated dims (*[N] or *[N][M]…). Reset elem_dim_n so
            // the wave434 *T[N] postfix lift at `,`/`)` does not re-fire and
            // overwrite the PTR-of-ARRAY shape.
            if (param_elem_dim_n > 0) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_elem_dim_n);
              di = 0;
              while (di < param_elem_dim_n && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                di = di + 1;
              }
              param_elem_dim_n = 0;
            }
            param_elem_elem_pending = 0;
            want_param_ty = 0;
            saw_param_tok = 1;
          } else if (kind == TOKEN_LBRACKET) {
            // wave437: *[N][M]T multi-dim — collect the next dim, return here.
            param_elem_elem_pending = 0;
            param_elem_prefix_arr_more = 1;
            param_elem_arr_need_size = 1;
          } else if (kind == TOKEN_STAR && p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_ARRAY || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR)) {
            // Extra STAR after a PTR elem (`[]*[2]*T` / `[2]*[2]*T` / `**[2]*T`
            // family and bare `***T`): commit pending dims first, then bump
            // the extra-PTR wrap COUNT in the unused slot dims[nd+1] (ndims>=1
            // or ndims staying 0 -> dims[1]). Stay pending to capture leaf T.
            if (param_elem_dim_n > 0) {
              nd = param_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                di = di + 1;
              }
              param_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4);
            }
            if (nd >= 0 && nd + 1 < P12G_DIM_MAX) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
              }
              // stay param_elem_elem_pending to capture leaf T
            } else {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, 0 - 1);
              param_elem_elem_pending = 0;
              want_param_ty = 0;
              saw_param_tok = 1;
            }
          } else if (kind == TOKEN_STAR && p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_ARRAY && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR)) {
            // Extra STAR after an ARRAY elem (`[][2]*T` family; PTR-outer
            // `*[2]*T`): same unused-slot encoding at dims[nd+1], nd>0.
            if (param_elem_dim_n > 0) {
              nd = param_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                di = di + 1;
              }
              param_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4);
            }
            if (nd > 0 && nd + 1 < P12G_DIM_MAX) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
              }
              // stay param_elem_elem_pending to capture leaf T
            } else {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, 0 - 1);
              param_elem_elem_pending = 0;
              want_param_ty = 0;
              saw_param_tok = 1;
            }
          } else if (kind == TOKEN_STAR && p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_ARRAY || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR)) {
            // Extra STAR after a SLICE elem (`[2][]*T` / `[][]*T` / `*[]*T`
            // family): slot depends on nd — 0 -> dims[0]; -2 sentinel ->
            // dims[1]; >0 -> dims[nd]. Stay pending to capture leaf T.
            if (param_elem_dim_n > 0) {
              nd = param_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                di = di + 1;
              }
              param_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4);
            }
            if (nd == 0) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + 0 * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + 0 * 4, extra);
              }
              // stay param_elem_elem_pending to capture leaf T
            } else if (nd == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + 1 * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + 1 * 4, extra);
              }
              // stay param_elem_elem_pending to capture leaf T
            } else if (nd > 0 && nd < P12G_DIM_MAX) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd * 4, extra);
              }
              // stay param_elem_elem_pending to capture leaf T
            } else {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, 0 - 1);
              param_elem_elem_pending = 0;
              want_param_ty = 0;
              saw_param_tok = 1;
            }
          } else {
            unsafe {
            bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
            }
            if (bk6 >= 0) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, bk6);
              // Commit accumulated dims (*[N] or *[N][M]…); same wave437 reset.
              if (param_elem_dim_n > 0) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_elem_dim_n);
                di = 0;
                while (di < param_elem_dim_n && di < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                  di = di + 1;
                }
                param_elem_dim_n = 0;
              }
              param_elem_elem_pending = 0;
              want_param_ty = 0;
              saw_param_tok = 1;
            } else {
              param_elem_elem_pending = 0;
              want_param_ty = 0;
            }
          }
        } else if (param_elem_arr_need_rb != 0) {
          if (kind == TOKEN_RBRACKET) {
            param_elem_arr_need_rb = 0;
            if (param_elem_prefix_arr_more != 0) {
              // wave437: *[N][M]T — return to base T capture for more dims.
              param_elem_prefix_arr_more = 0;
              param_elem_elem_pending = 1;
            } else {
              // wave434: after elem T[N], stay open for further [M] dims.
              param_elem_suffix_pending = 1;
            }
          } else {
            param_elem_arr_need_rb = 0;
            param_elem_prefix_arr_more = 0;
            want_param_ty = 0;
          }
        } else if (param_elem_arr_need_size != 0) {
          if (kind == TOKEN_RBRACKET) {
            // Extra empty `[]` after a PTR/SLICE elem: three encodings — the
            // ndims=-2 sentinel (dims[0] counts wraps), an unused-slot count
            // at dims[nd], or dims[nd+1] for SLICE-elem with committed dims.
            if ((p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE) && param_elem_dim_n == 0 && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4) == P12G_ELEM_PTR_TO_SLICE_NDIMS || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4) <= 0) && !(p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR && p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR)) {
              if (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4) == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + 0 * 4);
                if (extra <= 0) {
                  extra = 1;
                }
                extra = extra + 1;
                if (extra < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + 0 * 4, extra);
                }
              } else {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, P12G_ELEM_PTR_TO_SLICE_NDIMS);
              }
              param_elem_arr_need_size = 0;
              param_elem_prefix_arr_more = 0;
              param_elem_dim_n = 0;
              param_elem_elem_pending = 1;
            } else if ((p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_ARRAY && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR)) || (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_ARRAY))) {
              // ARRAY elem (SLICE/PTR outer) or PTR elem (any outer): extra
              // wrap COUNT in the first unused dim slot dims[nd] (nd>=0).
              if (param_elem_dim_n > 0) {
                nd = param_elem_dim_n;
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, nd);
                di = 0;
                while (di < nd && di < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                  di = di + 1;
                }
                param_elem_dim_n = 0;
              } else {
                nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4);
              }
              if (nd >= 0 && nd < P12G_DIM_MAX) {
                extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd * 4);
                if (extra < 0) {
                  extra = 0;
                }
                extra = extra + 1;
                if (extra < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd * 4, extra);
                }
                param_elem_arr_need_size = 0;
                param_elem_prefix_arr_more = 0;
                param_elem_elem_pending = 1;
              } else {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, 0 - 1);
                param_elem_arr_need_size = 0;
                param_elem_prefix_arr_more = 0;
                param_elem_dim_n = 0;
                want_param_ty = 0;
                saw_param_tok = 1;
              }
            } else if (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE && (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_ARRAY || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) == P12G_TY_PTR)) {
              // SLICE elem with committed dims (`[2][][2][]T` family):
              // extra wrap COUNT in the unused slot dims[nd+1] (nd>0).
              if (param_elem_dim_n > 0) {
                nd = param_elem_dim_n;
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, nd);
                di = 0;
                while (di < nd && di < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                  di = di + 1;
                }
                param_elem_dim_n = 0;
              } else {
                nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4);
              }
              if (nd > 0 && nd + 1 < P12G_DIM_MAX) {
                extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
                if (extra < 0) {
                  extra = 0;
                }
                extra = extra + 1;
                if (extra < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
                }
                param_elem_arr_need_size = 0;
                param_elem_prefix_arr_more = 0;
                param_elem_elem_pending = 1;
              } else {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, 0 - 1);
                param_elem_arr_need_size = 0;
                param_elem_prefix_arr_more = 0;
                param_elem_dim_n = 0;
                want_param_ty = 0;
                saw_param_tok = 1;
              }
            } else {
              // wave434: elem T[] (3-layer) stays deferred; wave437 also
              // clears prefix_arr_more if this came from *[N][]T.
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, 0 - 1);
              param_elem_arr_need_size = 0;
              param_elem_prefix_arr_more = 0;
              param_elem_dim_n = 0;
              want_param_ty = 0;
              saw_param_tok = 1;
            }
          } else if (kind == TOKEN_INT && iv > 0) {
            // Collect one elem dim; finalize on non-`[` after the closing `]`.
            if (param_elem_dim_n < P12G_DIM_MAX) {
              param_elem_dims[param_elem_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
              param_elem_dim_n = param_elem_dim_n + 1;
            }
            param_elem_arr_need_size = 0;
            param_elem_arr_need_rb = 1;
          } else {
            param_elem_arr_need_size = 0;
            param_elem_prefix_arr_more = 0;
            want_param_ty = 0;
          }
        } else if (param_elem_suffix_pending != 0) {
          if (kind == TOKEN_LBRACKET) {
            param_elem_suffix_pending = 0;
            param_elem_arr_need_size = 1;
          } else {
            // Finalize elem multi-dim (dims>0 -> elem=ARRAY) or leave scalar.
            if (param_elem_dim_n > 0) {
              leaf2 = p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4);
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, leaf2);
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_ARRAY);
              p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + param_count * 4, param_elem_dim_n);
              di = 0;
              while (di < param_elem_dim_n && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + param_count * P12G_PARAM_DIMS_ROW_INNER + di * 4, param_elem_dims[di]);
                di = di + 1;
              }
            }
            param_elem_suffix_pending = 0;
            param_elem_dim_n = 0;
            want_param_ty = 0;
          }
        } else if (param_elem_pending != 0) {
          if (kind == TOKEN_IDENT) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_NAMED);
            p12g_param_copy_name(ent_img, mi, param_count, source, lex_inout);
            // wave434: keep scanning for elem suffix [N]/[]/[N][M].
            param_elem_suffix_pending = 1;
          } else if (kind == TOKEN_LBRACKET) {
            // wave435: `*[...` — elem opens with `[`; defer the elem kind
            // decision to param_elem_slice_need_rb (`]` vs INT).
            param_elem_slice_need_rb = 1;
          } else if (kind == TOKEN_STAR) {
            // After `[]` (or a top-level `*` for `**T`): STAR is a PTR elem.
            // token_to_type_kind does not handle STAR, so store elem=PTR and
            // capture the pointee via param_elem_elem_pending.
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_PTR);
            param_elem_elem_pending = 1;
          } else {
            unsafe {
            bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
            }
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, bk6);
            // wave434: keep scanning for elem suffix [N]/[]/[N][M].
            param_elem_suffix_pending = 1;
          }
          param_elem_pending = 0;
          saw_param_tok = 1;
        } else if (p12g_load_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4) < 0) {
          if (kind == TOKEN_IDENT) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_NAMED);
            p12g_param_copy_name(ent_img, mi, param_count, source, lex_inout);
            // wave433: keep scanning for suffix T[N] / T[] / T[N][M].
            param_suffix_pending = 1;
            saw_param_tok = 1;
          } else if (kind == TOKEN_STAR) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_PTR);
            param_elem_pending = 1;
          } else if (kind == TOKEN_LBRACKET) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, P12G_TY_SLICE);
            param_slice_need_rb = 1;
          } else {
            unsafe {
            bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
            }
            p12g_store_i32(ent_img, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + param_count * 4, bk6);
            // wave433: keep scanning for suffix T[N] / T[] / T[N][M].
            param_suffix_pending = 1;
            saw_param_tok = 1;
          }
        } else {
          want_param_ty = 0;
        }
      } else {
        // Twin of the C params-branch tail else: any other token in the
        // param region (e.g. a bare `self` name before its type colon)
        // marks the param present so the `)`/`,` close bumps the count.
        saw_param_tok = 1;
      }
    } else if (saw_params_close == 1 && want_ret == 0 && depth == 0 && paren == 0 && kind == TOKEN_COLON) {
      // Return-type gate: reset the whole ret shape machine (wave427-438).
      want_ret = 1;
      ret_elem_pending = 0;
      ret_slice_need_rb = 0;
      ret_suffix_pending = 0;
      ret_arr_need_size = 0;
      ret_arr_need_rb = 0;
      ret_dim_n = 0;
      ret_elem_suffix_pending = 0;
      ret_elem_arr_need_size = 0;
      ret_elem_arr_need_rb = 0;
      ret_elem_slice_need_rb = 0;
      ret_elem_elem_pending = 0;
      ret_elem_prefix_arr_need_rb = 0;
      ret_elem_prefix_arr_more = 0;
      ret_elem_dim_n = 0;
      ret_prefix_arr_need_rb = 0;
      ret_prefix_arr_need_size = 0;
      ret_prefix_arr_elem_pending = 0;
    } else if (want_ret != 0) {
      // Ret shape capture: builtin / NAMED / PTR / SLICE / ARRAY / multi-dim
      // and the full PTR/SLICE-elem families (waves 427-438 + wave954 twins).
      if (ret_arr_need_rb != 0) {
        if (kind == TOKEN_RBRACKET) {
          // wave431: after T[N], stay open for further [M] dims.
          ret_arr_need_rb = 0;
          ret_suffix_pending = 1;
        } else {
          ret_arr_need_rb = 0;
          want_ret = 0;
        }
      } else if (ret_arr_need_size != 0) {
        if (kind == TOKEN_RBRACKET) {
          // Suffix T[] -> SLICE with the prior base as elem (no multi after).
          leaf = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, leaf);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, P12G_TY_SLICE);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_SIZES + mi * 4, 0 - 1);
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_NDIMS + mi * 4, 0);
          ret_arr_need_size = 0;
          ret_dim_n = 0;
          want_ret = 0;
        } else if (kind == TOKEN_INT && iv > 0) {
          // Collect one dim; finalize on non-`[` after the closing `]`.
          if (ret_dim_n < P12G_DIM_MAX) {
            ret_dims[ret_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
            ret_dim_n = ret_dim_n + 1;
          }
          ret_arr_need_size = 0;
          ret_arr_need_rb = 1;
        } else {
          ret_arr_need_size = 0;
          want_ret = 0;
        }
      } else if (ret_suffix_pending != 0) {
        if (kind == TOKEN_LBRACKET) {
          ret_suffix_pending = 0;
          ret_arr_need_size = 1;
        } else {
          // Finalize multi-dim (or leave scalar/named base if no dims).
          if (ret_dim_n > 0) {
            leaf = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, leaf);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, P12G_TY_ARRAY);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_NDIMS + mi * 4, ret_dim_n);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_SIZES + mi * 4, ret_dims[0]);
            di = 0;
            while (di < ret_dim_n && di < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_dims[di]);
              di = di + 1;
            }
          }
          ret_suffix_pending = 0;
          want_ret = 0;
        }
      } else if (ret_slice_need_rb != 0) {
        // Prefix array ret after the opening bracket (kind tentatively
        // SLICE): RBRACKET -> []T (SLICE; capture pointee next); INT N ->
        // [N]T ARRAY.
        if (kind == TOKEN_RBRACKET) {
          ret_slice_need_rb = 0;
          ret_elem_pending = 1;
        } else if (kind == TOKEN_INT && iv > 0) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, P12G_TY_ARRAY);
          ret_dim_n = 0;
          if (ret_dim_n < P12G_DIM_MAX) {
            ret_dims[ret_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
            ret_dim_n = ret_dim_n + 1;
          }
          ret_slice_need_rb = 0;
          ret_prefix_arr_need_rb = 1;
        } else {
          want_ret = 0;
          ret_slice_need_rb = 0;
        }
      } else if (ret_prefix_arr_need_rb != 0) {
        // Prefix [N ret — want RBRACKET then leaf T or another bracket.
        if (kind == TOKEN_RBRACKET) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_NDIMS + mi * 4, ret_dim_n);
          if (ret_dim_n > 0) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_SIZES + mi * 4, ret_dims[0]);
          } else {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_SIZES + mi * 4, 0 - 1);
          }
          di = 0;
          while (di < ret_dim_n && di < P12G_DIM_MAX) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_dims[di]);
            di = di + 1;
          }
          ret_prefix_arr_need_rb = 0;
          ret_prefix_arr_elem_pending = 1;
        } else {
          ret_prefix_arr_need_rb = 0;
          want_ret = 0;
        }
      } else if (ret_prefix_arr_need_size != 0) {
        // Prefix [N][ ret — want the next dim INT.
        if (kind == TOKEN_INT && iv > 0) {
          if (ret_dim_n < P12G_DIM_MAX) {
            ret_dims[ret_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
            ret_dim_n = ret_dim_n + 1;
          }
          ret_prefix_arr_need_size = 0;
          ret_prefix_arr_need_rb = 1;
        } else {
          ret_prefix_arr_need_size = 0;
          want_ret = 0;
        }
      } else if (ret_prefix_arr_elem_pending != 0) {
        // After [N] / [N][M]… ret — capture the leaf T, or another bracket.
        if (kind == TOKEN_LBRACKET) {
          ret_prefix_arr_elem_pending = 0;
          ret_prefix_arr_need_size = 1;
        } else if (kind == TOKEN_IDENT) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, P12G_TY_NAMED);
          p12g_ret_copy_name(ent_img, mi, source, lex_inout);
          ret_dim_n = 0;
          ret_prefix_arr_elem_pending = 0;
          want_ret = 0;
        } else {
          unsafe {
          bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
          }
          if (bk6 >= 0) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, bk6);
            ret_dim_n = 0;
            ret_prefix_arr_elem_pending = 0;
            want_ret = 0;
          } else {
            ret_prefix_arr_elem_pending = 0;
            want_ret = 0;
          }
        }
      } else if (ret_elem_pending != 0) {
        if (kind == TOKEN_IDENT) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, P12G_TY_NAMED);
          p12g_ret_copy_name(ent_img, mi, source, lex_inout);
          // wave438: keep scanning for elem suffix dims.
          ret_elem_suffix_pending = 1;
        } else if (kind == TOKEN_LBRACKET) {
          // wave438: elem opens with a bracket; defer the elem kind
          // decision to ret_elem_slice_need_rb (RBRACKET vs INT).
          ret_elem_slice_need_rb = 1;
        } else if (kind == TOKEN_STAR) {
          // Extra STAR (double-PTR ret family): STAR is a PTR elem; capture
          // the pointee via ret_elem_elem_pending.
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, P12G_TY_PTR);
          ret_elem_elem_pending = 1;
        } else {
          unsafe {
          bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
          }
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, bk6);
          // wave438: keep scanning for elem suffix dims.
          ret_elem_suffix_pending = 1;
        }
        ret_elem_pending = 0;
      } else if (ret_elem_slice_need_rb != 0) {
        // wave438: bracket after PTR — RBRACKET -> PTR to SLICE (capture
        // base T next); INT N -> PTR to ARRAY (capture N, expect RBRACKET).
        if (kind == TOKEN_RBRACKET) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, P12G_TY_SLICE);
          ret_elem_slice_need_rb = 0;
          ret_elem_elem_pending = 1;
        } else if (kind == TOKEN_INT && iv > 0) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, P12G_TY_ARRAY);
          if (ret_elem_dim_n < P12G_DIM_MAX) {
            ret_elem_dims[ret_elem_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
            ret_elem_dim_n = ret_elem_dim_n + 1;
          }
          ret_elem_slice_need_rb = 0;
          ret_elem_prefix_arr_need_rb = 1;
        } else {
          ret_elem_slice_need_rb = 0;
          want_ret = 0;
        }
      } else if (ret_elem_prefix_arr_need_rb != 0) {
        // wave438: PTR[N — want RBRACKET then base T. Dims stay in the
        // local buffer until base T capture commits them (multi-dim).
        if (kind == TOKEN_RBRACKET) {
          ret_elem_prefix_arr_need_rb = 0;
          ret_elem_elem_pending = 1;
        } else {
          ret_elem_prefix_arr_need_rb = 0;
          want_ret = 0;
        }
      } else if (ret_elem_elem_pending != 0) {
        // wave438: slice/array closed; capture base T and commit accumulated
        // ARRAY dims from the local buffer. Multi-dim returns here via the
        // prefix_arr_more flag. Extra-STAR arms bump the unused-slot wrap
        // COUNT (per-elem-family slot selection).
        if (kind == TOKEN_IDENT) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4, P12G_TY_NAMED);
          p12g_ret_copy_name(ent_img, mi, source, lex_inout);
          // Commit accumulated dims. Reset ret_elem_dim_n so the wave434
          // *T[N] postfix lift at the terminator does not re-fire.
          if (ret_elem_dim_n > 0) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, ret_elem_dim_n);
            di = 0;
            while (di < ret_elem_dim_n && di < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
              di = di + 1;
            }
            ret_elem_dim_n = 0;
          }
          ret_elem_elem_pending = 0;
          want_ret = 0;
        } else if (kind == TOKEN_LBRACKET) {
          // wave438: multi-dim — collect the next dim, return here.
          ret_elem_elem_pending = 0;
          ret_elem_prefix_arr_more = 1;
          ret_elem_arr_need_size = 1;
        } else if (kind == TOKEN_STAR && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_PTR && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_PTR) {
          // Extra STAR, PTR elem + PTR outer: extra PTR wrap COUNT in
          // dims[nd+1] (ndims>=1) or dims[1] (ndims 0).
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

          if (nd >= 0 && nd + 1 < P12G_DIM_MAX) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
            ret_elem_elem_pending = 0;
            want_ret = 0;
          }
        } else if (kind == TOKEN_STAR && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_ARRAY && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_PTR) {
          // Extra STAR, ARRAY elem + PTR outer: dims[nd+1], nd>0.
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

          if (nd > 0 && nd + 1 < P12G_DIM_MAX) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
            ret_elem_elem_pending = 0;
            want_ret = 0;
          }
        } else if (kind == TOKEN_STAR && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_SLICE && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_PTR) {
          // Extra STAR, SLICE elem + PTR outer: slot by nd — 0 -> dims[0];
          // -2 sentinel -> dims[1]; >0 -> dims[nd].
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

          if (nd == 0) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else if (nd == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 1 * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 1 * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else if (nd > 0 && nd < P12G_DIM_MAX) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
            ret_elem_elem_pending = 0;
            want_ret = 0;
          }

        } else if (kind == TOKEN_STAR && (p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_PTR || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_ARRAY) && (p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_ARRAY)) {
          // wave954: extra STAR with SLICE/ARRAY outer: same three-way slot
          // selection as the PTR-outer arm.
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

          if (nd == 0) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else if (nd == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 1 * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 1 * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else if (nd > 0 && nd < P12G_DIM_MAX) {
            extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd * 4);
            if (extra < 0) {
              extra = 0;
            }
            extra = extra + 1;
            if (extra < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd * 4, extra);
            }
            // stay ret_elem_elem_pending to capture leaf T
          } else {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
            ret_elem_elem_pending = 0;
            want_ret = 0;
          }

        } else {
          unsafe {
          bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
          }
          if (bk6 >= 0) {
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4, bk6);
            // Commit accumulated dims; when none pending and elem is PTR or
            // SLICE under a PTR/SLICE/ARRAY outer, stamp the PTR_TO_SLICE
            // sentinel (ndims=-2) so the leftover walk can peel extra wraps.
            if (ret_elem_dim_n > 0) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, ret_elem_dim_n);
              di = 0;
              while (di < ret_elem_dim_n && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else if ((p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_PTR || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_SLICE) && (p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_PTR || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_ARRAY)) {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
              if (nd == 0) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, P12G_ELEM_PTR_TO_SLICE_NDIMS);
              }
            }
            ret_elem_elem_pending = 0;
            ret_elem_suffix_pending = 1;
          } else {
            ret_elem_elem_pending = 0;
            want_ret = 0;
          }
        }
      } else if (ret_elem_arr_need_rb != 0) {
        if (kind == TOKEN_RBRACKET) {
          ret_elem_arr_need_rb = 0;
          if (ret_elem_prefix_arr_more != 0) {
            // wave438: multi-dim — return to base T capture for more dims.
            ret_elem_prefix_arr_more = 0;
            ret_elem_elem_pending = 1;
          } else {
            // wave438: after elem T[N], stay open for further [M] dims.
            ret_elem_suffix_pending = 1;
          }
        } else {
          ret_elem_arr_need_rb = 0;
          ret_elem_prefix_arr_more = 0;
          want_ret = 0;
        }
      } else if (ret_elem_arr_need_size != 0) {
        if (kind == TOKEN_RBRACKET) {
          // Extra empty bracket after PTR/SLICE/ARRAY elem: unused-slot wrap
          // COUNT at dims[nd] (PTR outer, ARRAY/PTR elem), dims[nd+1]
          // (committed dims), or the ndims=-2 sentinel family.
          if ((p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_ARRAY || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_PTR) && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_PTR) {
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

            if (nd >= 0 && nd < P12G_DIM_MAX) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd * 4, extra);
              }
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_elem_pending = 1;
            } else {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_dim_n = 0;
              want_ret = 0;
            }
          } else if (p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_SLICE && p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_PTR) {
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

            if ((nd == P12G_ELEM_PTR_TO_SLICE_NDIMS || nd <= 0) && ret_elem_dim_n == 0) {
              if (nd == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4);
                if (extra <= 0) {
                  extra = 1;
                }
                extra = extra + 1;
                if (extra < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4, extra);
                }
              } else {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, P12G_ELEM_PTR_TO_SLICE_NDIMS);
              }
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_dim_n = 0;
              ret_elem_elem_pending = 1;
            } else if (nd > 0 && nd + 1 < P12G_DIM_MAX) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
              }
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_elem_pending = 1;
            } else {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_dim_n = 0;
              want_ret = 0;
            }

          } else if ((p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_PTR || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4) == P12G_TY_ARRAY) && (p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_SLICE || p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) == P12G_TY_ARRAY)) {
            if (ret_elem_dim_n > 0) {
              nd = ret_elem_dim_n;
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, nd);
              di = 0;
              while (di < nd && di < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
                di = di + 1;
              }
              ret_elem_dim_n = 0;
            } else {
              nd = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
            }

            if ((nd == P12G_ELEM_PTR_TO_SLICE_NDIMS || nd <= 0) && ret_elem_dim_n == 0) {
              if (nd == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4);
                if (extra <= 0) {
                  extra = 1;
                }
                extra = extra + 1;
                if (extra < P12G_DIM_MAX) {
                  p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + 0 * 4, extra);
                }
              } else {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, P12G_ELEM_PTR_TO_SLICE_NDIMS);
              }
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_dim_n = 0;
              ret_elem_elem_pending = 1;
            } else if (nd > 0 && nd + 1 < P12G_DIM_MAX) {
              extra = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4);
              if (extra < 0) {
                extra = 0;
              }
              extra = extra + 1;
              if (extra < P12G_DIM_MAX) {
                p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + nd + 1 * 4, extra);
              }
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_elem_pending = 1;
            } else {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
              ret_elem_arr_need_size = 0;
              ret_elem_prefix_arr_more = 0;
              ret_elem_dim_n = 0;
              want_ret = 0;
            }

          } else {
            // wave438: elem T[] (3-layer) stays deferred; also clears
            // prefix_arr_more if this came from a multi-dim path.
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, 0 - 1);
            ret_elem_arr_need_size = 0;
            ret_elem_prefix_arr_more = 0;
            ret_elem_dim_n = 0;
            want_ret = 0;
          }
        } else if (kind == TOKEN_INT && iv > 0) {
          // Collect one elem dim; finalize on non-`[` after the closing `]`.
          if (ret_elem_dim_n < P12G_DIM_MAX) {
            ret_elem_dims[ret_elem_dim_n] = parser_asm_lex_peek_int_val_c(lex_inout, source);
            ret_elem_dim_n = ret_elem_dim_n + 1;
          }
          ret_elem_arr_need_size = 0;
          ret_elem_arr_need_rb = 1;
        } else {
          ret_elem_arr_need_size = 0;
          ret_elem_prefix_arr_more = 0;
          want_ret = 0;
        }
      } else if (ret_elem_suffix_pending != 0) {
        if (kind == TOKEN_LBRACKET) {
          ret_elem_suffix_pending = 0;
          ret_elem_arr_need_size = 1;
        } else {
          // Finalize elem multi-dim (dims>0 -> elem=ARRAY) or leave scalar.
          if (ret_elem_dim_n > 0) {
            leaf = p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4, leaf);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4, P12G_TY_ARRAY);
            p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4, ret_elem_dim_n);
            di = 0;
            while (di < ret_elem_dim_n && di < P12G_DIM_MAX) {
              p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + di * 4, ret_elem_dims[di]);
              di = di + 1;
            }
          }
          ret_elem_suffix_pending = 0;
          ret_elem_dim_n = 0;
          want_ret = 0;
        }
      } else if (p12g_load_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4) < 0) {
        if (kind == TOKEN_IDENT) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, P12G_TY_NAMED);
          p12g_ret_copy_name(ent_img, mi, source, lex_inout);
          // wave430/431: keep scanning for suffix dims.
          ret_suffix_pending = 1;
        } else if (kind == TOKEN_STAR) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, P12G_TY_PTR);
          ret_elem_pending = 1;
        } else if (kind == TOKEN_LBRACKET) {
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, P12G_TY_SLICE);
          ret_slice_need_rb = 1;
        } else {
          unsafe {
          bk6 = parser_asm_type_ref_builtin_kind_ord_c(kind);
          }
          p12g_store_i32(ent_img, P12G_OFF_METHOD_RET_KINDS + mi * 4, bk6);
          if (bk6 >= 0) {
            ret_suffix_pending = 1;
          } else {
            want_ret = 0;
          }
        }
      } else {
        want_ret = 0;
      }
    }
    // Terminator (twin of the C sig-machine tail): LBRACE opens a default
    // body (has_default stamps on close), RBRACE at depth 0 is the trait
    // close (leave it for the outer body loop), SEMICOLON ends the
    // signature, FUNCTION is the wave464 ASI case (leave for outer loop).
    if (kind == TOKEN_LBRACE) {
      depth = depth + 1;
    } else if (kind == TOKEN_RBRACE) {
      if (depth > 0) {
        depth = depth - 1;
        if (depth == 0) {
          // wave468: method body closed -> default method eligible for hoist.
          p12g_store_i32(ent_img, P12G_OFF_METHOD_HAS_DEFAULT + mi * 4, 1);
          unsafe {
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
          return;
        }
      } else {
        return;
      }
    } else if (kind == TOKEN_SEMICOLON && depth == 0) {
      unsafe {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
      return;
    } else if (kind == TOKEN_FUNCTION && depth == 0 && paren == 0) {
      return;
    }
    unsafe {
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
}


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

/**
 * TYPE_NAMED spelling "Self" (capital S) — not TOKEN_SELF lowercase
 * binding. Used by self_matches_for, named_eq_self, and rewrite_self.
 * @param nm *u8 — spelling bytes; null → 0
 * @param nl i32 — byte count; must be 4
 * @return i32 — 1 if exactly `Self`; 0 otherwise
 * PLATFORM: SHARED — product P12i B-minus. Do not copy into P4b.
 */
#[no_mangle]
export function xlang_skip_name_is_self_c(nm: *u8, nl: i32): i32 {
  if (nl != 4) {
    return 0;
  }
  if (nm == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (nm[0] != 83) {
      return 0;
    }
    if (nm[1] != 101) {
      return 0;
    }
    if (nm[2] != 108) {
      return 0;
    }
    if (nm[3] != 102) {
      return 0;
    }
  }
  return 1;
}

/**
 * Byte-exact compare of two spellings. Dest cap is 64 (C twin gnm[64]).
 * Lengths must match; then min(alen, 64) bytes are compared.
 * @param a *u8 — left bytes; null with alen>0 → 0
 * @param alen i32 — left length
 * @param b *u8 — right bytes; null with blen>0 → 0
 * @param blen i32 — right length
 * @return i32 — 1 if equal, 0 otherwise
 * PLATFORM: SHARED — file-local helper for P12i; not a second P6b authority.
 */
function skip_named_bytes_eq(a: *u8, alen: i32, b: *u8, blen: i32): i32 {
  let i: i32 = 0;
  if (alen != blen) {
    return 0;
  }
  if (alen <= 0) {
    return 1;
  }
  if (a == 0 as *u8 || b == 0 as *u8) {
    return 0;
  }
  unsafe {
    i = 0;
    while (i < alen && i < GNM_CAP) {
      if (a[i as usize] != b[i as usize]) {
        return 0;
      }
      i = i + 1;
    }
  }
  return 1;
}

/**
 * Zero dest[0..64) then copy the TYPE_NAMED spelling of `ty_ref`.
 * @param arena *u8 — opaque ASTArena
 * @param ty_ref i32 — type_ref whose name is copied
 * @param gnm *u8 — dest 64; null → 0
 * @return i32 — full name_len from the sidecar (may exceed 64)
 * PLATFORM: SHARED — C trampoline holds gnm[64]; memset every fill.
 */
function skip_fill_gnm(arena: *u8, ty_ref: i32, gnm: *u8): i32 {
  let zi: i32 = 0;
  if (gnm == 0 as *u8) {
    return 0;
  }
  unsafe {
    zi = 0;
    while (zi < GNM_CAP) {
      gnm[zi as usize] = 0;
      zi = zi + 1;
    }
    return pipeline_type_named_name_into(arena, ty_ref, gnm);
  }
}

/**
 * NAMED for-type name check used by the three self_matches_for arms.
 * Self spelling → `self_ok`; else dest-buffer byte-eq against `for_name`.
 * @param arena *u8 — opaque ASTArena
 * @param ty_ref i32 — type_ref whose NAME is compared
 * @param for_name *u8 — impl for-type spelling
 * @param for_nlen i32 — for-type length
 * @param gnm *u8 — dest 64
 * @param self_ok i32 — value to return when the type spelling is `Self`
 * @return i32 — self_ok / 1 match / 0 mismatch
 * PLATFORM: SHARED — file-local; keep the C twin's Self vs memcmp order.
 */
function skip_named_self_or_eq(arena: *u8, ty_ref: i32, for_name: *u8, for_nlen: i32, gnm: *u8, self_ok: i32): i32 {
  let gnl: i32 = 0;
  gnl = skip_fill_gnm(arena, ty_ref, gnm);
  if (xlang_skip_name_is_self_c(gnm, gnl) != 0) {
    return self_ok;
  }
  if (skip_named_bytes_eq(gnm, gnl, for_name, for_nlen) == 0) {
    return 0;
  }
  return 1;
}

/**
 * Verify an impl method's param0 (self) type matches the impl for-type.
 * Wave441/470/471: unknown/untyped accept; `Self` aliases the named
 * non-ptr for-type; pointer receivers `*For` / `*Self` are accepted
 * when the impl is `for For` (non-ptr). Language has no local u8[N];
 * `gnm` is the C trampoline dest (cap 64).
 * @param arena *u8 — opaque ASTArena; may be null (sidecar returns -1/0)
 * @param pty0 i32 — type_ref of impl method param0; 0 if untyped
 * @param for_k i32 — for-type TypeKind ordinal; <0 → accept
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_name *u8 — for-type name bytes; may be null
 * @param for_nlen i32 — for-type name length
 * @param gnm *u8 — dest 64 for one TYPE_NAMED spelling; C trampoline holds it
 * @return i32 — 1 match or unknown/untyped; 0 definite mismatch
 * PLATFORM: SHARED — product P12i B-minus. P12l dest-buffers
 * concrete_implements_trait over this matcher. Do not copy into typeck.
 * Do not merge with P6b. Do not open a new P-lane.
 */
#[no_mangle]
export function xlang_skip_impl_self_matches_for_into_c(arena: *u8, pty0: i32, for_k: i32, for_ptr: i32, for_name: *u8, for_nlen: i32, gnm: *u8): i32 {
  let got0: i32 = 0;
  let elem: i32 = 0;
  let gek: i32 = 0;
  let rc: i32 = 0;
  let self_ok: i32 = 0;
  if (for_k < 0) {
    return 1;
  }
  unsafe {
    if (pty0 != 0) {
      got0 = pipeline_type_kind_ord_at(arena, pty0);
    } else {
      got0 = 0 - 1;
    }
  }
  if (got0 < 0) {
    return 1;
  }
  if (gnm == 0 as *u8) {
    return 0;
  }
  if (for_ptr != 0) {
    if (got0 != TYPE_PTR) {
      return 0;
    }
    unsafe {
      if (pty0 != 0) {
        elem = pipeline_type_elem_ref_at(arena, pty0);
      } else {
        elem = 0;
      }
      if (elem != 0) {
        gek = pipeline_type_kind_ord_at(arena, elem);
      } else {
        gek = 0 - 1;
      }
    }
    if (gek >= 0 && gek != for_k) {
      return 0;
    }
    if (gek == for_k && for_k == TYPE_NAMED && for_nlen > 0 && for_name != 0 as *u8 && elem != 0) {
      rc = skip_named_self_or_eq(arena, elem, for_name, for_nlen, gnm, 1);
      if (rc == 0) {
        return 0;
      }
    }
    return 1;
  }
  if (got0 == TYPE_PTR) {
    unsafe {
      if (pty0 != 0) {
        elem = pipeline_type_elem_ref_at(arena, pty0);
      } else {
        elem = 0;
      }
      if (elem != 0) {
        gek = pipeline_type_kind_ord_at(arena, elem);
      } else {
        gek = 0 - 1;
      }
    }
    if (gek < 0) {
      return 1;
    }
    if (gek != for_k) {
      return 0;
    }
    if (for_k == TYPE_NAMED && for_nlen > 0 && for_name != 0 as *u8 && elem != 0) {
      rc = skip_named_self_or_eq(arena, elem, for_name, for_nlen, gnm, 1);
      if (rc == 0) {
        return 0;
      }
    }
    return 1;
  }
  if (got0 != for_k) {
    return 0;
  }
  if (got0 == TYPE_NAMED && for_nlen > 0 && for_name != 0 as *u8) {
    /* C twin: Self → (for_k == NAMED) ? 1 : 0; after got0 != for_k
     * the NAMED arm has for_k == NAMED, so this is 1. Keep the
     * ternary so the dest-buffer twin matches the C control flow. */
    if (for_k == TYPE_NAMED) {
      self_ok = 1;
    } else {
      self_ok = 0;
    }
    rc = skip_named_self_or_eq(arena, pty0, for_name, for_nlen, gnm, self_ok);
    if (rc == 0) {
      return 0;
    }
  }
  return 1;
}

/**
 * Zero dest[0..64) then copy min(for_nl, 63) bytes of the for-type spelling.
 * Matches the C twin: n = for_nl; if n > 63 then n = 63; memset; memcpy n.
 * @param for_nm *u8 — source spelling; caller already rejected null
 * @param for_nl i32 — source length; caller already rejected <= 0
 * @param for_copy *u8 — dest 64; null → 0
 * @return i32 — copied byte count (1..63)
 * PLATFORM: SHARED — file-local dest fill for P12j rewrite_self.
 */
function skip_fill_for_copy(for_nm: *u8, for_nl: i32, for_copy: *u8): i32 {
  let n: i32 = 0;
  let zi: i32 = 0;
  if (for_copy == 0 as *u8 || for_nm == 0 as *u8) {
    return 0;
  }
  n = for_nl;
  if (n > 63) {
    n = 63;
  }
  unsafe {
    zi = 0;
    while (zi < GNM_CAP) {
      for_copy[zi as usize] = 0;
      zi = zi + 1;
    }
    zi = 0;
    while (zi < n) {
      for_copy[zi as usize] = for_nm[zi as usize];
      zi = zi + 1;
    }
  }
  return n;
}

/**
 * Trait TYPE_NAMED "Self" vs impl for-type name match.
 * Wave469/470: expect "Self" aliases the named non-ptr for-type; got
 * "Self" (default hoist) aliases for; otherwise byte-eq. Pointer for
 * (`for *T`) is a mismatch this wave. Byte-eq reuses skip_named_bytes_eq
 * (dest cap 64 matches skip_tl name tables).
 * @param expect_nm *u8 — trait expected type name; may be "Self"
 * @param expect_nl i32 — length; <=0 → match (no name constraint)
 * @param got_nm *u8 — impl-side type name
 * @param got_nl i32 — length
 * @param for_nm *u8 — impl for-type name; null with for_nl>0 → mismatch in Self arms
 * @param for_nl i32 — for-type length
 * @param for_ptr i32 — 1 if for-type is *T
 * @return i32 — 1 match, 0 mismatch
 * PLATFORM: SHARED — product P12j B-minus. Seed twin stays C. Do not
 * copy into typeck. Do not merge with P6b. Do not merge with
 * concrete_implements_trait. Do not open a new P-lane.
 */
#[no_mangle]
export function xlang_skip_trait_named_eq_self_c(expect_nm: *u8, expect_nl: i32, got_nm: *u8, got_nl: i32, for_nm: *u8, for_nl: i32, for_ptr: i32): i32 {
  let exp_self: i32 = 0;
  let got_self: i32 = 0;
  if (expect_nl <= 0) {
    return 1;
  }
  exp_self = xlang_skip_name_is_self_c(expect_nm, expect_nl);
  got_self = xlang_skip_name_is_self_c(got_nm, got_nl);
  if (exp_self != 0) {
    if (for_ptr != 0 || for_nl <= 0 || for_nm == 0 as *u8) {
      return 0;
    }
    if (got_self != 0) {
      return 1;
    }
    if (got_nm == 0 as *u8) {
      return 0;
    }
    return skip_named_bytes_eq(got_nm, got_nl, for_nm, for_nl);
  }
  if (got_self != 0) {
    if (for_ptr != 0 || for_nl <= 0 || for_nm == 0 as *u8) {
      return 0;
    }
    if (expect_nm == 0 as *u8) {
      return 0;
    }
    return skip_named_bytes_eq(expect_nm, expect_nl, for_nm, for_nl);
  }
  if (got_nm == 0 as *u8) {
    return 0;
  }
  return skip_named_bytes_eq(got_nm, got_nl, expect_nm, expect_nl);
}

/**
 * Rewrite TYPE_NAMED "Self" (and PTR-to-Self) to the impl `for` named type.
 * Used when hoisting trait default methods so UFCS method_call can match
 * receiver type A against param0 type A. Soft: for_ptr / non-named for
 * leave type_ref unchanged. Language has no local u8[N]; `gnm` and
 * `for_copy` are C trampoline dests (cap 64).
 * @param arena *u8 — opaque ASTArena; null → type_ref unchanged
 * @param type_ref i32 — type to rewrite; 0 → 0
 * @param for_nm *u8 — for-type name bytes
 * @param for_nl i32 — length
 * @param for_ptr i32 — 1 if for is *T (no rewrite this wave)
 * @param gnm *u8 — dest 64 for one TYPE_NAMED spelling; C trampoline holds it
 * @param for_copy *u8 — dest 64 NUL-padded for-type copy for find_or_alloc
 * @return i32 — rewritten type_ref or original
 * PLATFORM: SHARED — product P12j B-minus. Sidecar = pipeline_type_*.
 * Do not FORCE pabi mega. Do not copy into typeck. Do not open a new P-lane.
 */
#[no_mangle]
export function xlang_skip_rewrite_self_type_ref_into_c(arena: *u8, type_ref: i32, for_nm: *u8, for_nl: i32, for_ptr: i32, gnm: *u8, for_copy: *u8): i32 {
  let k: i32 = 0;
  let gnl: i32 = 0;
  let n: i32 = 0;
  let for_named: i32 = 0;
  let elem: i32 = 0;
  let ek: i32 = 0;
  if (arena == 0 as *u8 || type_ref == 0 || for_ptr != 0 || for_nl <= 0 || for_nm == 0 as *u8) {
    return type_ref;
  }
  if (gnm == 0 as *u8 || for_copy == 0 as *u8) {
    return type_ref;
  }
  n = skip_fill_for_copy(for_nm, for_nl, for_copy);
  if (n <= 0) {
    return type_ref;
  }
  /* One unsafe for sidecar FFI. skip_fill_* helpers keep their own dest unsafe. */
  unsafe {
    k = pipeline_type_kind_ord_at(arena, type_ref);
    if (k == TYPE_PTR) {
      elem = pipeline_type_elem_ref_at(arena, type_ref);
      if (elem != 0) {
        ek = pipeline_type_kind_ord_at(arena, elem);
      } else {
        ek = 0 - 1;
      }
      if (ek != TYPE_NAMED) {
        return type_ref;
      }
      gnl = skip_fill_gnm(arena, elem, gnm);
      if (xlang_skip_name_is_self_c(gnm, gnl) == 0) {
        return type_ref;
      }
      for_named = pipeline_type_find_or_alloc_named(arena, for_copy, n);
      if (for_named == 0) {
        return type_ref;
      }
      return pipeline_type_find_or_alloc_compound(arena, TYPE_PTR, for_named, 0);
    }
    if (k != TYPE_NAMED) {
      return type_ref;
    }
    gnl = skip_fill_gnm(arena, type_ref, gnm);
    if (xlang_skip_name_is_self_c(gnm, gnl) == 0) {
      return type_ref;
    }
    return pipeline_type_find_or_alloc_named(arena, for_copy, n);
  }
}

/**
 * Register declaration-order type-param names for a function into dest
 * g_fn_gp_* tables (P12d layout). Replaces any prior row with the same
 * function name. Input `names` is a flat [n][64] snapshot (pending
 * angle-list or scan). Caps: fname 63, n ≤ 4, table 32.
 * @param fn_name *u8 — function name bytes; null / empty → 0
 * @param fn_name_len i32 — byte count; capped at 63
 * @param names *u8 — dest input rows, stride 64
 * @param lens *i32 — dest input row lengths
 * @param n i32 — number of type-param rows; n<=0 → 0
 * @param gp_fname *u8 — dest generic-fn names, stride 64, cap 32
 * @param gp_fname_len *i32 — dest generic-fn name lens, cap 32
 * @param gp_names *u8 — dest type-param names, stride 64, 32 x 4
 * @param gp_lens *i32 — dest type-param lens, 32 x 4
 * @param gp_nargs *i32 — dest type-param counts, cap 32
 * @param gp_n *i32 — in/out occupied row count
 * @return i32 — n registered, 0 on null/empty, -1 if table full
 * PLATFORM: SHARED — product P12k B-minus. C trampoline owns g_fn_gp_*.
 * Do not merge with P1c pending. Do not wrap method_on_param this wave.
 */
#[no_mangle]
export function xlang_generic_func_register_type_params_into_c(fn_name: *u8, fn_name_len: i32, names: *u8, lens: *i32, n: i32, gp_fname: *u8, gp_fname_len: *i32, gp_names: *u8, gp_lens: *i32, gp_nargs: *i32, gp_n: *i32): i32 {
  let fi: i32 = 0;
  let pi: i32 = 0;
  let slot: i32 = -1;
  let gn: i32 = 0;
  let pl: i32 = 0;
  let fname_off: usize = 0;
  let name_off: usize = 0;
  let in_off: usize = 0;
  let lens_off: usize = 0;
  if (fn_name == 0 as *u8 || fn_name_len <= 0 || names == 0 as *u8 || lens == 0 as *i32 || n <= 0) {
    return 0;
  }
  if (gp_fname == 0 as *u8 || gp_fname_len == 0 as *i32 || gp_names == 0 as *u8 || gp_lens == 0 as *i32 || gp_nargs == 0 as *i32 || gp_n == 0 as *i32) {
    return 0;
  }
  if (fn_name_len > 63) {
    fn_name_len = 63;
  }
  if (n > GENERIC_CALL_MAX_ARGS) {
    n = GENERIC_CALL_MAX_ARGS;
  }
  unsafe {
    gn = gp_n[0];
    fi = 0;
    while (fi < gn) {
      fname_off = (fi as usize) * (BOUND_NAME_CAP as usize);
      if (skip_named_bytes_eq(gp_fname + fname_off, gp_fname_len[fi], fn_name, fn_name_len) != 0) {
        slot = fi;
        break;
      }
      fi = fi + 1;
    }
    if (slot < 0) {
      if (gn >= FN_GP_MAX) {
        return -1;
      }
      slot = gn;
      gp_n[0] = gn + 1;
    }
    fname_off = (slot as usize) * (BOUND_NAME_CAP as usize);
    pl = skip_fill_for_copy(fn_name, fn_name_len, gp_fname + fname_off);
    gp_fname_len[slot] = fn_name_len;
    gp_nargs[slot] = n;
    pi = 0;
    while (pi < n) {
      in_off = (pi as usize) * (BOUND_NAME_CAP as usize);
      name_off = ((slot as usize) * (GENERIC_CALL_MAX_ARGS as usize) + pi as usize) * (BOUND_NAME_CAP as usize);
      lens_off = (slot as usize) * (GENERIC_CALL_MAX_ARGS as usize) + pi as usize;
      pl = lens[pi];
      if (pl <= 0) {
        pl = skip_fill_for_copy(names + in_off, 0, gp_names + name_off);
        gp_lens[lens_off] = 0;
      } else {
        pl = skip_fill_for_copy(names + in_off, pl, gp_names + name_off);
        gp_lens[lens_off] = pl;
      }
      pi = pi + 1;
    }
  }
  return n;
}

/**
 * Look up the declaration-order index of a type-parameter name on a
 * generic function recorded by scan or register_type_params.
 * @param fn_name *u8 — function name bytes; null / empty → -1
 * @param fn_name_len i32 — byte count; capped at 63
 * @param tp_name *u8 — type-param spelling (e.g. "T"); null / empty → -1
 * @param tp_name_len i32 — byte count; capped at 63
 * @param gp_fname *u8 — dest generic-fn names, stride 64, cap 32
 * @param gp_fname_len *i32 — dest generic-fn name lens, cap 32
 * @param gp_names *u8 — dest type-param names, stride 64, 32 x 4
 * @param gp_lens *i32 — dest type-param lens, 32 x 4
 * @param gp_nargs *i32 — dest type-param counts, cap 32
 * @param gp_n i32 — occupied row count (read-only)
 * @return i32 — 0-based type-arg index, or -1 if unknown function / name
 * PLATFORM: SHARED — product P12k B-minus. C trampoline owns g_fn_gp_*.
 * Do not merge with P1c pending. Do not wrap method_on_param this wave.
 */
#[no_mangle]
export function xlang_generic_func_type_param_index_into_c(fn_name: *u8, fn_name_len: i32, tp_name: *u8, tp_name_len: i32, gp_fname: *u8, gp_fname_len: *i32, gp_names: *u8, gp_lens: *i32, gp_nargs: *i32, gp_n: i32): i32 {
  let fi: i32 = 0;
  let pi: i32 = 0;
  let nargs: i32 = 0;
  let fname_off: usize = 0;
  let name_off: usize = 0;
  let lens_off: usize = 0;
  if (fn_name == 0 as *u8 || fn_name_len <= 0 || tp_name == 0 as *u8 || tp_name_len <= 0) {
    return -1;
  }
  if (gp_fname == 0 as *u8 || gp_fname_len == 0 as *i32 || gp_names == 0 as *u8 || gp_lens == 0 as *i32 || gp_nargs == 0 as *i32 || gp_n <= 0) {
    return -1;
  }
  if (fn_name_len > 63) {
    fn_name_len = 63;
  }
  if (tp_name_len > 63) {
    tp_name_len = 63;
  }
  unsafe {
    fi = 0;
    while (fi < gp_n) {
      fname_off = (fi as usize) * (BOUND_NAME_CAP as usize);
      if (skip_named_bytes_eq(gp_fname + fname_off, gp_fname_len[fi], fn_name, fn_name_len) != 0) {
        nargs = gp_nargs[fi];
        pi = 0;
        while (pi < nargs) {
          lens_off = (fi as usize) * (GENERIC_CALL_MAX_ARGS as usize) + pi as usize;
          name_off = lens_off * (BOUND_NAME_CAP as usize);
          if (skip_named_bytes_eq(gp_names + name_off, gp_lens[lens_off], tp_name, tp_name_len) != 0) {
            return pi;
          }
          pi = pi + 1;
        }
        return -1;
      }
      fi = fi + 1;
    }
  }
  return -1;
}

/**
 * True when some registered impl block has trait name `trait_nm` AND
 * its for-type matches `concrete_ty_ref` (P12i self_matches_for).
 * Typeck dyn-coerce (`let x: dyn Trait = concrete`) is the consumer;
 * it must not iterate the impl-seen tables itself.
 * Language has no file-local statics; dest tables are the C
 * g_xlang_skip_impl_* parallel arrays (trait stride 64, for-name
 * stride 64, cap 16). `gnm` is the C trampoline dest for one
 * TYPE_NAMED spelling inside self_matches_for.
 * @param arena *u8 — opaque ASTArena; same instance that populated impls
 * @param concrete_ty_ref i32 — RHS concrete type_ref; 0 → 0
 * @param trait_nm *u8 — trait spelling (e.g. "Clone"); null / empty → 0
 * @param trait_nlen i32 — trait name length; <=0 → 0
 * @param impl_trait *u8 — dest trait names, stride 64, cap 16
 * @param impl_trait_len *i32 — dest trait name lens, cap 16
 * @param for_kinds *i32 — dest for-type TypeKind ords, cap 16
 * @param for_is_ptr *i32 — dest for-type is-*T flags, cap 16
 * @param for_names *u8 — dest for-type names, stride 64, cap 16
 * @param for_name_lens *i32 — dest for-type name lens, cap 16
 * @param seen_n i32 — occupied impl-seen count (read-only)
 * @param gnm *u8 — dest 64 for self_matches_for; C trampoline holds it
 * @return i32 — 1 if any impl matches, 0 otherwise
 * PLATFORM: SHARED — product P12l B-minus. C trampoline owns
 * g_xlang_skip_impl_*. Do not copy into typeck. Do not merge with P6b.
 * Do not wrap method_on_param / bound_check this wave.
 */
#[no_mangle]
export function xlang_skip_impl_concrete_implements_trait_into_c(arena: *u8, concrete_ty_ref: i32, trait_nm: *u8, trait_nlen: i32, impl_trait: *u8, impl_trait_len: *i32, for_kinds: *i32, for_is_ptr: *i32, for_names: *u8, for_name_lens: *i32, seen_n: i32, gnm: *u8): i32 {
  let si: i32 = 0;
  let tlen: i32 = 0;
  let trait_off: usize = 0;
  let for_off: usize = 0;
  let n: i32 = 0;
  if (trait_nm == 0 as *u8 || trait_nlen <= 0 || concrete_ty_ref == 0) {
    return 0;
  }
  if (impl_trait == 0 as *u8 || impl_trait_len == 0 as *i32 || for_kinds == 0 as *i32 || for_is_ptr == 0 as *i32 || for_names == 0 as *u8 || for_name_lens == 0 as *i32 || gnm == 0 as *u8) {
    return 0;
  }
  if (seen_n <= 0) {
    return 0;
  }
  n = seen_n;
  if (n > SKIP_IMPL_SEEN_MAX) {
    n = SKIP_IMPL_SEEN_MAX;
  }
  unsafe {
    si = 0;
    while (si < n) {
      tlen = impl_trait_len[si];
      trait_off = (si as usize) * (GNM_CAP as usize);
      if (skip_named_bytes_eq(impl_trait + trait_off, tlen, trait_nm, trait_nlen) != 0) {
        for_off = (si as usize) * (GNM_CAP as usize);
        if (xlang_skip_impl_self_matches_for_into_c(arena, concrete_ty_ref, for_kinds[si], for_is_ptr[si], for_names + for_off, for_name_lens[si], gnm) != 0) {
          return 1;
        }
      }
      si = si + 1;
    }
  }
  return 0;
}

/**
 * Walk dest impl-seen rows for trait spelling `trait_nm` + for-name `ta`.
 * On a miss, emit the C varargs "does not impl" diagnostic.
 * Extracted so the P12m export's check_block stays under typeck's
 * statement budget (XT001).
 * @param impl_trait *u8 — dest impl trait names, stride 64
 * @param impl_trait_len *i32 — dest impl trait name lens
 * @param for_names *u8 — dest for-type names, stride 64
 * @param for_name_lens *i32 — dest for-type name lens
 * @param seen_n i32 — occupied impl-seen count (already capped)
 * @param trait_nm *u8 — bound trait spelling
 * @param trait_nlen i32 — bound trait length
 * @param ta *u8 — concrete type-arg spelling
 * @param ta_len i32 — concrete type-arg length
 * @param line i32 — 1-based diagnostic line
 * @param col i32 — 1-based diagnostic column
 * @return i32 — 1 found, 0 miss (diag emitted)
 * PLATFORM: SHARED — helper of P12m dest-buffer.
 */
function skip_impl_seen_match_or_diag(impl_trait: *u8, impl_trait_len: *i32, for_names: *u8, for_name_lens: *i32, seen_n: i32, trait_nm: *u8, trait_nlen: i32, ta: *u8, ta_len: i32, line: i32, col: i32): i32 {
  let si: i32 = 0;
  let impl_ok: i32 = 0;
  let trait_off: usize = 0;
  let for_off: usize = 0;
  if (impl_trait == 0 as *u8) {
    return 0;
  }
  if (impl_trait_len == 0 as *i32) {
    return 0;
  }
  if (for_names == 0 as *u8) {
    return 0;
  }
  if (for_name_lens == 0 as *i32) {
    return 0;
  }
  if (trait_nm == 0 as *u8) {
    return 0;
  }
  if (ta == 0 as *u8) {
    return 0;
  }
  unsafe {
    si = 0;
    while (si < seen_n) {
      trait_off = (si as usize) * (GNM_CAP as usize);
      for_off = (si as usize) * (GNM_CAP as usize);
      if (skip_named_bytes_eq(impl_trait + trait_off, impl_trait_len[si], trait_nm, trait_nlen) != 0) {
        if (skip_named_bytes_eq(for_names + for_off, for_name_lens[si], ta, ta_len) != 0) {
          impl_ok = 1;
        }
      }
      si = si + 1;
    }
  }
  if (impl_ok == 0) {
    impl_ok = xlang_generic_bound_diag_not_impl_c(ta, ta_len, trait_nm, trait_nlen, line, col);
    impl_ok = 0;
  }
  return impl_ok;
}

/**
 * Verify every captured bound on `fn_name` against the impl-seen
 * registry for the concrete type-arg names at this call / type site.
 * Language has no file-local statics; dest tables are the C
 * g_fn_bound_* (stride 64, cap 16) and g_xlang_skip_impl_*
 * (trait / for-name stride 64, cap 16) parallel arrays. Type-arg
 * rows are stride 64 (C `type_args[][64]`). Phantom type-param
 * names (`Foo<T>` where T is a type-param of Foo) skip the impl
 * check via P12k type_param_index. Diagnostics go through the C
 * varargs trampolines (language has no printf varargs).
 * @param fn_name *u8 — callee spelling; null / empty → 0
 * @param fn_name_len i32 — byte count; capped at 63
 * @param type_args *u8 — concrete type-name rows, stride 64; null only legal when nargs==0
 * @param type_arg_lens *i32 — per-slot name lengths; null only legal when nargs==0
 * @param nargs i32 — type-arg slot count
 * @param line i32 — 1-based diagnostic line
 * @param col i32 — 1-based diagnostic column
 * @param bound_name *u8 — dest generic-fn names, stride 64, cap 16
 * @param bound_name_len *i32 — dest generic-fn name lens, cap 16
 * @param bound_trait *u8 — dest bound-trait names, stride 64, cap 16
 * @param bound_trait_len *i32 — dest bound-trait name lens, cap 16
 * @param bound_pos *i32 — dest type-param positions, cap 16
 * @param bound_n i32 — occupied bound-row count (read-only)
 * @param impl_trait *u8 — dest impl trait names, stride 64, cap 16
 * @param impl_trait_len *i32 — dest impl trait name lens, cap 16
 * @param for_names *u8 — dest impl for-type names, stride 64, cap 16
 * @param for_name_lens *i32 — dest impl for-type name lens, cap 16
 * @param seen_n i32 — occupied impl-seen count (read-only)
 * @return i32 — 0 all bounds satisfied (or nothing to check); -1 ≥1 violation
 * PLATFORM: SHARED — product P12m B-minus. C trampoline owns
 * g_fn_bound_* and g_xlang_skip_impl_*. Do not wrap method_on_param.
 * bound_check_c is P12o. Do not merge with fat trait-reg accessors.
 * Do not copy into typeck (typeck already calls the historical `_c`).
 */
#[no_mangle]
export function xlang_generic_bound_check_type_args_into_c(fn_name: *u8, fn_name_len: i32, type_args: *u8, type_arg_lens: *i32, nargs: i32, line: i32, col: i32, bound_name: *u8, bound_name_len: *i32, bound_trait: *u8, bound_trait_len: *i32, bound_pos: *i32, bound_n: i32, impl_trait: *u8, impl_trait_len: *i32, for_names: *u8, for_name_lens: *i32, seen_n: i32): i32 {
  let bi: i32 = 0;
  let si: i32 = 0;
  let n: i32 = 0;
  let sn: i32 = 0;
  let pos: i32 = 0;
  let ta_len: i32 = 0;
  let impl_ok: i32 = 0;
  let skip: i32 = 0;
  let violated: i32 = 0;
  let name_off: usize = 0;
  let trait_off_b: usize = 0;
  let trait_off_s: usize = 0;
  let for_off: usize = 0;
  let ta: *u8 = 0 as *u8;
  if (fn_name == 0 as *u8) {
    return 0;
  }
  if (fn_name_len <= 0) {
    return 0;
  }
  if (bound_name == 0 as *u8) {
    return 0;
  }
  if (bound_name_len == 0 as *i32) {
    return 0;
  }
  if (bound_trait == 0 as *u8) {
    return 0;
  }
  if (bound_trait_len == 0 as *i32) {
    return 0;
  }
  if (bound_pos == 0 as *i32) {
    return 0;
  }
  if (impl_trait == 0 as *u8) {
    return 0;
  }
  if (impl_trait_len == 0 as *i32) {
    return 0;
  }
  if (for_names == 0 as *u8) {
    return 0;
  }
  if (for_name_lens == 0 as *i32) {
    return 0;
  }
  if (bound_n <= 0) {
    return 0;
  }
  if (fn_name_len > 63) {
    fn_name_len = 63;
  }
  n = bound_n;
  if (n > FN_BOUND_MAX) {
    n = FN_BOUND_MAX;
  }
  sn = seen_n;
  if (sn < 0) {
    sn = 0;
  }
  if (sn > SKIP_IMPL_SEEN_MAX) {
    sn = SKIP_IMPL_SEEN_MAX;
  }
  unsafe {
    bi = 0;
    while (bi < n) {
      skip = 0;
      name_off = (bi as usize) * (BOUND_NAME_CAP as usize);
      if (skip_named_bytes_eq(bound_name + name_off, bound_name_len[bi], fn_name, fn_name_len) == 0) {
        skip = 1;
      }
      pos = 0;
      ta_len = 0;
      ta = fn_name;
      if (skip == 0) {
        pos = bound_pos[bi];
        if (nargs <= 0) {
          skip = 2;
        }
      }
      if (skip == 0) {
        if (type_args == 0 as *u8) {
          skip = 2;
        }
      }
      if (skip == 0) {
        if (type_arg_lens == 0 as *i32) {
          skip = 2;
        }
      }
      if (skip == 0) {
        if (pos < 0) {
          skip = 2;
        }
      }
      if (skip == 0) {
        if (pos >= nargs) {
          skip = 2;
        }
      }
      if (skip == 2) {
        xlang_generic_bound_diag_need_type_args_c(fn_name, fn_name_len, line, col);
        violated = -1;
        skip = 1;
      }
      if (skip == 0) {
        ta = type_args + (pos as usize) * (BOUND_NAME_CAP as usize);
        ta_len = type_arg_lens[pos];
        if (ta_len <= 0) {
          xlang_generic_bound_diag_need_type_args_c(fn_name, fn_name_len, line, col);
          violated = -1;
          skip = 1;
        }
      }
      if (skip == 0) {
        if (xlang_generic_func_type_param_index_c(fn_name, fn_name_len, ta, ta_len) >= 0) {
          skip = 1;
        }
      }
      if (skip == 0) {
        trait_off_b = (bi as usize) * (BOUND_NAME_CAP as usize);
        impl_ok = skip_impl_seen_match_or_diag(impl_trait, impl_trait_len, for_names, for_name_lens, sn, bound_trait + trait_off_b, bound_trait_len[bi], ta, ta_len, line, col);
        if (impl_ok == 0) {
          violated = -1;
        }
      }
      bi = bi + 1;
    }
  }
  return violated;
}

/**
 * Copy min(nlen, 64) bytes from a dest-table name row into out64.
 * Does not zero the rest of out64 (matches the F4 C twins). Returns
 * nlen (the stored length, which may exceed 64). nlen<=0 or null
 * pointers → 0 and no write.
 * @param src *u8 — dest-table row; null → 0
 * @param nlen i32 — stored length; <=0 → 0
 * @param out64 *u8 — caller dest, capacity >= 64; null → 0
 * @return i32 — nlen on copy, 0 on reject
 * PLATFORM: SHARED — file-local helper for P12n; not a second P1b copy_slice.
 */
function skip_copy_row64(src: *u8, nlen: i32, out64: *u8): i32 {
  let ci: i32 = 0;
  if (src == 0 as *u8) {
    return 0;
  }
  if (out64 == 0 as *u8) {
    return 0;
  }
  if (nlen <= 0) {
    return 0;
  }
  unsafe {
    ci = 0;
    while (ci < nlen && ci < GNM_CAP) {
      out64[ci as usize] = src[ci as usize];
      ci = ci + 1;
    }
  }
  return nlen;
}

/**
 * Occupied impl-seen count. Language has no file-local statics; dest
 * is the C `g_xlang_skip_impl_seen_n` scalar passed by the trampoline.
 * @param seen_n i32 — occupied impl-seen count (read-only)
 * @return i32 — seen_n unchanged (empty registry → 0)
 * PLATFORM: SHARED — product P12n B-minus. C trampoline owns the scalar.
 * Do not merge with concrete_implements. Do not wrap method_on_param.
 */
#[no_mangle]
export function xlang_skip_impl_seen_count_into_c(seen_n: i32): i32 {
  return seen_n;
}

/**
 * Copy the trait name of impl block `si` into `out64` (capacity >= 64).
 * Language has no file-local statics; dest tables are the C
 * g_xlang_skip_impl_trait / _len (stride 64, cap 16). Does not zero
 * the rest of out64. Returns the stored length (may exceed 64; copy
 * truncates at 64 so the caller can detect truncation).
 * @param si i32 — impl index, 0..seen_n-1
 * @param out64 *u8 — dest 64; null → 0
 * @param impl_trait *u8 — dest impl trait names, stride 64, cap 16
 * @param impl_trait_len *i32 — dest impl trait name lens, cap 16
 * @param seen_n i32 — occupied impl-seen count (read-only)
 * @return i32 — stored trait name length, or 0 on invalid si / empty name
 * PLATFORM: SHARED — product P12n B-minus. Historical public name
 * `xlang_skip_impl_trait_name_into_c` stays the C trampoline.
 * Do not merge with concrete_implements. Do not wrap method_on_param.
 */
#[no_mangle]
export function xlang_skip_impl_trait_name_dest_into_c(si: i32, out64: *u8, impl_trait: *u8, impl_trait_len: *i32, seen_n: i32): i32 {
  let nlen: i32 = 0;
  let off: usize = 0;
  if (out64 == 0 as *u8) {
    return 0;
  }
  if (impl_trait == 0 as *u8) {
    return 0;
  }
  if (impl_trait_len == 0 as *i32) {
    return 0;
  }
  if (si < 0) {
    return 0;
  }
  if (si >= seen_n) {
    return 0;
  }
  if (si >= SKIP_IMPL_SEEN_MAX) {
    return 0;
  }
  unsafe {
    nlen = impl_trait_len[si];
    if (nlen <= 0) {
      return 0;
    }
    off = (si as usize) * (GNM_CAP as usize);
    nlen = skip_copy_row64(impl_trait + off, nlen, out64);
  }
  return nlen;
}

/**
 * Read the for-type info of impl block `si`. All out-params are
 * written on success (returns 1) and left untouched on failure
 * (returns 0). Language has no file-local statics; dest tables are
 * the C g_xlang_skip_impl_for_* parallel arrays (name stride 64,
 * cap 16). Empty for-type names still succeed (nlen 0, no copy).
 * @param si i32 — impl index, 0..seen_n-1
 * @param out_kind *i32 — dest for-type kind ord (NAMED=8); null → 0
 * @param out_is_ptr *i32 — dest 1 if for-type is *T; null → 0
 * @param out_name64 *u8 — dest for-type name bytes, capacity >= 64; null → 0
 * @param out_nlen_ptr *i32 — dest for-type name length; null → 0
 * @param for_kinds *i32 — dest for-type kinds, cap 16
 * @param for_is_ptr *i32 — dest for-type ptr flags, cap 16
 * @param for_names *u8 — dest for-type names, stride 64, cap 16
 * @param for_name_lens *i32 — dest for-type name lens, cap 16
 * @param seen_n i32 — occupied impl-seen count (read-only)
 * @return i32 — 1 on success, 0 if si out of range or dest null
 * PLATFORM: SHARED — product P12n B-minus. Historical public name
 * `xlang_skip_impl_for_type_into_c` stays the C trampoline.
 * Do not merge with concrete_implements. Do not wrap method_on_param.
 */
#[no_mangle]
export function xlang_skip_impl_for_type_dest_into_c(si: i32, out_kind: *i32, out_is_ptr: *i32, out_name64: *u8, out_nlen_ptr: *i32, for_kinds: *i32, for_is_ptr: *i32, for_names: *u8, for_name_lens: *i32, seen_n: i32): i32 {
  let nlen: i32 = 0;
  let off: usize = 0;
  if (si < 0) {
    return 0;
  }
  if (si >= seen_n) {
    return 0;
  }
  if (si >= SKIP_IMPL_SEEN_MAX) {
    return 0;
  }
  if (out_kind == 0 as *i32) {
    return 0;
  }
  if (out_is_ptr == 0 as *i32) {
    return 0;
  }
  if (out_name64 == 0 as *u8) {
    return 0;
  }
  if (out_nlen_ptr == 0 as *i32) {
    return 0;
  }
  if (for_kinds == 0 as *i32) {
    return 0;
  }
  if (for_is_ptr == 0 as *i32) {
    return 0;
  }
  if (for_names == 0 as *u8) {
    return 0;
  }
  if (for_name_lens == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_kind[0] = for_kinds[si];
    out_is_ptr[0] = for_is_ptr[si];
    nlen = for_name_lens[si];
    out_nlen_ptr[0] = nlen;
    off = (si as usize) * (GNM_CAP as usize);
    skip_copy_row64(for_names + off, nlen, out_name64);
  }
  return 1;
}

/**
 * Verify every captured generic call / type-position site against
 * decl bounds. Language has no file-local statics; dest tables are
 * the C g_call_* parallel arrays P12d scan already writes (callee
 * stride 64, typeargs 32x4x64, args cap 4, call cap 32). Each site
 * delegates to the historical public
 * `xlang_generic_bound_check_type_args_c` (P12m trampoline injects
 * g_fn_bound_* + g_xlang_skip_impl_*). Zero algorithm besides the
 * iteration. Empty registry (call_n<=0) → 0.
 * @param callee *u8 — dest callee names, stride 64, cap 32
 * @param callee_len *i32 — dest callee name lens, cap 32
 * @param typeargs *u8 — dest type-arg rows, 32 x 4 x 64
 * @param typearg_lens *i32 — dest type-arg lens, 32 x 4
 * @param nargs *i32 — dest per-site type-arg counts, cap 32
 * @param line *i32 — dest 1-based diagnostic lines, cap 32
 * @param col *i32 — dest 1-based diagnostic columns, cap 32
 * @param call_n i32 — occupied call-site count (read-only)
 * @return i32 — 0 all sites satisfied (or nothing to check); -1 ≥1 violation
 * PLATFORM: SHARED — product P12o B-minus. C trampoline owns g_call_*.
 * Do not merge with bound_check_type_args (iterator vs per-site).
 * Do not wrap method_on_param. Do not dest-buffer F3. Do not copy
 * into typeck (typeck already calls type_args `_c`).
 */
#[no_mangle]
export function xlang_generic_bound_check_into_c(callee: *u8, callee_len: *i32, typeargs: *u8, typearg_lens: *i32, nargs: *i32, line: *i32, col: *i32, call_n: i32): i32 {
  let ci: i32 = 0;
  let n: i32 = 0;
  let violated: i32 = 0;
  let callee_off: usize = 0;
  let args_off: usize = 0;
  let lens_off: usize = 0;
  let lens_row: *i32 = 0 as *i32;
  if (callee == 0 as *u8) {
    return 0;
  }
  if (callee_len == 0 as *i32) {
    return 0;
  }
  if (typeargs == 0 as *u8) {
    return 0;
  }
  if (typearg_lens == 0 as *i32) {
    return 0;
  }
  if (nargs == 0 as *i32) {
    return 0;
  }
  if (line == 0 as *i32) {
    return 0;
  }
  if (col == 0 as *i32) {
    return 0;
  }
  if (call_n <= 0) {
    return 0;
  }
  n = call_n;
  if (n > GENERIC_CALL_MAX) {
    n = GENERIC_CALL_MAX;
  }
  unsafe {
    ci = 0;
    while (ci < n) {
      callee_off = (ci as usize) * (BOUND_NAME_CAP as usize);
      args_off = (ci as usize) * (GENERIC_CALL_MAX_ARGS as usize) * (BOUND_NAME_CAP as usize);
      lens_off = (ci as usize) * (GENERIC_CALL_MAX_ARGS as usize);
      lens_row = typearg_lens + lens_off;
      if (xlang_generic_bound_check_type_args_c(callee + callee_off, callee_len[ci], typeargs + args_off, lens_row, nargs[ci], line[ci], col[ci]) != 0) {
        violated = 0 - 1;
      }
      ci = ci + 1;
    }
  }
  return violated;
}

/**
 * Find the trait-registry row for `trait_nm` by linear name scan.
 * Language has no file-local statics / no fat-struct field access;
 * dest is the C `g_xlang_skip_trait_reg[]` table as a byte image
 * (stride = sizeof(ent), cap 16). Name bytes live at P12G_OFF_NAME
 * (64) and name_len at P12G_OFF_NAME_LEN. Empty names never match
 * (same as the C twin).
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param table *u8 — dest trait-reg ent image; null → -1
 * @param stride i32 — bytes per ent (C sizeof); <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — row 0..n-1, or -1 if not found / rejected
 * PLATFORM: SHARED — product P12p B-minus. C trampoline owns the table.
 * Do not wrap method_on_param. Do not dest-buffer dest-extras
 * elem_array_dim as extra. Do not copy into typeck / codegen
 * (they already call historical `_c`).
 */
#[no_mangle]
export function xlang_skip_trait_find_reg_into_c(trait_nm: *u8, trait_nlen: i32, table: *u8, stride: i32, n: i32): i32 {
  let ti: i32 = 0;
  let n_cap: i32 = 0;
  let tlen: i32 = 0;
  let ent: *u8 = 0 as *u8;
  let tname: *u8 = 0 as *u8;
  if (trait_nm == 0 as *u8) {
    return 0 - 1;
  }
  if (trait_nlen <= 0) {
    return 0 - 1;
  }
  if (table == 0 as *u8) {
    return 0 - 1;
  }
  if (stride <= 0) {
    return 0 - 1;
  }
  if (n <= 0) {
    return 0 - 1;
  }
  n_cap = n;
  if (n_cap > SKIP_TRAIT_REG_MAX) {
    n_cap = SKIP_TRAIT_REG_MAX;
  }
  unsafe {
    ti = 0;
    while (ti < n_cap) {
      ent = table + ((ti * stride) as usize);
      tlen = p12g_load_i32(ent, P12G_OFF_NAME_LEN);
      tname = ent + (P12G_OFF_NAME as usize);
      if (tlen > 0) {
        if (skip_named_bytes_eq(tname, tlen, trait_nm, trait_nlen) != 0) {
          return ti;
        }
      }
      ti = ti + 1;
    }
  }
  return 0 - 1;
}

/**
 * Return the declared method count (= vtable slot count) for a trait.
 * Empty / missing trait → 0 (same as the C twin: missing and empty
 * both return 0, so this is not the "is registered" predicate).
 * @param trait_nm *u8 — trait name bytes; null → 0
 * @param trait_nlen i32 — byte count; must be > 0
 * @param table *u8 — dest trait-reg ent image; null → 0
 * @param stride i32 — bytes per ent; <=0 → 0
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — method count (>=0)
 * PLATFORM: SHARED — product P12p B-minus. C trampoline owns the table.
 * Do not wrap method_on_param. Do not dest-buffer remaining F3 getters.
 */
#[no_mangle]
export function xlang_skip_trait_method_count_into_c(trait_nm: *u8, trait_nlen: i32, table: *u8, stride: i32, n: i32): i32 {
  let ti: i32 = 0;
  let n_meth: i32 = 0;
  let ent: *u8 = 0 as *u8;
  ti = xlang_skip_trait_find_reg_into_c(trait_nm, trait_nlen, table, stride, n);
  if (ti < 0) {
    return 0;
  }
  if (table == 0 as *u8) {
    return 0;
  }
  if (stride <= 0) {
    return 0;
  }
  unsafe {
    ent = table + ((ti * stride) as usize);
    n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  }
  if (n_meth > 0) {
    return n_meth;
  }
  return 0;
}

/**
 * Resolve a method name to its vtable slot (declaration order, 0-based).
 * Empty method names never match. Missing trait / missing method → -1.
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — trait name length; must be > 0
 * @param method_nm *u8 — method name bytes; null → -1
 * @param method_nlen i32 — method name length; must be > 0
 * @param table *u8 — dest trait-reg ent image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — slot >= 0, or -1 if trait/method absent
 * PLATFORM: SHARED — product P12p B-minus. C trampoline owns the table.
 * Do not wrap method_on_param. Do not dest-buffer remaining F3 getters.
 */
#[no_mangle]
export function xlang_skip_trait_method_slot_into_c(trait_nm: *u8, trait_nlen: i32, method_nm: *u8, method_nlen: i32, table: *u8, stride: i32, n: i32): i32 {
  let ti: i32 = 0;
  let mi: i32 = 0;
  let n_meth: i32 = 0;
  let mlen: i32 = 0;
  let ent: *u8 = 0 as *u8;
  let mname: *u8 = 0 as *u8;
  if (method_nm == 0 as *u8) {
    return 0 - 1;
  }
  if (method_nlen <= 0) {
    return 0 - 1;
  }
  ti = xlang_skip_trait_find_reg_into_c(trait_nm, trait_nlen, table, stride, n);
  if (ti < 0) {
    return 0 - 1;
  }
  if (table == 0 as *u8) {
    return 0 - 1;
  }
  if (stride <= 0) {
    return 0 - 1;
  }
  unsafe {
    ent = table + ((ti * stride) as usize);
    n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  }
  if (n_meth < 0) {
    n_meth = 0;
  }
  if (n_meth > P12G_METH_MAX) {
    n_meth = P12G_METH_MAX;
  }
  unsafe {
    mi = 0;
    while (mi < n_meth) {
      mlen = p12g_load_i32(ent, P12G_OFF_METHOD_LENS + mi * 4);
      mname = ent + ((P12G_OFF_METHODS + mi * P12G_METHOD_NAME_ROW) as usize);
      if (mlen > 0) {
        if (skip_named_bytes_eq(mname, mlen, method_nm, method_nlen) != 0) {
          return mi;
        }
      }
      mi = mi + 1;
    }
  }
  return 0 - 1;
}

/**
 * Copy the method name at vtable `slot` into `out64` (capacity >= 64).
 * Historical public name already ends `_into_c`, so this dest body is
 * `_dest_into_c`. Rejects stored nlen>64 (does not copy; returns 0) —
 * do not reuse skip_copy_row64 (that helper returns stored nlen even
 * when it exceeds 64). Does not zero the rest of out64.
 * @param trait_nm *u8 — trait name bytes; null → 0
 * @param trait_nlen i32 — trait name length; must be > 0
 * @param slot i32 — vtable slot; <0 → 0
 * @param out64 *u8 — dest 64; null → 0
 * @param table *u8 — dest trait-reg ent image; null → 0
 * @param stride i32 — bytes per ent; <=0 → 0
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — method name length (>0 on success), 0 if trait/slot invalid
 * PLATFORM: SHARED — product P12p B-minus. C trampoline owns the table.
 * Do not wrap method_on_param. Do not dest-buffer remaining F3 getters.
 */
#[no_mangle]
export function xlang_skip_trait_method_name_dest_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, out64: *u8, table: *u8, stride: i32, n: i32): i32 {
  let ti: i32 = 0;
  let mi: i32 = 0;
  let n_meth: i32 = 0;
  let mlen: i32 = 0;
  let ent: *u8 = 0 as *u8;
  let mname: *u8 = 0 as *u8;
  if (out64 == 0 as *u8) {
    return 0;
  }
  if (slot < 0) {
    return 0;
  }
  ti = xlang_skip_trait_find_reg_into_c(trait_nm, trait_nlen, table, stride, n);
  if (ti < 0) {
    return 0;
  }
  if (table == 0 as *u8) {
    return 0;
  }
  if (stride <= 0) {
    return 0;
  }
  unsafe {
    ent = table + ((ti * stride) as usize);
    n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  }
  if (slot >= n_meth) {
    return 0;
  }
  unsafe {
    mlen = p12g_load_i32(ent, P12G_OFF_METHOD_LENS + slot * 4);
    mname = ent + ((P12G_OFF_METHODS + slot * P12G_METHOD_NAME_ROW) as usize);
  }
  if (mlen <= 0) {
    return 0;
  }
  if (mlen > GNM_CAP) {
    return 0;
  }
  unsafe {
    mi = 0;
    while (mi < mlen) {
      out64[mi as usize] = mname[mi as usize];
      mi = mi + 1;
    }
  }
  return mlen;
}

/**
 * Resolve `trait_nm` to the fat-ent byte image, or null.
 * Used by P12q simple F3 getters so each export does not re-copy
 * find_reg + stride arithmetic.
 * @param trait_nm *u8 — trait name bytes; null → null
 * @param trait_nlen i32 — byte count; must be > 0
 * @param table *u8 — dest trait-reg image; null → null
 * @param stride i32 — bytes per ent; <=0 → null
 * @param n i32 — occupied registry count (read-only)
 * @return *u8 — ent at table+ti*stride, or null if missing / rejected
 * PLATFORM: SHARED — P12q helper. C trampoline owns the table.
 */
function skip_trait_ent_at(trait_nm: *u8, trait_nlen: i32, table: *u8, stride: i32, n: i32): *u8 {
  let ti: i32 = 0;
  let ent: *u8 = 0 as *u8;
  ti = xlang_skip_trait_find_reg_into_c(trait_nm, trait_nlen, table, stride, n);
  if (ti < 0) {
    return 0 as *u8;
  }
  if (table == 0 as *u8) {
    return 0 as *u8;
  }
  if (stride <= 0) {
    return 0 as *u8;
  }
  unsafe {
    ent = table + ((ti * stride) as usize);
  }
  return ent;
}

/**
 * True when 0 <= slot < num_methods on the fat-ent image.
 * Matches the C getter twins (no extra METH_MAX cap; writers already
 * check < MAX).
 * @param ent *u8 — fat-ent image; null → 0
 * @param slot i32 — vtable slot; <0 → 0
 * @return i32 — 1 in range, 0 otherwise
 * PLATFORM: SHARED — P12q helper.
 */
function skip_trait_slot_in_range(ent: *u8, slot: i32): i32 {
  let n_meth: i32 = 0;
  if (ent == 0 as *u8) {
    return 0;
  }
  if (slot < 0) {
    return 0;
  }
  n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  if (slot >= n_meth) {
    return 0;
  }
  return 1;
}

/**
 * Load a slot-indexed i32 from the fat trait-reg image.
 * One body for ret_kind / ret_elem_kind / ret_array_size /
 * ret_array_ndims / ret_elem_elem_kind / ret_elem_array_ndims.
 * C trampoline passes offsetof of the i32[METH_MAX] field.
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → -1
 * @param table *u8 — dest trait-reg image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @param field_off i32 — offsetof of the i32[METH_MAX] field; <0 → -1
 * @return i32 — stored value, or -1 if trait/slot invalid
 * PLATFORM: SHARED — product P12q B-minus. C trampoline owns the table.
 * Do not wrap method_on_param. Do not dest-buffer dest-extras
 * elem_array_dim as extra. Do not copy into typeck / codegen.
 */
#[no_mangle]
export function xlang_skip_trait_method_slot_i32_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, table: *u8, stride: i32, n: i32, field_off: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let v: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  if (field_off < 0) {
    return 0 - 1;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0 - 1;
  }
  v = p12g_load_i32(ent, field_off + slot * 4);
  return v;
}

/**
 * Load a [slot][param_ix] i32 from the fat trait-reg image.
 * One body for param_kind / param_elem_kind / param_array_ndims /
 * param_elem_elem_kind / param_elem_array_ndims. C trampoline
 * passes offsetof of the i32[METH_MAX][PARAM_MAX] field and the
 * per-slot row stride (PARAM_MAX * sizeof(i32) = 32).
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → -1
 * @param param_ix i32 — formal index including self; <0 or >= PARAM_MAX → -1
 * @param table *u8 — dest trait-reg image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @param field_off i32 — offsetof of the 2D i32 field; <0 → -1
 * @param row_stride i32 — bytes per slot row; <=0 → -1
 * @return i32 — stored value, or -1 if trait/slot/param invalid
 * PLATFORM: SHARED — product P12q B-minus. C trampoline owns the table.
 * Do not wrap method_on_param. Do not dest-buffer dest-extras
 * elem_array_dim as extra.
 */
#[no_mangle]
export function xlang_skip_trait_method_param_i32_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, param_ix: i32, table: *u8, stride: i32, n: i32, field_off: i32, row_stride: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let v: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  if (param_ix < 0) {
    return 0 - 1;
  }
  if (param_ix >= P12G_PARAM_MAX) {
    return 0 - 1;
  }
  if (field_off < 0) {
    return 0 - 1;
  }
  if (row_stride <= 0) {
    return 0 - 1;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0 - 1;
  }
  v = p12g_load_i32(ent, field_off + slot * row_stride + param_ix * 4);
  return v;
}

/**
 * Return one dim of a trait-method `[K][N]…T` return.
 * Simple getter: dim_ix >= ndims → -1. dest-extras wrap soup lives
 * in ret_elem_array_dim (stays C).
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → -1
 * @param dim_ix i32 — dimension index (0 = outer); <0 or >= DIM_MAX → -1
 * @param table *u8 — dest trait-reg image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — N > 0, or -1 if trait/slot/dim invalid
 * PLATFORM: SHARED — product P12q B-minus. C trampoline owns the table.
 */
#[no_mangle]
export function xlang_skip_trait_method_ret_array_dim_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, dim_ix: i32, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let nd: i32 = 0;
  let v: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  if (dim_ix < 0) {
    return 0 - 1;
  }
  if (dim_ix >= P12G_DIM_MAX) {
    return 0 - 1;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0 - 1;
  }
  nd = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ARRAY_NDIMS + slot * 4);
  if (dim_ix >= nd) {
    return 0 - 1;
  }
  v = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ARRAY_DIMS + slot * P12G_RET_DIMS_ROW + dim_ix * 4);
  return v;
}

/**
 * Return one dim of a trait-method `[K][N]…T` formal.
 * Simple getter: dim_ix >= ndims → -1. dest-extras wrap soup lives
 * in param_elem_array_dim (stays C). Extra i of a METHOD_CALL maps
 * to param_ix = i+1 (param 0 is self).
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → -1
 * @param param_ix i32 — formal index including self; <0 or >= PARAM_MAX → -1
 * @param dim_ix i32 — dimension index (0 = outer); <0 or >= DIM_MAX → -1
 * @param table *u8 — dest trait-reg image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — N > 0, or -1 if trait/slot/param/dim invalid
 * PLATFORM: SHARED — product P12q B-minus. C trampoline owns the table.
 */
#[no_mangle]
export function xlang_skip_trait_method_param_array_dim_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, param_ix: i32, dim_ix: i32, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let nd: i32 = 0;
  let v: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  if (param_ix < 0) {
    return 0 - 1;
  }
  if (param_ix >= P12G_PARAM_MAX) {
    return 0 - 1;
  }
  if (dim_ix < 0) {
    return 0 - 1;
  }
  if (dim_ix >= P12G_DIM_MAX) {
    return 0 - 1;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0 - 1;
  }
  nd = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + slot * P12G_PARAM_LENS_ROW + param_ix * 4);
  if (dim_ix >= nd) {
    return 0 - 1;
  }
  v = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + slot * P12G_PARAM_DIMS_ROW + param_ix * P12G_PARAM_DIMS_ROW_INNER + dim_ix * 4);
  return v;
}

/**
 * Copy the TYPE_NAMED spelling of a trait-method return into out64.
 * Historical public name already ends `_into_c`, so this dest body is
 * `_dest_into_c`. Rejects stored nlen>64 (does not copy; returns 0) —
 * do not reuse skip_copy_row64. Does not zero the rest of out64.
 * @param trait_nm *u8 — trait name bytes; null → 0
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → 0
 * @param out64 *u8 — dest 64; null → 0
 * @param table *u8 — dest trait-reg image; null → 0
 * @param stride i32 — bytes per ent; <=0 → 0
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — name length (>0 on success), 0 if trait/slot invalid or unset
 * PLATFORM: SHARED — product P12q B-minus. C trampoline owns the table.
 */
#[no_mangle]
export function xlang_skip_trait_method_ret_name_dest_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, out64: *u8, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  let i: i32 = 0;
  let src: *u8 = 0 as *u8;
  if (out64 == 0 as *u8) {
    return 0;
  }
  if (slot < 0) {
    return 0;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0;
  }
  nlen = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + slot * 4);
  if (nlen <= 0) {
    return 0;
  }
  if (nlen > GNM_CAP) {
    return 0;
  }
  unsafe {
    src = ent + ((P12G_OFF_METHOD_RET_NAMES + slot * P12G_RET_NAME_ROW) as usize);
    i = 0;
    while (i < nlen) {
      out64[i as usize] = src[i as usize];
      i = i + 1;
    }
  }
  return nlen;
}

/**
 * Copy the TYPE_NAMED spelling of one trait-method formal into out64.
 * Historical public name already ends `_into_c`, so this dest body is
 * `_dest_into_c`. Rejects stored nlen>64 (does not copy; returns 0).
 * Extra i of a METHOD_CALL maps to param_ix = i+1 (param 0 is self).
 * @param trait_nm *u8 — trait name bytes; null → 0
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → 0
 * @param param_ix i32 — formal index including self; <0 or >= PARAM_MAX → 0
 * @param out64 *u8 — dest 64; null → 0
 * @param table *u8 — dest trait-reg image; null → 0
 * @param stride i32 — bytes per ent; <=0 → 0
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — name length (>0 on success), 0 if trait/slot/param invalid or unset
 * PLATFORM: SHARED — product P12q B-minus. C trampoline owns the table.
 */
#[no_mangle]
export function xlang_skip_trait_method_param_name_dest_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, param_ix: i32, out64: *u8, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  let i: i32 = 0;
  let src: *u8 = 0 as *u8;
  if (out64 == 0 as *u8) {
    return 0;
  }
  if (slot < 0) {
    return 0;
  }
  if (param_ix < 0) {
    return 0;
  }
  if (param_ix >= P12G_PARAM_MAX) {
    return 0;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0;
  }
  nlen = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + slot * P12G_PARAM_LENS_ROW + param_ix * 4);
  if (nlen <= 0) {
    return 0;
  }
  if (nlen > GNM_CAP) {
    return 0;
  }
  unsafe {
    src = ent + ((P12G_OFF_METHOD_PARAM_NAMES + slot * P12G_PARAM_NAME_ROW + param_ix * P12G_PARAM_NAME_INNER) as usize);
    i = 0;
    while (i < nlen) {
      out64[i as usize] = src[i as usize];
      i = i + 1;
    }
  }
  return nlen;
}

/**
 * dest-extras wrap-soup dim lookup over one dims row.
 * Shared by ret_elem_array_dim and param_elem_array_dim (G.7: one
 * body, not two copies of the ndims==-2 / ndims==0 / dim_ix>=ndims
 * unused-slot rules).
 * @param ent *u8 — fat-ent image; null → -1
 * @param dims_base i32 — byte offset of dims[0] for this slot(/param)
 * @param nd i32 — stored elem_array_ndims (may be -2 / 0 / >0)
 * @param dim_ix i32 — requested dim; <0 or >= DIM_MAX → -1
 * @return i32 — N > 0, extra wrap count, or -1 if unused / invalid
 * PLATFORM: SHARED — P12r helper. Matches C twins in skip_tl.inc.
 */
function skip_trait_elem_array_dim_at(ent: *u8, dims_base: i32, nd: i32, dim_ix: i32): i32 {
  let extra: i32 = 0;
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (dim_ix < 0) {
    return 0 - 1;
  }
  if (dim_ix >= P12G_DIM_MAX) {
    return 0 - 1;
  }
  /* ndims==-2: extra SLICE wrap in dims[0] (0 means 1); unused
   * slot dims[1] extra PTR wrap (0 / missing → -1). dim_ix>=nd
   * would reject every dim_ix>=0 because -2 is negative. */
  if (nd == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
    extra = p12g_load_i32(ent, dims_base + dim_ix * 4);
    if (dim_ix == 0) {
      if (extra <= 0) {
        extra = 1;
      }
      return extra;
    }
    if (dim_ix == 1) {
      if (extra <= 0) {
        return 0 - 1;
      }
      return extra;
    }
    return 0 - 1;
  }
  /* ndims==0: unused slot dims[0] / dims[1] extra wrap. dim_ix>=nd
   * would treat dim_ix as an extra-wrap probe and then reject
   * because nd is not >0. leftover dim_ix>=2 → -1. */
  if (nd == 0) {
    if (dim_ix == 0) {
      extra = p12g_load_i32(ent, dims_base + 0);
      if (extra <= 0) {
        return 0 - 1;
      }
      return extra;
    }
    if (dim_ix == 1) {
      extra = p12g_load_i32(ent, dims_base + 4);
      if (extra <= 0) {
        return 0 - 1;
      }
      return extra;
    }
    return 0 - 1;
  }
  /* leftover negative ndims other than -2: C hits dim_ix>=nd then
   * !(nd>0 && nd<DIM_MAX) → -1. */
  if (nd <= 0) {
    return 0 - 1;
  }
  /* dim_ix>=ndims: unused slot dims[ndims] / dims[ndims+1] extra
   * wrap. extra>0 returns the count; 0 / missing → -1. */
  if (dim_ix >= nd) {
    if (nd >= P12G_DIM_MAX) {
      return 0 - 1;
    }
    if (dim_ix == nd) {
      extra = p12g_load_i32(ent, dims_base + nd * 4);
      if (extra <= 0) {
        return 0 - 1;
      }
      return extra;
    }
    if (dim_ix == nd + 1) {
      if (nd + 1 >= P12G_DIM_MAX) {
        return 0 - 1;
      }
      extra = p12g_load_i32(ent, dims_base + (nd + 1) * 4);
      if (extra <= 0) {
        return 0 - 1;
      }
      return extra;
    }
    return 0 - 1;
  }
  extra = p12g_load_i32(ent, dims_base + dim_ix * 4);
  return extra;
}

/**
 * Return one dim of a trait-method return's ARRAY elem (`*[K][N]T`)
 * including dest-extras unused-slot wrap soup.
 * Twin of param_elem_array_dim. Historical public stays `_c`.
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → -1
 * @param dim_ix i32 — dimension index (0 = outer of the ARRAY elem)
 * @param table *u8 — dest trait-reg image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — N > 0 / extra wrap count, or -1 if invalid
 * PLATFORM: SHARED — product P12r B-minus. C trampoline owns the table.
 * method_on_param is P12s. Do not merge with simple ret_array_dim.
 * Do not copy into typeck / codegen.
 */
#[no_mangle]
export function xlang_skip_trait_method_ret_elem_array_dim_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, dim_ix: i32, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let nd: i32 = 0;
  let dims_base: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  if (dim_ix < 0) {
    return 0 - 1;
  }
  if (dim_ix >= P12G_DIM_MAX) {
    return 0 - 1;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0 - 1;
  }
  nd = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + slot * 4);
  dims_base = P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + slot * P12G_RET_DIMS_ROW;
  return skip_trait_elem_array_dim_at(ent, dims_base, nd, dim_ix);
}

/**
 * Return one dim of a trait-method formal's ARRAY elem (`[][K][N]T`)
 * including dest-extras unused-slot wrap soup.
 * Extra i of a METHOD_CALL maps to param_ix = i+1 (param 0 is self).
 * Historical public stays `_c`.
 * @param trait_nm *u8 — trait name bytes; null → -1
 * @param trait_nlen i32 — byte count; must be > 0
 * @param slot i32 — vtable slot; <0 → -1
 * @param param_ix i32 — formal index including self; <0 or >= PARAM_MAX → -1
 * @param dim_ix i32 — dimension index (0 = outer of the ARRAY elem)
 * @param table *u8 — dest trait-reg image; null → -1
 * @param stride i32 — bytes per ent; <=0 → -1
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — N > 0 / extra wrap count, or -1 if invalid
 * PLATFORM: SHARED — product P12r B-minus. C trampoline owns the table.
 * method_on_param is P12s. Do not merge with simple param_array_dim.
 * Do not copy into typeck / codegen.
 */
#[no_mangle]
export function xlang_skip_trait_method_param_elem_array_dim_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, param_ix: i32, dim_ix: i32, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let nd: i32 = 0;
  let dims_base: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  if (param_ix < 0) {
    return 0 - 1;
  }
  if (param_ix >= P12G_PARAM_MAX) {
    return 0 - 1;
  }
  if (dim_ix < 0) {
    return 0 - 1;
  }
  if (dim_ix >= P12G_DIM_MAX) {
    return 0 - 1;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  if (skip_trait_slot_in_range(ent, slot) == 0) {
    return 0 - 1;
  }
  nd = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + slot * P12G_PARAM_LENS_ROW + param_ix * 4);
  dims_base = P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + slot * P12G_PARAM_DIMS_ROW + param_ix * P12G_PARAM_DIMS_ROW_INNER;
  return skip_trait_elem_array_dim_at(ent, dims_base, nd, dim_ix);
}

/**
 * Write method_on_param ret outs for one fat-ent slot.
 * Matches the C twin: ret_kind optional; name_len starts at 0;
 * out_ret_name is memset-64 then capped at 63. Do not reuse
 * skip_copy_row64 (F4 returns stored nlen) or ret_name_dest
 * (rejects nlen>64, no memset, no cap-63).
 * @param ent *u8 — fat-ent image; null → 1 with no write
 * @param slot i32 — vtable slot already in range
 * @param out_ret_kind *i32 — TypeKind dest; null → skip
 * @param out_ret_name *u8 — 64-byte NAMED dest; null → skip copy
 * @param out_ret_name_len *i32 — name length dest; null → skip
 * @return i32 — always 1 (hit)
 * PLATFORM: SHARED — P12s helper.
 */
function skip_method_on_param_fill_ret(ent: *u8, slot: i32, out_ret_kind: *i32, out_ret_name: *u8, out_ret_name_len: *i32): i32 {
  let rnl: i32 = 0;
  let i: i32 = 0;
  let rk: i32 = 0;
  let src: *u8 = 0 as *u8;
  if (ent == 0 as *u8) {
    return 1;
  }
  rk = p12g_load_i32(ent, P12G_OFF_METHOD_RET_KINDS + slot * 4);
  rnl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + slot * 4);
  unsafe {
    if (out_ret_kind != 0 as *i32) {
      out_ret_kind[0] = rk;
    }
    if (out_ret_name_len != 0 as *i32) {
      out_ret_name_len[0] = 0;
    }
    if (out_ret_name != 0 as *u8) {
      i = 0;
      while (i < GNM_CAP) {
        out_ret_name[i as usize] = 0;
        i = i + 1;
      }
      if (rnl > 0) {
        if (rnl > 63) {
          rnl = 63;
        }
        src = ent + ((P12G_OFF_METHOD_RET_NAMES + slot * P12G_RET_NAME_ROW) as usize);
        i = 0;
        while (i < rnl) {
          out_ret_name[i as usize] = src[i as usize];
          i = i + 1;
        }
        if (out_ret_name_len != 0 as *i32) {
          out_ret_name_len[0] = rnl;
        }
      }
    }
  }
  return 1;
}

/**
 * Walk one bound trait's methods for a name+arity grant.
 * First matching method wins; arity mismatch continues to the
 * next same-name slot (do not reuse method_slot first-match).
 * @param trait_nm *u8 — bound trait spelling; null / empty → 0
 * @param trait_nlen i32 — byte count; must be > 0
 * @param method_nm *u8 — method spelling; already non-empty
 * @param method_nlen i32 — byte count; already > 0
 * @param num_args i32 — METHOD extras (self not counted)
 * @param out_ret_kind *i32 — TypeKind dest; may be null
 * @param out_ret_name *u8 — 64-byte NAMED dest; may be null
 * @param out_ret_name_len *i32 — name length dest; may be null
 * @param table *u8 — dest trait-reg image
 * @param stride i32 — bytes per ent
 * @param n i32 — occupied registry count
 * @return i32 — 1 granted, 0 no
 * PLATFORM: SHARED — P12s helper. C trampoline owns the table.
 */
function skip_method_on_param_try_trait(trait_nm: *u8, trait_nlen: i32, method_nm: *u8, method_nlen: i32, num_args: i32, out_ret_kind: *i32, out_ret_name: *u8, out_ret_name_len: *i32, table: *u8, stride: i32, n: i32): i32 {
  let ent: *u8 = 0 as *u8;
  let mi: i32 = 0;
  let n_meth: i32 = 0;
  let mlen: i32 = 0;
  let expect_np: i32 = 0;
  let skip: i32 = 0;
  let mname: *u8 = 0 as *u8;
  if (trait_nm == 0 as *u8) {
    return 0;
  }
  if (trait_nlen <= 0) {
    return 0;
  }
  ent = skip_trait_ent_at(trait_nm, trait_nlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0;
  }
  n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  if (n_meth < 0) {
    n_meth = 0;
  }
  if (n_meth > P12G_METH_MAX) {
    n_meth = P12G_METH_MAX;
  }
  unsafe {
    mi = 0;
    while (mi < n_meth) {
      skip = 0;
      mlen = p12g_load_i32(ent, P12G_OFF_METHOD_LENS + mi * 4);
      mname = ent + ((P12G_OFF_METHODS + mi * P12G_METHOD_NAME_ROW) as usize);
      if (mlen <= 0) {
        skip = 1;
      }
      if (skip == 0) {
        if (skip_named_bytes_eq(mname, mlen, method_nm, method_nlen) == 0) {
          skip = 1;
        }
      }
      if (skip == 0) {
        expect_np = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_COUNTS + mi * 4);
        if (expect_np >= 0) {
          if (expect_np != num_args + 1) {
            skip = 1;
          }
        }
      }
      if (skip == 0) {
        skip_method_on_param_fill_ret(ent, mi, out_ret_kind, out_ret_name, out_ret_name_len);
        return 1;
      }
      mi = mi + 1;
    }
  }
  return 0;
}

/**
 * Grant `method` on type-param T when the enclosing generic function
 * declared `T: Trait` and Trait lists that method.
 * First matching bound+trait+method+arity wins. `num_args` is METHOD
 * extras (self not counted); expect_np < 0 skips the arity gate.
 * Language has no file-local statics / no fat-struct field access;
 * dest is g_fn_bound_* (stride 64, cap 16) plus the fat trait-reg
 * image (stride = sizeof(ent), cap 16). type_param_index is the
 * P12k historical `_c` (C trampoline injects g_fn_gp_*).
 * @param fn_name *u8 — enclosing generic function spelling; null / empty → 0
 * @param fn_name_len i32 — byte count; capped at 63
 * @param tp_name *u8 — receiver type-param spelling; null / empty → 0
 * @param tp_name_len i32 — byte count; capped at 63
 * @param method_name *u8 — method spelling; null / empty → 0
 * @param method_name_len i32 — byte count; capped at 63
 * @param num_args i32 — METHOD extras (self is implicit)
 * @param out_ret_kind *i32 — TypeKind ord dest; may be null
 * @param out_ret_name *u8 — 64-byte NAMED dest; may be null
 * @param out_ret_name_len *i32 — name length dest; may be null
 * @param bound_name *u8 — dest generic-fn names, stride 64, cap 16
 * @param bound_name_len *i32 — dest generic-fn name lens, cap 16
 * @param bound_trait *u8 — dest bound-trait names, stride 64, cap 16
 * @param bound_trait_len *i32 — dest bound-trait name lens, cap 16
 * @param bound_pos *i32 — dest type-param positions, cap 16
 * @param bound_n i32 — occupied bound-row count (read-only)
 * @param table *u8 — dest trait-reg image; null → 0
 * @param stride i32 — bytes per ent; <=0 → 0
 * @param n i32 — occupied registry count (read-only)
 * @return i32 — 1 method granted by a bound; 0 no
 * PLATFORM: SHARED — product P12s B-minus. C trampoline owns
 * g_fn_bound_* and g_xlang_skip_trait_reg[]. Do not copy into
 * typeck / codegen (they already call historical `_c`). Do not
 * merge with bound_check_type_args. Do not merge with F3 lookup.
 */
#[no_mangle]
export function xlang_generic_bound_method_on_param_into_c(fn_name: *u8, fn_name_len: i32, tp_name: *u8, tp_name_len: i32, method_name: *u8, method_name_len: i32, num_args: i32, out_ret_kind: *i32, out_ret_name: *u8, out_ret_name_len: *i32, bound_name: *u8, bound_name_len: *i32, bound_trait: *u8, bound_trait_len: *i32, bound_pos: *i32, bound_n: i32, table: *u8, stride: i32, n: i32): i32 {
  let pos: i32 = 0;
  let bi: i32 = 0;
  let nb: i32 = 0;
  let skip: i32 = 0;
  let hit: i32 = 0;
  let name_off: usize = 0;
  let trait_off: usize = 0;
  if (fn_name == 0 as *u8) {
    return 0;
  }
  if (fn_name_len <= 0) {
    return 0;
  }
  if (tp_name == 0 as *u8) {
    return 0;
  }
  if (tp_name_len <= 0) {
    return 0;
  }
  if (method_name == 0 as *u8) {
    return 0;
  }
  if (method_name_len <= 0) {
    return 0;
  }
  if (bound_name == 0 as *u8) {
    return 0;
  }
  if (bound_name_len == 0 as *i32) {
    return 0;
  }
  if (bound_trait == 0 as *u8) {
    return 0;
  }
  if (bound_trait_len == 0 as *i32) {
    return 0;
  }
  if (bound_pos == 0 as *i32) {
    return 0;
  }
  if (table == 0 as *u8) {
    return 0;
  }
  if (stride <= 0) {
    return 0;
  }
  if (bound_n <= 0) {
    return 0;
  }
  if (fn_name_len > 63) {
    fn_name_len = 63;
  }
  if (tp_name_len > 63) {
    tp_name_len = 63;
  }
  if (method_name_len > 63) {
    method_name_len = 63;
  }
  pos = xlang_generic_func_type_param_index_c(fn_name, fn_name_len, tp_name, tp_name_len);
  if (pos < 0) {
    return 0;
  }
  nb = bound_n;
  if (nb > FN_BOUND_MAX) {
    nb = FN_BOUND_MAX;
  }
  unsafe {
    bi = 0;
    while (bi < nb) {
      skip = 0;
      name_off = (bi as usize) * (BOUND_NAME_CAP as usize);
      if (skip_named_bytes_eq(bound_name + name_off, bound_name_len[bi], fn_name, fn_name_len) == 0) {
        skip = 1;
      }
      if (skip == 0) {
        if (bound_pos[bi] != pos) {
          skip = 1;
        }
      }
      if (skip == 0) {
        trait_off = (bi as usize) * (BOUND_NAME_CAP as usize);
        hit = skip_method_on_param_try_trait(bound_trait + trait_off, bound_trait_len[bi], method_name, method_name_len, num_args, out_ret_kind, out_ret_name, out_ret_name_len, table, stride, n);
        if (hit == 1) {
          return 1;
        }
      }
      bi = bi + 1;
    }
  }
  return 0;
}

/**
 * True when module already has a same-name method for this for-type
 * (self-matched) or a static (0-param) same-name def. Matches the C
 * hoist twin's override / free-def skip.
 * @param module *u8 — opaque ast_Module; null → 0
 * @param arena *u8 — opaque ASTArena for self_matches_for
 * @param mnm *u8 — method spelling; null / empty → 0
 * @param mlen i32 — byte count; <=0 → 0
 * @param for_k i32 — impl for-type TypeKind
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_nm *u8 — for-type spelling; may be null
 * @param for_nl i32 — for-type length
 * @param gnm *u8 — dest 64 for self_matches_for; C trampoline holds it
 * @return i32 — 1 exists (skip inject), 0 inject
 * PLATFORM: SHARED — P12t helper.
 */
function skip_hoist_method_exists(module: *u8, arena: *u8, mnm: *u8, mlen: i32, for_k: i32, for_ptr: i32, for_nm: *u8, for_nl: i32, gnm: *u8): i32 {
  let fi: i32 = 0;
  let nf: i32 = 0;
  let pty0: i32 = 0;
  let skip: i32 = 0;
  let np: i32 = 0;
  if (module == 0 as *u8) {
    return 0;
  }
  if (mnm == 0 as *u8) {
    return 0;
  }
  if (mlen <= 0) {
    return 0;
  }
  nf = pipeline_module_num_funcs(module);
  unsafe {
    fi = 0;
    while (fi < nf) {
      skip = 0;
      if (pipeline_module_func_name_equal_at(module, fi, mnm, mlen) == 0) {
        skip = 1;
      }
      if (skip == 0) {
        pty0 = pipeline_module_func_param_type_ref_at(module, fi, 0);
        if (xlang_skip_impl_self_matches_for_into_c(arena, pty0, for_k, for_ptr, for_nm, for_nl, gnm) != 0) {
          return 1;
        }
        np = pipeline_module_func_num_params_at(module, fi);
        if (np == 0) {
          return 1;
        }
      }
      fi = fi + 1;
    }
  }
  return 0;
}

/**
 * Inject one default-method slot of a fat-ent when it has a body
 * and the module does not already override it for this for-type.
 * Parse+commit stays in the C helper (onefunc_result by-value).
 * @param module *u8 — opaque ast_Module
 * @param arena *u8 — opaque ASTArena
 * @param src *u8 — full-file source bytes (stash dest)
 * @param src_len i32 — byte count
 * @param ent *u8 — fat-ent image; null → 0
 * @param mi i32 — method slot
 * @param for_k i32 — impl for-type TypeKind
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_nm *u8 — for-type spelling
 * @param for_nl i32 — for-type length
 * @param gnm *u8 — dest 64 for self_matches_for
 * @return i32 — 1 injected, 0 skipped
 * PLATFORM: SHARED — P12t helper.
 */
function skip_hoist_try_method(module: *u8, arena: *u8, src: *u8, src_len: i32, ent: *u8, mi: i32, for_k: i32, for_ptr: i32, for_nm: *u8, for_nl: i32, gnm: *u8): i32 {
  let has_def: i32 = 0;
  let mlen: i32 = 0;
  let mnm: *u8 = 0 as *u8;
  let fn_pos: i32 = 0;
  let fn_line: i32 = 0;
  let fn_col: i32 = 0;
  if (ent == 0 as *u8) {
    return 0;
  }
  if (mi < 0) {
    return 0;
  }
  has_def = p12g_load_i32(ent, P12G_OFF_METHOD_HAS_DEFAULT + mi * 4);
  if (has_def == 0) {
    return 0;
  }
  mlen = p12g_load_i32(ent, P12G_OFF_METHOD_LENS + mi * 4);
  if (mlen <= 0) {
    return 0;
  }
  unsafe {
    mnm = ent + ((P12G_OFF_METHODS + mi * P12G_METHOD_NAME_ROW) as usize);
  }
  if (skip_hoist_method_exists(module, arena, mnm, mlen, for_k, for_ptr, for_nm, for_nl, gnm) != 0) {
    return 0;
  }
  fn_pos = p12g_load_i32(ent, P12G_OFF_METHOD_FN_POS + mi * 4);
  fn_line = p12g_load_i32(ent, P12G_OFF_METHOD_FN_LINE + mi * 4);
  fn_col = p12g_load_i32(ent, P12G_OFF_METHOD_FN_COL + mi * 4);
  return xlang_skip_hoist_inject_one_c(module, arena, src, src_len, fn_pos, fn_line, fn_col, for_nm, for_nl, for_ptr);
}

/**
 * Walk one impl-seen row: find the bound trait in the fat table,
 * then try each default-method slot.
 * @param module *u8 — opaque ast_Module
 * @param arena *u8 — opaque ASTArena
 * @param src *u8 — full-file source bytes
 * @param src_len i32 — byte count
 * @param tname *u8 — impl trait spelling; null / empty → 0
 * @param tlen i32 — byte count; <=0 → 0
 * @param for_k i32 — impl for-type TypeKind
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_nm *u8 — for-type spelling
 * @param for_nl i32 — for-type length
 * @param table *u8 — dest trait-reg image
 * @param stride i32 — bytes per ent
 * @param n i32 — occupied registry count
 * @param gnm *u8 — dest 64 for self_matches_for
 * @return i32 — number of injects from this impl row
 * PLATFORM: SHARED — P12t helper.
 */
function skip_hoist_try_impl(module: *u8, arena: *u8, src: *u8, src_len: i32, tname: *u8, tlen: i32, for_k: i32, for_ptr: i32, for_nm: *u8, for_nl: i32, table: *u8, stride: i32, n: i32, gnm: *u8): i32 {
  let ent: *u8 = 0 as *u8;
  let mi: i32 = 0;
  let n_meth: i32 = 0;
  let n_inj: i32 = 0;
  if (tname == 0 as *u8) {
    return 0;
  }
  if (tlen <= 0) {
    return 0;
  }
  ent = skip_trait_ent_at(tname, tlen, table, stride, n);
  if (ent == 0 as *u8) {
    return 0;
  }
  n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  if (n_meth < 0) {
    n_meth = 0;
  }
  if (n_meth > P12G_METH_MAX) {
    n_meth = P12G_METH_MAX;
  }
  mi = 0;
  while (mi < n_meth) {
    n_inj = n_inj + skip_hoist_try_method(module, arena, src, src_len, ent, mi, for_k, for_ptr, for_nm, for_nl, gnm);
    mi = mi + 1;
  }
  return n_inj;
}

/**
 * Hoist trait default-method bodies as free UFCS functions when the
 * impl did not override them. Per-impl inject so Self rewrites to
 * each for-type (wave470). Language has no file-local statics / no
 * fat-struct field access / no local onefunc_result; dest is
 * g_xlang_skip_impl_* (stride 64, cap 16) plus the fat trait-reg
 * image, and parse+commit stays in the C inject helper.
 * @param module *u8 — opaque ast_Module; null → 0
 * @param arena *u8 — opaque ASTArena stashed at trait_reg_reset; null → 0
 * @param src *u8 — full-file source bytes (stash dest); null / empty → 0
 * @param src_len i32 — byte count; <=0 → 0
 * @param impl_trait *u8 — dest impl trait names, stride 64, cap 16
 * @param impl_trait_len *i32 — dest impl trait name lens, cap 16
 * @param for_kinds *i32 — dest for-type TypeKind ords, cap 16
 * @param for_is_ptr *i32 — dest for-type is-*T flags, cap 16
 * @param for_names *u8 — dest for-type names, stride 64, cap 16
 * @param for_name_lens *i32 — dest for-type name lens, cap 16
 * @param impl_n i32 — occupied impl-seen count (read-only)
 * @param table *u8 — dest trait-reg image; null → 0
 * @param stride i32 — bytes per ent; <=0 → 0
 * @param n i32 — occupied registry count (read-only)
 * @param gnm *u8 — dest 64 for self_matches_for; C trampoline holds it
 * @return i32 — number of injects (0 if nothing to hoist)
 * PLATFORM: SHARED — product P12t B-minus. C trampoline owns
 * g_xlang_skip_impl_* / g_xlang_skip_trait_reg[] / g_w439_src_*.
 * Do not copy into typeck. Do not merge with method_on_param.
 * Do not wrap trait_check_impls_complete.
 */
#[no_mangle]
export function xlang_skip_hoist_default_methods_into_c(module: *u8, arena: *u8, src: *u8, src_len: i32, impl_trait: *u8, impl_trait_len: *i32, for_kinds: *i32, for_is_ptr: *i32, for_names: *u8, for_name_lens: *i32, impl_n: i32, table: *u8, stride: i32, n: i32, gnm: *u8): i32 {
  let si: i32 = 0;
  let sn: i32 = 0;
  let tlen: i32 = 0;
  let skip: i32 = 0;
  let n_inj: i32 = 0;
  let trait_off: usize = 0;
  let for_off: usize = 0;
  if (module == 0 as *u8) {
    return 0;
  }
  if (arena == 0 as *u8) {
    return 0;
  }
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len <= 0) {
    return 0;
  }
  if (impl_trait == 0 as *u8) {
    return 0;
  }
  if (impl_trait_len == 0 as *i32) {
    return 0;
  }
  if (for_kinds == 0 as *i32) {
    return 0;
  }
  if (for_is_ptr == 0 as *i32) {
    return 0;
  }
  if (for_names == 0 as *u8) {
    return 0;
  }
  if (for_name_lens == 0 as *i32) {
    return 0;
  }
  if (table == 0 as *u8) {
    return 0;
  }
  if (stride <= 0) {
    return 0;
  }
  if (gnm == 0 as *u8) {
    return 0;
  }
  if (impl_n <= 0) {
    return 0;
  }
  sn = impl_n;
  if (sn > SKIP_IMPL_SEEN_MAX) {
    sn = SKIP_IMPL_SEEN_MAX;
  }
  unsafe {
    si = 0;
    while (si < sn) {
      skip = 0;
      tlen = impl_trait_len[si];
      if (tlen <= 0) {
        skip = 1;
      }
      if (skip == 0) {
        trait_off = (si as usize) * (GNM_CAP as usize);
        for_off = (si as usize) * (GNM_CAP as usize);
        n_inj = n_inj + skip_hoist_try_impl(module, arena, src, src_len, impl_trait + trait_off, tlen, for_kinds[si], for_is_ptr[si], for_names + for_off, for_name_lens[si], table, stride, n, gnm);
      }
      si = si + 1;
    }
  }
  return n_inj;
}

/**
 * Find the module func implementing this trait method for this for-type.
 * Prefer self-matched same-name; fall back to the first same-name (static
 * methods with param0 != for-type). Not skip_hoist_method_exists (that
 * skips inject on 0-param; this returns a func index for signature checks).
 * @param module *u8 — opaque ast_Module; null → -1
 * @param arena *u8 — opaque ASTArena for self_matches_for
 * @param mnm *u8 — method spelling; null / empty → -1
 * @param mlen i32 — byte count; <=0 → -1
 * @param for_k i32 — impl for-type TypeKind
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_nm *u8 — for-type spelling; may be null
 * @param for_nl i32 — for-type length
 * @param gnm *u8 — dest 64 for self_matches_for; C trampoline holds it
 * @return i32 — module func index, or -1 if no same-name method
 * PLATFORM: SHARED — P12u helper.
 */
function skip_trait_check_find_method(module: *u8, arena: *u8, mnm: *u8, mlen: i32, for_k: i32, for_ptr: i32, for_nm: *u8, for_nl: i32, gnm: *u8): i32 {
  let fi: i32 = 0;
  let nf: i32 = 0;
  let pty0: i32 = 0;
  let skip: i32 = 0;
  let first_fi: i32 = -1;
  if (module == 0 as *u8) {
    return -1;
  }
  if (mnm == 0 as *u8) {
    return -1;
  }
  if (mlen <= 0) {
    return -1;
  }
  nf = pipeline_module_num_funcs(module);
  unsafe {
    fi = 0;
    while (fi < nf) {
      skip = 0;
      if (pipeline_module_func_name_equal_at(module, fi, mnm, mlen) == 0) {
        skip = 1;
      }
      if (skip == 0) {
        if (first_fi < 0) {
          first_fi = fi;
        }
        pty0 = pipeline_module_func_param_type_ref_at(module, fi, 0);
        if (xlang_skip_impl_self_matches_for_into_c(arena, pty0, for_k, for_ptr, for_nm, for_nl, gnm) != 0) {
          return fi;
        }
      }
      fi = fi + 1;
    }
  }
  return first_fi;
}

/**
 * Check one trait-method slot of a fat-ent against the module: find the
 * impl func, arity, dest-SLICE param/ret shape. Missing / mismatch
 * emits a C varargs diag and returns -1; empty mlen is skip (0).
 * @param module *u8 — opaque ast_Module
 * @param arena *u8 — opaque ASTArena
 * @param ent *u8 — fat-ent image; null → 0
 * @param mi i32 — method slot
 * @param si i32 — impl-seen index (C helpers read file-local tables)
 * @param ti i32 — fat-reg slot
 * @param for_k i32 — impl for-type TypeKind
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_nm *u8 — for-type spelling
 * @param for_nl i32 — for-type length
 * @param gnm *u8 — dest 64 for self_matches_for
 * @return i32 — 0 ok, -1 one or more diags
 * PLATFORM: SHARED — P12u helper.
 */
function skip_trait_check_try_method(module: *u8, arena: *u8, ent: *u8, mi: i32, si: i32, ti: i32, for_k: i32, for_ptr: i32, for_nm: *u8, for_nl: i32, gnm: *u8): i32 {
  let mlen: i32 = 0;
  let mnm: *u8 = 0 as *u8;
  let expect_np: i32 = 0;
  let found_fi: i32 = -1;
  let got_np: i32 = 0;
  let rc: i32 = 0;
  let skip: i32 = 0;
  if (ent == 0 as *u8) {
    return 0;
  }
  if (mi < 0) {
    return 0;
  }
  mlen = p12g_load_i32(ent, P12G_OFF_METHOD_LENS + mi * 4);
  if (mlen <= 0) {
    return 0;
  }
  unsafe {
    mnm = ent + ((P12G_OFF_METHODS + mi * P12G_METHOD_NAME_ROW) as usize);
  }
  found_fi = skip_trait_check_find_method(module, arena, mnm, mlen, for_k, for_ptr, for_nm, for_nl, gnm);
  if (found_fi < 0) {
    return xlang_skip_trait_check_diag_missing_c(si, mnm, mlen);
  }
  expect_np = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_COUNTS + mi * 4);
  skip = 0;
  if (expect_np < 0) {
    skip = 1;
  }
  if (skip == 0) {
    got_np = pipeline_module_func_num_params_at(module, found_fi);
    if (got_np != expect_np) {
      rc = xlang_skip_trait_check_diag_param_count_c(si, mnm, mlen);
    } else {
      if (xlang_skip_trait_check_param_shape_c(module, arena, found_fi, si, ti, mi, mnm, mlen, expect_np) != 0) {
        rc = -1;
      }
    }
  }
  if (xlang_skip_trait_check_ret_shape_c(module, arena, found_fi, si, ti, mi, mnm, mlen) != 0) {
    rc = -1;
  }
  return rc;
}

/**
 * Walk one impl-seen row: find the bound trait in the fat table, then
 * check each method slot. Unknown trait emits a C varargs diag.
 * @param module *u8 — opaque ast_Module
 * @param arena *u8 — opaque ASTArena
 * @param tname *u8 — impl trait spelling; null / empty → 0
 * @param tlen i32 — byte count; <=0 → 0
 * @param si i32 — impl-seen index
 * @param for_k i32 — impl for-type TypeKind
 * @param for_ptr i32 — 1 if for-type is *T
 * @param for_nm *u8 — for-type spelling
 * @param for_nl i32 — for-type length
 * @param table *u8 — dest trait-reg image
 * @param stride i32 — bytes per ent
 * @param n i32 — occupied registry count
 * @param gnm *u8 — dest 64 for self_matches_for
 * @return i32 — 0 ok, -1 one or more diags
 * PLATFORM: SHARED — P12u helper.
 */
function skip_trait_check_try_impl(module: *u8, arena: *u8, tname: *u8, tlen: i32, si: i32, for_k: i32, for_ptr: i32, for_nm: *u8, for_nl: i32, table: *u8, stride: i32, n: i32, gnm: *u8): i32 {
  let ent: *u8 = 0 as *u8;
  let ti: i32 = -1;
  let mi: i32 = 0;
  let n_meth: i32 = 0;
  let rc: i32 = 0;
  if (tname == 0 as *u8) {
    return 0;
  }
  if (tlen <= 0) {
    return 0;
  }
  ti = xlang_skip_trait_find_reg_into_c(tname, tlen, table, stride, n);
  if (ti < 0) {
    return xlang_skip_trait_check_diag_unknown_c(si);
  }
  unsafe {
    ent = table + ((ti * stride) as usize);
  }
  n_meth = p12g_load_i32(ent, P12G_OFF_NUM_METHODS);
  if (n_meth < 0) {
    n_meth = 0;
  }
  if (n_meth > P12G_METH_MAX) {
    n_meth = P12G_METH_MAX;
  }
  mi = 0;
  while (mi < n_meth) {
    if (skip_trait_check_try_method(module, arena, ent, mi, si, ti, for_k, for_ptr, for_nm, for_nl, gnm) != 0) {
      rc = -1;
    }
    mi = mi + 1;
  }
  return rc;
}

/**
 * After default-method hoist, scan each impl-seen row for missing
 * methods / arity / dest-SLICE param+ret mismatch, then run the
 * generic-bound scan+check. Language has no file-local statics / no
 * fat-struct field access / no printf varargs; dest is
 * g_xlang_skip_impl_* (stride 64, cap 16) plus the fat trait-reg
 * image, and shape/diag stay in the C helpers. Hoist is the P12t
 * trampoline (C wrapper calls it first).
 * @param module *u8 — opaque ast_Module; null → 0
 * @param arena *u8 — opaque ASTArena stashed at trait_reg_reset; may be null
 * @param impl_trait *u8 — dest impl trait names, stride 64, cap 16
 * @param impl_trait_len *i32 — dest impl trait name lens, cap 16
 * @param for_kinds *i32 — dest for-type TypeKind ords, cap 16
 * @param for_is_ptr *i32 — dest for-type is-*T flags, cap 16
 * @param for_names *u8 — dest for-type names, stride 64, cap 16
 * @param for_name_lens *i32 — dest for-type name lens, cap 16
 * @param impl_n i32 — occupied impl-seen count (read-only)
 * @param table *u8 — dest trait-reg image; null → skip impl walk
 * @param stride i32 — bytes per ent; <=0 → skip impl walk
 * @param n i32 — occupied registry count (read-only)
 * @param gnm *u8 — dest 64 for self_matches_for; C trampoline holds it
 * @param src *u8 — full-file source bytes (stash dest); may be null
 * @param src_len i32 — byte count
 * @return i32 — 0 all ok, -1 ≥1 violation
 * PLATFORM: SHARED — product P12u B-minus. C trampoline owns
 * g_xlang_skip_impl_* / g_xlang_skip_trait_reg[] / g_w439_src_*.
 * Do not copy into typeck. Do not merge with skip_hoist /
 * method_on_param / F3 lookup.
 */
#[no_mangle]
export function xlang_trait_check_impls_complete_into_c(module: *u8, arena: *u8, impl_trait: *u8, impl_trait_len: *i32, for_kinds: *i32, for_is_ptr: *i32, for_names: *u8, for_name_lens: *i32, impl_n: i32, table: *u8, stride: i32, n: i32, gnm: *u8, src: *u8, src_len: i32): i32 {
  let si: i32 = 0;
  let sn: i32 = 0;
  let tlen: i32 = 0;
  let skip: i32 = 0;
  let rc: i32 = 0;
  let walk: i32 = 1;
  let trait_off: usize = 0;
  let for_off: usize = 0;
  if (module == 0 as *u8) {
    return 0;
  }
  if (impl_trait == 0 as *u8) {
    walk = 0;
  }
  if (impl_trait_len == 0 as *i32) {
    walk = 0;
  }
  if (for_kinds == 0 as *i32) {
    walk = 0;
  }
  if (for_is_ptr == 0 as *i32) {
    walk = 0;
  }
  if (for_names == 0 as *u8) {
    walk = 0;
  }
  if (for_name_lens == 0 as *i32) {
    walk = 0;
  }
  if (table == 0 as *u8) {
    walk = 0;
  }
  if (stride <= 0) {
    walk = 0;
  }
  if (gnm == 0 as *u8) {
    walk = 0;
  }
  if (impl_n <= 0) {
    walk = 0;
  }
  if (walk != 0) {
    sn = impl_n;
    if (sn > SKIP_IMPL_SEEN_MAX) {
      sn = SKIP_IMPL_SEEN_MAX;
    }
    unsafe {
      si = 0;
      while (si < sn) {
        skip = 0;
        tlen = impl_trait_len[si];
        if (tlen <= 0) {
          skip = 1;
        }
        if (skip == 0) {
          trait_off = (si as usize) * (GNM_CAP as usize);
          for_off = (si as usize) * (GNM_CAP as usize);
          if (skip_trait_check_try_impl(module, arena, impl_trait + trait_off, tlen, si, for_kinds[si], for_is_ptr[si], for_names + for_off, for_name_lens[si], table, stride, n, gnm) != 0) {
            rc = -1;
          }
        }
        si = si + 1;
      }
    }
  }
  xlang_generic_bound_scan_c(src, src_len);
  if (xlang_generic_bound_check_c() != 0) {
    rc = -1;
  }
  return rc;
}

// ---------------------------------------------------------------------------
// 7.2.1 P12g (2026-09-13 RFC route α): skip_one_trait via ent stack-image.
// g-1 PRESET ONLY — this body is not linked into any gate yet (no caller,
// no BODIES region covers it). C twin stays authoritative. g-2 grows the
// signature machine here; g-3 flips XLANG_PTHIN_SKIP_TL_BODIES_FROM_X to
// cover skip_one_trait and adds the stack-image trampoline in the seed TU.
// Offsets mirror the C xlang_skip_trait_reg_ent_t layout pinned by 30
// _Static_asserts in seeds/pthin_skip_tl.from_x.c — copies, not authority.
// PLATFORM: SHARED freestanding.
// ---------------------------------------------------------------------------

/** P12g ent-image field offsets (see seed pins; C layout is authority). */
const P12G_OFF_NAME: i32 = 0;
const P12G_OFF_NAME_LEN: i32 = 64;
const P12G_OFF_METHODS: i32 = 68;
const P12G_OFF_METHOD_LENS: i32 = 2116;
const P12G_OFF_METHOD_HAS_DEFAULT: i32 = 2244;
const P12G_OFF_METHOD_FN_POS: i32 = 2372;
const P12G_OFF_METHOD_FN_LINE: i32 = 2500;
const P12G_OFF_METHOD_FN_COL: i32 = 2628;
const P12G_OFF_METHOD_RET_KINDS: i32 = 2756;
const P12G_OFF_METHOD_RET_NAMES: i32 = 2884;
const P12G_OFF_METHOD_RET_NAME_LENS: i32 = 4932;
const P12G_OFF_METHOD_RET_ELEM_KINDS: i32 = 5060;
const P12G_OFF_METHOD_RET_ARRAY_SIZES: i32 = 5188;
const P12G_OFF_METHOD_RET_ARRAY_NDIMS: i32 = 5316;
const P12G_OFF_METHOD_RET_ARRAY_DIMS: i32 = 5444;
const P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS: i32 = 6468;
const P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS: i32 = 6596;
const P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS: i32 = 7620;
const P12G_OFF_METHOD_PARAM_COUNTS: i32 = 7748;
const P12G_OFF_METHOD_PARAM_KINDS: i32 = 7876;
const P12G_OFF_METHOD_PARAM_NAMES: i32 = 8900;
const P12G_OFF_METHOD_PARAM_NAME_LENS: i32 = 25284;
const P12G_OFF_METHOD_PARAM_ELEM_KINDS: i32 = 26308;
const P12G_OFF_METHOD_PARAM_ARRAY_NDIMS: i32 = 27332;
const P12G_OFF_METHOD_PARAM_ARRAY_DIMS: i32 = 28356;
const P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS: i32 = 36548;
const P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS: i32 = 37572;
const P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS: i32 = 45764;
const P12G_OFF_NUM_METHODS: i32 = 46788;
/** Row strides for the indexed method arrays (m row / [m][p] param row). */
const P12G_METHOD_ROW: i32 = 128;
const P12G_METHOD_NAME_ROW: i32 = 64;
const P12G_RET_NAME_ROW: i32 = 64;
const P12G_RET_DIMS_ROW: i32 = 32;
const P12G_PARAM_KINDS_ROW: i32 = 32;
const P12G_PARAM_NAME_ROW: i32 = 512;
const P12G_PARAM_NAME_INNER: i32 = 64;
const P12G_PARAM_LENS_ROW: i32 = 32;
const P12G_PARAM_DIMS_ROW: i32 = 256;
const P12G_PARAM_DIMS_ROW_INNER: i32 = 32;

// TOKEN_* pins for the trait walk (P12g; C _Static_asserts fire on drift).
const TOKEN_TRAIT: i32 = 49;
const TOKEN_INT: i32 = 80;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;

/** P12g local: store i32 at base+off (LE byte writes; mirror of P13c). */
function p12g_store_i32(base: *u8, off: i32, v: i32): void {
  let a: usize = 0;
  unsafe {
    a = v as usize;
    base[off + 0] = (a & 255) as u8;
    a = a >> 8;
    base[off + 1] = (a & 255) as u8;
    a = a >> 8;
    base[off + 2] = (a & 255) as u8;
    a = a >> 8;
    base[off + 3] = (a & 255) as u8;
  }
}

/**
 * P12v param shape核. C trampoline owns gnm + fat tables.
 * PLATFORM: SHARED — do not merge into P12u outer.
 */
#[no_mangle]
export function xlang_skip_trait_check_param_shape_x_into_c(
    module: *u8, arena: *u8, found_fi: i32, si: i32, ti: i32, mi: i32,
    mnm: *u8, mlen: i32, expect_np: i32,
    table: *u8, stride: i32,
    for_kinds: *i32, for_is_ptr: *i32, for_names: *u8, for_name_lens: *i32,
    gnm: *u8): i32 {

  let d: i32 = 0;
  let eand: i32 = 0;
  let ed: i32 = 0;
  let eeek: i32 = 0;
  let eek: i32 = 0;
  let eend: i32 = 0;
  let ek: i32 = 0;
  let elem: i32 = 0;
  let enl: i32 = 0;
  let extra: i32 = 0;
  let extra_ptr: i32 = 0;
  let extra_slice: i32 = 0;
  let gek: i32 = 0;
  let gnl: i32 = 0;
  let got_pk: i32 = 0;
  let gsz: i32 = 0;
  let k: i32 = 0;
  let leaf_tr: i32 = 0;
  let mm: i32 = 0;
  let nd: i32 = 0;
  let pelem: i32 = 0;
  let pgek: i32 = 0;
  let pi: i32 = 0;
  let pty: i32 = 0;
  let pty0: i32 = 0;
  let ent: *u8 = 0 as *u8;
  if (module == 0 as *u8 || arena == 0 as *u8 || found_fi < 0) {
    return 0;
  }
  if (si < 0 || si >= 16) {
    return 0;
  }
  if (ti < 0 || ti >= SKIP_TRAIT_REG_MAX) {
    return 0;
  }
  if (mi < 0 || mi >= 32) {
    return 0;
  }
  if (mnm == 0 as *u8 || mlen <= 0 || expect_np < 0) {
    return 0;
  }
  if (table == 0 as *u8 || stride <= 0 || for_kinds == 0 as *i32 || for_is_ptr == 0 as *i32 || for_names == 0 as *u8 || for_name_lens == 0 as *i32 || gnm == 0 as *u8) {
    return 0;
  }
  unsafe {
    ent = table + ((ti as usize) * (stride as usize));

pi = 0;
          while (pi < expect_np && pi < P12G_PARAM_MAX) {
            ek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
            
            
            if (ek >= 0) {
            pty = pipeline_module_func_param_type_ref_at(module, found_fi, pi);
            got_pk = -1;
            if (pty != 0) {
              got_pk = pipeline_type_kind_ord_at(arena, pty);
            }
            // wave432: twin of seed param shape check (NAMED name / *T elem / []T elem).

            {
              mm = 0;
              if (got_pk >= 0 && got_pk != ek) {
                mm = 1;
              } else if (got_pk == ek && ek == P12G_TY_NAMED) {
                enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                if (enl > 0 && pty != 0) {
gnl = pipeline_type_named_name_into(arena, pty, gnm);
                  if (xlang_skip_trait_named_eq_self_c(
                        (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                        gnm, gnl,
                        (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                        for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                }
              } else if (got_pk == ek &&
                         (ek == P12G_TY_PTR || ek == P12G_TY_SLICE)) {
                eek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
                elem = 0;
                if (pty != 0) {
                  elem = pipeline_type_elem_ref_at(arena, pty);
                }
                if (eek >= 0 && elem != 0) {
                  gek = pipeline_type_kind_ord_at(arena, elem);
                  if (gek >= 0 && gek != eek) {
                    mm = 1;
                  } else if (gek == eek && eek == P12G_TY_NAMED) {
                    enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                    if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, elem, gnm);
                      if (xlang_skip_trait_named_eq_self_c(
                            (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                            gnm, gnl,
                            (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                            for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                    }
                  } else if (gek == eek && eek == P12G_TY_SLICE) {
                    // 
// * wave435: *[]T → PTR to SLICE of T. Walk pipeline SLICE
// * leaf → its elem → compare elem_elem (the slice base T).
// * dest-SLICE extra `[][][]T` / `[][][][]T`: skip-trait
// * stores eek=SLICE + eeek=leaf + ndims=-2 (extra inner
// * SLICE). Extra wrap count is dims[0] (0 means 1).
// * Pipeline pelem is then still SLICE — peel extra times
// * when ndims==-2 or T001 if layers run out. `[][]T`
// * (ndims=0) keeps the one-peel. dest extras dest-SLICE
// * of SLICE extra `[][]*T`: extra PTR wrap COUNT is
// * unused slot dims[0] with ndims staying 0 (1 =
// * `[][]*T`; 0 = no extra PTR = `[][]i32`). After the
// * leftover-SLICE peel, pelem is still PTR vs eeek=leaf
// * — peel leftover PTR extra times or T001. dest extras
// * dest-SLICE of SLICE extra ARRAY `[][][2]T`: leftover
// * after leftover-SLICE peel is ARRAY vs eeek=leaf
// * (ndims>=1, dims[0..ndims-1] from wave437 pending
// * LBRACKET after `[][]` then `[M]`). Peel leftover
// * ARRAY or T001. dest extras dest-SLICE of SLICE extra
// * ARRAY extra PTR `[][][2]*T`: leftover after extra
// * ARRAY peels is PTR vs eeek=leaf; extra PTR wrap
// * COUNT is unused slot dims[ndims] (1 = `[][][2]*T`;
// * 0 = no extra PTR = `[][][2]T`). Peel leftover PTR
// * extra times or T001. Store already has ndims>=1
// * (named / UFCS dest-stamp via the formal).
// * Discriminant: ndims==-2 extra SLICE; ndims==0 extra
// * PTR; ndims>=1 inner ARRAY (plus unused-slot extra
// * PTR). Do not invent -3.
// * PLATFORM: SHARED parse. G.7: complete this walk.
// 

                    eeek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
                    pelem = pipeline_type_elem_ref_at(arena, elem);
                    if (eeek >= 0 && pelem != 0) {
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      eand = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                      if (eand == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                        extra =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                        
                        if (extra <= 0) {
                          extra = 1;
                          }
                        while (extra > 0) {
                          if (pgek != P12G_TY_SLICE || pelem == 0) {
                            mm = 1;
                            break;
                          }
                          pelem = pipeline_type_elem_ref_at(arena, pelem);
                          if (pelem == 0) {
                            mm = 1;
                            break;
                          }
                          pgek = pipeline_type_kind_ord_at(arena, pelem);
                          extra = extra - 1;
                        }
                        // 
// * dest extras dest-SLICE of SLICE extra PTR
// * `[][][]*T`: leftover after extra SLICE peels
// * is PTR vs eeek=leaf. Extra PTR wrap COUNT is
// * unused slot dims[1] (1 = `[][][]*T`; 0 = no
// * extra PTR = `[][][]T`). Peel leftover PTR
// * extra times or T001. dest extras dest-ARRAY
// * of SLICE extra PTR `[2][][]*T` uses the same
// * dims[1] encoding (ARRAY leftover matches at
// * leftover SLICE vs eek=SLICE — not this walk;
// * not T001). Do not invent -3. PLATFORM:
// * SHARED. G.7: complete this walk.
// 

                        extra_ptr =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (1) * 4);
                        if (extra_ptr > 0) {
                          while (extra_ptr > 0) {
                            if (pgek != P12G_TY_PTR || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_ptr = extra_ptr - 1;
                          }
                        }
                      } else if (eand == 0) {
                        extra_ptr =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                        if (extra_ptr > 0) {
                          while (extra_ptr > 0) {
                            if (pgek != P12G_TY_PTR || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_ptr = extra_ptr - 1;
                          }
                        }
                      } else if (eand >= 1) {
                        // 
// * dest extras dest-SLICE of SLICE extra ARRAY
// * `[][][2]T`: leftover after leftover-SLICE
// * peel is ARRAY vs eeek=leaf. Inner ARRAY
// * dims are dims[0..ndims-1] (wave437 pending
// * LBRACKET after `[][]` then `[M]`). Peel
// * ARRAY outer-first or T001 if layers run
// * out. dest extras dest-SLICE of SLICE extra
// * ARRAY extra PTR `[][][2]*T`: leftover after
// * extra ARRAY peels is PTR vs eeek=leaf.
// * Extra PTR wrap COUNT is unused slot
// * dims[ndims] (1 = `[][][2]*T`; 0 = no extra
// * PTR = `[][][2]T`; same unused slot as dest
// * extras dest-SLICE of ARRAY extra `[][2][]T`
// * and dest extras dest-ARRAY of SLICE extra
// * `[2][][2]*T`; discriminant is elem_kind
// * SLICE vs ARRAY AND SLICE vs ARRAY outer).
// * Peel leftover PTR extra times or T001.
// * dest extras dest-ARRAY of SLICE extra PTR
// * `[2][][2]*T` uses the same dims[ndims]
// * encoding (ARRAY leftover matches at leftover
// * SLICE vs eek=SLICE — not this walk; not
// * T001). dest extras dest-SLICE of SLICE extra
// * wrap `[][][2][]T`: leftover after extra
// * ARRAY peels is SLICE vs eeek=leaf. Extra
// * SLICE wrap COUNT is unused slot
// * dims[ndims+1] (1 = `[][][2][]T`; 2 =
// * `[][][2][][]T`; 0 = no extra wrap =
// * `[][][2]T`; extra PTR of `[][][2]*T`
// * stays dims[ndims] — do not reopen). Peel
// * leftover SLICE extra times (after ARRAY,
// * before extra PTR) or T001. dest extras
// * dest-ARRAY of SLICE extra wrap `[2][][2][]T`
// * uses the same dims[ndims+1] encoding
// * (ARRAY leftover matches at leftover SLICE
// * vs eek=SLICE — not this walk; not T001).
// * PTR-outer extra empty `[]` `*[][2][]T`
// * uses the same dims[ndims+1] extra SLICE
// * encoding (this walk peels leftover SLICE
// * then extra ARRAY then extra SLICE then
// * extra PTR; leftover PTR vs eek=SLICE is
// * not T001 once extra SLICE is stored).
// * Extra ADDR_OF of typed `[][2][]i32`
// * dest-stamps via the formal (no dest extras
// * dest-PTR stamp). Nested extra lit dest
// * extras dest-PTR stamp stays deferred.
// * PTR-outer extra STAR `*[][2]*T` uses the
// * same dims[ndims] extra PTR encoding (this
// * walk peels leftover SLICE then extra ARRAY
// * then extra PTR; leftover PTR vs eek=SLICE
// * is not T001 once extra PTR is stored). Extra
// * ADDR_OF of typed `[][2]*i32` dest-stamps via
// * the formal (no dest extras dest-PTR stamp).
// * `[][]i32` (ndims==0) keeps leftover vs
// * eeek=leaf. Discriminant vs extra PTR
// * wrap-once: ndims==0 dims[0]; vs extra SLICE:
// * ndims==-2. Store already has ndims>=1
// * (named / UFCS dest-stamp via the formal).
// * Do not invent -3. PLATFORM: SHARED.
// * G.7: complete this walk.
// 

                        
                        
                        
                        d = 0;
              while (d < eand) {

                          
                          if (pgek != P12G_TY_ARRAY || pelem == 0) {
                            mm = 1;
                            break;
                          }
                          gsz = pipeline_type_array_size_at(arena, pelem);
                          if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                            mm = 1;
                            break;
                          }
                          pelem = pipeline_type_elem_ref_at(arena, pelem);
                          if (pelem == 0) {
                            mm = 1;
                            break;
                          }
                          pgek = pipeline_type_kind_ord_at(arena, pelem);
                        
                d = d + 1;
              }
                        extra_slice = 0;
                        if (eand > 0 && eand + 1 < 8) {
                          extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eand + 1) * 4);
                          }
                        if (extra_slice > 0) {
                          while (extra_slice > 0) {
                            if (pgek != P12G_TY_SLICE || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_slice = extra_slice - 1;
                          }
                        }
                        extra_ptr = 0;
                        if (eand > 0 && eand < 8) {
                          extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eand) * 4);
                          }
                        if (extra_ptr > 0) {
                          while (extra_ptr > 0) {
                            if (pgek != P12G_TY_PTR || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_ptr = extra_ptr - 1;
                          }
                        }
                      }
                      if (pgek >= 0 && pgek != eeek) {
                        mm = 1;
                      } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                        enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                        if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                          if (xlang_skip_trait_named_eq_self_c(
                                (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                                gnm, gnl,
                                (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                                for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                        }
                      }
                    }
                  } else if (gek == eek && eek == P12G_TY_ARRAY) {
                    // 
// * wave436: *[N]T → PTR to ARRAY of N T. The PTR's elem
// * (elem) is the ARRAY. Walk its dims (elem_array_ndims/
// * dims) then compare the leaf elem kind/name with
// * elem_elem (base T). Multi-dim *[N][M]T is soft-skipped
// * at registration (eeks=-1) so this path only fires for
// * single-dim. Twin of wave433 ARRAY walk but on elem level.
// * PLATFORM: SHARED parse.
// 

                    eeek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
                    eend = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                    leaf_tr = elem;
                    
                    d = 0;
              while (d < eend && leaf_tr != 0) {

                      k = pipeline_type_kind_ord_at(arena, leaf_tr);
                      
                      if (k != P12G_TY_ARRAY) {
                        mm = 1;
                        break;
                      }
                      gsz = pipeline_type_array_size_at(arena, leaf_tr);
                      if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                        mm = 1;
                        break;
                      }
                      leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                      if (leaf_tr == 0 && d + 1 < eend) {
                        mm = 1;
                        break;
                      }
                    
                d = d + 1;
              }
                    if ((mm == 0) && eeek >= 0 && leaf_tr != 0) {
                      pgek = pipeline_type_kind_ord_at(arena, leaf_tr);
                      // 
// * dest extras dest-SLICE of ARRAY extra `[][2]*T` /
// * `[][2][]T` / `[][2][]*T` and PTR-outer `*[2]*T` /
// * `*[2][]*T`: after walking ARRAY dims leftover is
// * still PTR (inner `*` of i32), SLICE (inner `[]`
// * of i32), or SLICE-of-PTR (`[][2][]*T` /
// * `*[2][]*T`) vs eeek=leaf. Extra PTR wrap count
// * is unused slot dims[ndims+1] (1 = `[][2]*T` /
// * `[][2][]*T` / `*[2]*T` / `*[2][]*T`); extra
// * SLICE wrap count is unused slot dims[ndims]
// * (1 = `[][2][]T` / `[][2][]*T` / `*[2][]T` /
// * `*[2][]*T`). Peel extra SLICE first (outer extra)
// * then extra PTR (inner extra) — dest extras wraps
// * PTR of leaf then SLICE. Peel PTR first of
// * `[][2][]*T` / `*[2][]*T` is T001 (leftover SLICE
// * vs PTR). `[][2]*T` / `*[2]*T` extra SLICE=0 still
// * peels PTR; `[][2][]T` extra PTR=0 still peels
// * SLICE. `[][2]i32` / `*[2]i32` (both slots 0)
// * keeps the ARRAY-then-leaf compare. Discriminant
// * dest extras dest-SLICE of ARRAY extra `[][2]*T`
// * vs PTR-outer `*[2]*T` (same unused slot) is
// * SLICE vs PTR outer. Do not invent -3.
// * PLATFORM: SHARED. G.7: complete this walk.
// 

                      extra_ptr = 0;
                      extra = 0;
                      if (eend > 0 && eend < 8) {
                        extra = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eend) * 4);
                        }
                      if (extra > 0) {
                        while (extra > 0) {
                          if (pgek != P12G_TY_SLICE || leaf_tr == 0) {
                            mm = 1;
                            break;
                          }
                          leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                          if (leaf_tr == 0) {
                            mm = 1;
                            break;
                          }
                          pgek = pipeline_type_kind_ord_at(arena, leaf_tr);
                          extra = extra - 1;
                        }
                      }
                      if (eend > 0 && eend + 1 < 8) {
                        extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eend + 1) * 4);
                        }
                      if (extra_ptr > 0) {
                        while (extra_ptr > 0) {
                          if (pgek != P12G_TY_PTR || leaf_tr == 0) {
                            mm = 1;
                            break;
                          }
                          leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                          if (leaf_tr == 0) {
                            mm = 1;
                            break;
                          }
                          pgek = pipeline_type_kind_ord_at(arena, leaf_tr);
                          extra_ptr = extra_ptr - 1;
                        }
                      }
                      if (pgek >= 0 && pgek != eeek) {
                        mm = 1;
                      } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                        enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                        if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, leaf_tr, gnm);
                          if (xlang_skip_trait_named_eq_self_c(
                                (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                                gnm, gnl,
                                (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                                for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                        }
                      }
                    }
                  } else if (gek == eek && eek == P12G_TY_PTR) {
                    // 
// * dest extras dest-PARAM leftover extra
// * ARRAY/SLICE/PTR peels PTR-elem ndims>=1
// * `**[2][]T` / `**[2]*T` AND dest extras
// * dest-PARAM extra empty `[]` PTR-elem ndims=0
// * `**[]T` AND dest extras dest-PARAM extra STAR
// * PTR-elem ndims=0 `***T`: leftover PTR vs
// * eek=PTR is not T001 without extra ARRAY then
// * extra SLICE then extra PTR peels (store-only
// * leftover PTR vs eeek=leaf after extra ARRAY
// * peels is T001). Peel leftover PTR then ARRAY
// * dims then extra SLICE then extra PTR or T001
// * when ndims>=1. Extra SLICE wrap COUNT is unused
// * slot dims[ndims] when ndims>=1 (1 = `**[2][]T`;
// * 2 = `**[2][][]T`; 0 = no extra wrap =
// * `**[2]i32` / `**[2]*T`) and unused slot
// * dims[0] with ndims staying 0 (1 = `**[]T`;
// * 2 = `**[][]T`; 0 = no extra SLICE = `**T` /
// * `***T`). Extra PTR wrap COUNT is unused slot
// * dims[ndims+1] (1 = `**[2]*T` / `**[2][]*T`;
// * 0 = no extra PTR = `**[2]i32` / `**[2][]T`;
// * both slots = `**[2][]*T`) and unused slot
// * dims[1] with ndims staying 0 (1 = `***T`;
// * 2 = `****T`; 0 = no extra PTR = `**T`; both
// * slots = `**[]*T`). leftover skip eek=-1 was
// * false green of leftover extras never compared
// * (impl `**[2]i32` vs trait `**[2][]i32`
// * compile=0 run=2 leftover skip so leftover
// * never compares extras; impl `**[2]i32` vs
// * trait `**[2]*i32` compile=0 run=98 leftover
// * skip). Twin of leftover eek==PTR eend>0 extra
// * ARRAY then extra SLICE then extra PTR peels
// * (`**[2][]T` / `**[2]*T` dest extras dest-RET
// * already closed) AND leftover eek==PTR eend==0
// * extra SLICE then extra PTR peels (`**[]T` /
// * `***T` dest extras dest-RET already closed).
// * Extra ADDR_OF of typed `*[2][]i32` / `*[2]*i32`
// * dest-stamps via the formal (no dest extras
// * dest-PTR stamp). leftover extra SLICE peels
// * leftover eek==PTR eand==-2 (`[]*[]T` /
// * `[]*[][]T` PTR-to-SLICE of SLICE outer) peel
// * leftover SLICE extra times then leftover PTR
// * extra times (eeek compare stays inside the
// * eand==-2 branch — leftover after leftover-PTR
// * peel is SLICE vs eeek=leaf would T001 matching
// * `[]*[]T` if lifted). leftover skip leftover
// * extras never compared was false green (impl
// * `[]*i32` vs trait `[]*[]i32` compile=0 run=1
// * leftover skip). Twin of leftover eek==SLICE
// * eand==-2 extra SLICE then extra PTR peels.
// * Do not invent -3. PLATFORM: SHARED. G.7:
// * complete this walk.
// 

                    eeek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
                    pelem = pipeline_type_elem_ref_at(arena, elem);
                    eand = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                    if (eeek >= 0 && pelem != 0) {
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      if (pgek == P12G_TY_ARRAY && eand > 0) {
                        
                        
                        
                        d = 0;
              while (d < eand && pelem != 0) {

                          k = pipeline_type_kind_ord_at(arena, pelem);
                          
                          if (k != P12G_TY_ARRAY) {
                            mm = 1;
                            break;
                          }
                          gsz = pipeline_type_array_size_at(arena, pelem);
                          if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                            mm = 1;
                            break;
                          }
                          pelem = pipeline_type_elem_ref_at(arena, pelem);
                          if (pelem == 0 && d + 1 < eand) {
                            mm = 1;
                            break;
                          }
                        
                d = d + 1;
              }
                        if ((mm == 0) && pelem != 0) {
                          pgek = pipeline_type_kind_ord_at(arena, pelem);
                          }
                        extra_slice = 0;
                        if (eand > 0 && eand < 8) {
                          extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eand) * 4);
                          }
                        if (extra_slice > 0) {
                          while (extra_slice > 0) {
                            if (pgek != P12G_TY_SLICE || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_slice = extra_slice - 1;
                          }
                        }
                        extra_ptr = 0;
                        if (eand > 0 && eand + 1 < 8) {
                          extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eand + 1) * 4);
                          }
                        if (extra_ptr > 0) {
                          while (extra_ptr > 0) {
                            if (pgek != P12G_TY_PTR || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_ptr = extra_ptr - 1;
                          }
                        }
                        if (mm == 0) {
                          if (pgek >= 0 && pgek != eeek) {
                            mm = 1;
                          } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                            enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                            if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                              if (xlang_skip_trait_named_eq_self_c(
                                    (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                                    gnm, gnl,
                                    (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                                    for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                            }
                          }
                        }
                      } else if (eand == 0) {
                        
                        
                        extra_slice =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                        if (extra_slice > 0) {
                          while (extra_slice > 0) {
                            if (pgek != P12G_TY_SLICE || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_slice = extra_slice - 1;
                          }
                        }
                        extra_ptr =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (1) * 4);
                        if (extra_ptr > 0) {
                          while (extra_ptr > 0) {
                            if (pgek != P12G_TY_PTR || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_ptr = extra_ptr - 1;
                          }
                        }
                        if (mm == 0) {
                          if (pgek >= 0 && pgek != eeek) {
                            mm = 1;
                          } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                            enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                            if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                              if (xlang_skip_trait_named_eq_self_c(
                                    (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                                    gnm, gnl,
                                    (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                                    for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                            }
                          }
                        }
                      } else if (eand == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                        // 
// * leftover extra SLICE peels leftover
// * eek==PTR eand==-2 `[]*[]T` / `[]*[][]T`
// * PTR-to-SLICE of SLICE outer: leftover PTR
// * vs eek=PTR is not T001 without leftover
// * extra SLICE peels (store-only leftover
// * extras never compared leftover skip false
// * green; impl `[]*i32` vs trait `[]*[]i32`
// * compile=0 run=1 leftover skip). Extra
// * SLICE wrap COUNT is dims[0] (0 means 1 =
// * `[]*[]T`; 2 = `[]*[][]T`). Extra PTR wrap
// * COUNT is unused slot dims[1] (1 =
// * `[]*[]*T`; 2 = `[]*[]**T`; 0 = no extra
// * PTR = `[]*[]T`). Peel leftover SLICE extra
// * times then leftover PTR extra times or
// * T001. Twin of leftover eek==SLICE
// * eand==-2 extra SLICE then extra PTR peels
// * (`[][][]T` / `[][][]*T` already closed)
// * AND leftover eek==ARRAY eand==-2 extra
// * SLICE peels (`[2]*[]T` already closed)
// * AND leftover eek==PTR eend==-2 extra
// * SLICE then extra PTR peels (`*[][]T` /
// * `*[][]*T` dest extras dest-RET already
// * closed). Extra ADDR_OF of typed dest
// * dest-stamps via the formal (no dest extras
// * dest-PTR stamp). Do not lift eeek compare
// * outside this branch — leftover after
// * leftover-PTR peel is SLICE vs eeek=leaf
// * would T001 matching `[]*[]T`. Do not
// * invent -3. PLATFORM: SHARED. G.7:
// * complete this walk.
// 

                        
                        
                        extra =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                        if (extra <= 0) {
                          extra = 1;
                          }
                        while (extra > 0) {
                          if (pgek != P12G_TY_SLICE || pelem == 0) {
                            mm = 1;
                            break;
                          }
                          pelem = pipeline_type_elem_ref_at(arena, pelem);
                          if (pelem == 0) {
                            mm = 1;
                            break;
                          }
                          pgek = pipeline_type_kind_ord_at(arena, pelem);
                          extra = extra - 1;
                        }
                        extra_ptr =
                            p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (1) * 4);
                        if (extra_ptr > 0) {
                          while (extra_ptr > 0) {
                            if (pgek != P12G_TY_PTR || pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pelem = pipeline_type_elem_ref_at(arena, pelem);
                            if (pelem == 0) {
                              mm = 1;
                              break;
                            }
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                            extra_ptr = extra_ptr - 1;
                          }
                        }
                        if (mm == 0) {
                          if (pgek >= 0 && pgek != eeek) {
                            mm = 1;
                          } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                            enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                            if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                              if (xlang_skip_trait_named_eq_self_c(
                                    (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                                    gnm, gnl,
                                    (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                                    for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else if (got_pk == ek && ek == P12G_TY_ARRAY) {
                // 
// * wave433: walk nested TYPE_ARRAY dims[0]=outer … then leaf elem
// * kind/name. Twin of wave431 ret multi-dim walk.
// * PLATFORM: SHARED parse.
// 

                nd = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                eek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
                leaf_tr = pty;
                if (nd > 0 && pty != 0) {
                  
                  d = 0;
              while (d < nd) {

                    k = pipeline_type_kind_ord_at(arena, leaf_tr);
                    
                    if (k != P12G_TY_ARRAY) {
                      mm = 1;
                      break;
                    }
                    gsz = pipeline_type_array_size_at(arena, leaf_tr);
                    if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                      mm = 1;
                      break;
                    }
                    leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                    if (leaf_tr == 0 && d + 1 < nd) {
                      mm = 1;
                      break;
                    }
                  
                d = d + 1;
              }
                  if ((mm == 0) && eek >= 0 && leaf_tr != 0) {
                    gek = pipeline_type_kind_ord_at(arena, leaf_tr);
                    if (gek >= 0 && gek != eek) {
                      mm = 1;
                    } else if (gek == eek && eek == P12G_TY_NAMED) {
                      enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                      if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, leaf_tr, gnm);
                        if (xlang_skip_trait_named_eq_self_c(
                              (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                              gnm, gnl,
                              (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                              for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                      }
                    } else if (gek == eek && eek == P12G_TY_PTR) {
                      // 
// * wave434: *T[N] → ARRAY of PTR (type syntax: [] binds tighter
// * than *). Walk pipeline ARRAY leaf (must be PTR) → its elem →
// * compare elem_elem (the *T base). PLATFORM: SHARED parse.
// 

                      eeek = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ELEM_KINDS + mi * P12G_PARAM_KINDS_ROW + pi * 4);
                      pelem = pipeline_type_elem_ref_at(arena, leaf_tr);
                      if (eeek >= 0 && pelem != 0) {
                        pgek = pipeline_type_kind_ord_at(arena, pelem);
                        // 
// * wave774: PTR pointee may be ARRAY/SLICE (e.g.
// * *[2]i32 or *[]i32). eeek holds the LEAF kind
// * (i32=0), not the direct pointee kind (ARRAY=10 /
// * SLICE=11). Walk elem_array_ndims dims (or -2 for
// * SLICE) to reach the leaf, then compare. Without
// * this, [2]*[2]i32 and [2]*[]i32 trait/impl params
// * mismatch (eeek=0 vs pgek=10/11).
// * dest extras dest-ARRAY of PTR `[2]*[][]T`: extra
// * wrap count is dims[0] (0 means 1 = `[2]*[]T`;
// * 2 = `[2]*[][]T`). Peel extra times when
// * ndims==-2 or T001 if layers run out. Peel-once
// * left pelem still SLICE vs eeek=leaf. Twin of
// * SLICE-of-SLICE extra peel above. Do not invent
// * -3. PLATFORM: SHARED. G.7: complete this walk.
// 

                        if (pgek == P12G_TY_ARRAY || pgek == P12G_TY_SLICE) {
                          eand = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_NDIMS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                          if (eand > 0) {
                            
                            
                            
                            ed = 0;
              while (ed < eand && pelem != 0) {

                              pelem = pipeline_type_elem_ref_at(arena, pelem);
                            
                ed = ed + 1;
              }
                            if (pelem != 0) {
                              pgek = pipeline_type_kind_ord_at(arena, pelem);
                            }
                            // 
// * dest extras dest-ARRAY of PTR extra
// * `[2]*[2]*T` / `[2]*[2][]*T`: leftover
// * after extra ARRAY peels is PTR vs
// * eeek=leaf (store-only T001). Extra
// * SLICE wrap COUNT is unused slot
// * dims[ndims] (1 = `[2]*[2][]T`; 0 = no
// * extra wrap = `[2]*[2]i32`). Extra PTR
// * wrap COUNT is unused slot
// * dims[ndims+1] (1 = `[2]*[2]*T`; 0 =
// * no extra PTR = `[2]*[2]i32`;
// * `[2]*[2][]*T` has both slots set).
// * Peel leftover SLICE extra times then
// * leftover PTR extra times or T001.
// * dest extras dest-SLICE of PTR extra
// * `[]*[2]*T` uses the same
// * dims[ndims+1] encoding (SLICE leftover
// * matches at leftover PTR vs eek=PTR —
// * not this walk; not T001). Discriminant
// * is ARRAY vs SLICE outer. Do not invent
// * -3. PLATFORM: SHARED. G.7: complete
// * this walk.
// 

                            extra_slice = 0;
                            if (eand < 8) {
                              extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eand) * 4);
                              }
                            if (extra_slice > 0) {
                              while (extra_slice > 0) {
                                if (pgek != P12G_TY_SLICE || pelem == 0) {
                                  mm = 1;
                                  break;
                                }
                                pelem = pipeline_type_elem_ref_at(arena, pelem);
                                if (pelem == 0) {
                                  mm = 1;
                                  break;
                                }
                                pgek = pipeline_type_kind_ord_at(arena, pelem);
                                extra_slice = extra_slice - 1;
                              }
                            }
                            extra_ptr = 0;
                            if (eand + 1 < 8) {
                              extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (eand + 1) * 4);
                              }
                            if (extra_ptr > 0) {
                              while (extra_ptr > 0) {
                                if (pgek != P12G_TY_PTR || pelem == 0) {
                                  mm = 1;
                                  break;
                                }
                                pelem = pipeline_type_elem_ref_at(arena, pelem);
                                if (pelem == 0) {
                                  mm = 1;
                                  break;
                                }
                                pgek = pipeline_type_kind_ord_at(arena, pelem);
                                extra_ptr = extra_ptr - 1;
                              }
                            }
                          } else if (eand == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                            extra =
                                p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW + pi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                            if (extra <= 0) {
                              extra = 1;
                              }
                            while (extra > 0) {
                              if (pgek != P12G_TY_SLICE || pelem == 0) {
                                mm = 1;
                                break;
                              }
                              pelem = pipeline_type_elem_ref_at(arena, pelem);
                              if (pelem == 0) {
                                mm = 1;
                                break;
                              }
                              pgek = pipeline_type_kind_ord_at(arena, pelem);
                              extra = extra - 1;
                            }
                          } else if (pelem != 0) {
                            pgek = pipeline_type_kind_ord_at(arena, pelem);
                          }
                        }
                        if (pgek >= 0 && pgek != eeek) {
                          mm = 1;
                        } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                          enl = p12g_load_i32(ent, P12G_OFF_METHOD_PARAM_NAME_LENS + mi * P12G_PARAM_LENS_ROW + pi * 4);
                          if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                            if (xlang_skip_trait_named_eq_self_c(
                                  (ent + ((P12G_OFF_METHOD_PARAM_NAMES + mi * P12G_PARAM_NAME_ROW + pi * P12G_PARAM_NAME_INNER) as usize)), enl,
                                  gnm, gnl,
                                  (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                                  for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                          }
                        }
                      }
                    }
                  }
                }
              }
              if (mm != 0) {
                return xlang_skip_trait_check_diag_param_type_c(si, mnm, mlen);
              }
            }
          
                        }
            pi = pi + 1;
}
          // 
// * wave428: trait wrote untyped self (param0 ek=-1) → require impl param0
// * matches `for` type (builtin / named / *T).
// * wave429: also when trait annotated self (ek0>=0) — was false-green:
// *   trait Double { double(self: i32) } + impl for u64 { double(self: i32) }
// *   passed param-type (matches trait) but for-type was ignored → call on i32 run=42.
// * wave441: logic extracted to xlang_skip_impl_self_matches_for_c (shared
// *   with method lookup); helper returns 1 when for-type unknown or self
// *   untyped (preserve old skip behavior). PLATFORM: SHARED parse.
// 

          if (expect_np >= 1) {
            pty0 = pipeline_module_func_param_type_ref_at(module, found_fi, 0);
            if ((xlang_skip_impl_self_matches_for_into_c(arena, pty0, for_kinds[si], for_is_ptr[si], for_names + ((si as usize) * (64 as usize)), for_name_lens[si], gnm) == 0)) {
              return xlang_skip_trait_check_diag_self_type_c(si, mnm, mlen);
            }
          }
  return 0;

    return 0;
  }
  return 0;
  return 0;
}
/**
 * P12v ret shape核. C trampoline owns gnm + fat tables.
 * PLATFORM: SHARED — same SHAPE gate as param; do not merge into P12u outer.
 */
#[no_mangle]
export function xlang_skip_trait_check_ret_shape_x_into_c(
    module: *u8, arena: *u8, found_fi: i32, si: i32, ti: i32, mi: i32,
    mnm: *u8, mlen: i32,
    table: *u8, stride: i32,
    for_is_ptr: *i32, for_names: *u8, for_name_lens: *i32,
    gnm: *u8): i32 {
  let d: i32 = 0;
  let ed: i32 = 0;
  let eeek: i32 = 0;
  let eek: i32 = 0;
  let eend: i32 = 0;
  let elem: i32 = 0;
  let enl: i32 = 0;
  let esz: i32 = 0;
  let expect_k: i32 = 0;
  let extra: i32 = 0;
  let extra_ptr: i32 = 0;
  let extra_slice: i32 = 0;
  let gek: i32 = 0;
  let gnl: i32 = 0;
  let got_k: i32 = 0;
  let gsz: i32 = 0;
  let k: i32 = 0;
  let leaf_tr: i32 = 0;
  let mm: i32 = 0;
  let nd: i32 = 0;
  let pelem: i32 = 0;
  let pgek: i32 = 0;
  let rty: i32 = 0;
  let ent: *u8 = 0 as *u8;
  if (module == 0 as *u8 || arena == 0 as *u8 || found_fi < 0) {
    return 0;
  }
  if (si < 0 || si >= 16) {
    return 0;
  }
  if (ti < 0 || ti >= SKIP_TRAIT_REG_MAX) {
    return 0;
  }
  if (mi < 0 || mi >= 32) {
    return 0;
  }
  if (mnm == 0 as *u8 || mlen <= 0) {
    return 0;
  }
  if (table == 0 as *u8 || stride <= 0 || for_is_ptr == 0 as *i32 || for_names == 0 as *u8 || for_name_lens == 0 as *i32 || gnm == 0 as *u8) {
    return 0;
  }
  unsafe {
    ent = table + ((ti as usize) * (stride as usize));

expect_k = p12g_load_i32(ent, P12G_OFF_METHOD_RET_KINDS + mi * 4);
  if (expect_k < 0) {
    return 0;
    }
        rty = pipeline_module_func_return_type_at(module, found_fi);
        got_k = -1;
        if (rty != 0) {
          got_k = pipeline_type_kind_ord_at(arena, rty);
        }
        mm = 0;
        if (got_k >= 0 && got_k != expect_k) {
          mm = 1;
        } else if (got_k == expect_k && expect_k == P12G_TY_NAMED) {
          enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
          if (enl > 0 && rty != 0) {
gnl = pipeline_type_named_name_into(arena, rty, gnm);
            if (xlang_skip_trait_named_eq_self_c(
                  (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                  gnm, gnl,
                  (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                  for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
          }
        } else if (got_k == expect_k && expect_k == P12G_TY_ARRAY) {
          // 
// * wave431: walk nested TYPE_ARRAY dims[0]=outer … then leaf elem kind/name.
// * ndims==0 falls back to wave430 single outer size + one elem.
// * PLATFORM: SHARED parse.
// 

          nd = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ARRAY_NDIMS + mi * 4);
          eek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4);
          leaf_tr = rty;
          if (nd > 0 && rty != 0) {
            
            d = 0;
              while (d < nd) {

              k = pipeline_type_kind_ord_at(arena, leaf_tr);
              
              if (k != P12G_TY_ARRAY) {
                mm = 1;
                break;
              }
              gsz = pipeline_type_array_size_at(arena, leaf_tr);
              if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_RET_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                mm = 1;
                break;
              }
              leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
              if (leaf_tr == 0 && d + 1 < nd) {
                mm = 1;
                break;
              }
            
                d = d + 1;
              }
            if ((mm == 0) && eek >= 0 && leaf_tr != 0) {
              gek = pipeline_type_kind_ord_at(arena, leaf_tr);
              if (gek >= 0 && gek != eek) {
                mm = 1;
              } else if (gek == eek && eek == P12G_TY_NAMED) {
                enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, leaf_tr, gnm);
                  if (xlang_skip_trait_named_eq_self_c(
                        (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                        gnm, gnl,
                        (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                        for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                }
              } else if (gek == eek && eek == P12G_TY_PTR) {
                // 
// * wave438: *T[N] → ARRAY of PTR (type syntax: [] binds tighter
// * than *). Walk pipeline ARRAY leaf (must be PTR) → its elem →
// * compare elem_elem (the *T base). Twin of wave434 param *T[N]
// * check. PLATFORM: SHARED parse.
// 

                eeek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4);
                pelem = pipeline_type_elem_ref_at(arena, leaf_tr);
                if (eeek >= 0 && pelem != 0) {
                  pgek = pipeline_type_kind_ord_at(arena, pelem);
                  if (pgek >= 0 && pgek != eeek) {
                    mm = 1;
                  } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                    enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                    if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                      if (xlang_skip_trait_named_eq_self_c(
                            (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                            gnm, gnl,
                            (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                            for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                    }
                  }
                }
              }
            }
          } else {
            elem = 0;
                if (rty != 0) {
                  elem = pipeline_type_elem_ref_at(arena, rty);
                }
            esz = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ARRAY_SIZES + mi * 4);
            if (esz >= 0 && rty != 0) {
              gsz = pipeline_type_array_size_at(arena, rty);
              if (gsz != esz) {
                mm = 1;
                }
            }
            if ((mm == 0) && eek >= 0 && elem != 0) {
              gek = pipeline_type_kind_ord_at(arena, elem);
              if (gek >= 0 && gek != eek) {
                mm = 1;
              } else if (gek == eek && eek == P12G_TY_NAMED) {
                enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, elem, gnm);
                  if (xlang_skip_trait_named_eq_self_c(
                        (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                        gnm, gnl,
                        (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                        for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                }
              } else if (gek == eek && eek == P12G_TY_PTR) {
                // 
// * wave438: *T[N] single-dim (nd==0 fallback) → ARRAY of PTR.
// * Walk pipeline ARRAY leaf (must be PTR) → its elem → compare
// * elem_elem (the *T base). Twin of wave434 param *T[N] check.
// * PLATFORM: SHARED parse.
// 

                eeek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4);
                pelem = pipeline_type_elem_ref_at(arena, elem);
                if (eeek >= 0 && pelem != 0) {
                  pgek = pipeline_type_kind_ord_at(arena, pelem);
                  if (pgek >= 0 && pgek != eeek) {
                    mm = 1;
                  } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                    enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                    if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                      if (xlang_skip_trait_named_eq_self_c(
                            (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                            gnm, gnl,
                            (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                            for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                    }
                  }
                }
              }
            }
          }
        } else if (got_k == expect_k &&
                   (expect_k == P12G_TY_PTR || expect_k == P12G_TY_SLICE)) {
          eek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_KINDS + mi * 4);
          elem = 0;
                if (rty != 0) {
                  elem = pipeline_type_elem_ref_at(arena, rty);
                }
          if ((mm == 0) && eek >= 0 && elem != 0) {
            gek = pipeline_type_kind_ord_at(arena, elem);
            if (gek >= 0 && gek != eek) {
              mm = 1;
            } else if (gek == eek && eek == P12G_TY_NAMED) {
              enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
              if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, elem, gnm);
                if (xlang_skip_trait_named_eq_self_c(
                      (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                      gnm, gnl,
                      (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                      for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
              }
            } else if (gek == eek && eek == P12G_TY_PTR) {
              // 
// * wave954: leftover extra SLICE peels leftover eek=PTR
// * eand=-2 []*[]T / []*[][]T RET twin. After outer PTR or
// * SLICE (got_k==expect_k: PTR outer *[]*T vs SLICE outer
// * []*[]T both reach this via eek==PTR elem vs gek==PTR
// * elem of impl), walk pointee ARRAY/SLICE ndims or PTR-
// * to-SLICE sentinel (-2) to reach the leaf, then compare
// * eeek (the leaf kind). Without this, impl []*i32 vs
// * trait []*[]i32 RET (eeek=leaf i32 vs leftover SLICE of
// * impl ptr-pointee) compiled=0 T001 leftover skip false
// * green. Produce: leftover PTR vs eek=PTR matched then
// * eend=-2 did not peel extra SLICE (store-only leftover
// * extras never compared = leftover skip false green).
// * Storage already complete (elem=PTR / eek=leaf /
// * ndims=-2 / dims[0]=N extra SLICE / dims[1]=extra PTR).
// * Discriminant vs dest extras dest-RET extra STAR
// * SLICE-elem ndims=-2 *[][]*T (RET eek=SLICE not PTR)
// * is eek=PTR vs eek=SLICE. Consume: leftover PTR vs
// * eek=PTR non-T001 must first peel leftover PTR then
// * extra SLICE then extra PTR. Peel leftover ARRAY when
// * eend>=1 (discriminant vs *[]*T eend=0 which takes the
// * no-peel direct compare path). Peel extra SLICE extra
// * times from dims[eend+1] (eend>=1) or dims[0]
// * (eend=-2 PTR_TO_SLICE sentinel; 0 means 1 extra SLICE
// * like *[][]T). Peel extra PTR extra times from
// * dims[eend] (eend>=1) or dims[1] (eend=-2). Then
// * compare pgek vs eeek (or T001 if peel fails). Twin of
// * param leftover PTR vs eek=PTR walk (param line 3584
// * already closed). Do not invent -3. PLATFORM: SHARED
// * parse. G.7: complete this walk for the RET twin.
// 

              eeek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4);
              pelem = pipeline_type_elem_ref_at(arena, elem);
              if (eeek >= 0 && pelem != 0) {
                pgek = pipeline_type_kind_ord_at(arena, pelem);
                eend = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
                // 
// * wave954: leftover ARRAY/SLICE/PTR walk must happen
// * whenever eend>=1 or eend==PTR_TO_SLICE(-2), REGARDLESS
// * of current pgek. Before wave954: gated on
// * `pgek==ARRAY || pgek==SLICE` which skipped the walk
// * for impl `[]*i32` vs trait `[]*[]i32` (pelem is
// * PTR→i32, pgek=I32, not SLICE/ARRAY) — eend=-2
// * extra=1 never peeled; pgek=I32==eeek=I32 false green.
// * Peel flow: if eend>=1 → ARRAY peels + extra SLICE +
// * extra PTR; if eend==-2 → extra SLICE + extra PTR;
// * else (eend==0) → no leftover peel, direct compare
// * (classic case like `*T` or `**T` with no extra dims).
// * Each peel step T001 on kind mismatch. Twin of param
// * line 3449 (eand==-2 walk) and param line 3395
// * (eand==0 extra SLICE/PTR walk). PLATFORM: SHARED.
// 

                if (eend > 0) {
                  if (pgek == P12G_TY_ARRAY) {
                    
                    
                    
                    ed = 0;
              while (ed < eend && pelem != 0) {

                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                    
                ed = ed + 1;
              }
                    if (pelem != 0) {
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                    }
                    extra_slice = 0;
                    if (eend < 8) {
                      extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend + 1) * 4);
                      }
                    if (extra_slice > 0) {
                      while (extra_slice > 0) {
                        if (pgek != P12G_TY_SLICE || pelem == 0) {
                          mm = 1;
                          break;
                        }
                        pelem = pipeline_type_elem_ref_at(arena, pelem);
                        if (pelem == 0) {
                          mm = 1;
                          break;
                        }
                        pgek = pipeline_type_kind_ord_at(arena, pelem);
                        extra_slice = extra_slice - 1;
                      }
                    }
                    extra_ptr = 0;
                    if (eend < 8) {
                      extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend) * 4);
                      }
                    if (extra_ptr > 0) {
                      while (extra_ptr > 0) {
                        if (pgek != P12G_TY_PTR || pelem == 0) {
                          mm = 1;
                          break;
                        }
                        pelem = pipeline_type_elem_ref_at(arena, pelem);
                        if (pelem == 0) {
                          mm = 1;
                          break;
                        }
                        pgek = pipeline_type_kind_ord_at(arena, pelem);
                        extra_ptr = extra_ptr - 1;
                      }
                    }
                  } else {
                    mm = 1;
                  }
                } else if (eend == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                  // 
// * PTR_TO_SLICE sentinel eend=-2: extra SLICE wrap
// * COUNT in dims[0] (0 means 1 = []*[]T / *[]T;
// * 2 = []*[][]T). Extra PTR wrap COUNT in dims[1]
// * (1 = []*[]*T; 2 = []*[]**T; 0 = no extra PTR =
// * []*[]T / *[]T). Peel SLICE extra times then
// * PTR extra times or T001. Twin of param line 3449
// * (PARAM path, already closed 875d557e2). Do not
// * invent -3. PLATFORM: SHARED parse.
// 

                  extra =
                      p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                  if (extra <= 0) {
                    extra = 1;
                    }
                  while (extra > 0) {
                    if (pgek != P12G_TY_SLICE || pelem == 0) {
                      mm = 1;
                      break;
                    }
                    pelem = pipeline_type_elem_ref_at(arena, pelem);
                    if (pelem == 0) {
                      mm = 1;
                      break;
                    }
                    pgek = pipeline_type_kind_ord_at(arena, pelem);
                    extra = extra - 1;
                  }
                  if (mm == 0) {
                    extra_ptr =
                        p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (1) * 4);
                    if (extra_ptr > 0) {
                      while (extra_ptr > 0) {
                        if (pgek != P12G_TY_PTR || pelem == 0) {
                          mm = 1;
                          break;
                        }
                        pelem = pipeline_type_elem_ref_at(arena, pelem);
                        if (pelem == 0) {
                          mm = 1;
                          break;
                        }
                        pgek = pipeline_type_kind_ord_at(arena, pelem);
                        extra_ptr = extra_ptr - 1;
                      }
                    }
                  }
                }
                if ((mm == 0) && pgek >= 0 && pgek != eeek) {
                  mm = 1;
                } else if ((mm == 0) && pgek == eeek && eeek == P12G_TY_NAMED) {
                  enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                  if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                    if (xlang_skip_trait_named_eq_self_c(
                          (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                          gnm, gnl,
                          (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                          for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                  }
                }
              }
            } else if (gek == eek && eek == P12G_TY_SLICE) {
              // 
// * wave438: *[]T → PTR to SLICE of T. Walk pipeline SLICE
// * leaf → its elem → compare elem_elem (the slice base T).
// * dest extras dest-RET extra empty `[]` SLICE-elem
// * `*[][2][]T`: leftover SLICE vs eek=SLICE is not T001
// * without extra ARRAY peels (store-only leftover ARRAY
// * vs eeek=leaf after leftover-SLICE peel is T001). Peel
// * leftover SLICE then extra ARRAY then extra SLICE then
// * extra PTR or T001. Extra SLICE wrap COUNT is unused
// * slot dims[ndims+1] (1 = `*[][2][]T`; 2 =
// * `*[][2][][]T`; 0 = no extra wrap = `*[][2]i32` /
// * `*[][2]*T`). Extra PTR wrap COUNT is unused slot
// * dims[ndims] (1 = `*[][2]*T` / `*[][2][]*T`; 0 = no
// * extra PTR = `*[][2]i32` / `*[][2][]T`; `*[][2][]*T`
// * has both slots set). leftover skip eek=-1 was false
// * green of extra empty `[]` SLICE-elem (impl
// * `*[][2]i32` vs trait `*[][2][]i32` compile=0;
// * dest-stamp via the local of typed dest = false
// * green even Ubuntu). dest extras dest-RET extra STAR
// * SLICE-elem ndims=0 `*[]*T`: extra PTR wrap COUNT is
// * unused slot dims[0] with ndims staying 0 (1 =
// * `*[]*T`; 2 = `*[]**T`; 0 = no extra PTR = `*[]i32`).
// * leftover skip eek=-1 was false green (impl `*[]i32`
// * vs trait `*[]*i32` compile=0; dest-stamp via the
// * local of typed dest = false green even Ubuntu). Peel
// * leftover PTR extra times or T001. `*[]T` (ndims=0
// * extra PTR=0) keeps leftover SLICE vs eek=SLICE
// * (pointee compare eeek). Twin of param leftover PTR
// * vs eek=SLICE extra ARRAY-then-SLICE-then-PTR peels
// * (`*[][2][]T` param already closed) and param extra
// * STAR ndims=0 leftover eand==0 extra PTR peels
// * (`*[]*T` param already closed). Discriminant vs dest
// * extras dest-RET extra empty `[]` ARRAY-elem `*[2][]T`
// * / PTR-elem `**[2][]T` is SLICE vs ARRAY vs PTR elem.
// * Extra ADDR_OF of typed `[][2][]i32` dest-stamps via
// * the formal leftover skip eek=-1 was false green. Do
// * not invent -3. PLATFORM: SHARED. G.7: complete this
// * walk.
// 

              eeek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4);
              pelem = pipeline_type_elem_ref_at(arena, elem);
              if (eeek >= 0 && pelem != 0) {
                pgek = pipeline_type_kind_ord_at(arena, pelem);
                eend = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
                if (eend >= 1) {
                  
                  
                  
                  d = 0;
              while (d < eend && pelem != 0) {

                    k = pipeline_type_kind_ord_at(arena, pelem);
                    
                    if (k != P12G_TY_ARRAY) {
                      mm = 1;
                      break;
                    }
                    gsz = pipeline_type_array_size_at(arena, pelem);
                    if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                      mm = 1;
                      break;
                    }
                    pelem = pipeline_type_elem_ref_at(arena, pelem);
                    if (pelem == 0 && d + 1 < eend) {
                      mm = 1;
                      break;
                    }
                  
                d = d + 1;
              }
                  if ((mm == 0) && pelem != 0) {
                    pgek = pipeline_type_kind_ord_at(arena, pelem);
                    }
                  extra_slice = 0;
                  if (eend > 0 && eend + 1 < 8) {
                    extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend + 1) * 4);
                    }
                  if (extra_slice > 0) {
                    while (extra_slice > 0) {
                      if (pgek != P12G_TY_SLICE || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_slice = extra_slice - 1;
                    }
                  }
                  extra_ptr = 0;
                  if (eend > 0 && eend < 8) {
                    extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend) * 4);
                    }
                  if (extra_ptr > 0) {
                    while (extra_ptr > 0) {
                      if (pgek != P12G_TY_PTR || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_ptr = extra_ptr - 1;
                    }
                  }
                } else if (eend == 0) {
                  // 
// * dest extras dest-RET extra STAR SLICE-elem
// * ndims=0 `*[]*T`: leftover after leftover-SLICE
// * peel is PTR vs eeek=leaf. Extra PTR wrap COUNT
// * is unused slot dims[0] (1 = `*[]*T`; 2 =
// * `*[]**T`; 0 = no extra PTR = `*[]i32`). Peel
// * leftover PTR extra times or T001. Twin of param
// * leftover eand==0 extra PTR peels. Do not invent
// * -3. PLATFORM: SHARED. G.7: complete this walk.
// 

                  
                  extra_ptr =
                      p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                  if (extra_ptr > 0) {
                    while (extra_ptr > 0) {
                      if (pgek != P12G_TY_PTR || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_ptr = extra_ptr - 1;
                    }
                  }
                } else if (eend == P12G_ELEM_PTR_TO_SLICE_NDIMS) {
                  // 
// * dest extras dest-RET extra STAR SLICE-elem
// * ndims=-2 `*[][]*T`: leftover after leftover-
// * SLICE peel is still SLICE vs eeek=leaf. Extra
// * SLICE wrap COUNT is dims[0] (0 means 1 =
// * `*[][]T`; 2 = `*[][][]T`). Extra PTR wrap
// * COUNT is unused slot dims[1] (1 = `*[][]*T`;
// * 2 = `*[][]**T`; 0 = no extra PTR = `*[][]T`).
// * Peel leftover SLICE extra times then leftover
// * PTR extra times or T001. Twin of param leftover
// * eand==-2 extra SLICE then extra PTR peels
// * (`*[][]*T` param already closed). Do not invent
// * -3. PLATFORM: SHARED. G.7: complete this walk.
// 

                  
                  
                  extra =
                      p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                  if (extra <= 0) {
                    extra = 1;
                    }
                  while (extra > 0) {
                    if (pgek != P12G_TY_SLICE || pelem == 0) {
                      mm = 1;
                      break;
                    }
                    pelem = pipeline_type_elem_ref_at(arena, pelem);
                    if (pelem == 0) {
                      mm = 1;
                      break;
                    }
                    pgek = pipeline_type_kind_ord_at(arena, pelem);
                    extra = extra - 1;
                  }
                  extra_ptr =
                      p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (1) * 4);
                  if (extra_ptr > 0) {
                    while (extra_ptr > 0) {
                      if (pgek != P12G_TY_PTR || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_ptr = extra_ptr - 1;
                    }
                  }
                }
                if (mm == 0) {
                  if (pgek >= 0 && pgek != eeek) {
                    mm = 1;
                  } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                    enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                    if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                      if (xlang_skip_trait_named_eq_self_c(
                            (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                            gnm, gnl,
                            (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                            for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                    }
                  }
                }
              }
            } else if (gek == eek && eek == P12G_TY_ARRAY) {
              // 
// * wave438: *[N]T / *[N][M]T → PTR to ARRAY of N T. The PTR's
// * elem (elem) is the ARRAY. Walk its dims (elem_array_ndims/
// * dims) then compare the leaf elem kind/name with elem_elem
// * (base T). Multi-dim *[N][M]T collected at registration
// * (wave437 twin). PLATFORM: SHARED parse.
// 

              eeek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4);
              eend = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
              leaf_tr = elem;
              
              d = 0;
              while (d < eend && leaf_tr != 0) {

                k = pipeline_type_kind_ord_at(arena, leaf_tr);
                
                if (k != P12G_TY_ARRAY) {
                  mm = 1;
                  break;
                }
                gsz = pipeline_type_array_size_at(arena, leaf_tr);
                if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                  mm = 1;
                  break;
                }
                leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                if (leaf_tr == 0 && d + 1 < eend) {
                  mm = 1;
                  break;
                }
              
                d = d + 1;
              }
              if ((mm == 0) && eeek >= 0 && leaf_tr != 0) {
                pgek = pipeline_type_kind_ord_at(arena, leaf_tr);
                // 
// * dest extras dest-RET PTR-to-ARRAY extra empty `[]`
// * `*[2][]T` AND dest extras dest-RET extra STAR
// * `*[2]*T`: leftover after ARRAY peels is SLICE /
// * PTR / SLICE-of-PTR vs eeek=leaf (store-only
// * T001). Extra SLICE wrap COUNT is unused slot
// * dims[ndims] (1 = `*[2][]T`; 0 = no extra wrap =
// * `*[2]i32`). Extra PTR wrap COUNT is unused slot
// * dims[ndims+1] (1 = `*[2]*T` / `*[2][]*T`; 0 = no
// * extra PTR = `*[2]i32` / `*[2][]T`; `*[2][]*T`
// * has both slots set). Peel leftover SLICE extra
// * times then leftover PTR extra times or T001.
// * Extra ADDR_OF of typed `[2]*i32` dest-stamps via
// * the formal leftover skip eek=-1 was false green;
// * dest extras dest-RET wrap-once dest-stamps
// * `*[2]i32`. Twin of param ARRAY leftover extra
// * SLICE-then-PTR peels. Do not invent -3.
// * PLATFORM: SHARED. G.7: complete this walk.
// 

                extra_slice = 0;
                extra_ptr = 0;
                if (eend > 0 && eend < 8) {
                  extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend) * 4);
                  }
                if (extra_slice > 0) {
                  while (extra_slice > 0) {
                    if (pgek != P12G_TY_SLICE || leaf_tr == 0) {
                      mm = 1;
                      break;
                    }
                    leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                    if (leaf_tr == 0) {
                      mm = 1;
                      break;
                    }
                    pgek = pipeline_type_kind_ord_at(arena, leaf_tr);
                    extra_slice = extra_slice - 1;
                  }
                }
                if (eend > 0 && eend + 1 < 8) {
                  extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend + 1) * 4);
                  }
                if (extra_ptr > 0) {
                  while (extra_ptr > 0) {
                    if (pgek != P12G_TY_PTR || leaf_tr == 0) {
                      mm = 1;
                      break;
                    }
                    leaf_tr = pipeline_type_elem_ref_at(arena, leaf_tr);
                    if (leaf_tr == 0) {
                      mm = 1;
                      break;
                    }
                    pgek = pipeline_type_kind_ord_at(arena, leaf_tr);
                    extra_ptr = extra_ptr - 1;
                  }
                }
                if (mm == 0) {
                  if (pgek >= 0 && pgek != eeek) {
                    mm = 1;
                  } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                    enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                    if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, leaf_tr, gnm);
                      if (xlang_skip_trait_named_eq_self_c(
                            (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                            gnm, gnl,
                            (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                            for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                    }
                  }
                }
              }
            } else if (gek == eek && eek == P12G_TY_PTR) {
              // 
// * dest extras dest-RET extra STAR PTR-elem `**[2]*T`
// * AND dest extras dest-RET extra empty `[]` PTR-elem
// * `**[2][]T` / `**[]T`: leftover PTR vs eek=PTR is
// * not T001 without extra ARRAY peels (store-only
// * leftover PTR vs eeek=leaf after extra ARRAY peels
// * is T001). Peel leftover PTR then ARRAY dims then
// * extra SLICE then extra PTR or T001. Extra SLICE
// * wrap COUNT is unused slot dims[ndims] when
// * ndims>=1 (1 = `**[2][]T`; 0 = no extra wrap =
// * `**[2]i32`) and unused slot dims[0] with ndims
// * staying 0 (1 = `**[]T`; 2 = `**[][]T`; 0 = no
// * extra SLICE = `**T` / `***T`). Extra PTR wrap
// * COUNT is unused slot dims[ndims+1] (1 = `**[2]*T`
// * / `**[2][]*T`; 0 = no extra PTR = `**[2]i32` /
// * `**[2][]T`; `**[2][]*T` has both slots set) and
// * unused slot dims[1] with ndims staying 0 (1 =
// * `***T`; 2 = `****T`; 0 = no extra PTR = `**T`;
// * both slots = `**[]*T`). leftover skip eek=-1 was
// * false green of extra empty `[]` PTR-elem (impl
// * `**[2]i32` / `**i32` vs trait `**[2][]i32` /
// * `**[]i32` compile=0). dest extras dest-RET extra
// * STAR PTR-elem ndims=0 `***T`: extra PTR wrap
// * COUNT is unused slot dims[1]. leftover skip
// * eek=-1 was false green (impl `**i32` vs trait
// * `***i32` compile=0; dest-stamp via the local of
// * typed dest = false green even Ubuntu). Peel
// * leftover PTR extra times or T001. `**i32`
// * (ndims=0 extra PTR=0 extra SLICE=0) keeps leftover
// * PTR vs eek=PTR (pointee compare eeek). Twin of
// * leftover eek==SLICE eend==0 extra PTR peels
// * (`*[]*T` already closed). Discriminant vs dest
// * extras dest-RET extra STAR ARRAY-elem `*[2]*T` /
// * extra empty `[]` ARRAY-elem `*[2][]T` is PTR vs
// * ARRAY elem. Extra ADDR_OF of typed `*[2]*i32`
// * dest-stamps via the formal leftover skip eek=-1
// * was false green; dest extras dest-RET wrap-once
// * dest-stamps `**[2]i32` / `**i32`. Do not invent
// * -3. PLATFORM: SHARED. G.7: complete this walk.
// 

              eeek = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ELEM_KINDS + mi * 4);
              pelem = pipeline_type_elem_ref_at(arena, elem);
              if (eeek >= 0 && pelem != 0) {
                pgek = pipeline_type_kind_ord_at(arena, pelem);
                eend = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_NDIMS + mi * 4);
                if (pgek == P12G_TY_ARRAY && eend > 0) {
                  
                  
                  
                  d = 0;
              while (d < eend && pelem != 0) {

                    k = pipeline_type_kind_ord_at(arena, pelem);
                    
                    if (k != P12G_TY_ARRAY) {
                      mm = 1;
                      break;
                    }
                    gsz = pipeline_type_array_size_at(arena, pelem);
                    if (gsz != p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (d) * 4)) {
                      mm = 1;
                      break;
                    }
                    pelem = pipeline_type_elem_ref_at(arena, pelem);
                    if (pelem == 0 && d + 1 < eend) {
                      mm = 1;
                      break;
                    }
                  
                d = d + 1;
              }
                  if ((mm == 0) && pelem != 0) {
                    pgek = pipeline_type_kind_ord_at(arena, pelem);
                    }
                  extra_slice = 0;
                  if (eend > 0 && eend < 8) {
                    extra_slice = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend) * 4);
                    }
                  if (extra_slice > 0) {
                    while (extra_slice > 0) {
                      if (pgek != P12G_TY_SLICE || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_slice = extra_slice - 1;
                    }
                  }
                  extra_ptr = 0;
                  if (eend > 0 && eend + 1 < 8) {
                    extra_ptr = p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (eend + 1) * 4);
                    }
                  if (extra_ptr > 0) {
                    while (extra_ptr > 0) {
                      if (pgek != P12G_TY_PTR || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_ptr = extra_ptr - 1;
                    }
                  }
                } else if (eend == 0) {
                  // 
// * dest extras dest-RET extra STAR PTR-elem
// * ndims=0 `***T` AND dest extras dest-RET extra
// * empty `[]` PTR-elem ndims=0 `**[]T`: leftover
// * after leftover-PTR peel is PTR / SLICE vs
// * eeek=leaf. Extra SLICE wrap COUNT is unused
// * slot dims[0] (1 = `**[]T`; 2 = `**[][]T`; 0 =
// * no extra SLICE = `**T` / `***T`). Extra PTR
// * wrap COUNT is unused slot dims[1] (1 = `***T`;
// * 2 = `****T`; 0 = no extra PTR = `**T`; both
// * slots = `**[]*T`). Peel leftover SLICE extra
// * times then leftover PTR extra times or T001.
// * leftover skip eek=-1 was false green of extra
// * empty `[]` PTR-elem ndims=0 (impl `**i32` vs
// * trait `**[]i32` compile=0; dest-stamp via the
// * local of typed dest = false green even Ubuntu).
// * Twin of leftover eek==SLICE eend==0 extra PTR
// * peels and leftover eek==PTR ndims>=1 extra
// * SLICE-then-PTR peels. Do not invent -3.
// * PLATFORM: SHARED. G.7: complete this walk.
// 

                  
                  
                  extra_slice =
                      p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (0) * 4);
                  if (extra_slice > 0) {
                    while (extra_slice > 0) {
                      if (pgek != P12G_TY_SLICE || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_slice = extra_slice - 1;
                    }
                  }
                  extra_ptr =
                      p12g_load_i32(ent, P12G_OFF_METHOD_RET_ELEM_ARRAY_DIMS + mi * P12G_PARAM_DIMS_ROW_INNER + (1) * 4);
                  if (extra_ptr > 0) {
                    while (extra_ptr > 0) {
                      if (pgek != P12G_TY_PTR || pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pelem = pipeline_type_elem_ref_at(arena, pelem);
                      if (pelem == 0) {
                        mm = 1;
                        break;
                      }
                      pgek = pipeline_type_kind_ord_at(arena, pelem);
                      extra_ptr = extra_ptr - 1;
                    }
                  }
                }
                if (mm == 0) {
                  if (pgek >= 0 && pgek != eeek) {
                    mm = 1;
                  } else if (pgek == eeek && eeek == P12G_TY_NAMED) {
                    enl = p12g_load_i32(ent, P12G_OFF_METHOD_RET_NAME_LENS + mi * 4);
                    if (enl > 0) {
gnl = pipeline_type_named_name_into(arena, pelem, gnm);
                      if (xlang_skip_trait_named_eq_self_c(
                            (ent + ((P12G_OFF_METHOD_RET_NAMES + mi * P12G_PARAM_NAME_INNER) as usize)), enl,
                            gnm, gnl,
                            (for_names + ((si as usize) * (64 as usize))), for_name_lens[si],
                            for_is_ptr[si]) == 0) {
                    mm = 1;
                  }
                    }
                  }
                }
              }
            }
          }
        }
        if (mm != 0) {
          return xlang_skip_trait_check_diag_ret_type_c(si, mnm, mlen);
        }
  return 0;

    return 0;
  }
  return 0;
}

