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

// std.json — JSON 最小解析与生成（对标 Zig std.json、Rust serde_json）
//
// 【文件职责】解析 number/null/bool/string；object/array 游标与序列化；
// 零拷贝 string view；类型化 decode。单遍、无 sscanf，性能优先。
// 【API 对标】Zig parseFromSlice；Rust from_str / to_string。仅最小子集，无大依赖。

/** JSON 游标：与 json_parse_glue.c json_cursor_t 布局一致（STD-034）。 */
struct JsonCursor {
  ptr: *u8;
  len: i32;
  off: i32;
}

extern function json_parse_number_c(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32;
extern function json_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32;
extern function json_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32;
extern function json_parse_string_c(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32):
i32;
extern function json_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32;
extern function json_append_null_c(buf: *u8, buf_cap: i32): i32;
extern function json_append_bool_c(buf: *u8, buf_cap: i32, val: i32): i32;
extern function json_append_number_c(buf: *u8, buf_cap: i32, val: f64): i32;
extern function json_skip_value_c(ptr: *u8, len: i32, consumed: *i32): i32;
extern function json_parse_string_view_c(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8;
extern function json_cursor_init_c(cur: *JsonCursor, ptr: *u8, len: i32): void;
extern function json_cursor_enter_object_c(cur: *JsonCursor): i32;
extern function json_cursor_object_next_c(cur: *JsonCursor, key_buf: *u8, key_cap: i32,
  key_len: *i32): i32;
extern function json_cursor_skip_value_c(cur: *JsonCursor): i32;
extern function json_cursor_enter_array_c(cur: *JsonCursor): i32;
extern function json_cursor_array_has_elem_c(cur: *JsonCursor): i32;
extern function json_cursor_value_type_c(cur: *JsonCursor): i32;
extern function json_decode_i32_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32;
extern function json_decode_f64_at_c(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32;
extern function json_decode_bool_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32;
extern function json_decode_string_at_c(ptr: *u8, len: i32, out: *u8, out_cap: i32,
  out_len: *i32, consumed: *i32): i32;
extern function json_object_decode_i32_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32;
extern function json_object_decode_bool_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32;
extern function json_object_decode_string_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32;
extern function json_object_decode_dotted_i32_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32;
extern function json_object_decode_dotted_string_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8, out_cap: i32, out_len: *i32): i32;
extern function json_object_decode_dotted_bool_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32;
extern function json_object_decode_dotted_f64_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32;
extern function json_typed_decode_smoke_c(): i32;
extern function json_append_object_c(buf: *u8, cap: i32, off: i32): i32;
extern function json_append_object_end_c(buf: *u8, cap: i32, off: i32): i32;
extern function json_append_array_c(buf: *u8, cap: i32, off: i32): i32;
extern function json_append_array_end_c(buf: *u8, cap: i32, off: i32): i32;
extern function json_append_comma_c(buf: *u8, cap: i32, off: i32): i32;
extern function json_append_key_c(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32;
extern function json_append_string_value_c(buf: *u8, cap: i32, off: i32, val: *u8,
  val_len: i32): i32;
extern function json_append_number_at_c(buf: *u8, cap: i32, off: i32, val: f64): i32;

// ─── libc/胶水 FFI 薄包装（extern 须 unsafe；公开 API 调用包装而非直接 extern）───

/** 包装 `json_parse_number_c`；glue FFI 须 unsafe。 */
function json_libc_parse_number_c(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32 {
  unsafe { return json_parse_number_c(ptr, len, out_val, consumed); }
}

/** 包装 `json_parse_null_c`；glue FFI 须 unsafe。 */
function json_libc_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32 {
  unsafe { return json_parse_null_c(ptr, len, consumed); }
}

/** 包装 `json_parse_bool_c`；glue FFI 须 unsafe。 */
function json_libc_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32 {
  unsafe { return json_parse_bool_c(ptr, len, out, consumed); }
}

/** 包装 `json_parse_string_c`；glue FFI 须 unsafe。 */
function json_libc_parse_string_c(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32): i32 {
  unsafe { return json_parse_string_c(ptr, len, out, out_cap, consumed); }
}

/** 包装 `json_escape_c`；glue FFI 须 unsafe。 */
function json_libc_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  unsafe { return json_escape_c(ptr, len, buf, buf_cap); }
}

/** 包装 `json_append_null_c`；glue FFI 须 unsafe。 */
function json_libc_append_null_c(buf: *u8, buf_cap: i32): i32 {
  unsafe { return json_append_null_c(buf, buf_cap); }
}

/** 包装 `json_append_bool_c`；glue FFI 须 unsafe。 */
function json_libc_append_bool_c(buf: *u8, buf_cap: i32, val: i32): i32 {
  unsafe { return json_append_bool_c(buf, buf_cap, val); }
}

/** 包装 `json_append_number_c`；glue FFI 须 unsafe。 */
function json_libc_append_number_c(buf: *u8, buf_cap: i32, val: f64): i32 {
  unsafe { return json_append_number_c(buf, buf_cap, val); }
}

/** 包装 `json_skip_value_c`；glue FFI 须 unsafe。 */
function json_libc_skip_value_c(ptr: *u8, len: i32, consumed: *i32): i32 {
  unsafe { return json_skip_value_c(ptr, len, consumed); }
}

/** 包装 `json_parse_string_view_c`；glue FFI 须 unsafe。 */
function json_libc_parse_string_view_c(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8 {
  unsafe { return json_parse_string_view_c(ptr, len, out_len, consumed); }
}

/** 包装 `json_cursor_init_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_init_c(cur: *JsonCursor, ptr: *u8, len: i32): void {
  unsafe { json_cursor_init_c(cur, ptr, len); }
}

/** 包装 `json_cursor_enter_object_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_enter_object_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_enter_object_c(cur); }
}

/** 包装 `json_cursor_object_next_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_object_next_c(cur: *JsonCursor, key_buf: *u8, key_cap: i32,
  key_len: *i32): i32 {
  unsafe { return json_cursor_object_next_c(cur, key_buf, key_cap, key_len); }
}

/** 包装 `json_cursor_skip_value_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_skip_value_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_skip_value_c(cur); }
}

/** 包装 `json_cursor_enter_array_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_enter_array_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_enter_array_c(cur); }
}

/** 包装 `json_cursor_array_has_elem_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_array_has_elem_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_array_has_elem_c(cur); }
}

/** 包装 `json_cursor_value_type_c`；glue FFI 须 unsafe。 */
function json_libc_cursor_value_type_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_value_type_c(cur); }
}

/** 包装 `json_decode_i32_at_c`；glue FFI 须 unsafe。 */
function json_libc_decode_i32_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  unsafe { return json_decode_i32_at_c(ptr, len, consumed, out); }
}

/** 包装 `json_decode_f64_at_c`；glue FFI 须 unsafe。 */
function json_libc_decode_f64_at_c(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32 {
  unsafe { return json_decode_f64_at_c(ptr, len, consumed, out); }
}

/** 包装 `json_decode_bool_at_c`；glue FFI 须 unsafe。 */
function json_libc_decode_bool_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  unsafe { return json_decode_bool_at_c(ptr, len, consumed, out); }
}

/** 包装 `json_decode_string_at_c`；glue FFI 须 unsafe。 */
function json_libc_decode_string_at_c(ptr: *u8, len: i32, out: *u8, out_cap: i32,
  out_len: *i32, consumed: *i32): i32 {
  unsafe { return json_decode_string_at_c(ptr, len, out, out_cap, out_len, consumed); }
}

/** 包装 `json_object_decode_i32_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_i32_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_i32_c(cur, key, key_len, out); }
}

/** 包装 `json_object_decode_bool_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_bool_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_bool_c(cur, key, key_len, out); }
}

/** 包装 `json_object_decode_string_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_string_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  unsafe { return json_object_decode_string_c(cur, key, key_len, out, out_cap, out_len); }
}

/** 包装 `json_object_decode_dotted_i32_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_dotted_i32_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_dotted_i32_c(cur, path, path_len, out); }
}

/** 包装 `json_object_decode_dotted_string_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_dotted_string_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8, out_cap: i32, out_len: *i32): i32 {
  unsafe { return json_object_decode_dotted_string_c(cur, path, path_len, out, out_cap, out_len); }
}

/** 包装 `json_object_decode_dotted_bool_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_dotted_bool_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_dotted_bool_c(cur, path, path_len, out); }
}

/** 包装 `json_object_decode_dotted_f64_c`；glue FFI 须 unsafe。 */
function json_libc_object_decode_dotted_f64_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32 {
  unsafe { return json_object_decode_dotted_f64_c(cur, path, path_len, out); }
}

/** 包装 `json_typed_decode_smoke_c`；glue FFI 须 unsafe。 */
function json_libc_typed_decode_smoke_c(): i32 {
  unsafe { return json_typed_decode_smoke_c(); }
}

/** 包装 `json_append_object_c`；glue FFI 须 unsafe。 */
function json_libc_append_object_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_object_c(buf, cap, off); }
}

