// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-7：simd_enc 产品源迁 seeds/simd_enc.from_x.c（纯编码，无 OS #if）。
// 本文件为语义对照 / 后续真迁 .x 的入口说明；全量 opcode 表仍在 seed C。
// 产品：cc seeds/simd_enc.from_x.c → src/asm/simd_enc.o
//
// 导出（C ABI，见 include/simd_enc.h）：
//   simd_enc_try_hw_vector_*_rbp / pshufd / select / 低层 x86 enc helpers 等。

// 占位：避免空 TU；产品不链本 .x 生成物。
function simd_enc_x_doc_anchor(): i32 {
  return 0;
}
