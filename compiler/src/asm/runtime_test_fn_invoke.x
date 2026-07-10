// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24：std.test 函数指针 invoke — 逻辑源说明。
// 产品仍为 seeds/runtime_test_fn_invoke.from_x.c（手写 C 间接调用）。
// 原因：.x 尚不能稳定经 usize 间接调用无参函数；真迁阻塞于语言/codegen。
// 回归：test_call_i32_void_c(fn) → fn() 或 fn==0 时 -1。

function runtime_test_fn_invoke_x_doc_anchor(): i32 {
  return 0;
}
