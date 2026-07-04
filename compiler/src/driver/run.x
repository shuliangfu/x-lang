// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// run.x — shux run 子命令
// 行为：编译 .x → a.out → 运行
// 用法：shux run x.x [-o exe]
// 注：cmd_run 内用 `if (rc == 0)` 再执行 exec；`if (rc != 0) return` 与 import ast
// 同编时 typeck 会误报 check_block（compiler 限制）。

const ast = import("ast");
/** C 侧 runtime.c：fork+exec 运行编译产物（须写全 C 链接名，-E-extern
* 不追加模块前缀）。 */
extern function driver_exec_compiled(argc: i32, argv: *u8): i32;
/** main.x 编译入口；链接符号 main_run_compiler_x_path_impl。 */
extern function main_run_compiler_x_path_impl(argc: i32, argv: *u8): i32;

/** 比较 buf[0..len-1] 与
* word_ptr[0..word_len-1]（当前未使用，保留供将来子命令解析复用）。 */
function run_eq_word(buf: *u8, len: i32, word_ptr: *u8, word_len: i32): i32 {
  if (len != word_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < len) {
    if (buf[i] != word_ptr[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

function cmd_run(argc: i32, argv: *u8): i32 {
  if (argc < 2) {
    return 1;
  }
  let rc: i32 = main_run_compiler_x_path_impl(argc, argv);
  if (rc == 0) {
    return driver_exec_compiled(argc, argv);
  }
  return rc;
}
