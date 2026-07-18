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
// See implementation.
//
// See implementation.

/* See implementation. */
export const CTX_OK: i32 = 0;
/* See implementation. */
export const CTX_ERR_NULL: i32 = -1;
/* See implementation. */
export const CTX_CANCELLED: i32 = -2;
/* See implementation. */
export const CTX_DEADLINE: i32 = -3;

/* See implementation. */
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

/** Exported function `background`.
 * Implements `background`.
 * @return Context
 */
export function background(): Context {
  /* See implementation. */
  let _rc: Context = Context { handle: 0 };
  unsafe { _rc = Context { handle: ctx_background_c() }; }
  return _rc;
}

/** Exported function `with_cancel`.
 * Implements `with_cancel`.
 * @param parent Context
 * @return Context
 */
export function with_cancel(parent: Context): Context {
  let _rc: Context = Context { handle: 0 };
  unsafe { _rc = Context { handle: ctx_with_cancel_c(parent.handle) }; }
  return _rc;
}

/** Exported function `with_deadline`.
 * Implements `with_deadline`.
 * @param parent Context
 * @param deadline_ns i64
 * @return Context
 */
export function with_deadline(parent: Context, deadline_ns: i64): Context {
  let _rc: Context = Context { handle: 0 };
  unsafe { _rc = Context { handle: ctx_with_deadline_c(parent.handle, deadline_ns) }; }
  return _rc;
}

/** Exported function `with_timeout`.
 * Implements `with_timeout`.
 * @param parent Context
 * @param timeout_ns i64
 * @return Context
 */
export function with_timeout(parent: Context, timeout_ns: i64): Context {
  let _rc: Context = Context { handle: 0 };
  unsafe { _rc = Context { handle: ctx_with_timeout_c(parent.handle, timeout_ns) }; }
  return _rc;
}

/** Exported function `cancel`.
 * Implements `cancel`.
 * @param ctx Context
 * @return void
 */
export function cancel(ctx: Context): void {
  unsafe {
    ctx_cancel_c(ctx.handle);
  }
}

/** Exported function `is_cancelled`.
 * Query helper `is_cancelled`.
 * @param ctx Context
 * @return i32
 */
export function is_cancelled(ctx: Context): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ctx_is_cancelled_c(ctx.handle); }
  return _rc;
}

/** Exported function `deadline_ns`.
 * Implements `deadline_ns`.
 * @param ctx Context
 * @return i64
 */
export function deadline_ns(ctx: Context): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = ctx_deadline_ns_c(ctx.handle); }
  return _rc;
}

/** Exported function `remaining_ns`.
 * Implements `remaining_ns`.
 * @param ctx Context
 * @return i64
 */
export function remaining_ns(ctx: Context): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = ctx_remaining_ns_c(ctx.handle); }
  return _rc;
}

/** Exported function `set_value`.
 * Implements `set_value`.
 * @param ctx Context
 * @param key *u8
 * @param value i64
 * @return i32
 */
export function set_value(ctx: Context, key: *u8, value: i64): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ctx_set_value_c(ctx.handle, key, value); }
  return _rc;
}

/** Exported function `get_value`.
 * Query helper `get_value`.
 * @param ctx Context
 * @param key *u8
 * @param out *i64
 * @return i32
 */
export function get_value(ctx: Context, key: *u8, out: *i64): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ctx_get_value_c(ctx.handle, key, out); }
  return _rc;
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ctx Context
 * @return void
 */
export function free(ctx: Context): void {
  unsafe {
    ctx_free_c(ctx.handle);
  }
}
