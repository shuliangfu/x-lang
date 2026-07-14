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

// std.context — 取消、超时与 deadline 传播（STD-071）
//
// 【文件职责】
// 跨模块统一的 Context 载体：background / with_cancel / with_deadline / with_timeout；
// cancel / is_cancelled；deadline_ns / remaining_ns；轻量键值 bag。
// 实现见 std/context/context.x（F-context v2 纯 .x）；STD-091 io / STD-092 net Context 超时已 gate。
//
// 【所属模块】标准库 std.context；用户通过 import("std.context") 使用。

/** 成功。 */
export const CTX_OK: i32 = 0;
/** 空指针或无效句柄。 */
export const CTX_ERR_NULL: i32 = -1;
/** 上下文已取消。 */
export const CTX_CANCELLED: i32 = -2;
/** 已超过 deadline。 */
export const CTX_DEADLINE: i32 = -3;

/** 不透明上下文句柄（映射 ctx_node*）。 */
export struct Context {
  handle: i64;
}

extern function ctx_background_c(): i64;
extern function ctx_with_cancel_c(parent: i64): i64;
extern function ctx_with_deadline_c(parent: i64, deadline_ns: i64): i64;
extern function ctx_with_timeout_c(parent: i64, timeout_ns: i64): i64;
extern function ctx_cancel_c(handle: i64): void;
extern function ctx_is_cancelled_c(handle: i64): i32;
extern function ctx_deadline_ns_c(handle: i64): i64;
extern function ctx_remaining_ns_c(handle: i64): i64;
extern function ctx_set_value_c(handle: i64, key: *u8, value: i64): i32;
extern function ctx_get_value_c(handle: i64, key: *u8, out: *i64): i32;
extern function ctx_free_c(handle: i64): void;
extern function ctx_smoke_c(): i32;

/** 根上下文：永不取消、无 deadline。 */
export function background(): Context {
  let _rc: Context = 0;
  unsafe { _rc = Context { handle: ctx_background_c() }; }
  return _rc;
}

/** 派生可取消子上下文；失败 handle=0。 */
export function with_cancel(parent: Context): Context {
  let _rc: Context = 0;
  unsafe { _rc = Context { handle: ctx_with_cancel_c(parent.handle) }; }
  return _rc;
}

/** 派生带绝对 deadline（单调纳秒）的子上下文。 */
export function with_deadline(parent: Context, deadline_ns: i64): Context {
  let _rc: Context = 0;
  unsafe { _rc = Context { handle: ctx_with_deadline_c(parent.handle, deadline_ns) }; }
  return _rc;
}

/** 派生相对超时子上下文（now + timeout_ns）。 */
export function with_timeout(parent: Context, timeout_ns: i64): Context {
  let _rc: Context = 0;
  unsafe { _rc = Context { handle: ctx_with_timeout_c(parent.handle, timeout_ns) }; }
  return _rc;
}

/** 取消上下文（本节点及子链查询可见）。 */
export function cancel(ctx: Context): void {
  unsafe {
    ctx_cancel_c(ctx.handle);
  }
}

/** 是否已取消：1 是，0 否。 */
export function is_cancelled(ctx: Context): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ctx_is_cancelled_c(ctx.handle); }
  return _rc;
}

/** 有效 deadline（单调纳秒）；0 表示无 deadline。 */
export function deadline_ns(ctx: Context): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = ctx_deadline_ns_c(ctx.handle); }
  return _rc;
}

/** 剩余时间（纳秒）；已取消或过期返回 0。 */
export function remaining_ns(ctx: Context): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = ctx_remaining_ns_c(ctx.handle); }
  return _rc;
}

/** 设置键值；成功 CTX_OK，槽满 -1。 */
export function set_value(ctx: Context, key: *u8, value: i64): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ctx_set_value_c(ctx.handle, key, value); }
  return _rc;
}

/** 读取键值；找到返回 1 并写 *out，否则 0。 */
export function get_value(ctx: Context, key: *u8, out: *i64): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ctx_get_value_c(ctx.handle, key, out); }
  return _rc;
}

/** 释放派生上下文（不可释放 background）。 */
export function free(ctx: Context): void {
  unsafe {
    ctx_free_c(ctx.handle);
  }
}
