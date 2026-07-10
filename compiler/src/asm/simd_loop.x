// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-8：simd_loop 产品源迁 seeds/simd_loop.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 入口；循环剥离实现仍在 seed C。
// 产品：cc seeds/simd_loop.from_x.c → src/asm/simd_loop.o
//
// 导出（C ABI，见 include/simd_loop.h）：
//   glue_try_simd_peel_index_add_while_elf_c
//   glue_try_simd_peel_f32_soa_sum_while_elf_c

function simd_loop_x_doc_anchor(): i32 {
  return 0;
}
