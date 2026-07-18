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

// std/backtrace/backtrace.x — F-backtrace v2：API 锚点（G-03 seed asm）
//
// 【文件职责】
// 版本标记与烟测 API 锚点；帧辅助/capture/symbolicate/烟测实现在 runtime_backtrace_platform.c。
//
// 【对标】Rust std::backtrace。

/** F-backtrace v1 版本标记。 */
export function backtrace_f_backtrace_v1_marker_c(): i32 {
  return 1;
}

/** F-backtrace v2 逻辑下沉标记。 */
export function backtrace_f_backtrace_v2_marker_c(): i32 {
  return 1;
}

// STD-052：backtrace_symbolicate_smoke_c 实现在 runtime_backtrace_platform.c（避免 .o 重复符号）。
