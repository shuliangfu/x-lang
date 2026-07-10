// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-289 / P2 parser thin P8 seed_parse：parse_into_buf / parse_into 入口编排。
// 产品实现：seeds/pthin_seed_parse.from_x.c（#include seed_parse_into_buf_slice.inc）；
// hybrid 宏 SHUX_PTHIN_SEED_PARSE_FROM_X（嵌套于 !PARSER_ASM_THIN_GLUE_NO_SEED_PARSE）。
// 产品 G05 默认仍 -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE（parse 由 parser_x 提供）。
//
// 符号：parse_into_buf / parser_parse_into_buf / parse_into / set_main_index。
