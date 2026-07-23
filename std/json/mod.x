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

/**
 * JSON C ABI wrappers.
 *
 * All `json_*_c` functions below are thin wrappers over the JSON
 * parser / serializer C implementation (see seeds). They are exposed
 * to XLANG via `extern "C"` declarations.
 *
 * ABI: C (System V / AAPCS). Calling convention matches the C runtime
 * (RFC 8259 grammar-driven recursive descent + cursor model + append
 * buffer serializer).
 * PLATFORM: SHARED — pure C, no platform-specific intrinsics; available
 * on all targets (macOS arm64 / Ubuntu x86_64 / Windows MSYS2).
 *
 * Cursor model:
 *   - JsonCursor { ptr: *u8, len: i32, off: i32 } tracks position
 *     during streaming decode of a JSON document.
 *   - Cursor enter/next/skip/value_type navigate object/array/value
 *     structure without allocating intermediate AST nodes.
 *
 * Decoder categories:
 *   - json_parse_*_c        : low-level value parsers (number/null/
 *                             bool/string + string view + escape)
 *   - json_cursor_*_c       : streaming cursor navigation
 *   - json_decode_*_at_c    : typed positional decoders (i32/f64/bool/
 *                             string)
 *   - json_object_decode_*_c: object key-lookup decoders (i32/bool/
 *                             string + dotted path variants)
 *   - json_append_*_c       : serializer builders (object/array/comma/
 *                             key/string value/number)
 *
 * Error codes: returns i32; 0 = OK, negative = error
 *   (e.g. -1 invalid JSON, -2 truncated, -3 type mismatch,
 *    -4 buffer overflow, -5 key not found).
 *
 * Unsafe contract: callers must wrap `json_*_c` calls in `unsafe { }`
 * blocks. P0a semantic downgrade currently allows unwrapped calls; P1
 * typeck enforcement (post-bootstrap) will reject unwrapped calls.
 */

/* See implementation. */
export struct JsonCursor {
  ptr: *u8;
  len: i32;
  off: i32;
}

