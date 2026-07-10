// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-284 / P2 parser thin P4-binop：左结合二元链（term…logor）。
// 产品实现：seeds/pthin_expr_binop.from_x.c（#include expr_binop_slice.inc）；
// hybrid 宏 SHUX_PTHIN_EXPR_BINOP_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parse_{term,addsub,shift,relcompare,compare,bitand,bitxor,bitor,logand,logor}_into_slice_c。
