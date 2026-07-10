// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-34/35：真迁 .x — link_abi 入口转发 / freestanding 探测 / CI skip / bootstrap weak 桩。
// 产品：./shux-c -E → seeds/runtime_link_abi.from_x.c（+ C 尾 + 字符串/签名抛光）。
// C 尾：invoke_cc/ld、路径后缀 is_elf_o/want_exe（索引/usize 语言限制）、object 扫描。
// G-02f-35：+ freestanding needs_io 多符号 OR；bootstrap weak no-op 桩。

extern "C" function main_entry(argc: i32, argv: *u8): i32;
extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;
extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32 {
  unsafe {
    let r: i32 = main_entry(argc, argv);
    return r;
  }
  return 0;
}

#[no_mangle]
function shux_freestanding_user_o_needs_panic(user_o: *u8): i32 {
  unsafe {
    let r: i32 = shux_link_obj_needs_undef_sym(user_o, "shux_panic_");
    return r;
  }
  return 0;
}

#[no_mangle]
function shux_freestanding_user_o_needs_io(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_exit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_open") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_openat") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_mmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_munmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_socket") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_connect") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_bind") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_listen") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_accept") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function invoke_cc_skip_native_tuning(): i32 {
  unsafe {
    let a: *u8 = getenv("CI");
    if (a != 0 as *u8) {
      return 1;
    }
    let b: *u8 = getenv("SHUX_CI_DOCKER");
    if (b != 0 as *u8) {
      return 1;
    }
    let c: *u8 = getenv("SHUX_NO_MARCH_NATIVE");
    if (c != 0 as *u8) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function bootstrap_init_static_tls(): void {
}

#[no_mangle]
function bootstrap_init_environ(argc: i32, argv: *u8): void {
}

#[no_mangle]
function bootstrap_nostdlib_pthread_is_stub(): i32 {
  return 0;
}
