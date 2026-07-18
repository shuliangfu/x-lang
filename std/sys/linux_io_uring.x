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

// std.sys.linux_io_uring — B-15 v1：io_uring 门面探测（完整实现在 std/io/io.c + io_uring.c）
//
// 【文件职责】
// 为阶段 B 提供 std.sys 层 io_uring 可用性探测；不重复实现 ring 逻辑。

/** C 侧探测：liburing 链入且 io_uring 可用时返回 1。 */
extern function shux_io_uring_is_available_c(): i32;

/**
 * 返回 1 表示当前构建/宿主可安全尝试 io_uring 路径。
 */
export function io_uring_available(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = shux_io_uring_is_available_c(); }
  return _rc;
}
