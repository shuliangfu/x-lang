// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-264 / R2 真迁：pure emit/argv flag helpers。
// 产品 PREFER_X_O：.x 吃满 has_emit + set_use_lto + set_print_target_cpu；
// FROM_X rest 业务符号 H=0（仅前向声明）。
// 🔒 串比较用字节；argv 扫描用尾递归 helper（避免 while+argv[i] 误抬 init_globals）。
// state 布局与 compile.x DriverCompileState 同构。

/** 与 seeds/rt_emit_flags.from_x.c DriverCompileStateSU / compile.x 字段序一致。 */
export struct RtEmitFlagsState {
  path_buf: u8[512];
  path_len: i32;
  out_path_buf: u8[512];
  out_path_len: i32;
  use_asm_backend: i32;
  target_arch: i32;
  target_buf: u8[512];
  target_len: i32;
  opt_level_buf: u8[8];
  opt_level_len: i32;
  use_lto: i32;
  backend_asm_explicit: i32;
  use_freestanding: i32;
  parse_saw_target: i32;
  target_cpu_buf: u8[64];
  target_cpu_len: i32;
  target_cpu_features: i32;
  print_target_cpu: i32;
  parse_saw_target_cpu: i32;
}

/** Return 1 iff NUL-terminated argv token `s` is exactly the two-byte flag "-E".
 * Compares bytes: 45 ('-'), 69 ('E'), 0. Null `s` is not a match.
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_flags_rt_argv_is_minus_E).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_argv_is_minus_E(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  // Exact match for "-E\0" via explicit byte checks (no strcmp).
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 69) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

/** Return 1 iff argv token `s` is exactly "-E-extern" (emit-extern flag).
 * Byte sequence: '-' 'E' '-' 'e' 'x' 't' 'e' 'r' 'n' NUL (45,69,45,101,120,116,101,114,110,0).
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_argv_is_minus_E_extern(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  // Exact match for "-E-extern\0" — nine payload bytes + terminator.
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 69) {
    return 0;
  }
  if (s[2] != 45) {
    return 0;
  }
  if (s[3] != 101) {
    return 0;
  }
  if (s[4] != 120) {
    return 0;
  }
  if (s[5] != 116) {
    return 0;
  }
  if (s[6] != 101) {
    return 0;
  }
  if (s[7] != 114) {
    return 0;
  }
  if (s[8] != 110) {
    return 0;
  }
  if (s[9] != 0) {
    return 0;
  }
  return 1;
}

/** Scan argv[i..argc) for -E or -E-extern; return 1 if either appears.
 * Uses tail recursion with `i` as a parameter (not a local while-index) so codegen
 * does not mis-lift argv indexing into init_globals.
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_flags_rt_scan_argv_emit).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_scan_argv_emit(argc: i32, argv: **u8, i: i32): i32 {
  if (i >= argc) {
    return 0;
  }
  if (rt_argv_is_minus_E(argv[i]) != 0) {
    return 1;
  }
  if (rt_argv_is_minus_E_extern(argv[i]) != 0) {
    return 1;
  }
  // Tail step: advance index via recursive call (param, not mutated local).
  return rt_scan_argv_emit(argc, argv, i + 1);
}

/** argv 是否含 -E / -E-extern（argc/argv 与 libc main 一致）。
 * 注意：勿写 `argv == 0 as **u8`（-E 会整函数丢符号）；null 由调用约定保证。 */
#[no_mangle]
export function driver_argv_has_emit_c_flag(argc: i32, argv: **u8): i32 {
  if (argc < 2) {
    return 0;
  }
  return rt_scan_argv_emit(argc, argv, 1);
}

/** -flto：置 use_lto=1。 */
#[no_mangle]
export function driver_compile_argv_set_use_lto_c(state: *RtEmitFlagsState): void {
  if (state == 0 as *RtEmitFlagsState) {
    return;
  }
  state.use_lto = 1;
}

/** --print-target-cpu：置 print_target_cpu=1。 */
#[no_mangle]
export function driver_compile_argv_set_print_target_cpu_c(state: *RtEmitFlagsState): void {
  if (state == 0 as *RtEmitFlagsState) {
    return;
  }
  state.print_target_cpu = 1;
}
