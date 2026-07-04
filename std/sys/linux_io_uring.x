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

// std.sys.linux_io_uring — B-15 v1：io_uring 门面探测（完整实现在 std/io/io.c + io_uring.c）
//
// 【文件职责】
// 为阶段 B 提供 std.sys 层 io_uring 可用性探测；不重复实现 ring 逻辑。

/** C 侧探测：liburing 链入且 io_uring 可用时返回 1。 */
extern function shux_io_uring_is_available_c(): i32;

/**
 * 返回 1 表示当前构建/宿主可安全尝试 io_uring 路径。
 */
function io_uring_available(): i32 {
  unsafe {
    return shux_io_uring_is_available_c();
  }
}
