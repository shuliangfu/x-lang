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

// std/schema/schema.x — F-schema v2：JSON/CSV typed decode（纯 .x；替代 schema_glue.c）
//
// 【文件职责】
// Schema 字段注册；JSON 对象/array 递归 decode（点分/索引键）；CSV 行与列映射；
// 字段级错误路径；C 烟测 schema_smoke_c。依赖 extern json_* 与 csv parse_row。
//
// 【对标】Rust serde + validator、Go mapstructure 最小子集。

const SCH_OK: i32 = 0;
const SCH_ERR_NULL: i32 = -1;
const SCH_ERR_NOT_FOUND: i32 = -2;
const SCH_ERR_TYPE: i32 = -3;
const SCH_ERR_INVALID: i32 = -4;
const SCH_ERR_FULL: i32 = -5;

const SCH_TYPE_STRING: i32 = 0;
const SCH_TYPE_I32: i32 = 1;
const SCH_TYPE_BOOL: i32 = 2;
const SCH_TYPE_F64: i32 = 3;

const SCH_MAX_FIELDS: i32 = 32;
const SCH_NAME_MAX: i32 = 64;
const SCH_VAL_MAX: i32 = 256;
const SCH_ERR_MSG_MAX: i32 = 128;
const SCH_SCHEMA_MEM_SIZE: usize = 12000;

/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const SCH_LIT_N0: u8[2] = [48, 0];
const SCH_LIT_N1: u8[2] = [49, 0];
const SCH_LIT_N2147483648: u8[11] = [50, 49, 52, 55, 52, 56, 51, 54, 52, 56, 0];
const SCH_LIT_CSV_PARSE_ERROR: u8[16] = [67, 83, 86, 32, 112, 97, 114, 115, 101, 32, 101, 114, 114, 111, 114, 0];
const SCH_LIT_JSON_ARRAY_PARSE_ERROR: u8[23] = [74, 83, 79, 78, 32, 97, 114, 114, 97, 121, 32, 112, 97, 114, 115, 101, 32, 101, 114, 114, 111, 114, 0];
const SCH_LIT_JSON_PARSE_ERROR: u8[17] = [74, 83, 79, 78, 32, 112, 97, 114, 115, 101, 32, 101, 114, 114, 111, 114, 0];
const SCH_LIT_JSON_VALUE_SKIP_FAILED: u8[23] = [74, 83, 79, 78, 32, 118, 97, 108, 117, 101, 32, 115, 107, 105, 112, 32, 102, 97, 105, 108, 101, 100, 0];
const SCH_LIT_ACTIVE: u8[7] = [97, 99, 116, 105, 118, 101, 0];
const SCH_LIT_AGE: u8[4] = [97, 103, 101, 0];
const SCH_LIT_ALICE: u8[6] = [97, 108, 105, 99, 101, 0];
const SCH_LIT_ARRAY_KEY_TOO_LONG: u8[19] = [97, 114, 114, 97, 121, 32, 107, 101, 121, 32, 116, 111, 111, 32, 108, 111, 110, 103, 0];
const SCH_LIT_BOB: u8[4] = [98, 111, 98, 0];
const SCH_LIT_BOB_25_FALSE: u8[14] = [98, 111, 98, 44, 50, 53, 44, 102, 97, 108, 115, 101, 10, 0];
const SCH_LIT_CAROL: u8[6] = [99, 97, 114, 111, 108, 0];
const SCH_LIT_EXPECTED_JSON_OBJECT: u8[21] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 74, 83, 79, 78, 32, 111, 98, 106, 101, 99, 116, 0];
const SCH_LIT_EXPECTED_ARRAY: u8[15] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 97, 114, 114, 97, 121, 0];
const SCH_LIT_EXPECTED_BOOL: u8[14] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 98, 111, 111, 108, 0];
const SCH_LIT_EXPECTED_F64: u8[13] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 102, 54, 52, 0];
const SCH_LIT_EXPECTED_I32: u8[13] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 105, 51, 50, 0];
const SCH_LIT_EXPECTED_NUMBER: u8[16] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 110, 117, 109, 98, 101, 114, 0];
const SCH_LIT_EXPECTED_OBJECT: u8[16] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 111, 98, 106, 101, 99, 116, 0];
const SCH_LIT_EXPECTED_STRING: u8[16] = [101, 120, 112, 101, 99, 116, 101, 100, 32, 115, 116, 114, 105, 110, 103, 0];
const SCH_LIT_FALSE: u8[6] = [102, 97, 108, 115, 101, 0];
const SCH_LIT_ITEMS_0: u8[8] = [105, 116, 101, 109, 115, 46, 48, 0];
const SCH_LIT_ITEMS_1: u8[8] = [105, 116, 101, 109, 115, 46, 49, 0];
const SCH_LIT_KEY_TOO_LONG: u8[13] = [107, 101, 121, 32, 116, 111, 111, 32, 108, 111, 110, 103, 0];
const SCH_LIT_MISSING_CSV_COLUMN: u8[19] = [109, 105, 115, 115, 105, 110, 103, 32, 67, 83, 86, 32, 99, 111, 108, 117, 109, 110, 0];
const SCH_LIT_MISSING_COLUMN: u8[15] = [109, 105, 115, 115, 105, 110, 103, 32, 99, 111, 108, 117, 109, 110, 0];
const SCH_LIT_MISSING_REQUIRED_FIELD: u8[23] = [109, 105, 115, 115, 105, 110, 103, 32, 114, 101, 113, 117, 105, 114, 101, 100, 32, 102, 105, 101, 108, 100, 0];
const SCH_LIT_NAME: u8[5] = [110, 97, 109, 101, 0];
const SCH_LIT_NO: u8[3] = [110, 111, 0];
const SCH_LIT_TRUE: u8[5] = [116, 114, 117, 101, 0];
const SCH_LIT_UNKNOWN_TYPE: u8[13] = [117, 110, 107, 110, 111, 119, 110, 32, 116, 121, 112, 101, 0];
const SCH_LIT_USER_AGE: u8[9] = [117, 115, 101, 114, 46, 97, 103, 101, 0];
const SCH_LIT_USER_NAME: u8[10] = [117, 115, 101, 114, 46, 110, 97, 109, 101, 0];
const SCH_LIT_USERS_0_NAME: u8[13] = [117, 115, 101, 114, 115, 46, 48, 46, 110, 97, 109, 101, 0];
const SCH_LIT_USERS_1_NAME: u8[13] = [117, 115, 101, 114, 115, 46, 49, 46, 110, 97, 109, 101, 0];
const SCH_LIT_YES: u8[4] = [121, 101, 115, 0];
const SCH_LIT_ITEMS_10_20: u8[18] = [123, 34, 105, 116, 101, 109, 115, 34, 58, 91, 49, 48, 44, 50, 48, 93, 125, 0];
const SCH_LIT_NAME_ALICE_AGE_30_ACTIVE_TRUE: u8[40] = [123, 34, 110, 97, 109, 101, 34, 58, 34, 97, 108, 105, 99, 101, 34, 44, 34, 97, 103, 101, 34, 58, 51, 48, 44, 34, 97, 99, 116, 105, 118, 101, 34, 58, 116, 114, 117, 101, 125, 0];
const SCH_LIT_NAME_X: u8[13] = [123, 34, 110, 97, 109, 101, 34, 58, 34, 120, 34, 125, 0];
const SCH_LIT_USER_NAME_CAROL_AGE_42: u8[35] = [123, 34, 117, 115, 101, 114, 34, 58, 123, 34, 110, 97, 109, 101, 34, 58, 34, 99, 97, 114, 111, 108, 34, 44, 34, 97, 103, 101, 34, 58, 52, 50, 125, 125, 0];
const SCH_LIT_USERS_NAME_ALICE_NAME_BOB: u8[44] = [123, 34, 117, 115, 101, 114, 115, 34, 58, 91, 123, 34, 110, 97, 109, 101, 34, 58, 34, 97, 108, 105, 99, 101, 34, 125, 44, 123, 34, 110, 97, 109, 101, 34, 58, 34, 98, 111, 98, 34, 125, 93, 125, 0];

