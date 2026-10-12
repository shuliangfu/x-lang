// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_primary_tramp.x — checklist 6.2 / w1539.
// The pointer shims, the by-value faces, the mangle trampoline, the
// struct-field depth counter, and the slice marker of the primary
// slice, plus its three AST writers: STRING_LIT byte append, struct-
// literal field append from a source span, and the shorthand field
// that builds a VAR node. The algorithm bodies stay in
// pthin_expr_primary.x. One file, because Darwin cannot ld -r two
// pure-asm objects.
// This file is its own translation unit. It is not a piece of the
// Darwin thirty-seven-piece body splitter.
//
// Host C still calls the three face names with a 16-byte lexer.
// SysV passes that lexer in two GPRs. Win64 MinGW passes it by
// address. Same-name positive target_os wrappers are the split.
// The @simd shim hands a 72-byte lexer result to parse.x. Win64 and
// AArch64 pass a composite over 16 bytes by address. SysV x86_64
// copies it to the stack, so linux and freebsd pass it by value.
// A whole-struct store keeps only the low 8 bytes, so every cursor
// moves through memcpy or field stores.
// Each shim keeps the seed quirks on purpose. The struct-field pointer
// shim writes a zero cursor back when the body fails. Callers restore
// their own copy.
// The C seed stays on disk for prove. Product g05 must not host-cc it.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

// 16 bytes. pos at 0, line at 8, col at 12.
allow(padding) struct PthinPrimaryLex {
  pos: usize;
  line: i32;
  col: i32;
}

// 24 bytes. ok at 0, expr_ref at 4, next_lex at 8.
allow(padding) struct PthinPrimaryExprResult {
  ok: i32;
  expr_ref: i32;
  next_lex: PthinPrimaryLex;
}

// 48 bytes. int_val at 16, float_val at 24, ident at 32, ident_len at 40.
allow(padding) struct PthinPrimaryLexToken {
  kind: i32;
  line: i32;
  col: i32;
  int_val: i64;
  float_val: f64;
  ident: *u8;
  ident_len: i32;
}

// 72 bytes. next_lex at 0, tok at 16, token_start at 64.
allow(padding) struct PthinPrimaryLexResult {
  next_lex: PthinPrimaryLex;
  tok: PthinPrimaryLexToken;
  token_start: usize;
}

// Struct-field value nesting depth. parse_field_value raises it around
// parse_expr. The empty-ident-braces probe reads it. The pipeline is
// one thread. PLATFORM: SHARED.
let g_pthin_primary_field_depth: i32[1] = [0];

extern function parser_asm_primary_lbrace_looks_like_block_x_into_c(lex_inout: *u8, source: *u8): i32;
extern function parser_asm_primary_empty_ident_braces_x_into_c(lex_inout: *u8, source: *u8, field_depth: i32): i32;
extern function parser_asm_parse_struct_lit_fields_x_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
extern function parser_asm_string_lit_decode_span_x_into_c(arena: *u8, head_ref: i32, source: *u8, q0: usize, nlen: i32, line: i32, col: i32): i32;
extern function parser_asm_parse_anonymous_struct_lit_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
extern function parser_asm_finish_struct_lit_from_type_ident_x_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, name_buf: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
extern function parser_asm_ident_pre_dispatch_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, tmpl_buf: *u8, regs_buf: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
extern function parser_asm_parse_primary_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32;
extern function parser_asm_append_type_inst_mangle_into_c(arena: *u8, base: *u8, base_len: i32, type_refs: *i32, nrefs: i32, out: *u8, out_cap: i32, suf: *u8, suf_cap: i32): i32;