extern "C" function json_parse_number_c(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32;
extern "C" function json_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32;
extern "C" function json_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32;
extern "C" function json_parse_string_c(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32):
i32;
extern "C" function json_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32;
extern "C" function json_append_null_c(buf: *u8, buf_cap: i32): i32;
extern "C" function json_append_bool_c(buf: *u8, buf_cap: i32, val: i32): i32;
extern "C" function json_append_number_c(buf: *u8, buf_cap: i32, val: f64): i32;
extern "C" function json_skip_value_c(ptr: *u8, len: i32, consumed: *i32): i32;
extern "C" function json_parse_string_view_c(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8;
extern "C" function json_cursor_init_c(cur: *JsonCursor, ptr: *u8, len: i32): void;
extern "C" function json_cursor_enter_object_c(cur: *JsonCursor): i32;
extern "C" function json_cursor_object_next_c(cur: *JsonCursor, key_buf: *u8, key_cap: i32,
  key_len: *i32): i32;
extern "C" function json_cursor_skip_value_c(cur: *JsonCursor): i32;
extern "C" function json_cursor_enter_array_c(cur: *JsonCursor): i32;
extern "C" function json_cursor_array_has_elem_c(cur: *JsonCursor): i32;
extern "C" function json_cursor_value_type_c(cur: *JsonCursor): i32;
extern "C" function json_decode_i32_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32;
extern "C" function json_decode_f64_at_c(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32;
extern "C" function json_decode_bool_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32;
extern "C" function json_decode_string_at_c(ptr: *u8, len: i32, out: *u8, out_cap: i32,
  out_len: *i32, consumed: *i32): i32;
extern "C" function json_object_decode_i32_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32;
extern "C" function json_object_decode_bool_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32;
extern "C" function json_object_decode_string_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32;
extern "C" function json_object_decode_dotted_i32_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32;
extern "C" function json_object_decode_dotted_string_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8, out_cap: i32, out_len: *i32): i32;
extern "C" function json_object_decode_dotted_bool_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32;
extern "C" function json_object_decode_dotted_f64_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32;
extern "C" function json_typed_decode_smoke_c(): i32;
extern "C" function json_append_object_c(buf: *u8, cap: i32, off: i32): i32;
extern "C" function json_append_object_end_c(buf: *u8, cap: i32, off: i32): i32;
extern "C" function json_append_array_c(buf: *u8, cap: i32, off: i32): i32;
extern "C" function json_append_array_end_c(buf: *u8, cap: i32, off: i32): i32;
extern "C" function json_append_comma_c(buf: *u8, cap: i32, off: i32): i32;
extern "C" function json_append_key_c(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32;
extern "C" function json_append_string_value_c(buf: *u8, cap: i32, off: i32, val: *u8,
  val_len: i32): i32;
extern "C" function json_append_number_at_c(buf: *u8, cap: i32, off: i32, val: f64): i32;

// See implementation.

/** Exported function `json_libc_parse_number_c`.
 * Implements `json_libc_parse_number_c`.
 * @param ptr *u8
 * @param len i32
 * @param out_val *f64
 * @param consumed *i32
 * @return i32
 */
export function json_libc_parse_number_c(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32 {
  unsafe { return json_parse_number_c(ptr, len, out_val, consumed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_parse_null_c`.
 * Implements `json_libc_parse_null_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @return i32
 */
export function json_libc_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32 {
  unsafe { return json_parse_null_c(ptr, len, consumed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_parse_bool_c`.
 * Implements `json_libc_parse_bool_c`.
 * @param ptr *u8
 * @param len i32
 * @param out *i32
 * @param consumed *i32
 * @return i32
 */
export function json_libc_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32 {
  unsafe { return json_parse_bool_c(ptr, len, out, consumed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_parse_string_c`.
 * Implements `json_libc_parse_string_c`.
 * @param ptr *u8
 * @param len i32
 * @param out *u8
 * @param out_cap i32
 * @param consumed *i32
 * @return i32
 */
export function json_libc_parse_string_c(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32): i32 {
  unsafe { return json_parse_string_c(ptr, len, out, out_cap, consumed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_escape_c`.
 * Implements `json_libc_escape_c`.
 * @param ptr *u8
 * @param len i32
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function json_libc_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  unsafe { return json_escape_c(ptr, len, buf, buf_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_null_c`.
 * Implements `json_libc_append_null_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function json_libc_append_null_c(buf: *u8, buf_cap: i32): i32 {
  unsafe { return json_append_null_c(buf, buf_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_bool_c`.
 * Implements `json_libc_append_bool_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @param val i32
 * @return i32
 */
export function json_libc_append_bool_c(buf: *u8, buf_cap: i32, val: i32): i32 {
  unsafe { return json_append_bool_c(buf, buf_cap, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_number_c`.
 * Implements `json_libc_append_number_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @param val f64
 * @return i32
 */
export function json_libc_append_number_c(buf: *u8, buf_cap: i32, val: f64): i32 {
  unsafe { return json_append_number_c(buf, buf_cap, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_skip_value_c`.
 * Implements `json_libc_skip_value_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @return i32
 */
export function json_libc_skip_value_c(ptr: *u8, len: i32, consumed: *i32): i32 {
  unsafe { return json_skip_value_c(ptr, len, consumed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_parse_string_view_c`.
 * Implements `json_libc_parse_string_view_c`.
 * @param ptr *u8
 * @param len i32
 * @param out_len *i32
 * @param consumed *i32
 * @return *u8
 */
export function json_libc_parse_string_view_c(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8 {
  unsafe { return json_parse_string_view_c(ptr, len, out_len, consumed); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `json_libc_cursor_init_c`.
 * Implements `json_libc_cursor_init_c`.
 * @param cur *JsonCursor
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function json_libc_cursor_init_c(cur: *JsonCursor, ptr: *u8, len: i32): void {
  unsafe { json_cursor_init_c(cur, ptr, len); }
}

/** Exported function `json_libc_cursor_enter_object_c`.
 * Implements `json_libc_cursor_enter_object_c`.
 * @param cur *JsonCursor
 * @return i32
 */
export function json_libc_cursor_enter_object_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_enter_object_c(cur); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function json_libc_cursor_object_next_c(cur: *JsonCursor, key_buf: *u8, key_cap: i32,
  key_len: *i32): i32 {
  unsafe { return json_cursor_object_next_c(cur, key_buf, key_cap, key_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_cursor_skip_value_c`.
 * Implements `json_libc_cursor_skip_value_c`.
 * @param cur *JsonCursor
 * @return i32
 */
export function json_libc_cursor_skip_value_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_skip_value_c(cur); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_cursor_enter_array_c`.
 * Implements `json_libc_cursor_enter_array_c`.
 * @param cur *JsonCursor
 * @return i32
 */
export function json_libc_cursor_enter_array_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_enter_array_c(cur); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_cursor_array_has_elem_c`.
 * Implements `json_libc_cursor_array_has_elem_c`.
 * @param cur *JsonCursor
 * @return i32
 */
export function json_libc_cursor_array_has_elem_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_array_has_elem_c(cur); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_cursor_value_type_c`.
 * Implements `json_libc_cursor_value_type_c`.
 * @param cur *JsonCursor
 * @return i32
 */
export function json_libc_cursor_value_type_c(cur: *JsonCursor): i32 {
  unsafe { return json_cursor_value_type_c(cur); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_decode_i32_at_c`.
 * Implements `json_libc_decode_i32_at_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
export function json_libc_decode_i32_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  unsafe { return json_decode_i32_at_c(ptr, len, consumed, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_decode_f64_at_c`.
 * Implements `json_libc_decode_f64_at_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *f64
 * @return i32
 */
export function json_libc_decode_f64_at_c(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32 {
  unsafe { return json_decode_f64_at_c(ptr, len, consumed, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_decode_bool_at_c`.
 * Implements `json_libc_decode_bool_at_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
export function json_libc_decode_bool_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  unsafe { return json_decode_bool_at_c(ptr, len, consumed, out); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function json_libc_decode_string_at_c(ptr: *u8, len: i32, out: *u8, out_cap: i32,
  out_len: *i32, consumed: *i32): i32 {
  unsafe { return json_decode_string_at_c(ptr, len, out, out_cap, out_len, consumed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_object_decode_i32_c`.
 * Implements `json_libc_object_decode_i32_c`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
export function json_libc_object_decode_i32_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_i32_c(cur, key, key_len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_object_decode_bool_c`.
 * Implements `json_libc_object_decode_bool_c`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
export function json_libc_object_decode_bool_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_bool_c(cur, key, key_len, out); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function json_libc_object_decode_string_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  unsafe { return json_object_decode_string_c(cur, key, key_len, out, out_cap, out_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_object_decode_dotted_i32_c`.
 * Implements `json_libc_object_decode_dotted_i32_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *i32
 * @return i32
 */
export function json_libc_object_decode_dotted_i32_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_dotted_i32_c(cur, path, path_len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_object_decode_dotted_string_c`.
 * Implements `json_libc_object_decode_dotted_string_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_cap i32
 * @param out_len *i32
 * @return i32
 */
export function json_libc_object_decode_dotted_string_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8, out_cap: i32, out_len: *i32): i32 {
  unsafe { return json_object_decode_dotted_string_c(cur, path, path_len, out, out_cap, out_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_object_decode_dotted_bool_c`.
 * Implements `json_libc_object_decode_dotted_bool_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *i32
 * @return i32
 */
export function json_libc_object_decode_dotted_bool_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  unsafe { return json_object_decode_dotted_bool_c(cur, path, path_len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_object_decode_dotted_f64_c`.
 * Implements `json_libc_object_decode_dotted_f64_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *f64
 * @return i32
 */
export function json_libc_object_decode_dotted_f64_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32 {
  unsafe { return json_object_decode_dotted_f64_c(cur, path, path_len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_typed_decode_smoke_c`.
 * Implements `json_libc_typed_decode_smoke_c`.
 * @return i32
 */
export function json_libc_typed_decode_smoke_c(): i32 {
  unsafe { return json_typed_decode_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_object_c`.
 * Implements `json_libc_append_object_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function json_libc_append_object_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_object_c(buf, cap, off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_object_end_c`.
 * Implements `json_libc_append_object_end_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function json_libc_append_object_end_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_object_end_c(buf, cap, off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_array_c`.
 * Implements `json_libc_append_array_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function json_libc_append_array_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_array_c(buf, cap, off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_array_end_c`.
 * Implements `json_libc_append_array_end_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function json_libc_append_array_end_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_array_end_c(buf, cap, off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_comma_c`.
 * Implements `json_libc_append_comma_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function json_libc_append_comma_c(buf: *u8, cap: i32, off: i32): i32 {
  unsafe { return json_append_comma_c(buf, cap, off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_key_c`.
 * Implements `json_libc_append_key_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function json_libc_append_key_c(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32 {
  unsafe { return json_append_key_c(buf, cap, off, key, key_len); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function json_libc_append_string_value_c(buf: *u8, cap: i32, off: i32, val: *u8,
  val_len: i32): i32 {
  unsafe { return json_append_string_value_c(buf, cap, off, val, val_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `json_libc_append_number_at_c`.
 * Implements `json_libc_append_number_at_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param val f64
 * @return i32
 */
export function json_libc_append_number_at_c(buf: *u8, cap: i32, off: i32, val: f64): i32 {
  unsafe { return json_append_number_at_c(buf, cap, off, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `needs_copy`.
 * Implements `needs_copy`.
 * @return i32
 */
export function needs_copy(): i32 { return -2; }

/** Exported function `decode_missing`.
 * Implements `decode_missing`.
 * @return i32
 */
export function decode_missing(): i32 { return -3; }

/** Exported function `parse_number`.
 * Implements `parse_number`.
 * @param ptr *u8
 * @param len i32
 * @param out_val *f64
 * @param consumed *i32
 * @return i32
 */
export function parse_number(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32 {
  return json_libc_parse_number_c(ptr, len, out_val, consumed);
}
/** Exported function `parse_null`.
 * Implements `parse_null`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @return i32
 */
export function parse_null(ptr: *u8, len: i32, consumed: *i32): i32 {
  return json_libc_parse_null_c(ptr, len, consumed);
}
/** Exported function `parse`.
 * Implements `parse`.
 * @param ptr *u8
 * @param len i32
 * @param out *i32
 * @param consumed *i32
 * @return i32
 */
export function parse(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32 {
  return json_libc_parse_bool_c(ptr, len, out, consumed);
}
/** Exported function `parse_string`.
 * Implements `parse_string`.
 * @param ptr *u8
 * @param len i32
 * @param out *u8
 * @param out_cap i32
 * @param consumed *i32
 * @return i32
 */
export function parse_string(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32): i32 {
  return json_libc_parse_string_c(ptr, len, out, out_cap, consumed);
}
/** Exported function `escape`.
 * Implements `escape`.
 * @param ptr *u8
 * @param len i32
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  return json_libc_escape_c(ptr, len, buf, buf_cap);
}
/** Exported function `append_null`.
 * Implements `append_null`.
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function append_null(buf: *u8, buf_cap: i32): i32 {
  return json_libc_append_null_c(buf, buf_cap);
}
/** Exported function `append`.
 * Implements `append`.
 * @param buf *u8
 * @param buf_cap i32
 * @param val i32
 * @return i32
 */
export function append(buf: *u8, buf_cap: i32, val: i32): i32 {
  return json_libc_append_bool_c(buf, buf_cap, val);
}
/** Exported function `append_number`.
 * Implements `append_number`.
 * @param buf *u8
 * @param buf_cap i32
 * @param val f64
 * @return i32
 */
export function append_number(buf: *u8, buf_cap: i32, val: f64): i32 {
  return json_libc_append_number_c(buf, buf_cap, val);
}

/** Exported function `skip_value`.
 * Implements `skip_value`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @return i32
 */
export function skip_value(ptr: *u8, len: i32, consumed: *i32): i32 {
  return json_libc_skip_value_c(ptr, len, consumed);
}

/** Exported function `parse_string_view`.
 * Implements `parse_string_view`.
 * @param ptr *u8
 * @param len i32
 * @param out_len *i32
 * @param consumed *i32
 * @return *u8
 */
export function parse_string_view(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8 {
  return json_libc_parse_string_view_c(ptr, len, out_len, consumed);
}

/** Exported function `cursor_init`.
 * Implements `cursor_init`.
 * @param ptr *u8
 * @param len i32
 * @return JsonCursor
 */
export function cursor_init(ptr: *u8, len: i32): JsonCursor {
  let cur: JsonCursor = JsonCursor { ptr: ptr, len: len, off: 0 };
  json_libc_cursor_init_c(&cur, ptr, len);
  return cur;
}

/** Internal function `cursor_enter_object`.
 * Implements `cursor_enter_object`.
 * @param cur *JsonCursor
 * @return i32
 */
function cursor_enter_object(cur: *JsonCursor): i32 {
  return json_libc_cursor_enter_object_c(cur);
}

/** Internal function `cursor_object_next`.
 * Implements `cursor_object_next`.
 * @param cur *JsonCursor
 * @param key_buf *u8
 * @param key_cap i32
 * @param key_len *i32
 * @return i32
 */
function cursor_object_next(cur: *JsonCursor, key_buf: *u8, key_cap: i32, key_len: *i32): i32 {
  return json_libc_cursor_object_next_c(cur, key_buf, key_cap, key_len);
}

/** Internal function `cursor_skip_value`.
 * Implements `cursor_skip_value`.
 * @param cur *JsonCursor
 * @return i32
 */
function cursor_skip_value(cur: *JsonCursor): i32 {
  return json_libc_cursor_skip_value_c(cur);
}

/** Internal function `cursor_enter_array`.
 * Implements `cursor_enter_array`.
 * @param cur *JsonCursor
 * @return i32
 */
function cursor_enter_array(cur: *JsonCursor): i32 {
  return json_libc_cursor_enter_array_c(cur);
}

/** Internal function `cursor_array_has_elem`.
 * Implements `cursor_array_has_elem`.
 * @param cur *JsonCursor
 * @return i32
 */
function cursor_array_has_elem(cur: *JsonCursor): i32 {
  return json_libc_cursor_array_has_elem_c(cur);
}

/** Internal function `cursor_value_type`.
 * Implements `cursor_value_type`.
 * @param cur *JsonCursor
 * @return i32
 */
function cursor_value_type(cur: *JsonCursor): i32 {
  return json_libc_cursor_value_type_c(cur);
}

/** Internal function `decode_at`.
 * Implements `decode_at`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
function decode_at(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  return json_libc_decode_i32_at_c(ptr, len, consumed, out);
}

/** Internal function `decode_at`.
 * Implements `decode_at`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *f64
 * @return i32
 */
function decode_at(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32 {
  return json_libc_decode_f64_at_c(ptr, len, consumed, out);
}

/** Internal function `decode_at`.
 * Implements `decode_at`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *bool
 * @return i32
 */
function decode_at(ptr: *u8, len: i32, consumed: *i32, out: *bool): i32 {
  return json_libc_decode_bool_at_c(ptr, len, consumed, out as *i32);
}

/* See implementation. */
function decode_string_at(ptr: *u8, len: i32, out: *u8, out_cap: i32, out_len: *i32,
  consumed: *i32): i32 {
  return json_libc_decode_string_at_c(ptr, len, out, out_cap, out_len, consumed);
}

/** Internal function `object_decode`.
 * Implements `object_decode`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
function object_decode(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  return json_libc_object_decode_i32_c(cur, key, key_len, out);
}

/** Internal function `object_decode`.
 * Implements `object_decode`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out *bool
 * @return i32
 */
function object_decode(cur: *JsonCursor, key: *u8, key_len: i32, out: *bool): i32 {
  return json_libc_object_decode_bool_c(cur, key, key_len, out as *i32);
}

/* See implementation. */
function object_decode_string(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8, out_cap: i32,
  out_len: *i32): i32 {
  return json_libc_object_decode_string_c(cur, key, key_len, out, out_cap, out_len);
}

/** Internal function `object_decode_dotted`.
 * Implements `object_decode_dotted`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *i32
 * @return i32
 */
function object_decode_dotted(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  return json_libc_object_decode_dotted_i32_c(cur, path, path_len, out);
}

/* See implementation. */
function object_decode_dotted_string(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  return json_libc_object_decode_dotted_string_c(cur, path, path_len, out, out_cap, out_len);
}

/** Internal function `object_decode_dotted`.
 * Implements `object_decode_dotted`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *bool
 * @return i32
 */
function object_decode_dotted(cur: *JsonCursor, path: *u8, path_len: i32, out: *bool): i32 {
  return json_libc_object_decode_dotted_bool_c(cur, path, path_len, out as *i32);
}

/** Internal function `object_decode_dotted`.
 * Implements `object_decode_dotted`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *f64
 * @return i32
 */
function object_decode_dotted(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32 {
  return json_libc_object_decode_dotted_f64_c(cur, path, path_len, out);
}

/** Internal function `typed_decode_smoke`.
 * Implements `typed_decode_smoke`.
 * @return i32
 */
function typed_decode_smoke(): i32 {
  return json_libc_typed_decode_smoke_c();
}

/** Internal function `append_object`.
 * Implements `append_object`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function append_object(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_object_c(buf, cap, off);
}

/** Internal function `append_object_end`.
 * Implements `append_object_end`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function append_object_end(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_object_end_c(buf, cap, off);
}

/** Internal function `append_array`.
 * Implements `append_array`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function append_array(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_array_c(buf, cap, off);
}

/** Internal function `append_array_end`.
 * Implements `append_array_end`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function append_array_end(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_array_end_c(buf, cap, off);
}

/** Internal function `append_comma`.
 * Implements `append_comma`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function append_comma(buf: *u8, cap: i32, off: i32): i32 {
  return json_libc_append_comma_c(buf, cap, off);
}

/** Internal function `append_key`.
 * Implements `append_key`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
function append_key(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32 {
  return json_libc_append_key_c(buf, cap, off, key, key_len);
}

/** Internal function `append_string_value`.
 * Implements `append_string_value`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param val *u8
 * @param val_len i32
 * @return i32
 */
function append_string_value(buf: *u8, cap: i32, off: i32, val: *u8, val_len: i32): i32 {
  return json_libc_append_string_value_c(buf, cap, off, val, val_len);
}

/** Internal function `append_number_at`.
 * Implements `append_number_at`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param val f64
 * @return i32
 */
function append_number_at(buf: *u8, cap: i32, off: i32, val: f64): i32 {
  return json_libc_append_number_at_c(buf, cap, off, val);
}
/** Internal function `json_module_anchor`.
 * Implements `json_module_anchor`.
 * @return i32
 */
function json_module_anchor(): i32 { return 0; }