/** JSON 游标布局（与 json.c json_cursor_t 一致）。 */
struct JsonCursor {
  ptr: *u8;
  len: i32;
  off: i32;
}

/** 单字段 decode 结果。 */
allow(padding) struct SchVal {
  present: i32;
  type: i32;
  str: u8[256];
  i32_v: i32;
  bool_v: i32;
  f64_v: f64;
}

/** Schema 字段定义。 */
allow(padding) struct SchFieldDef {
  name: u8[64];
  type: i32;
  optional: i32;
  col_index: i32;
}

/** Schema 存储：定义 + decode 值 + 错误路径。 */
allow(padding) struct SchSchema {
  fields: SchFieldDef[32];
  values: SchVal[32];
  field_count: i32;
  error_field: u8[64];
  error_msg: u8[128];
}

extern function json_cursor_init_c(cur: *JsonCursor, ptr: *u8, len: i32): void;
extern function json_cursor_enter_object_c(cur: *JsonCursor): i32;
extern function json_cursor_object_next_c(cur: *JsonCursor, key_buf: *u8, key_cap: i32,
  key_len: *i32): i32;
extern function json_cursor_skip_value_c(cur: *JsonCursor): i32;
extern function json_cursor_enter_array_c(cur: *JsonCursor): i32;
extern function json_cursor_array_has_elem_c(cur: *JsonCursor): i32;
extern function json_cursor_value_type_c(cur: *JsonCursor): i32;
extern function json_parse_string_c(ptr: *u8, len: i32, out: *u8, out_cap: i32,
  consumed: *i32): i32;
