// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-279 / P2 parser thin P2：let/alias 册（body_let + top_level_let + type_alias）。
// 产品实现：seeds/pthin_let_alias.from_x.c（#include 既有 *_slice.inc）；
// hybrid 宏 SHUX_PTHIN_LET_ALIAS_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：
//   parser_asm_parse_body_let_bracket_compound_init_ref_slice_c
//   parser_asm_parse_cond_expr_into_slice_c
//   parser_asm_parse_one_top_level_let_into_slice_c
//   parser_asm_parse_one_type_alias_into_slice_c
//   labi_pthin_let_alias_slice_marker
