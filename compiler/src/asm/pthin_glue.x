// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-319 / P2 parser thin P10 glue tail：parser_*_glue 薄包装 + 晚期 skip/lex helpers。
// 产品实现：seeds/pthin_glue.from_x.c（#include glue_tail_slice.inc ≈6.5k）；
// hybrid 宏 SHUX_PTHIN_GLUE_FROM_X。
//
// 符号：parser_*_glue 族、parser_asm_skip_one_function_full_into_slice_c 等。
