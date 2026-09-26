// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_std_runtime_fast.x — std.runtime panic and crash-evidence face.
//
// Darwin arm64 product body for ../std/runtime/runtime.o. The six
// wrappers forward to xlang_panic_ and xlang_crash_evidence_collect_c,
// which live in the panic and backtrace objects. Linux and Windows
// keep seeds/runtime_std_runtime_fast.from_x.c on the host-cc path.
// PLATFORM: SHARED wrappers; MACOS|DARWIN arm64 prefers this .x.

/* wave386: pointer-width payload (int or cstr). */
export extern "C" function xlang_panic_(has_msg: i32, msg_val: isize): void;
export extern "C" function xlang_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** Exported function `std_runtime_crash_evidence_collect`.
 * Implements `std_runtime_crash_evidence_collect`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
#[no_mangle]
export function std_runtime_crash_evidence_collect(has_msg: i32, msg_val: i32): void {
  unsafe {
    xlang_crash_evidence_collect_c(has_msg, msg_val);
  }
}

/** Exported function `runtime_crash_evidence_collect_c`.
 * Implements `runtime_crash_evidence_collect_c`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
#[no_mangle]
export function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  std_runtime_crash_evidence_collect(has_msg, msg_val);
}

/** Exported function `std_runtime_runtime_panic`.
 * Implements `std_runtime_runtime_panic`.
 * @return void
 */
#[no_mangle]
export function std_runtime_runtime_panic(): void {
  unsafe {
    xlang_panic_(0, 0);
  }
}

/** Exported function `runtime_panic`.
 * Implements `runtime_panic`.
 * @return void
 */
#[no_mangle]
export function runtime_panic(): void {
  unsafe {
    xlang_panic_(0, 0);
  }
}

/** Exported function `std_runtime_runtime_abort`.
 * Implements `std_runtime_runtime_abort`.
 * @return void
 */
#[no_mangle]
export function std_runtime_runtime_abort(): void {
  unsafe {
    xlang_panic_(0, 0);
  }
}

/** Exported function `runtime_abort`.
 * Implements `runtime_abort`.
 * @return void
 */
#[no_mangle]
export function runtime_abort(): void {
  unsafe {
    xlang_panic_(0, 0);
  }
}
