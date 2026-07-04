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

// std/http/http.x — F-http v1 模块锚点（HTTP/1.x/H2 在 http_glue.c + *.inc.c）
//
// 【文件职责】
// 提供 F-http v1 可编译 .x 单元；经 ld -r 与 http_glue.c 合并为 http.o。
// 对外 API 在 mod.x。

/** F-http v1 版本标记；供聚合 gate 校验 http.x 已参与 ld -r 合并。 */
function http_f_http_v1_marker_c(): i32 {
  return 1;
}
