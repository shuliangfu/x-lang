// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-321 / P2 parser thin P12 skip top-level：
// skip_one_struct/enum/trait/impl/extern + parse_one_extern + enum_register。
// 产品实现：seeds/pthin_skip_tl.from_x.c（#include skip_tl_slice.inc ≈1.4k）；
// hybrid 宏 SHUX_PTHIN_SKIP_TL_FROM_X。
