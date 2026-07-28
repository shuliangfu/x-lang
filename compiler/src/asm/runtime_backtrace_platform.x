// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_backtrace_platform.x — public API wrappers for backtrace platform glue.
// R2 full mode (wave506): thin layer provides all public API with #[no_mangle];
// rest layer (runtime_backtrace_platform.from_x.c) only keeps OS bridge _impl functions.
// PLATFORM: SHARED — thin wrappers are platform-agnostic; OS-specific logic
//           (execinfo/dladdr/DbgHelp/CaptureStackBackTrace) is isolated in _impl.

/* === OS bridge declarations — _impl functions in runtime_backtrace_platform.from_x.c === */

export extern "C" function backtrace_u8_hex2_impl(b: u8, out: *u8): void;
export extern "C" function backtrace_read_frame_addr_impl(buf: *u8, i: i32): *u8;
export extern "C" function backtrace_write_frame_addr_impl(buf: *u8, i: i32, addr: *u8): void;
export extern "C" function backtrace_copy_sym_name_impl(out: *u8, name_cap: i32, name: *u8): void;
export extern "C" function backtrace_format_hex_addr_impl(out: *u8, cap: i32, addr: *u8): void;
export extern "C" function backtrace_name_has_gold_anchor_impl(name: *u8): i32;
export extern "C" function backtrace_capture_impl(buf: *u8, max_frames: i32): i32;
export extern "C" function backtrace_symbolicate_impl(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max: i32): i32;
export extern "C" function backtrace_gold_anchor_addr_impl(): *u8;
export extern "C" function backtrace_capture_and_check_gold_c_impl(): i32;
export extern "C" function backtrace_xplat_platform_name_impl(): *u8;
export extern "C" function backtrace_xplat_quality_impl(): i32;
export extern "C" function xlang_crash_evidence_collect_impl(has_msg: i32, msg_val: i32): void;

/** Doc anchor for runtime_backtrace_platform module. */
export function runtime_backtrace_platform_x_doc_anchor(): i32 {
  return 0;
}

/* === Public API — thin wrappers delegating to _impl OS bridges === */

/** Convert single byte to two lowercase hex characters.
 * @param b Input byte.
 * @param out Output buffer (must be at least 2 bytes). */
#[no_mangle]
export function backtrace_u8_hex2(b: u8, out: *u8): void {
  unsafe { backtrace_u8_hex2_impl(b, out); }
}

/** Read the i-th frame address from buffer.
 * @param buf Frame buffer.
 * @param i Frame index.
 * @return Frame address pointer, or null on invalid input. */
#[no_mangle]
export function backtrace_read_frame_addr_c(buf: *u8, i: i32): *u8 {
  unsafe { return backtrace_read_frame_addr_impl(buf, i); }
}

/** Write frame address into buffer at position i.
 * @param buf Frame buffer.
 * @param i Frame index.
 * @param addr Address to store. */
#[no_mangle]
export function backtrace_write_frame_addr_c(buf: *u8, i: i32, addr: *u8): void {
  unsafe { backtrace_write_frame_addr_impl(buf, i, addr); }
}

/** Copy symbol name into output buffer (max name_cap-1 bytes + NUL).
 * @param out Output buffer.
 * @param name_cap Capacity of output buffer.
 * @param name Input symbol name. */
#[no_mangle]
export function backtrace_copy_sym_name_c(out: *u8, name_cap: i32, name: *u8): void {
  unsafe { backtrace_copy_sym_name_impl(out, name_cap, name); }
}

/** Format address as hex string (0x...) into output buffer.
 * @param out Output buffer.
 * @param cap Output capacity.
 * @param addr Address to format. */
#[no_mangle]
export function backtrace_format_hex_addr_c(out: *u8, cap: i32, addr: *u8): void {
  unsafe { backtrace_format_hex_addr_impl(out, cap, addr); }
}

/** Check if symbol name contains "gold_anchor" substring.
 * @param name Symbol name to check.
 * @return 1 if contains, 0 otherwise. */
#[no_mangle]
export function backtrace_name_has_gold_anchor_c(name: *u8): i32 {
  unsafe { return backtrace_name_has_gold_anchor_impl(name); }
}

/** Capture current call stack into buffer.
 * @param buf Frame buffer for addresses.
 * @param max_frames Maximum frames to capture.
 * @return Number of frames captured, 0 on failure. */
#[no_mangle]
export function backtrace_capture_c(buf: *u8, max_frames: i32): i32 {
  unsafe { return backtrace_capture_impl(buf, max_frames); }
}

/** Symbolicate captured buffer (resolve addresses to symbol names).
 * @param buf Captured frame address buffer.
 * @param len Number of frames.
 * @param out_ptrs Output pointer buffer (optional).
 * @param out_names Output name buffer.
 * @param max Maximum frames to symbolicate.
 * @return Number of successfully symbolicated frames. */
#[no_mangle]
export function backtrace_symbolicate_c(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max: i32): i32 {
  unsafe { return backtrace_symbolicate_impl(buf, len, out_ptrs, out_names, max); }
}

/** Get address of the gold_anchor symbol (for smoke tests).
 * @return Function pointer to gold_anchor. */
#[no_mangle]
export function backtrace_gold_anchor_addr_c(): *u8 {
  unsafe { return backtrace_gold_anchor_addr_impl(); }
}

/** Capture stack and check for gold_anchor symbol.
 * @return 0 if found, error code otherwise. */
#[no_mangle]
export function backtrace_capture_and_check_gold_c(): i32 {
  unsafe { return backtrace_capture_and_check_gold_c_impl(); }
}

/** Get current platform name string.
 * @return Platform string ("Darwin"/"Windows"/"Linux"/"Unknown"). */
#[no_mangle]
export function backtrace_xplat_platform_name_c(): *u8 {
  unsafe { return backtrace_xplat_platform_name_impl(); }
}

/** Run cross-platform symbol quality probe.
 * @return 0 on success, non-zero on failure. */
#[no_mangle]
export function backtrace_xplat_quality_c(): i32 {
  unsafe { return backtrace_xplat_quality_impl(); }
}

/** Collect crash evidence when XLANG_CRASH_EVIDENCE=1.
 * @param has_msg Whether panic had a message.
 * @param msg_val Message value. */
#[no_mangle]
export function xlang_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  unsafe { xlang_crash_evidence_collect_impl(has_msg, msg_val); }
}

/** Check if symbol name contains gold_anchor (public .x function).
 * @param name Symbol name to check.
 * @return 1 if contains, 0 otherwise. */
#[no_mangle]
export function name_has_gold_anchor(name: *u8): i32 {
  unsafe { return backtrace_name_has_gold_anchor_impl(name); }
}