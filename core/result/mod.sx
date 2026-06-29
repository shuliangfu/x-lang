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

// core.result — Result<T,E> 与错误传播（自举前实现）
// Result 寄存器化：双 8 字节槽布局，满足 x86-64 SysV 两寄存器返回（rax/rdx），错误检查零内存访问（见 analysis/Result寄存器化.md）。
// 当前：Result_i32 全系列（ok/err、unwrap_or、is_ok/is_err、expect、expect_i32_or_panic、or/and）；泛型 Result<T,E> 与 map/and_then 待类型实参与函数类型支持后扩展。
// LANG-010 泛型模板（parser 链暂不 import 模板体，避免 parser_gen 未单态化符号）：struct Result<T, E> { value: T; err: E; }

// Result_i32：两对 (i32, padding) 共 16 字节，C 侧两寄存器返回；第二槽 err 为 0 表示成功
allow(padding) struct Result_i32 {
  value: i32;
  _pad1: i32;
  err: i32;
  _pad2: i32;
}

// 构造成功值：第一槽为值，第二槽为 0
function ok(x: i32): Result_i32 {
  return Result_i32 { value: x, _pad1: 0, err: 0, _pad2: 0 }
}

// 构造错误值：第二槽为错误码
function err(e: i32): Result_i32 {
  return Result_i32 { value: 0, _pad1: 0, err: e, _pad2: 0 }
}

// 成功则返回值，否则返回默认值（if/else：seed shux-c C 解析器 return 内三元 ? : 与 expr? 歧义）
function unwrap_or(r: Result_i32, default_val: i32): i32 {
  if (r.err == 0) {
    return r.value;
  }
  return default_val;
}

// 是否为成功
function is_ok(r: Result_i32): bool {
  return r.err == 0;
}

/** 泛型成功判定占位：v1 gate 符号锚点；具象路径用 is_ok。 */
function is_ok_gen(r: Result_i32): bool {
  return is_ok(r);
}

/** 泛型 unwrap_or 占位：v1 gate 符号锚点；具象路径用 unwrap_or。 */
function unwrap_or_gen(r: Result_i32, default_val: i32): i32 {
  return unwrap_or(r, default_val);
}

// 是否为错误
function is_err(r: Result_i32): bool {
  return r.err != 0;
}

// 成功则返回值，否则返回默认值（与 unwrap_or 同义，命名供“期望有默认”的调用方使用）
function expect(r: Result_i32, default_val: i32): i32 {
  if (r.err == 0) {
    return r.value;
  }
  return default_val;
}

// 成功则返回值，否则 panic（用于必须成功的场景）
function expect_or_panic(r: Result_i32): i32 {
  if (r.err == 0) {
    return r.value;
  } else {
    return panic();
  }
}

// 成功则返回本结果，否则返回 other（组合两个结果，取第一个 Ok）
function or(r: Result_i32, other: Result_i32): Result_i32 {
  if (r.err == 0) {
    return r;
  }
  return other;
}

// 失败则返回本结果，否则返回 other（串联：当前成功才继续）
function and(r: Result_i32, other: Result_i32): Result_i32 {
  if (r.err != 0) {
    return r;
  }
  return other;
}

// ——— eager 组合子（CORE-003 map/and_then/or_else） ———

/** 成功则 ok(mapped)，否则保持 err。 */
function map(r: Result_i32, mapped: i32): Result_i32 {
  if (is_ok(r)) {
    return ok(mapped);
  }
  return r;
}

/** 成功则返回 next，否则保持 err。 */
function and_then(r: Result_i32, next: Result_i32): Result_i32 {
  if (is_ok(r)) {
    return next;
  }
  return r;
}

/** 失败则返回 other，否则保持 ok。 */
function or_else(r: Result_i32, other: Result_i32): Result_i32 {
  if (is_err(r)) {
    return other;
  }
  return r;
}

// ——— Result_u8 ———
allow(padding) struct Result_u8 {
  value: u8;
  _pad1: u8;
  _pad2: u8;
  _pad3: u8;
  err: i32;
  _pad4: i32;
}

/** 构造成功 Result_u8。 */
function ok_u8(x: u8): Result_u8 {
  return Result_u8 { value: x, _pad1: 0, _pad2: 0, _pad3: 0, err: 0, _pad4: 0 };
}

/** 构造错误 Result_u8。 */
function err_u8(e: i32): Result_u8 {
  return Result_u8 { value: 0, _pad1: 0, _pad2: 0, _pad3: 0, err: e, _pad4: 0 };
}

/** 成功则返回值，否则 default。 */
function unwrap_or_u8(r: Result_u8, default_val: u8): u8 {
  if (r.err == 0) {
    return r.value;
  }
  return default_val;
}

/** 是否为成功。 */
function is_ok_u8(r: Result_u8): bool {
  return r.err == 0;
}

/** 是否为错误。 */
function is_err_u8(r: Result_u8): bool {
  return r.err != 0;
}

/** 成功则返回值，否则 panic。 */
function expect_u8_or_panic(r: Result_u8): u8 {
  if (r.err == 0) {
    return r.value;
  }
  return panic();
}

/** 成功则 ok(mapped)，否则保持 err。 */
function map_u8(r: Result_u8, mapped: u8): Result_u8 {
  if (is_ok_u8(r)) {
    return ok_u8(mapped);
  }
  return r;
}

/** 失败则返回 other，否则保持 ok。 */
function or_else_u8(r: Result_u8, other: Result_u8): Result_u8 {
  if (is_err_u8(r)) {
    return other;
  }
  return r;
}

// ——— 兼容性别名 ———
function ok_i32(x: i32): Result_i32 { return ok(x); }
function err_i32(e: i32): Result_i32 { return err(e); }
function unwrap_or_i32(r: Result_i32, default_val: i32): i32 { return unwrap_or(r, default_val); }
function is_ok_i32(r: Result_i32): bool { return is_ok(r); }
function is_err_i32(r: Result_i32): bool { return is_err(r); }
function expect_i32(r: Result_i32, default_val: i32): i32 { return expect(r, default_val); }
function expect_i32_or_panic(r: Result_i32): i32 { return expect_or_panic(r); }
function or_i32(r: Result_i32, other: Result_i32): Result_i32 { return or(r, other); }
function and_i32(r: Result_i32, other: Result_i32): Result_i32 { return and(r, other); }
function map_i32(r: Result_i32, mapped: i32): Result_i32 { return map(r, mapped); }
function and_then_i32(r: Result_i32, next: Result_i32): Result_i32 { return and_then(r, next); }
function or_else_i32(r: Result_i32, other: Result_i32): Result_i32 { return or_else(r, other); }

// 泛型占位，表示本模块可 import；完整 Result<T,E> 待类型实参语法后扩展
function result_placeholder<T>(x: T): T { return x; }
/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function result_module_anchor(): i32 { return 0; }
