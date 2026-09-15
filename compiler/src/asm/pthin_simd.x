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

// pthin_simd.x — G-02f-288 P7 parser thin simd product bodies.
//
// 7.2.1 P7b Route C productize (2026-09-13): after P3b type_ref, simd.inc
// is the next still-host-cc product slice with a portable buf-path region.
// IDENT `shuffle` / `select` spelling is Route C (*u8 + length). Callee
// name fill (`simd_shuffle` / `simd_select`) is buf-path Route C into a
// caller buffer. Arena expr alloc, lexer by-value, and
// parse_at_simd_builtin_into stay C. Do not wrap the two AUDIT_CALL sites
// (not a contiguous already-T nop block).
//
// 7.2.1 P7c B-minus (2026-09-15): 有则补全 this file with the always-
// host-cc callee VAR + CALL wrap soup in simd_builtin_slice.inc.
// Language has no Expr by-value / no local u8[N]; C trampoline holds
// name[256], reuses parser_asm_simd_callee_name_fill_c (G.7 one fill),
// and forwards the dest buffer. Sidecar writes reuse existing pabi
// set_kind / set_common_zeros / set_line_col / set_var_name /
// set_call_c plus pipeline_expr_init_call_resolve_at_ref (C twin zeros
// stamp call_resolved_* = -1; pabi zeros does not). Do not FORCE pabi
// mega. Do not dest-buffer parse_at_simd_builtin this wave (extra
// lexer_next + parse_expr_into). Do not copy wrap into parse. Do not
// merge with P4b suffix CALL wrap (that wrap takes pending_n type
// args; simd builtins have none). Do not wrap the two AUDIT_CALL
// sites. Do not open a new P-lane. Do not add bodies to
// pthin_expr_primary.x.
//
// Hybrid P7b/P7c: g05_try_x_to_o this file; XLANG_PTHIN_SIMD_BODIES_FROM_X
// skips the portable .inc region. Cold: no define, full .inc stays.
// Pack encoding: (is_shuffle << 8) | need_args; 0 = no match.
// PLATFORM: SHARED freestanding.

/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/** Wave-0 pabi: write Expr.var_name / var_name_len (zeros the 256-byte slot). */
export extern "C" function pipeline_expr_set_var_name(a: *u8, er: i32, nm: *u8, nlen: i32): void;
/**
 * Suffix pabi: write call_callee_ref + call_num_type_args.
 * G.7: one writer for those slots. Do not copy; do not FORCE pabi mega;
 * do not merge with the P4b suffix CALL wrap (pending_n type args).
 */
export extern "C" function pipeline_expr_set_call_c(a: *u8, er: i32, callee_ref: i32, num_type_args: i32): void;
/**
 * Stamp call_resolved_func_index / call_resolved_dep_index = -1.
 * C twin simd_expr_common_zeros_c writes this sentinel; pabi zeros does
 * not. G.7: reuse the existing pabi writer.
 */
export extern "C" function pipeline_expr_init_call_resolve_at_ref(a: *u8, expr_ref: i32): void;

const EXPR_VAR: i32 = 3;
const EXPR_CALL: i32 = 48;

/**
 * Bounds check shared by IDENT spelling probes in this file.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @param want_len i32 — required spelling length
 * @return i32 — 1 if data is live, ident_len==want_len, and the span fits
 */
function parser_asm_simd_ident_span_ok(data: *u8, length: usize, token_start: usize, ident_len: i32, want_len: i32): i32 {
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
function parser_asm_simd_ident_byte(data: *u8, token_start: usize, i: i32): u8 {
  let c: u8 = 0;
  unsafe {
    c = data[token_start + i as usize];
  }
  return c;
}

/**
 * IDENT spelling pack for `@shuffle` / `@select`.
 * shuffle → (1 << 8) | 2; select → 3; anything else → 0.
 * Byte compares copy the C twin (`shuffle` 7 / `select` 6).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — pack, or 0 if the spelling is not a simd builtin
 * PLATFORM: SHARED — buf-path split of the former static C twin.
 */
#[no_mangle]
export function parser_asm_simd_builtin_ident_pack_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  // `shuffle` — 115,104,117,102,102,108,101
  if (parser_asm_simd_ident_span_ok(data, length, token_start, ident_len, 7) != 0) {
    if (parser_asm_simd_ident_byte(data, token_start, 0) == 115) {
      if (parser_asm_simd_ident_byte(data, token_start, 1) == 104) {
        if (parser_asm_simd_ident_byte(data, token_start, 2) == 117) {
          if (parser_asm_simd_ident_byte(data, token_start, 3) == 102) {
            if (parser_asm_simd_ident_byte(data, token_start, 4) == 102) {
              if (parser_asm_simd_ident_byte(data, token_start, 5) == 108) {
                if (parser_asm_simd_ident_byte(data, token_start, 6) == 101) {
                  return (1 << 8) | 2;
                }
              }
            }
          }
        }
      }
    }
  }
  // `select` — 115,101,108,101,99,116
  if (parser_asm_simd_ident_span_ok(data, length, token_start, ident_len, 6) != 0) {
    if (parser_asm_simd_ident_byte(data, token_start, 0) == 115) {
      if (parser_asm_simd_ident_byte(data, token_start, 1) == 101) {
        if (parser_asm_simd_ident_byte(data, token_start, 2) == 108) {
          if (parser_asm_simd_ident_byte(data, token_start, 3) == 101) {
            if (parser_asm_simd_ident_byte(data, token_start, 4) == 99) {
              if (parser_asm_simd_ident_byte(data, token_start, 5) == 116) {
                return 3;
              }
            }
          }
        }
      }
    }
  }
  return 0;
}

