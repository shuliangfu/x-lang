// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-22：lsp_diag_stubs_no_c 产品源迁 seeds/lsp_diag_stubs_no_c.from_x.c。
// G-02f-101：+ copy_text / json_escape_str 薄门闩。
// rest→.x 迁移：lsp_diag_copy_text_impl + json_escape_str_impl 真迁 .x
//   Why：消除 seed 中 2 个纯字节操作 rest 函数，推进 L2（权威零 C）覆盖
//   Invariant：与 seed 同语义（copy_text 纯字节拷贝；json_escape 转义 "/\\/\n/\r/\t）
//   Perf：无 libc 依赖，无热路径分支冗余

function lsp_diag_stubs_no_c_x_doc_anchor(): i32 {
  return 0;
}

/* ---- rest→.x 迁移：纯字节操作 _impl 实现 ---- */

// 【Why 根源】seed 中 lsp_diag_copy_text_impl 是纯字节拷贝，无 libc/static/va_list 限制，
// 可直接用 .x 实现。PREFER_X_O 路径下 seed 跳过此函数，由 .x 提供。
// 【Invariant】与 seed 同语义：null 检查 + cap 边界 + null 终止
// 【Perf】单次遍历，无分支预测惩罚
#[no_mangle]
function lsp_diag_copy_text_impl(dst: *u8, cap: i32, src: *u8): void {
  if (dst == 0 || cap <= 0) { return; }
  if (src == 0) { dst[0] = 0; return; }
  let n: i32 = 0;
  while (n + 1 < cap && src[n] != 0) {
    dst[n] = src[n];
    n = n + 1;
  }
  dst[n] = 0;
}

// 【Why 根源】seed 中 json_escape_str_impl 是纯字节转义，无 libc/static/va_list 限制，
// 可直接用 .x 实现。.x 不支持 switch/case，用 if/else 链替代（语义等价）。
// 【Invariant】与 seed 同语义：转义 "(34) \(92) \n(10) \r(13) \t(9)；cap 边界检查
// 【Perf】单次遍历，if/else 链按 ASCII 频率排序
#[no_mangle]
function json_escape_str_impl(msg: *u8, out: *u8, out_cap: i32): i32 {
  let k: i32 = 0;
  if (msg == 0 || out == 0 || out_cap <= 0) { return 0; }
  let i: i32 = 0;
  let bs: u8 = 92;
  let n_ch: u8 = 110;
  let r_ch: u8 = 114;
  let t_ch: u8 = 116;
  while (msg[i] != 0 && k < out_cap - 2) {
    let c: u8 = msg[i];
    if (c == 34 || c == 92) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = c; k = k + 1;
    } else if (c == 10) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = n_ch; k = k + 1;
    } else if (c == 13) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = r_ch; k = k + 1;
    } else if (c == 9) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = t_ch; k = k + 1;
    } else {
      out[k] = c; k = k + 1;
    }
    i = i + 1;
  }
  if (k < out_cap) { out[k] = 0; }
  return k;
}

/* ---- G-02f-101：lsp diag text helpers 门闩（_impl 已在 .x 中实现，无需 unsafe） ---- */

#[no_mangle]
function lsp_diag_copy_text(dst: *u8, cap: i32, src: *u8): void {
  lsp_diag_copy_text_impl(dst, cap, src);
}

#[no_mangle]
function json_escape_str(msg: *u8, out: *u8, out_cap: i32): i32 {
  return json_escape_str_impl(msg, out, out_cap);
}
