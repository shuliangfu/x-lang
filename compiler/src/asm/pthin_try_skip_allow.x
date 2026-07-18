// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-322 / P2 parser thin P13 try_skip_allow：
// write_try_skip_allow_result + try_skip_allow_padding + parse_into_try_skip_allow。
// 产品实现：seeds/pthin_try_skip_allow.from_x.c（#include try_skip_allow_slice.inc ≈1.6k）；
// hybrid 宏 SHUX_PTHIN_TRY_SKIP_ALLOW_FROM_X。
