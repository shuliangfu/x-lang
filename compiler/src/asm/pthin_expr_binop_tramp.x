// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_binop_tramp.x — checklist 6.2 / w1535.
// By-value parse_*_into_slice faces for the ten binop levels, the
// pointer cast shim, and the slice marker. The four algorithm
// functions stay in pthin_expr_binop.x. The operand writer stays
// in pthin_expr_binop_set.x. This file does not add a fifth
// function to the Darwin four-function splitter.
//
// Host C still calls the slice names with a 16-byte lexer.
// SysV passes that lexer in two GPRs. Win64 MinGW passes it by
// address. Same-name positive target_os wrappers are the split.
// A whole-struct store keeps only the low 8 bytes, so the cursor
// moves through memcpy and the cast write-back is field stores.
// The C seed stays on disk for prove. Product g05 must not host-cc it.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

// 16 bytes. pos at 0, line at 8, col at 12.
allow(padding) struct ParserAsmLexLexer {
  pos: usize;
  line: i32;
  col: i32;
}

// 24 bytes. ok at 0, expr_ref at 4, next_lex at 8.
allow(padding) struct PthinBinopExprResult {
  ok: i32;
  expr_ref: i32;
  next_lex: ParserAsmLexLexer;
}

/**
 * Left-assoc body. Level 0 calls the cast shim. Defined in
 * pthin_expr_binop.x. This file only forwards the cursor.
 */
extern function parser_asm_parse_binop_level_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, level: i32): i32;

