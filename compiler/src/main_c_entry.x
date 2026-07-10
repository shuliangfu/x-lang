// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-16：LEGACY C main 入口源在 seeds/main.from_x.c（勿与 src/main.x 驱动逻辑混淆）。
// 产品：cc seeds/main.from_x.c → src/main.o / main_driver.o / main_x.o（变体 flags）。
// 真入口业务逻辑见 src/main.x。

function main_c_entry_x_doc_anchor(): i32 {
  return 0;
}
