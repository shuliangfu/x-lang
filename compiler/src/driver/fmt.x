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

// fmt.x — shux fmt 子命令：委托 C 侧 fmt_check_cmd（对标 deno fmt）
// 符号名 driver_cmd_fmt：源码标识符 cmd_fmt + 模块前缀 driver_
// 勿 import ast：shux-c -E 生成 driver_fmt_gen.c 时无需 AST 
// 类型，且可避免解析失败。

/** C 侧 fmt_check_cmd.c：无参递归 cwd；--check / --fail-fast / --ignore=。 */
extern function driver_run_fmt(argc: i32, argv: *u8): i32;

/**
* shux fmt [--check] [--fail-fast] [--ignore=a,b] [path ...]
* 无路径时格式化当前目录下全部 .x；--check 成功时无输出。
*/
function cmd_fmt(argc: i32, argv: *u8): i32 {
  return driver_run_fmt(argc, argv);
}
