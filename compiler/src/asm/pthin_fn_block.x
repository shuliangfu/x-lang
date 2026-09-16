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
// parse_one_function_library stays C (struct-by-value result + scan).
// Block zeros / module func slot stay C. Do not dest-buffer parse
// this wave (P6d). Do not copy wrap into parse_type_ref / parse_match
// / P15 library_wrap scan. Do not copy name-match loops into
// library_slice. Do not mix range_for. Do not wrap AUDIT. Do not
// open a new P-lane.
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
// Hybrid P6b/P6c/P6d/P6e: g05_try_x_to_o this file;
// XLANG_PTHIN_FN_BLOCK_BODIES_FROM_X skips name-match + modifiers +
// library wrap; XLANG_PTHIN_FN_BLOCK_PARSE_LAYOUT_FROM_X skips the
// layout parse C twin when parse_x is present. P9a is linked later
// into the same thin_glue (same as P7d/P4ud). Cold: no define, full
// .inc. Do not reuse XLANG_PTHIN_FN_BLOCK_FROM_X for P6b/P6c/P6d/P6e
// bodies. PLATFORM: SHARED freestanding.

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
/** Sidecar: write field_align at (layout, field). */
export extern "C" function pipeline_module_struct_layout_set_field_align(module: *u8, li: i32, j: i32, al: i32): void;
/** Sidecar: next field offset given type + align req. */
export extern "C" function pipeline_struct_layout_next_field_offset_ex(module: *u8, arena: *u8, layout_idx: i32, new_field_type_ref: i32, field_align_req: i32): i32;

/** Allocate a fresh Type slot; 0 on failure. */
export extern "C" function ast_ast_arena_type_alloc(arena: *u8): i32;
/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** pabi: zero a Type slot and write a primitive kind_ord (0..16). */
export extern "C" function pipeline_type_init_primitive_kind_at(a: *u8, ref: i32, kind_ord: i32): i32;
/** pabi: zero a Type slot and write TYPE_NAMED + spelling (nlen 1..255). */
export extern "C" function pipeline_type_init_named_at(a: *u8, ref: i32, name: *u8, name_len: i32): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/** Wave-0: write Expr.resolved_type_ref. */
export extern "C" function pipeline_expr_set_resolved_type_ref(a: *u8, er: i32, type_ref: i32): void;
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
const TOKEN_IDENT: i32 = 59;
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
 * wrap family. parse_one_function_library stays C; do not copy.
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
