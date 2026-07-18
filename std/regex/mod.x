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

// std.regex — 最小正则（字面量/字符类/量词/分组/capture，纯 C 引擎）
// STD-062：match 引擎 perf 优化（字面量快路径 + 首字节跳跃）生产级 bench 锚点。
//
// 【文件职责】compile、match、free；STD-064 capture：group_count/offset/length。
// 【依赖】std.heap；引擎在 std/regex/regex.x（F-regex v2 纯 .x）；全平台无 regex.h。
extern function regex_compile_c(pat: *u8, pat_len: i32): *u8;
extern function regex_match_c(re: *u8, str: *u8, len: i32): i32;
extern function regex_free_c(re: *u8): void;
extern function regex_group_count_c(re: *u8): i32;
extern function regex_group_offset_c(re: *u8, group: i32): i32;
extern function regex_group_length_c(re: *u8, group: i32): i32;

/** 编译模式；失败返回 null。 */
export function compile(pat: *u8, pat_len: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = regex_compile_c(pat, pat_len); }
  return _rc;
}

/** 子串匹配；成功 0，失败 -1（对标 Rust is_match；`match` 为关键字，仅作模块 API 名）。 */
export function match(re: *u8, str: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_match_c(re, str, len); }
  return _rc;
}

/** 释放 compile 返回的句柄。 */
export function free(re: *u8): void {
  unsafe {
    regex_free_c(re);
  }
}

/** 返回 capture 槽数（含 group 0 全匹配）；compile 后即可读。 */
export function group_count(re: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_group_count_c(re); }
  return _rc;
}

/** 读上次 match 的 group 起始字节偏移；无有效 capture 时 -1。 */
export function group_offset(re: *u8, group: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_group_offset_c(re, group); }
  return _rc;
}

/** 读上次 match 的 group 匹配长度；无有效 capture 时 -1。 */
export function group_length(re: *u8, group: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_group_length_c(re, group); }
  return _rc;
}
