// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_ternary_tramp.x — checklist 6.2 / w1538.
// By-value faces parser_asm_parse_ternary_into_slice_c and
// parser_asm_parse_assign_into_slice_c, the logor pointer shim, and
// the slice marker. The four algorithm functions stay in
// pthin_expr_ternary.x. pipeline_expr_set_if_c stays in the P5 seed.
// pipeline_expr_set_binop_operands_c stays in pthin_expr_binop_set.x.
// This file is its own translation unit. It is not a fifth function
// of the Darwin four-piece body splitter.
//
// Host C still calls both slice names with a 16-byte lexer.
// SysV passes that lexer in two GPRs. Win64 MinGW passes it by
// address. Same-name positive target_os wrappers are the split.
// A whole-struct store keeps only the low 8 bytes, so the cursor
// moves through memcpy and the logor write-back is field stores.
// Stretch-audit calls stay in the C seed. They are product nops
// and are not copied here. The C seed stays on disk for prove.
// Product g05 must not host-cc it.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

// 16 bytes. pos at 0, line at 8, col at 12.
allow(padding) struct PthinTernaryLex {
  pos: usize;
  line: i32;
  col: i32;
}

// 24 bytes. ok at 0, expr_ref at 4, next_lex at 8.
allow(padding) struct PthinTernaryExprResult {
  ok: i32;
  expr_ref: i32;
  next_lex: PthinTernaryLex;
}

/**
 * Dest-buffer ternary body. Defined in pthin_expr_ternary.x.
 * This file only forwards the cursor.
 */
extern function parser_asm_parse_ternary_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

/**
 * Dest-buffer assign body. Defined in pthin_expr_ternary.x.
 * This file only forwards the cursor. The body keeps the
 * redundant double parse. Do not collapse it here.
 */
extern function parser_asm_parse_assign_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

