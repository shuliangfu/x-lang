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

// std/backtrace/backtrace.x — F-backtrace v2：API 锚点（G-03 seed asm）
//
// 【文件职责】
// 版本标记与烟测 API 锚点；帧辅助/capture/symbolicate/烟测实现在 runtime_backtrace_platform.c。
//
// 【对标】Rust std::backtrace。

/** F-backtrace v1 版本标记。 */
function backtrace_f_backtrace_v1_marker_c(): i32 {
  return 1;
}

/** F-backtrace v2 逻辑下沉标记。 */
function backtrace_f_backtrace_v2_marker_c(): i32 {
  return 1;
}

// STD-052：backtrace_symbolicate_smoke_c 实现在 runtime_backtrace_platform.c（避免 .o 重复符号）。
