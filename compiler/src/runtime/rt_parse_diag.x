// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-307 / P2 runtime rest：已知精确 parse 失败诊断 note。
// 产品实现：seeds/rt_parse_diag.from_x.c；hybrid 宏 SHUX_RT_PARSE_DIAG_FROM_X。

/** TOKEN_STRING 失败时发 P001；否则 0（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function runtime_report_precise_parse_failure_if_known(input_path: *u8, src: *u8, src_len: usize): i32 {
  if (src == 0 as *u8 || src_len == 0) {
    return 0;
  }
  return 0;
}
