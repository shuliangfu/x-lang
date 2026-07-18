// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

export extern "C" function build_runtime_info_impl(msg: *u8): void;
export extern "C" function build_runtime_warn_impl(msg: *u8): void;

/** Exported function `build_runtime_x_doc_anchor`.
 * Implements `build_runtime_x_doc_anchor`.
 * @return i32
 */
export function build_runtime_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function build_runtime_info(msg: *u8): void {
  unsafe {
    build_runtime_info_impl(msg);
  }
}

#[no_mangle]
/** Exported function `build_runtime_warn`.
 * Implements `build_runtime_warn`.
 * @param msg *u8
 * @return void
 */
export function build_runtime_warn(msg: *u8): void {
  unsafe {
    build_runtime_warn_impl(msg);
  }
}

// See implementation.

export extern "C" function build_patch_pipeline_gen_c_impl(): i32;
export extern "C" function build_patch_driver_gen_c_impl(): i32;
export extern "C" function build_run_legacy_steps_impl(shu_path: *u8): i32;

/* See implementation. */

#[no_mangle]
export function build_patch_pipeline_gen_c(): i32 { unsafe { return build_patch_pipeline_gen_c_impl(); } return 0; }
#[no_mangle]
/** Exported function `build_patch_driver_gen_c`.
 * Implements `build_patch_driver_gen_c`.
 * @param ) i32 { unsafe { return build_patch_driver_gen_c_impl(
 * @return void
 */
export function build_patch_driver_gen_c(): i32 { unsafe { return build_patch_driver_gen_c_impl(); } return 0; }
#[no_mangle]
/** Exported function `build_run_legacy_steps`.
 * Implements `build_run_legacy_steps`.
 * @param shu_path *u8): i32 { unsafe { return build_run_legacy_steps_impl(shu_path
 * @return void
 */
export function build_run_legacy_steps(shu_path: *u8): i32 { unsafe { return build_run_legacy_steps_impl(shu_path); } return 0; }
