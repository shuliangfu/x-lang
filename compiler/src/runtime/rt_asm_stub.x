// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-300 / P2 runtime R9 → R2 full：asm 最小 GAS 桩 + -o want_exe。
// 产品 PREFER_X_O：.x 吃满业务符号；FROM_X rest 仅 marker（业务 H=0）。
// Cap residual（driver_abi）：GAS 行表 line_at/count + CodegenOutBuf append_cstr
// （.x 禁巨型 data[] 布局写；禁局部 u8[N] 拼行）。
// 全量 elf/macho codegen 仍 backend / mega。
// 冷启动：seeds/rt_asm_stub.from_x.c 全 C 体（含 weak asm_codegen_ast）。

export extern "C" function shux_output_want_exe(path: *u8): i32;
export extern "C" function driver_asm_stub_gas_line_at(i: i32): *u8;
export extern "C" function driver_asm_stub_gas_line_count(): i32;
export extern "C" function driver_asm_stub_out_append_cstr(out: *u8, s: *u8): i32;

/** -o 路径是否表示可执行（转调 shux_output_want_exe）。 */
#[no_mangle]
export function driver_asm_output_want_exe(path: *u8): i32 {
  unsafe {
    return shux_output_want_exe(path);
  }
  return 0;
}

/**
 * asm 后端 C 桩：写出最小 GAS（main return 42）。
 * module/arena 未用；out 为 opaque CodegenOutBuf*（经 Cap residual 写 data/len）。
 */
#[no_mangle]
export function asm_codegen_ast(module: *u8, arena: *u8, out: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  if (out == 0 as *u8) {
    return 0 - 1;
  }
  // silence unused (cold C also voids them)
  if (module == 0 as *u8) {
    // no-op: keep signature isomorphic with seed
  }
  if (arena == 0 as *u8) {
    // no-op
  }
  unsafe {
    n = driver_asm_stub_gas_line_count();
  }
  while (i < n) {
    let line: *u8 = 0 as *u8;
    let rc: i32 = 0;
    unsafe {
      line = driver_asm_stub_gas_line_at(i);
      rc = driver_asm_stub_out_append_cstr(out, line);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    i = i + 1;
  }
  return 0;
}
