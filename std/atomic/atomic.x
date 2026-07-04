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

// std/atomic/atomic.x — F-atomic v2 模块锚点（F-ZC 纯 .x；原子操作在 runtime_atomic_glue.c）
//
// 【文件职责】
// 提供 F-atomic v2 可编译 .x 单元；与 runtime_atomic_glue.o 一并链入 exe。
// 对外 API 在 mod.x。

/** F-atomic v1 版本标记；供聚合 gate 校验 atomic.x 已参与 ld -r 合并。 */
function atomic_f_atomic_v1_marker_c(): i32 {
  return 1;
}
