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
// See implementation.

const context = import("std.context");
const io = import("std.io");
const async_mod = import("std.async");
const net = import("std.net");

/* See implementation. */
allow(padding) struct Trace {
  handle: i64;
}

/* See implementation. */
allow(padding) struct Span {
  id: i64;
}

/* See implementation. */
allow(padding) struct TraceId {
  bytes: u8[16];
}

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
/** Exported function `err_full`.
 * Implements `err_full`.
 * @return i32
 */
export function err_full(): i32 { return -3; }
/** Exported function `err_invalid`.
 * Implements `err_invalid`.
 * @return i32
 */
export function err_invalid(): i32 { return -4; }

extern function create_c(): i64;
extern function free_c(handle: i64): void;
extern function trace_id_c(handle: i64, out16: *u8): void;
extern function current_span_c(handle: i64): i64;
extern function start_span_c(handle: i64, parent_id: i64, name: *u8, name_len: i32): i64;
extern function end_span_c(handle: i64, span_id: i64): i32;
extern function start_child_c(handle: i64, name: *u8, name_len: i32): i64;
extern function span_count_c(handle: i64): i32;
extern function export_text_c(handle: i64, out: *u8, out_cap: i32): i32;

/** Exported function `new`.
 * Implements `new`.
 * @return Trace
 */
export function new(): Trace {
  let h: i64 = 0;
  unsafe { h = create_c(); }
  return Trace { handle: h };
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param tr *Trace
 * @return void
 */
export function free(tr: *Trace): void {
  let zero: i64 = 0;
  if (tr == 0) { return; }
  if (tr.handle != zero) {
    unsafe { free_c(tr.handle); }
    tr.handle = zero;
  }
}

/** Exported function `id`.
 * Implements `id`.
 * @param tr *Trace
 * @param out *TraceId
 * @return void
 */
export function id(tr: *Trace, out: *TraceId): void {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero || out == 0) { return; }
  unsafe { trace_id_c(tr.handle, &out.bytes[0]); }
}

/** Exported function `current_span`.
 * Implements `current_span`.
 * @param tr *Trace
 * @return i64
 */