extern function json_parse_number_c(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32;
extern function json_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32;
extern function json_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32;

extern function parse_row(ptr: *u8, len: i32, offset: i32, field_starts: *i32,
  field_lens: *i32, max_fields: i32, out_count: *i32): i32;

extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memset(s: *u8, c: i32, n: usize): *u8;
extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;
extern function strcmp(a: *u8, b: *u8): i32;
extern function strlen(s: *u8): usize;

/** F-schema v1 版本标记；供聚合 gate 校验 schema.x 已参与构建。 */
function schema_f_schema_v1_marker_c(): i32 {
  return 1;
}

/** F-schema v2 逻辑全量 .x 标记。 */
function schema_f_schema_v2_marker_c(): i32 {
  return 1;
}

/** 由 i64 句柄取 Schema 指针；非法返回 NULL。 */
function sch_from_handle(handle: i64): *SchSchema {
  if (handle == 0) { return 0; }
  return handle as *SchSchema;
}

/** 受限拷贝 C 串到 dst；最多 cap-1 字节并 NUL 结尾。 */
function sch_strncpy(dst: *u8, src: *u8, cap: i32): void {
  let n: i32 = 0;
  if (dst == 0 || src == 0 || cap <= 0) { return; }
  while (src[n] != 0 && n < cap - 1) {
    dst[n] = src[n];
    n = n + 1;
  }
  dst[n] = 0;
}

/** 从定长字节缓冲拷贝 name_len 字节并 NUL 结尾。 */
function sch_copy_bytes_n(dst: *u8, src: *u8, name_len: i32, cap: i32): void {
  let n: i32 = name_len;
  if (dst == 0 || src == 0 || cap <= 0) { return; }
  if (n >= cap) { n = cap - 1; }
  unsafe { memcpy(dst, src, n); }
  dst[n] = 0;
}

/** 设置字段级错误信息。 */
function sch_set_error(sch: *SchSchema, field: *u8, msg: *u8): void {
  if (sch == 0) { return; }
  if (field != 0 && field[0] != 0) {
    sch_strncpy(&sch.error_field[0], field, SCH_NAME_MAX);
  } else {
    sch.error_field[0] = 0;
  }
  if (msg != 0 && msg[0] != 0) {
    sch_strncpy(&sch.error_msg[0], msg, SCH_ERR_MSG_MAX);
  } else {
    sch.error_msg[0] = 0;
  }
}

/** 清空 decode 结果与错误状态。 */
function sch_clear_values(sch: *SchSchema): void {
  let i: i32 = 0;
  if (sch == 0) { return; }
  while (i < sch.field_count) {
    sch.values[i].present = 0;
    sch.values[i].type = sch.fields[i].type;
    sch.values[i].str[0] = 0;
    sch.values[i].i32_v = 0;
    sch.values[i].bool_v = 0;
    sch.values[i].f64_v = 0.0;
    i = i + 1;
  }
  sch.error_field[0] = 0;
  sch.error_msg[0] = 0;
}

/** 按名称查找字段索引；不存在返回 -1。 */
function sch_find_field(sch: *SchSchema, name: *u8): i32 {
  let i: i32 = 0;
  if (sch == 0 || name == 0) { return -1; }
  while (i < sch.field_count) {
    if (unsafe { strcmp(&sch.fields[i].name[0], name) } == 0) { return i; }
    i = i + 1;
  }
  return -1;
}

/** 手动解析十进制 i32；成功 0，失败 -1。 */
function sch_parse_i32_text(text: *u8, out: *i32): i32 {
  let i: i32 = 0;
  let sign: i32 = 1;
  let val: i64 = 0;
  let c: i32 = 0;
  if (text == 0 || out == 0) { return -1; }
  if (text[0] == 45) { sign = -1; i = 1; }
  else if (text[0] == 43) { i = 1; }
  if (text[i] == 0) { return -1; }
  if (sign < 0 && text[i] == 0) { return -1; }
  /* INT_MIN 特判 */
  if (sign < 0 && text[i] == 50) {
    let min_str: *u8 = &SCH_LIT_N2147483648[0];
    let j: i32 = 0;
    while (min_str[j] != 0 && text[i + j] == min_str[j]) { j = j + 1; }
    if (min_str[j] == 0 && text[i + j] == 0) {
      out[0] = -2147483648;
      return 0;
    }
  }
  while (text[i] != 0) {
    c = text[i] as i32;
    if (c < 48 || c > 57) { return -1; }
    val = val * 10 + (c - 48);
    i = i + 1;
  }
  if (sign < 0) { val = -val; }
  out[0] = val as i32;
  return 0;
}

/** 手动解析 f64（整数/小数/可选 e 指数）；成功 0，失败 -1。 */
function sch_parse_f64_text(text: *u8, out: *f64): i32 {
  let i: i32 = 0;
  let sign: f64 = 1.0;
  let int_part: f64 = 0.0;
  let frac_part: f64 = 0.0;
  let frac_div: f64 = 1.0;
  let exp_sign: f64 = 1.0;
  let exp_val: i32 = 0;
  let c: i32 = 0;
  let result: f64 = 0.0;
  let k: i32 = 0;
  if (text == 0 || out == 0 || text[0] == 0) { return -1; }
  if (text[0] == 45) { sign = -1.0; i = 1; }
  else if (text[0] == 43) { i = 1; }
  if (text[i] == 0) { return -1; }
  while (text[i] != 0) {
    c = text[i] as i32;
    if (c < 48 || c > 57) { break; }
    int_part = int_part * 10.0 + (c - 48) as f64;
    i = i + 1;
  }
  if (text[i] == 46) {
    i = i + 1;
    while (text[i] != 0) {
      c = text[i] as i32;
      if (c < 48 || c > 57) { break; }
      frac_div = frac_div * 10.0;
      frac_part = frac_part * 10.0 + (c - 48) as f64;
      i = i + 1;
    }
  }
  result = sign * (int_part + frac_part / frac_div);
  if (text[i] == 101 || text[i] == 69) {
    i = i + 1;
    if (text[i] == 45) { exp_sign = -1.0; i = i + 1; }
    else if (text[i] == 43) { i = i + 1; }
    if (text[i] == 0) { return -1; }
    exp_val = 0;
    while (text[i] != 0) {
      c = text[i] as i32;
      if (c < 48 || c > 57) { return -1; }
      exp_val = exp_val * 10 + (c - 48);
      i = i + 1;
    }
    if (exp_sign < 0.0) { exp_val = -exp_val; }
    if (exp_val > 0) {
      k = 0;
      while (k < exp_val) { result = result * 10.0; k = k + 1; }
    } else if (exp_val < 0) {
      k = 0;
      while (k > exp_val) { result = result / 10.0; k = k - 1; }
    }
  }
  if (text[i] != 0) { return -1; }
  out[0] = result;
  return 0;
}

/** 将文本解析为字段类型并写入 values[idx]。 */
function sch_parse_text(sch: *SchSchema, idx: i32, text: *u8): i32 {
  let fd: *SchFieldDef = 0;
  let v: *SchVal = 0;
  let fd_type: i32 = 0;
  if (sch == 0 || idx < 0 || idx >= sch.field_count || text == 0) { return SCH_ERR_NULL; }
  fd = &sch.fields[idx];
  v = &sch.values[idx];
  fd_type = fd.type;
  v.present = 1;
  v.type = fd_type;
  if (fd_type == SCH_TYPE_STRING) {
    sch_strncpy(&v.str[0], text, SCH_VAL_MAX);
    return SCH_OK;
  }
  if (fd_type == SCH_TYPE_I32) {
    if (sch_parse_i32_text(text, &v.i32_v) != 0) {
      sch_set_error(sch, &fd.name[0], &SCH_LIT_EXPECTED_I32[0]);
      return SCH_ERR_TYPE;
    }
    return SCH_OK;
  }
  if (fd_type == SCH_TYPE_BOOL) {
    if (unsafe { strcmp(text, &SCH_LIT_TRUE[0]) } == 0 || unsafe { strcmp(text, &SCH_LIT_N1[0]) } == 0 ||
        unsafe { strcmp(text, &SCH_LIT_YES[0]) } == 0) {
      v.bool_v = 1;
      return SCH_OK;
    }
    if (unsafe { strcmp(text, &SCH_LIT_FALSE[0]) } == 0 || unsafe { strcmp(text, &SCH_LIT_N0[0]) } == 0 ||
        unsafe { strcmp(text, &SCH_LIT_NO[0]) } == 0) {
      v.bool_v = 0;
      return SCH_OK;
    }
    sch_set_error(sch, &fd.name[0], &SCH_LIT_EXPECTED_BOOL[0]);
    return SCH_ERR_TYPE;
  }
  if (fd_type == SCH_TYPE_F64) {
    if (sch_parse_f64_text(text, &v.f64_v) != 0) {
      sch_set_error(sch, &fd.name[0], &SCH_LIT_EXPECTED_F64[0]);
      return SCH_ERR_TYPE;
    }
    return SCH_OK;
  }
  sch_set_error(sch, &fd.name[0], &SCH_LIT_UNKNOWN_TYPE[0]);
  return SCH_ERR_INVALID;
}

/** 校验所有必填字段已 present。 */
function sch_check_required(sch: *SchSchema): i32 {
  let i: i32 = 0;
  if (sch == 0) { return SCH_ERR_NULL; }
  while (i < sch.field_count) {
    if (sch.fields[i].optional == 0 && sch.values[i].present == 0) {
      sch_set_error(sch, &sch.fields[i].name[0], &SCH_LIT_MISSING_REQUIRED_FIELD[0]);
      return SCH_ERR_NOT_FOUND;
    }
    i = i + 1;
  }
  return SCH_OK;
}

/** 拼接 prefix.local 为点分键名；prefix 为空时仅复制 local。 */
function sch_build_dotted_key(out: *u8, out_cap: i32, prefix: *u8, local: *u8): i32 {
  let pl: i32 = 0;
  let ll: i32 = 0;
  if (out == 0 || out_cap <= 0 || local == 0) { return SCH_ERR_NULL; }
  if (prefix != 0 && prefix[0] != 0) { unsafe { pl = strlen(prefix) as i32; } }
  unsafe { ll = strlen(local) as i32; }
  if (pl == 0) {
    if (ll + 1 > out_cap) { return SCH_ERR_INVALID; }
    unsafe { memcpy(out, local, (ll + 1)); }
    return SCH_OK;
  }
  if (pl + 1 + ll + 1 > out_cap) { return SCH_ERR_INVALID; }
  unsafe { memcpy(out, prefix, pl); }
  out[pl] = 46;
  unsafe { memcpy(out + (pl + 1), local, ll); }
  out[pl + 1 + ll] = 0;
  return SCH_OK;
}

/** 手动 i32 转十进制串；返回长度（不含 NUL），失败 -1。 */
function sch_i32_to_str(buf: *u8, cap: i32, val: i32): i32 {
  let tmp: u8[16];
  let i: i32 = 0;
  let j: i32 = 0;
  let n: i32 = 0;
  let v: i32 = val;
  let neg: i32 = 0;
  if (buf == 0 || cap <= 0) { return -1; }
  if (v == 0) {
    if (cap < 2) { return -1; }
    buf[0] = 48;
    buf[1] = 0;
    return 1;
  }
  if (v < 0) {
    neg = 1;
    if (v == -2147483648) {
      let min_s: *u8 = &SCH_LIT_N2147483648[0];
      if (cap < 12) { return -1; }
      if (neg != 0) { buf[0] = 45; j = 1; }
      sch_strncpy(buf + j, min_s, cap - j);
      unsafe { return (strlen(buf) as i32); }
    }
    v = -v;
  }
  while (v > 0 && i < 15) {
    tmp[i] = (48 + (v % 10)) as u8;
    i = i + 1;
    v = v / 10;
  }
  n = i + neg;
  if (n + 1 > cap) { return -1; }
  if (neg != 0) { buf[0] = 45; j = 1; }
  while (i > 0) {
    i = i - 1;
    buf[j] = tmp[i];
    j = j + 1;
  }
  buf[j] = 0;
  return j;
}

/** 拼接 prefix.index 为数组元素键名（如 tags.0）。 */
function sch_build_index_key(out: *u8, out_cap: i32, prefix: *u8, index: i32): i32 {
  let idx_buf: u8[16];
  let pl: i32 = 0;
  let n: i32 = 0;
  if (out == 0 || out_cap <= 0 || prefix == 0) { return SCH_ERR_NULL; }
  n = sch_i32_to_str(&idx_buf[0], 16, index);
  if (n <= 0) { return SCH_ERR_INVALID; }
  unsafe { pl = strlen(prefix) as i32; }
  if (pl + 1 + n + 1 > out_cap) { return SCH_ERR_INVALID; }
  unsafe { memcpy(out, prefix, pl); }
  out[pl] = 46;
  unsafe { memcpy(out + (pl + 1), &idx_buf[0], n); }
  out[pl + 1 + n] = 0;
  return SCH_OK;
}

/** 在游标当前 value 处解码标量到已注册字段 full_key。 */
function sch_decode_json_scalar(sch: *SchSchema, cur: *JsonCursor, full_key: *u8): i32 {
  let idx: i32 = 0;
  let consumed: i32 = 0;
  let vp: *u8 = 0;
  let vlen: i32 = 0;
  let sl: i32 = 0;
  let dv: f64 = 0.0;
  let out_buf: u8[256];
  if (sch == 0 || cur == 0 || full_key == 0) { return SCH_ERR_NULL; }
  idx = sch_find_field(sch, full_key);
  if (idx < 0) {
    if (unsafe { json_cursor_skip_value_c(cur) } != 0) { return SCH_ERR_INVALID; }
    return SCH_OK;
  }
  vp = cur.ptr + cur.off;
  vlen = cur.len - cur.off;
  if (sch.fields[idx].type == SCH_TYPE_STRING) {
    unsafe { sl = json_parse_string_c(vp, vlen, &out_buf[0], SCH_VAL_MAX, &consumed); }
    if (sl < 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_EXPECTED_STRING[0]);
      return SCH_ERR_TYPE;
    }
    out_buf[sl] = 0;
    sch.values[idx].present = 1;
    sch_strncpy(&sch.values[idx].str[0], &out_buf[0], SCH_VAL_MAX);
    if (unsafe { json_cursor_skip_value_c(cur) } != 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_JSON_VALUE_SKIP_FAILED[0]);
      return SCH_ERR_INVALID;
    }
    return SCH_OK;
  }
  if (sch.fields[idx].type == SCH_TYPE_I32) {
    if (unsafe { json_parse_number_c(vp, vlen, &dv, &consumed) } != 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_EXPECTED_NUMBER[0]);
      return SCH_ERR_TYPE;
    }
    sch.values[idx].present = 1;
    sch.values[idx].i32_v = dv as i32;
    if (unsafe { json_cursor_skip_value_c(cur) } != 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_JSON_VALUE_SKIP_FAILED[0]);
      return SCH_ERR_INVALID;
    }
    return SCH_OK;
  }
  if (sch.fields[idx].type == SCH_TYPE_F64) {
    if (unsafe { json_parse_number_c(vp, vlen, &sch.values[idx].f64_v, &consumed) } != 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_EXPECTED_NUMBER[0]);
      return SCH_ERR_TYPE;
    }
    sch.values[idx].present = 1;
    if (unsafe { json_cursor_skip_value_c(cur) } != 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_JSON_VALUE_SKIP_FAILED[0]);
      return SCH_ERR_INVALID;
    }
    return SCH_OK;
  }
  if (sch.fields[idx].type == SCH_TYPE_BOOL) {
    if (unsafe { json_parse_bool_c(vp, vlen, &sch.values[idx].bool_v, &consumed) } != 1) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_EXPECTED_BOOL[0]);
      return SCH_ERR_TYPE;
    }
    sch.values[idx].present = 1;
    if (unsafe { json_cursor_skip_value_c(cur) } != 0) {
      sch_set_error(sch, &sch.fields[idx].name[0], &SCH_LIT_JSON_VALUE_SKIP_FAILED[0]);
      return SCH_ERR_INVALID;
    }
    return SCH_OK;
  }
  return SCH_ERR_INVALID;
}

