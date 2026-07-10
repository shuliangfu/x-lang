// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-326 / P2 parser thin P17 diag_late：
// diag_after_imports_then_structs + diag_fail_at_token_kind +
// diag_skip_let_const_buf + body_skip_let_const_then_if_buf。
// 产品实现：seeds/pthin_diag_late.from_x.c（#include diag_late_slice.inc ≈269）；
// hybrid 宏 SHUX_PTHIN_DIAG_LATE_FROM_X。
