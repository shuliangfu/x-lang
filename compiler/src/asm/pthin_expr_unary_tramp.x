// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_unary_tramp.x — checklist 6.2 / w1536.
// By-value face parser_asm_parse_unary_into_slice_c, the pointer
// primary shim, and the slice marker. The three algorithm functions
// stay in pthin_expr_unary.x. The operand writer stays in
// pthin_expr_unary_set.x. This file does not add a fourth function
// to the Darwin three-function splitter.
//
// Host C still calls the slice name with a 16-byte lexer.
// SysV passes that lexer in two GPRs. Win64 MinGW passes it by
// address. Same-name positive target_os wrappers are the split.
// A whole-struct store keeps only the low 8 bytes, so the cursor
// moves through memcpy and the primary write-back is field stores.
// Stretch-audit calls stay in the C seed. They are product nops
// and are not copied here. The C seed stays on disk for prove.
// Product g05 must not host-cc it.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

// 16 bytes. pos at 0, line at 8, col at 12.
allow(padding) struct ParserAsmLexLexer {
  pos: usize;
  line: i32;
  col: i32;
}

// 24 bytes. ok at 0, expr_ref at 4, next_lex at 8.
allow(padding) struct PthinUnaryExprResult {
  ok: i32;
  expr_ref: i32;
  next_lex: ParserAsmLexLexer;
}

/**
 * Dest-buffer unary body. Defined in pthin_expr_unary.x.
 * This file only forwards the cursor.
 */
extern function parser_asm_parse_unary_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

#[cfg(target_os = "windows")]
extern function parser_parse_primary_into(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void;
#[cfg(target_os = "linux")]
extern function parser_parse_primary_into(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void;
#[cfg(target_os = "macos")]
extern function parser_parse_primary_into(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parser_parse_primary_into(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void;

/**
 * Copy the caller's 16-byte lexer, run the unary body, and write
 * ok / expr_ref / next_lex into the 24-byte result.
 * A null out returns. A null source or lexer writes ok=0.
 * Failure from the body also writes ok=0 and leaves the previous
 * cursor out of the result.
 * @param arena *u8 — AST arena; passed through
 * @param lex *u8 — 16-byte cursor; not null when source is set
 * @param source *u8 — source slice; null writes ok=0
 * @param out *u8 — 24-byte parse_expr_result; null returns
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_expr_unary_tramp_face(arena: *u8, lex: *u8, source: *u8, out: *u8): void {
  if (out == 0 as *u8) {
    return;
  }
  let op: *i32 = out as *i32;
  if (source == 0 as *u8 || lex == 0 as *u8) {
    unsafe {
      op[0] = 0;
    }
    return;
  }
  // Mutable copy. The body parks the cursor through the pointer.
  // memcpy keeps line and col; a struct assignment does not.
  // PLATFORM: SHARED.
  let cur: u8[16] = [];
  cur[0] = 0;
  let ok: i32 = 0;
  let refv: i32 = 0;
  unsafe {
    memcpy(&cur[0], lex, 16);
    let rc: i32 = parser_asm_parse_unary_x_into_c(arena, &cur[0], source, &ok, &refv);
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
 * Call parser_parse_primary_into. Win64 already holds the lexer
 * address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinUnaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_expr_unary_call_primary(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void {
  unsafe {
    parser_parse_primary_into(arena, lex, source, out);
  }
}

/**
 * Call parser_parse_primary_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinUnaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_expr_unary_call_primary(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_primary_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_primary_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinUnaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_expr_unary_call_primary(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_primary_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_primary_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinUnaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_expr_unary_call_primary(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinUnaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_primary_into(arena, *lex, source, out);
  }
}

/**
 * Pointer face for parse_primary. Copies nothing into a second lexer
 * variable: the SysV wrapper loads *lex. Writes ok, expr_ref, and
 * the three cursor fields. A null argument returns 0.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — result ok; null returns 0
 * @param out_expr_ref *i32 — result expr ref; null returns 0
 * @return i32 — 1 when the call ran, 0 when an argument was null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_parse_primary_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  // The by-value spill sits in the wrapper. This frame still holds
  // the 24-byte result, and the historical fill path was short by
  // more than the result alone. PLATFORM: SHARED.
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinUnaryExprResult = {
    ok: 0,
    expr_ref: 0,
    next_lex: { pos: 0, line: 0, col: 0 }
  };
  unsafe {
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    pthin_expr_unary_call_primary(arena, p, source, &res);
    out_ok[0] = res.ok;
    out_expr_ref[0] = res.expr_ref;
    p.pos = res.next_lex.pos;
    p.line = res.next_lex.line;
    p.col = res.next_lex.col;
  }
  return 1;
}

/**
 * By-value face for parse_unary. Forwards to the pointer body.
 * Win64 receives the lexer as an address.
 * @param arena *u8 — AST arena
 * @param lex *ParserAsmLexLexer — cursor address
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parser_asm_parse_unary_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_unary_tramp_face(arena, lex as *u8, source, out);
  }
}

/**
 * By-value face for parse_unary. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex ParserAsmLexLexer — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function parser_asm_parse_unary_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_unary_tramp_face(arena, &lex as *u8, source, out);
  }
}

/**
 * By-value face for parse_unary. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex ParserAsmLexLexer — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function parser_asm_parse_unary_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_unary_tramp_face(arena, &lex as *u8, source, out);
  }
}

/**
 * By-value face for parse_unary. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex ParserAsmLexLexer — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
#[no_mangle]
export function parser_asm_parse_unary_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_unary_tramp_face(arena, &lex as *u8, source, out);
  }
}

/**
 * Slice marker. Returns 1 when this object is linked.
 * @return i32 — always 1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_pthin_expr_unary_slice_marker(): i32 {
  return 1;
}

/**
 * Proof that product g05 linked this .x trampoline.
 * The face name and the marker can also come from the C seed.
 * This anchor cannot.
 * @return i32 — always 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pthin_expr_unary_tramp_w1536_anchor(): i32 {
  return 0;
}
