// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-323 / P2 parser thin P14 skip_if：
// skip_trait_impl_block_raw + skip_one_if_core/statement + module_try_register_enum。
// 产品实现：seeds/pthin_skip_if.from_x.c（#include skip_if_slice.inc ≈955）；
// hybrid 宏 SHUX_PTHIN_SKIP_IF_FROM_X。
