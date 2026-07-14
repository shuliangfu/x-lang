// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：build_runtime 产品源迁 seeds/build_runtime.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-105：+ info / warn 薄门闩。

export extern "C" function build_runtime_info_impl(msg: *u8): void;
export extern "C" function build_runtime_warn_impl(msg: *u8): void;

export function build_runtime_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：build_runtime log 门闩 ---- */

#[no_mangle]
export function build_runtime_info(msg: *u8): void {
  unsafe {
    build_runtime_info_impl(msg);
  }
}

#[no_mangle]
export function build_runtime_warn(msg: *u8): void {
  unsafe {
    build_runtime_warn_impl(msg);
  }
}

// G-02f-111：+ patch pipeline/driver gen + legacy steps 薄门闩。

export extern "C" function build_patch_pipeline_gen_c_impl(): i32;
export extern "C" function build_patch_driver_gen_c_impl(): i32;
export extern "C" function build_run_legacy_steps_impl(shu_path: *u8): i32;

/* ---- G-02f-111：build_runtime patch/legacy 门闩 ---- */

#[no_mangle]
export function build_patch_pipeline_gen_c(): i32 { unsafe { return build_patch_pipeline_gen_c_impl(); } return 0; }
#[no_mangle]
export function build_patch_driver_gen_c(): i32 { unsafe { return build_patch_driver_gen_c_impl(); } return 0; }
#[no_mangle]
export function build_run_legacy_steps(shu_path: *u8): i32 { unsafe { return build_run_legacy_steps_impl(shu_path); } return 0; }
