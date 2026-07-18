// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-285 / P2 parser thin P4-ternary：ternary / assign 层。
// 产品实现：seeds/pthin_expr_ternary.from_x.c（#include ternary_assign_slice.inc）；
// hybrid 宏 SHUX_PTHIN_EXPR_TERNARY_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parser_asm_parse_{ternary,assign}_into_slice_c。
