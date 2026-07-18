// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-282 / P2 parser thin P4-primary：parse_primary + finish_struct_lit。
// 产品实现：seeds/pthin_expr_primary.from_x.c（struct_lit + primary inc，同 TU）；
// hybrid 宏 SHUX_PTHIN_EXPR_PRIMARY_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parse_primary_into_slice_c / anonymous_struct_lit / finish_struct_lit_from_type_ident。
