// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// std.debug — 开发调试输出（stderr）+ core.assert 重导出
//
// 【文件职责】
// print/println 写 stderr（对标 Zig std.debug.print）；断言转发 core.assert。
// 程序正常输出用 std.fmt（stdout）；正式日志用 std.log。
const fmt = import("std.fmt");
const io = import("std.io");
const assert_mod = import("core.assert");

/** Tier-S 烟测钩子。 */
export function placeholder(): i32 { return 0; }

// ——— stderr print/println（printf 式调试，不对用户程序 stdout 污染） ———

/** 将 ptr[0..len) 写入 stderr。 */
export function print(ptr: *u8, len: i32): i32 {
  return io.write_stderr(ptr, len as usize);
}

/** 将 ptr[0..len) 写入 stderr 并追加换行。 */
export function println(ptr: *u8, len: i32): i32 {
  let r: i32 = io.write_stderr(ptr, len as usize);
  let nl: u8[1] = [10];
  let _: i32 = io.write_stderr(&nl[0], 1);
  return r;
}

/** 将 i32 十进制写入 stderr。 */
export function print(x: i32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.write_stderr(&buf[0], n as usize);
}
export function println(x: i32): i32 {
  let r: i32 = print(x);
  let nl: u8[1] = [10];
  let _: i32 = io.write_stderr(&nl[0], 1);
  return r;
}
export function print(x: u32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.write_stderr(&buf[0], n as usize);
}
export function println(x: u32): i32 {
  let r: i32 = print(x);
  let nl: u8[1] = [10];
  let _: i32 = io.write_stderr(&nl[0], 1);
  return r;
}
export function print(x: i64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.write_stderr(&buf[0], n as usize);
}
export function println(x: i64): i32 {
  let r: i32 = print(x);
  let nl: u8[1] = [10];
  let _: i32 = io.write_stderr(&nl[0], 1);
  return r;
}
export function print(x: bool): i32 {
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.to_buf(&buf[0], 8, x);
  if (n < 0) { return -1; }
  return io.write_stderr(&buf[0], n as usize);
}
export function println(x: bool): i32 {
  let r: i32 = print(x);
  let nl: u8[1] = [10];
  let _: i32 = io.write_stderr(&nl[0], 1);
  return r;
}
export function print(x: f64): i32 {
  let buf: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.to_buf(&buf[0], 64, x);
  if (n < 0) { return -1; }
  return io.write_stderr(&buf[0], n as usize);
}
export function println(x: f64): i32 {
  let r: i32 = print(x);
  let nl: u8[1] = [10];
  let _: i32 = io.write_stderr(&nl[0], 1);
  return r;
}

// ——— 重导出 core.assert（不变量；失败 panic，非测试 expect） ———
export function assert(b: bool): i32 { return assert_mod.assert(b); }
export function debug_assert(b: bool): i32 { return assert_mod.debug_assert(b); }
export function assert_eq(a: i32, b: i32): i32 { return assert_mod.assert_eq_i32(a, b); }
export function assert_ne(a: i32, b: i32): i32 { return assert_mod.assert_ne_i32(a, b); }
export function assert_eq(a: u32, b: u32): i32 { return assert_mod.assert_eq_u32(a, b); }
export function assert_ne(a: u32, b: u32): i32 { return assert_mod.assert_ne_u32(a, b); }
export function assert_eq(a: bool, b: bool): i32 { return assert_mod.assert_eq_bool(a, b); }
export function assert_ne(a: bool, b: bool): i32 { return assert_mod.assert_ne_bool(a, b); }
export function assert_eq(a: u64, b: u64): i32 { return assert_mod.assert_eq_u64(a, b); }
export function assert_ne(a: u64, b: u64): i32 { return assert_mod.assert_ne_u64(a, b); }
export function assert_eq(a: *u8, b: *u8): i32 { return assert_mod.assert_eq_ptr(a, b); }
export function assert_ne(a: *u8, b: *u8): i32 { return assert_mod.assert_ne_ptr(a, b); }

/** 模块尾占位：transitive import 解析时末位 function 会丢失。 */
export function debug_module_anchor(): i32 { return 0; }
