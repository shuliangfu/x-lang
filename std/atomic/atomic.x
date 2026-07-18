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

// std/atomic/atomic.x — F-atomic v2 模块锚点（F-ZC 纯 .x；原子操作在 runtime_atomic_glue.c）
//
// 【文件职责】
// 提供 F-atomic v2 可编译 .x 单元；与 runtime_atomic_glue.o 一并链入 exe。
// 对外 API 在 mod.x。

/** F-atomic v1 版本标记；供聚合 gate 校验 atomic.x 已参与 ld -r 合并。 */
export function atomic_f_atomic_v1_marker_c(): i32 {
  return 1;
}