/**
 * Write the lowered callee name into `out[0..64)`.
 * is_shuffle != 0 → `simd_shuffle` (12); else `simd_select` (11).
 * Bytes past the name and before 64 are written 0, matching the C twin
 * (var_name is 256 wide; only the first 64 were zeroed).
 * @param is_shuffle i32 — non-zero selects simd_shuffle
 * @param out *u8 — destination; must be >= 64 bytes; null is 0
 * @return i32 — name length, or 0 on null
 * PLATFORM: SHARED — buf-path split of the inline C name fill.
 */
#[no_mangle]
export function parser_asm_simd_callee_name_fill_c(is_shuffle: i32, out: *u8): i32 {
  let nlen: i32 = 0;
  let i: i32 = 0;
  if (out == 0 as *u8) {
    return 0;
  }
  if (is_shuffle != 0) {
    // simd_shuffle
    unsafe {
      out[0] = 115;
      out[1] = 105;
      out[2] = 109;
      out[3] = 100;
      out[4] = 95;
      out[5] = 115;
      out[6] = 104;
      out[7] = 117;
      out[8] = 102;
      out[9] = 102;
      out[10] = 108;
      out[11] = 101;
    }
    nlen = 12;
  } else {
    // simd_select
    unsafe {
      out[0] = 115;
      out[1] = 105;
      out[2] = 109;
      out[3] = 100;
      out[4] = 95;
      out[5] = 115;
      out[6] = 101;
      out[7] = 108;
      out[8] = 101;
      out[9] = 99;
      out[10] = 116;
    }
    nlen = 11;
  }
  i = nlen;
  while (i < 64) {
    unsafe {
      out[i] = 0;
    }
    i = i + 1;
  }
  return nlen;
}

/**
 * Shared alloc + zeros + kind + line/col=0 + call_resolve=-1 for P7c wraps.
 * C twin writes kind then simd_expr_common_zeros_c (which stamps
 * call_resolved_* = -1); pabi zeros does not touch kind/line/col or
 * the resolve sentinel, so this order matches the dest-buffer family.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param kind i32 — ExprKind ordinal (EXPR_VAR or EXPR_CALL)
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — P7c helper. Not a second wrap authority.
 */
function skip_simd_wrap_prep(arena: *u8, kind: i32): i32 {
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
    pipeline_expr_init_call_resolve_at_ref(arena, ref);
  }
  return ref;
}

/**
 * Allocate EXPR_VAR callee + EXPR_CALL and wire call_callee_ref.
 * Dest-buffer twin of the always-host-cc wrap soup in
 * parser_asm_parse_at_simd_builtin_into_c. C trampoline holds name[256]
 * and fills it via parser_asm_simd_callee_name_fill_c (language has no
 * local u8[N]). Does not reject nlen<=0 (C twin only checks alloc).
 * num_type_args is 0 (simd builtins are not turbofish).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param name *u8 — lowered callee spelling; null → 0
 * @param nlen i32 — content length (11 or 12 from fill)
 * @return i32 — new CALL expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P7c Route C. Authority for the simd
 * callee+CALL wrap. parse_at_simd_builtin stays C; do not copy.
 * Do not merge with P4b suffix CALL wrap.
 */
#[no_mangle]
export function parser_asm_simd_call_wrap_into_c(arena: *u8, name: *u8, nlen: i32): i32 {
  let callee_ref: i32 = 0;
  let call_ref: i32 = 0;
  let n: i32 = 0;
  if (arena == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  n = nlen;
  if (n < 0) {
    n = 0;
  }
  callee_ref = skip_simd_wrap_prep(arena, EXPR_VAR);
  if (callee_ref == 0) {
    return 0;
  }
  unsafe {
    pipeline_expr_set_var_name(arena, callee_ref, name, n);
  }
  call_ref = skip_simd_wrap_prep(arena, EXPR_CALL);
  if (call_ref == 0) {
    return 0;
  }
  unsafe {
    pipeline_expr_set_call_c(arena, call_ref, callee_ref, 0);
  }
  return call_ref;
}
