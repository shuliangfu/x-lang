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

// std/log/log.x — 日志格式化层（F-log v1；替代 log.c 中非 OS 部分）
//
// 【文件职责】
// log_write_c / log_write_structured_kv_c：级别前缀与 OBS-003 行组装；
// 实际 sink 写入在 runtime_log_os.c（compiler runtime；log_emit_bytes_c）。

extern function log_apply_env_once_c(): void;
extern function log_get_min_level_c(): i32;
extern function log_emit_bytes_c(buf: *u8, len: i32): i32;

/** 异步槽最大行宽（与 runtime_log_os.c LOG_ASYNC_SLOT_SIZE 一致）。 */
const LOG_ASYNC_SLOT_SIZE: i32 = 512;

/** 级别前缀与名称字面量（模块级，避免 -E 局部数组/早 return _codegen 缺陷）。 */
let g_log_pfx_dbg: u8[8] = [91, 68, 69, 66, 85, 71, 93, 32];
let g_log_pfx_inf: u8[7] = [91, 73, 78, 70, 79, 93, 32];
let g_log_pfx_wrn: u8[7] = [91, 87, 65, 82, 78, 93, 32];
let g_log_pfx_err: u8[8] = [91, 69, 82, 82, 79, 82, 93, 32];
let g_log_name_dbg: u8[6] = [100, 101, 98, 117, 103, 0];
let g_log_name_inf: u8[5] = [105, 110, 102, 111, 0];
let g_log_name_wrn: u8[5] = [119, 97, 114, 110, 0];
let g_log_name_err: u8[6] = [101, 114, 114, 111, 114, 0];
let g_log_obs_pfx: u8[13] = [115, 104, 117, 120, 58, 32, 108, 101, 118, 101, 108, 61, 0];
let g_log_obs_mid: u8[12] = [32, 99, 111, 109, 112, 111, 110, 101, 110, 116, 61, 0];
let g_log_sp: u8[1] = [32];

/** 级别前缀字节长度。 */
function log_prefix_len(level: i32): i32 {
  if (level == 0) { return 8; }
  if (level == 1) { return 7; }
  if (level == 2) { return 7; }
  if (level == 3) { return 8; }
  return 7;
}

/** 将固定字节串复制到 out[0..n)；返回 n。 */
function log_copy_lit(out: *u8, lit: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    out[i] = lit[i];
    i = i + 1;
  }
  return n;
}

/** 将级别前缀写入 out；返回写入长度。 */
function log_prefix_copy(level: i32, out: *u8): i32 {
  if (level == 0) { return log_copy_lit(out, &g_log_pfx_dbg[0], 8); }
  if (level == 1) { return log_copy_lit(out, &g_log_pfx_inf[0], 7); }
  if (level == 2) { return log_copy_lit(out, &g_log_pfx_wrn[0], 7); }
  if (level == 3) { return log_copy_lit(out, &g_log_pfx_err[0], 8); }
  return log_copy_lit(out, &g_log_pfx_inf[0], 7);
}

/** 返回级别名 C 串指针（debug/info/warn/error）。 */
function log_level_name_ptr(level: i32): *u8 {
  if (level == 0) { return &g_log_name_dbg[0]; }
  if (level == 1) { return &g_log_name_inf[0]; }
  if (level == 2) { return &g_log_name_wrn[0]; }
  if (level == 3) { return &g_log_name_err[0]; }
  return &g_log_name_inf[0];
}

/** 计算 NUL 结尾 C 串长度（不用 libc strlen，避免 -E 与 string.h 冲突）。 */
function log_cstr_len(s: *u8): i32 {
  let i: i32 = 0;
  if (s == 0) { return 0; }
  while (s[i] != 0) {
    i = i + 1;
  }
  return i;
}

/** 追加 C 串到 out；返回新 offset，失败 -1。 */
function log_append_cstr(out: *u8, off: i32, cap: i32, s: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  if (s == 0) { return off; }
  n = log_cstr_len(s);
  if (off + n >= cap) { return -1; }
  while (i < n) {
    out[off + i] = s[i];
    i = i + 1;
  }
  return off + n;
}

/** 追加固定字面节串。 */
function log_append_lit(out: *u8, off: i32, cap: i32, lit: *u8, lit_len: i32): i32 {
  let i: i32 = 0;
  if (off + lit_len >= cap) { return -1; }
  while (i < lit_len) {
    out[off + i] = lit[i];
    i = i + 1;
  }
  return off + lit_len;
}

/** 写一条人类可读日志："[LEVEL] " + ptr[0..len] + 换行。 */
function log_write_c(level: i32, ptr: *u8, len: i32): i32 {
  let line: u8[512] = [];
  let pl: i32 = 0;
  let total: i32 = 0;
  let min_lvl: i32 = 0;
  let rc: i32 = 0;
  let i: i32 = 0;
  unsafe { log_apply_env_once_c(); }
  if (level < 0 || level > 3 || ptr == 0) { return -1; }
  unsafe { min_lvl = log_get_min_level_c(); }
  if (level < min_lvl) { return 0; }
  pl = log_prefix_copy(level, &line[0]);
  total = pl + len + 1;
  if (total >= LOG_ASYNC_SLOT_SIZE) { return -1; }
  i = 0;
  while (i < len) {
    line[pl + i] = ptr[i];
    i = i + 1;
  }
  line[pl + len] = 10;
  unsafe { rc = log_emit_bytes_c(&line[0], total); }
  return rc;
}

/** OBS-003 结构化行：shux: level=… component=… kv…。 */
function log_write_structured_kv_c(component: *u8, level: i32, kv_body: *u8): i32 {
  let line: u8[1024] = [];
  let n: i32 = 0;
  let min_lvl: i32 = 0;
  let rc: i32 = 0;
  unsafe { log_apply_env_once_c(); }
  if (component == 0 || kv_body == 0 || level < 0 || level > 3) { return -1; }
  unsafe { min_lvl = log_get_min_level_c(); }
  if (level < min_lvl) { return 0; }
  n = log_append_lit(&line[0], 0, 1024, &g_log_obs_pfx[0], 12);
  if (n < 0) { return -1; }
  n = log_append_cstr(&line[0], n, 1024, log_level_name_ptr(level));
  if (n < 0) { return -1; }
  n = log_append_lit(&line[0], n, 1024, &g_log_obs_mid[0], 11);
  if (n < 0) { return -1; }
  n = log_append_cstr(&line[0], n, 1024, component);
  if (n < 0) { return -1; }
  n = log_append_lit(&line[0], n, 1024, &g_log_sp[0], 1);
  if (n < 0) { return -1; }
  n = log_append_cstr(&line[0], n, 1024, kv_body);
  if (n < 0) { return -1; }
  if (n + 1 >= 1024) { return -1; }
  line[n] = 10;
  n = n + 1;
  unsafe { rc = log_emit_bytes_c(&line[0], n); }
  return rc;
}
