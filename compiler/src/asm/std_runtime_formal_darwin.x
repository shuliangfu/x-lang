// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_runtime_formal_darwin.x — Darwin arm64 body of std/runtime/runtime.o.
//
// Same four exports as std/runtime/formal_surface.c. Names stay unsuffixed.
// Windows keeps that C face (记218 Linux pure-asm).
// PLATFORM: MACOS|DARWIN|LINUX | LINUX.

/**
 * Report that the runtime face is linked.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN|LINUX
 */
export function std_runtime_ready(): i32 {
  return 0;
}

/**
 * Report that runtime diagnostics are enabled.
 * @return i32 — always 1
 * PLATFORM: MACOS|DARWIN|LINUX
 */
export function std_runtime_diag_enabled(): i32 {
  return 1;
}

/**
 * Accept a diagnostic code and detail. This face does not store them.
 * @param code diagnostic code
 * @param detail diagnostic detail
 * PLATFORM: MACOS|DARWIN|LINUX
 */
export function std_runtime_diag_collect(code: i32, detail: i32): void {
  let _code: i32 = code;
  let _detail: i32 = detail;
  return;
}

/**
 * Accept panic-hook fields. This face does not store them.
 * @param has_msg 1 when a message value is present
 * @param msg_val message value
 * PLATFORM: MACOS|DARWIN|LINUX
 */
export function std_runtime_panic_hook_collect(has_msg: i32, msg_val: i32): void {
  let _has_msg: i32 = has_msg;
  let _msg_val: i32 = msg_val;
  return;
}
