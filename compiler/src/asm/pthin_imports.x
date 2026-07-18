// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-320 / P2 parser thin P11 imports：skip_imports / collect_imports / consume_path。
// 产品实现：seeds/pthin_imports.from_x.c（#include imports_slice.inc ≈1.8k）；
// hybrid 宏 SHUX_PTHIN_IMPORTS_FROM_X。
//
// 符号：parser_asm_skip_imports_* / collect_imports_* / diag_token_after_collect_*。