/** 递归解码 JSON object（支持 nested object → 点分字段名）；与 array 互递归。 */
function sch_decode_json_object(sch: *SchSchema, cur: *JsonCursor, prefix: *u8): i32 {
  let key_buf: u8[64];
  let full_key: u8[64];
  let key_len: i32 = 0;
  let rc: i32 = 0;
  let vtype: i32 = 0;
  if (sch == 0 || cur == 0) { return SCH_ERR_NULL; }
  loop {
    unsafe { rc = json_cursor_object_next_c(cur, &key_buf[0], SCH_NAME_MAX, &key_len); }
    if (rc == 0) { break; }
    if (rc < 0) {
      sch_set_error(sch, 0, &SCH_LIT_JSON_PARSE_ERROR[0]);
      return SCH_ERR_INVALID;
    }
    key_buf[key_len] = 0;
    if (sch_build_dotted_key(&full_key[0], SCH_NAME_MAX, prefix, &key_buf[0]) != SCH_OK) {
      sch_set_error(sch, 0, &SCH_LIT_KEY_TOO_LONG[0]);
      return SCH_ERR_INVALID;
    }
    unsafe { vtype = json_cursor_value_type_c(cur); }
    if (vtype == 3) {
      if (unsafe { json_cursor_enter_object_c(cur) } != 0) {
        sch_set_error(sch, &full_key[0], &SCH_LIT_EXPECTED_OBJECT[0]);
        return SCH_ERR_INVALID;
      }
      rc = sch_decode_json_object(sch, cur, &full_key[0]);
      if (rc != SCH_OK) { return rc; }
    } else if (vtype == 4) {
      rc = sch_decode_json_array(sch, cur, &full_key[0]);
      if (rc != SCH_OK) { return rc; }
    } else {
      rc = sch_decode_json_scalar(sch, cur, &full_key[0]);
      if (rc != SCH_OK) { return rc; }
    }
  }
  return SCH_OK;
}

