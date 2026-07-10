// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-31：真迁 .x — shux check 静默成功查询（deno check 语义）。
// 产品：./shux-c -E → seeds/fmt_check_cmd.from_x.c（+ C 尾段）。
// C 尾：路径收集、walk_dir、fmt/check CLI、argv 拼装、lint 策略。
// 说明：本 TU 提供 driver_check_quiet_ok_get 强符号（覆盖 driver_abi weak 默认）。

#[no_mangle]
function driver_check_quiet_ok_get(): i32 {
  // deno check：全部成功时不打印逐文件 check OK。
  return 1;
}
