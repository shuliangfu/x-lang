// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* wave237 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * parser_asm_parse_expr_debug_enabled is pure orch (no *_impl).
 * PLATFORM: SHARED — product hybrid pure uses same face as cold seed twin. */
export extern "C" function link_abi_getenv(name: *u8): *u8;

/** Exported function `parser_asm_parse_expr_link_x_doc_anchor`.
 * Implements `parser_asm_parse_expr_link_x_doc_anchor`.
 * @return i32
 */
export function parser_asm_parse_expr_link_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Whether XLANG_PARSER_ASM_DEBUG enables parser-asm parse_expr debug.
 * wave237 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * Rules (≡ historical seed): null / empty / leading '0' → 0; any other non-empty → 1.
 * @return i32 — 1 if debug enabled, 0 otherwise
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function parser_asm_parse_expr_debug_enabled(): i32 {
  unsafe {
    // wave237 G.7: XLANG_PARSER_ASM_DEBUG via link_abi_getenv (not raw getenv / not *_impl).
    let v: *u8 = link_abi_getenv("XLANG_PARSER_ASM_DEBUG");
    if (v == 0 as *u8) {
      return 0;
    }
    if (v[0] == 0) {
      return 0;
    }
    // Leading ASCII '0' (48) disables debug (≡ historical seed).
    if (v[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}