/** 递归解码 JSON array（元素键 prefix.0 / prefix.1 …）；与 object 互递归。 */
function sch_decode_json_array(sch: *SchSchema, cur: *JsonCursor, prefix: *u8): i32 {
  let idx: i32 = 0;
  let elem_key: u8[64];
  let has: i32 = 0;
  let vtype: i32 = 0;
  let rc: i32 = 0;
  if (sch == 0 || cur == 0 || prefix == 0) { return SCH_ERR_NULL; }
  if (unsafe { json_cursor_enter_array_c(cur) } != 0) {
    sch_set_error(sch, prefix, &SCH_LIT_EXPECTED_ARRAY[0]);
    return SCH_ERR_INVALID;
  }
  loop {
    unsafe { has = json_cursor_array_has_elem_c(cur); }
    if (has < 0) {
      sch_set_error(sch, prefix, &SCH_LIT_JSON_ARRAY_PARSE_ERROR[0]);
      return SCH_ERR_INVALID;
    }
    if (has == 0) { break; }
    if (sch_build_index_key(&elem_key[0], SCH_NAME_MAX, prefix, idx) != SCH_OK) {
      sch_set_error(sch, prefix, &SCH_LIT_ARRAY_KEY_TOO_LONG[0]);
      return SCH_ERR_INVALID;
    }
    unsafe { vtype = json_cursor_value_type_c(cur); }
    if (vtype == 3) {
      if (unsafe { json_cursor_enter_object_c(cur) } != 0) {
        sch_set_error(sch, &elem_key[0], &SCH_LIT_EXPECTED_OBJECT[0]);
        return SCH_ERR_INVALID;
      }
      rc = sch_decode_json_object(sch, cur, &elem_key[0]);
      if (rc != SCH_OK) { return rc; }
    } else if (vtype == 4) {
      rc = sch_decode_json_array(sch, cur, &elem_key[0]);
      if (rc != SCH_OK) { return rc; }
    } else {
      rc = sch_decode_json_scalar(sch, cur, &elem_key[0]);
      if (rc != SCH_OK) { return rc; }
    }
    idx = idx + 1;
  }
  return SCH_OK;
}

