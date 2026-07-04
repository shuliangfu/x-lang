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

// std/env/env.x — 环境变量逻辑层（F-env v1；替代 env.c 中非 OS 部分）
//
// 【文件职责】
// args_iter 委托 process；KV 解析向量；platform_encoding 烟测。
// OS getenv/setenv/iter 在 runtime_env_os.c（compiler runtime）。

/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const ENV_LIT_KEY: u8[4] = [75, 69, 89, 0];
const ENV_LIT_K: u8[2] = [75, 0];
const ENV_LIT_V_EQ_W: u8[4] = [86, 61, 87, 0];
const ENV_LIT_NOEQ: u8[5] = [78, 79, 69, 81, 0];
const ENV_LIT_EMPTY: u8[1] = [0];

extern function strchr(s: *u8, c: i32): *u8;
extern function strlen(s: *u8): usize;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;

extern function process_args_count_c(): i32;
extern function process_arg_c(i: i32): *u8;

extern function env_getenv_c(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32;
extern function env_setenv_c(name: *u8, value: *u8, overwrite: i32): i32;
extern function env_unsetenv_c(name: *u8): i32;

/** args_iter 计数：委托 process argc。 */
function args_iter_count_c(): i32 {
  unsafe { return process_args_count_c(); }
}

/** args_iter 取第 i 个 argv 指针（NUL 结尾）；越界返回 NULL。 */
function args_iter_at_c(i: i32): *u8 {
  unsafe { return process_arg_c(i); }
}

/** C 串相等比较；1 相等。 */
function env_cstr_eq(a: *u8, b: *u8): i32 {
  let i: i32 = 0;
  if (a == 0 || b == 0) { return 0; }
  while (a[i] != 0 && a[i] == b[i]) {
    i = i + 1;
  }
  if (a[i] != b[i]) { return 0; }
  return 1;
}

/**
 * 解析 environ 风格条目 entry（NUL 结尾）为 key/value 写入 out 缓冲。
 * 无 '=' 时 value 为空串；仅首 '=' 分割。成功 0，cap 不足 -1。
 */
function env_parse_kv_entry(entry: *u8, key_out: *u8, key_cap: i32,
                          val_out: *u8, val_cap: i32): i32 {
  let eq: *u8 = 0;
  let key_len: i32 = 0;
  let val_len: i32 = 0;
  if (entry == 0 || key_out == 0 || val_out == 0 || key_cap <= 0 || val_cap <= 0) {
    return -1;
  }
  unsafe { eq = strchr(entry, 61); }
  if (eq != 0) {
    key_len = (eq - entry) as i32;
    unsafe { val_len = strlen(eq + 1) as i32; }
  } else {
    unsafe { key_len = strlen(entry) as i32; }
    val_len = 0;
  }
  if (key_len + 1 > key_cap || val_len + 1 > val_cap) {
    return -1;
  }
  unsafe { memcpy(key_out, entry, key_len); }
  key_out[key_len] = 0;
  if (val_len > 0) {
    unsafe { memcpy(val_out, eq + 1, val_len); }
  }
  val_out[val_len] = 0;
  return 0;
}

/**
 * STD-132 C 金样：KV 解析 + setenv/getenv 空 value / value 含 '=' 往返。
 * 成功 0，失败非 0。
 */
function env_platform_encoding_smoke_c(): i32 {
  let key: u8[64];
  let val: u8[64];
  let out: u8[32];
  let gl: i32 = 0;
  let test_empty: u8[19] = [83, 72, 85, 88, 95, 69, 78, 86, 95, 80, 69, 95, 69, 77, 80, 84, 89, 0, 0];
  let test_eq: u8[15] = [83, 72, 85, 88, 95, 69, 78, 86, 95, 80, 69, 95, 69, 81, 0];
  let kv1: u8[5] = [75, 69, 89, 61, 0];
  let kv2: u8[6] = [75, 61, 86, 61, 87, 0];
  let kv3: u8[5] = [78, 79, 69, 81, 0];
  let kv4: u8[6] = [65, 66, 61, 67, 68, 0];
  let ab_val: u8[3] = [97, 61, 98];

  if (env_parse_kv_entry(&kv1[0], &key[0], 64, &val[0], 64) != 0) { return 1; }
  if (env_cstr_eq(&key[0], &ENV_LIT_KEY[0]) == 0) { return 2; }
  if (val[0] != 0) { return 3; }

  if (env_parse_kv_entry(&kv2[0], &key[0], 64, &val[0], 64) != 0) { return 4; }
  if (env_cstr_eq(&key[0], &ENV_LIT_K[0]) == 0) { return 5; }
  if (env_cstr_eq(&val[0], &ENV_LIT_V_EQ_W[0]) == 0) { return 6; }

  if (env_parse_kv_entry(&kv3[0], &key[0], 64, &val[0], 64) != 0) { return 7; }
  if (env_cstr_eq(&key[0], &ENV_LIT_NOEQ[0]) == 0) { return 8; }
  if (val[0] != 0) { return 9; }

  if (env_parse_kv_entry(&kv4[0], &key[0], 2, &val[0], 64) != -1) { return 10; }

  unsafe { env_unsetenv_c(&test_empty[0]); }
  unsafe { if (env_setenv_c(&test_empty[0], &ENV_LIT_EMPTY[0], 1) != 0) { return 11; } }
  unsafe { gl = env_getenv_c(&test_empty[0], 18, &out[0], 32); }
  if (gl != 0) { return 12; }

  unsafe { env_unsetenv_c(&test_eq[0]); }
  unsafe { if (env_setenv_c(&test_eq[0], &ab_val[0], 1) != 0) { return 13; } }
  unsafe { gl = env_getenv_c(&test_eq[0], 14, &out[0], 32); }
  if (gl != 3) { return 14; }
  if (out[0] != 97 || out[1] != 61 || out[2] != 98) { return 15; }

  unsafe { env_unsetenv_c(&test_empty[0]); }
  unsafe { env_unsetenv_c(&test_eq[0]); }
  return 0;
}
