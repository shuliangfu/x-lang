// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-10：parser_asm_thin_c 产品源迁 seeds/parser_asm_thin_c.from_x.c。
// 产品：cc seed -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/asm → parser_asm_thin_glue.o
// slice 碎片仍位于 seeds/parser_asm/parser_asm_*_slice.inc（由 seed #include）。

function parser_asm_thin_c_x_doc_anchor(): i32 {
  return 0;
}
