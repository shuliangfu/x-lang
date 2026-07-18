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

// std.result — core.result 用户友好重导出与错误桥接（STD-081）
//
// 【文件职责】
// 重导出 Result 类型族与 eager 组合子；与 std.error 错误码桥接。
//
// 【对标】Rust std::result、Zig 错误返回模型便捷层。

const result = import("core.result");
const error = import("std.error");

/** 构造 Ok(i32)。 */
export function ok(x: i32): Result_i32 { return result.ok(x); }

/** 构造 Err(i32)。 */
export function err(e: i32): Result_i32 { return result.err(e); }

/** 是否 Ok。 */
export function is_ok(r: Result_i32): bool { return result.is_ok(r); }

/** 是否 Err。 */
export function is_err(r: Result_i32): bool { return result.is_err(r); }

/** 成功返回值，否则 default。 */
export function unwrap_or(r: Result_i32, default_val: i32): i32 {
  return result.unwrap_or(r, default_val);
}

/** eager map（Result 侧）。 */
export function map(r: Result_i32, mapped: i32): Result_i32 {
  if (result.is_ok(r)) {
    return result.ok(mapped);
  }
  return result.err(r.err);
}

/** eager and_then（Result 侧）。 */
export function and_then(r: Result_i32, next: Result_i32): Result_i32 {
  if (result.is_ok(r)) {
    return next;
  }
  return result.err(r.err);
}

/** eager or_else（Result 侧）。 */
export function or_else(r: Result_i32, fallback: Result_i32): Result_i32 {
  if (result.is_ok(r)) {
    return r;
  }
  return fallback;
}

/** 从 std.error 风格错误码构造 Result；0=Ok(0)，非 0=Err(code)。 */
export function from_error_code(code: i32): Result_i32 {
  if (code == error.ok()) {
    return result.ok(0);
  }
  return result.err(code);
}

/** 错误码为 0 时 Ok(value)，否则 Err(err_code)。 */
export function from_value(value: i32, err_code: i32): Result_i32 {
  if (err_code == error.ok()) {
    return result.ok(value);
  }
  return result.err(err_code);
}

/** 提取 Result 错误码（Ok 时返回 ok()）。 */
export function err_code(r: Result_i32): i32 {
  if (result.is_ok(r)) {
    return error.ok();
  }
  return r.err;
}
