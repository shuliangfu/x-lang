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

// test.x — shux test 子命令：在仓库根目录执行测试脚本（默认
// tests/run-all.sh）
// 符号名 driver_cmd_test：源码标识符 cmd_test + 模块前缀 driver_

const ast = import("ast");

/** C 侧 runtime.c：cd 到仓库根并 bash 执行测试脚本。 */
extern function driver_run_test(argc: i32, argv: *u8): i32;

/**
* shux test [script.sh]
* 无参时跑
* tests/run-all.sh；可指定相对仓库根的脚本路径。退出码与脚本一致（非 0
* 映射为 1）。
*/
function cmd_test(argc: i32, argv: *u8): i32 {
  return driver_run_test(argc, argv);
}