/** 创建空 Schema；失败返回 0。 */
function schema_create_c(): i64 {
  let sch: *SchSchema = 0;
  unsafe { sch = calloc(1, SCH_SCHEMA_MEM_SIZE) as *SchSchema; }
  if (sch == 0) { return 0; }
  return sch as i64;
}

/** 释放 Schema。 */
function schema_free_c(handle: i64): void {
  let sch: *SchSchema = sch_from_handle(handle);
  if (sch != 0) { unsafe { free(sch as *u8); } }
}

/** 清空字段定义与 decode 结果。 */
function schema_clear_c(handle: i64): void {
  let sch: *SchSchema = sch_from_handle(handle);
  if (sch == 0) { return; }
  sch.field_count = 0;
  sch_clear_values(sch);
}

/**
 * 注册字段：name 为 JSON 键名 / 逻辑名；col_index 用于 CSV/SQLite 列映射。
 * optional 非 0 表示可选；返回 SCH_OK 或错误码。
 */
function schema_add_field_c(handle: i64, name: *u8, name_len: i32, type: i32,
  optional: i32, col_index: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let key: u8[64];
  let fi: i32 = 0;
  if (sch == 0 || name == 0 || name_len <= 0) { return SCH_ERR_NULL; }
  if (name_len >= SCH_NAME_MAX) { return SCH_ERR_INVALID; }
  if (sch.field_count >= SCH_MAX_FIELDS) { return SCH_ERR_FULL; }
  sch_copy_bytes_n(&key[0], name, name_len, SCH_NAME_MAX);
  if (sch_find_field(sch, &key[0]) >= 0) { return SCH_ERR_INVALID; }
  fi = sch.field_count;
  sch_strncpy(&sch.fields[fi].name[0], &key[0], SCH_NAME_MAX);
  sch.fields[fi].type = type;
  sch.fields[fi].optional = optional != 0 ? 1 : 0;
  sch.fields[fi].col_index = col_index;
  sch.values[fi].type = type;
  sch.field_count = sch.field_count + 1;
  return SCH_OK;
}

/** 从 JSON 对象缓冲 decode；支持 flat + nested object 点分字段（如 user.name）。 */
function schema_decode_json_c(handle: i64, json: *u8, json_len: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let cur: JsonCursor;
  let rc: i32 = 0;
  let empty: u8[1];
  if (sch == 0 || json == 0 || json_len <= 0) { return SCH_ERR_NULL; }
  sch_clear_values(sch);
  unsafe { json_cursor_init_c(&cur, json, json_len); }
  if (unsafe { json_cursor_enter_object_c(&cur) } != 0) {
    sch_set_error(sch, 0, &SCH_LIT_EXPECTED_JSON_OBJECT[0]);
    return SCH_ERR_INVALID;
  }
  empty[0] = 0;
  rc = sch_decode_json_object(sch, &cur, &empty[0]);
  if (rc != SCH_OK) { return rc; }
  return sch_check_required(sch);
}

/** 从 CSV 行 decode；按 field.col_index 映射列。 */
function schema_decode_csv_row_c(handle: i64, row: *u8, row_len: i32, offset: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let starts: i32[32];
  let lens: i32[32];
  let count: i32 = 0;
  let i: i32 = 0;
  let cell: u8[256];
  let ci: i32 = 0;
  let cl: i32 = 0;
  if (sch == 0 || row == 0) { return SCH_ERR_NULL; }
  sch_clear_values(sch);
  unsafe { parse_row(row, row_len, offset, &starts[0], &lens[0], SCH_MAX_FIELDS, &count); }
  if (count <= 0) {
    sch_set_error(sch, 0, &SCH_LIT_CSV_PARSE_ERROR[0]);
    return SCH_ERR_INVALID;
  }
  while (i < sch.field_count) {
    ci = sch.fields[i].col_index;
    if (ci < 0 || ci >= count) {
      if (sch.fields[i].optional == 0) {
        sch_set_error(sch, &sch.fields[i].name[0], &SCH_LIT_MISSING_CSV_COLUMN[0]);
        return SCH_ERR_NOT_FOUND;
      }
      i = i + 1;
      continue;
    }
    cl = lens[ci];
    if (cl >= SCH_VAL_MAX) { cl = SCH_VAL_MAX - 1; }
    unsafe { memcpy(&cell[0], row + starts[ci], cl); }
    cell[cl] = 0;
    if (sch_parse_text(sch, i, &cell[0]) != SCH_OK) { return SCH_ERR_TYPE; }
    i = i + 1;
  }
  return sch_check_required(sch);
}

/**
 * 从列文本数组映射（CSV 解析后或 SQLite row_col_text 结果）。
 * col_starts/col_lens 为每列在 row 缓冲内的偏移与长度；count 为列数。
 */
function schema_map_columns_c(handle: i64, row: *u8, col_starts: *i32, col_lens: *i32,
  count: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let i: i32 = 0;
  let cell: u8[256];
  let ci: i32 = 0;
  let cl: i32 = 0;
  if (sch == 0 || row == 0 || col_starts == 0 || col_lens == 0) { return SCH_ERR_NULL; }
  sch_clear_values(sch);
  while (i < sch.field_count) {
    ci = sch.fields[i].col_index;
    if (ci < 0 || ci >= count) {
      if (sch.fields[i].optional == 0) {
        sch_set_error(sch, &sch.fields[i].name[0], &SCH_LIT_MISSING_COLUMN[0]);
        return SCH_ERR_NOT_FOUND;
      }
      i = i + 1;
      continue;
    }
    cl = col_lens[ci];
    if (cl < 0) { cl = 0; }
    if (cl >= SCH_VAL_MAX) { cl = SCH_VAL_MAX - 1; }
    unsafe { memcpy(&cell[0], row + col_starts[ci], cl); }
    cell[cl] = 0;
    if (sch_parse_text(sch, i, &cell[0]) != SCH_OK) { return SCH_ERR_TYPE; }
    i = i + 1;
  }
  return sch_check_required(sch);
}

