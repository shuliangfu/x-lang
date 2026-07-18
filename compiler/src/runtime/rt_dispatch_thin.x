// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-312/453 → R2 full：分派薄门闩 + full 入口 + shux-c sibling。
// 产品 PREFER_X_O：.x 吃满业务符号；FROM_X rest 仅 marker（业务 H=0）。
// Cap residual（driver_abi）：sibling fork/exec/access/path 拼装（🔒 平台）。
// 产品路径：run_compiler_full 固定走 full_x_impl_c（对齐 ASM_USE_COMPILER_IMPL_C）。
// 冷启动：seeds/rt_dispatch_thin.from_x.c 全 C 体（含非 product ifdef）。

export extern "C" function driver_run_asm_backend_impl_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32, argv: *u8
): i32;
export extern "C" function driver_run_emit_c_path_impl_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8,
  opt_level: *u8, use_lto: i32, argc: i32, argv: *u8
): i32;
export extern "C" function driver_run_compiler_full_x_impl_c(argc: i32, argv: *u8): i32;
/** Cap residual：sibling 平台体（path 拼装 + access + fork/exec/wait）。 */
export extern "C" function driver_dispatch_sibling_try_spawn(argc: i32, argv: *u8): i32;

/** 兼容旧 asm_backend_c 名；转调 impl_c。 */
#[no_mangle]
export function driver_run_asm_backend_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32, argv: *u8
): i32 {
  unsafe {
    return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
  }
  return 0;
}

/** 兼容旧 emit_c_path_c 名；转调 impl_c。 */
#[no_mangle]
export function driver_run_emit_c_path_c(
  input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8,
  opt_level: *u8, use_lto: i32, argc: i32, argv: *u8
): i32 {
  unsafe {
    return driver_run_emit_c_path_impl_c(
      input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv
    );
  }
  return 0;
}

/**
 * 完整编译入口：产品路径固定走 full_x_impl_c。
 * （冷启动 seed 在非 product ifdef 下可走 full_x 别名。）
 */
#[no_mangle]
export function driver_run_compiler_full(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full_x_impl_c(argc, argv);
  }
  return 0;
}

/**
 * 含 import 时 seed X codegen 易重复符号；若同目录有 shux-c 则委托其完成 -o 链接。
 * 返回 ≥0 为子进程 exit；-1 表示未委托（继续本进程路径）。
 * 🔒 path/access/fork/exec 在 Cap residual。
 */
#[no_mangle]
export function driver_try_compile_via_shu_c_sibling(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_dispatch_sibling_try_spawn(argc, argv);
  }
  return 0 - 1;
}