/** 包装 `json_append_object_end_c`；glue FFI 须 unsafe。 */
function json_libc_append_object_end_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_object_end_c(buf, cap, off); }
}

/** 包装 `json_append_array_c`；glue FFI 须 unsafe。 */
function json_libc_append_array_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_array_c(buf, cap, off); }
}

/** 包装 `json_append_array_end_c`；glue FFI 须 unsafe。 */
function json_libc_append_array_end_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_array_end_c(buf, cap, off); }
}

/** 包装 `json_append_comma_c`；glue FFI 须 unsafe。 */
function json_libc_append_comma_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_comma_c(buf, cap, off); }
}

/** 包装 `json_append_key_c`；glue FFI 须 unsafe。 */
function json_libc_append_key_c(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32 {
  unsafe { return json_append_key_c(buf, cap, off, key, key_len); }
}

/** 包装 `json_append_string_value_c`；glue FFI 须 unsafe。 */
function json_libc_append_string_value_c(buf: *u8, cap: i32, off: i32, val: *u8,
  val_len: i32): i32 {
  unsafe { return json_append_string_value_c(buf, cap, off, val, val_len); }
}

/** 包装 `json_append_number_at_c`；glue FFI 须 unsafe。 */
function json_libc_append_number_at_c(buf: *u8, cap: i32, off: i32, val: f64): i32 {
  unsafe { return json_append_number_at_c(buf, cap, off, val); }
}

/** 零拷贝视图需拷贝时的 out_len 哨兵（STD-008）。 */
function needs_copy(): i32 { return -2; }

/** object 字段缺失时的返回码（STD-116）。 */
function decode_missing(): i32 { return -3; }

function parse_number(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32 {
  return json_libc_parse_number_c(ptr, len, out_val, consumed);
}
function parse_null(ptr: *u8, len: i32, consumed: *i32): i32 {
  return json_libc_parse_null_c(ptr, len, consumed);
}
function parse(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32 {
  return json_libc_parse_bool_c(ptr, len, out, consumed);
}
/** 解析 JSON 字符串 "..."（含 \\ \\\" \\n \\r \\t \\uXXXX）；内容写入 out，返回内容长度，失败 -1。 */
function parse_string(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32): i32 {
  return json_libc_parse_string_c(ptr, len, out, out_cap, consumed);
}
function escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  return json_libc_escape_c(ptr, len, buf, buf_cap);
}
function append_null(buf: *u8, buf_cap: i32): i32 {
  return json_libc_append_null_c(buf, buf_cap);
}
function append(buf: *u8, buf_cap: i32, val: i32): i32 {
  return json_libc_append_bool_c(buf, buf_cap, val);
}
function append_number(buf: *u8, buf_cap: i32, val: f64): i32 {
  return json_libc_append_number_c(buf, buf_cap, val);
}

/** 跳过 ptr[0..len) 处完整 JSON 值；成功 0 并写 consumed 字节数，失败 -1（STD-034）。 */
function skip_value(ptr: *u8, len: i32, consumed: *i32): i32 {
  return json_libc_skip_value_c(ptr, len, consumed);
}

/** 无转义 JSON 字符串零拷贝视图；含转义时返回 null 且 *out_len = needs_copy()。 */
function parse_string_view(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8 {
  return json_libc_parse_string_view_c(ptr, len, out_len, consumed);
}

/** 初始化 JSON 游标。 */
function cursor_init(ptr: *u8, len: i32): JsonCursor {
  let cur: JsonCursor = JsonCursor { ptr: ptr, len: len, off: 0 };
  json_libc_cursor_init_c(&cur, ptr, len);
  return cur;
}

/** 进入 object；期望 leading `{`。 */
function cursor_enter_object(cur: *JsonCursor): i32 {
  return json_libc_cursor_enter_object_c(cur);
}

/** 读取下一 object 键；成功 1，结束 0，错误 -1。 */
function cursor_object_next(cur: *JsonCursor, key_buf: *u8, key_cap: i32, key_len: *i32): i32 {
  return json_libc_cursor_object_next_c(cur, key_buf, key_cap, key_len);
}

/** 跳过当前 value。 */
function cursor_skip_value(cur: *JsonCursor): i32 {
  return json_libc_cursor_skip_value_c(cur);
}

/** 进入 array；期望 leading `[`。 */
function cursor_enter_array(cur: *JsonCursor): i32 {
  return json_libc_cursor_enter_array_c(cur);
}

/** 数组内是否还有元素：1 有，0 已到 `]`。 */
function cursor_array_has_elem(cur: *JsonCursor): i32 {
  return json_libc_cursor_array_has_elem_c(cur);
}

/** 游标处 JSON 值种类（STD-116）。 */
function cursor_value_type(cur: *JsonCursor): i32 {
  return json_libc_cursor_value_type_c(cur);
}

/** 在 ptr 起点解码 i32。 */
function decode_at(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  return json_libc_decode_i32_at_c(ptr, len, consumed, out);
}

/** 在 ptr 起点解码 f64。 */
function decode_at(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32 {
  return json_libc_decode_f64_at_c(ptr, len, consumed, out);
}

/** 在 ptr 起点解码 bool（*bool 重载，与 i32 区分）。 */
function decode_at(ptr: *u8, len: i32, consumed: *i32, out: *bool): i32 {
  return json_libc_decode_bool_at_c(ptr, len, consumed, out as *i32);
}

/** 在 ptr 起点解码 string。 */
function decode_string_at(ptr: *u8, len: i32, out: *u8, out_cap: i32, out_len: *i32,
  consumed: *i32): i32 {
  return json_libc_decode_string_at_c(ptr, len, out, out_cap, out_len, consumed);
}

/** object 内按 key 解码 i32 字段。 */
function object_decode(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  return json_libc_object_decode_i32_c(cur, key, key_len, out);
}

/** object 内按 key 解码 bool 字段（*bool 重载）。 */
function object_decode(cur: *JsonCursor, key: *u8, key_len: i32, out: *bool): i32 {
  return json_libc_object_decode_bool_c(cur, key, key_len, out as *i32);
}

/** object 内按 key 解码 string 字段。 */
function object_decode_string(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8, out_cap: i32,
  out_len: *i32): i32 {
  return json_libc_object_decode_string_c(cur, key, key_len, out, out_cap, out_len);
}

/** object 内按点分路径解码 i32（如 user.age）。 */
function object_decode_dotted(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  return json_libc_object_decode_dotted_i32_c(cur, path, path_len, out);
}

/** object 内按点分路径解码 string（如 user.name）。 */
function object_decode_dotted_string(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  return json_libc_object_decode_dotted_string_c(cur, path, path_len, out, out_cap, out_len);
}

/** object 内按点分路径解码 bool（*bool 重载，如 ok / flags.0）。 */
function object_decode_dotted(cur: *JsonCursor, path: *u8, path_len: i32, out: *bool): i32 {
  return json_libc_object_decode_dotted_bool_c(cur, path, path_len, out as *i32);
}

/** object 内按点分路径解码 f64（如 metrics.cpu / values.0）。 */
function object_decode_dotted(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32 {
  return json_libc_object_decode_dotted_f64_c(cur, path, path_len, out);
}

/** 类型化 decode C 烟测钩子（STD-116）。 */
function typed_decode_smoke(): i32 {
  return json_libc_typed_decode_smoke_c();
}

/** 在 buf[off] 写入 `{`。 */
function append_object(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_object_c(buf, cap, off);
}

/** 在 buf[off] 写入 `}`。 */
function append_object_end(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_object_end_c(buf, cap, off);
}

/** 在 buf[off] 写入 `[`。 */
function append_array(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_array_c(buf, cap, off);
}

/** 在 buf[off] 写入 `]`。 */
function append_array_end(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_array_end_c(buf, cap, off);
}

/** 在 buf[off] 写入 `,`。 */
function append_comma(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_comma_c(buf, cap, off);
}

/** 在 buf[off] 写入 `"key":`。 */
function append_key(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32 {
  return json_libc_append_key_c(buf, cap, off, key, key_len);
}

/** 在 buf[off] 写入 `"value"`。 */
function append_string_value(buf: *u8, cap: i32, off: i32, val: *u8, val_len: i32): i32 {
  return json_libc_append_string_value_c(buf, cap, off, val, val_len);
}

/** 在 buf[off] 写入 number。 */
function append_number_at(buf: *u8, cap: i32, off: i32, val: f64): i32 {
  return json_libc_append_number_at_c(buf, cap, off, val);
}
/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function json_module_anchor(): i32 { return 0; }
