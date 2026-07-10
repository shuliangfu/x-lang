// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-290 / P2 parser thin P9 stretch lite：TokenKind 表、import 路径、bind 校验。
// 产品实现：seeds/pthin_stretch.from_x.c（#include emit_heavy_stretch_slice.inc）；
// hybrid 宏 SHUX_PTHIN_STRETCH_FROM_X。
// suite（≈28k）仍 mega #include，不本步 hybrid。
//
// 符号：parser_asm_stretch_token_run_len_c / import_path_* / bind_name_validate 等。
