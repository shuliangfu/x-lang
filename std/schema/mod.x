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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.

/* See implementation. */
allow(padding) struct Schema {
  handle: i64;
}

/** Exported function `text`.
 * Implements `text`.
 * @return i32
 */
export function text(): i32 { return 0; }
/** Exported function `int`.
 * Implements `int`.
 * @return i32
 */
export function int(): i32 { return 1; }
/** Exported function `flag`.
 * Implements `flag`.
 * @return i32
 */
export function flag(): i32 { return 2; }
/** Exported function `float`.
 * Implements `float`.
 * @return i32
 */
export function float(): i32 { return 3; }

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_null`.
 * Implements `err_null`.
 * @return i32
 */
export function err_null(): i32 { return -1; }
/** Exported function `err_not_found`.
 * Implements `err_not_found`.
 * @return i32
 */
export function err_not_found(): i32 { return -2; }
/** Exported function `err_type`.
 * Implements `err_type`.
 * @return i32
 */
export function err_type(): i32 { return -3; }
/** Exported function `err_invalid`.
 * Implements `err_invalid`.
 * @return i32
 */
export function err_invalid(): i32 { return -4; }
/** Exported function `err_full`.
 * Implements `err_full`.
 * @return i32
 */
export function err_full(): i32 { return -5; }

extern function schema_create_c(): i64;
extern function schema_free_c(handle: i64): void;
extern function schema_clear_c(handle: i64): void;
extern function schema_add_field_c(handle: i64, name: *u8, name_len: i32, type: i32, optional: i32, col_index: i32): i32;
extern function schema_decode_json_c(handle: i64, json: *u8, json_len: i32): i32;
extern function schema_decode_csv_row_c(handle: i64, row: *u8, row_len: i32, offset: i32): i32;
extern function schema_map_columns_c(handle: i64, row: *u8, col_starts: *i32, col_lens: *i32, count: i32): i32;
extern function schema_get_string_c(handle: i64, name: *u8, name_len: i32, out: *u8, out_cap: i32): i32;
extern function schema_get_i32_c(handle: i64, name: *u8, name_len: i32, out: *i32): i32;
extern function schema_get_bool_c(handle: i64, name: *u8, name_len: i32, out: *i32): i32;
extern function schema_get_f64_c(handle: i64, name: *u8, name_len: i32, out: *f64): i32;
extern function schema_last_error_field_c(handle: i64, out: *u8, out_cap: i32): i32;
extern function schema_last_error_message_c(handle: i64, out: *u8, out_cap: i32): i32;

/** Exported function `new`.
 * Implements `new`.
 * @return Schema
 */
export function new(): Schema {
  let h: i64 = 0;
  unsafe { h = schema_create_c(); }
  return Schema { handle: h };
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param sch *Schema
 * @return void
 */
export function free(sch: *Schema): void {
  let zero: i64 = 0;
  if (sch == 0) { return; }
  if (sch.handle != zero) {
    unsafe { schema_free_c(sch.handle); }
    sch.handle = zero;
  }
}

/** Exported function `clear`.
 * Implements `clear`.
 * @param sch *Schema
 * @return void
 */
export function clear(sch: *Schema): void {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero) { return; }
  unsafe { schema_clear_c(sch.handle); }
}

/**
 * See implementation.
 * See implementation.
 */
export function add_field(sch: *Schema, name: *u8, name_len: i32, type: i32, optional: i32, col_index: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero || name == 0) { return err_null(); }
  unsafe { return schema_add_field_c(sch.handle, name, name_len, type, optional, col_index); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `decode_json`.
 * Implements `decode_json`.
 * @param sch *Schema
 * @param json *u8
 * @param json_len i32
 * @return i32
 */
export function decode_json(sch: *Schema, json: *u8, json_len: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero || json == 0) { return err_null(); }
  unsafe { return schema_decode_json_c(sch.handle, json, json_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `decode_csv_row`.
 * Implements `decode_csv_row`.
 * @param sch *Schema
 * @param row *u8
 * @param row_len i32
 * @param offset i32
 * @return i32
 */
export function decode_csv_row(sch: *Schema, row: *u8, row_len: i32, offset: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero || row == 0) { return err_null(); }
  unsafe { return schema_decode_csv_row_c(sch.handle, row, row_len, offset); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `map_columns`.
 * Implements `map_columns`.
 * @param sch *Schema
 * @param row *u8
 * @param col_starts *i32
 * @param col_lens *i32
 * @param count i32
 * @return i32
 */
export function map_columns(sch: *Schema, row: *u8, col_starts: *i32, col_lens: *i32, count: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero || row == 0) { return err_null(); }
  unsafe { return schema_map_columns_c(sch.handle, row, col_starts, col_lens, count); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `get_string`.
 * Query helper `get_string`.
 * @param sch *Schema
 * @param name *u8
 * @param name_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function get_string(sch: *Schema, name: *u8, name_len: i32, out: *u8, out_cap: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero) { return err_null(); }
  unsafe { return schema_get_string_c(sch.handle, name, name_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `get`.
 * Implements `get`.
 * @param sch *Schema
 * @param name *u8
 * @param name_len i32
 * @param out *i32
 * @return i32
 */
export function get(sch: *Schema, name: *u8, name_len: i32, out: *i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero) { return err_null(); }
  unsafe { return schema_get_i32_c(sch.handle, name, name_len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `get`.
 * Implements `get`.
 * @param sch *Schema
 * @param name *u8
 * @param name_len i32
 * @param out *bool
 * @return i32
 */
export function get(sch: *Schema, name: *u8, name_len: i32, out: *bool): i32 {
  let zero: i64 = 0;
  let raw: i32 = 0;
  if (sch == 0 || sch.handle == zero) { return err_null(); }
  let r: i32 = 0;
  unsafe { r = schema_get_bool_c(sch.handle, name, name_len, &raw); }
  if (r == err_ok()) {
    out[0] = raw != 0;
  }
  return r;
}

/** Exported function `get`.
 * Implements `get`.
 * @param sch *Schema
 * @param name *u8
 * @param name_len i32
 * @param out *f64
 * @return i32
 */
export function get(sch: *Schema, name: *u8, name_len: i32, out: *f64): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero) { return err_null(); }
  unsafe { return schema_get_f64_c(sch.handle, name, name_len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `last_error_field`.
 * Implements `last_error_field`.
 * @param sch *Schema
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function last_error_field(sch: *Schema, out: *u8, out_cap: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero) { return err_null(); }
  unsafe { return schema_last_error_field_c(sch.handle, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `last_error_message`.
 * Implements `last_error_message`.
 * @param sch *Schema
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function last_error_message(sch: *Schema, out: *u8, out_cap: i32): i32 {
  let zero: i64 = 0;
  if (sch == 0 || sch.handle == zero) { return err_null(); }
  unsafe { return schema_last_error_message_c(sch.handle, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `to_code`.
 * Implements `to_code`.
 * @param local i32
 * @return i32
 */
export function to_code(local: i32): i32 {
  if (local == err_ok()) { return 0; }
  if (local == err_null()) { return -1501; }
  if (local == err_not_found()) { return -1502; }
  if (local == err_type()) { return -1503; }
  if (local == err_invalid()) { return -1504; }
  if (local == err_full()) { return -1505; }
  return -1500;
}
