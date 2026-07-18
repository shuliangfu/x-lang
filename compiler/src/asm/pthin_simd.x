// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-288 / P2 parser thin P7 simd：@shuffle / @select builtin。
// 产品实现：seeds/pthin_simd.from_x.c（#include simd_builtin_slice.inc）；
// hybrid 宏 SHUX_PTHIN_SIMD_FROM_X → ld -r 进 parser_asm_thin_glue.o。
//
// 符号：parser_asm_parse_at_simd_builtin_into_c。
