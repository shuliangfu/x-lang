// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-275 / P2 link_abi L6：invoke_ld 纯表（brew -L / compress -l* / tail flags）→ R2 full。
// 产品：PREFER_X_O → g05_try_x_to_o；冷启动 seeds/labi_invoke_ld_list.from_x.c。
// hybrid 宏 SHUX_LABI_INVOKE_LD_LIST_FROM_X（FROM_X rest 业务 H=0，仅 marker）。
//
// R2 full：.x 吃满 brew/compress/tail/driver/entry 纯表。
// Cap residual：spawn/ld/cc IO 仍在 mega shux_asm_invoke_ld_platform / tail_libs（🔒）。
// G-02f-L：真迁 if/else + let 绑定短字符串（依赖 W-string-nul；无全局表）。
// 禁止「函数体仅 return "lit"」——parser 会 skip 整函数；用 let p + return p。

#[no_mangle]
export function labi_ld_brew_lib_path_count(): i32 {
  return 2;
}

#[no_mangle]
export function labi_ld_brew_lib_path_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-L/opt/homebrew/lib";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-L/usr/local/lib";
    return p;
  }
  return 0 as *u8;
}

#[no_mangle]
export function labi_ld_flag_lz(): *u8 {
  let p: *u8 = "-lz";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lzstd(): *u8 {
  let p: *u8 = "-lzstd";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lbrotlienc(): *u8 {
  let p: *u8 = "-lbrotlienc";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lbrotlidec(): *u8 {
  let p: *u8 = "-lbrotlidec";
  return p;
}

#[no_mangle]
export function labi_ld_compress_flag_count(): i32 {
  return 4;
}

#[no_mangle]
export function labi_ld_compress_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-lz";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-lzstd";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-lbrotlienc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-lbrotlidec";
    return p;
  }
  return 0 as *u8;
}

#[no_mangle]
export function labi_ld_flag_lm(): *u8 {
  let p: *u8 = "-lm";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lsqlite3(): *u8 {
  let p: *u8 = "-lsqlite3";
  return p;
}

#[no_mangle]
export function labi_ld_flag_pthread(): *u8 {
  let p: *u8 = "-pthread";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lpthread(): *u8 {
  let p: *u8 = "-lpthread";
  return p;
}

#[no_mangle]
export function labi_ld_flag_ldl(): *u8 {
  let p: *u8 = "-ldl";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lc(): *u8 {
  let p: *u8 = "-lc";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lSystem(): *u8 {
  let p: *u8 = "-lSystem";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lws2_32(): *u8 {
  let p: *u8 = "-lws2_32";
  return p;
}

#[no_mangle]
export function labi_ld_flag_lbcrypt(): *u8 {
  let p: *u8 = "-lbcrypt";
  return p;
}

#[no_mangle]
export function labi_ld_driver_clang(): *u8 {
  let p: *u8 = "clang";
  return p;
}

#[no_mangle]
export function labi_ld_driver_ld(): *u8 {
  let p: *u8 = "ld";
  return p;
}

#[no_mangle]
export function labi_ld_driver_gcc(): *u8 {
  let p: *u8 = "gcc";
  return p;
}

#[no_mangle]
export function labi_ld_driver_cc(): *u8 {
  let p: *u8 = "cc";
  return p;
}

#[no_mangle]
export function labi_ld_mach_entry_main(): *u8 {
  let p: *u8 = "_main";
  return p;
}

#[no_mangle]
export function labi_ld_flag_e(): *u8 {
  let p: *u8 = "-e";
  return p;
}

#[no_mangle]
export function labi_ld_flag_o(): *u8 {
  let p: *u8 = "-o";
  return p;
}

#[no_mangle]
export function labi_ld_common_tail_flag_count(): i32 {
  return 7;
}

#[no_mangle]
export function labi_ld_common_tail_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-lm";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-lsqlite3";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-pthread";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-lpthread";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "-ldl";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "-lc";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "-lSystem";
    return p;
  }
  return 0 as *u8;
}
