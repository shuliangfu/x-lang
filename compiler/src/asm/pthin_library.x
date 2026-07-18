// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-324 / P2 parser thin P15 library parse：
// parse_one_function_library_{into,buf,scan} + lex_from_{lr,try_skip,library}。
// 产品实现：seeds/pthin_library.from_x.c（#include library_slice.inc ≈1.8k）；
// hybrid 宏 SHUX_PTHIN_LIBRARY_FROM_X。
