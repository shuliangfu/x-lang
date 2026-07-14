// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-302/450 / P2 runtime rest：errno 诊断族 pure 门闩。
// 产品实现：seeds/rt_diag_errno.from_x.c；hybrid 宏 SHUX_RT_DIAG_ERRNO_FROM_X。
// G-02f-450：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。
//
// 符号：runtime_diag_code_for_kind / runtime_diag_errno{,_path,_path_pair} /
//       runtime_diag_cli_usage_note。

export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function runtime_diag_code_for_kind_impl(kind: *u8): *u8;

/** kind 文案 → 诊断码（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function runtime_diag_code_for_kind(kind: *u8): *u8 {
  unsafe {
    return runtime_diag_code_for_kind_impl(kind);
  }
  return 0 as *u8;
}
