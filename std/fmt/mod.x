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

// std.fmt — 格式化与标准输出（对标 Zig std.fmt、Rust std::fmt）
//
// 【文件职责】
// 重导出 core.fmt；提供 print/println；多字段 format 通过函数重载按实参类型分派。
const fmt = import("core.fmt");
const io = import("std.io");

/** Tier-S 烟测钩子。 */
export function placeholder(): i32 { return 0; }

/** 重导出 core.fmt：整型占位（薄转发，供 `import("std.fmt")` 直接调用）。 */
export function format(x: i32): i32 { return fmt.fmt_i32(x); }
/** 将标量十进制/布尔/浮点写入 buf，返回写入字节数，不足返回 -1（按实参类型重载）。 */
export function to_buf(buf: *u8, cap: i32, x: i32): i32 { return fmt.fmt_i32_to_buf(buf, cap, x); }
export function to_buf(buf: *u8, cap: i32, u: u32): i32 { return fmt.fmt_u32_to_buf(buf, cap, u); }
export function to_buf(buf: *u8, cap: i32, x: i64): i32 { return fmt.fmt_i64_to_buf(buf, cap, x); }
export function to_buf(buf: *u8, cap: i32, u: u64): i32 { return fmt.fmt_u64_to_buf(buf, cap, u); }
export function to_buf(buf: *u8, cap: i32, x: usize): i32 { return fmt.fmt_usize_to_buf(buf, cap, x); }
export function to_buf(buf: *u8, cap: i32, x: isize): i32 { return fmt.fmt_isize_to_buf(buf, cap, x); }
export function to_buf(buf: *u8, cap: i32, b: bool): i32 { return fmt.fmt_bool_to_buf(buf, cap, b); }
export function to_buf(buf: *u8, cap: i32, x: f64): i32 { return fmt.fmt_f64_to_buf(buf, cap, x); }
export function to_buf_prec(buf: *u8, cap: i32, x: f64, prec: i32): i32 {
  return fmt.fmt_f64_to_buf_prec(buf, cap, x, prec);
}
export function hex_to_buf(buf: *u8, cap: i32, u: u32): i32 { return fmt.fmt_u32_hex_to_buf(buf, cap, u); }
export function hex_to_buf(buf: *u8, cap: i32, u: u64): i32 { return fmt.fmt_u64_hex_to_buf(buf, cap, u); }
export function append_to_buf(buf: *u8, cap: i32, off: i32, x: i32): i32 {
  return fmt.fmt_append_i32_to_buf(buf, cap, off, x);
}
export function append_to_buf(buf: *u8, cap: i32, off: i32, x: i64): i32 {
  return fmt.fmt_append_i64_to_buf(buf, cap, off, x);
}

/** 单占位模板：pat 中首个 brace-pair 替换为 i32 十进制（STD-166）。 */
export function format_template(buf: *u8, cap: i32, pat: *u8, pat_len: i32, val: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  let replaced: i32 = 0;
  while (i < pat_len) {
    if (replaced == 0 && i + 1 < pat_len && pat[i] == 123 && pat[i + 1] == 125) {
      let n: i32 = fmt.fmt_i32_to_buf(&buf[o], cap - o, val);
      if (n < 0) { return -1; }
      o = o + n;
      i = i + 2;
      replaced = 1;
    } else {
      if (o >= cap) { return -1; }
      buf[o] = pat[i];
      o = o + 1;
      i = i + 1;
    }
  }
  return o;
}

// ——— 标准输出 print/println（stdout）：字节串 + 标量重载 ———
/** 将 ptr[0..len) 写入 stdout；返回写入字节数，-1 错误。 */
export function print(ptr: *u8, len: i32): i32 { return io.print(ptr, len as usize); }
/** 将字节切片写入 stdout。 */
export function print(s: u8[]): i32 { return io.print(s.data, s.length); }

/** 将 ptr[0..len) 写入 stdout 并追加换行。 */
export function println(ptr: *u8, len: i32): i32 {
  let r: i32 = io.print(ptr, len as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
/** 将字节切片写入 stdout 并追加换行。 */
export function println(s: u8[]): i32 {
  let r: i32 = io.print(s.data, s.length);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}

/** 将 i32 十进制写入 stdout。 */
export function print(x: i32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: i32): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: u32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: u32): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: i64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: i64): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: u64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: u64): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: usize): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_usize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: usize): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_usize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: isize): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_isize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: isize): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_isize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: bool): i32 {
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_bool_to_buf(&buf[0], 8, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: bool): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_bool_to_buf(&buf[0], 8, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}
export function print(x: f64): i32 {
  let buf: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_f64_to_buf(&buf[0], 64, x);
  if (n < 0) { return -1; }
  return io.print(&buf[0], n as usize);
}
export function println(x: f64): i32 {
  /* 勿 print(x) 自调用重载：typeck 未写 call_resolved 时 C 会落到切片 print 形参。 */
  let buf: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_f64_to_buf(&buf[0], 64, x);
  if (n < 0) { return -1; }
  let r: i32 = io.print(&buf[0], n as usize);
  let nl: u8[1] = [10];
  let ign: i32 = io.print(&nl[0], 1);
  return r;
}

/** format 整数 overload 共用体：按形参类型调用 fmt_scalar_to_buf。 */
export function format(buf: *u8, cap: i32, a: i32, b: i32): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: i32, b: u32): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_u32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: u32, b: i32): i32 {
  let n1: i32 = fmt.fmt_u32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: u32, b: u32): i32 {
  let n1: i32 = fmt.fmt_u32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_u32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: i64, b: i32): i32 {
  let n1: i32 = fmt.fmt_i64_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: i32, b: i64): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i64_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: i64, b: i64): i32 {
  let n1: i32 = fmt.fmt_i64_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i64_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: u64, b: u64): i32 {
  let n1: i32 = fmt.fmt_u64_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_u64_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: usize, b: usize): i32 {
  let n1: i32 = fmt.fmt_usize_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_usize_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: isize, b: i32): i32 {
  let n1: i32 = fmt.fmt_isize_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: i32, b: usize): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_usize_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, p: *u8, v: i32): i32 {
  let n1: i32 = fmt.fmt_ptr_to_buf(buf, cap, p);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, v);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, a: bool, b: bool): i32 {
  let n1: i32 = fmt.fmt_bool_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_bool_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}
export function format(buf: *u8, cap: i32, x: f64, v: i32): i32 {
  let n1: i32 = fmt.fmt_f64_to_buf(buf, cap, x);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, v);
  if (n2 < 0) { return -1; }
  return n1 + n2;
}

export function format(buf: *u8, cap: i32, a: i32, b: i32, c: i32): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  let n3: i32 = fmt.fmt_i32_to_buf(&buf[n1 + n2], cap - n1 - n2, c);
  if (n3 < 0) { return -1; }
  return n1 + n2 + n3;
}
export function format(buf: *u8, cap: i32, a: i32, b: u32, c: usize): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_u32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  let n3: i32 = fmt.fmt_usize_to_buf(&buf[n1 + n2], cap - n1 - n2, c);
  if (n3 < 0) { return -1; }
  return n1 + n2 + n3;
}

/** 重导出 core.fmt 指针格式化。 */
export function ptr_to_buf(buf: *u8, cap: i32, p: *u8): i32 {
  return fmt.fmt_ptr_to_buf(buf, cap, p);
}
/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
export function fmt_module_anchor(): i32 { return 0; }
