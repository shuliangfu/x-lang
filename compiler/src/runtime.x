// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-14：runtime 产品源迁 seeds/runtime.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；driver/pipeline 主体仍在 seed C。
// 产品：cc seeds/runtime.from_x.c + RUNTIME_DRIVER_NO_C_CFLAGS → src/runtime_driver_no_c.o
// 其它变体：runtime_driver.o / runtime_x.o / runtime.o / runtime_driver_asm_*。

function runtime_x_doc_anchor(): i32 {
  return 0;
}
