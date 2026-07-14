// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-269 / P2 link_abi L2：host 字面量探测 thin shell。
// 产品：PREFER_X_O → g05_try_x_to_o；冷启动 seeds/labi_host_lit.from_x.c。
// hybrid 宏 SHUX_LABI_HOST_LIT_FROM_X。
//
// Track L：真迁 thin 转发（.x 无法表达 C #if host 表）。
//   - shux_host_is_linux → _impl（#if __linux__ 在 mega rest）
//   - shux_host_is_apple_aarch64 → _impl（#if APPLE+aarch64 在 mega rest）
// 与 cfg host lit 双机制一致（f-182）：编译期 #if，非 uname。

export extern "C" function shux_host_is_linux_impl(): i32;
export extern "C" function shux_host_is_apple_aarch64_impl(): i32;

#[no_mangle]
export function shux_host_is_linux(): i32 {
  unsafe {
    return shux_host_is_linux_impl();
  }
  return 0;
}

#[no_mangle]
export function shux_host_is_apple_aarch64(): i32 {
  unsafe {
    return shux_host_is_apple_aarch64_impl();
  }
  return 0;
}

/* Pure audit: number of L2 host-lit thin gates in this slice. */
#[no_mangle]
export function labi_host_lit_count(): i32 {
  return 2;
}
