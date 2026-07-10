// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-285 / P2 parser thin P4-as_suffix：`as type` / `?` 传播后缀。
// 产品实现：seeds/pthin_expr_as_suffix.from_x.c（#include as_suffix_slice.inc）；
// hybrid 宏 SHUX_PTHIN_EXPR_AS_SUFFIX_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parser_asm_parse_as_suffix_into_slice_c。
