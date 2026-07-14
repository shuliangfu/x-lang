// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-307/448 / P2 runtime rest：已知精确 parse 失败诊断 note。
// 产品实现：seeds/rt_parse_diag.from_x.c；hybrid 宏 SHUX_RT_PARSE_DIAG_FROM_X。
// G-02f-448：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

export extern "C" function runtime_report_precise_parse_failure_if_known_impl(
  input_path: *u8, src: *u8, src_len: usize): i32;

/** TOKEN_STRING 失败时发 P001；否则 0（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function runtime_report_precise_parse_failure_if_known(input_path: *u8, src: *u8, src_len: usize): i32 {
  unsafe {
    return runtime_report_precise_parse_failure_if_known_impl(input_path, src, src_len);
  }
  return 0;
}
