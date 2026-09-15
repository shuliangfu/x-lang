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
// method_on_param / bound_check stay C (also walk g_fn_bound_* +
// trait-reg). Do not merge with P1c pending tables. Do not open a
// new P-lane. Do not FORCE pabi mega.
//
// Hybrid P12b/P12c/P12d/P12e/P12f/P12h/P12i/P12j/P12k: g05_try_x_to_o this
// file; XLANG_PTHIN_SKIP_TL_BODIES_FROM_X skips the portable .inc
// region (struct/enum/extern + impl header + generic_bound_scan +
// enum_register + parse_one_extern_skip + parse_one_extern_and_add +
// skip_name_is_self + self_matches_for + named_eq_self +
// rewrite_self + register_type_params + type_param_index). Requires P9a
// bridge + P1b skip walks (otherwise skip_balanced / skip_generic_angle
// / copy_slice would UNDEF). token.h remains the TOKEN_* authority via
// P12 C _Static_assert pins. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_SKIP_TL_FROM_X for P12b–P12k bodies. P12g skip_one_trait
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
 * PLATFORM: SHARED — product P12i B-minus. concrete_implements_trait
 * stays C and calls the historical static. Do not copy into typeck.
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