/** 读取 string 字段；返回长度，未找到或类型错误返回负数。 */
function schema_get_string_c(handle: i64, name: *u8, name_len: i32, out: *u8,
  out_cap: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let key: u8[64];
  let idx: i32 = 0;
  let n: i32 = 0;
  if (sch == 0 || name == 0 || out == 0 || out_cap <= 0) { return SCH_ERR_NULL; }
  if (name_len >= SCH_NAME_MAX) { return SCH_ERR_INVALID; }
  sch_copy_bytes_n(&key[0], name, name_len, SCH_NAME_MAX);
  idx = sch_find_field(sch, &key[0]);
  if (idx < 0) { return SCH_ERR_NOT_FOUND; }
  if (sch.values[idx].present == 0 ||
      sch.fields[idx].type != SCH_TYPE_STRING) { return SCH_ERR_TYPE; }
  unsafe { n = strlen(&sch.values[idx].str[0]) as i32; }
  if (n >= out_cap) { n = out_cap - 1; }
  unsafe { memcpy(out, &sch.values[idx].str[0], n); }
  out[n] = 0;
  return n;
}

/** 读取 i32 字段。 */
function schema_get_i32_c(handle: i64, name: *u8, name_len: i32, out: *i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let key: u8[64];
  let idx: i32 = 0;
  if (sch == 0 || name == 0 || out == 0) { return SCH_ERR_NULL; }
  if (name_len >= SCH_NAME_MAX) { return SCH_ERR_INVALID; }
  sch_copy_bytes_n(&key[0], name, name_len, SCH_NAME_MAX);
  idx = sch_find_field(sch, &key[0]);
  if (idx < 0) { return SCH_ERR_NOT_FOUND; }
  if (sch.values[idx].present == 0 ||
      sch.fields[idx].type != SCH_TYPE_I32) { return SCH_ERR_TYPE; }
  out[0] = sch.values[idx].i32_v;
  return SCH_OK;
}

/** 读取 bool 字段。 */
function schema_get_bool_c(handle: i64, name: *u8, name_len: i32, out: *i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let key: u8[64];
  let idx: i32 = 0;
  if (sch == 0 || name == 0 || out == 0) { return SCH_ERR_NULL; }
  if (name_len >= SCH_NAME_MAX) { return SCH_ERR_INVALID; }
  sch_copy_bytes_n(&key[0], name, name_len, SCH_NAME_MAX);
  idx = sch_find_field(sch, &key[0]);
  if (idx < 0) { return SCH_ERR_NOT_FOUND; }
  if (sch.values[idx].present == 0 ||
      sch.fields[idx].type != SCH_TYPE_BOOL) { return SCH_ERR_TYPE; }
  out[0] = sch.values[idx].bool_v;
  return SCH_OK;
}

/** 读取 f64 字段。 */
function schema_get_f64_c(handle: i64, name: *u8, name_len: i32, out: *f64): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let key: u8[64];
  let idx: i32 = 0;
  if (sch == 0 || name == 0 || out == 0) { return SCH_ERR_NULL; }
  if (name_len >= SCH_NAME_MAX) { return SCH_ERR_INVALID; }
  sch_copy_bytes_n(&key[0], name, name_len, SCH_NAME_MAX);
  idx = sch_find_field(sch, &key[0]);
  if (idx < 0) { return SCH_ERR_NOT_FOUND; }
  if (sch.values[idx].present == 0 ||
      sch.fields[idx].type != SCH_TYPE_F64) { return SCH_ERR_TYPE; }
  out[0] = sch.values[idx].f64_v;
  return SCH_OK;
}

/** 复制最近错误字段名；无错误返回 0 长度。 */
function schema_last_error_field_c(handle: i64, out: *u8, out_cap: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let n: i32 = 0;
  if (sch == 0 || out == 0 || out_cap <= 0) { return SCH_ERR_NULL; }
  unsafe { n = strlen(&sch.error_field[0]) as i32; }
  if (n >= out_cap) { n = out_cap - 1; }
  unsafe { memcpy(out, &sch.error_field[0], n); }
  out[n] = 0;
  return n;
}

/** 复制最近错误消息。 */
function schema_last_error_message_c(handle: i64, out: *u8, out_cap: i32): i32 {
  let sch: *SchSchema = sch_from_handle(handle);
  let n: i32 = 0;
  if (sch == 0 || out == 0 || out_cap <= 0) { return SCH_ERR_NULL; }
  unsafe { n = strlen(&sch.error_msg[0]) as i32; }
  if (n >= out_cap) { n = out_cap - 1; }
  unsafe { memcpy(out, &sch.error_msg[0], n); }
  out[n] = 0;
  return n;
}

