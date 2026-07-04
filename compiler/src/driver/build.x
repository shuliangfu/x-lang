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

// build.x — shux build 子命令
// 行为：
//   - 有参数（如 shux build x.x -o exe）：编译指定 .x（run_compiler_x_path_impl）。
//   - 无参数（仅 shux build）：由 C 侧在当前目录查找
// build.x，编译并运行默认产物 ./a.out（driver_build_build_x）。
// 用法：shux build [x.x] [-o exe] [-E] [-backend c] [-L path]

const ast = import("ast");

/** main.x 实现；链接符号 main_run_compiler_x_path_impl。 */
extern function main_run_compiler_x_path_impl(argc: i32, argv: *u8): i32;

/** C 侧 runtime.c：当前目录 build.x → driver_run_compiler_full，成功后 exec
./a.out。 */
extern function driver_build_build_x(): i32;

/**
* shux build 入口：子命令已从 argv 剥离后，argc==1
* 表示除程序名外无额外参数。
*/
function cmd_build(argc: i32, argv: *u8): i32 {
  if (argc < 2) {
    return driver_build_build_x();
  }
  return main_run_compiler_x_path_impl(argc, argv);
}
