// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-302 / P2 runtime rest：errno 诊断族 pure 门闩。
// 产品实现：seeds/rt_diag_errno.from_x.c；hybrid 宏 SHUX_RT_DIAG_ERRNO_FROM_X。
//
// 符号：runtime_diag_code_for_kind / runtime_diag_errno{,_path,_path_pair} /
//       runtime_diag_cli_usage_note。

extern "C" function strcmp(a: *u8, b: *u8): i32;

/** kind 文案 → 诊断码（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function runtime_diag_code_for_kind(kind: *u8): *u8 {
  if (kind == 0 as *u8) {
    return 0 as *u8;
  }
  return 0 as *u8;
}