#[cfg(target_os = "windows")]
extern function parse_expr_into(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "linux")]
extern function parse_expr_into(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "macos")]
extern function parse_expr_into(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parse_expr_into(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;

#[cfg(target_os = "windows")]
extern function parser_finish_struct_lit_from_type_ident_into_glue(arena: *u8, lit_ref: i32, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "linux")]
extern function parser_finish_struct_lit_from_type_ident_into_glue(arena: *u8, lit_ref: i32, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "macos")]
extern function parser_finish_struct_lit_from_type_ident_into_glue(arena: *u8, lit_ref: i32, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parser_finish_struct_lit_from_type_ident_into_glue(arena: *u8, lit_ref: i32, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;

#[cfg(target_os = "windows")]
extern function parser_parse_match_into(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "linux")]
extern function parser_parse_match_into(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "macos")]
extern function parser_parse_match_into(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parser_parse_match_into(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void;

#[cfg(target_os = "windows")]
extern function lexer_next_into(out: *PthinPrimaryLexResult, lex: *PthinPrimaryLex, source: *u8): void;
#[cfg(target_os = "linux")]
extern function lexer_next_into(out: *PthinPrimaryLexResult, lex: PthinPrimaryLex, source: *u8): void;
#[cfg(target_os = "macos")]
extern function lexer_next_into(out: *PthinPrimaryLexResult, lex: PthinPrimaryLex, source: *u8): void;
#[cfg(target_os = "freebsd")]
extern function lexer_next_into(out: *PthinPrimaryLexResult, lex: PthinPrimaryLex, source: *u8): void;

#[cfg(target_os = "windows")]
extern function parser_asm_parse_type_ref_for_arena_into_slice_c(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32;
#[cfg(target_os = "linux")]
extern function parser_asm_parse_type_ref_for_arena_into_slice_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32;
#[cfg(target_os = "macos")]
extern function parser_asm_parse_type_ref_for_arena_into_slice_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32;
#[cfg(target_os = "freebsd")]
extern function parser_asm_parse_type_ref_for_arena_into_slice_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32;

#[cfg(target_os = "windows")]
extern function parser_asm_skip_generic_angle_list_count_into_slice_c(out: *PthinPrimaryLex, count: *i32, lex: *PthinPrimaryLex, source: *u8): void;
#[cfg(target_os = "linux")]
extern function parser_asm_skip_generic_angle_list_count_into_slice_c(out: *PthinPrimaryLex, count: *i32, lex: PthinPrimaryLex, source: *u8): void;
#[cfg(target_os = "macos")]
extern function parser_asm_skip_generic_angle_list_count_into_slice_c(out: *PthinPrimaryLex, count: *i32, lex: PthinPrimaryLex, source: *u8): void;
#[cfg(target_os = "freebsd")]
extern function parser_asm_skip_generic_angle_list_count_into_slice_c(out: *PthinPrimaryLex, count: *i32, lex: PthinPrimaryLex, source: *u8): void;

#[cfg(target_os = "windows")]
extern function parser_parse_at_simd_builtin_into(arena: *u8, r0: *PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "linux")]
extern function parser_parse_at_simd_builtin_into(arena: *u8, r0: PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "macos")]
extern function parser_parse_at_simd_builtin_into(arena: *u8, r0: *PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parser_parse_at_simd_builtin_into(arena: *u8, r0: PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void;

/**
 * Call parse_expr_into with the cursor. Win64 already holds the lexer address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_parse_expr(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  unsafe {
    parse_expr_into(arena, lex, source, out);
  }
}

/**
 * Call parse_expr_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_parse_expr(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parse_expr_into(arena, *lex, source, out);
  }
}

/**
 * Call parse_expr_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_parse_expr(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parse_expr_into(arena, *lex, source, out);
  }
}

/**
 * Call parse_expr_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_parse_expr(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parse_expr_into(arena, *lex, source, out);
  }
}

/**
 * Call the finish_struct_lit glue with the cursor. Win64 already holds the lexer address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lit_ref i32 — struct literal
 * @param lex *PthinPrimaryLex — cursor after '{'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_finish(arena: *u8, lit_ref: i32, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  unsafe {
    parser_finish_struct_lit_from_type_ident_into_glue(arena, lit_ref, lex, source, out);
  }
}

/**
 * Call the finish_struct_lit glue with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lit_ref i32 — struct literal
 * @param lex *PthinPrimaryLex — cursor after '{'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_finish(arena: *u8, lit_ref: i32, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_finish_struct_lit_from_type_ident_into_glue(arena, lit_ref, *lex, source, out);
  }
}

/**
 * Call the finish_struct_lit glue with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lit_ref i32 — struct literal
 * @param lex *PthinPrimaryLex — cursor after '{'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_finish(arena: *u8, lit_ref: i32, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_finish_struct_lit_from_type_ident_into_glue(arena, lit_ref, *lex, source, out);
  }
}

/**
 * Call the finish_struct_lit glue with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lit_ref i32 — struct literal
 * @param lex *PthinPrimaryLex — cursor after '{'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_finish(arena: *u8, lit_ref: i32, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_finish_struct_lit_from_type_ident_into_glue(arena, lit_ref, *lex, source, out);
  }
}

/**
 * Call parser_parse_match_into with the cursor. Win64 already holds the lexer address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_match(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  unsafe {
    parser_parse_match_into(arena, lex, source, out);
  }
}

/**
 * Call parser_parse_match_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_match(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_match_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_match_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_match(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_match_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_match_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_match(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_match_into(arena, *lex, source, out);
  }
}

/**
 * Call lexer_next_into with the cursor. Win64 already holds the lexer address, so the pointer is forwarded.
 * @param out *PthinPrimaryLexResult — 72-byte result; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_lex_next(out: *PthinPrimaryLexResult, lex: *PthinPrimaryLex, source: *u8): void {
  unsafe {
    lexer_next_into(out, lex, source);
  }
}

/**
 * Call lexer_next_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param out *PthinPrimaryLexResult — 72-byte result; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_lex_next(out: *PthinPrimaryLexResult, lex: *PthinPrimaryLex, source: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    lexer_next_into(out, *lex, source);
  }
}

/**
 * Call lexer_next_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param out *PthinPrimaryLexResult — 72-byte result; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_lex_next(out: *PthinPrimaryLexResult, lex: *PthinPrimaryLex, source: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    lexer_next_into(out, *lex, source);
  }
}

/**
 * Call lexer_next_into with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param out *PthinPrimaryLexResult — 72-byte result; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_lex_next(out: *PthinPrimaryLexResult, lex: *PthinPrimaryLex, source: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    lexer_next_into(out, *lex, source);
  }
}

/**
 * Call the type_ref parser with the cursor. Win64 already holds the lexer address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out_lex *PthinPrimaryLex — cursor after the type; not null
 * @return i32 — callee result
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_type_ref(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32 {
  unsafe {
    return parser_asm_parse_type_ref_for_arena_into_slice_c(arena, lex, source, out_lex);
  }
}

/**
 * Call the type_ref parser with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out_lex *PthinPrimaryLex — cursor after the type; not null
 * @return i32 — callee result
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_type_ref(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32 {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    return parser_asm_parse_type_ref_for_arena_into_slice_c(arena, *lex, source, out_lex);
  }
}

/**
 * Call the type_ref parser with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out_lex *PthinPrimaryLex — cursor after the type; not null
 * @return i32 — callee result
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_type_ref(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32 {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    return parser_asm_parse_type_ref_for_arena_into_slice_c(arena, *lex, source, out_lex);
  }
}

/**
 * Call the type_ref parser with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out_lex *PthinPrimaryLex — cursor after the type; not null
 * @return i32 — callee result
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_type_ref(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out_lex: *PthinPrimaryLex): i32 {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    return parser_asm_parse_type_ref_for_arena_into_slice_c(arena, *lex, source, out_lex);
  }
}

/**
 * Call the generic angle-list skipper with the cursor. Win64 already holds the lexer address, so the pointer is forwarded.
 * @param out *PthinPrimaryLex — cursor after '>'; not null
 * @param count *i32 — argument count; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_skip_angle(out: *PthinPrimaryLex, count: *i32, lex: *PthinPrimaryLex, source: *u8): void {
  unsafe {
    parser_asm_skip_generic_angle_list_count_into_slice_c(out, count, lex, source);
  }
}

/**
 * Call the generic angle-list skipper with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param out *PthinPrimaryLex — cursor after '>'; not null
 * @param count *i32 — argument count; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_skip_angle(out: *PthinPrimaryLex, count: *i32, lex: *PthinPrimaryLex, source: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_asm_skip_generic_angle_list_count_into_slice_c(out, count, *lex, source);
  }
}

/**
 * Call the generic angle-list skipper with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param out *PthinPrimaryLex — cursor after '>'; not null
 * @param count *i32 — argument count; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_skip_angle(out: *PthinPrimaryLex, count: *i32, lex: *PthinPrimaryLex, source: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_asm_skip_generic_angle_list_count_into_slice_c(out, count, *lex, source);
  }
}

/**
 * Call the generic angle-list skipper with the cursor. SysV takes the 16-byte lexer in two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param out *PthinPrimaryLex — cursor after '>'; not null
 * @param count *i32 — argument count; not null
 * @param lex *PthinPrimaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_skip_angle(out: *PthinPrimaryLex, count: *i32, lex: *PthinPrimaryLex, source: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_asm_skip_generic_angle_list_count_into_slice_c(out, count, *lex, source);
  }
}

/**
 * Call parser_parse_at_simd_builtin_into with the 72-byte lexer result.
 * This ABI passes a composite over 16 bytes by address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param r0 *PthinPrimaryLexResult — token after '@'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_primary_call_simd(arena: *u8, r0: *PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void {
  unsafe {
    parser_parse_at_simd_builtin_into(arena, r0, source, out);
  }
}

/**
 * Call parser_parse_at_simd_builtin_into with the 72-byte lexer result.
 * SysV x86_64 copies a composite over 16 bytes to the stack, so a local copy goes by value.
 * @param arena *u8 — AST arena; not null
 * @param r0 *PthinPrimaryLexResult — token after '@'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_primary_call_simd(arena: *u8, r0: *PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  let loc: PthinPrimaryLexResult = {
    next_lex: { pos: 0, line: 0, col: 0 },
    tok: { kind: 0, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0 as *u8, ident_len: 0 },
    token_start: 0
  };
  unsafe {
    memcpy(&loc as *u8, r0 as *u8, 72);
    parser_parse_at_simd_builtin_into(arena, loc, source, out);
  }
}

/**
 * Call parser_parse_at_simd_builtin_into with the 72-byte lexer result.
 * This ABI passes a composite over 16 bytes by address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param r0 *PthinPrimaryLexResult — token after '@'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_primary_call_simd(arena: *u8, r0: *PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void {
  unsafe {
    parser_parse_at_simd_builtin_into(arena, r0, source, out);
  }
}

/**
 * Call parser_parse_at_simd_builtin_into with the 72-byte lexer result.
 * SysV x86_64 copies a composite over 16 bytes to the stack, so a local copy goes by value.
 * @param arena *u8 — AST arena; not null
 * @param r0 *PthinPrimaryLexResult — token after '@'; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinPrimaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_primary_call_simd(arena: *u8, r0: *PthinPrimaryLexResult, source: *u8, out: *PthinPrimaryExprResult): void {
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  let loc: PthinPrimaryLexResult = {
    next_lex: { pos: 0, line: 0, col: 0 },
    tok: { kind: 0, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0 as *u8, ident_len: 0 },
    token_start: 0
  };
  unsafe {
    memcpy(&loc as *u8, r0 as *u8, 72);
    parser_parse_at_simd_builtin_into(arena, loc, source, out);
  }
}

/**
 * Write ok, expr_ref, and the three cursor fields of a 24-byte result
 * back through the caller's pointers.
 * @param res *PthinPrimaryExprResult — result; not null
 * @param lex_inout *u8 — 16-byte cursor; not null
 * @param out_ok *i32 — not null
 * @param out_expr_ref *i32 — not null
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_primary_write_back(res: *PthinPrimaryExprResult, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32): void {
  unsafe {
    let p: *PthinPrimaryLex = lex_inout as *PthinPrimaryLex;
    out_ok[0] = res.ok;
    out_expr_ref[0] = res.expr_ref;
    p.pos = res.next_lex.pos;
    p.line = res.next_lex.line;
    p.col = res.next_lex.col;
  }
}

/**
 * Pointer face for parse_expr. Writes ok, expr_ref, and the cursor
 * even when ok is 0. A null argument returns 0.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — null returns 0
 * @param out_expr_ref *i32 — null returns 0
 * @return i32 — 1 when the call ran
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_parse_expr_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinPrimaryExprResult = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  unsafe {
    pthin_primary_call_parse_expr(arena, lex_inout as *PthinPrimaryLex, source, &res);
    pthin_primary_write_back(&res, lex_inout, out_ok, out_expr_ref);
  }
  return 1;
}

/**
 * Pointer face for a struct-literal field value. Same as the parse_expr
 * face, and the field depth is one higher during the call.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — null returns 0
 * @param out_expr_ref *i32 — null returns 0
 * @return i32 — 1 when the call ran
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_struct_lit_parse_field_value_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinPrimaryExprResult = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  unsafe {
    g_pthin_primary_field_depth[0] = g_pthin_primary_field_depth[0] + 1;
    pthin_primary_call_parse_expr(arena, lex_inout as *PthinPrimaryLex, source, &res);
    g_pthin_primary_field_depth[0] = g_pthin_primary_field_depth[0] - 1;
    pthin_primary_write_back(&res, lex_inout, out_ok, out_expr_ref);
  }
  return 1;
}

/**
 * Pointer face for finish_struct_lit_from_type_ident. Writes the result
 * back even when ok is 0. A null argument returns without a write.
 * @param arena *u8 — AST arena
 * @param lit_ref i32 — struct literal
 * @param lex_inout *u8 — 16-byte cursor after '{'; updated
 * @param source *u8 — source slice
 * @param out_ok *i32 — result ok
 * @param out_expr_ref *i32 — result expr ref
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_finish_struct_lit_ptr_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void {
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return;
  }
  let res: PthinPrimaryExprResult = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  unsafe {
    pthin_primary_call_finish(arena, lit_ref, lex_inout as *PthinPrimaryLex, source, &res);
    pthin_primary_write_back(&res, lex_inout, out_ok, out_expr_ref);
  }
}

/**
 * Pointer face for match. Same contract as the parse_expr face.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor on `match`; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — null returns 0
 * @param out_expr_ref *i32 — null returns 0
 * @return i32 — 1 when the call ran
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_parse_match_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinPrimaryExprResult = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  unsafe {
    pthin_primary_call_match(arena, lex_inout as *PthinPrimaryLex, source, &res);
    pthin_primary_write_back(&res, lex_inout, out_ok, out_expr_ref);
  }
  return 1;
}

/**
 * Pointer face for an @simd builtin. Lexes the token after the cursor,
 * then hands that 72-byte result to parse.x. Same write-back contract
 * as the parse_expr face.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor before the name; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — null returns 0
 * @param out_expr_ref *i32 — null returns 0
 * @return i32 — 1 when the call ran
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_parse_at_simd_builtin_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinPrimaryExprResult = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  let r0: PthinPrimaryLexResult = {
    next_lex: { pos: 0, line: 0, col: 0 },
    tok: { kind: 0, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0 as *u8, ident_len: 0 },
    token_start: 0
  };
  let cur: u8[16] = [];
  cur[0] = 0;
  unsafe {
    memcpy(&cur[0], lex_inout, 16);
    pthin_primary_call_lex_next(&r0, &cur[0] as *PthinPrimaryLex, source);
    pthin_primary_call_simd(arena, &r0, source, &res);
    pthin_primary_write_back(&res, lex_inout, out_ok, out_expr_ref);
  }
  return 1;
}

/**
 * Look ahead after '{' and say whether it opens a block. The caller's
 * cursor is not moved.
 * @param lex_inout *u8 — 16-byte cursor after '{'; read only; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @return i32 — body result
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lbrace_looks_like_block_ptr_c(lex_inout: *u8, source: *u8): i32 {
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  let cur: u8[16] = [];
  cur[0] = 0;
  unsafe {
    memcpy(&cur[0], lex_inout, 16);
    return parser_asm_primary_lbrace_looks_like_block_x_into_c(&cur[0], source);
  }
}

/**
 * Probe `Name {}` and say whether the braces read as a block. Passes
 * the current field depth. The caller's cursor is not moved.
 * @param lex_inout *u8 — 16-byte cursor after '{'; read only; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @return i32 — body result
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout: *u8, source: *u8): i32 {
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  let cur: u8[16] = [];
  cur[0] = 0;
  unsafe {
    memcpy(&cur[0], lex_inout, 16);
    return parser_asm_primary_empty_ident_braces_x_into_c(&cur[0], source, g_pthin_primary_field_depth[0]);
  }
}

/**
 * Pointer face for struct-literal fields. Success writes ok 1, the
 * literal ref, and the cursor after '}'. lit_ref 0 or a failed body
 * writes ok 0, ref 0, and a zero cursor, as the seed did.
 * @param arena *u8 — AST arena
 * @param lit_ref i32 — struct literal
 * @param lex_inout *u8 — 16-byte cursor after '{'; updated
 * @param source *u8 — source slice
 * @param out_ok *i32 — result ok
 * @param out_expr_ref *i32 — result expr ref
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_parse_struct_lit_fields_ptr_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void {
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return;
  }
  let res: PthinPrimaryExprResult = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  let cur: u8[16] = [];
  cur[0] = 0;
  let ok: i32 = 0;
  let refv: i32 = 0;
  unsafe {
    if (lit_ref != 0) {
      memcpy(&cur[0], lex_inout, 16);
      let rc: i32 = parser_asm_parse_struct_lit_fields_x_into_c(arena, lit_ref, &cur[0], source, &ok, &refv);
      if (rc != 0 && ok != 0) {
        res.ok = 1;
        res.expr_ref = refv;
        let rp: *u8 = &res as *u8;
        memcpy(rp + 8, &cur[0], 16);
      }
    }
    pthin_primary_write_back(&res, lex_inout, out_ok, out_expr_ref);
  }
}

/**
 * Decode a string-literal span into the STRING_LIT chain.
 * @param arena *u8 — AST arena; null returns -1
 * @param head_ref i32 — STRING_LIT head; 0 or less returns -1
 * @param source *u8 — source slice; null returns -1
 * @param q0 usize — first byte after the opening quote
 * @param nlen i32 — span length
 * @param line i32 — for diagnostics
 * @param col i32 — for diagnostics
 * @return i32 — body result, or -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_string_lit_decode_span_ptr_c(arena: *u8, head_ref: i32, source: *u8, q0: usize, nlen: i32, line: i32, col: i32): i32 {
  if (arena == 0 as *u8 || source == 0 as *u8 || head_ref <= 0) {
    return -1;
  }
  unsafe {
    return parser_asm_string_lit_decode_span_x_into_c(arena, head_ref, source, q0, nlen, line, col);
  }
}

/**
 * Pointer face for an anonymous struct literal. Clears ok and ref, then
 * runs the body on the caller's cursor.
 * @param arena *u8 — AST arena
 * @param lex_inout *u8 — 16-byte cursor after '{'; updated by the body
 * @param source *u8 — source slice
 * @param out_ok *i32 — result ok
 * @param out_expr_ref *i32 — result expr ref
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_parse_anonymous_struct_lit_ptr_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void {
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    parser_asm_parse_anonymous_struct_lit_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
  }
}

/**
 * Parse one type at the cursor and move the cursor past it.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @return i32 — type ref from the type parser
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_parse_type_ref_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32 {
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  let cur: u8[16] = [];
  cur[0] = 0;
  let after: PthinPrimaryLex = { pos: 0, line: 0, col: 0 };
  let tr: i32 = 0;
  unsafe {
    memcpy(&cur[0], lex_inout, 16);
    tr = pthin_primary_call_type_ref(arena, &cur[0] as *PthinPrimaryLex, source, &after);
    memcpy(lex_inout, &after as *u8, 16);
  }
  return tr;
}

/**
 * Skip a generic angle list at the cursor and count its arguments.
 * @param lex_inout *u8 — 16-byte cursor on '<'; updated; null returns
 * @param source *u8 — source slice; null returns
 * @param out_count *i32 — set to 0, then the count; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_skip_angle_count_ptr_into_c(lex_inout: *u8, source: *u8, out_count: *i32): void {
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || out_count == 0 as *i32) {
    return;
  }
  let cur: u8[16] = [];
  cur[0] = 0;
  let after: PthinPrimaryLex = { pos: 0, line: 0, col: 0 };
  unsafe {
    out_count[0] = 0;
    memcpy(&cur[0], lex_inout, 16);
    pthin_primary_call_skip_angle(&after, out_count, &cur[0] as *PthinPrimaryLex, source);
    memcpy(lex_inout, &after as *u8, 16);
  }
}

/**
 * Run the IDENT pre-dispatch body with zeroed template and register
 * buffers.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor; updated by the body; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — cleared first; null returns 0
 * @param out_expr_ref *i32 — cleared first; null returns 0
 * @return i32 — body result
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_ident_pre_dispatch_ptr_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let tmpl: u8[256] = [];
  let regs: u8[128] = [];
  let i: i32 = 0;
  while (i < 256) {
    tmpl[i] = 0;
    if (i < 128) {
      regs[i] = 0;
    }
    i = i + 1;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    return parser_asm_ident_pre_dispatch_x_into_c(arena, lex_inout, source, &tmpl[0], &regs[0], out_ok, out_expr_ref);
  }
}

/**
 * Mangle a generic type instance name. Holds the 64-byte suffix buffer.
 * @param arena *u8 — AST arena
 * @param base *u8 — base name bytes
 * @param base_len i32 — base name length
 * @param type_refs *i32 — type argument refs
 * @param nrefs i32 — type argument count
 * @param out *u8 — output buffer
 * @param out_cap i32 — output capacity
 * @return i32 — body result
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_append_type_inst_mangle_c(arena: *u8, base: *u8, base_len: i32, type_refs: *i32, nrefs: i32, out: *u8, out_cap: i32): i32 {
  let suf: u8[64] = [];
  suf[0] = 0;
  unsafe {
    return parser_asm_append_type_inst_mangle_into_c(arena, base, base_len, type_refs, nrefs, out, out_cap, &suf[0], 64);
  }
}

/**
 * Shared body of the primary face. Holds the six scratch buffers.
 * A failed body writes ok 0 and nothing else.
 * @param arena *u8 — AST arena
 * @param lex *u8 — 16-byte cursor; copied
 * @param source *u8 — source slice; null returns
 * @param out *u8 — 24-byte result; null returns
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_primary_face_primary(arena: *u8, lex: *u8, source: *u8, out: *u8): void {
  if (out == 0 as *u8 || source == 0 as *u8) {
    return;
  }
  let mc: i32[256] = [];
  let args: i32[256] = [];
  let pr: i32[8] = [];
  let pend: i32[8] = [];
  let mangled: u8[128] = [];
  let name: u8[256] = [];
  mc[0] = 0;
  args[0] = 0;
  pr[0] = 0;
  pend[0] = 0;
  mangled[0] = 0;
  name[0] = 0;
  let cur: u8[16] = [];
  cur[0] = 0;
  let ok: i32 = 0;
  let refv: i32 = 0;
  let op: *i32 = out as *i32;
  unsafe {
    memcpy(&cur[0], lex, 16);
    let rc: i32 = parser_asm_parse_primary_x_into_c(arena, &cur[0], source, &ok, &refv, &mc[0], &args[0], &pr[0], &pend[0], &mangled[0], &name[0]);
    if (rc == 0 || ok == 0) {
      op[0] = 0;
      return;
    }
    op[0] = 1;
    op[1] = refv;
    memcpy(out + 8, &cur[0], 16);
  }
}

/**
 * Shared body of the anonymous-struct face and the finish face.
 * which 0 runs the anonymous body. which 1 runs the finish body with a
 * zeroed 256-byte name buffer; lit_ref 0 stops after the clear.
 * @param arena *u8 — AST arena; null returns
 * @param lit_ref i32 — struct literal for which 1
 * @param lex *u8 — 16-byte cursor after '{'; copied
 * @param source *u8 — source slice; null returns
 * @param out *u8 — 24-byte result; null returns
 * @param which i32 — 0 anonymous, 1 finish
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_primary_face_struct(arena: *u8, lit_ref: i32, lex: *u8, source: *u8, out: *u8, which: i32): void {
  if (arena == 0 as *u8 || source == 0 as *u8 || out == 0 as *u8) {
    return;
  }
  let op: *i32 = out as *i32;
  let name: u8[256] = [];
  name[0] = 0;
  let cur: u8[16] = [];
  cur[0] = 0;
  let ok: i32 = 0;
  let refv: i32 = 0;
  unsafe {
    op[0] = 0;
    op[1] = 0;
    let rc: i32 = 0;
    if (which == 0) {
      memcpy(&cur[0], lex, 16);
      rc = parser_asm_parse_anonymous_struct_lit_x_into_c(arena, &cur[0], source, &ok, &refv);
    } else {
      if (lit_ref == 0) {
        return;
      }
      let i: i32 = 0;
      while (i < 256) {
        name[i] = 0;
        i = i + 1;
      }
      memcpy(&cur[0], lex, 16);
      rc = parser_asm_finish_struct_lit_from_type_ident_x_into_c(arena, lit_ref, &cur[0], source, &name[0], &ok, &refv);
    }
    if (rc == 0 || ok == 0) {
      op[0] = 0;
      return;
    }
    op[0] = 1;
    op[1] = refv;
    memcpy(out + 8, &cur[0], 16);
  }
}

/**
 * By-value face for parse_primary. Forwards to the shared body. Win64 receives the lexer as an address.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parser_asm_parse_primary_into_slice_c(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_primary(arena, lex as *u8, source, out);
  }
}

/**
 * By-value face for parse_primary. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function parser_asm_parse_primary_into_slice_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_primary(arena, &lex as *u8, source, out);
  }
}

/**
 * By-value face for parse_primary. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function parser_asm_parse_primary_into_slice_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_primary(arena, &lex as *u8, source, out);
  }
}

/**
 * By-value face for parse_primary. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
#[no_mangle]
export function parser_asm_parse_primary_into_slice_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_primary(arena, &lex as *u8, source, out);
  }
}

/**
 * By-value face for an anonymous struct literal. Forwards to the shared body. Win64 receives the lexer as an address.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parser_asm_parse_anonymous_struct_lit_c(arena: *u8, lex: *PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, 0, lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for an anonymous struct literal. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function parser_asm_parse_anonymous_struct_lit_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, 0, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for an anonymous struct literal. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function parser_asm_parse_anonymous_struct_lit_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, 0, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for an anonymous struct literal. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
#[no_mangle]
export function parser_asm_parse_anonymous_struct_lit_c(arena: *u8, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, 0, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for finish_struct_lit_from_type_ident. Forwards to the shared body. Win64 receives the lexer as an address.
 * @param arena *u8 — AST arena
 * @param lit_ref i32 — struct literal
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parser_asm_finish_struct_lit_from_type_ident_into_c(arena: *u8, lit_ref: i32, lex: *PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, lit_ref, lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for finish_struct_lit_from_type_ident. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lit_ref i32 — struct literal
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function parser_asm_finish_struct_lit_from_type_ident_into_c(arena: *u8, lit_ref: i32, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, lit_ref, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for finish_struct_lit_from_type_ident. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lit_ref i32 — struct literal
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function parser_asm_finish_struct_lit_from_type_ident_into_c(arena: *u8, lit_ref: i32, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, lit_ref, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for finish_struct_lit_from_type_ident. Forwards to the shared body. SysV receives the lexer in two GPRs. A touched pad keeps the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lit_ref i32 — struct literal
 * @param lex — 16-byte cursor after '{'
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
#[no_mangle]
export function parser_asm_finish_struct_lit_from_type_ident_into_c(arena: *u8, lit_ref: i32, lex: PthinPrimaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_primary_face_struct(arena, lit_ref, &lex as *u8, source, out, 1);
  }
}

extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;
extern function ast_ast_arena_expr_alloc(a: *u8): i32;
extern function parser_asm_expr_set_common_zeros_c(e: *u8): void;
extern function lexer_note_string_lit_overflow(line: i32, col: i32): void;
extern function pipeline_expr_append_struct_lit_field(arena: *u8, lit_ref: i32, name: *u8, nlen: i32, init_ref: i32): i32;
extern function parser_asm_lex_source_data_c(source: *u8): *u8;
extern function parser_asm_lex_source_length_c(source: *u8): usize;

// ---- AST writers ----
// The seed did get / edit / set on a 1224-byte copy. These writers
// edit the arena slot in place through pipeline_arena_expr_ptr.
// set_copy is a whole-slot copy, so both forms leave the same bytes.
// An alloc may grow the arena, so every slot pointer is fetched again
// after an alloc. i32 fields go through *i32 stores.
// PLATFORM: SHARED.

/**
 * Set up one STRING_LIT overflow node: common zeros, kind 59,
 * line and col from the head, int_val 0, var_name_len 0.
 * @param ov *u8 — slot of the new node; not null
 * @param line i32 — head line
 * @param col i32 — head col
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_primary_set_init_overflow(ov: *u8, line: i32, col: i32): void {
  unsafe {
    parser_asm_expr_set_common_zeros_c(ov);
    let p: *i32 = ov as *i32;
    p[0] = 59;
    p[2] = line;
    p[3] = col;
    p[4] = 0;
    p[5] = 0;
    p[72] = 0;
  }
}

/**
 * Append one byte to a STRING_LIT head. The first 127 bytes live in
 * the head var_name. Later bytes go to a chain of overflow nodes
 * linked through int_val, 127 bytes each. 4095 bytes is the limit.
 * Same algorithm as the static append_byte in the primary seed.
 * @param arena *u8 — AST arena; null returns -1
 * @param head_ref i32 — STRING_LIT head; 0 or less returns -1
 * @param b i32 — byte; only the low 8 bits are kept
 * @param line i32 — for the overflow diagnostic
 * @param col i32 — for the overflow diagnostic
 * @return i32 — 0 ok, -1 on error or overflow
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_string_lit_append_byte_ptr_c(arena: *u8, head_ref: i32, b: i32, line: i32, col: i32): i32 {
  if (arena == 0 as *u8 || head_ref <= 0) {
    return -1;
  }
  let bv: u8 = (b & 255) as u8;
  unsafe {
    let he: *u8 = pipeline_arena_expr_ptr(arena, head_ref);
    if (he == 0 as *u8) {
      return -1;
    }
    let hp: *i32 = he as *i32;
    let total: i32 = hp[72];
    if (total < 0) {
      total = 0;
    }
    if (total >= 4095) {
      lexer_note_string_lit_overflow(line, col);
      return -1;
    }
    if (total < 127) {
      he[32 + total] = bv;
      hp[72] = total + 1;
      return 0;
    }
    let hline: i32 = hp[2];
    let hcol: i32 = hp[3];
    let cur: i32 = hp[4];
    let off: i32 = total - 127;
    if (cur <= 0) {
      let ov: i32 = ast_ast_arena_expr_alloc(arena);
      if (ov == 0) {
        return -1;
      }
      let oe: *u8 = pipeline_arena_expr_ptr(arena, ov);
      pthin_primary_set_init_overflow(oe, hline, hcol);
      he = pipeline_arena_expr_ptr(arena, head_ref);
      hp = he as *i32;
      hp[4] = ov;
      hp[5] = 0;
      cur = ov;
    }
    while (off >= 127) {
      let ce: *u8 = pipeline_arena_expr_ptr(arena, cur);
      let cp: *i32 = ce as *i32;
      let next: i32 = cp[4];
      if (next <= 0) {
        let nv: i32 = ast_ast_arena_expr_alloc(arena);
        if (nv == 0) {
          return -1;
        }
        ce = pipeline_arena_expr_ptr(arena, cur);
        cp = ce as *i32;
        cp[4] = nv;
        cp[5] = 0;
        let ne: *u8 = pipeline_arena_expr_ptr(arena, nv);
        pthin_primary_set_init_overflow(ne, hline, hcol);
        next = nv;
      }
      off = off - 127;
      cur = next;
    }
    let te: *u8 = pipeline_arena_expr_ptr(arena, cur);
    let tp: *i32 = te as *i32;
    te[32 + off] = bv;
    if (tp[72] < off + 1) {
      tp[72] = off + 1;
    }
    he = pipeline_arena_expr_ptr(arena, head_ref);
    hp = he as *i32;
    hp[72] = total + 1;
  }
  return 0;
}

/**
 * Copy a field name from the source span into a zeroed 256-byte
 * buffer. Bytes past the source length stay 0.
 * @param name *u8 — 256-byte buffer; not null
 * @param source *u8 — source slice; not null
 * @param start usize — first byte
 * @param nlen i32 — 1..255
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_primary_set_copy_name(name: *u8, source: *u8, start: usize, nlen: i32): void {
  let i: i32 = 0;
  unsafe {
    while (i < 256) {
      name[i] = 0;
      i = i + 1;
    }
    let data: *u8 = parser_asm_lex_source_data_c(source);
    let slen: usize = parser_asm_lex_source_length_c(source);
    i = 0;
    while (i < nlen) {
      let at: usize = start + (i as usize);
      if (at < slen) {
        name[i] = data[at];
      }
      i = i + 1;
    }
  }
}

/**
 * Append a named field to a struct literal. The name comes from the
 * source span [start, start+nlen).
 * @param arena *u8 — AST arena; null returns -1
 * @param lit_ref i32 — struct literal; 0 or less returns -1
 * @param source *u8 — source slice; null returns -1
 * @param start usize — name start
 * @param nlen i32 — name length; outside 1..255 returns -1
 * @param init_ref i32 — field value expr
 * @return i32 — pipeline_expr_append_struct_lit_field result, or -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_struct_lit_append_field_src_c(arena: *u8, lit_ref: i32, source: *u8, start: usize, nlen: i32, init_ref: i32): i32 {
  let name: u8[256] = [];
  name[0] = 0;
  if (arena == 0 as *u8 || source == 0 as *u8 || lit_ref <= 0 || nlen <= 0 || nlen > 255) {
    return -1;
  }
  unsafe {
    pthin_primary_set_copy_name(&name[0], source, start, nlen);
    return pipeline_expr_append_struct_lit_field(arena, lit_ref, &name[0], nlen, init_ref);
  }
}

/**
 * Zero a fresh VAR node the way the finish_type_ident twin does.
 * Same as the common zeros except call_num_type_args (632) is not
 * written. soa_stride (604) is not written either.
 * @param e *u8 — slot; not null
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_primary_set_finish_zeros(e: *u8): void {
  unsafe {
    let p: *i32 = e as *i32;
    p[1] = 0;
    p[73] = 0;
    p[74] = 0;
    p[75] = 0;
    p[76] = 0;
    p[77] = 0;
    p[78] = 0;
    p[79] = 0;
    p[80] = 0;
    p[81] = 0;
    p[82] = 0;
    p[301] = 0;
    p[83] = 0;
    p[148] = 0;
    p[149] = 0;
    p[150] = 0;
    p[152] = 0;
    p[153] = 0;
    p[154] = 0;
    p[155] = 0;
    p[156] = 0;
    p[157] = 0;
    p[159] = 0;
    p[224] = 0;
    p[225] = 0;
    p[226] = 0;
    p[227] = 0;
    p[228] = 0;
    p[229] = 0;
    p[295] = 0;
    p[296] = 0;
    p[297] = 0;
    p[298] = 0;
    p[302] = 0;
    p[303] = 0;
    p[304] = -1;
    p[305] = -1;
  }
}

/**
 * Append a shorthand field `{ x }`. Builds a VAR node named x with
 * line 0 and col 0, then appends it as the field value.
 * @param arena *u8 — AST arena; null returns -1
 * @param lit_ref i32 — struct literal; 0 or less returns -1
 * @param source *u8 — source slice; null returns -1
 * @param start usize — name start
 * @param nlen i32 — name length; outside 1..255 returns -1
 * @return i32 — pipeline_expr_append_struct_lit_field result, or -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_struct_lit_append_shorthand_src_c(arena: *u8, lit_ref: i32, source: *u8, start: usize, nlen: i32): i32 {
  let name: u8[256] = [];
  name[0] = 0;
  if (arena == 0 as *u8 || source == 0 as *u8 || lit_ref <= 0 || nlen <= 0 || nlen > 255) {
    return -1;
  }
  unsafe {
    pthin_primary_set_copy_name(&name[0], source, start, nlen);
    let vref: i32 = ast_ast_arena_expr_alloc(arena);
    if (vref == 0) {
      return -1;
    }
    let ve: *u8 = pipeline_arena_expr_ptr(arena, vref);
    if (ve == 0 as *u8) {
      return -1;
    }
    pthin_primary_set_finish_zeros(ve);
    let vp: *i32 = ve as *i32;
    vp[0] = 3;
    vp[2] = 0;
    vp[3] = 0;
    vp[4] = 0;
    vp[5] = 0;
    vp[6] = 0;
    vp[7] = 0;
    vp[72] = nlen;
    let i: i32 = 0;
    while (i < 128) {
      if (i < nlen) {
        ve[32 + i] = name[i];
      } else {
        ve[32 + i] = 0;
      }
      i = i + 1;
    }
    return pipeline_expr_append_struct_lit_field(arena, lit_ref, &name[0], nlen, vref);
  }
}

/**
 * Slice marker. Returns 2 when this object is linked.
 * @return i32 — always 2
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_pthin_expr_primary_slice_marker(): i32 {
  return 2;
}

/**
 * Proof that product g05 linked this .x trampoline.
 * The face names and the marker can also come from the C seed.
 * This anchor cannot.
 * @return i32 — always 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pthin_expr_primary_tramp_w1539_anchor(): i32 {
  return 0;
}