export function current_span(tr: *Trace): i64 {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero) { return zero; }
  unsafe { return current_span_c(tr.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `start`.
 * Implements `start`.
 * @param tr *Trace
 * @param parent_id i64
 * @param name *u8
 * @param name_len i32
 * @return Span
 */
export function start(tr: *Trace, parent_id: i64, name: *u8, name_len: i32): Span {
  let zero: i64 = 0;
  let sid: i64 = zero;
  if (tr == 0 || tr.handle == zero || name == 0) {
    return Span { id: zero };
  }
  unsafe { sid = start_span_c(tr.handle, parent_id, name, name_len); }
  return Span { id: sid };
}

/** Exported function `start_child`.
 * Implements `start_child`.
 * @param tr *Trace
 * @param name *u8
 * @param name_len i32
 * @return Span
 */
export function start_child(tr: *Trace, name: *u8, name_len: i32): Span {
  let zero: i64 = 0;
  let sid: i64 = zero;
  if (tr == 0 || tr.handle == zero || name == 0) {
    return Span { id: zero };
  }
  unsafe { sid = start_child_c(tr.handle, name, name_len); }
  return Span { id: sid };
}

/** Exported function `end`.
 * Implements `end`.
 * @param tr *Trace
 * @param sp Span
 * @return i32
 */
export function end(tr: *Trace, sp: Span): i32 {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero || sp.id == zero) { return err_null(); }
  unsafe { return end_span_c(tr.handle, sp.id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `count`.
 * Implements `count`.
 * @param tr *Trace
 * @return i32
 */
export function count(tr: *Trace): i32 {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero) { return err_null(); }
  unsafe { return span_count_c(tr.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `export_text`.
 * Implements `export_text`.
 * @param tr *Trace
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function export_text(tr: *Trace, out: *u8, out_cap: i32): i32 {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero || out == 0) { return err_null(); }
  unsafe { return export_text_c(tr.handle, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `attach`.
 * Implements `attach`.
 * @param ctx Context
 * @param tr Trace
 * @return i32
 */
export function attach(ctx: Context, tr: Trace): i32 {
  let k: u8[6] = [116, 114, 97, 99, 101, 0];
  return context.set_value(ctx, &k[0], tr.handle);
}

/** Exported function `from_ctx`.
 * Implements `from_ctx`.
 * @param ctx Context
 * @return Trace
 */
export function from_ctx(ctx: Context): Trace {
  let zero: i64 = 0;
  let h: i64 = zero;
  let tr: Trace = Trace { handle: zero };
  let k: u8[6] = [116, 114, 97, 99, 101, 0];
  if (context.get_value(ctx, &k[0], &h) != 0) {
    tr.handle = h;
  }
  return tr;
}

/* See implementation. */

/**
 * See implementation.
 * See implementation.
 */
export function hook_begin(tr: *Trace, name: *u8, name_len: i32): Span {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero || name == 0) {
    return Span { id: zero };
  }
  return start_child(tr, name, name_len);
}

/**
 * See implementation.
 */
export function hook_end(tr: *Trace, sp: Span): i32 {
  let zero: i64 = 0;
  if (tr == 0 || tr.handle == zero || sp.id == zero) {
    return err_ok();
  }
  return end(tr, sp);
}

/** Exported function `io_read`.
 * Read path helper `io_read`.
 * @param ctx Context
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function io_read(ctx: Context, handle: usize, ptr: *u8, len: usize): i32 {
  let tr: Trace = from_ctx(ctx);
  let n_io_read: u8[7] = [105, 111, 46, 114, 101, 97, 100];
  let sp: Span = hook_begin(&tr, &n_io_read[0], 7);
  let r: i32 = io.read_ctx(handle, ptr, len, ctx);
  hook_end(&tr, sp);
  return r;
}

/** Exported function `io_write`.
 * Write path helper `io_write`.
 * @param ctx Context
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function io_write(ctx: Context, handle: usize, ptr: *u8, len: usize): i32 {
  let tr: Trace = from_ctx(ctx);
  let n_io_write: u8[8] = [105, 111, 46, 119, 114, 105, 116, 101];
  let sp: Span = hook_begin(&tr, &n_io_write[0], 8);
  let r: i32 = io.write_ctx(handle, ptr, len, ctx);
  hook_end(&tr, sp);
  return r;
}

/** Exported function `net_connect`.
 * Implements `net_connect`.
 * @param ctx Context
 * @param addr Ipv4Addr
 * @param port u32
 * @return i32
 */
export function net_connect(ctx: Context, addr: Ipv4Addr, port: u32): i32 {
  let tr: Trace = from_ctx(ctx);
  let n_net_conn: u8[11] = [110, 101, 116, 46, 99, 111, 110, 110, 101, 99, 116];
  let sp: Span = hook_begin(&tr, &n_net_conn[0], 11);
  let fd: i32 = net.connect_ctx_fd(addr, port, ctx);
  hook_end(&tr, sp);
  return fd;
}

/** Exported function `net_read`.
 * Read path helper `net_read`.
 * @param ctx Context
 * @param stream TcpStream
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function net_read(ctx: Context, stream: TcpStream, ptr: *u8, len: usize): i32 {
  let tr: Trace = from_ctx(ctx);
  let n_net_rd: u8[15] = [110, 101, 116, 46, 115, 116, 114, 101, 97, 109, 95, 114, 101, 97, 100];
  let sp: Span = hook_begin(&tr, &n_net_rd[0], 15);
  let r: i32 = net.read_ctx(stream, ptr, len, ctx);
  hook_end(&tr, sp);
  return r;
}

/** Exported function `async_drain`.
 * Implements `async_drain`.
 * @param ctx Context
 * @param rt *AsyncRuntime
 * @return i32
 */
export function async_drain(ctx: Context, rt: *AsyncRuntime): i32 {
  let tr: Trace = from_ctx(ctx);
  let n_async: u8[11] = [97, 115, 121, 110, 99, 46, 100, 114, 97, 105, 110];
  let sp: Span = hook_begin(&tr, &n_async[0], 11);
  let r: i32 = async_mod.drain(rt);
  hook_end(&tr, sp);
  return r;
}

extern function hooks_smoke_c(): i32;

/** Exported function `hooks_smoke`.
 * Implements `hooks_smoke`.
 * @return i32
 */
export function hooks_smoke(): i32 {
  unsafe { return hooks_smoke_c(); }
  return 0; // unreachable — typeck workaround
}