#[cfg(target_os = "windows")]
extern function parser_parse_logor_into(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void;
#[cfg(target_os = "linux")]
extern function parser_parse_logor_into(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void;
#[cfg(target_os = "macos")]
extern function parser_parse_logor_into(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void;
#[cfg(target_os = "freebsd")]
extern function parser_parse_logor_into(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void;

/**
 * Copy the caller's 16-byte lexer, run one dest-buffer body, and
 * write ok / expr_ref / next_lex into the 24-byte result.
 * which 0 selects parse_ternary. which 1 selects parse_assign.
 * A null out returns. A null source or lexer writes ok=0.
 * Failure from the body also writes ok=0 and leaves the previous
 * cursor out of the result. Success forces ok=1.
 * @param arena *u8 — AST arena; passed through
 * @param lex *u8 — 16-byte cursor; not null when source is set
 * @param source *u8 — source slice; null writes ok=0
 * @param out *u8 — 24-byte parse_expr_result; null returns
 * @param which i32 — 0 ternary body, 1 assign body
 * @return void
 * PLATFORM: SHARED.
 */
function pthin_expr_ternary_tramp_face(arena: *u8, lex: *u8, source: *u8, out: *u8, which: i32): void {
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
    let rc: i32 = 0;
    if (which == 0) {
      rc = parser_asm_parse_ternary_x_into_c(arena, &cur[0], source, &ok, &refv);
    } else {
      rc = parser_asm_parse_assign_x_into_c(arena, &cur[0], source, &ok, &refv);
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
 * Call parser_parse_logor_into. Win64 already holds the lexer
 * address, so the pointer is forwarded.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinTernaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinTernaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
function pthin_expr_ternary_call_logor(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void {
  unsafe {
    parser_parse_logor_into(arena, lex, source, out);
  }
}

/**
 * Call parser_parse_logor_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinTernaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinTernaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
function pthin_expr_ternary_call_logor(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_logor_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_logor_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinTernaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinTernaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
function pthin_expr_ternary_call_logor(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_logor_into(arena, *lex, source, out);
  }
}

/**
 * Call parser_parse_logor_into. SysV takes the 16-byte lexer in
 * two GPRs. A touched pad keeps that spill inside `sub sp`.
 * @param arena *u8 — AST arena; not null
 * @param lex *PthinTernaryLex — cursor; not null
 * @param source *u8 — source slice; not null
 * @param out *PthinTernaryExprResult — 24-byte result; not null
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
function pthin_expr_ternary_call_logor(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *PthinTernaryExprResult): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    parser_parse_logor_into(arena, *lex, source, out);
  }
}

/**
 * Pointer face for parse_logor. The SysV wrapper loads *lex.
 * Writes ok, expr_ref, and the three cursor fields even when ok
 * is 0. A null argument returns 0 and does not call logor.
 * Returns 1 when the call ran. This is not a second logor parser.
 * @param arena *u8 — AST arena; null returns 0
 * @param lex_inout *u8 — 16-byte cursor; updated; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @param out_ok *i32 — result ok; null returns 0
 * @param out_expr_ref *i32 — result expr ref; null returns 0
 * @return i32 — 1 when the call ran, 0 when an argument was null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_parse_logor_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  // The by-value spill sits in the wrapper. This frame still holds
  // the 24-byte result, and the historical fill path was short by
  // more than the result alone. PLATFORM: SHARED.
  let frame_pad: u8[128] = [];
  frame_pad[0] = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  let res: PthinTernaryExprResult = {
    ok: 0,
    expr_ref: 0,
    next_lex: { pos: 0, line: 0, col: 0 }
  };
  unsafe {
    let p: *PthinTernaryLex = lex_inout as *PthinTernaryLex;
    pthin_expr_ternary_call_logor(arena, p, source, &res);
    out_ok[0] = res.ok;
    out_expr_ref[0] = res.expr_ref;
    p.pos = res.next_lex.pos;
    p.line = res.next_lex.line;
    p.col = res.next_lex.col;
  }
  return 1;
}

/**
 * By-value face for parse_ternary. Forwards to the pointer body.
 * Win64 receives the lexer as an address.
 * @param arena *u8 — AST arena
 * @param lex *PthinTernaryLex — cursor address
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parser_asm_parse_ternary_into_slice_c(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_ternary. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex PthinTernaryLex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function parser_asm_parse_ternary_into_slice_c(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_ternary. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex PthinTernaryLex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function parser_asm_parse_ternary_into_slice_c(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_ternary. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex PthinTernaryLex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
#[no_mangle]
export function parser_asm_parse_ternary_into_slice_c(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, &lex as *u8, source, out, 0);
  }
}

/**
 * By-value face for parse_assign. Forwards to the pointer body.
 * Win64 receives the lexer as an address.
 * @param arena *u8 — AST arena
 * @param lex *PthinTernaryLex — cursor address
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: WINDOWS x64.
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parser_asm_parse_assign_into_slice_c(arena: *u8, lex: *PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_assign. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex PthinTernaryLex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: LINUX x86_64 SysV.
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function parser_asm_parse_assign_into_slice_c(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_assign. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex PthinTernaryLex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: MACOS arm64 SysV.
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function parser_asm_parse_assign_into_slice_c(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, &lex as *u8, source, out, 1);
  }
}

/**
 * By-value face for parse_assign. Forwards to the pointer body.
 * SysV receives the lexer in two GPRs. A touched pad keeps
 * the spill inside `sub sp`.
 * @param arena *u8 — AST arena
 * @param lex PthinTernaryLex — 16-byte cursor
 * @param source *u8 — source slice
 * @param out *u8 — 24-byte parse_expr_result
 * @return void
 * PLATFORM: FREEBSD x86_64 SysV.
 */
#[cfg(target_os = "freebsd")]
#[no_mangle]
export function parser_asm_parse_assign_into_slice_c(arena: *u8, lex: PthinTernaryLex, source: *u8, out: *u8): void {
  let frame_pad: u8[32] = [];
  frame_pad[0] = 0;
  unsafe {
    pthin_expr_ternary_tramp_face(arena, &lex as *u8, source, out, 1);
  }
}

/**
 * Slice marker. Returns 2 when this object is linked.
 * 2 means the ternary face and the assign face are both here.
 * @return i32 — always 2
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_pthin_expr_ternary_slice_marker(): i32 {
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
export function pthin_expr_ternary_tramp_w1538_anchor(): i32 {
  return 0;
}
