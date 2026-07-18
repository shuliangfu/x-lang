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

// std.uuid — UUID v4/v7 生成、解析与比较（STD-075）
//
// 【文件职责】
// 128-bit UUID 布局；v4（CSPRNG）、v7（Unix 毫秒有序）；
// 标准字符串 parse/format；eq / version / as_bytes。
//
// 【对标】RFC 9562、Go google/uuid、Zig std.uuid。

/** 128-bit UUID 字节布局（RFC 9562 网络序分组）。 */
allow(padding) struct Uuid {
  bytes: u8[16];
}

extern function uuid_new_v4_c(out: *u8): i32;
extern function uuid_new_v7_c(out: *u8): i32;
extern function uuid_parse_c(ptr: *u8, len: i32, out: *u8): i32;
extern function uuid_format_c(u: *u8, out: *u8, out_cap: i32): i32;
extern function uuid_eq_c(a: *u8, b: *u8): i32;
extern function uuid_version_c(u: *u8): i32;

/** 生成 UUID v4；失败返回全零 Uuid。 */
export function new_v4(): Uuid {
  let u: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  unsafe { if (uuid_new_v4_c(&u.bytes[0]) != 0) {
    return Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  } }
  return u;
}

/** 生成 UUID v7（RFC 9562：墙钟毫秒 + 同毫秒序号单调递增）；失败返回全零 Uuid。 */
export function new_v7(): Uuid {
  let u: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  unsafe { 
    if (uuid_new_v7_c(&u.bytes[0]) != 0) {
      return Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
    } 
  }
  return u;
}

/** 解析 UUID 字符串（36 带连字符或 32 纯 hex）；0 成功，-1 失败。 */
export function parse(ptr: *u8, len: i32, out: *Uuid): i32 {
  if (out == 0) { return -1; }
  unsafe { return uuid_parse_c(ptr, len, &out.bytes[0]); }
  return 0; // unreachable — typeck workaround
}

/** 格式化为小写连字符字符串；返回 36，失败 -1。 */
export function format(u: Uuid, out: *u8, out_cap: i32): i32 {
  unsafe { return uuid_format_c(&u.bytes[0], out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** 128-bit 相等：1 是，0 否。 */
export function eq(a: Uuid, b: Uuid): i32 {
  unsafe { return uuid_eq_c(&a.bytes[0], &b.bytes[0]); }
  return 0; // unreachable — typeck workaround
}

/** 版本 nibble（4=v4，7=v7）；非法 -1。 */
export function version(u: Uuid): i32 {
  unsafe { return uuid_version_c(&u.bytes[0]); }
  return 0; // unreachable — typeck workaround
}

/** 返回 UUID 首字节指针（16 字节连续；零拷贝视图）。 */
export function as_bytes(u: *Uuid): *u8 {
  if (u == 0) { return 0 as *u8; }
  return &u.bytes[0];
}