#[cfg(target_os = "windows")]
extern function parser_parse_cast_into(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void;
#[cfg(target_os = "linux")]
extern function parser_parse_cast_into(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void;
#[cfg(target_os = "macos")]
extern function parser_parse_cast_into(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parser_parse_cast_into(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void;

/**
 * Copy the caller's 16-byte lexer, run one precedence level, and
 * write ok / expr_ref / next_lex into the 24-byte result.
 * A null out returns. A null source or lexer writes ok=0.
 * Failure from the level function also writes ok=0 and leaves the
 * previous cursor out of the result.
 * @param arena *u8 — AST arena; passed through
 * @param lex *u8 — 16-byte cursor; not null when source is set
 * @param source *u8 — source slice; null writes ok=0
 * @param out *u8 — 24-byte parse_expr_result; null returns
 * @param level i32 — 0..9
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_expr_binop_tramp_level(arena: *u8, lex: *u8, source: *u8, out: *u8, level: i32): void {
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
  // Mutable copy. The level function parks the cursor through the
  // pointer. memcpy keeps line and col; a struct assignment does not.
  // PLATFORM: SHARED.
  let cur: u8[16] = [];
  cur[0] = 0;
  let ok: i32 = 0;
  let refv: i32 = 0;
  unsafe {
    memcpy(&cur[0], lex, 16);
    let rc: i32 = parser_asm_parse_binop_level_x_into_c(arena, &cur[0], source, &ok, &refv, level);
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
 * Call parser_parse_cast_into. Win64 already holds the lexer
 * address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinBinopExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_expr_binop_call_cast(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void {
  unsafe {
    parser_parse_cast_into(arena, lex, source, out);
  }
}

/**
 * Call parser_parse_cast_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinBinopExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_expr_binop_call_cast(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_cast_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_cast_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinBinopExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_expr_binop_call_cast(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_cast_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_cast_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *ParserAsmLexLexer — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinBinopExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_expr_binop_call_cast(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *PthinBinopExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_cast_into(arena, *lex, source, out);
  }
}

/**
 * Pointer face for parse_cast. Copies nothing into a second lexer
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
export function parser_parse_cast_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  // The by-value spill sits in the wrapper. This frame still holds
  // the 24-byte result, and the historical fill path was short by
  // more than the result alone. PLATFORM: SHARED.
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinBinopExprResult = {
    ok: 0,
    expr_ref: 0,
    next_lex: { pos: 0, line: 0, col: 0 }
  };
  unsafe {
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    pthin_expr_binop_call_cast(arena, p, source, &res);
    out_ok[0] = res.ok;
    out_expr_ref[0] = res.expr_ref;
    p.pos = res.next_lex.pos;
    p.line = res.next_lex.line;
    p.col = res.next_lex.col;
  }
  return 1;
}

/**
 * By-value face for parse_term. Shape: cast ( (*|/|%) cast )*.
 * Forwards to the pointer body at level 0.
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
export function parser_asm_parse_term_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_term. Shape: cast ( (*|/|%) cast )*.
 * Forwards to the pointer body at level 0.
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
export function parser_asm_parse_term_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_term. Shape: cast ( (*|/|%) cast )*.
 * Forwards to the pointer body at level 0.
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
export function parser_asm_parse_term_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_term. Shape: cast ( (*|/|%) cast )*.
 * Forwards to the pointer body at level 0.
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
export function parser_asm_parse_term_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_addsub. Shape: term ( (+|-) term )*.
 * Forwards to the pointer body at level 1.
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
export function parser_asm_parse_addsub_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_addsub. Shape: term ( (+|-) term )*.
 * Forwards to the pointer body at level 1.
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
export function parser_asm_parse_addsub_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_addsub. Shape: term ( (+|-) term )*.
 * Forwards to the pointer body at level 1.
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
export function parser_asm_parse_addsub_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_addsub. Shape: term ( (+|-) term )*.
 * Forwards to the pointer body at level 1.
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
export function parser_asm_parse_addsub_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_shift. Shape: addsub ( (<<|>>) addsub )*.
 * Forwards to the pointer body at level 2.
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
export function parser_asm_parse_shift_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 2);
  }
}

/**
 * By-value face for parse_shift. Shape: addsub ( (<<|>>) addsub )*.
 * Forwards to the pointer body at level 2.
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
export function parser_asm_parse_shift_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 2);
  }
}

/**
 * By-value face for parse_shift. Shape: addsub ( (<<|>>) addsub )*.
 * Forwards to the pointer body at level 2.
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
export function parser_asm_parse_shift_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 2);
  }
}

/**
 * By-value face for parse_shift. Shape: addsub ( (<<|>>) addsub )*.
 * Forwards to the pointer body at level 2.
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
export function parser_asm_parse_shift_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 2);
  }
}

/**
 * By-value face for parse_relcompare. Shape: shift ( (<|<=|>|>=) shift )*.
 * Forwards to the pointer body at level 3.
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
export function parser_asm_parse_relcompare_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 3);
  }
}

/**
 * By-value face for parse_relcompare. Shape: shift ( (<|<=|>|>=) shift )*.
 * Forwards to the pointer body at level 3.
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
export function parser_asm_parse_relcompare_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 3);
  }
}

/**
 * By-value face for parse_relcompare. Shape: shift ( (<|<=|>|>=) shift )*.
 * Forwards to the pointer body at level 3.
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
export function parser_asm_parse_relcompare_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 3);
  }
}

/**
 * By-value face for parse_relcompare. Shape: shift ( (<|<=|>|>=) shift )*.
 * Forwards to the pointer body at level 3.
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
export function parser_asm_parse_relcompare_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 3);
  }
}

/**
 * By-value face for parse_compare. Shape: relcompare ( (==|!=) relcompare )*.
 * Forwards to the pointer body at level 4.
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
export function parser_asm_parse_compare_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 4);
  }
}

/**
 * By-value face for parse_compare. Shape: relcompare ( (==|!=) relcompare )*.
 * Forwards to the pointer body at level 4.
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
export function parser_asm_parse_compare_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 4);
  }
}

/**
 * By-value face for parse_compare. Shape: relcompare ( (==|!=) relcompare )*.
 * Forwards to the pointer body at level 4.
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
export function parser_asm_parse_compare_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 4);
  }
}

/**
 * By-value face for parse_compare. Shape: relcompare ( (==|!=) relcompare )*.
 * Forwards to the pointer body at level 4.
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
export function parser_asm_parse_compare_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 4);
  }
}

/**
 * By-value face for parse_bitand. Shape: compare ( & compare )*.
 * Forwards to the pointer body at level 5.
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
export function parser_asm_parse_bitand_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 5);
  }
}

/**
 * By-value face for parse_bitand. Shape: compare ( & compare )*.
 * Forwards to the pointer body at level 5.
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
export function parser_asm_parse_bitand_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 5);
  }
}

/**
 * By-value face for parse_bitand. Shape: compare ( & compare )*.
 * Forwards to the pointer body at level 5.
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
export function parser_asm_parse_bitand_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 5);
  }
}

/**
 * By-value face for parse_bitand. Shape: compare ( & compare )*.
 * Forwards to the pointer body at level 5.
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
export function parser_asm_parse_bitand_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 5);
  }
}

/**
 * By-value face for parse_bitxor. Shape: bitand ( ^ bitand )*.
 * Forwards to the pointer body at level 6.
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
export function parser_asm_parse_bitxor_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 6);
  }
}

/**
 * By-value face for parse_bitxor. Shape: bitand ( ^ bitand )*.
 * Forwards to the pointer body at level 6.
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
export function parser_asm_parse_bitxor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 6);
  }
}

/**
 * By-value face for parse_bitxor. Shape: bitand ( ^ bitand )*.
 * Forwards to the pointer body at level 6.
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
export function parser_asm_parse_bitxor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 6);
  }
}

/**
 * By-value face for parse_bitxor. Shape: bitand ( ^ bitand )*.
 * Forwards to the pointer body at level 6.
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
export function parser_asm_parse_bitxor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 6);
  }
}

/**
 * By-value face for parse_bitor. Shape: bitxor ( | bitxor )*.
 * Forwards to the pointer body at level 7.
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
export function parser_asm_parse_bitor_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 7);
  }
}

/**
 * By-value face for parse_bitor. Shape: bitxor ( | bitxor )*.
 * Forwards to the pointer body at level 7.
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
export function parser_asm_parse_bitor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 7);
  }
}

/**
 * By-value face for parse_bitor. Shape: bitxor ( | bitxor )*.
 * Forwards to the pointer body at level 7.
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
export function parser_asm_parse_bitor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 7);
  }
}

/**
 * By-value face for parse_bitor. Shape: bitxor ( | bitxor )*.
 * Forwards to the pointer body at level 7.
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
export function parser_asm_parse_bitor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 7);
  }
}

/**
 * By-value face for parse_logand. Shape: bitor ( && bitor )*.
 * Forwards to the pointer body at level 8.
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
export function parser_asm_parse_logand_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 8);
  }
}

/**
 * By-value face for parse_logand. Shape: bitor ( && bitor )*.
 * Forwards to the pointer body at level 8.
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
export function parser_asm_parse_logand_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 8);
  }
}

/**
 * By-value face for parse_logand. Shape: bitor ( && bitor )*.
 * Forwards to the pointer body at level 8.
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
export function parser_asm_parse_logand_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 8);
  }
}

/**
 * By-value face for parse_logand. Shape: bitor ( && bitor )*.
 * Forwards to the pointer body at level 8.
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
export function parser_asm_parse_logand_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 8);
  }
}

/**
 * By-value face for parse_logor. Shape: logand ( || logand )*.
 * Forwards to the pointer body at level 9.
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
export function parser_asm_parse_logor_into_slice_c(arena: *u8, lex: *ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, lex as *u8, source, out, 9);
  }
}

/**
 * By-value face for parse_logor. Shape: logand ( || logand )*.
 * Forwards to the pointer body at level 9.
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
export function parser_asm_parse_logor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 9);
  }
}

/**
 * By-value face for parse_logor. Shape: logand ( || logand )*.
 * Forwards to the pointer body at level 9.
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
export function parser_asm_parse_logor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 9);
  }
}

/**
 * By-value face for parse_logor. Shape: logand ( || logand )*.
 * Forwards to the pointer body at level 9.
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
export function parser_asm_parse_logor_into_slice_c(arena: *u8, lex: ParserAsmLexLexer, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_binop_tramp_level(arena, &lex as *u8, source, out, 9);
  }
}

/**
 * Slice marker. Ten levels, term through logor.
 * @return i32 — always 10
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_pthin_expr_binop_slice_marker(): i32 {
  return 10;
}

/**
 * Anchor so g05 can tell this pure-asm object from a host-cc seed.
 * @return i32 — always 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pthin_expr_binop_tramp_w1535_anchor(): i32 {
  return 0;
}

