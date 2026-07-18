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

// std.dynlib — 动态加载 .so/.dll（对标 Zig std.DynLib、Rust libloading）
//
// 【文件职责】open(path)、sym(lib, name)、close(lib)。按需链接。
// 【依赖】core；与 std/dynlib/dynlib.x + runtime_dynlib_os.c 同属一模块（F-dynlib v2 / F-ZC）。

extern function dynlib_open_c(path: *u8): *u8;
extern function dynlib_sym_c(lib: *u8, name: *u8): *u8;
extern function dynlib_close_c(lib: *u8): void;
extern function dynlib_last_error_copy_c(buf: *u8, cap: i32): i32;

/** 打开动态库 path（NUL 结尾）；失败返回 0。 */
export function open(path: *u8): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = dynlib_open_c(path); }
  return _rc;
}

/** 取符号 name（NUL 结尾）；失败返回 0。 */
export function sym(lib: *u8, name: *u8): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = dynlib_sym_c(lib, name); }
  return _rc;
}

/** 关闭动态库。 */
export function close(lib: *u8): void {
  unsafe {
    dynlib_close_c(lib);
  }
}

/** 复制最近一次 open/sym 失败诊断到 buf；返回写入字节数，无内容返回 0（STD-096）。 */
export function last_os_error(buf: *u8, cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = dynlib_last_error_copy_c(buf, cap); }
  return _rc;
}
