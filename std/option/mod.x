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

// std.option — core.option 用户友好重导出与组合子（STD-080）
//
// 【文件职责】
// 重导出 Option 类型族与 eager 组合子；与 std.result 互转辅助。
// 不重复 core 语义，仅提供 std 层统一 import 入口。
//
// 【对标】Rust std::option、Zig optional 便捷 API。

const core_opt = import("core.option");
const core_res = import("core.result");

/** 构造无值 Option_i32。 */
function none(): Option_i32 { return core_opt.none_i32(); }

/** 构造有值 Option_i32。 */
function some(x: i32): Option_i32 { return core_opt.some_i32(x); }

/** 有值返回值，否则 default。 */
function unwrap_or(opt: Option_i32, default_val: i32): i32 {
  return core_opt.unwrap_or_i32(opt, default_val);
}

/** 是否为 Some。 */
function is_some(opt: Option_i32): bool { return core_opt.is_some_i32(opt); }

/** 是否为 None。 */
function is_none(opt: Option_i32): bool { return core_opt.is_none_i32(opt); }

/** eager map：有值则 some(mapped)，否则 none。 */
function map(opt: Option_i32, mapped: i32): Option_i32 {
  if (core_opt.is_some_i32(opt)) {
    return core_opt.some_i32(mapped);
  }
  return core_opt.none_i32();
}

/** eager and_then：有值则 next，否则 none。 */
function and_then(opt: Option_i32, next: Option_i32): Option_i32 {
  if (core_opt.is_some_i32(opt)) {
    return next;
  }
  return core_opt.none_i32();
}

/** 取第一个 Some，否则 other。 */
function or(opt: Option_i32, other: Option_i32): Option_i32 {
  return core_opt.or_i32(opt, other);
}

/** Result_i32 成功转 Some(value)，失败转 None。 */
function from_result(r: Result_i32): Option_i32 {
  if (core_res.is_ok_i32(r)) {
    return core_opt.some_i32(r.value);
  }
  return core_opt.none_i32();
}

/** Result_u8 成功转 Some，失败转 None。 */
function from_result(r: Result_u8): Option_u8 {
  if (core_res.is_ok_u8(r)) {
    return core_opt.some_u8(r.value);
  }
  return core_opt.none_u8();
}

/** Option 有值转 Ok，None 转 Err(err_if_none)。 */
function to_result(opt: Option_i32, err_if_none: i32): Result_i32 {
  if (core_opt.is_some_i32(opt)) {
    return core_res.ok_i32(opt.value);
  }
  return core_res.err_i32(err_if_none);
}
