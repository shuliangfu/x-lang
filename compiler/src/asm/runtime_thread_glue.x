// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function shu_cpu_zero_impl(set: *u8): void;
export extern "C" function shu_cpu_set_impl(cpu: u32, set: *u8): void;

/** Exported function `runtime_thread_glue_x_doc_anchor`.
 * Read path helper `runtime_thread_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_thread_glue_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shu_cpu_zero(set: *u8): void {
  unsafe {
    shu_cpu_zero_impl(set);
  }
}

#[no_mangle]
/** Exported function `shu_cpu_set`.
 * Implements `shu_cpu_set`.
 * @param cpu u32
 * @param set *u8
 * @return void
 */
export function shu_cpu_set(cpu: u32, set: *u8): void {
  unsafe {
    shu_cpu_set_impl(cpu, set);
  }
}
