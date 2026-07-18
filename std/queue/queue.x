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

// std/queue/queue.x — F-queue v2：API 锚点（G-03 seed asm）
//
// 【文件职责】
// 版本标记；sync_queue_contention_smoke_c / queue_contention_worker_push_c 实现在
// runtime_queue_contention.c（pthread + 环形队列烟测）。
//
// 【对标】Rust VecDeque + std.sync::Mutex 竞争烟测。

/** F-queue v1 版本标记。 */
export function queue_f_queue_v1_marker_c(): i32 {
  return 1;
}

/** F-queue v2 烟测逻辑下沉标记。 */
export function queue_f_queue_v2_marker_c(): i32 {
  return 1;
}

// sync_queue_contention_smoke_c — 见 compiler/src/asm/runtime_queue_contention.c
// queue_contention_worker_push_c — 见 runtime_queue_contention.c
