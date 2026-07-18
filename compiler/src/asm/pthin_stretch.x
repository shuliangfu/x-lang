// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-290 / P2 parser thin P9 stretch lite：TokenKind 表、import 路径、bind 校验。
// G-02f-318：并入 suite（emit_heavy_stretch_suite_slice ≈28k）同一 hybrid 宏。
// 产品实现：seeds/pthin_stretch.from_x.c（#include stretch + suite slice.inc）；
// hybrid 宏 SHUX_PTHIN_STRETCH_FROM_X。
//
// 符号：parser_asm_stretch_token_run_len_c / import_path_* / bind_name_validate
//       + suite 审计 probe/audit 族（见 suite_slice.inc）。