/** C 烟测：JSON + CSV + 列映射 + 错误路径 + nested/array。 */
function schema_smoke_c(): i32 {
  let sch: i64 = 0;
  let age: i32 = 0;
  let active: i32 = 0;
  let name: u8[64];
  let json: *u8 = &SCH_LIT_NAME_ALICE_AGE_30_ACTIVE_TRUE[0];
  let csv: *u8 = &SCH_LIT_BOB_25_FALSE[0];
  let starts: i32[4];
  let lens: i32[4];
  let count: i32 = 0;
  let json_len: i32 = 0;
  let csv_len: i32 = 0;
  let nested: *u8 = 0;
  let nested_len: i32 = 0;
  let arr_json: *u8 = 0;
  let arr_len: i32 = 0;
  let arr_obj: *u8 = 0;
  let arr_obj_len: i32 = 0;
  sch = schema_create_c();
  if (sch == 0) { return 1; }
  if (schema_add_field_c(sch, &SCH_LIT_NAME[0], 4, SCH_TYPE_STRING, 0, 0) != SCH_OK) { return 2; }
  if (schema_add_field_c(sch, &SCH_LIT_AGE[0], 3, SCH_TYPE_I32, 0, 1) != SCH_OK) { return 3; }
  if (schema_add_field_c(sch, &SCH_LIT_ACTIVE[0], 6, SCH_TYPE_BOOL, 0, 2) != SCH_OK) { return 4; }
  unsafe { json_len = strlen(json) as i32; }
  if (schema_decode_json_c(sch, json, json_len) != SCH_OK) { return 5; }
  if (schema_get_string_c(sch, &SCH_LIT_NAME[0], 4, &name[0], 64) <= 0) { return 6; }
  if (unsafe { strcmp(&name[0], &SCH_LIT_ALICE[0]) } != 0) { return 7; }
  if (schema_get_i32_c(sch, &SCH_LIT_AGE[0], 3, &age) != SCH_OK || age != 30) { return 8; }
  if (schema_get_bool_c(sch, &SCH_LIT_ACTIVE[0], 6, &active) != SCH_OK || active != 1) { return 9; }
  unsafe { csv_len = strlen(csv) as i32; }
  if (schema_decode_csv_row_c(sch, csv, csv_len, 0) != SCH_OK) { return 10; }
  if (schema_get_string_c(sch, &SCH_LIT_NAME[0], 4, &name[0], 64) <= 0) { return 11; }
  if (unsafe { strcmp(&name[0], &SCH_LIT_BOB[0]) } != 0) { return 12; }
  if (schema_get_i32_c(sch, &SCH_LIT_AGE[0], 3, &age) != SCH_OK || age != 25) { return 13; }
  if (schema_get_bool_c(sch, &SCH_LIT_ACTIVE[0], 6, &active) != SCH_OK || active != 0) { return 14; }
  if (unsafe { parse_row(csv, csv_len, 0, &starts[0], &lens[0], 4, &count) } < 0) { return 15; }
  if (count != 3) { return 15; }
  if (schema_map_columns_c(sch, csv, &starts[0], &lens[0], count) != SCH_OK) { return 16; }
  if (schema_decode_json_c(sch, &SCH_LIT_NAME_X[0], 14) != SCH_ERR_NOT_FOUND) { return 17; }
  if (schema_last_error_field_c(sch, &name[0], 64) <= 0) { return 18; }
  /* nested object → 点分字段 */
  schema_free_c(sch);
  sch = schema_create_c();
  if (sch == 0) { return 19; }
  if (schema_add_field_c(sch, &SCH_LIT_USER_NAME[0], 9, SCH_TYPE_STRING, 0, 0) != SCH_OK) { return 20; }
  if (schema_add_field_c(sch, &SCH_LIT_USER_AGE[0], 8, SCH_TYPE_I32, 0, 1) != SCH_OK) { return 21; }
  nested = &SCH_LIT_USER_NAME_CAROL_AGE_42[0];
  unsafe { nested_len = strlen(nested) as i32; }
  if (schema_decode_json_c(sch, nested, nested_len) != SCH_OK) { return 22; }
  if (schema_get_string_c(sch, &SCH_LIT_USER_NAME[0], 9, &name[0], 64) <= 0) { return 23; }
  if (unsafe { strcmp(&name[0], &SCH_LIT_CAROL[0]) } != 0) { return 24; }
  if (schema_get_i32_c(sch, &SCH_LIT_USER_AGE[0], 8, &age) != SCH_OK || age != 42) { return 25; }
  /* JSON array → 索引点分键 */
  schema_free_c(sch);
  sch = schema_create_c();
  if (sch == 0) { return 26; }
  if (schema_add_field_c(sch, &SCH_LIT_ITEMS_0[0], 7, SCH_TYPE_I32, 0, 0) != SCH_OK) { return 27; }
  if (schema_add_field_c(sch, &SCH_LIT_ITEMS_1[0], 7, SCH_TYPE_I32, 0, 1) != SCH_OK) { return 28; }
  arr_json = &SCH_LIT_ITEMS_10_20[0];
  unsafe { arr_len = strlen(arr_json) as i32; }
  if (schema_decode_json_c(sch, arr_json, arr_len) != SCH_OK) { return 29; }
  if (schema_get_i32_c(sch, &SCH_LIT_ITEMS_0[0], 7, &age) != SCH_OK || age != 10) { return 30; }
  if (schema_get_i32_c(sch, &SCH_LIT_ITEMS_1[0], 7, &age) != SCH_OK || age != 20) { return 31; }
  /* JSON array-of-objects */
  schema_free_c(sch);
  sch = schema_create_c();
  if (sch == 0) { return 32; }
  if (schema_add_field_c(sch, &SCH_LIT_USERS_0_NAME[0], 12, SCH_TYPE_STRING, 0, 0) != SCH_OK) { return 33; }
  if (schema_add_field_c(sch, &SCH_LIT_USERS_1_NAME[0], 12, SCH_TYPE_STRING, 0, 1) != SCH_OK) { return 34; }
  arr_obj = &SCH_LIT_USERS_NAME_ALICE_NAME_BOB[0];
  unsafe { arr_obj_len = strlen(arr_obj) as i32; }
  if (schema_decode_json_c(sch, arr_obj, arr_obj_len) != SCH_OK) { return 35; }
  if (schema_get_string_c(sch, &SCH_LIT_USERS_0_NAME[0], 12, &name[0], 64) <= 0) { return 36; }
  if (unsafe { strcmp(&name[0], &SCH_LIT_ALICE[0]) } != 0) { return 37; }
  if (schema_get_string_c(sch, &SCH_LIT_USERS_1_NAME[0], 12, &name[0], 64) <= 0) { return 38; }
  if (unsafe { strcmp(&name[0], &SCH_LIT_BOB[0]) } != 0) { return 39; }
  schema_free_c(sch);
  return 0;
}
