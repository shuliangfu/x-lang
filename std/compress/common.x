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

// std/compress/common.x — F-std-zero-c：各格式共用流状态魔数与头布局（替代 compress_common.h）
//
// 【文件职责】
// gzip / brotli / zstd 流状态头魔数与 POD 布局；各格式 lib.x 可本地重复 const 或 import 本模块。
// 【所属模块】std.compress（F-04 v7 纯 .x；零 .c/.h）

/** gzip 流状态魔数（'GZST'）。 */
export const SHU_GZIP_STREAM_MAGIC: u32 = 0x475a5354;

/** brotli 流状态魔数（'BRST'）。 */
export const SHU_BROTLI_STREAM_MAGIC: u32 = 0x42525354;

/** zstd 流状态魔数（'ZSTR'）。 */
export const SHU_ZSTD_STREAM_MAGIC: u32 = 0x5a535452;

/** gzip 流状态头（后接 z_stream 或 stub 占位）；mode 0=compress 1=decompress。 */
allow(padding) struct CompressStreamHdr {
  magic: u32;
  mode: i32;
  ended: i32;
  inited: i32;
}

/** F-compress-common-zero-c 标记；供 zero-c track gate 校验。 */
export function compress_common_zero_c_marker_c(): i32 {
  return 1;
}
