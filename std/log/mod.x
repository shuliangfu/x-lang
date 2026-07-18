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

// std.log — 日志级别与 stderr/文件输出（对标 Zig std.log、Rust log，零分配）
// STD-053：多 sink（SINK_STDERR | SINK_FILE）+ 级别过滤 + 结构化 KV（OBS-003）。
// STD-106：文件轮转 set_rotate_limit + 异步缓冲 set_async_enabled / async_flush。
//
// 【文件职责】set_min_level、log、structured_kv；输出到 stderr 和/或文件。
// 【依赖】core；与 std/log/log.x 同属一模块（F-log v1 / F-ZC）；OS 胶层在 runtime_log_os.o。
extern function log_set_min_level_c(level: i32): void;
extern function log_write_c(level: i32, ptr: *u8, len: i32): i32;
extern function log_set_sink_mask_c(mask: i32): void;
extern function log_set_file_sink_c(path: *u8, len: i32): i32;
extern function log_close_file_sink_c(): void;
extern function log_write_structured_kv_c(comp: *u8, level: i32, kv: *u8): i32;
extern function log_set_rotate_c(max_bytes: i32, max_backups: i32): i32;
extern function log_set_async_enabled_c(enabled: i32): i32;
extern function log_async_flush_c(): i32;

/** stderr sink 掩码位。 */
export const SINK_STDERR: i32 = 1;
/** 文件 sink 掩码位。 */
export const SINK_FILE: i32 = 2;

export function level_debug(): i32 { return 0; }
export function level_info(): i32 { return 1; }
export function level_warn(): i32 { return 2; }
export function level_error(): i32 { return 3; }

/** 设置最小输出级别；低于此级别的 log 不写。0=DEBUG, 1=INFO, 2=WARN, 3=ERROR。 */
export function set_min_level(level: i32): void { unsafe { log_set_min_level_c(level); } }

/** 设置活跃 sink 掩码：SINK_STDERR | SINK_FILE。 */
export function set_sink_mask(mask: i32): void { unsafe { log_set_sink_mask_c(mask); } }

/** 打开追加写文件 sink；path 为字节路径，len 为长度。成功 0，失败 -1。 */
export function set_file_sink(path: *u8, len: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_set_file_sink_c(path, len); }
  return rc;
}

/** 关闭文件 sink（若已打开）。 */
export function close_file_sink(): void { unsafe { log_close_file_sink_c(); } }

/** 写一条人类可读日志："[LEVEL] " + ptr[0..len] + 换行。返回 0 成功，-1 失败。 */
export function log(level: i32, ptr: *u8, len: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_write_c(level, ptr, len); }
  return rc;
}

/** 写一条 OBS-003 结构化行：shux: level=… component=… kv…；comp/kv 为 NUL 结尾字节串。 */
export function structured_kv(comp: *u8, level: i32, kv: *u8): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_write_structured_kv_c(comp, level, kv); }
  return rc;
}

/** 设置文件 sink 轮转阈值（须先 set_file_sink）；max_backups 0=截断，1..8=备份。 */
export function set_rotate_limit(max_bytes: i32, max_backups: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_set_rotate_c(max_bytes, max_backups); }
  return rc;
}

/** 启用/关闭异步缓冲（32 槽环形队列）；关闭前自动 flush。 */
export function set_async_enabled(enabled: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_set_async_enabled_c(enabled); }
  return rc;
}

/** 刷出异步缓冲到活跃 sink。 */
export function async_flush(): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_async_flush_c(); }
  return rc;
}
