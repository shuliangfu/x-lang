// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Win tip_l4 DIG: xlang_bi CG002 on parser_asm_lex_wrap_buf_c (even alone;
// code_len>0 out_len=0). Full bridge nowrap TU + this stub ld -r past P9a.
// Stub returns null; callers already null-check wrap slots.
// PLATFORM: WINDOWS. Not used on Darwin/Linux (real wrap stays in bridge.x).

export function parser_asm_lex_wrap_buf_c(data: *u8, len: i32): *u8 {
  return 0 as *u8;
}
