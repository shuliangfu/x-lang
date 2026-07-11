// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-300 / P2 runtime R9-lite：asm 最小 GAS 桩 + -o 是否可执行 thin 门闩。
// 产品实现：seeds/rt_asm_stub.from_x.c；hybrid 宏 SHUX_RT_ASM_STUB_FROM_X。
//
// 符号：asm_codegen_ast（weak GAS main→42）、driver_asm_output_want_exe。
// 全量 elf/macho codegen 仍 backend / mega。

extern "C" function shux_output_want_exe(path: *u8): i32;

/** -o 路径是否表示可执行（转调 shux_output_want_exe；G-02f-430 已 .x 真迁）。 */
#[no_mangle]
function driver_asm_output_want_exe(path: *u8): i32 {
  unsafe {
    return shux_output_want_exe(path);
  }
  return 0;
}
