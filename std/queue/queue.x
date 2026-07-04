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

// std/queue/queue.x — F-queue v2：API 锚点（G-03 seed asm）
//
// 【文件职责】
// 版本标记；sync_queue_contention_smoke_c / queue_contention_worker_push_c 实现在
// runtime_queue_contention.c（pthread + 环形队列烟测）。
//
// 【对标】Rust VecDeque + std.sync::Mutex 竞争烟测。

/** F-queue v1 版本标记。 */
function queue_f_queue_v1_marker_c(): i32 {
  return 1;
}

/** F-queue v2 烟测逻辑下沉标记。 */
function queue_f_queue_v2_marker_c(): i32 {
  return 1;
}

// sync_queue_contention_smoke_c — 见 compiler/src/asm/runtime_queue_contention.c
// queue_contention_worker_push_c — 见 runtime_queue_contention.c
