// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-283 / P2 parser thin P4-unary：parse_unary 表达式册。
// 产品实现：seeds/pthin_expr_unary.from_x.c（#include unary_slice.inc）；
// hybrid 宏 SHUX_PTHIN_EXPR_UNARY_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parser_asm_parse_unary_into_slice_c（await/run/spawn/-/!/&/* 前缀 + primary）。
