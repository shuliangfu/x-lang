// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-325 / P2 parser thin P16 diag pipeline：
// onefunc_wired + diag_parse_one_after_collect + parse_one_function_ok +
// module import getters + diag_lex_after_imports。
// 产品实现：seeds/pthin_diag_pipeline.from_x.c（#include diag_pipeline_slice.inc ≈914）；
// hybrid 宏 SHUX_PTHIN_DIAG_PIPELINE_FROM_X。
