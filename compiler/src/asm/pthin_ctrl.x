// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-286 / P2 parser thin P5 ctrl：if_stmt / match / if_expr。
// 产品实现：seeds/pthin_ctrl.from_x.c（#include 三 slice.inc）；
// hybrid 宏 SHUX_PTHIN_CTRL_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parse_if_stmt_into_c / parse_match_* / parse_if_expr_into_c / realign helpers。
